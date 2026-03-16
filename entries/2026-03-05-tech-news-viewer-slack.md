# BPG Tech News Dashboard: Slack Integration
## Build Journal Entry — Standard

**Builder:** Ben Giordano
**Date:** 2026-03-05 (retroactive — logged 2026-03-16)
**Repo:** bengio777/tech-news-viewer_admin
**Status:** Complete
**Tier:** Standard

---

## 1. Problem Statement

The BPG Tech News pipeline produced a daily briefing but had no review or approval step. Drafts were written directly to GitHub and emailed without human review. The goal was to add a Slack-based review loop where each day's draft is posted to a channel with image previews, allowing the editor to swap images or publish from Slack without touching a terminal.

A secondary requirement: the system needed persistent draft state across Slack interactions (button clicks, ephemeral pickers) so that image selections and publish actions could always reference the correct draft version — even if triggered minutes apart.

## 2. Solution

Added a full Slack integration layer to the Next.js admin dashboard (`tech-news-viewer_admin`), with three API routes and two supporting lib modules:

- **`/api/slack/draft`** — Receives the draft from `run-briefing.sh`, stores it in Vercel KV, and posts a Block Kit message to Slack with image previews and action buttons.
- **`/api/slack/interactions`** — Handles button callbacks: swap image (shows ephemeral picker), select image (updates KV + refreshes Slack message), publish (writes final markdown to GitHub with selected images applied), and regenerate (instructs user to re-run the pipeline).
- **`/api/slack/events`** — Handles the `/briefing` slash command for status checks, publish, and watchlist management (add/remove/list companies).
- **`lib/kv.ts`** — Typed KV layer over `@vercel/kv` for draft CRUD (`saveDraft`, `getDraft`, `updateTabImage`, `markPublished`) and watchlist operations. Drafts stored with 7-day TTL.
- **`lib/slack.ts`** — Block Kit builders (`buildDraftMessage`, `buildImagePickerBlocks`), Slack API helpers (`postMessage`, `updateMessage`, `postEphemeral`), and HMAC-SHA256 signature verification using the Web Crypto API.

Four bugs were found and fixed within the same session during initial testing.

## 3. Architecture

```
run-briefing.sh
    |
    POST /api/slack/draft  (x-draft-secret auth)
    |
    ├── saveDraft() → Vercel KV (draft:YYYY-MM-DD, 7-day TTL)
    └── buildDraftMessage() → postMessage() → Slack channel
                                    |
                          [Slack Block Kit message]
                          Header + status line + per-tab section:
                          - Story context link
                          - Image preview (if URL passes validator)
                          - "Swap Image" button
                          + Publish / Regenerate buttons
                                    |
                          User clicks button
                                    |
                          POST /api/slack/interactions  (HMAC-SHA256 sig verify)
                          |
                          ├── swap_image   → buildImagePickerBlocks() → postEphemeral()
                          ├── select_image → updateTabImage() in KV
                          │                  → buildDraftMessage() → updateMessage() in Slack
                          ├── publish_briefing → applySelectedImages() → GitHub Contents API PUT
                          │                      → markPublished() in KV
                          └── regenerate_briefing → ephemeral: "run run-briefing.sh again"

          /briefing <subcommand>
                          |
                          POST /api/slack/events  (HMAC-SHA256 sig verify)
                          |
                          ├── status [date] → getDraft() → tab-by-tab image status
                          ├── watch add/remove/list → KV watchlist ops
                          └── help → command reference
```

**KV key schema:**
- `draft:YYYY-MM-DD` → `BriefingDraft` object (7-day TTL)
- `watchlist` → `string[]` of company names

**Slack image URL validator** (`isSlackImageUrl`):
- Accepts: `.jpg`, `.jpeg`, `.png`, `.gif`, `.webp` by extension
- Accepts: `images.unsplash.com` (CDN, no extension in path)
- Accepts: URLs with `?fm=jpg|jpeg|png|webp` query parameter
- Rejects: all other URLs (prevents broken Slack image blocks)

**GitHub publish path** (from interactions route):
- Applies `selectedUrl ?? autoUrl` per tab, injecting image markdown after `<!-- tab: Name -->` markers
- Writes to `YYYY/week-WW/YYYY-MM-DD.md` in the catalog repo
- Handles both create and update (checks for existing SHA)

## 4. Component Specifications

### API Routes

| Route | Auth Method | Key Behavior |
|-------|-------------|-------------|
| `POST /api/slack/draft` | `x-draft-secret` header | Stores draft in KV, posts to Slack, saves `slackTs` for later updates |
| `POST /api/slack/interactions` | HMAC-SHA256 signature | Routes 4 action IDs; updates Slack message in-place on image select |
| `POST /api/slack/events` | HMAC-SHA256 signature | `/briefing` slash command with 5 subcommand paths |

### lib/kv.ts

