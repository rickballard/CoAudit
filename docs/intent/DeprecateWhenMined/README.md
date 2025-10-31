# DeprecateWhenMined — CoAudit Advisory Sandbox (Hands-Off)

**Purpose:** CoAudit’s **hands-off** staging area for *Evolutionary Advisory Units (EAUs)*.
We **observe, compare, and advise**. We **do not** change other repos. CoPrime (or other
executors) may *ingest* these advisories and act elsewhere. When mined of value, **delete this folder**.

**Start here**
- Charter & scope: `00_CHARTER.md`
- Strategy & system: `10_STRATEGY.md`
- Current advisory index: `60_DATA/indices/ADVICE_INDEX.md`
- Mining runbook for CoPrime: `80_RUNBOOK/CoPrime-Mining-Runbook.md`

**Reply path (hands-off loop)**
- Executors drop `*.reply.json` in `60_DATA/replies/` (schema: `40_SCHEMAS/reply.schema.json`)
- CoAudit sweep updates scorecards and advisory statuses (no outward writes)

**Absolute handoff link (after merge to main):**
https://github.com/rickballard/CoAudit/blob/main/docs/intent/DeprecateWhenMined/README.md

**Timestamp (pack built):** 2025-10-31T04:26:28.281804Z

**Deletion rule:** After `80_RUNBOOK/Deprecation-Checklist.md` is ✅, open a PR titled  
**deprecate: remove DeprecateWhenMined (mined)**
