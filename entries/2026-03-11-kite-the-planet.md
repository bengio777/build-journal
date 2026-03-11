# Kite the Planet: Locale and Currency System
## Build Journal Entry — Full

**Builder:** Ben Giordano
**Build Date:** 2026-03-11
**Platform:** Next.js 15, TypeScript, Tailwind, Supabase, Vercel
**Status:** Complete — PR #1 open
**Repo:** bengio777/KTP_V01
**Tier:** Full

---

## 1. Problem Statement

Kite the Planet serves a global audience of kitesurfers booking travel across 198 spots worldwide. Prices need to display in the user's local currency, and the app needs to detect a new visitor's locale without requiring them to configure anything. The challenge: language alone doesn't determine currency — Portuguese speakers could be in Portugal (EUR) or Brazil (BRL), English speakers could be in the US (USD), UK (GBP), or Ireland (EUR). The system needed to handle these ambiguities correctly and stay in sync across anonymous sessions, localStorage, and authenticated Supabase accounts.

---

## 2. Solution

A full locale and currency system built in 18 tasks using subagent-driven development (TDD, fresh subagent per task, two-stage review). The system:

- Detects locale from `navigator.language` (BCP 47) on first visit with 3-tier resolution
- Persists locale in localStorage between sessions
- Syncs with Supabase `users.locale_code` on login
- Fetches live exchange rates weekly via Open Exchange Rates cron
- Formats prices in both user currency and destination currency via `Intl.NumberFormat`
- Surfaces locale selection via `NavFlagChip` → `FlagPicker` popover in the nav
- Captures locale preference in onboarding Step 0 (`LocaleStep`)

53 tests across 10 test files. Build clean.

---

## 3. Architecture

### Locale Detection Flow
```
navigator.language (BCP 47)
  → detectLocaleCode() — 3-tier: exact match → language tie-breaker → 'US' fallback
  → getLocaleByCode() — resolves to full Locale object
  → LocaleProvider (Effect 1) — stored code takes priority over auto-detect
  → LocaleProvider (Effect 2) — login overwrites with Supabase locale_code
```

### Price Display Flow
```
amountUSD + userLocale + exchangeRates + destinationCurrency?
  → formatPrice() — converts via rates, formats via Intl.NumberFormat
  → FormattedPrice { primary, secondary? }
  → PriceBlock — renders with CSS custom property colors
```

### Key Design Decisions

**`navigator.language` over IP geolocation.** Browser language is zero-cost, already on the client, and encodes both language and region (e.g. `pt-BR` vs `pt-PT`). IP geolocation requires a third-party API call, adds latency, and breaks on VPNs and shared IPs.

**BCP 47 three-tier resolution.** Exact region match → language tie-breaker map → fallback. This correctly disambiguates `pt-BR` (Brazil/BRL) from `pt` (Portugal/EUR), and `en-GB` (UK/GBP) from `en` (US/USD).

**Two-phase SSR hydration.** Server renders with US/USD default. Client mount reads localStorage. Prevents hydration mismatch without blocking the render.

**`upsert` not `update` in LocaleStep.** User row may not exist yet at onboarding Step 0. `update` would silently no-op.

---

## 4. Data Schema

### `exchange_rates` table
```sql
CREATE TABLE exchange_rates (
  from_currency TEXT NOT NULL,
  to_currency   TEXT NOT NULL,
  rate          NUMERIC NOT NULL,
  updated_at    TIMESTAMPTZ DEFAULT now(),
  PRIMARY KEY (from_currency, to_currency)
);
-- RLS: read-all policy
-- Seed: USD→USD rate of 1.0
```

### `users` table addition
```sql
ALTER TABLE users ADD COLUMN IF NOT EXISTS locale_code TEXT NOT NULL DEFAULT 'US';
```

### localStorage
```json
{ "code": "GB" }
```
Key: `ktp_locale`. JSON-wrapped for forward compatibility.

---

## 5. Component Specifications