| Export | Signature | Notes |
|--------|-----------|-------|
| `saveDraft` | `(draft: BriefingDraft) → void` | Sets `draft:date` with 7-day TTL |
| `getDraft` | `(date: string) → BriefingDraft \| null` | |
| `updateTabImage` | `(date, tabLabel, selectedUrl) → void` | Throws if draft or tab not found |
| `markPublished` | `(date: string) → void` | Sets `status: "published"` |
| `getWatchlist` | `() → Watchlist` | Defaults to `[]` |
| `addToWatchlist` | `(company: string) → Watchlist` | Deduplicates by exact string |
| `removeFromWatchlist` | `(company: string) → Watchlist` | Case-insensitive match |

### lib/slack.ts

| Export | Purpose |
|--------|---------|
| `buildDraftMessage` | Per-tab sections: story context link + image block + Swap button; Publish/Regenerate footer |
| `buildImagePickerBlocks` | Ephemeral picker: OG image, recommended images, stock photos — each with labeled Select button |
| `verifySlackSignature` | Web Crypto HMAC-SHA256; rejects requests older than 5 minutes |
| `postMessage` / `updateMessage` / `postEphemeral` | Thin wrappers over `chat.postMessage`, `chat.update`, `chat.postEphemeral` |
| `respondToUrl` | Fire-and-forget POST to Slack response URL |

### Image Category Labels

| Old Label | New Label |
|-----------|-----------|
| Meme | Stock Photo |

## 5. Lessons Learned

### Surface API errors at the boundary
The first version of the draft endpoint checked `result.ok` but only logged the error — it still returned `200`. Slack errors (`invalid_blocks`, auth failures) were invisible. The fix: check `result.ok` and return `502` with `slackError` in the response body. **Takeaway: for any external API call, treat a non-ok response as an error at the HTTP boundary, not just in logs.**

### Slack's image block validator is strict
Slack rejects image blocks with URLs that don't end in a recognized image extension — even if the URL resolves to a valid image (Unsplash CDN URLs have no extension). This only surfaced during live testing. The fix required adding Unsplash domain detection and `?fm=` parameter parsing to the validator. **Takeaway: test image block rendering with actual CDN URLs before shipping. Don't assume HTTPS URL = accepted.**

### Block Kit button `style` has only two valid values
`style: "default"` is not a valid Slack button style — only `"primary"` and `"danger"` are accepted. The invalid value caused silent block validation failures. **Takeaway: reference the Block Kit docs for each field's valid enum values, not just the field names.**

### KV as interaction state eliminates stateless callbacks
Slack interactions are stateless HTTP callbacks — there's no shared memory between the button click and the server. Storing the full `BriefingDraft` in KV (keyed by date) means every interaction can retrieve the full context, update a single field, and re-render the message correctly. The `slackTs` stored on the draft is what enables in-place message updates. **Takeaway: for multi-step Slack workflows, always store state externally. Pass only a key (date, ID) in button values.**

## 6. Build History

### Session (Mar 5, 2026 — ~2 hours)

| Step | What Happened |
|------|--------------|
| Foundation | Created `lib/kv.ts` (typed KV layer) and `lib/slack.ts` (Block Kit builders + HMAC verifier). Defined `BriefingDraft` and `TabImageState` types. |
| Draft route | Built `/api/slack/draft` — receives POST from pipeline, stores in KV, posts Block Kit message with per-tab image previews. |
| Interactions | Built `/api/slack/interactions` — swap image (ephemeral picker), select image (KV update + Slack message update), publish (GitHub write), regenerate (instructs to re-run). |
| Events | Built `/api/slack/events` — `/briefing` slash command with status, watch, and help subcommands. |
| Fix 1 | Slack API errors not surfaced: draft endpoint returned 200 on Slack failure. Fixed with `result.ok` check → 502. |
| Fix 2 | Unsplash CDN URLs rejected by image validator. Added `images.unsplash.com` domain check and `?fm=` param detection. |
| Fix 3 | `style="default"` on Slack button block invalid. Removed the `style` property entirely (defaults to unstyled). |
| Fix 4 | Image picker label "Meme" renamed to "Stock Photo" in `buildImagePickerBlocks`. |
| Top story context | Added `topStory` field to `TabImageState`. `buildDraftMessage` shows linked story title next to each tab image block. |

## 7. Commit Log

| Hash | Date | Description |
|------|------|-------------|
| `9a230614` | 2026-03-05 | feat: add Slack integration with KV draft management |
| `8a2051bc` | 2026-03-05 | fix: surface Slack API errors from draft endpoint |
| `bfae5701` | 2026-03-05 | fix: remove invalid style="default" from Slack button block |
| `a4e1755f` | 2026-03-05 | fix: allow Unsplash CDN URLs in Slack image validator |
| `298a1093` | 2026-03-05 | fix: rename Meme to Stock Photo in image picker labels |
| `e10f1d5c` | 2026-03-05 | feat: show top story context in Slack draft image blocks |
