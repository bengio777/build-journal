# PRD Builder: Production-Ready PRD Skill
## Build Journal Entry — Standard

**Builder:** Ben Giordano
**Date:** 2026-02-11 (retroactive — logged 2026-03-16)
**Repo:** bengio777/prd-builder
**Status:** Complete
**Tier:** Standard

---

## 1. Problem Statement

Building AI-powered products was consistently bottlenecked at the planning stage. Product ideas would get started without a clear scope, and every session began re-litigating which features belong in v1. There was no structured path from "I have an app idea" to a document specific enough to hand to a dev team or an AI coding agent. Most PRD templates produce vague wishlists instead of opinionated, buildable specs.

The goal: a Claude Code skill that guides a user through structured discovery, coaches each feature into the right version, generates a production-ready PRD, and validates it before output.

## 2. Solution

Built `prd-builder` — a 6-phase Claude Code skill with 10 on-demand reference files:

- **Phase 1: Discovery Interview** — captures product vision, jobs-to-be-done, all personas, feature brain dump, constraints, competitive landscape, monetization, kill criteria, and glossary seeds
- **Phase 2: Version Coaching** — evaluates each feature against 6 criteria and presents a Version Placement Map with persistent Feature IDs (F001, F002...)
- **Phase 3: Generate PRD** — reads template + examples + quality systems, produces a precise, opinionated document with user stories, acceptance criteria, data model, dependency graph, and decision log
- **Phase 4: Validate and Output** — 21-point quality checklist, cross-reference integrity check, narrative coherence, surfaces 3 riskiest assumptions for gut-check; saves as `PRD-[ProductName]-v[X.X].md`
- **Phase 5: Iterate and Version** — handles minor iterations and major version progressions; Feature IDs persist across versions
- **Phase 6: Scaling Checkpoints** — technical, product, and operational scaling readiness at each major version boundary

Key design: reference files load on demand per phase, not all at once. Three optional deep-dive modules (competitive analysis, platform/integration, revenue architecture) are offered after discovery and are additive — never blocking.

## 3. Architecture

Single Claude Code skill directory with SKILL.md as the workflow controller and 10 reference files loaded lazily per phase:

```
prd-builder/
├── SKILL.md                          # 6-phase workflow, quality checklist, reference index
├── references/
│   ├── prd-template.md               # Exact PRD section structure
│   ├── prd-template-examples.md      # Worked examples per section
│   ├── quality-systems.md            # Deduplication, cross-reference, coherence rules
│   ├── version-coaching.md           # Coaching criteria + Version Placement Map format
│   ├── deep-dive-modules.md          # Module index + offer script
│   ├── module-competitive-analysis.md
│   ├── module-platform-integration.md
│   ├── module-revenue-architecture.md
│   ├── implementation-handoff.md     # Build chunking, dependency graph, handoff
│   └── iteration-scaling.md          # Version progression, retrospectives, scaling
├── INSTALL.md                        # Operationalization guide
├── WORKFLOW-DEFINITION.md            # 6-step SOP
├── BUILDING-BLOCK-SPEC.md            # AI building block spec
└── SPEC.md                           # Project spec with deliverables + review criteria
```

**Key design decisions:**
- Reference files load on demand — keeps context lean; the full reference corpus would be too large to load upfront
- Deep-dive modules are offered, never blocking — "Want to go deeper, or should I draft first?" prevents over-engineering the discovery phase
- Feature IDs (F001, F002...) assigned during coaching and immutable across versions — enables reliable cross-referencing in large PRDs
- `v0.1` for drafts, `v1.0` for complete PRDs — versioning convention baked into output file naming

## 4. Component Specifications

| Component | File | Purpose |
|-----------|------|---------|
| Core skill | `SKILL.md` | 6-phase workflow (164 lines), 21-point quality checklist, reference file load triggers |
| PRD template | `references/prd-template.md` | Exact section structure for generated documents |
| Template examples | `references/prd-template-examples.md` | Worked examples for each PRD section |
| Quality systems | `references/quality-systems.md` | Deduplication, cross-reference integrity, narrative coherence, assumption risk ranking |
| Version coaching | `references/version-coaching.md` | 6 evaluation criteria, Version Placement Map format |
| Deep-dive index | `references/deep-dive-modules.md` | Module index and offer script for natural handoff |
| Competitive module | `references/module-competitive-analysis.md` | Positioning, differentiators, table stakes |
| Platform module | `references/module-platform-integration.md` | Per-version integration plan, API trajectory |
| Revenue module | `references/module-revenue-architecture.md` | Tier structure, expansion revenue, pricing model |
| Implementation handoff | `references/implementation-handoff.md` | Build chunking, dependency graphs, "How to Use This PRD" header |
| Iteration/scaling | `references/iteration-scaling.md` | Minor iterations, major version progressions, scaling checkpoints |
| Install guide | `INSTALL.md` | File loading behavior, workflow sequence, operationalization |
| Workflow SOP | `WORKFLOW-DEFINITION.md` | 6-step SOP for Product Requirements Development process |
| Building block spec | `BUILDING-BLOCK-SPEC.md` | Autonomy spectrum, step decomposition, failure modes |

## 5. Lessons Learned

**On-demand reference loading is the right pattern for multi-phase skills.** Loading all 10 reference files at session start would consume context budget before discovery even begins. The phase-gated loading approach — read version-coaching.md in Phase 2, read prd-template.md in Phase 3 — keeps each phase's context focused on the task at hand. This pattern is reusable for any skill with more than 3-4 reference files.

**Feature IDs solve a real problem in long PRDs.** Without persistent IDs, the version roadmap can drift from the feature set — "User Auth" in Section 2 becomes "Authentication System" in Section 5 and no one catches the inconsistency. Assigning F001, F002... during coaching and running a cross-reference integrity check at output catches this class of error before it ships.

**Kill criteria belong in every PRD.** Most PRDs scope what to build but not when to stop. Defining 2-3 measurable failure signals upfront ("can't get 50 users in 60 days") prevents sunk-cost continuation on products that have already failed their own tests.

**Deep-dive modules work best as offers, not gates.** Original design had competitive analysis as a required step. Changed to optional after recognizing that blocking PRD generation on a competitive deep-dive creates friction for solo builders who already know their space. The offer script ("Want to go deeper, or should I draft first?") gets used when it matters and skipped when it doesn't.

**The PRD is only as good as the kill criteria and assumptions.** Surfacing the 3 riskiest assumptions at output, and asking the user to gut-check them, is the highest-leverage quality step. A PRD built on bad assumptions is worse than no PRD — it creates false confidence.

## 6. Build History

| Session | Date | Focus | Outcome |
|---------|------|-------|---------|
| 1 | 2026-02-11 | Initial build | SKILL.md v1.0 + 10 reference files; fixed PRD output path for Claude Code compatibility |
| 2 | 2026-02-16 | Workflow documentation | WORKFLOW-DEFINITION.md (8-section SOP) |
| 3 | 2026-02-24 | Registry documentation | BUILDING-BLOCK-SPEC.md + SPEC.md for HOAI course submission |

All three sessions were part of the same build arc — initial skill, then documentation, then course registration. No architectural changes between sessions.

## 7. Commit Log

| Hash | Date | Description |
|------|------|-------------|
| 7b51038 | 2026-02-24 | Add building block spec and project spec |
| 07f0982 | 2026-02-16 | Add workflow definition SOP |
| 2395744 | 2026-02-11 | fix: update PRD output path for Claude Code compatibility |
| f8d23cb | 2026-02-11 | feat: initial prd-builder skill v1.0 |
