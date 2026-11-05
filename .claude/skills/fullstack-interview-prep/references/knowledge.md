# Knowledge record: Kurt's full-stack interview

Last updated: **2026-11-04** (replies #2–#4, and Kurt's own answers). First written 2026-11-03, the session that built `Ravi's Position/`. Add new facts here with a date when they come in.

## Contents
1. The interview
2. Candidate summary
3. BETM projects: who built what
4. Confirmed claims (corrections)
5. Resume files
6. Verified tech versions
7. Workflow and tools
8. Open items

---

## 1. The interview
- **Company and role:** **Full Stack Engineer at Dodge & Cox** (San Francisco investment manager, founded 1930, 100% employee-owned, ~$465B AUM as of Mar 2026; verified on Wikipedia and the firm's fact sheet, 2026-11-04). **The role doesn't involve AI.**
- **Why Kurt is interviewing:** **Ravi**, his former manager at BETM, left BETM, joined Dodge & Cox, and invited Kurt to interview for his team. Ravi forwards the resume to the hiring manager. **Ravi is the manager who resigned in story M1** (Kurt confirmed 2026-11-04): tell M1 as continuity, never as "the team was left in trouble". Ravi is Kurt's advocate: he knows his work and wants him on the team. The other interviewers don't, so Kurt's claims should be exact and match what Ravi would say.
- **Format and interviewers:** unknown (Kurt, 2026-11-04).
- **Date:** assumed **about Tue Nov 10, 2026** (not confirmed). The 7-day plan runs Wed Nov 4 → Tue Nov 10.
- **What Kurt heard:** heavy on **React + TypeScript**, **AG Grid** (Ravi said so explicitly), and the **design of Load Deal (Jupiter) and Watt**.
- **Guide:** `Ravi's Position/`, with pages 00–08 (08 is AG Grid). There is an earlier AI-role guide in `AI Engineer/` (BCBSMA Sr. AI Engineer, Oct 2026). Its story bank `AI Engineer/13-Behavioral-Story-Bank.md` (S1–S14, M1) is shared by both guides.

## 2. Candidate summary
- About 8 years of experience. Backend, data and cloud first; applied AI since about mid-2025; now writing a lot of production React/TypeScript. **Framing:** "a backend-heavy full-stack engineer who writes production React + TypeScript."
- **BETM** (Boston Energy Trading & Marketing), Software Engineer, Jul 2025 – present.
- **Wayfair** 2020–2025, Data Platform: Kronos to Kubernetes, the Backstage observability platform with **TypeScript plugins**, and a Slack SLO app. Wayfair co-op in 2018: built the **beta Kronos UI** and API.
- **Cerner** 2018–2020: Java UI for a healthcare revenue-cycle app.
- MS Information Systems (Northeastern); BS IoT Engineering (BUPT).
- Non-native English speaker. Reads the guide on his phone in the GitHub app.
- **Kurt's own answers (2026-11-04):**
  - He coded the very first version of Kronos as a Wayfair co-op in 2018. Backstage: he remembers little. It's Spotify's open-source developer-portal framework (a CNCF project, still active), which Wayfair teams used as the UI frame so they didn't reinvent the wheel. Frontend vs backend plugins: unknown. **Don't invent details**; he says "a few years ago, I don't remember the internals".
  - **Accessibility:** none at Wayfair. At Cerner the UI had to support screen-reader readout, so in the Java UI he gave every button and box a description.
  - **Datadog RUM:** he analyzes RUM data with Claude to study user experience; most slowness was backend. He has **not used the React Profiler**.
  - He has **not used Next.js or Server Components**.
  - **What he'd change on Watt:** the agent setup. He'd host an open-source agent (**Hermes Agent** from Nous Research, confirmed 2026-11-04) and build features on top of it, because it's widely used and better than a custom setup.
  - **Why Jupiter removed the browser cache:** so every request shows backend data, the source of truth; the backend may change (recomputes, overrides).
  - Stories (spec change, C1 disagreement, PR catches) he'll think about later.
- More background: `HANDOFF.md` §2 (written for the AI role).

## 3. BETM projects: who built what
Source: the company-laptop session's git-history reply, 2026-11-03. Commit counts are approximate. Some Jupiter commits were counted more than once across branches.

### Watt: the BETM AI platform (micro-frontend shell)
- **Stack:** React 19, TypeScript, Vite 8, Tailwind 4, React Router, MSAL, hooks + Context (**no state library**), Recharts, Vega-Lite, Vitest + Testing Library, Datadog RUM.
- **Kurt, frontend** (about 239 commits across 4 UI repos, Aug–Nov 2026):
  - **Data Validation UI** (rules, run history, monitors, chat pages)
  - **Ask Data UI** (he created it)
  - part of **Ask Knowledge UI** (uploads, PDF citation highlighting)
  - in the shell: the **Admin tab** and a shared **admin-kit** package used by 3 apps (one cost-reporting page). Reply #2 detail: admin-kit is his (13 commits); in the shell itself his commit is a fix to the admin sections (expired links). The UI-element helpers were shared work.
  - **68 of the 102** UI test files (reply #1; reply #5 counts 65 of 103). **Kurt decided (2026-11-04):** say "about two-thirds" in interviews; leave the sent resume; use "about two-thirds" if the resume is re-rendered.
- **Kurt, backend:**
  - the entitlements-driven app registry
  - signed short-lived bundle links
  - UI-element permissions
  - API-gateway routing
  - the **chat API contract with SSE streaming over Redis** (the shared chat-kit runs on it)
  - cost endpoints
  - permission caching for entitlement changes
  - per-user warehouse tokens
  - Kurt also wrote the specs.
- **Another frontend engineer:** the shell itself (scaffold, sign-in, sidebar, the entitlement-driven app list, health panel, Users & access), **ui-kit**, **most of chat-kit** (10 commits to Kurt's 5, per reply #2), and most of Ask Knowledge.
- **Related:** the Data Validation service (Kurt built it solo; an LLM judge triages failures, and a human confirms before any write). Data Intelligence Cortex layer: 85.6s → 8.8s.

### Jupiter: the Load Deal app
- **Stack:** React 19, TypeScript, Vite 7, Tailwind 3, **AG Grid + AG Charts**, ApexCharts, Vega-Lite, React Context, Dexie (IndexedDB), MSAL, Vitest. Backend: FastAPI, Snowflake, ADF, Redis, Service Bus.
- **Kurt, frontend** (Jul–Oct 2026):
  - the **Ask AI chat page**: job polling; answers shown as SQL, tables and charts; history
  - **PnL Summary** moved from mock data to the live API
  - **Portfolio PnL history**
  - the **Admin usage tab**
  - **daylight-saving fixes** across forecast charts, grids and Excel exports
- **Kurt, backend:**
  - the Load Deal service, load validation and proforma ingestion
  - the **PnL engine and API** (released Aug 2026; saves 3 hrs/day)
  - the Ask AI job API (rate limits, cost per turn, a read-only agent database role)
  - PnL caching
  - Jupiter admin entitlements
- **Another frontend engineer:** most of the other pages (about 270 commits). Kurt approved 26 of their PRs.
- **Other stories:**
  - PnL reconciliation with the PM: 60+ discrepancies resolved, 32/32 deals matched (S8).
  - A 10× Snowflake cost spike caused by a cache-warming loop using 98% of execution time: ~100 → ~11 credits/day (S7). Details are in the PnL Summary bullet below.
  - Load Deal AI, built in 3 weeks: Cortex agent + semantic view, LangGraph with citation checks, a 20-question eval set (S1).

### Jupiter design details (company reply #2, Jupiter part, 2026-11-03)
- **Users:** the business development group: traders, portfolio managers and analysts. **Before:** a proforma workbook per deal, a variance-analysis workbook, and a daily flash email with an Excel screenshot.
- **Architecture:**
  - React (MSAL/Entra) → **Azure APIM** → FastAPI on **AKS**, with Redis for the cache, locks and Ask AI jobs
  - **SQL Server** is the source of truth for deals and config. Writes go there first, then to Snowflake, and a Snowflake failure doesn't block a write.
  - **Snowflake** holds PnL and analytics. The PnL is a **stored procedure** run as a background job by ADF or a KEDA worker (via Service Bus).
  - Raw Excel files go to the data lake.
  - API layers: middleware (JWT + entitlements) → router → service → repository.
- **Frontend:**
  - React Router 7 with a `ProtectedRoute` (entitlements fail closed and are cached in session storage)
  - one axios instance whose interceptor gets an MSAL token; runtime config is written by the container at startup
  - types are hand-written (no OpenAPI codegen)
  - feature folders, each with its client, hooks, mappers, charts and grids
  - Dexie (24-hour IndexedDB cache) was **removed in Aug 2026**; caching is server-side Redis only
- **Charts:** Vega-Lite in Ask AI (Kurt's, lazy-loaded); AG Charts on Load Book; AG Grid integrated charts on Live Deal Summary; ApexCharts on ST Forecast; Recharts on Portfolio, DART and Admin usage.
- **API:**
  - kebab-case REST, 21 routers
  - page/page_size pagination (default 100, max usually 3000)
  - one response envelope; Pydantic 422 errors are the exception, still in FastAPI's default shape
- **AG Grid:**
  - **client-side row model** with the **Enterprise** modules everywhere
  - tree data, row grouping, range selection, status-bar sums, integrated charts
  - row counts: ~720–745 hourly rows at 200 per page; long-term forecast 2000-row pages loaded into memory, shown 100 per page
  - one wide grid turns column virtualisation off on purpose
  - another engineer built most grids
- **Recompute (Kurt's):** ADF or KEDA job; a Redis lock blocks repeats for 120 s; the UI shows a toast (no polling); each run has its own ID and cache entry.
- **PnL Summary performance (Kurt's): guide only, NOT on the resume** (Kurt's decision, 2026-11-03):
  - 72 async handlers were blocking the event loop. Moving that work off the loop cut p50 from 4.5–5.1 s to 3.6 s.
  - He then cached results by run identity (warm lookup 81–95 ms, never stale).
  - A cache-warming loop used 98% of the API warehouse's run time (222.9 of 227.2 execution-hours over 7 days). That week 96 of 179 queue runs failed and 453 messages were dead-lettered. **Fix (not removal):** renew message locks, one message per deal, warm only the current and prior month.
  - The event-loop fix: he made the 72 handlers plain `def` functions (FastAPI runs them in a thread pool).
- **DST fix (Kurt's):**
  - Found when a desk user reported a spike in the ST Forecast Hedges line on the fall-back day; Kurt's read-only audit found no hour key knew DST.
  - Root cause on **both sides**: API `GROUP BY` on time + hour-ending summed the two 1 AM rows (2× spike), a parser built times from a drifting hour label, and load/validator/override keys lacked the time zone; the UI built chart points from New York wall-clock time. (Another engineer fixed a separate DST issue in March.)
  - The fix keys every hourly row by date + hour-ending + EDT/EST, so a day can have 23, 24 or 25 hours, with one helper that converts the key to a fixed-offset time.
  - Applied across charts (EDT/EST tooltips), grids (a TZ column), Excel export and override saves.
  - About 10 UI and 27 backend commits, with a spec and unit tests.
- **Ask AI (Kurt's, all layers):**
  - **Job + poll** because APIM buffers and cuts long connections and the load balancer drops idle ones after about 4 min.
  - Polls every 2 s, then 5 s after 30 s, with a 10-min cap; stops after 3 failures in a row.
  - A job with no heartbeat for 60 s is reported lost. Rate limit: 10 questions/min.
  - The agent uses a read-only database role and fails closed.
  - Each turn's Cortex cost is logged. History moved to server threads.
  - In **Oct 2026** Ask AI moved to the shared chat package (Kurt's Watt chat library), which streams in short windows and falls back to polling. The resume still says "job polling" (Kurt chose to keep it).
  - **Window sizes (reply #4):** Jupiter still uses the library default **40 s** (sized for a 45 s gateway). Watt's AI services use **170 s** since 2026-10-13 (180 s unbuffered stream policy). Whether Jupiter's route allows 180 s: unsure.
- **Upload validation:**
  - 10 MB limit; the steps are create → validate → store raw → process.
  - Weak spots: required fields aren't enforced, the error message is generic, and a failed upload doesn't roll back the deal row.
- **Tests:**
  - UI: Vitest + Testing Library, 25 files and ~150 cases; Kurt wrote 17 of the files.
  - API: pytest, ~140 files; Kurt made 261 of the 294 test commits. Baseline: 839 passed, 3 skipped.
  - **CI runs lint (ESLint) and a type check (`tsc -b --noEmit`), both blocking, plus a Docker build, but no tests** (reply #5). The pipeline is Kurt's; he made ESLint blocking. No coverage target.
- **Domain terms:**
  - **Load deal:** a contract to serve a utility's customer load.
  - **Loads-through cutoff:** the last date with settled load in a PnL run.
  - **Whole-month basis:** the full calendar month, matching the workbook. Cash basis stops at the loads-through date.

### Watt design details (company reply #2, Watt + BOTH part, 2026-11-04)
- **Apps (4):** Doc Intelligence, Data Intelligence (Ask Data), Data Validation, Memory. Users: a dev/stage script grants 6; the production count is unknown (never guess one).
- **Before Watt:** the app list was a build-time file; every signed-in user saw every app, and bundles were downloadable without sign-in. Goal (Kurt's registry design doc): a user sees exactly the apps their AI role grants.
- **Flow:** shell (MSAL) → Azure APIM → entitlements service (Redis/SQL) returns allowed apps + signed bundle links + UI elements → shell `import()`s `mount.js` from blob storage → `mount(container, host)` in a shadow root → app calls its own FastAPI backend (AKS) through APIM. A job hits a sync route every 5 min to point each app at its newest version.
- **Sign-in (shell: another engineer):** MSAL redirect flow; tokens in sessionStorage (localStorage was tried for cross-tab SSO and reverted; a new tab tries silent sign-in); silent refresh, redirect fallback; 22-hour session limit with a 10-min warning (clock in localStorage, "convenience, not security"). Child apps never touch MSAL: the host object has user, `getAuthToken(scopes)`, API base URL, gateway key, UI elements, theme, route, telemetry. **Kurt's:** Ask Data's own scope + on-behalf-of exchange for a per-user warehouse token.
- **Registry (Kurt: design doc + server side, 12 commits):** entry = slug, label, icon, bundle link, API base URL, description, version, privilege, link expiry, UI elements, optional admin entry. Static data in service config; the live version is a DB column only the sync route writes; access = one permission per app, granted to roles, cached in Redis. Bundle contract v1: exports `meta` + `mount`, optional `admin.js`. An unconfigured app returns **503**, never a half-built entry (Kurt's rule).
- **Signed links (Kurt's signing service):** Azure user-delegation SAS via managed identity (no storage key); read-only, one file, **5 min** default (1–60 configurable, never past the 12-hour delegation key); admin bundle signed only for admins. Bundles gzipped, immutable 1-year cache, semver folders, pipeline refuses overwrites. Shell checks the host against an allow list, preloads, `import()`s. **No Module Federation, no iframe**; no formal comparison recorded ("chosen for simplicity").
- **UI-element permissions (Kurt: server-side sorting):** `/app-slug` = app access; `/app-slug/x` → that app's list; others = shell elements (Admin tab, manage-admins) with privilege levels. The shell parses leniently (drops bad entries). Apps get a snapshot at mount, but **no app reads its list yet**.
- **Gateway (mostly Kurt):** APIM, one path per app under one shell product; bearer token + subscription key + product header; JWT + audience validated; CORS; response buffering off for streams. Every backend validates the token again (pods are reachable directly). Admin routes re-check entitlements (5-min per-user cache). Data routes don't check app access yet (see below).
- **Chat library (Kurt, 33 commits):** POST returns conversation/turn/message IDs; the turn runs as a background job writing to a Redis Streams log; client reads SSE. Events: start, status, delta, part, final, error, reconnect, done, each numbered within the turn; reconnect replays from the last ID. Window 170 s (180 s gateway limit), pings every 15 s, dev 30 s to force handovers. After 5 failed reconnects → poll every 2 s; refresh or a 2nd tab resumes. Stop = Redis flag; runner saves the partial answer as stopped, then final + done. Keys hashed, values AES-GCM encrypted when a secret is set; log TTL 1 h; no heartbeat for 30 s → lost. Ask Data, Doc Intelligence and Data Validation adopted it the next day; Jupiter a week later. Turns measured 136–336 s.
- **Packages:** private scope on Azure Artifacts; one pipeline (tests, type check, lint, build; publish only new versions). ui-kit 0.1.0 (another engineer), chat-kit 0.1.10 (both; types generated from the Python library's JSON Schemas), admin-kit 1.1.0 (Kurt, 13 commits; renders a versioned `CostReport` schema served by every backend), shell contract 1.3.0 (both).
- **Data Validation UI (mostly Kurt):** Create Rule and Diagnose chat modes, Run history, Monitors (pipelines, datasets), Capabilities, admin bundle; hash router. Forms: required names, positive freshness, filter rows (no duplicates, max 10); server Pydantic 422 (bad cron, unknown time zone). Run history: server paging 25/page, search, filters, sort; unknown filter → 422. Chat actions run only if they exactly match an open proposal, else 409. Deleting a dataset in use → 409 naming the suite. LLM cost per run to 4 decimals (judge call ≈ $0.0004). 22 UI test files (~124 cases); service ~130 test files, last run 2,295 passed. Another engineer moved its chat pages onto chat-kit in Oct.
- **Failure handling (mostly another engineer):** 401 → retry sign-in once, then "Sign-in required"; 403 "Access denied"; 503/network "Apps unavailable" + Try again; expired link → refetch once, then "session timed out". Health checks every 60 s while visible (8 s timeout). Permission changes apply on the next reload; nothing pushes to open tabs. **Kurt's:** the server-side 503 rule and the admin expired-link fix.
- **Hardest problems (Kurt's):** (1) the gateway cutting long AI turns → the resumable streaming design; (2) production lifecycle bugs: a repair step overwrote just-finished turns (now re-reads, only touches running turns); on **2026-10-21** every Jupiter Ask AI turn failed ("event log unavailable", 503) because the production geo-replicated Redis runs streams in strict ID mode and rejected the library's IDs. Same-day hotfix, then a library fix + a strict-ID fake in tests. Polled events also lacked IDs (duplicates); now every event is numbered.

### Watt follow-ups (company reply #4, 2026-11-04)
- **Gateway limit:** the 61.1 s cut was on the Data Validation chat route, dev/stage, 2026-08-28: a hard 60 s cap with data flowing (not idle); infra was asked to raise it. The spec says Azure Application Gateway has a fixed total timeout of 60 or 180 s per route. 2026-10-13: AI services moved to 170 s windows and the gateway got an unbuffered 180 s stream policy. Same setting raised or a different route: unsure.
- **chat-kit client:** `fetch` streaming, not EventSource (needs the Authorization header). Headers (token, gateway key, product) rebuilt on every request. Events are JSON cast to the schema-generated types; no zod/ajv, a few hand-written guards (rows, confirm, SQL).
- **Bundles:** each app bundles its own React. `mount` returns `{ unmount }`. Each app creates its own shadow root inside the element the shell gives it (main and admin bundles).
- **Data-route access:** data routes check the token, not app access yet. Kurt chose (2026-11-04) to keep this to one line everywhere: "the next hardening step". Don't add per-app details to the repo.
- **Strict-ID fix:** the library wrote IDs as `n-1` (full ID, rejected by strict mode); now writes `n` and Redis fills the sequence (region ID in strict mode, `0` in plain Redis). Reads/resume use only the counter. Tests use a strict-ID fake Redis.
- **Rollback:** the architecture doc says re-point the registry at the previous immutable version (no shell rebuild). Whether the 5-min sync re-picks the newest: unsure.
- **sessionStorage:** another engineer moved the token cache there on 2026-09-25 so sign-in ends when the tab/browser closes; deep links in a new tab try silent sign-in. No security reason is written down.
- **Hash router:** Kurt's 2026-08-08 commit, "dependency-free hash router (refresh-proof for a static SPA)".
- **Apps:** Doc Intelligence = the Ask Knowledge UI and service (slug renamed 2026-09-22). Memory = people see and edit what the AI apps remember about them; super admins see everyone's.

### AG Grid in Jupiter and AMP (company reply #3, 2026-11-04)
**Jupiter** (develop branch):
- **34.3.1 Enterprise** (community, enterprise, react pinned) + AG Charts Enterprise 12.3.1. Licence set once in the entry file (an env-var move was reverted). Entry registers `AllEnterpriseModule` + integrated charts; two lazy grids also register `AllCommunityModule` (redundant).
- **Legacy CSS themes** (alpine; quartz on a few) with `theme="legacy"`; dark mode swaps the wrapper class; some grids remount on theme change. No Theming API.
- **Client-side row model** everywhere. Deal Pricing & Load ~720–745 rows, 200/page; long-term forecast pulls 2,000-row pages, shows 100/page (total unknown); other paged grids 20/page.
- **Features:** Live Deal Summary (set filters, row grouping, side bar, cell selection, integrated charts, Excel export, column state in sessionStorage); ST Forecast (tree data, set filters, Excel export, state in localStorage); Load Book (tree data, editable scenario cells; hedge grid has status-bar sum, pinned bottom totals, floating filters); Price & Load (floating + date filters, pinned Date, sort Date→HE→TZ, overrides in a modal); Flash Table (quick filter, pinned month rows, column groups, 30+ deal columns). Not used: master/detail, pivot, undo/redo, grid state API, CSV export.
- **Updates:** rowData replaced from state/useMemo; no transactions; `getRowId` only on two admin grids (another engineer). **No live updates**; the current-hour highlight has no timer.
- **Kurt's renderers:** month group header (fold/unfold), deal label cell (month chevron / indented deal), ARR/MLC unsettled-day tooltip, hedge block-hours header tooltip. Others' renderers: badges, links, action buttons, row-drag delete, role switch. Editors: only the built-in select (Settings).
- **Formatters:** shared (another engineer): 2 decimals, accounting currency, ISO dates, red class for negatives. Kurt: the Ask AI table formatter.
- **Column defs:** newer grids typed `ColDef<T>` / `ColGroupDef<T>`, older files loose; helper factories (priority formatting, overrides, current-hour highlight); mostly `useMemo`; no `columnTypes`.
- **Column virtualisation off** in the Flash Table: another engineer's comment says auto-size only measures rendered columns, so only ~half of 30+ columns got sized. Kurt's rewrite kept it.
- **Kurt's grid fixes:** exact heights instead of `autoHeight` + re-fit on late data; ARR/MLC zero-height grids (legend moved to the panel header); Ask AI 130px dark-mode band (tall drop zone opt-in); current-hour `Date` per cell → cached 1 s; Flash Table height follows visible rows. `rowBuffer=10` is another engineer's, no reason given.
- **Tests:** Vitest; no test mounts a grid. Kurt's tests: TZ column placement/sort, fall-back-day highlight, 25-row exports, row mappers, the Flash Table model.
- **Kurt's grid code:** Portfolio PnL Flash Table rewrite (2026-10-22); DST across grids and exports (2026-10-20); PnL Summary grid sizing and data wiring (Jul–Aug); Ask AI result table + Admin usage panel (Sep); ARR/MLC labels and tooltips (Aug).
- **Excel:** 3 grids use `exportDataAsExcel` (another engineer); the rest use exceljs (another engineer). Kurt added the TZ sort and the Losses % fix, and rewrote the load forecast export for DST.

**AMP** (develop as of late Aug 2026; Kurt's last AMP commit 2026-08-21):
- **33.2.1 Community**, no Enterprise, no licence. Another engineer had added Enterprise-only grouping props and a set filter in 2025; Kurt removed them in Mar 2026 ("Enterprise-only, unregistered") and used a text filter.
- Most grids register only client-side row model, text filter, pagination; File Center registers `AllCommunityModule`. Legacy alpine everywhere; Kurt added `theme="legacy"` to nine grids; one grid still lacks it and uses deprecated selection props.
- 13 grids (12 Admin + File Center), client-side with pagination (15–100/page), hundreds of rows likely. Shared custom sort header; Admin filtering is a search bar outside the grid; File Center has text + custom floating filters, an external filter, and multi-row checkbox selection.
- All renderers by another engineer; no editors. Kurt's formatters join arrays into comma lists. File Center shows UTC dates but filters on local dates (possible mismatch, not verified).
- Column defs mostly untyped arrays in `useMemo`; only File Center uses `ColDef<T>`.
- **Kurt created no AMP grid.** His grid work = the v33 cleanup on **2026-03-04** (3 commits): removed unregistered Enterprise props, fixed v33 deprecations on six tables, replaced the set filter, added `theme="legacy"`, moved to the new click-selection option, fixed the File Center duplicate row ID.
- Exports: exceljs + file-saver + hand-built CSV (another engineer, Feb 2025). Kurt fixed a hidden character in a volume table's CSV dates and the price table's export values. No live grid updates. Tests: 3 Jest utility files, none for grids.

**Watt rollback (Q15, corrects reply #4):** the sync picks the highest semver in blob storage and writes it back; no pin/hold flag. Supported rollback = **delete the newer blob** (sync code + Kurt's design doc). The shell's ARCHITECTURE.md is out of date ("re-point the registry"). The bundle container has a time-based immutability policy that may block deletes, so the practical fix may be to publish a corrected higher version. Kurt built the service, the design doc and the sync job.

### TypeScript and React facts (company reply #5, Part A, 2026-11-04)
- **TS:** Watt 6.0.3 (strict: true in Ask Data, Data Validation, Memory, packages; shell and Doc Intelligence rely on the TS 6 default). Jupiter 5.8.3, strict on.
- **CI:** Watt app pipelines = lint + build (`tsc -b`); Data Validation also Vitest; bundle-publish = npm audit + tests (DV: audit + build); shell = Docker build; packages = test, typecheck, lint, build, publish. Jupiter: see above.
- **Props:** Watt ~70 interface to 3 type (plus inline); Jupiter ~38 type / 30 interface; no lint rule.
- **React:** Compiler on only in the Watt shell (another engineer). No newer React 19 APIs (no ref-as-prop, use(), useActionState, <Context> provider), no transitions; Jupiter has one forwardRef. Kurt used useSyncExternalStore in Data Validation.
- **Contexts:** Watt apps mostly none (host object instead; Doc Intelligence has two, another engineer's). Jupiter: auth user, entitlements (hasAccess), settings, theme, deal summary; Kurt's PnL context (data, meta, loading, error, notFound, refresh); Portfolio PnL context shared (Kurt added month history + YTD).
- **Kurt's hooks:** useCostReport (aborts older request, drops late answers), useAskAiJob (create/poll/cancel), useVisual<T>; also useLoad<T>, useConversations, useJupiterChatClient.
- **Fetching (Watt):** plain fetch; headers from host getAuthToken; AbortSignal timeouts (DV 300 s → 408; Doc Intelligence admin 60 s); in-memory caches only.
- **DV forms (Kurt's, except the check edit modal):** controlled useState; patch interfaces with optional fields, only touched fields sent; no create type (rules via chat). `MonitorKind = 'pipeline' | 'dataset'`, discriminated unions on kind/type; check type and severity are strings. **Gap:** 422 field lists fall back to status text (detail kept only when a string).
- **Types:** admin-kit generic only `withShares<T>`; Kurt's satisfies AppHost (test), .d.ts files, Record by conversation kind, intersection, Jupiter unions/guards/`Envelope<T>`; conditional types are another engineer's. Fixes: DV description `string | null` → `string` (2026-09-05) and the seeded null owner; Jupiter fallback month (2026-09-01). Jupiter has ~316 `any` (lint warns only).
- **Permission keys:** plain strings in Watt, AMP, Jupiter. Kurt's: shell admin-path helper; AMP Entra object ID + case-insensitive type code.
- **PDF viewer ref (Kurt, 2026-09-29):** host div + controller refs; citation reveal centers, waits ~400 ms, re-centers; pre-sized page holders.
- **Tests:** no MSW (vi.mock, vi.stubGlobal fetch, vi.fn). Test files (Kurt's): shell 35 (20), Doc Intelligence 39 (18), Ask Data 6 (6), DV 22 (20), Memory 1 (1) = **65 of 103 in Watt**; Jupiter 25 (17). Reply #1 said 68 of 102 (on the resume). Best test: DV conversation search (fake timers, 300 ms debounce → one request, no stale overwrite).

### Jupiter facts (company reply #5, Part B, 2026-11-04)
- **Ask AI (Kurt's):** classic answer = one result object with parallel arrays (text, SQL, tables, Vega-Lite); errors = code + message (cancelled, disabled, timeout). chat-kit version = parts tagged by kind (sql, table, chart, suggestions). State: context (conversations, activeId, agent, threadsLoading, loadState, serviceDisabled); hook (phase, jobId, progress, startedAt; refs for timer, abort controller, run ID). No error boundary (chart block has a fallback). Poll stops via clearTimeout + AbortController + run-ID counter, on done/error/404/3 failures/10-min cap/cancel (DELETE)/unmount. Table fields `c0, c1…` (dots break AG Grid field paths); measure = all numeric and one has a fraction → 2 decimals. No on-screen row limit (420 px scroll); PDF export caps at 500 rows.
- **PnL amounts:** numbers; `null` = not computed, never 0. Only Ask AI tables are strings.
- **Stored procedure:** recomputes PnL for one or all deals for one balance-of-month period; writes a new run (today's as-of date) in hourly and daily parts. The SQL is in a separate warehouse repo, so the author wasn't checked; the callers are Kurt's.
- **Blocking handlers found** from one production trace: active-deals request 4.17 s for ~160 ms work (140 ms auth SQL, 4.0 s gap, 17 ms cache hit) while a heavy PnL request ran on the pod. Conversion was AST-driven (plain `def` only if no `await`); tests enforce it.
- **Entitlements in the UI:** session storage, no TTL, no refresh on 403; new tab or logout clears. Kurt's fixes: never cache empty results; fixed the server cache key (changes took up to a day).
- **Gateway:** Jupiter's chat stream route has a **60 s** unbuffered timeout; the service closes streams at 40 s; turns can run to 180 s across reconnects.
- **Overrides modal:** another engineer, June 2026, no reason recorded. **Load Book scenarios** are saved only to browser localStorage by an effect (no API, no Save button).
- **Grouping/tree:** Live Deal Summary has no default grouping (user grouping restored from session storage). ST Forecast tree: comparison pair (6) → on/off-peak. Load Book: category (hedges, exchange, award totals, forward volume delta) → deal or scenario. Charts: another engineer (integrated Dec 2025, Load Book AG Charts Jan 2026), no reason recorded.
- **CI:** API = ruff lint + format, image build; pytest never in the pipeline (an old design record says otherwise and is out of date); the repo rule is to run tests locally. UI = tsc + ESLint (Kurt created it in July, before any tests; Vitest came in Sept and wasn't added). Dexie removed by another engineer 2026-08-06/07, no reason recorded (Kurt's reason: backend is the source of truth).
- **Telemetry:** Datadog RUM + browser logs (another engineer, Nov 2025): 100% sessions and session replay, privacy "allow" (unmasked). Kurt's fix: the container passes only app-prefixed env vars, so Datadog agent vars (including an API key) no longer reach the browser, and build logs no longer print the RUM token.

### AMP, jobs and Watt facts (company reply #5, Part C, 2026-11-04)
- **AMP UI:** no class components (only a Dexie DB class). Tailwind (custom colors, font, extra-wide breakpoint, ~3,000 classNames) + 12 global CSS files + ~106 inline styles. Dexie: one table (key, data, timestamp), 24 h TTL on read, cleared at sign-in/logout; now only reference dropdowns, because Kurt stopped caching revenue/pricing/volume on 2026-03-11. Dexie and Tailwind setup: another engineer.
- **AMP landing ~10 s → 5 s (Kurt, March 2026 release):** backend only; per-entity fetch on a 4-thread pool, so two ~5 s chains run in parallel. Measurement not recorded (likely his timing logs from a week earlier). The remaining 5 s = the slower entity fetch (Redis, or warehouse on a miss); notes mention a 5.6 s time-dimension rebuild and an external time-series call of 10 s (3–5 s after batching).
- **AMP tables:** no deal/position tables (deals are Jupiter's); asset price, volume, revenue, outage, outage management, line view, market monitor, admin grids, file list; all sorting in the browser.
- **AMP job service (Kurt, 83/85 commits):** KEDA ScaledJob; Redis list trigger polled every 5 s; 0–20 replicas, one job per pod, 1 h deadline; Python retries; always-on controller every 30 s (dependencies, retries, cascade cancel); job types Python/SQL/stored procedure/HTTP; seeded jobs = demos + a revenue calculation; code on a non-default branch; another engineer's Service Bus move unmerged. AMP's scheduled cache refreshes run on Databricks (Kurt's). **Ask Kurt whether the service is live in production** before claiming what runs on it.
- **Jupiter worker:** KEDA ScaledJob on Service Bus (created by another engineer; later changes Kurt's): per-deal cache refreshes (~32 messages), portfolio PnL refresh, optional recompute; polls every 10 s, ≤3 replicas, lock renewal up to 30 min; recompute ~1 min; cold portfolio build 5.6 s vs 0.3 s warm.
- **Watt onboarding:** Memory (newest app) service + UI started 2026-10-16 and was in the dev/stage registry that day (merged next day) → under a day; service work ran to 2026-11-02 (134 commits). Not in the production config. "Who: me" in the reply, so Kurt likely built Memory (confirm). Teams: no doc names them ("business users").
- **Strict-ID incident (2026-10-21):** found from the Redis error ("can't be a complete ID", uniqueness mode strict); production Redis has active geo-replication (strict by default), dev/stage don't. Jupiter hotfix 01:54 UTC, library fix 02:01, hotfix dropped 02:08.

### AMP: Asset Management Platform
- **Stack:** React 18, TypeScript, **Create React App**, **AG Grid**, ECharts, Highcharts, Chart.js, embedded Power BI, React Context, Dexie, MSAL, Datadog RUM.
- **Kurt, frontend** (Jan–Aug 2026): the asset dashboard's price and volume tabs, filters and widgets; outage-management forms; admin user and service-principal forms; entitlement-based access checks.
- **Kurt, backend:**
  - five services
  - asset analytics speedups (parallel fetches, Redis first)
  - the KEDA job-execution service
  - the shared entitlements service: 3–6s → ~10ms, fail-closed
  - outage management 7s → 1s
- **Others** wrote about 2/3 of AMP's UI commits. Kurt approved 60 of their PRs.

### Leadership (M1)
When his manager resigned, Kurt led 3 contract engineers day to day for about 2 months, across the AI project, the PnL engine and AMP. Total PRs he approved: 86 (Load Deal + AMP).

## 4. Confirmed claims (Kurt decided, 2026-11-03)
| Topic | Use this | Never |
|---|---|---|
| AMP ownership | "Owned AMP's five services and React UI for over a year, leading contract engineers' UI work" | "sole full-time engineer" |
| AMP landing page | **~10s → 5s** | 20s → 5s |
| PnL Summary latency | **guide only** (event-loop fix story, 06 Q7); not on the resume | putting 4.5–5.1s → 3.6s on the resume, or crediting Redis for it |

Kurt's own base resume (`Resume/Kurt_Wang_Resume.pdf`, 1 page, uploaded 2026-11-03) **still has the old "sole" and "20s" claims**. Remind him to fix them if he plans to send it.

## 5. Resume files
- **Sent to Ravi:** `Resume/Kurt_Wang_Resume_FullStack_1page.pdf`, built from `Resume/resume_fullstack_1page.html` with `scripts/render_resume.sh`.
- **2-page version:** `Resume/Kurt_Wang_Resume_FullStack.pdf`. The same text, editable, is in the Claude Doc https://claude.ai/artifact/7FQqeczbL7UWrDUbJkmvZ7 (tab "Full-stack version"; tab "Original (Oct 2026)" is the older 2-page base).
- `Resume/` is excluded from git (`.git/info/exclude`) and exists only on Kurt's Mac.

## 6. Verified tech versions (checked 2026-11-03 on npm and the official docs)
- **React 19.3.1** (19.3 released Sept 9, 2026). React Compiler 1.0 (Oct 2025). Create React App is deprecated (Feb 2025).
- **TypeScript 7.0.2** (the native Go port, released July 2026). 7.1 is in beta. TS 6.0 (Mar 2026) was the last JavaScript-based version and made `strict` the default.
- **Next.js 16.x.** MSW v3. React Router: npm shows 8.x, but react.dev still says v7, so the guide gives no version.
- **RFC 10017** (OAuth 2.0 for Browser-Based Apps, Aug 2026) exists and recommends a BFF.
- **AG Grid 36.2.0** (Sept 16, 2026; npm `latest`; there's also a `v32-lts` line). Modules have been required since v33, `AgGridProvider` since v35.1, and the Theming API (`themeQuartz`, no CSS import) since v33. `rowSelection` has been an object (`{ mode: 'multiRow' }`) since v32.2. 36.2.0 still accepts `theme: 'legacy'` and ships the alpine/quartz CSS. Page 08 targets 36.2.0.
- **Kurt's apps (checked on npm 2026-11-04):** Jupiter 34.3.1 (2025-10-29), AMP 33.2.1 (2025-03-24), AG Charts Enterprise 12.3.1.

## 7. Workflow and tools
- **Remote Control** lets claude.ai/code or the phone app drive this Mac's session. It **cannot** attach from another CLI.
- **Company-laptop session:** Kurt runs a separate Claude session on his work laptop, with access to BETM's repos. He relays messages by phone. See `company-session.md` for the prompts and their status.
- **The guide is pushed** to `github.com/moveingsun/interview_prep` (private), branch `main`. Commit and push only when Kurt asks.
- **Rendering:** headless Chrome works here (`/Applications/Google Chrome.app`). `pdftoppm` is not installed, but the Read tool can still view the PDFs.

## 8. Open items
- [x] Message #2, Jupiter part: received 2026-11-03 and applied to pages 01, 05 and 06.
- [x] Message #2, Watt + BOTH part: received 2026-11-04 and applied to pages 07, 06, 05, 04, 03, 02, 01 and story S7.
- [x] Message #4 (follow-ups on page 07): answered 2026-11-04 and applied to pages 07, 06, 05 and 02.
- [x] Message #5: all three parts answered 2026-11-04 (pages 01–08).
- [ ] Ask Kurt: is the AMP job service live in production, and what runs on it? Did he build the Memory app?
- [ ] Ask Kurt: did he write the PnL stored procedure itself (the SQL is in a separate warehouse repo)?
- [ ] Kurt-only gaps left: production user count, time to add an app, spec changes, PR feedback examples, why Price & Load uses a modal, what Live Deal Summary groups by, tree-data levels, who first noticed the DST bug.
- [x] Message #3 (AG Grid, Jupiter + AMP + Watt rollback): answered 2026-11-04 and applied to pages 08, 06 and 07.
- [x] The company and role: Dodge & Cox, Full Stack Engineer (2026-11-04).
- [ ] The exact date, the format and the interviewers.
- [ ] Kurt fixes "sole" and "20s" in his own 1-page base resume.
