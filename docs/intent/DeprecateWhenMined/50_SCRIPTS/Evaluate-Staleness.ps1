$ErrorActionPreference='Stop'
$root = Split-Path $PSCommandPath -Parent | Split-Path -Parent
$eaudir = Join-Path $root '60_DATA\advisories'
if(Test-Path $eaudir){
  Get-ChildItem $eaudir -Filter '*.eau.json' | ForEach-Object {
    $o = Get-Content $_.FullName | ConvertFrom-Json
    if(-not $o.freshness){ return }
    $updated = Get-Date $o.updated
    $days = (Get-Date) - $updated
    if($days.Days -ge $o.freshness.review_in_days){ $o.status = 'stale' }
    ($o | ConvertTo-Json -Depth 10) | Set-Content -Encoding UTF8 $_.FullName
  }
}
Write-Host "Staleness evaluated."
