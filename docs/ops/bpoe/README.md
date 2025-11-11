## Guards: LEG/RFE
- **LEG** (Line-Endings Guard): CI fails if CRLF appears in docs/** or .github/workflows/**.
- **RFE** (Render-First Emission): emit YAML/JSON via single-quoted here-strings to files, then re-open and lint before commit.