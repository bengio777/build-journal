# Blog Post Skill: BG Media Post-Coaching
## Build Journal Entry — Standard

**Builder:** Ben Giordano
**Date:** 2026-02-12 (retroactive — logged 2026-03-16)
**Repo:** bengio777/Substack-short-blog-post_skill
**Status:** Complete
**Tier:** Standard

---

## 1. Problem Statement

Writing a Substack post from raw media (video, photo, audio) requires moving through several distinct stages — picking the right media, extracting the story, structuring the narrative, drafting, editing, and publishing — each of which demands different cognitive modes. Doing this unassisted means either rushing through the thinking or grinding to a halt at the blank page. The goal was a coaching workflow that handles the heavy lifting (media analysis, story angle generation, structure scaffolding, drafting, editorial passes) while the author makes every creative decision. The output needed to be Substack-native, multimedia-aware, and concise — a ~5 minute read, not a blog-length dump.

---

## 2. Solution

A Claude Code skill (`/write-substack-post`) that coaches the author through an 8-step workflow using the Amuse-Bouche short-form storytelling framework. The skill accepts multi-source media inputs (local files, YouTube links, Spotify links, iCloud references) and routes them through 4 specialized sub-skills, each handling a distinct phase of the creation process. Every creative decision is gated by an explicit human checkpoint — the AI proposes, the author reacts, and nothing advances without approval.

The workflow was designed and submitted as the Week 2 assignment for the HOAI (Hands-on AI Builders) course, satisfying the "Build a Collaborative AI Workflow" module requirements. A test run on real media (a screenshot of the BPG Tech News briefing web viewer, Feb 21 2026) validated 5 of 5 human checkpoints — every checkpoint produced a substantive steering change.

---

## 3. Architecture

```
/write-substack-post (skills/SKILL.md)
        |
        |-- Step 1: Select Source Media (human-driven)
        |-- Step 2: Extract the Story --> skills/media-analysis/SKILL.md
        |-- Step 3: Coach Story Structure --> skills/story-coaching/SKILL.md
        |-- Step 4/5: Draft + Multimedia --> skills/draft-multimedia/SKILL.md
        |-- Step 6: Review and Tighten --> skills/editorial-coaching/SKILL.md
        |-- Step 7: Format for Substack (AI-deterministic)
        |-- Step 8: Post-Publish Reflection (human-driven)
```

**Execution Pattern:** Skill-Powered Prompt — conversational workflow where AI proposes at each stage and the human decides. No autonomous decision-making. Sequential flow with human gates.

**Autonomy Spectrum:**
- Human-driven (2 steps): Steps 1, 8 — author does the work, AI provides guidance
- AI-Semi-Autonomous (4 steps): Steps 2, 3, 4/5, 6 — AI proposes and coaches, author makes every creative decision
- AI-Deterministic (1 step): Step 7 — formatting follows rules

**Media Input Paths:**
- Local files (photos, short clips) → analyzed directly, included in post repo
- YouTube links → Substack auto-embeds
- Spotify links → Substack auto-embeds
- iCloud references → author provides compressed version or YouTube link

**Critical Path:** Step 3 (Story Structure Coaching) is the workflow bottleneck — the most cognitively demanding step, and everything downstream depends on locking the structure before drafting.

---

## 4. Component Specifications

### Master Skill
| File | Purpose |
|------|---------|
| `skills/SKILL.md` | 8-step orchestration. Invoked via `/write-substack-post`. Routes to 4 sub-skills at the appropriate stage. Enforces propose → react → confirm loop. |

### Sub-Skills
| Sub-Skill | File | Key Logic |
|-----------|------|-----------|
| Media Analysis | `skills/media-analysis/SKILL.md` | 3 media-type processing paths (photo → EXIF + visual, video → transcribe + visual, audio → transcribe + tone). Generates 2-3 story angles per analysis run. |
| Story Coaching | `skills/story-coaching/SKILL.md` | Amuse-Bouche framework: Anchor → Essential Details → Dismount → Hook (written last). 5 hook types with selection criteria (Dialogue, Snapshot, Bold Statement, Emotional, Question). Probing questions for each stage. |
| Draft & Multimedia | `skills/draft-multimedia/SKILL.md` | Media-to-beat mapping (opener, anchor, closer). 3 presentation formats (photo, video, audio). Word count target: 1,200-1,500 words. Media density rule: 1 piece per 300-400 words. Voice check before presenting draft. |
| Editorial Coaching | `skills/editorial-coaching/SKILL.md` | 3-pass structure: brevity pass, hook check, dismount check. Coaching principle: explain the "why" behind every suggestion ("kill your darlings," every sentence earns its place). Voice preservation rule: tighten, never rewrite. 2-round editing limit. |

