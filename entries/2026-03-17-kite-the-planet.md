# Kite the Planet: BrandVoiceAgent + Brand Foundation
## Build Journal Entry — Standard

**Builder:** Ben Giordano
**Date:** 2026-03-17
**Repo:** KTP_V01 (https://github.com/bengio777/KTP_V01)
**Status:** Complete
**Tier:** Standard

---

## 1. Problem Statement

BrandVoiceAgent existed as a shell — role defined, responsibilities listed, prompt empty. Meanwhile the agent's upstream inputs (brand-voice.md, core-principles.md, mission-statement.md) were working drafts that needed to be completed before the prompt could be written. The session addressed both: finish the brand foundation docs, then build the agent that enforces them.

Secondary problem: architectural question on whether the tiered BrandVoiceAgent design (mandatory review, sampling audit, flag-and-direct verdict, drift reporting) was sound before committing to it. Research and synthesis ran first.

---

## 2. Solution

**Brand foundation docs (completed this session):**
- `brand-positioning.md` — Full customer service model, Ritz Carlton/hostel spectrum, what best-in-class looks like for KTP
- `corporate-values.md` — AI org operating principles: hiring model, trust-before-autonomy, 4-stage progression (Shell → Shadow → Supervised → Autonomous)
- `core-principles.md` — Added 5th principle: global community / inclusive framing
- `mission-statement.md` — Added operational identity (KTP as customer service company)
- `CLAUDE.md` — Added agent build sequence, skill/prompt distinction, deferred Figma/FigJam to V2

**BrandVoiceAgent prompt (written this session):**
- Full prompt at `docs/agents/shared/brand-voice-agent.md`
- REVIEW mode: 5-question test, voice assignment by content type, APPROVED/REVISE/REWRITE verdict with REQUIRED ACTION per failure
- AUDIT mode: drift summary, pass rate, NONE/LOW/MODERATE/HIGH drift signal, escalation recommendation
- Two few-shot examples (Dakhla spot editorial APPROVED, destination guide REVISE)
- COO escalation protocol (retry / queue for human / log and continue)
- Status: Shell → Active (Shadow)

**Architectural refinements applied:**
- Flag-and-direct confirmed as correct pattern (never rewrite)
- REQUIRED ACTION field added per failure
- Self-check from originating agent = formatting confirmation only, not quality gate
- Sampling/drift reporting deferred — always-on mandatory review correct at current volume
- Single source of truth: brand docs injected as context, not duplicated per agent

---

## 3. Architecture

BrandVoiceAgent: Level 1 agent — single prompt, no tools, brand docs injected as context at runtime.

Context injection: brand-voice.md, core-principles.md, mission-statement.md, brand-positioning.md

Reporting line: BrandVoiceAgent → COO OrchestratorAgent

---

## 4. Lessons Learned

- Research synthesis before build prevented two mistakes: over-engineering sampling at low volume, duplicating brand standards per agent
- REQUIRED ACTION per failure is essential — "Test 3: FAIL" without a directive triggers circular retries
- Self-check theater is a real prompt failure mode — explicitly addressed in prompt
- Flag-and-direct forces training-loop-compatible behavior; rewrite masks agent drift

---

## 5. Commit Log

| Hash | Date | Description |
|------|------|-------------|
| a296665 | 2026-03-17 | feat: BrandVoiceAgent prompt — Shell → Active (Shadow) |
| 94b0a51 | 2026-03-17 | docs: add customer service positioning, citation standards, content ethics, brand positioning doc |
| 1735ed0 | 2026-03-17 | docs: add legal/business ops backlog — trademark and DesignAgent gap flagged |
| dbf7027 | 2026-03-17 | docs: add 5th brand test (inclusive/cultural) and global community principle |
| cc8544d | 2026-03-17 | docs: add KTP corporate values for AI org — hiring model, trust, autonomy progression |
| f27ee8d | 2026-03-17 | docs: add agent build sequence and skill/prompt distinction to CLAUDE.md |
| b0ed42d | 2026-03-17 | docs: update agent PRD with Travelpayouts integration and TIE prototype status |
| 281bff5 | 2026-03-17 | docs: defer Figma + FigJam to V2, update current stage in CLAUDE.md |
