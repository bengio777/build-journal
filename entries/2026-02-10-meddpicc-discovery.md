# MEDDPICC Discovery: AI-Powered Sales Discovery Workflow
## Build Journal Entry — Standard

**Builder:** Ben Giordano
**Date:** 2026-02-10 (retroactive — logged 2026-03-16)
**Repo:** bengio777/MEDDPICC_Discovery
**Status:** Complete
**Tier:** Standard

---

## 1. Problem Statement

Enterprise AEs running discovery calls often arrive underprepared — researching the wrong signals, asking generic questions, and leaving without a clear qualification read. MEDDPICC is the right framework for enterprise deals, but knowing the framework and running it effectively are different skills. The gap is in operationalizing it: having the right research pre-built, the right questions mapped to gaps, and a consistent scoring discipline after every call.

The goal: an end-to-end augmented workflow that lets an AE hand off the research, briefing, and scoring work to AI while retaining every judgment call and outbound action as a human gate. The output is a qualified (or disqualified) opportunity with a full MEDDPICC scorecard and defined next steps.

## 2. Solution

Built MEDDPICC Discovery — a Claude Project workflow covering the complete discovery lifecycle across three phases:

**Pre-Call (Steps 1–6):**
- Draft and send a confirmation email with a proposed agenda
- Deep multi-threaded research across 5 parallel tracks (stakeholder, team mapping, regulatory drivers, financial filings, company/industry context), every finding confidence-flagged as Verified / Inferred / Gap
- Synthesize research into a glanceable briefing doc with Rapport Angles, Stakeholder Map, Intelligence Plays, and MEDDPICC Targeting sections

**Call (Step 7):**
- AE runs the call with the briefing doc and MEDDPICC Discovery Questions as live references
- TED framework (Tell me / Explain / Describe) used to drive depth; 75/25 prospect-to-seller ratio maintained

**Post-Call (Steps 8–11):**
- Generate a tone-calibrated follow-up email and mutual action plan with reciprocal commitments
- Score the opportunity — each MEDDPICC element rated Strong / Partial / Gap / Unknown with supporting evidence; stage gate minimums enforced (Pain, Champion, Economic Buyer must each be at least Partial to advance)
- AE makes final qualify / deprioritize / disqualify decision

**Platform:** Claude Project with 4 pre-loaded context files encoding the full MEDDPICC knowledge base.

## 3. Architecture

Claude Project with a 4-file context corpus and a structured 11-step workflow. No code — the workflow runs entirely as AI-augmented prompting within a persistent Claude Project.

```
MEDDPICC_Discovery/
├── Reference Files/
│   ├── MEDDICC_Qualification_Framework.md       # Element definitions (M, E, D, D, P, I, C, C)
│   ├── MEDDPICC_Discovery_Questions.md          # 32 questions organized by element with TED levels
│   ├── MEDDPICC_Scoring_Criteria.md             # Strong/Partial/Gap/Unknown rubric per element
│   └── Sales_Stage_Definitions.md              # 6-stage CRM model with entry/exit criteria
├── outputs/
│   ├── meddpicc-discovery-prep-call-and-follow-up-prompt.md   # Master workflow prompt
│   ├── meddpicc-discovery-prep-call-and-follow-up-building-blocks.md
│   ├── meddpicc-discovery-prep-call-and-follow-up-sop.md
│   └── notion-registration-queue.md
├── WORKFLOW-DEFINITION.md                       # 11-step SOP with failure modes and quality checks
├── BUILDING-BLOCK-SPEC.md                       # AI building block specification
├── SPEC.md                                      # Project spec with deliverables and review criteria
└── README.md
```

**Key design decisions:**
- **Claude Project as the platform** — persistent context means the 4 reference files are always loaded; no prompt injection required per session
- **Confidence flagging on all research** — Verified / Inferred / Gap makes it explicit what the AE can rely on vs. what needs to be probed on the call
- **Human gates at every outbound action** — 6 of 11 steps are human review points; no email is sent and no deal is advanced without AE approval
- **Stage gate minimums enforced at scoring** — Pain, Champion, and Economic Buyer must be at least Partial before the deal advances; prevents optimistic qualification decisions
- **Mutual action plan with reciprocal commitments** — follow-up includes specific deliverables and owners on both sides, not just next-step vagueness

## 4. Component Specifications

### Context Files (Reference Files/)

