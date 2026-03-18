# Kite the Planet — Daily Recap
**Date:** 2026-03-18
**Commits today:** 0 (config, API investigation, file setup — no code changes committed)

## Accomplished

- **Instagram classifier pipeline code complete.** `classify.py` handles the full flow: parse following/followers JSON, keyword filter ~1,500 accounts, Business Discovery API calls with retry/backoff, Claude Haiku classification, checkpoint every 50 accounts, push to Notion. `smoke_test.py` validates token and 5 known kite accounts.
- **Meta app configured.** KTP Kite Research (ID: `1214812320844120`) has all 4 permissions in "Ready for testing": `instagram_basic`, `instagram_manage_insights`, `pages_show_list`, `pages_read_engagement`. IG User ID confirmed: `17841400751470586` (@ben_f_gio).
- **Privacy policy created** in Notion + `PRIVACY-POLICY.md` in repo. Meta App Review requires a public URL — this covers it.
- **META-CONFIG.md written** documenting all IDs, token regeneration steps, and the Business Discovery endpoint format.
- **Google Workspace email set up.** `ben@kitetheplanet.com` active via alias domain on benjamin-giordano.com Workspace. GoDaddy auto-authorized. MX records live. DKIM pending DNS propagation (retry in 24h).
- **EnsembleData identified as alternate data provider.** Recommended by a contact who exhausted Meta/IG API. Endpoint: `/instagram/user/info`, 1 unit/call, Wood plan $100/month = 1,500 calls/day, Python SDK available, no rate limits. This is the integration path for next session.

## Blockers / Open Items

- **Meta Tech Provider gate:** Business Discovery for third-party accounts requires Tech Provider status + App Review. "Ready for testing" only covers your own account. This is a hard blocker for the native IG API path. Paused — EnsembleData is the active route.
- **EnsembleData integration not yet implemented:** `classify.py` and `smoke_test.py` still use the Meta Business Discovery API. Next session replaces these with EnsembleData calls.
- **DKIM propagation:** Google Workspace DKIM token is configured in GoDaddy DNS but verification is pending. Retry at Google Admin → Apps → Gmail → Authenticate email in 24h.
- **EnsembleData account:** Need to sign up, get API key, add to `.env` as `ENSEMBLE_API_KEY`.

## Next Session

1. Sign up for EnsembleData (ensembledata.com) — get API key
2. Add `ENSEMBLE_API_KEY` to `.env` in `tools/ig-classifier/`
3. Rewrite `fetch_ig_profile()` in `classify.py` to use `EDClient.instagram.user_info_from_username(username)` instead of Meta Business Discovery
4. Update `smoke_test.py` to use EnsembleData for the 5 test accounts
5. Run smoke test — confirm bio + follower count returning
6. Run full pipeline overnight

## Commits
| Hash | Description |
|------|-------------|
| — | No commits this session — all work was API investigation and file setup |
