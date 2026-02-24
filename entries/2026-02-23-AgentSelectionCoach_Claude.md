# AgentSelectionCoach_Claude: Agent Selection Coach Skill
## Build Journal Entry — Standard

**Builder:** Ben Giordano
**Date:** 2026-02-23
**Repo:** AgentSelectionCoach_Claude
**Status:** Complete
**Tier:** Standard

---

## 1. Problem Statement

Users building AI-powered tools frequently over-engineer their architecture — reaching for autonomous agents when a simple workflow or even a single prompt would suffice. Needed an interactive coaching skill (modeled after the Prompt Coach) that guides users through selecting the right agent architecture pattern via structured conversation, grounded in frameworks from Anthropic, Google, and OpenAI reference docs.

## 2. Solution

Built a Claude Code skill (`agent-selection-coach`) with a 5-stage guided interview flow: Task Discovery, Complexity Check, Signal Matching, Trade-off Discussion, and Recommendation Delivery. The skill actively pushes back on over-engineering, cites frameworks when coaching, personalizes trade-offs to the user's task, and hands off to the Prompt Coach skill for the next phase.

## 3. Architecture

Single Claude Code skill directory with three files:
- `SKILL.md` — Main coaching logic, 5 stages, output format, 8 behavior rules
- `references/decision-matrix.md` — Complexity Ladder, Signal-to-Pattern Map, Escalation Checklist, Anti-Patterns
- `references/pattern-catalog.md` — 8 architecture patterns with trade-offs, examples, pitfalls

Reference files are lazy-loaded at specific stages (decision-matrix in Stages 2-3, pattern-catalog in Stages 4-5). Knowledge is embedded, not dependent on external files at runtime.

## 4. Component Specifications

**SKILL.md (193 lines)**
- YAML frontmatter with trigger description covering agent/architecture questions and over-engineering detection
- Role definition with "rocket ship vs bicycle" coaching metaphor
- 5 coaching stages, each with Purpose, Questions, Listen For, Push Back, Transition
- Structured output format: Decision Path visualization + Recommendation Summary
- 8 behavior rules enforcing one-question-at-a-time, push-back-on-complexity, cite-the-framework
- Prompt Coach handoff in final output

**decision-matrix.md (120 lines)**
- 4-level Complexity Ladder (Level 0-3) with definitions, criteria, examples
- 8-row Signal-to-Pattern Map with "Why" column
- 4-question Complexity Escalation Checklist with "What a NO means"
- 8 Anti-Patterns with one-line descriptions

**pattern-catalog.md (258 lines)**
- 8 patterns: Single LLM Call, Augmented LLM, Prompt Chaining, Routing, Parallelization (Sectioning + Voting), Orchestrator-Workers, Evaluator-Optimizer, Autonomous Agent
- Each with: How it works, Choose this when, Real-world examples, Key trade-offs table, Common pitfall

## 5. Lessons Learned

- **Subagent-driven development works for Markdown content, not just code.** Dispatching implementer + spec reviewer subagents for reference doc writing caught completeness issues (count verification) that would have been easy to miss.
- **The brainstorming → design → plan → build pipeline held well.** Design doc approved before any writing started, plan broke the work into reviewable chunks, subagents executed cleanly.
- **Separate skills compose better than combined skills.** Decided to keep Agent Selection Coach and Prompt Coach as separate skills with a handoff reference rather than merging — matches the "monolithic prompts" anti-pattern the coach itself warns against.

## 6. Build History

1. Created GitHub repo (`bengio777/AgentSelectionCoach_Claude`)
2. Brainstorming: explored user intent, chose Linear Funnel approach, defined 5-stage flow
3. Design doc: approved design covering flow, output format, embedded knowledge, behavior rules
4. Implementation plan: 7 tasks from scaffold through push
5. Subagent-driven build: implementer + spec reviewer per content task
6. Smoke test: invoked skill in-session, verified coaching flow through Stage 3
7. Pushed to GitHub

## 7. Commit Log

| Hash | Date | Description |
|------|------|-------------|
| 4706dac | 2026-02-23 | Add Agent Selection Coach design document |
| 775ca3d | 2026-02-23 | Add implementation plan for Agent Selection Coach skill |
| bc26ea8 | 2026-02-23 | feat: add Agent Selection Coach skill |
