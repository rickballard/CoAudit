$ErrorActionPreference="Stop"
$root = Split-Path $PSCommandPath -Parent | Split-Path -Parent
$paths = @(
  Join-Path $root "60_DATA\advisories\*.eau.json",
  Join-Path $root "60_DATA\replies\*.reply.json"
)
$bad = @()
foreach($p in $paths){
  foreach($f in (Get-ChildItem $p -ErrorAction SilentlyContinue)){
    $raw = Get-Content $f.FullName -Raw
    if([string]::IsNullOrWhiteSpace($raw) -or -not ($raw | Test-Json -ErrorAction SilentlyContinue)){
      $bad += $f.FullName
    }
  }
}
if($bad.Count){ Write-Error "Invalid JSON files:`n$($bad -join "`n")" } else { Write-Host "All advisory/reply JSON valid." }
