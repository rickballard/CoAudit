$ErrorActionPreference='Stop'
$root = Split-Path $PSCommandPath -Parent | Split-Path -Parent
$eaudir = Join-Path $root '60_DATA\advisories'
$idxdir = Join-Path $root '60_DATA\indices'
New-Item -ItemType Directory -Force $idxdir | Out-Null
$items = @()
if(Test-Path $eaudir){
  $items = Get-ChildItem $eaudir -Filter '*.eau.json' | Get-Content | ForEach-Object { $_ | ConvertFrom-Json }
}
$items | ConvertTo-Json -Depth 10 | Set-Content -Encoding UTF8 (Join-Path $idxdir 'ADVICE_INDEX.json')
$md = @("# Advisory Index","")
foreach($i in ($items | Sort-Object id)){ $md += "- **$($i.id)** — $($i.title)  _(status: $($i.status))_" }
$md_text = if($md.Count -gt 2){ $md -join [Environment]::NewLine } else { "# Advisory Index`n*(no advisories yet)*" }
$md_text | Set-Content -Encoding UTF8 (Join-Path $idxdir 'ADVICE_INDEX.md')
Write-Host "Index written."
