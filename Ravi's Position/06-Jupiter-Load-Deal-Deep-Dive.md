# 06 · Jupiter (Load Deal) Deep Dive

[← Index](00-Index.md) · **Interview priority:** High · **Read time:** ~35 min, then draw it and say it out loud

> **Why this matters for this role:** You heard that the interview will ask about the design of Load Deal. A project deep dive is where interviewers check that you really built what your resume says. They ask "why" three times in a row. You need a clear 2-minute walkthrough, one diagram you can draw from memory, and honest answers about who built which part.

**Status:** filled from the company-session replies of Nov 3 (git history, design docs, code). A few `[fill in]`s remain.

## Primer

### What Jupiter is (one breath)
Jupiter is the business development group's one place to manage **load deals** over their whole life, from upload to PnL. Users are **traders, portfolio managers and analysts**.

Before Jupiter, they used Excel: a proforma workbook per deal, a variance-analysis workbook, and a daily "flash" email with a pasted Excel screenshot. Jupiter's PnL had to match the old workbook's PnL Summary sheet.

### Who built what (from git history)
- **You, backend:**
  - the PnL Summary service (one endpoint, 17 visuals)
  - the **recompute backend** (Redis lock, run IDs)
  - the **Ask AI** job API
  - much of the backend and deploy work (27 of 43 infra commits)
  - **261 of 294** API test commits
- **You, frontend:**
  - **Ask AI** (the whole page)
  - PnL Summary **API wiring** and data context
  - **Portfolio PnL** month history and YTD view
  - the **Admin usage tab**
  - the **DST fix** across the forecast screens
  - **17 of the 25** UI test files
