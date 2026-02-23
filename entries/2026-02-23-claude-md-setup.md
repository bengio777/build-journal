# CLAUDE.md Setup: Global Configuration for Claude Code
## Build Journal Entry — Quick

**Builder:** Ben Giordano
**Date:** 2026-02-23
**Repo:** ~/.claude/CLAUDE.md (global, not repo-specific)
**Tier:** Quick

---

## 1. Problem Statement

No global CLAUDE.md existed. Every session started cold — Claude rediscovered directory structure, registries, communication preferences, and workflow conventions from scratch. Build journal analysis revealed 8 recurring patterns across all projects that were being re-learned each session instead of codified.

## 2. Solution

Created `~/.claude/CLAUDE.md` with 10 instructions across 7 sections, each earning its token cost:

- **Who I Am / Current Focus** — eliminates cold-start discovery
- **How I Work** — communication style (direct, one question at a time, lead with recommendation)
- **Decision Authority** — execute vs. ask boundaries to reduce permission friction
- **Engineering Calibration** — bidirectional over/under-engineering challenge
- **Verification** — verify before claiming done; diagnose before retrying
- **Build Completion Standards** — register during build, SOP template, phase shipping, test delivery early
- **Session Patterns** — auto-trigger build journal on wrap-up signals
- **Failure Modes** — conditional, only for external API/data interactions

Also logged 5 class questions for HOAI professor to Notion Class Questions Tracker.

## 3. Lessons Learned

- **Build journals are a gold mine for CLAUDE.md content.** Analyzing 5 entries surfaced patterns that no single session would have revealed. The retrospective habit feeds forward into configuration.
- **Trim aggressively.** Started with 8 candidate instructions, eliminated 2 (parallel workstreams — Claude already does this; on-demand activation — too narrow for global config), trimmed 2 more. Final: 58 lines.
- **Token cost awareness matters.** Every line in CLAUDE.md loads every session. The SOP template was originally 8 inline steps; replaced with a one-liner pointer to existing files. Same outcome, fewer tokens.

## 4. Commit Log

| Hash | Date | Description |
|------|------|-------------|
| N/A | 2026-02-23 | CLAUDE.md created at ~/.claude/CLAUDE.md (not in a git repo) |
