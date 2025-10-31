param(
  [Parameter(Mandatory)][string]$AdvisoryId,
  [Parameter(Mandatory)][string]$Repo,
  [Parameter(Mandatory)][ValidateSet("accepted","partially_accepted","deferred","rejected","superseded")] [string]$Resolution,
  [string]$Actor = $env:USERNAME,
  [string]$Notes = "",
  [string[]]$EvidenceLinks = @(),
  [string[]]$Hashes = @()
)
$ErrorActionPreference='Stop'
$root = Split-Path $PSCommandPath -Parent | Split-Path -Parent
$schema = Join-Path $root '40_SCHEMAS\reply.schema.json'
$repdir = Join-Path $root '60_DATA\replies'
New-Item -ItemType Directory -Force $repdir | Out-Null
$now = (Get-Date).ToString('o')
$obj = [ordered]@{
  advisory_id=$AdvisoryId; repo=$Repo; actor=$Actor; timestamp=$now;
  resolution=$Resolution; notes=$Notes; evidence_links=$EvidenceLinks; hashes=$Hashes
}
$tmp = Join-Path $env:TEMP ("{0}.{1}.reply.json" -f $AdvisoryId,$Repo.Replace('/','_'))
$obj | ConvertTo-Json -Depth 10 | Set-Content -Encoding UTF8 $tmp
if(-not ((Get-Content $tmp -Raw) | Test-Json)){ throw "Reply JSON failed basic validation." }
$dest = Join-Path $repdir (Split-Path $tmp -Leaf)
Move-Item $tmp $dest -Force
Write-Host "Created reply:" $dest
