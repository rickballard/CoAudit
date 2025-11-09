$ErrorActionPreference='Stop'

$root   = Split-Path $PSScriptRoot -Parent   # 50_SCRIPTS -> (.. = DWM root)
$eaudir = Join-Path $root '60_DATA\advisories'
$repdir = Join-Path $root '60_DATA\replies'
$idxps1 = Join-Path (Join-Path $root '50_SCRIPTS') 'Compile-AdviceIndex.ps1'
$scps1  = Join-Path (Join-Path $root '50_SCRIPTS') 'Render-Scorecards.ps1'

$bad = @()

# 1) Validate *.eau.json
if(Test-Path $eaudir){
  Get-ChildItem $eaudir -Filter '*.eau.json' -File | ForEach-Object {
    $raw = Get-Content $_.FullName -Raw
    if([string]::IsNullOrWhiteSpace($raw) -or -not ($raw | Test-Json -EA SilentlyContinue)){
      $bad += "EAU invalid: $($_.Name)"
    }
  }
}

# 2) Validate *.reply.json
if(Test-Path $repdir){
  Get-ChildItem $repdir -Filter '*.reply.json' -File -EA SilentlyContinue | ForEach-Object{
    $raw = Get-Content $_.FullName -Raw
    if([string]::IsNullOrWhiteSpace($raw) -or -not ($raw | Test-Json -EA SilentlyContinue)){
      $bad += "Reply invalid: $($_.Name)"
    }
  }
}

# 3) Rebuild index & scorecards (already hardened to skip bad JSON)
pwsh -NoProfile -File $idxps1 | Out-Host
pwsh -NoProfile -File $scps1  | Out-Host

if($bad.Count){
  Write-Error ("DWM health failures:`n - " + ($bad -join "`n - "))
}else{
  Write-Host "DWM health OK" -ForegroundColor Green
}
