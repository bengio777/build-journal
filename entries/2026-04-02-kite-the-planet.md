# Kite the Planet: Platform V2 Schema, Operator Portal, and Admin QA Layer
## Build Journal Entry — Full

**Builder:** Ben Giordano
**Build Date:** 2026-04-02 (work spans Apr 1–2)
**Platform:** Next.js 15 / TypeScript / Supabase / Vercel
**Status:** In Progress — V2 schema live, operator portal live, admin QA layer live
**Repo:** https://github.com/bengio777/KTP_V01.git
**Tier:** Full

---

## 1. Problem Statement

V1 shipped with flat `operators` and `instructors` tables. This worked for the initial scaffold but broke down the moment real operator onboarding began:

- No support for multi-role organizations (a school has an owner, managers, instructors, and staff — not just one "operator")
- Instructors added by an org couldn't exist in the system until they created an account (no unclaimed profiles)
- No RBAC layer — any "operator" could see or touch any record
- No path to a people-layer CRM for managing relationships across roles over time
- `operators` and `instructors` tables were structurally incompatible with the persona roadmap (travelers will eventually also be `profiles`)

The schema needed a ground-up redesign before operator acquisition could begin in earnest.

---

## 2. Solution

Designed and shipped Platform V2 across two days:

**Schema redesign:**
- `organizations` table (replaces `operators`) — holds schools, rental shops, brands; `org_types[]`, `iko_certified`, Supabase Storage media
- `profiles` table (replaces `instructors`) — any person in the system: owner, instructor, staff, or future traveler; `user_id = null` for unclaimed
- `org_memberships` join table — links profiles to orgs with `role` (owner/admin_manager/manager/instructor/staff), `status`, `joined_at`
- All FK references migrated: `operator_id → org_id`, `instructor_id → profile_id`, 13 files updated

**Operator portal features (Apr 1–2):**
- Onboarding flow with media upload infrastructure
- Media storage migrated from Vercel Blob to Supabase Storage
- 28-day rolling lesson/schedule calendar (`/operator/schedule`)
- Availability slots + package management (V2 FK wiring)
- Experiences CRUD (V2 FK wiring)
- Inquiries + intake/payment link generation (V2 FK wiring)
- Telegram bot notification wiring (slug lookup fix)
- Stripe webhook Supabase module-load initialization fix

**Admin QA layer:**
- `/admin/people` — all profiles with membership/role/claimed/IKO/language/specialty breakdown; stat cards
- `/admin/lab/experiences` — card grid of all operator_experiences with status badges and org names
- `/admin/lab/instructors` — card grid of instructors from org_memberships with profile badges
- `/admin/schools` — member + instructor counts per org via parallel org_memberships query
- `/admin/integrations` — progress-bar dashboard of API integration status

**Public coming-soon pages:**
- `/experiences` and `/instructors` — dark zinc-950 holding pages with back-link

**Deploy workflow standardization:**
- Identified GitHub falling silently behind when using `vercel --prod` directly (GitHub-triggered builds had been CANCELED)
- Established atomic rule: `vercel --prod` → commit → push, treated as one operation
- Committed 45 files + pushed to sync GitHub with Vercel production

---

## 3. Architecture

```
Supabase (PostgreSQL)
├── organizations          → replaces operators
│   ├── id (uuid)
│   ├── name, slug, description
│   ├── org_types (text[])
│   ├── iko_certified (boolean)
│   ├── country, location, website, email
│   └── logo_url, gallery_urls (Supabase Storage)
│
├── profiles               → replaces instructors
│   ├── id (uuid)
│   ├── user_id (uuid, nullable — null = unclaimed)
│   ├── display_name, bio
│   ├── languages (text[]), specialties (text[])
│   ├── iko_certified (boolean), iko_level (text)
│   └── is_public (boolean)
│
└── org_memberships        → join table (RBAC layer)
    ├── org_id → organizations.id
    ├── profile_id → profiles.id
    ├── role: owner | admin_manager | manager | instructor | staff
    ├── status: active | invited | suspended
    └── joined_at (timestamptz)

Next.js 15 App Router
├── /operator/*            → operator portal (auth-gated, profile→membership→orgId pattern)
├── /admin/*               → internal admin (force-dynamic, no auth gate)
├── /admin/lab/*           → pre-production QA views
├── /operators/[slug]      → public school profiles (organizations table)
├── /experiences           → coming soon (public)
└── /instructors           → coming soon (public)

Vercel (production)
├── vercel --prod CLI deploy (GitHub integration bypassed due to CANCELED queue issue)
└── Deploy sequence: vercel --prod → git commit → git push (atomic)
```

