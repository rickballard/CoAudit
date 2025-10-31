$ErrorActionPreference="Stop"
$root  = Split-Path $PSCommandPath -Parent | Split-Path -Parent
$eaudir= Join-Path $root "60_DATA\advisories"
$idxdir= Join-Path $root "60_DATA\indices"
New-Item -ItemType Directory -Force $idxdir | Out-Null

$items = @()
if(Test-Path $eaudir){
  Get-ChildItem $eaudir -Filter "*.eau.json" -File | ForEach-Object {
    $raw = Get-Content $_.FullName -Raw
    if([string]::IsNullOrWhiteSpace($raw)){ return }
    if(-not ($raw | Test-Json -ErrorAction SilentlyContinue)){ return }
    try{ $items += ($raw | ConvertFrom-Json) }catch{}
  }
}

$items | ConvertTo-Json -Depth 10 | Set-Content -Encoding UTF8 (Join-Path $idxdir "ADVICE_INDEX.json")
$md = @("# Advisory Index","")
foreach($i in ($items | Sort-Object id)){ $md += "- **$($i.id)** — $($i.title)  _(status: $($i.status))_" }
if($md.Count -le 2){ $md = @("# Advisory Index","*(no advisories yet)*") }
$md -join [Environment]::NewLine | Set-Content -Encoding UTF8 (Join-Path $idxdir "ADVICE_INDEX.md")
Write-Host "Index written."
