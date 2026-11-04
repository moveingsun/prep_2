# Knowledge record: Kurt's full-stack interview

Last updated: **2026-11-03**, the session that built `Ravi's Position/`. Add new facts here with a date when they come in.

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
- **Role:** full-stack engineer. Company and team: `[unknown, ask Kurt]`. **Ravi** referred Kurt and forwards his resume to the hiring manager.
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
- More background: `HANDOFF.md` §2 (written for the AI role).

## 3. BETM projects: who built what
Source: the company-laptop session's git-history reply, 2026-11-03. Commit counts are approximate. Some Jupiter commits were counted more than once across branches.

### Watt: the BETM AI platform (micro-frontend shell)
- **Stack:** React 19, TypeScript, Vite 8, Tailwind 4, React Router, MSAL, hooks + Context (**no state library**), Recharts, Vega-Lite, Vitest + Testing Library, Datadog RUM.
- **Kurt, frontend** (about 239 commits across 4 UI repos, Aug–Nov 2026):
  - **Data Validation UI** (rules, run history, monitors, chat pages)
  - **Ask Data UI** (he created it)
  - part of **Ask Knowledge UI** (uploads, PDF citation highlighting)
  - in the shell: the **Admin tab** and a shared **admin-kit** package used by 3 apps (one cost-reporting page)
  - **68 of the 102** UI test files
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
- **Another frontend engineer:** the shell itself (scaffold, sign-in, sidebar, the entitlement-driven app list, health panel, Users & access), the **chat-kit** and **ui-kit** packages, and most of Ask Knowledge.
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
  - A 10× Snowflake cost spike caused by a query/cache loop using 98% of execution time: ~100 → ~11 credits/day (S7).
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
  - He removed a cache-warming loop that used 98% of the API warehouse's run time over 7 days.
- **DST fix (Kurt's):**
  - Root cause: local-time conversion collapsed the two 1 AM hours on the fall-back day into one.
  - The fix keys every hourly row by date + hour-ending + EDT/EST, so a day can have 23, 24 or 25 hours, with one helper that converts the key to a fixed-offset time.
  - Applied across charts (EDT/EST tooltips), grids (a TZ column), Excel export and override saves.
  - About 10 UI and 27 backend commits, with a spec and unit tests.
- **Ask AI (Kurt's, all layers):**
  - **Job + poll** because APIM buffers and cuts long connections and the load balancer drops idle ones after about 4 min.
  - Polls every 2 s, then 5 s after 30 s, with a 10-min cap; stops after 3 failures in a row.
  - A job with no heartbeat for 60 s is reported lost. Rate limit: 10 questions/min.
  - The agent uses a read-only database role and fails closed.
  - Each turn's Cortex cost is logged. History moved to server threads.
  - In **Oct 2026** Ask AI moved to the shared chat package, which **streams in 40-second windows** and falls back to polling. The resume still says "job polling" (Kurt chose to keep it).
- **Upload validation:**
  - 10 MB limit; the steps are create → validate → store raw → process.
  - Weak spots: required fields aren't enforced, the error message is generic, and a failed upload doesn't roll back the deal row.
- **Tests:**
  - UI: Vitest + Testing Library, 25 files and ~150 cases; Kurt wrote 17 of the files.
  - API: pytest, ~140 files; Kurt made 261 of the 294 test commits. Baseline: 839 passed, 3 skipped.
  - **CI runs only lint.** There's no coverage target.
- **Domain terms:**
  - **Load deal:** a contract to serve a utility's customer load.
  - **Loads-through cutoff:** the last date with settled load in a PnL run.
  - **Whole-month basis:** the full calendar month, matching the workbook. Cash basis stops at the loads-through date.

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
- **AG Grid 36.2.0** (Sept 16, 2026; npm `latest`; there's also a `v32-lts` line). Modules have been required since v33, `AgGridProvider` since v35.1, and the Theming API (`themeQuartz`, no CSS import) since v33. `rowSelection` has been an object (`{ mode: 'multiRow' }`) since v32.2. Page 08 targets 36.2.0. Jupiter's own version is still unknown.

## 7. Workflow and tools
- **Remote Control** lets claude.ai/code or the phone app drive this Mac's session. It **cannot** attach from another CLI.
- **Company-laptop session:** Kurt runs a separate Claude session on his work laptop, with access to BETM's repos. He relays messages by phone. See `company-session.md` for the prompts and their status.
- **The guide is pushed** to `github.com/moveingsun/interview_prep` (private), branch `main`. Commit and push only when Kurt asks.
- **Rendering:** headless Chrome works here (`/Applications/Google Chrome.app`). `pdftoppm` is not installed, but the Read tool can still view the PDFs.

## 8. Open items
- [x] Message #2, Jupiter part: received 2026-11-03 and applied to pages 01, 05 and 06.
- [ ] Message #2, Watt + BOTH part (Kurt says "next" to the company session) → fill page 07.
- [ ] The company-session reply to the AG Grid message → fill `08-AG-Grid.md` (version, license, row model, features).
- [ ] The interview date, the company and the format.
- [ ] Kurt fixes "sole" and "20s" in his own 1-page base resume.