---

## 4. Data Schema

### Key Migrations (Apr 1–2)

| Migration File | Description |
|---------------|-------------|
| `20260402000000_school_operators_v1.sql` | School operator portal schema (availability, packages) |
| `20260402000001_instructor_availability.sql` | Instructor schedule and availability slots |
| `20260402000002_platform_v2_people_orgs.sql` | Core V2 schema: organizations, profiles, org_memberships |
| `20260402000003_profiles_iko_level.sql` | Add iko_level (text) to profiles — pending application to live Supabase |

### Auth Pattern (V2)

All operator portal pages use this standard flow:

```typescript
const supabase = await createClient()
const { data: { user } } = await supabase.auth.getUser()
if (!user) redirect('/operator/login')

const { data: profile } = await supabase
  .from('profiles')
  .select('id')
  .eq('user_id', user.id)
  .single()

const { data: membership } = await supabase
  .from('org_memberships')
  .select('org_id, role')
  .eq('profile_id', profile.id)
  .eq('status', 'active')
  .single()

// Use membership.org_id for all subsequent queries
```

### Nested Join Normalization

PostgREST FK joins return arrays in some configurations. Standard normalization:

```typescript
const orgName = (Array.isArray(m.organizations) ? m.organizations[0] : m.organizations)?.name ?? '—'
```

---

## 5. Component Specifications

### `/admin/people` — People Admin Page
- **Data**: `profiles` + nested `org_memberships(org_id, role, status, joined_at, organizations(name))`
- **Stat cards**: Total, Claimed, Unclaimed, IKO, Public
- **Table columns**: Name + truncated UUID, Org/Role badges (role color map), Claimed badge, IKO + level, Languages (max 3), Specialties (max 2), Public flag, Created date
- **Role color map**: owner=purple, admin_manager=indigo, manager=blue, instructor=sky, staff=gray
- **TypeScript note**: Explicit type annotation required on memberships array to prevent implicit-any from `never[]` inference

### `/admin/lab/experiences` — Experiences QA View
- **Data**: `operator_experiences` + nested `organizations`
- **Layout**: 3-column card grid
- **Card**: photo, title, status badge (published/draft), type pill, org name, description (line-clamp-2), price + capacity
- **Stat cards**: Total, Published, Draft, With Price

### `/admin/lab/instructors` — Instructors QA View
- **Data**: `org_memberships` (role=instructor) + nested `profiles` + `organizations`
- **Layout**: card grid with avatar/initials circle
- **Card**: name, org + location, status/claimed/IKO/public badges, bio, languages, specialties

### `/admin/schools` — Member Counts
- Parallel query for `org_memberships` aggregated into `Record<orgId, {total, instructors}>`
- No PostgREST count syntax needed — JS aggregation post-fetch

### `/operator/schedule` — 28-Day Lesson Calendar
- Rolling calendar with availability slots and assigned instructors
- Date-indexed grid view

### `/admin/integrations` — Integrations Dashboard
- Progress bar layout showing API integration status per partner
- Two-section structure: active + pending

---

## 6. Lessons Learned

### Schema Design Method
The unlock for RBAC schema design was a structured user-story → gap-table → deconstruct → defer workflow:
1. Write user stories for each persona (operator owner, instructor, traveler)
2. Ask: "Given this context, what gaps am I not considering?" → table format
3. Walk through each gap: necessary for V1, or defer?
4. Defer non-essential gaps to explicit V2/V3 backlog items

This approach prevented over-engineering while ensuring the core schema was correct. The iterative rough-draft → user-stories → gap-analysis → finalize sequence is the right method for schema design with fuzzy requirements.

### Deploy Workflow
`vercel --prod` + `git push` are one atomic operation. GitHub falls silently behind when using CLI deploys exclusively (GitHub-triggered Vercel builds can get stuck in CANCELED queue). The correct sequence is:
1. `vercel --prod` (deploys to production)
2. `git commit` (captures all changes)
3. `git push` (syncs GitHub)

Never end a session with deployed-but-uncommitted changes.

### TypeScript Strict Mode + Supabase
Arrays derived inside `.map()` with no type context are inferred as `never[]`, causing implicit-any errors on the callback parameter `m`. Fix: explicit type annotation on the derived array const, not the callback.

```typescript
// Wrong — memberships inferred as never[], m is implicitly any
const memberships = array.map((m) => ({ ... }))

// Right — explicit type annotation
const memberships: { orgName: string; role: string }[] =
  array.map((m: any) => ({ ... }))
```