| Component | Location | Responsibility |
|-----------|----------|----------------|
| `lib/locales.ts` | Data | 15 locales, `Locale` type, featured/all helpers |
| `lib/detect-locale.ts` | Logic | BCP 47 → locale code, 3-tier resolution |
| `lib/format-price.ts` | Logic | USD → local + destination currency formatting |
| `lib/locale-storage.ts` | Persistence | localStorage get/set with SSR guard + error handling |
| `lib/supabase/client.ts` | Infrastructure | Browser Supabase client factory |
| `lib/supabase/server.ts` | Infrastructure | Server Supabase client factory (async, cookie adapter) |
| `lib/locale-context.tsx` | State | `LocaleProvider`, `useLocale`, two-effect sync |
| `app/api/cron/refresh-exchange-rates/route.ts` | API | Weekly OXR fetch + Supabase upsert |
| `components/ui/PriceBlock.tsx` | UI | Dual-currency price display |
| `components/locale/FlagPicker.tsx` | UI | Flag grid with featured + all regions |
| `components/locale/NavFlagChip.tsx` | UI | Nav popover trigger |
| `components/onboarding/LocaleStep.tsx` | UI | Onboarding Step 0 locale confirmation |
| `app/layout.tsx` | Wiring | Server-fetches rates, wraps app in LocaleProvider |
| `supabase/migrations/` | DB | exchange_rates table + users.locale_code |
| `vercel.json` | Infra | Weekly cron schedule (`0 0 * * 0`) |

---

## 6. Lessons Learned

### Tool authorization friction at scale
Running 18 tasks with a fresh subagent per task, two-stage review, and TDD generates a high volume of tool calls that each require manual approval. The volume wasn't a problem — the implementation quality was excellent — but the hands-on authorization requirement made it less autonomous than ideal. Next step: build a whitelist of known-safe commands (test runners, read operations, git log, npm install) so future sessions require fewer interruptions.

### Language ≠ currency — and BCP 47 knows the difference
The locale disambiguation problem was more nuanced than it first appeared:
- `pt` could be Portugal (EUR) or Brazil (BRL)
- `en` could be US (USD), UK (GBP), Ireland (EUR), or dozens of others

The key insight: `navigator.language` already encodes the region in BCP 47 tags (`pt-BR`, `en-GB`). A three-tier resolver (exact match → language tie-breaker → fallback) handles all cases without needing IP geolocation. The tie-breaker map assigns the most likely country for bare language codes, and explicit user selection or Supabase sync overrides the auto-detect anyway.

### `Intl.NumberFormat` has engine-specific gotchas
- Missing `minimumFractionDigits: 0` causes engine-dependent output (some engines render "€100.00", others "€100")
- Non-breaking space (U+00A0) is used as a thousands separator and currency-symbol spacer in some locales — test assertions must use `\u00A0` or they fail intermittently across environments
- Discovered empirically, not from docs

### Two-stage review catches real bugs
The spec compliance + code quality review cycle (not just self-review) caught multiple real issues that would have shipped:
- `setLocale` typed as `void` but implemented as `async` (type mismatch)
- `FlagPicker` preview card showing `locale.language` instead of `locale.country` (spec deviation)
- `fetchRates` throwing `null` on empty data (silent diagnostic hole)
- Missing `.catch()` on login reconciliation effect (unhandled promise rejection)

---

## 7. Build History

| Hash | Date | Description |
|------|------|-------------|
| `8465cd7` | 2026-03-11 | feat(onboarding): add LocaleStep (Step 0) locale confirmation screen |
| `041fece` | 2026-03-11 | fix(locale): improve error diagnostics in fetchRates and reconciliation effect |
| `416ccc7` | 2026-03-11 | feat(locale): reconcile Supabase locale_code to localStorage on login |
| `5cb1595` | 2026-03-11 | feat(locale): auto-detect locale from navigator.language on first visit |
| `247f39a` | 2026-03-11 | feat(layout): wire LocaleProvider with server-fetched exchange rates |
| `8cea75a` | 2026-03-11 | fix(ui): restore locale.country in FlagPicker preview card per spec |
| `b238703` | 2026-03-11 | feat(ui): add NavFlagChip with popover flag picker |
| `6baaaf4` | 2026-03-11 | feat(ui): add FlagPicker component with featured + all regions layout |
| `398991a` | 2026-03-11 | feat(ui): add PriceBlock component with dual-currency display |
| `a8fb0ac` | 2026-03-11 | feat(tokens): add pricing color tokens for light and dark modes |
| `f65f1fb` | 2026-03-11 | fix(locale): update setLocale type to Promise<void> to match async implementation |
| `52828ae` | 2026-03-11 | feat(locale): add LocaleContext with localStorage + Supabase sync |
| `ca6898f` | 2026-03-11 | fix(cron): add upsert failure test and guard invalid OXR response |
| `0f7d2c2` | 2026-03-11 | feat(cron): add weekly exchange rate refresh from OXR |
| `c7a9f80` | 2026-03-11 | feat(db): add exchange_rates table and users.locale_code migration |
| `7b29688` | 2026-03-11 | fix(supabase): correct import from next/headers |
| `44576cf` | 2026-03-11 | feat(supabase): add browser and server client factories |
| `dca42bf` | 2026-03-11 | fix(locale): harden localStorage helpers and add corrupted storage test |
| `3c89d43` | 2026-03-11 | feat(locale): add localStorage helpers for locale persistence |
| `aea5634` | 2026-03-11 | fix(locale): tighten formatPrice tests and fix minimumFractionDigits |
| `07d028a` | 2026-03-11 | feat(locale): add formatPrice with dual-currency display logic |
| `6f7cbff` | 2026-03-11 | test(locale): add exact-match edge case tests for de-CH and es-AR |
| `4346114` | 2026-03-11 | feat(locale): add locale auto-detection from navigator.language |
| `07fcc67` | 2026-03-11 | feat(locale): add static locale config with 15 flag entries |
| `06223ca` | 2026-03-11 | chore: add vitest + supabase dependencies |
| `8b87342` | 2026-03-11 | chore: ignore .worktrees directory |
| `77160fe` | 2026-03-11 | feat(plan): add locale and currency system implementation plan |
| `d399f7f` | 2026-03-11 | docs(spec): finalize locale/currency spec — reviewer approved |
| `6a48a88` | 2026-03-11 | feat(spec): add locale and currency system design |

