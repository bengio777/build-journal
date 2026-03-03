# Universal Task Capture: Cloud Run Debugging & Deploy Pipeline Fix
## Build Journal Entry — Standard

**Builder:** Ben Giordano
**Date:** 2026-03-02
**Repo:** https://github.com/bengio777/universal-task-capture
**Status:** Complete — Service live, Cloud Build pipeline operational
**Tier:** Standard

---

## 1. Problem Statement

The `task-capture-ui` service on Cloud Run had never successfully served a request — every hit returned 500. Separately, the Cloud Build source-based deploy pipeline had been silently broken since the initial deploy, forcing all future changes to require a local Docker build workflow.

Two independent problems: a broken service, and a broken deploy pipeline.

---

## 2. Solution

**Service (500 → 200):**
1. Diagnosed root cause via Cloud Run logs: `notion-client` v3 removed `databases.query()` — pinned to `==2.2.1` which still has the proven API
2. After pinning, new error: Notion API returning 404 for all 9 database IDs — confirmed all IDs were stale (databases had been recreated and config was never updated)
3. Used Notion MCP to look up all 9 live database IDs and updated `databases.py`

**Deploy Pipeline:**
1. Added `.gcloudignore` to exclude `.venv` (653MB) from source uploads — reduced upload from ~653MB to 42KB
2. Added `cloudbuild.yaml` with `E2_HIGHCPU_8` machine type
3. Discovered `gcloud run deploy --source` ignores `cloudbuild.yaml` — switched to `gcloud builds submit --config`
4. Fixed 3 IAM permission gaps on the compute service account (GCP's new default for Cloud Build in modern projects)

---

## 3. Architecture

No architectural changes. Same stack as deployed:
- FastAPI + HTMX frontend on Cloud Run (`us-central1`)
- Notion as task database backend (9 topic databases)
- `google-adk` Runner for Quick Capture (in-process agent)
- Artifact Registry (`cloud-run-source-deploy`) for images
- Cloud Build (`E2_HIGHCPU_8`) for CI/CD via `gcloud builds submit`

```
Browser
  └── HTMX requests
        └── FastAPI (Cloud Run)
              ├── app/notion_client.py  → Notion API (9 databases)
              ├── app/agent_runner.py   → Google ADK Runner → Gemini
              └── app/main.py           → Routes + Jinja2 templates
```

---

## 4. Component Specifications

### `google-adk/requirements.txt`
- Pinned `notion-client==2.2.1` — last version with `databases.query()` at `/databases/{id}/query`

### `google-adk/task_capture_agent/config/databases.py`
- Updated all 9 `data_source_id` values to match current Notion workspace
- Also corrected `MASTER_DB_ID` and `NEEDS_SORTING_DB_ID`

### `google-adk/.gcloudignore`
- Excludes `.venv`, `__pycache__`, `.pytest_cache`, `.adk`, `tests/`, `.env` from Cloud Build source uploads

### `google-adk/cloudbuild.yaml`
- 3-step pipeline: docker build → docker push → gcloud run deploy
- `E2_HIGHCPU_8` machine type to handle large image push (~3GB due to `google-adk` deps)
- `CLOUD_LOGGING_ONLY` to avoid Cloud Storage log duplication

### GCP IAM (project: `task-capture-bg`)
- Added `roles/artifactregistry.writer` to compute SA
- Added `roles/run.developer` to compute SA
- Added `roles/iam.serviceAccountUser` on compute SA to itself

---

## 5. Lessons Learned

1. **`gcloud run deploy --source` ignores `cloudbuild.yaml`** — use `gcloud builds submit --config=path/cloudbuild.yaml` to use a custom build config. The source deploy always generates its own config.

2. **"Retry budget exhausted" in Cloud Build is misleading** — it was masking a clean `permission denied` on every push attempt. The real error only surfaced when using `gcloud builds submit` directly.

3. **In modern GCP projects, Cloud Build runs under the compute SA** (`[NUM]-compute@developer.gserviceaccount.com`), not `@cloudbuild.gserviceaccount.com`. Needs explicit grants: `artifactregistry.writer`, `run.developer`, and `iam.serviceAccountUser` on itself.

4. **Always pin SDK deps to exact versions** — `notion-client>=2.2.0` silently resolved to v3 at build time, which removed `databases.query()` with no obvious warning in the error.

5. **Stale database IDs produce 404, not 403** — when Notion databases are recreated, the IDs change. The error looks like a permissions issue but is actually a missing resource. Check IDs before debugging auth.

6. **`--platform=linux/amd64` is only needed locally on Apple Silicon** — passing it in Cloud Build (which runs on amd64 natively) causes exit code 125. Strip it from `cloudbuild.yaml`.

7. **`$PROJECT_ID` is not expanded inside the `substitutions` block** — only in step args. Hardcode the project ID in substitution default values.

### From Previous Sessions

8. **Pin dependency versions before deploying** — floating versions in `requirements.txt` cause runtime failures that are invisible until logs are checked.

9. **Test the delivery mechanism before building features** — validate Cloud Run deploy path with a hello-world container on day 1. Don't write features until the pipeline works.

10. **Multi-platform architecture is an underestimated source of friction** — Apple Silicon development targeting Cloud Run (AMD64) causes subtle build failures. Always specify `--platform linux/amd64` for local builds.

11. **Configure MCP integrations before building, not after** — gcloud MCP would have given live log access from the start. Set up gcloud MCP at project start.

---

## 6. Build History

| Session | Date | Focus | Outcome |
|---------|------|-------|---------|
| 1 | 2026-02-24 | Google ADK agent implementation | ADK agent, Notion tools, 4 tests passing |
| 2 | 2026-02-25 | CRUD frontend (FastAPI + HTMX) | FastAPI + HTMX + Notion client + ADK runner + Dockerfile (9 commits, 34 tests) |
| 3 | 2026-02-25 | Docker + Cloud Run deployment | Switched to local buildx, service deployed — 500 under diagnosis |
| 4 | 2026-03-02 | **Cloud Run debugging + deploy pipeline fix** | Service 200, Cloud Build pipeline operational |

---

## 7. Commit Log

| Hash | Date | Description |
|------|------|-------------|
| a0a65ff | 2026-03-02 | fix: hardcode project ID in cloudbuild.yaml substitution |
| 9180b75 | 2026-03-02 | fix: remove --platform flag from cloudbuild.yaml |
| e7e9f5d | 2026-03-02 | fix: add .gcloudignore and cloudbuild.yaml to fix source-based deploys |
| 94295bd | 2026-03-02 | fix: update all 9 Notion database IDs to match current workspace |
| d98e5e1 | 2026-03-02 | fix: pin notion-client to 2.2.1 to restore databases.query() |
| d1d9103 | 2026-03-02 | fix: migrate from databases.query to data_sources.query (reverted) |
| c01c2ae | 2026-03-02 | fix: pin notion-client to 2.7.0 to avoid v3 breaking API change |
| 6062bae | 2026-03-02 | docs: add full retrospective for Cloud Run deployment session |
| 1a6372a | 2026-02-25 | docs: add build journal daily recap for CRUD frontend session |
| eb493c1 | 2026-02-25 | fix: add build-essential to Dockerfile for C extension compilation |
| 0bd1366 | 2026-02-25 | feat: add Dockerfile for Cloud Run deployment |
| 86c4ae7 | 2026-02-25 | feat: replace stub templates with full HTMX UI |
| 40ada93 | 2026-02-25 | feat: add FastAPI routes and stub templates |
| bd888f0 | 2026-02-25 | feat: add ADK runner wrapper for quick capture |
| ed7b3fd | 2026-02-25 | feat: add Notion CRUD client with tests |
| 453e1dd | 2026-02-25 | deps: add fastapi, jinja2, uvicorn, httpx for CRUD frontend |
| c4f909d | 2026-02-24 | Add Google ADK implementation of Universal Task Capture agent |
| 2b20b6a | 2026-02-23 | Add SPEC.md and SPEC-SUMMARY.md for HOAI assignment submission |
