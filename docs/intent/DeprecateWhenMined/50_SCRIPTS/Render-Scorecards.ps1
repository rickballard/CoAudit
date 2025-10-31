$ErrorActionPreference='Stop'
$root = Split-Path $PSCommandPath -Parent | Split-Path -Parent
$repdir = Join-Path $root '60_DATA\replies'
$scroot = Join-Path $root '60_DATA\scorecards'
$scdir  = Join-Path $scroot 'repos'
New-Item -ItemType Directory -Force $scdir | Out-Null

$replies = @()
if(Test-Path $repdir){
  Get-ChildItem $repdir -Filter '*.reply.json' -ErrorAction SilentlyContinue |
    ForEach-Object {
      $raw = Get-Content $_.FullName -Raw
      if([string]::IsNullOrWhiteSpace($raw)){ return }
      if(-not ($raw | Test-Json -ErrorAction SilentlyContinue)){ return }
      try { $replies += ($raw | ConvertFrom-Json) } catch {}
    }
}

$byRepo = $replies | Group-Object repo
foreach($g in $byRepo){
  $accepted = ($g.Group | Where-Object { $_.resolution -in @('accepted','partially_accepted') }).Count
  $total = $g.Count
  $score = if($total -gt 0){ [math]::Round(($accepted/$total)*100,0) } else { 0 }
  @{ repo=$g.Name; total=$total; accepted=$accepted; score=$score } |
    ConvertTo-Json | Set-Content -Encoding UTF8 (Join-Path $scdir "$($g.Name).score.json")
}

$avg = 0
if($byRepo.Count -gt 0){
  $scores = foreach($g in $byRepo){
    (Get-Content (Join-Path $scdir "$($g.Name).score.json") | ConvertFrom-Json).score
  }
  $avg = [math]::Round( ($scores | Measure-Object -Average).Average, 0 )
}

"# CoSuite Advisory Closure Score`n`nOrg score: **$avg%**" |
  Set-Content -Encoding UTF8 (Join-Path $scroot 'ORG_SCORECARD.md')

Write-Host "Scorecards rendered."
