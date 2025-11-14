Set-StrictMode -Version Latest
param(
  [Parameter(Mandatory)][string]$SessionPlanPath,
  [switch]$Lenient
)
$ErrorActionPreference='Stop'

if(!(Test-Path $SessionPlanPath)){
  if($Lenient){ return [pscustomobject]@{ WavesLeft=$null; Progress=0; DeadlineUtc=$null; Drift=0; Context="" } }
  throw "Plan not found: $SessionPlanPath"
}

$plan = Get-Content -Raw $SessionPlanPath | ConvertFrom-Json
$wavesTotal = [int]($plan.waves_total ?? 0)
$wavesDone  = [int]($plan.waves_done  ?? 0)
$deadline   = if($plan.deadline_utc){ [datetime]::Parse($plan.deadline_utc) } else { $null }
$cadMin     = if($plan.cadence_minutes){ [double]$plan.cadence_minutes } else { $null }

$drift = 0
if($plan.start_utc -and $cadMin){
  $start = [datetime]::Parse($plan.start_utc)
  $elapsedWaves = [math]::Floor( ((Get-Date).ToUniversalTime() - $start).TotalMinutes / $cadMin )
  $drift = $elapsedWaves - $wavesDone
}

$progress  = if($wavesTotal -gt 0){ [math]::Min(1,[math]::Max(0,$wavesDone / $wavesTotal)) } else { 0 }
$wavesLeft = if($wavesTotal -ge $wavesDone){ $wavesTotal - $wavesDone } else { 0 }

# Try to capture branch/PR context (best-effort; tolerate GH-less envs)
$branch  = (git rev-parse --abbrev-ref HEAD 2>$null)
$prjson  = (& gh pr view --json number 2>$null)
$prnum   = if($LASTEXITCODE -eq 0 -and $prjson){ ($prjson | ConvertFrom-Json).number } else { $null }
$context = @($branch, if($prnum){"#${prnum}"}) -join ''

[pscustomobject]@{
  WavesLeft   = $wavesLeft
  Progress    = $progress
  DeadlineUtc = $deadline
  Drift       = $drift
  Context     = $context
}