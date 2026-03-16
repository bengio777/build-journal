# content-pipeline-frontend: Draft Feed Viewer for the Content Pipeline
## Build Journal Entry — Standard

**Builder:** Ben Giordano
**Date:** 2026-03-03 (retroactive — logged 2026-03-16)
**Repo:** bengio777/content-pipeline-frontend
**Status:** Complete
**Tier:** Standard

---

## 1. Problem Statement

The content pipeline produces draft articles (news, podcast, weekly) but had no readable front-end. Drafts lived as raw markdown files with no way to browse, filter, or read them in a rendered format. A public-facing viewer was needed to surface pipeline output and serve as the display layer for the Publisher agent's deliverables.

## 2. Solution

Built a static Next.js site forked from `podcast-summaries` that reads markdown draft files from `content/drafts/`, renders them with a filterable feed on the home page, and provides individual detail pages per draft. Deployed to Vercel via GitHub auto-deploy. The site is read-only — content is sourced exclusively from the pipeline, not authored here.

## 3. Architecture

- **Framework:** Next.js (App Router, TypeScript)
- **Styling:** Tailwind CSS with dark mode support, Geist font
- **Data layer:** File-system reads at build time via `lib/drafts.ts` — no database, no API
- **Markdown processing:** `gray-matter` for frontmatter parsing, `remark` + `remark-html` for rendering, `sanitize-html` for XSS sanitization before HTML injection into the article component
- **Deployment:** Vercel via GitHub auto-deploy (push to main triggers redeploy)
- **Content contract:** Publisher agent writes files to `content/drafts/YYYY-MM-DD-[slug].md`; the frontend reads them passively

**Route structure:**
- `/` — filterable draft feed (query param `?type=news|podcast|weekly`)
- `/drafts/[slug]` — individual draft detail page with static params generation

## 4. Component Specifications

### `lib/drafts.ts`
Core data layer. Exports `getAllDrafts()` and `getDraft(slug)`.
- Reads all `.md` files from `content/drafts/`
- Parses frontmatter (`title`, `date`, `type`, `status`, `phase`)
- Extracts `lead` (first non-empty, non-divider, non-bold line) and `subheader` (first `**bold**` line after a `---` divider) from body content for card previews
- Sorts by date descending
- Sanitizes rendered HTML via `sanitize-html` with an allowlist including `h1`–`h4` and `img`

### `app/page.tsx` — Home / Feed
- Accepts `searchParams.type` for client-side-style filtering via URL query param
- Renders type-badge pill filters (All / News / Podcast / Weekly) as `<Link>` components
- Draft cards show: type badge (color-coded), date, title, subheader, and lead excerpt

### `app/drafts/[slug]/page.tsx` — Detail Page
- Uses `generateStaticParams()` to pre-generate all known slugs at build time
- `notFound()` guard for missing slugs
- Renders full article body via `prose` typography classes; HTML is pre-sanitized in the data layer

### Frontmatter Schema
```yaml
title: ""
date: "YYYY-MM-DD"
type: "news | podcast | weekly"
status: "draft"
phase: 1 | 2
```

## 5. Lessons Learned

- **Fork-and-redirect is fast but leaves stale references.** The initial fork from `podcast-summaries` required an explicit cleanup commit to remove stale references in CLAUDE.md, README, and layout metadata. Worth doing this as step one, not a follow-up.
- **Extracting lead/subheader from markdown body is fragile by design.** The `extractLeadAndSubheader` function relies on prose conventions (bold lines after `---` dividers) rather than explicit frontmatter fields. This works for the current pipeline output format but will break if the Publisher agent changes its formatting conventions. A future improvement would be to promote `lead` and `subheader` to explicit frontmatter fields.
- **Static params + `notFound()` guard is the right pattern for file-backed SSG routes.** The guard handles slug drift (e.g., a file deleted after build) gracefully without crashing the route.
- **Sanitizing HTML in the data layer, not at render time, is the right approach.** The sanitization happens inside `getDraft()` before the HTML string is returned, so it cannot be bypassed by component consumers. The rendered article component receives pre-sanitized HTML.

## 6. Build History

**Day 1 — Mar 3 (Bootstrap + Core Features)**
Forked from `podcast-summaries`, cleaned stale references, replaced the data layer with `drafts.ts`, built the home feed page with type filters, added the draft detail page with `notFound()` guard, and seeded `content/drafts/` with existing pipeline drafts. 9 commits.

**Day 2 — Mar 4 (Content)**
Added the "Dark Patterns, Upgraded" draft article. 1 commit.

**Day 3 — Mar 5 (Polish + Content)**
Added "The Verification Gap" draft. Improved card display to show subheader and lead. Updated page title, added mission statement subheader to the page header, and updated the subtitle to a daily digest description. 4 commits.

## 7. Commit Log

| Hash | Date | Description |
|------|------|-------------|
| `44afbb48` | 2026-03-05 | Update page subtitle to daily digest description |
| `5341e4e3` | 2026-03-05 | Add mission statement subheader to page header |
| `b620c841` | 2026-03-05 | Update page title to BG Tech News Analysis (drafts) |
| `0457e1e2` | 2026-03-05 | feat: show subheader and lead on draft cards |
| `2275e18b` | 2026-03-05 | feat: add draft — The Verification Gap |
| `33c1881e` | 2026-03-04 | feat: add draft — Dark Patterns, Upgraded |
| `12ccc770` | 2026-03-03 | chore: update package-lock.json |
| `7c1ad925` | 2026-03-03 | feat: seed content/drafts with existing pipeline drafts |
| `46141f12` | 2026-03-03 | fix: add notFound guard for missing draft slugs |
| `1b1717ef` | 2026-03-03 | feat: add draft detail page |
| `91e79631` | 2026-03-03 | feat: add draft feed home page with type filters |
| `f9f3a97f` | 2026-03-03 | feat: replace data layer with drafts.ts |
| `ad54d722` | 2026-03-03 | fix: update stale podcast-summaries references in CLAUDE.md, README, and layout metadata |
| `1db180c6` | 2026-03-03 | feat: bootstrap content-pipeline-frontend from podcast-summaries |
