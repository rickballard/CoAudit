param([string]$Id,[string]$Title,[string]$Rationale,[string[]]$Repos)
$ErrorActionPreference='Stop'
$base = Split-Path $PSCommandPath -Parent | Split-Path -Parent
$eaudir = Join-Path $base '60_DATA\advisories'
New-Item -ItemType Directory -Force $eaudir | Out-Null
$now = (Get-Date).ToString('o')
$eau = [ordered]@{
  id=$Id; title=$Title; created=$now; updated=$now; version='0.1.0'
  scope=@{ repos=$Repos; tags=@() }
  rationale=$Rationale; comparators=@(); proposed_actions=@()
  copy_paste=@{ issue_text_path='70_TEMPLATES/ISSUE_TEXT_TEMPLATE.md'; pr_text_path='70_TEMPLATES/PR_TEXT_TEMPLATE.md'; files_to_add=@() }
  evidence=@(); provenance=@{ sources=@(); confidence='medium' }
  freshness=@{ review_in_days=30; expires_after_days=120 }
  status='draft'
}
$path = Join-Path $eaudir "$Id.eau.json"
$eau | ConvertTo-Json -Depth 8 | Set-Content -Encoding UTF8 $path
Write-Host "Created $path"
