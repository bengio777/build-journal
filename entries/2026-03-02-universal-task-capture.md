# Universal Task Capture: Cloud Run Deployment
## Build Journal Entry — Full Retrospective (Standard)

**Builder:** Ben Giordano
**Date:** 2026-03-02
**Repo:** https://github.com/bengio777/universal-task-capture
**Status:** In Progress — Service deployed, 500 on root route under diagnosis
**Tier:** Standard

---

## 1. Problem Statement

Build and deploy a personal task capture system with a web UI to Google Cloud Run. The system allows capturing tasks via a FastAPI + HTMX frontend, classifies them using a Google ADK agent powered by Gemini, and routes them to the correct Notion database across 9 task categories. The goal: replace manual copy-paste task entry with a single URL that handles intake, classification, and storage.

---

## 2. Solution

A single Cloud Run service running FastAPI + Jinja2 + HTMX. The ADK agent (Google Gen AI + Gemini) is imported as a Python module and called in-process via the Runner API — no inter-service HTTP. Notion is queried directly at runtime (no SQLite cache). Docker image built locally with `buildx` targeting `linux/amd64` and pushed to Artifact Registry, then deployed via `gcloud run deploy`.

**Service URL:** https://task-capture-ui-370032337595.us-central1.run.app

---

## 3. Architecture

```
Browser
  └── HTMX requests
        └── FastAPI (Cloud Run)
              ├── app/notion_client.py  → Notion API (9 databases)
              ├── app/agent_runner.py   → Google ADK Runner → Gemini
              └── app/main.py           → Routes + Jinja2 templates
```

**Key decisions:**
- Single Cloud Run service (not microservices) — ADK tools imported as Python, not HTTP
- HTMX over React — no JS build pipeline, server-rendered, fits Python stack
- Notion queried directly — 500ms latency acceptable for personal tool, no SQLite cache needed
- `linux/amd64` built locally with `docker buildx --push` — bypasses Cloud Build entirely
- GCP project `task-capture-bg` (created new) — cleaner than reusing `gen-lang-client-*`

---

## 4. Component Specifications

| Component | File | Description |
|-----------|------|-------------|
| Notion CRUD client | `app/notion_client.py` | list, update, edit, archive across 9 databases |
| ADK agent runner | `app/agent_runner.py` | Wraps Google ADK Runner for quick-capture classification |
| FastAPI routes | `app/main.py` | GET /, POST /tasks, POST /tasks/manual, PATCH/PUT/DELETE /tasks/{id} |
| HTMX UI | `app/templates/` | base layout, task list, task row, edit form, manual create |
| Dockerfile | `google-adk/Dockerfile` | python:3.12-slim + build-essential for C extensions |
| Requirements | `google-adk/requirements.txt` | notion-client pinned to ==2.7.0 |

**Dependency pins:**
- `notion-client==2.7.0` — v3.0.0 broke `databases.query()` silently; pinned after diagnosing 500 on first deploy

---

## 5. Lessons Learned

### Pin dependency versions before deploying
`notion-client` released v3.0.0 which silently broke `databases.query()`. Floating versions in `requirements.txt` caused a runtime 500 that was invisible until Cloud Run logs were checked. **Rule: pin all non-trivial dependencies before the first deploy.**

### Test the delivery mechanism before building features
The full app was built before the Cloud Run deploy path was validated. Cloud Build failures, IAM permission issues, and org policy restrictions consumed multiple sessions. **Rule: deploy a hello-world container on day 1. Don't write features until the pipeline works.**

### Use local `docker buildx` over Cloud Build for personal projects
Cloud Build added IAM complexity with no benefit for a personal project. Local `buildx --platform linux/amd64 --push` is simpler, faster, and gives immediate feedback. **Rule: use Cloud Build only when CI/CD or team workflows require it.**

### Multi-platform architecture is an underestimated source of friction
Development on Apple Silicon (ARM) producing images for Cloud Run (AMD64) caused subtle build failures. **Rule: always specify `--platform linux/amd64` in Dockerfile and buildx commands for Cloud Run deployments.**

### Configure MCP integrations before building, not after
The gcloud MCP server would have given Claude live access to Cloud Run logs from the start. Instead, debugging required manual log pulls and CLI auth token expiry added friction. **Rule: set up gcloud MCP (and Notion MCP) at project start — not mid-debug.**

### IAM and org policy configuration is significant work
Getting Cloud Run `allUsers` invoker permission required overriding `iam.allowedPolicyMemberDomains` at the project level. Keep a record of the policy override for future projects.

---

## 6. Build History

| Date | Session | Outcome |
|------|---------|---------|
| 2026-02-22 | Project spec and SKILL.md | SPEC.md, SPEC-SUMMARY.md, initial repo |
| 2026-02-24 | Google ADK implementation | ADK agent, Notion tools, 4 tests passing |
| 2026-02-25 | CRUD frontend build | FastAPI + HTMX + Notion client + ADK runner + Dockerfile (9 commits, 34 tests) |
| 2026-03-02 | Cloud Run deployment | Switched to local buildx, pinned notion-client==2.7.0, service live — 500 under diagnosis |
| 2026-03-02 | Tooling | Added gcloud MCP server to Claude Code user config |

**Open item:** Root `/` returns 500. Diagnosis unblocked once gcloud MCP loads in next session.

---

## 7. Commit Log

| Hash | Date | Description |
|------|------|-------------|
| 1a6372a | 2026-02-25 | docs: add build journal daily recap for CRUD frontend session |
| eb493c1 | 2026-02-25 | fix: add build-essential to Dockerfile for C extension compilation |
| 0bd1366 | 2026-02-25 | feat: add Dockerfile for Cloud Run deployment |
| 86c4ae7 | 2026-02-25 | feat: replace stub templates with full HTMX UI |
| 40ada93 | 2026-02-25 | feat: add FastAPI routes and stub templates |
| bd888f0 | 2026-02-25 | feat: add ADK runner wrapper for quick capture |
| ed7b3fd | 2026-02-25 | feat: add Notion CRUD client with tests |
| 453e1dd | 2026-02-25 | deps: add fastapi, jinja2, uvicorn, httpx for CRUD frontend |
| a18da43 | 2026-02-25 | docs: add CRUD frontend implementation plan |
| 24ec95d | 2026-02-25 | Add CRUD frontend design doc and Topic Link URL fix |
| d90743f | 2026-02-24 | docs: add build journal entry for Google ADK implementation |
| c4f909d | 2026-02-24 | Add Google ADK implementation of Universal Task Capture agent |
| 2b20b6a | 2026-02-23 | Add SPEC.md and SPEC-SUMMARY.md for HOAI assignment submission |
| bf5093c | 2026-02-22 | Add test run output with 4 documented test cases |
| 637f3f5 | 2026-02-16 | Add capture-task skill file to project repo |
| 3fc3359 | 2026-02-16 | Initial commit: Universal Task and To-Do Capture project |