### Supabase Local Build Error
`supabaseKey is required` fires at build time when Supabase client instantiates in API routes without env vars. This is a pre-existing local dev issue (not caused by schema migration). Build succeeds on Vercel where env vars are set. Don't diagnose this as a migration problem.

---

## 7. Build History

| Date | Phase | Key Output |
|------|-------|------------|
| Apr 1 | Operator portal foundation | Onboarding flow, media upload infra, Supabase Storage migration, Telegram bot |
| Apr 1 | Operator portal V2 | Role fix, public profiles, experiences, pricing |
| Apr 1–2 | Stripe + integrations | Webhook Supabase init fix, integrations dashboard |
| Apr 2 | School operator portal | 28-day schedule calendar, admin dashboards |
| Apr 2 | Platform V2 architecture | Docs, schema design, user story → gap analysis |
| Apr 2 | V2 migrations | 4 migration files, RBAC tables live in Supabase |
| Apr 2 | V2 code migration | 13 files: operator_id → org_id, instructor_id → profile_id |
| Apr 2 | Admin QA layer | People page, Lab experiences/instructors views |
| Apr 2 | Public pages | /experiences, /instructors coming-soon |
| Apr 2 | Deploy sync fix | GitHub caught up, atomic deploy workflow established |

---

## 8. Repository File Manifest (Session-Created)

| File Path | Description |
|-----------|-------------|
| `app/admin/people/page.tsx` | People admin page — all profiles with membership breakdown |
| `app/admin/lab/experiences/page.tsx` | Lab QA view — all operator experiences |
| `app/admin/lab/instructors/page.tsx` | Lab QA view — all instructors from org_memberships |
| `app/experiences/page.tsx` | Public coming-soon page for experiences |
| `app/instructors/page.tsx` | Public coming-soon page for instructors |
| `app/operator/schedule/page.tsx` | 28-day rolling lesson calendar |
| `app/operator/schedule/LessonCalendar.tsx` | Calendar component |
| `app/admin/integrations/page.tsx` | Integrations status dashboard |
| `app/admin/integrations/IntegrationsDashboard.tsx` | Dashboard component with progress bars |
| `docs/plans/2026-04-02-platform-architecture-people-orgs.md` | Platform V2 architecture doc |
| `supabase/migrations/20260402000000_school_operators_v1.sql` | School operator portal schema |
| `supabase/migrations/20260402000001_instructor_availability.sql` | Instructor availability schema |
| `supabase/migrations/20260402000002_platform_v2_people_orgs.sql` | V2 organizations/profiles/memberships |
| `supabase/migrations/20260402000003_profiles_iko_level.sql` | Add iko_level to profiles (pending apply) |
| `lib/whatsapp.ts` | WhatsApp notification utility |
| `tools/gmaps-scraper/seed_operators_supabase.py` | Seed organizations table from gmaps data |

---

## 9. Reusable Architecture Pattern

### The People + Orgs + RBAC Triad

This schema pattern works for any multi-tenant platform with human roles:

```sql
-- Any entity that employs or associates people
organizations (id, name, slug, type[], metadata)

-- Any person in the system (owned or not)
profiles (id, user_id NULLABLE, display_name, metadata)
-- user_id = null → unclaimed (invited but not registered)
-- user_id = uuid → claimed (has logged in)

-- The join with role enforcement
org_memberships (org_id, profile_id, role ENUM, status ENUM, joined_at)
```

**Why it works:**
- Separates identity (profiles) from affiliation (memberships)
- Enables unclaimed invites before a person has an account
- RBAC lives in the join table, not in the profile or org
- Personas can accumulate memberships (an instructor at org A and org B)
- Travelers will eventually be profiles too — the schema extends without breaking

**Auth pattern**: always resolve `user → profile → membership → org_id` before any org-scoped query.

---

## 10. Next Steps

### Completed
- [x] Platform V2 schema: organizations, profiles, org_memberships
- [x] All V1 FK references migrated (13 files)
- [x] Admin QA layer for visual schema validation
- [x] Operator portal wired to V2 schema
- [x] School operator portal + schedule calendar
- [x] Public coming-soon pages for experiences and instructors
- [x] Deploy workflow standardized (atomic vercel --prod + push)

### Remaining
- [ ] Apply `20260402000003_profiles_iko_level.sql` migration to live Supabase (iko_level column)
- [ ] Rough drafts for additional personas (traveler profile, instructor public page)
- [ ] Flight search engine end-to-end testing
- [ ] Trip workflow end-to-end testing
- [ ] Operator acquisition: seed real organizations from gmaps data (`seed_operators_supabase.py`)
- [ ] Agent team activation: BrandVoiceAgent first per CLAUDE.md build sequence
