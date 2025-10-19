---
title: "Missing required metrics registry"
severity: "amber"
owner: "@repo-owners"
repo: "${repo}"
created: "2025-10-19"
---

**Why this matters**  
Without a machine-readable metrics registry, CoAudit cannot trend or compare your key metrics.

**What to do**  
Add `repo.metrics.yml` at the repository root using the provided template, then reference it from `METRICS_INDEX.md`.

**Evidence**  
- n/a
