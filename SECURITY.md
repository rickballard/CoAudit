# Security Policy

CoAudit is designed to operate in a **read-only** mode across external repositories.

- It must not create or update branches, tags, issues, or pull requests in other repositories.
- Fine-grained PAT used in CI must be limited to `contents:read` for public repositories.
- Any future feature that proposes changes must be gated behind explicit manual steps and produce **draft PRs only** in the target repository, never automatic pushes.
