<<<<<<< HEAD
=======
[![CoAudit Advisory Nightly](https://github.com/rickballard/CoAudit/actions/workflows/coaudit-advice-nightly.yml/badge.svg)](https://github.com/rickballard/CoAudit/actions/workflows/coaudit-advice-nightly.yml)

>>>>>>> origin/main
<!-- DWM:BEGIN -->
## 🚨 CoPrime: DeprecateWhenMined Advisory Sandbox

A **hands-off** CoAudit sandbox for *Evolutionary Advisory Units (EAUs)* is available.  
**Mine** it for actionable guidance across the CoSuite, then **delete it** when done.

**Start here (absolute link):**  
https://github.com/rickballard/CoAudit/blob/main/docs/intent/DeprecateWhenMined/README.md

**What you’ll find**
- Charter (hands-off rules), strategy, comparators  
- JSON schemas for advisories & replies  
- Read-only PS7 scripts to compile the advice index & scorecards  
- Copy-paste Issue/PR templates for executing sessions  
- A deprecation checklist to remove the folder once mined

> CoAudit observes → compares → advises → measures. It makes **no changes** to other repos.
<!-- DWM:END -->

# CoAudit (Bootstrap)

Read‑only auditor for the CoSuite. This repository **never writes** to other repos.
It crawls public CoSuite repositories, discovers metrics in use/planned/missing, validates
intent manifests, and emits **advisory reports** as artifacts and JSON under `/reports/`.

## Safety stance
- Uses a **read‑only token** (repo:public_repo or contents:read). No PRs, no pushes.
- Local scripts only **clone/fetch**. No git config changes in target repos.
- CI workflow permissions set to `contents: read` and `pull-requests: read` only.

## Quick start (local)
1. Create a GitHub fine‑grained PAT with **read‑only** access to your public repos.
2. `pwsh -File scripts/Discover-Metrics.ps1 -Owner rickballard -Token $env:GITHUB_TOKEN`
3. Results appear in `reports/2025-10-19/` and as ndjson in `reports/stream/`.

## Outputs
- `reports/YYYY-MM-DD/metrics.discovery.json` — raw discovered signals
- `reports/YYYY-MM-DD/metrics.registry.json` — normalized registry (in_use/planned/missing)
- `reports/YYYY-MM-DD/repo.<name>.metrics.json` — per‑repo summary
- `reports/cards/*.md` — advisory cards (actionable guidance)

## Integrations (later)
- Push compact time‑series to CoCache (append‑only ndjson)
- Pull rulepacks from CoCore (`rules/rulepack.json`) and exemplars from CoRef
- Optional: publish a static dashboard via GitHub Pages (read‑only)

---

**Important:** Target repos (e.g., `CoCore`, `CoRef`, `CoAgent`, etc.) should keep relaxed
branch protections only if truly necessary. CoAudit enforces **read‑only discipline** either way.
<!-- BEGIN: STATUS -->
### Operational Status
CoDrift Index: n/a% (n/a)
<!-- END: STATUS -->


<<<<<<< HEAD
=======

>>>>>>> origin/main
