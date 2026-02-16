# Build Journal Activation Redesign

**Date:** 2026-02-15
**Status:** Approved

## Problem

The current SessionStart hook fires on every session, asking two activation questions before any work begins. This adds friction to sessions that don't need build journal tracking.

## Decision

Move from automatic SessionStart activation to on-demand activation via:

1. **Slash command** (`/build-journal`) — primary, explicit entry point
2. **Natural language detection** — via enriched skill description trigger phrases
3. **Wrap-up signals** — always fire regardless of prior activation

## What Changes

### Remove
- `hooks/hooks.json` — SessionStart hook configuration
- `hooks/session-start.sh` — SessionStart hook script

### Add
- `commands/build-journal.md` — Slash command for explicit activation

### Modify
- `skills/build-journal/SKILL.md` — Expanded trigger phrases and updated flow

## Slash Command

**File:** `commands/build-journal.md`

Simple activation command with no arguments. On invocation:
1. Confirms activation ("Build Journal tracking is on")
2. Asks one question: "Want the end-of-session interview when we wrap up?"
3. Begins watching for wrap-up signals

## Skill Description Trigger Phrases

Three categories:

1. **Explicit activation** — "start build journal", "activate build journal", "build journal on"
2. **Contextual cues** — "track this build", "let's document this session", "I want to journal this", "let's capture what we're building"
3. **Wrap-up signals** (existing) — "closing out", "done for the day", "wrapping up the build", "project is done", "pausing work", "picking this up tomorrow", "stopping for now"

## Activation Flow

- Categories 1-2 (activation): Ask interview preference, begin tracking
- Category 3 (wrap-up): Run retrospective/recap flow directly
- Wrap-up signals fire whether or not tracking was activated earlier — no missed entries

## Approach Rationale

Chose skill-description-based detection over a UserPromptSubmit hook because:
- Zero overhead — no hook running on every message
- Simpler architecture — one mechanism instead of two
- Extensible later — can add UserPromptSubmit hook if skill matching proves too narrow