| File | Purpose | Size |
|------|---------|------|
| `MEDDICC_Qualification_Framework.md` | Defines all 8 MEDDPICC elements with qualifying questions, red flags, and advance criteria per element | Reference |
| `MEDDPICC_Discovery_Questions.md` | 32 questions organized by element; each mapped to a TED level (Tell / Explain / Describe) appropriate to what is already known | Reference |
| `MEDDPICC_Scoring_Criteria.md` | Strong requires direct prospect quotes; Partial requires paraphrase; Gap means heard nothing; Unknown means never probed | Reference |
| `Sales_Stage_Definitions.md` | 6-stage CRM model (Prospecting through Closed) with specific entry/exit criteria per stage | Reference |

### Workflow Prompt (`outputs/meddpicc-discovery-prep-call-and-follow-up-prompt.md`)

Master prompt that orchestrates all 11 steps. Loaded once into the Claude Project alongside the 4 context files. Each step is invoked by the AE with the relevant inputs; Claude references the appropriate context file(s) for that step automatically.

### WORKFLOW-DEFINITION.md

Full 11-step SOP with step-by-step procedure, decision points, quality checks, failure modes, and automation notes. Covers edge cases: thin research on private companies, prospect silence after follow-up, first-call scoring that's all Gap (expected — treat as call objectives for next interaction).

### Building Block Decomposition (`outputs/meddpicc-discovery-prep-call-and-follow-up-building-blocks.md`)

Analysis of which AI building blocks the workflow uses per step: structured prompting, parallel research threads, synthesis, tone calibration, rubric-based scoring. Used for HOAI course building block identification.

## 5. Lessons Learned

**Multi-threaded research needs explicit confidence flagging.** Without a Verified / Inferred / Gap taxonomy, AI research outputs tend to present everything at the same confidence level. The AE has no way to distinguish "this is from a 10-K" from "this seems likely based on the job title." Baking the taxonomy into the Step 3 prompt output format fixed this.

**Glanceable format matters for live-call use.** The briefing doc has to work during a live call — AE is on camera, needs to parse a section in 5–10 seconds. Bold headers, highlighted sub-bullets, and strict section ordering (not narrative prose) made the difference between a doc you actually use and one you abandon mid-call.

**Stage gate minimums prevent optimistic qualification.** Without enforced minimums, the tendency is to advance deals on enthusiasm. Requiring Pain, Champion, and Economic Buyer to be at least Partial before stage advancement creates a forcing function. The Strong vs. Partial test — "can I quote the prospect, or am I paraphrasing my own assumption?" — is operationally useful.

**Mutual action plans outperform next-step asks.** "I'll send the security overview — will you schedule the technical deep-dive?" outperforms "I'll follow up" because it creates explicit bilateral commitment. The reciprocal structure surfaced naturally when modeling what high-performing AEs actually do on closing calls.

**Augmented workflow is the right type here.** Full automation is wrong for discovery — the AE's judgment and relationship are the product. The right design is AI handling the cognitive load (research, synthesis, scoring) while the human owns every relationship touchpoint and decision gate. That's the pattern this workflow follows.

## 6. Build History

**Feb 10 — Initial commit**
Repo created. Initial project structure and context file placeholders committed.

**Feb 11 — Core workflow built**
Full workflow built in a single session: all 4 reference files authored (MEDDPICC framework, 32 discovery questions with TED mapping, scoring criteria, sales stage definitions), master workflow prompt written, and process definition document completed. 3 phases (Prep, Call, Follow-up) defined across 11 steps with human gates explicit at each outbound and decision point.

**Feb 16 — Workflow SOP added**
WORKFLOW-DEFINITION.md written following the standard 8-section SOP template: overview, prerequisites, trigger, procedure, outputs, quality checks, failure modes, and automation notes. Added edge case handling for thin research, post-follow-up silence, and first-call all-Gap scoring.

**Feb 23–24 — HOAI course submission prep**
README rewritten with project description, architecture overview, and output index. BUILDING-BLOCK-SPEC.md and SPEC.md added as part of HOAI Builders Week 3 submission requirements. (Covered separately in the HOAI Multi-Agent Submission Prep build journal entry.)

## 7. Commit Log

| Hash | Date | Description |
|------|------|-------------|
| `6c114804` | 2026-02-10 | Initial commit |
| `428bdb86` | 2026-02-11 | Add MEDDPICC Discovery Prep, Call, and Follow-up workflow |
| `9e1e1e7a` | 2026-02-16 | Add workflow definition SOP |
| `62fca32d` | 2026-02-23 | docs: rewrite README with project description, architecture, and outputs |
| `ebbb09b3` | 2026-02-24 | Add building block spec and project spec |