### Supporting Outputs
| File | Purpose |
|------|---------|
| `outputs/bg-media-post-coaching-building-block-spec.md` | AI Building Block Spec — execution pattern classification, 7-step autonomy breakdown, 4 skill candidates with inputs/outputs/failure modes |
| `outputs/bg-media-post-coaching-prompt.md` | Baseline Workflow Prompt — 8-step coaching instructions with explicit checkpoint language |
| `outputs/bg-media-post-coaching-definition.md` | Workflow Definition / SOP — 229-line document with refined steps, decision points, dependency map, context shopping list, research sources |
| `TEST-RUN-OUTPUT.md` | Test run on real media (BPG Tech News screenshot). 5 human checkpoints documented with what AI proposed vs. what author changed. |

---

## 5. Lessons Learned

### The Amuse-Bouche constraint solves the blank-page problem differently
Most writing workflows start with "what do you want to write about?" This one starts with the media. Working backwards from the media to the story angles — then anchoring the narrative before writing the hook — removes the paralysis of starting from nothing. The constraint ("an amuse-bouche, not a 7-course meal") is the feature: it forces the author to commit to a single memorable moment before anything else is written.

### Human checkpoints only work if they produce changes
The test run validated this: 5 of 5 checkpoints produced substantive author interventions — title rewritten with personal voice, generic anchor rejected and replaced with the authentic feeling, origin story added, cliché killed, dismount options combined, hook language tightened. A checkpoint that authors rubber-stamp isn't a checkpoint — it's theater. The propose → react → refine loop needs to surface options that are genuinely contestable.

### Sub-skills as coaching modules
Breaking the workflow into 4 sub-skills (media analysis, story coaching, drafting, editorial) was the right call. Each sub-skill has its own domain logic, failure modes, and coaching principles. The master skill is coordination only. This structure made the HOAI assignment deliverables map cleanly: each sub-skill is a distinct building block with specified inputs, outputs, and decision logic.

### Embed all context in the skills
The Workflow Definition's context shopping list identified 8 context artifacts needed across the 8 steps (Amuse-Bouche framework, 5 Hook Types, multimedia placement principles, editing principles, etc.). Embedding all of this inside the skill files — rather than requiring external context docs — means the workflow is fully self-contained. No prep needed before invoking it.

---

## 6. Build History

### Feb 12 — Initial Build (2 commits)
- Initial commit: `BG Media Post-Coaching` workflow established
- Added multi-source media support: YouTube, Spotify, and iCloud input paths added to Step 1

### Feb 22 — Test Run and Skill Files
- Added test run output (`TEST-RUN-OUTPUT.md`) and finalized skill files for the collaborative workflow assignment submission
- Skills directory fully populated: master SKILL.md + 4 sub-skills (media-analysis, story-coaching, draft-multimedia, editorial-coaching)

### Feb 23 — HOAI Assignment Submission
- Added `SPEC.md` and `SPEC-SUMMARY.md` for the HOAI course submission
- Full assignment requirements mapping documented against all three deliverables (Building Block Spec, Baseline Prompt + Skills, Test Run)

---

## 7. Commit Log

| Hash | Date | Description |
|------|------|-------------|
| a2006543 | 2026-02-12 | Initial commit: BG Media Post-Coaching workflow |
| 2c9298f3 | 2026-02-12 | Add multi-source media support (YouTube, Spotify, iCloud) |
| c3e2ad74 | 2026-02-22 | Add test run output and skill files for collaborative workflow assignment |
| 289512d6 | 2026-02-23 | Add SPEC.md and SPEC-SUMMARY.md for HOAI assignment submission |
