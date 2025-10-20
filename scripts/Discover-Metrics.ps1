param(
  [Parameter(Mandatory=$true)][string]$Owner,
  [Parameter(Mandatory=$false)][string]$Token = $env:GITHUB_TOKEN,
  [Parameter(Mandatory=$false)][string]$Root = "$HOME\Documents\GitHub",
  [Parameter(Mandatory=$false)][switch]$ShallowClone
)

$ErrorActionPreference = "Stop"

# Token is optional for public repos (lower rate limits)
if (-not $Token) {
  Write-Warning "No GITHUB_TOKEN provided. Running unauthenticated (lower rate limits)."
}

# Output dirs
$reportDir = Join-Path $PSScriptRoot ("../reports/{0}" -f (Get-Date -Format 'yyyy-MM-dd'))
$cardsDir  = Join-Path $reportDir "cards"
$streamDir = Join-Path $PSScriptRoot "../reports/stream"
New-Item -ItemType Directory -Force -Path $reportDir, $cardsDir, $streamDir | Out-Null

function Invoke-GHGet([string]$Url) {
  $Headers = @{ 'User-Agent' = 'CoAudit' }
  if ($Token) { $Headers['Authorization'] = "Bearer $Token" }
  return Invoke-RestMethod -Headers $Headers -Uri $Url -Method Get
}

# 1) List public source repos for owner
$per_page = 100
$page = 1
$repos = @()
do {
  $url = "https://api.github.com/users/$Owner/repos?type=source&per_page=$per_page&page=$page"
  $batch = Invoke-GHGet $url
  if (-not $batch -or $batch.Count -eq 0) { break }
  $repos += $batch
  $page += 1
} while ($true)

$records = @()

foreach ($r in $repos) {
  $name = $r.name
  $cloneUrl = $r.clone_url
  $local = Join-Path $Root $name

  if (-not (Test-Path $local)) {
    if ($ShallowClone) {
      git clone --depth=1 $cloneUrl $local 2>$null
    } else {
      git clone $cloneUrl $local 2>$null
    }
  }

  if (Test-Path $local) {
    Push-Location $local
    try {
      git fetch --all --prune 2>$null
      git checkout $r.default_branch 2>$null
      git pull 2>$null
    } finally { Pop-Location }
  } else {
    Write-Warning "Clone failed or repo missing: $name ($cloneUrl). Skipping."
    continue
  }

  Push-Location $local
  try {
    $sha = (git rev-parse --short HEAD).Trim()

    # METRICS_INDEX.md
    Get-ChildItem -Recurse -Filter 'METRICS_INDEX.md' -ErrorAction SilentlyContinue | ForEach-Object {
      $text = Get-Content $_.FullName -Raw
      if ($text -match '\|\s*(id|metric|kpi)\s*\|\s*(name|title)\s*\|') {
        $lines = $text -split "`n"
        foreach ($line in $lines) {
          if ($line -match '^\|' -and $line -notmatch '^\|[-:]') {
            $cols = ($line.Trim('|').Split('|') | ForEach-Object { $_.Trim() })
            if ($cols.Count -ge 2 -and $cols[0] -notin @('id','metric','kpi')) {
              $records += [pscustomobject]@{
                repo=$name; sha=$sha; source='METRICS_INDEX.md'; id=$cols[0]; name=$cols[1]; status='in_use'; evidence=$_.FullName
              }
            }
          }
        }
      }
    }

    # *.metrics.(yml|yaml|json)
    Get-ChildItem -Recurse -Include *.metrics.yml,*.metrics.yaml,*.metrics.json -ErrorAction SilentlyContinue | ForEach-Object {
      $path = $_.FullName
      $content = Get-Content $path -Raw
      $id = if ($content -match '(?m)^\s*id:\s*"?([^"#]+)"?') { $Matches[1].Trim() } else { [IO.Path]::GetFileNameWithoutExtension($path) }
      $records += [pscustomobject]@{repo=$name; sha=$sha; source='metrics_file'; id=$id; name=$id; status='in_use'; evidence=$path}
    }

    # INTENT manifests (planned_metrics)
    Get-ChildItem -Recurse -Include INTENT.yml,INTENT.yaml,manifest.json -ErrorAction SilentlyContinue | ForEach-Object {
      $text = Get-Content $_.FullName -Raw
      if ($text -match '(?m)^\s*planned_metrics:') {
        $records += [pscustomobject]@{repo=$name; sha=$sha; source='intent'; id='(various)'; name='planned_metrics'; status='planned'; evidence=$_.FullName}
      }
    }

    # Workflows producing reports/*
    Get-ChildItem -Recurse -Path .github/workflows -Include *.yml,*.yaml -ErrorAction SilentlyContinue | ForEach-Object {
      $wf = Get-Content $_.FullName -Raw
      if ($wf -match 'reports\/.*\.(json|csv|ndjson)') {
        $records += [pscustomobject]@{repo=$name; sha=$sha; source='workflow'; id='(artifact)'; name='artifact_emission'; status='in_use'; evidence=$_.FullName}
      }
    }
  } finally {
    Pop-Location
  }
}

# Write outputs
$discoveryPath = Join-Path $reportDir 'metrics.discovery.json'
$records | ConvertTo-Json -Depth 8 | Out-File $discoveryPath -Encoding utf8

# Simple registry normalization (dedupe on repo+id+status)
$registry = $records | Group-Object repo, id, status | ForEach-Object {
  $first = $_.Group[0]
  [pscustomobject]@{
    repo = $first.repo
    id   = $first.id
    name = $first.name
    status = $first.status
    evidence = ($_.Group | Select-Object -ExpandProperty evidence | Select-Object -Unique)
  }
}

$registryPath = Join-Path $reportDir 'metrics.registry.json'
$registry | ConvertTo-Json -Depth 8 | Out-File $registryPath -Encoding utf8

# Emit NDJSON stream for CoCache append
$nd = Join-Path $streamDir ('metrics.{0}.ndjson' -f (Get-Date -Format 'yyyyMMdd'))
$registry | ForEach-Object { $_ | ConvertTo-Json -Compress } | Set-Content -Path $nd -Encoding utf8

Write-Host "Discovery complete. See:`n $discoveryPath`n $registryPath`n $nd"
