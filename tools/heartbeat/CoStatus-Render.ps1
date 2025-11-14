Set-StrictMode -Version Latest
param(
  [Parameter(Mandatory)][string]$SessionPlanPath,
  [string]$OutPath = "docs/ops/costatus/SAMPLE.txt",
  [switch]$Lenient
)
$ErrorActionPreference='Stop'

$inputs = Join-Path $PSScriptRoot 'CoStatus-Inputs.ps1'
if(!(Test-Path $inputs)){ throw "Missing helper: $inputs" }

$i = & $inputs -SessionPlanPath $SessionPlanPath -Lenient:$Lenient

# Placeholder level mapping — Co1 will own this policy later
$levels = @{ CU='OK'; PU='SOFT'; HU='OK'; WT='SOFT' }

# progress -> 8-cell bar
$prog   = [double]($i.Progress ?? 0)
if($prog -lt 0){ $prog = 0 } elseif($prog -gt 1){ $prog = 1 }
$filled = [int]([math]::Round($prog * 8))
if($filled -lt 0){ $filled = 0 } elseif($filled -gt 8){ $filled = 8 }
$bar = ('▓'*$filled)+('░'*(8-$filled))

# countdown (T±hh:mm)
if($i.DeadlineUtc){
  $span = ([datetime]$i.DeadlineUtc - (Get-Date).ToUniversalTime())
  $sign = if($span.TotalMinutes -ge 0){'+'}else{'-'}
  $t = 'T{0}{1:hh\:mm}' -f $sign, $span.Duration()
}else{
  $t = 'T+00:00'
}

# drift
$dr    = [int]($i.Drift ?? 0)
$drift = ('{0}{1}' -f ($(if($dr -ge 0){'+'}else{'-'})), [math]::Abs($dr))

$ctx = ($i.Context ?? '').ToString()

$line = "CoStatus: [CU {0}][PU {1}][HU {2}][WT {3}]  {4}  Drift {5}  {6}  {7}" -f `
        $levels.CU,$levels.PU,$levels.HU,$levels.WT,$t,$drift,$bar,$ctx

[IO.File]::WriteAllText($OutPath,$line,[Text.UTF8Encoding]::new($false))
Write-Host "Emitted CoStatus => $OutPath"
Write-Host "  $line"