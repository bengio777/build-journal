# Build Journal: Plugin Build & Activation Redesign
## Build Journal Entry — Standard

**Builder:** Ben Giordano
**Date:** 2026-02-15
**Repo:** build-journal
**Status:** In Progress
**Tier:** Standard

---

## 1. Problem Statement

Three converging problems: no consistent documentation habit for builds, scattered notes across tools with no structure, and no portfolio trail showing skill progression. The immediate trigger was the previous project (class question logger with iOS Shortcuts) — debugging iOS Shortcuts scripting took far longer than expected, and there was no way to capture that data. The realization: this kind of build metadata is valuable for every project, not just painful ones. It feeds into understanding progression, setting realistic expectations for future builds, and teaching others — at meetups, conferences, and in everyday conversations with friends and colleagues.

## 2. Solution

A Claude Code plugin that auto-captures build metadata during coding sessions and generates tiered retrospective documents. Two modes: Full Retrospective (project complete) and Daily Recap (pausing mid-project). Output writes to four destinations simultaneously: project repo, central archive, Notion, and Google Sheets.

The activation model was redesigned mid-build — originally a SessionStart hook that asked two questions every session, now moving to on-demand activation via `/build-journal` slash command plus natural language detection through enriched skill descriptions.

## 3. Architecture

Claude Code plugin with four components:

- **Slash command** (`/build-journal`) — explicit activation entry point
- **Skill** (`skills/build-journal/SKILL.md`) — core logic for auto-capture, interview, tier selection, and quad-write output
- **Templates** (`templates/`) — three tiers (Quick 4-section, Standard 7-section, Full 10-section) scaled to project scope
- **Central archive** (`entries/`) — all build journal entries in one place across projects

Natural language detection handled by skill description trigger phrases rather than a UserPromptSubmit hook — zero overhead, simpler architecture.

## 4. Component Specifications

| Component | File | Purpose |
|-----------|------|---------|
| Plugin manifest | `.claude-plugin/plugin.json` | Plugin registration and metadata |
| SessionStart hook | `hooks/hooks.json` + `hooks/session-start.sh` | Original activation (being removed) |
| Core skill | `skills/build-journal/SKILL.md` | Auto-capture, interview, tier selection, quad-write |
| Quick template | `templates/quick.md` | 4-section template for small fixes |
| Standard template | `templates/standard.md` | 7-section template for feature builds |
| Full template | `templates/full.md` | 10-section template for multi-day projects |
| Central archive | `entries/` | Cross-project entry storage |
| Design doc | `docs/plans/2026-02-15-build-journal-design.md` | Original design |
| Implementation plan | `docs/plans/2026-02-15-build-journal-implementation.md` | Step-by-step build plan |
| Activation redesign | `docs/plans/2026-02-15-activation-redesign-design.md` | Redesign from hook to on-demand |

## 5. Lessons Learned

- **Plugin system is still maturing.** Manual registration in `installed_plugins.json` and `settings.json` may not be picked up by Claude Code. The `claude plugin add` command is the safer path.
- **Hook output format matters.** The SessionStart hook fired successfully but used `hookSpecificOutput.additionalContext` instead of the documented `systemMessage` format — the context never reached the model. Always verify against current plugin docs.
- **Start with on-demand, not automatic.** The SessionStart hook felt heavy — asking questions every session creates friction. Slash commands + skill description triggers give the user control without losing discoverability.
- **Build journal was born from a previous build's pain.** The iOS Shortcuts debugging session that triggered the class question logger also revealed the need for build metadata capture. One project's friction became the next project's feature.
- **The real value is progression tracking.** Individual entries are useful, but the portfolio effect — showing the crawl-walk-run-rocketship progression of AI skill development — is the bigger payoff for teaching and speaking.

## 6. Build History

Single-session build on 2026-02-15. Started with design document, moved through implementation plan, built all components (manifest, hooks, skill, templates, archive), then redesigned the activation model from automatic to on-demand based on E2E testing feedback.

The E2E test this session revealed the hook fired but didn't deliver context — validating the decision to move away from the hook approach entirely.

## 7. Commit Log

| Hash | Date | Description |
|------|------|-------------|
| 2f7c8e2 | 2026-02-15 | docs: add activation redesign design doc |
| 93f7194 | 2026-02-15 | feat: add entries directory for central build journal archive |
| 920fc60 | 2026-02-15 | feat: add build-journal skill with auto-capture and interview flow |
| 45d8e54 | 2026-02-15 | feat: add tiered build journal templates (quick, standard, full) |
| f0790bc | 2026-02-15 | feat: add SessionStart hook for session activation |
| 0e0a7ca | 2026-02-15 | feat: add plugin manifest |
| 095b586 | 2026-02-15 | docs: add Build Journal implementation plan |
| 1008ba9 | 2026-02-15 | Add Build Journal design document |