- **Another frontend engineer:** most screens, the routing and fetch plumbing, the response envelope, most grids and charts, and the Recompute button. You approved 26 of their PRs ([M1](../AI%20Engineer/13-Behavioral-Story-Bank.md#m1)).
- **How to say it:** "I owned the PnL backend and the AI assistant end to end, and I built the PnL and Ask AI screens. Another engineer built most of the other screens, and I reviewed their PRs."

### Architecture (draw this)

```
 Browser: React 19 + TS
 (MSAL / Entra sign-in)
        │
 Azure APIM (gateway)
        │
 FastAPI on AKS ── Redis
  │        │        (cache, locks,
  │        │         Ask AI jobs)
 SQL      Snowflake ── Data Lake
 Server   (PnL,        (raw Excel)
 (deals)   analytics)
             ▲
 ADF pipeline or KEDA worker
 (Service Bus) runs the PnL
 stored procedure
```

- **SQL Server is the source of truth** for deals and config. Deal writes go there first, then to Snowflake. A Snowflake failure doesn't block the write.
- **The PnL is computed inside Snowflake** by a stored procedure, as a background job.
- **API layers:** middleware (JWT + entitlements) → router → service → repository.
- **Caching is server-side only** (a Redis read-through). The browser cache (Dexie/IndexedDB) was removed in Aug 2026.

### Main screens (about 13)
- **Portfolio:** KPI cards and a deal table.
- **New Deal:** upload a proforma Excel file.
- **View Deal:** one deal's monthly and hourly forecast.
- **Live Deal Summary:** a grid of active deals, with AG Grid charts.
- **ST Forecast:** the short-term load forecast and hedges.
- **Load Book:** positions and what-if.
- **PnL Summary:** one deal's 17-visual PnL dashboard.
- **Portfolio PnL:** PnL rolled up across deals.
- **Deal Pricing & Load:** hourly price and load, with overrides.
- **Ask AI:** the chat assistant.
- **Admin, Settings and Deal Structure:** usage, access and setup.

### Frontend stack and structure
- React 19, TypeScript, Vite, Tailwind, **React Router 7**, MSAL, axios, **AG Grid Enterprise** (client-side row model), Vitest + Testing Library.
- **Charts:**
  - **Vega-Lite** in Ask AI (yours, lazy-loaded)
  - **AG Charts** on Load Book
  - **AG Grid integrated charts** on Live Deal Summary
  - **ApexCharts** on ST Forecast
  - **Recharts** on Portfolio, the DART chart and Admin usage
- **Structure:** pages are thin wrappers. Each feature folder holds its own API client, hooks, mappers, charts and grids. App-wide providers (auth, entitlements, settings, theme) sit in one context folder. The shared header and menu come from the company ui-kit package.

### Domain words
- **Load deal:** a contract to serve a utility's customer load (retail, residential and small commercial). It's managed over its life for portfolio and PnL attribution.
- **Loads-through cutoff:** the last date with settled load in a PnL run. Actuals run from the month start up to that date.
- **Whole-month basis:** PnL over the full calendar month, matching the old workbook's PnL Summary sheet. The other option, **cash basis**, stops the actual window at the loads-through date.
- **Hour-ending (HE):** power data labels each hour by when it ends. HE1 is 00:00–01:00.

### The 2-minute walkthrough (use this order)
1. **Problem and users** (15 sec): BD traders, PMs and analysts ran deals and PnL in Excel workbooks and screenshot emails.
2. **Architecture** (30 sec): draw the diagram, top to bottom.
3. **One request** (30 sec): "A trader opens PnL Summary." UI → APIM → FastAPI checks entitlements → Redis by run ID → Snowflake on a miss → 17 visuals back in one response.
4. **One hard decision** (20 sec): the DST row key, or job + poll for Ask AI.
5. **Result** (10 sec): released Aug 2026, 32 of 32 deals matched the workbook, about 3 hours a day saved.
6. **What you'd change** (15 sec): see Q15.

## Questions & answers

### Q1. Walk me through Jupiter end to end.  `[P0]`
**Say this first (~30 sec):**
> "Jupiter is where our business development team manages load deals, from uploading the Excel proforma to the PnL. Before, they used workbooks and screenshot emails. The React app signs in with Entra and calls a FastAPI service on Kubernetes through Azure API Management. Deals live in SQL Server. PnL is computed in Snowflake by a background job, and Redis caches the results. I owned the PnL backend and the AI assistant, and I built those screens. It went live in August, matched all 32 deals in the traders' workbook, and saves about three hours a day."

**If they dig deeper:**
- Draw the diagram. Then follow one request (walkthrough step 3).
- Why SQL Server *and* Snowflake: SQL Server for transactional deal data and config, Snowflake for heavy PnL and analytics.
- Why the PnL runs in Snowflake: the data is already there, so the procedure runs next to the data instead of moving large hourly data sets out.

**Your angle:** [S8](../AI%20Engineer/13-Behavioral-Story-Bank.md#s8), [S1](../AI%20Engineer/13-Behavioral-Story-Bank.md#s1).
**Likely follow-ups:** "Why two databases?" · "What was the hardest part?" (Q14) · "How does the UI get its data?" (Q3)

---

### Q2. How is the frontend structured?  `[P0]`
**Say this first (~30 sec):**
> "React 19 with TypeScript on Vite, and React Router 7. Pages are thin wrappers. Each feature has its own folder with its API client, hooks, mappers, charts and grids, so a feature can change without touching others. App-wide state such as auth, entitlements, settings and theme lives in context providers. There's no Redux. Grids are AG Grid Enterprise. Another engineer set up most of this structure, and I built the PnL Summary data layer and the Ask AI feature inside it."

**If they dig deeper:**
- **Routing:** a `ProtectedRoute` waits for sign-in, checks entitlements, and sends you to your first allowed page or an Unauthorized page.
- **Why no Redux:** server data is fetched per feature. Shared client state is small (user, permissions, settings), so Context is enough.
- **Five chart libraries:** honest answer: "Vega-Lite is mine. Snowflake's agent returns Vega-Lite specs, so we render what we get, and I lazy-load it. The others grew over time with different authors. I'd consolidate them."

**Your angle:** [M1](../AI%20Engineer/13-Behavioral-Story-Bank.md#m1).
**Likely follow-ups:** "Would you add a state library?" ([03](03-React-Fundamentals.md)) · "How do you share types with the backend?" (Q3)

---

### Q3. How does the frontend get data and talk to the API?  `[P0]`
**Say this first (~30 sec):**
> "There's one axios instance. Its interceptor gets a token silently from MSAL, falls back to a popup, and adds the bearer token and gateway headers. The API base URL comes from a config file that the container writes at startup, so one image serves every environment. Every response uses one envelope with metadata, data and an error message, and each client unwraps it. Types are written by hand next to each client. Generating them from FastAPI's OpenAPI schema would be my next step."

**If they dig deeper:**
- **Caching:** the browser cache (Dexie/IndexedDB, 24-hour TTL) was removed in Aug 2026. Caching is now only on the server, in Redis, so there's one place to invalidate. Deal Structure keeps a small in-memory cache that de-duplicates in-flight requests.
- **Stale responses:** in PnL Summary you added a guard that ignores a late response when the user has already switched deals. This is the classic effect race ([03](03-React-Fundamentals.md)).
- **Runtime config:** one Docker image for dev, test and prod; no rebuild per environment.

**Your angle:** [S9](../AI%20Engineer/13-Behavioral-Story-Bank.md#s9).
**Likely follow-ups:** "Why not TanStack Query?" · "Why remove the browser cache?" `[fill in: the reason isn't in the commit; say what you believe]`

---

### Q4. Show me the API design.  `[P1]`
**Say this first (~30 sec):**
> "REST with kebab-case resources: deal, deal-structures, trade-capture, pnl-summary, pnl-overrides, load-book and ask-ai, with per-deal sub-routes. Lists page with page and page_size: the default is 100, the usual max is 3000. Filters are query parameters such as date ranges, sort_by and sort_order. There are 21 routers behind one base router, and exception handlers map errors into the same envelope."

**If they dig deeper:**
- **Honest gap:** Pydantic validation errors (422) still use FastAPI's default shape, not the envelope. "I'd fix that, so the UI has one error format." (RFC 9457 Problem Details is the standard option; [05](05-Frontend-System-Design.md).)
- **PnL Summary is one endpoint for 17 visuals**, shaped for the screen, so the page makes one call, not seventeen.
- Another engineer built most routers and the envelope. You wrote the PnL and Ask AI routes.

**Likely follow-ups:** "Offset or cursor pagination?" · "How do you version the API?"

---

### Q5. How does the PnL engine work, and how did you prove the numbers?  `[P0]`
**Say this first (~30 sec):**
> "The PnL is a stored procedure in Snowflake, run as a background job. `[fill in: one sentence on what it computes, e.g., load × price against forward curves]`. The proof was matching the traders' own workbook. At first it didn't match. I worked with the PM through more than 60 discrepancies, for example a missing forward curve and the loads-through cutoff rule, and wrote each rule down. Moving to a whole-month basis fixed the last group, and all 32 deals matched."

**If they dig deeper:**
- Whole-month vs cash basis: see the Primer. The endpoint supports both.
- Most mismatches were business rules, not code. Writing each rule down and getting sign-off unblocked the work.

**Your angle:** [S8](../AI%20Engineer/13-Behavioral-Story-Bank.md#s8).
**Likely follow-ups:** "How do you stop regressions?" (Q13) · "What if the workbook was wrong?"

---

### Q6. A PnL recompute takes time. How does the UI handle it?  `[P1]`
**Say this first (~30 sec):**
> "A recompute, or any override save, starts a background job: a Data Factory pipeline, or a queue message that a KEDA worker picks up. A Redis lock stops double clicks for 120 seconds. The UI doesn't poll. It shows a toast: queued, already running, or failed. Each run has its own ID and its own cache entry, so when the user reloads, the new run just appears and no old result is served by mistake."

**If they dig deeper:**
- Every response carries the run ID and computed time, and a runs endpoint lists past runs.
- **What you'd add:** show progress in the UI (poll the runs endpoint, or push an event), instead of asking the user to reload.
- You built the recompute backend and the toast. Another engineer built the Recompute button.

**Your angle:** [S14](../AI%20Engineer/13-Behavioral-Story-Bank.md#s14) (the KEDA job service).
**Likely follow-ups:** "Why a lock in Redis and not in the database?" · "What if the job fails silently?"

---

### Q7. Tell me about a performance problem you fixed on Jupiter.  `[P0]`
**Say this first (~30 sec):**
> "PnL Summary took about 5 seconds. I measured, and the cause wasn't the database. In FastAPI, 72 async handlers were calling blocking code, so one slow call froze the whole event loop on that pod, and every request waited. I moved the blocking work off the event loop, and the median dropped from 4.5–5.1 seconds to 3.6. Then I cached each result by its run ID. A warm lookup now takes about 80 to 95 milliseconds. Because a new run means a new key, the cache is never stale."

**If they dig deeper:**
- **The concept:** an `async def` route must never call a blocking driver directly. Either use a plain `def` route (FastAPI runs it in a thread pool), or wrap the call with `run_in_threadpool` / `asyncio.to_thread`. `[fill in: which one you used]`
- **The cache key = run identity.** Invalidation is the hard part of caching. Making the key change when the data changes removes the problem.
- **Third fix:** a cache-warming loop used 98% of the API warehouse's run time over 7 days. You removed it (the Snowflake cost story, [S7](../AI%20Engineer/13-Behavioral-Story-Bank.md#s7)). Now the cache fills on a miss.
- **This is guide-only, not on the resume.** You decided that on Nov 3. It's still a true story you can tell.

**Your angle:** [S7](../AI%20Engineer/13-Behavioral-Story-Bank.md#s7), [S9](../AI%20Engineer/13-Behavioral-Story-Bank.md#s9).
**Likely follow-ups:** "How did you find the blocking calls?" `[fill in]` · "Why not cache in the browser?" (Q3)

---

### Q8. The daylight-saving bug: what was it, and how did you fix it?  `[P0]`
**Say this first (~30 sec):**
> "Power data is hourly, labeled by date and hour-ending. The code turned each row into a New York local time. On the fall-back day there are two 1 AM hours, so both became the same instant and one hour disappeared. In spring there's an hour that doesn't exist. I made date, hour-ending and EDT or EST the key for every hourly row, so a day can have 23, 24 or 25 hours. I wrote one helper that turns that key into a fixed-offset time and used it everywhere."

**If they dig deeper:**
- **Charts:** one point per real hour, and tooltips say EDT or EST.
- **Grids:** a TZ column. **Excel exports** keep both 1 AM rows, sorted by TZ.
- **Overrides** send the time zone, and the server includes it in the save key.
- **Size:** about 10 UI commits and 27 backend commits, with a written spec and unit tests.
- **Lesson:** never convert to local time as an identity. Keep the business key, and convert only to display.

**Your angle:** your own fix, front to back. Also good for "a bug that crossed the stack."
**Likely follow-ups:** "How did you test it?" (unit tests on the helper with both DST days) · "Why not store UTC?"

---

### Q9. Ask AI: why job + poll, and how does the chat UI work?  `[P0]`
**Say this first (~30 sec):**
> "My design doc ruled out streaming at first. Our gateway buffers and cuts long connections, and the load balancer drops idle ones after about four minutes. So the UI posts a question and gets a job ID. Job state is in Redis, so any pod can answer a poll. The UI polls every 2 seconds, slows to 5 after 30 seconds, and stops at 10 minutes. Answers show as Markdown with a SQL block, an AG Grid table and a Vega-Lite chart. In October I moved it to our shared chat package, which streams in 40-second windows to stay under the gateway limits, and falls back to polling."

**If they dig deeper:**
- **Safety:**
  - polling stops after 3 failures in a row
  - a job with no heartbeat for 60 seconds is reported lost
  - a rate limit of 10 questions per minute
  - the agent runs under a **read-only database role** and fails closed if it can't switch roles
- **Cost:** every turn logs its Cortex usage, and an admin endpoint reports the cost in dollars.
- **History** moved from the browser's local storage to server threads.
- **Agents:** Snowflake Cortex with a semantic view, plus LangGraph with citation checks and a 20-question eval set ([S1](../AI%20Engineer/13-Behavioral-Story-Bank.md#s1)).
- You built all of it.

**Likely follow-ups:** "SSE or WebSocket?" ([05](05-Frontend-System-Design.md)) · "How would you build the polling hook?" ([04](04-React-Coding-Exercises.md))

---

### Q10. How are permissions handled in the UI and on the server?  `[P1]`
**Say this first (~30 sec):**
> "The server always enforces access. The middleware checks the JWT and the user's entitlements on every request. In the UI, a protected route checks entitlements before a page renders and sends you to your first allowed page. Entitlements fail closed and are cached per user in session storage. The shared entitlements service is mine: I removed N+1 lookups and made it Redis-first, so a check went from 3–6 seconds to about 10 milliseconds."

**Your angle:** [S9](../AI%20Engineer/13-Behavioral-Story-Bank.md#s9).
**Likely follow-ups:** "What happens when permissions change mid-session?" `[fill in]`

---

### Q11. How does Jupiter use AG Grid?  `[P0]`
**Say this first (~30 sec):**
> "Every grid uses the client-side row model with the Enterprise modules. Deal Pricing & Load shows a month of hourly rows, about 720 to 745, at 200 per page. The long-term forecast loads all API pages, 2000 rows at a time, into memory and shows 100 per page. We use tree data, row grouping, range selection, status-bar sums, and integrated charts on Live Deal Summary. Another engineer built most grids. My grid work was the DST fix: a TZ column and correct 23- and 25-hour days, also in Excel export."

**If they dig deeper:**
- **Why client-side is fine here:** a few thousand rows fit easily in memory, and AG Grid virtualizes the DOM. The server-side row model pays off at hundreds of thousands of rows, or when grouping must happen on the server.
- One wide grid turns **column virtualization off** on purpose `[fill in: why, e.g., auto-sizing or export]`.
- AG Grid version: `[fill in]`. All the details are in [08 · AG Grid](08-AG-Grid.md).

**Likely follow-ups:** "When would you switch to the server-side row model?" · "How do you keep a grid fast with live updates?" ([08](08-AG-Grid.md))

---

### Q12. How are deal uploads validated?  `[P1]`
**Say this first (~30 sec):**
> "The client accepts only one Excel file, blocks the draft status, and warns about mismatches after upload. Before an active save, Deal Structure calls a server validate endpoint and shows the issues in a modal. On the server, the upload runs in steps: create the deal, validate the file, store the raw file in the data lake, then process it. Validation checks the file type and size, workbook structure, headers, labels and data consistency. A guard stops a re-baseline upload from silently dropping metrics."

**If they dig deeper:**
- 10 MB limit (413 above it). A failed step returns 400.
- **Honest weak spots, and the fixes you'd make:**
  - required form fields aren't enforced → enforce them
  - the UI shows a generic "upload failed" → show the server's specific errors
  - a failed upload doesn't roll back the deal row → do it in one transaction, or clean up
- Mostly another engineer's code. You have a few commits on the validator.

**Likely follow-ups:** "How would you show validation errors per cell?"

---

### Q13. How is Jupiter tested?  `[P1]`
**Say this first (~30 sec):**
> "The UI uses Vitest with Testing Library: 25 test files and about 150 cases, and I wrote 17 of those files. They cover the DST helper, chart mappers, exports, the override API, Ask AI, page access rules and PnL warnings. The API uses pytest with about 140 test files, with fakes for Redis and the Snowflake agent, so nothing calls a live service. I made most of the API test commits. One honest gap: CI only runs lint today, so tests run locally. Adding them to CI is my next step."

**If they dig deeper:**
- A plan doc records a baseline of 839 passed, 3 skipped.
- No coverage target is configured.
- The workbook reconciliation (32/32 deals) was the business acceptance test ([S8](../AI%20Engineer/13-Behavioral-Story-Bank.md#s8)).

**Likely follow-ups:** "Why doesn't CI run the tests?" `[fill in: honest reason]`

---

### Q14. What was the hardest problem?  `[P0]`
**Say this first (~30 sec):** pick one, based on the interviewer:
- **Business-heavy interviewer:** the workbook reconciliation (Q5). The rules were unclear, and each mismatch could be my bug, an unwritten rule, or a workbook error.
- **Technical interviewer:** the DST bug (Q8). It touched the data key, charts, grids, Excel export and the save API.
- **Performance-minded interviewer:** the blocked event loop (Q7).

**Likely follow-ups:** "What would you do differently?" (Q15)

---

### Q15. What would you change if you built it again?  `[P0]`
**Say this first (~30 sec):**
> "Four things. Generate TypeScript types from the FastAPI OpenAPI schema, instead of writing them by hand. Run the tests in CI, not only lint. Put validation errors in the same envelope, and make failed uploads roll back cleanly. And show recompute progress in the UI instead of asking users to reload."

**If they dig deeper:** pick one, and give the cost and the benefit. For example, codegen costs one CI step and catches contract breaks at build time.

**Likely follow-ups:** "Why wasn't it done the first time?" Honest answer: speed to the August release, with a small team.

---

### Q16. How did you work with the frontend engineer?  `[P1]`
**Say this first (~30 sec):**
> "When my manager left, I led the frontend engineer and two other contractors day to day. Every evening I wrote down what to build next, why, and what 'done' means. In the morning we had a short check-in, and I reviewed their PRs: 26 on Jupiter. For PnL Summary we split the work: I did the API and data layer, and they added the month toggle, run picker, cash view and Recompute button."

**Your angle:** [M1](../AI%20Engineer/13-Behavioral-Story-Bank.md#m1).
**Likely follow-ups:** "Give an example of PR feedback you gave." `[fill in]`

## References
- [Story bank: S1 · Load Deal AI](../AI%20Engineer/13-Behavioral-Story-Bank.md#s1)
- [Story bank: S7 · Snowflake cost spike](../AI%20Engineer/13-Behavioral-Story-Bank.md#s7)
- [Story bank: S8 · PnL reconciliation](../AI%20Engineer/13-Behavioral-Story-Bank.md#s8)
- [Story bank: S9 · Entitlements service](../AI%20Engineer/13-Behavioral-Story-Bank.md#s9)
- [Story bank: M1 · Leading three contractors](../AI%20Engineer/13-Behavioral-Story-Bank.md#m1)
- [FastAPI: Concurrency and async / await](https://fastapi.tiangolo.com/async/): why blocking calls inside `async def` freeze the event loop (Q7).
- [05 · Full-Stack & Frontend System Design](05-Frontend-System-Design.md) and [08 · AG Grid](08-AG-Grid.md).