---

## 8. Repository File Manifest

| File Path | Description |
|-----------|-------------|
| `lib/locales.ts` | 15-locale config, Locale type, featured/all helpers |
| `lib/detect-locale.ts` | BCP 47 → locale code, 3-tier resolution |
| `lib/format-price.ts` | formatPrice, ExchangeRates type, FormattedPrice type |
| `lib/locale-storage.ts` | localStorage get/set with SSR guard |
| `lib/locale-context.tsx` | LocaleProvider, useLocale, two-effect sync |
| `lib/supabase/client.ts` | createBrowserClient factory |
| `lib/supabase/server.ts` | createServerClient async factory |
| `app/layout.tsx` | Root layout — fetches rates, wraps in LocaleProvider |
| `app/globals.css` | Pricing CSS custom properties |
| `app/api/cron/refresh-exchange-rates/route.ts` | Weekly OXR → Supabase exchange rate refresh |
| `components/ui/PriceBlock.tsx` | Dual-currency price display component |
| `components/locale/FlagPicker.tsx` | Flag grid picker, featured + all regions |
| `components/locale/NavFlagChip.tsx` | Nav popover trigger for locale selection |
| `components/onboarding/LocaleStep.tsx` | Onboarding Step 0 — locale confirmation |
| `supabase/migrations/001_exchange_rates.sql` | exchange_rates table + RLS + seed |
| `supabase/migrations/002_users_locale_code.sql` | users.locale_code column |
| `vercel.json` | Weekly cron schedule |
| `vitest.config.ts` | Test config — jsdom, globals, @ alias |
| `vitest.setup.ts` | jest-dom + localStorage mock |
| `.env.local.example` | Documents required env vars |

---

## 9. Reusable Architecture Pattern

**Multi-signal locale resolution with graceful fallback**

```
Signal priority (highest → lowest):
1. Supabase user record (login reconciliation)
2. localStorage (returning visitor)
3. navigator.language BCP 47 (first visit auto-detect)
4. Hardcoded fallback ('US')
```

This pattern works for any user preference that needs to:
- Work for anonymous users (no account required)
- Persist across sessions (localStorage)
- Sync with an account when one exists (Supabase)
- Make a reasonable first guess (browser signal)

The key insight: each signal overrides the previous in priority order, and the system never blocks on the highest-priority signal — it renders with the best available guess and upgrades silently when better data arrives.

---

## 10. Next Steps

### Completed
- Locale config (15 locales)
- BCP 47 auto-detection
- `formatPrice` with dual-currency display
- localStorage persistence
- Supabase client factories
- DB migrations (exchange_rates, users.locale_code)
- Weekly exchange rate cron (OXR → Supabase)
- LocaleContext with two-effect sync
- CSS pricing tokens
- PriceBlock, FlagPicker, NavFlagChip UI components
- Root layout wiring
- LocaleStep onboarding (Step 0)
- PR #1 open against main

### Remaining
- Apply Supabase migrations (`001_exchange_rates.sql`, `002_users_locale_code.sql`)
- Set env vars: `OPEN_EXCHANGE_RATES_APP_ID`, `CRON_SECRET` in Vercel + `.env.local`
- Merge PR #1
- Agent prompts: ContentAgent, BrandVoiceAgent, SalesIntelligenceAgent, OperatorOutreachAgent, COO OrchestratorAgent
