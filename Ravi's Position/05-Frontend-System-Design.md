# 05 · Full-Stack & Frontend System Design

[← Index](00-Index.md) · **Interview priority:** High · **Read time:** ~50 min, then practice 3 scenarios out loud

> **Why this matters for this role:** A full-stack round almost always has a "how would you build X?" question, and they will also ask you to explain the design of your own projects. They listen for structure, trade-offs, and whether you know what happens in the browser, not only on the server. Your edge: you can follow a click all the way to Redis and Snowflake. Most frontend candidates stop at the API call. This page gives you one structure and 12 patterns. The project pages ([06 Load Deal](06-Jupiter-Load-Deal-Deep-Dive.md), [07 Watt](07-Watt-AI-Platform-Deep-Dive.md)) apply them to your real systems.

## Primer

### Be clear about who built what (say it once, early)

"On Watt, I built the backend, the streaming chat API, and two of the apps: Data Validation and Ask Data. Another frontend engineer built the shell and the shared chat and UI kits. On Jupiter, I built the PnL engine, the AI chat page and the live PnL views, and our frontend engineer built most of the other pages. So I'll walk through the full design, and I'll be clear about which parts I built myself."

This is a strength if you say it calmly. Never claim UI code you did not write. The full list of what you built is in [01](01-Pitch-and-Full-Stack-Framing.md).

### A design-answer framework: RADIO

RADIO is a common frontend design framework (from GreatFrontEnd). It is a checklist, not a strict order. For a full-stack round, add the backend path to **A** and the backend fixes to **O**.

| Min | Step | What to cover |
|---|---|---|
| 0–5 | **R**equirements | users, scale, must-haves, out of scope |
| 5–12 | **A**rchitecture | UI parts, API, services, data stores |
| 12–17 | **D**ata model | entities; server vs client vs URL state |
| 17–25 | **I**nterface | endpoints, events, key component props |
| 25–38 | **O**ptimizations | perf, errors, security, a11y, deep dive |
| 38–45 | Wrap-up | trade-offs, what's next, your questions |

Tips:
- Ask 3–5 clarifying questions, then **say your assumptions out loud** ("I'll assume 200 users and 100k rows").
- Draw boxes before details. Then ask, "Which part would you like me to go deeper on?"
- If time is short, name what you are skipping ("I'll skip i18n").
- End with how you would measure success and roll it out.

### The full-stack request path

Know what happens at each hop. This diagram is your default architecture.

```
Browser: React SPA
  │ 1. load HTML / JS / CSS
  ▼
CDN (static files; long cache for hashed files)
  │ 2. fetch /api/... with token or cookie
  ▼
API gateway (TLS, token check, routing, limits)
  │ 3. route by path to a service
  ▼
Services (FastAPI / Java)
  │ 4. check permissions (fail closed)
  ├──► Redis (cache, precomputed views)
  └──► DB / Snowflake (source of truth)
```

- **Browser:** rendering, client cache, URL state.
- **CDN:** caches static files only. Never cache user data here.
- **Gateway:** validates the token, routes, rate limits.
- **Service:** business rules and the real permission check.
- **Redis / DB:** fast reads vs the source of truth.

### Cross-cutting checklist

Go through this list in the **O** step. Interviewers notice when you cover it without being asked.

- **Auth:** who is the user? Token or cookie? The server checks every call.
- **Permissions:** the UI hides things; the server enforces. Fail closed.
- **Errors:** one error format; retry only safe calls; show a trace ID.
- **Loading states:** skeleton, empty, error, no access, stale data.
- **Caching:** CDN, browser query cache, Redis. Say how each one is invalidated.
- **Performance:** LCP / INP / CLS; bundle size; virtualization; no request waterfalls.
- **Accessibility (a11y):** keyboard, focus, labels, contrast, screen-reader updates.
- **Security:** XSS (sanitize, CSP), CSRF if you use cookies, no secrets in the bundle.
- **Observability:** errors with release version, real-user metrics, traceparent.
- **Testing:** unit, component, contract, end-to-end (E2E).
- **Deployment:** CDN, hashed assets, feature flags, fast rollback.

### Scenario → your closest project

| Scenario | Your closest example |
|---|---|
| Q1 Data grid | Load Deal / PnL UI ([06](06-Jupiter-Load-Deal-Deep-Dive.md)) |
| Q2 AI chat UI | Load Deal AI ([S1](../AI%20Engineer/13-Behavioral-Story-Bank.md#s1)) |
| Q3 App shell | Watt ([S3](../AI%20Engineer/13-Behavioral-Story-Bank.md#s3), [07](07-Watt-AI-Platform-Deep-Dive.md)) |
| Q4 Fast dashboard | AMP landing page ([S14](../AI%20Engineer/13-Behavioral-Story-Bank.md#s14)) |
| Q5 Real-time | Watt chat streaming ([07 Q11](07-Watt-AI-Platform-Deep-Dive.md)); no live price feed |
| Q6 Auth | Watt sign-in, entitlements ([S9](../AI%20Engineer/13-Behavioral-Story-Bank.md#s9)) |
| Q7 API design | Load Deal and Watt APIs |
| Q8 State | AMP React UI `[fill in]` |
| Q9 Testing | PnL reconciliation ([S8](../AI%20Engineer/13-Behavioral-Story-Bank.md#s8)) |
| Q10 Observability | Wayfair platform ([S12](../AI%20Engineer/13-Behavioral-Story-Bank.md#s12)) |
| Q11 Long jobs | KEDA job service ([S14](../AI%20Engineer/13-Behavioral-Story-Bank.md#s14)) |
| Q12 End to end | PnL engine ([S8](../AI%20Engineer/13-Behavioral-Story-Bank.md#s8)) |

## Questions & answers

### Q1. Design a data grid for 100k+ trades or deals: sort, filter, inline edit, export.  `[P0]`

**Clarify first:** How many rows today, and in 2 years? How many columns? Mostly reading, or heavy editing? Can two users edit the same deal? Do prices update live? Export what the user sees, or everything? Who may edit which fields?

**Say this first (~30 sec):**
"First I decide where the data lives. If the full set fits in memory, around 100k rows or less, I load it once and let the grid sort and filter in the browser, with row virtualization so only the visible rows are in the DOM. If it is bigger or growing, I use a server-side row model: the grid asks the API for blocks of rows with the current sort and filter, and the database does the work with indexes. Edits are optimistic, with a version on each row so the server can reject a stale write and the UI can show the conflict. Large exports run on the server as a job, not in the browser."

**If they dig deeper:**

- **Client vs server row model:**

| | Client-side | Server-side |
|---|---|---|
| Data size | fits in memory | any size |
| Sort / filter | instant, in browser | API call, DB index |
| Freshness | stale until reload | fresh per block |
| Complexity | low | API + paging logic |

- **Virtualization:** the DOM is the real limit, not the JS array. Render only visible rows plus a small buffer. AG Grid does this by default (10 extra rows above and below). For a custom list, use TanStack Virtual.
- **AG Grid facts (verified):** the Client-Side Row Model is the default and handles 100k+ rows. The Server-Side Row Model is Enterprise; it loads rows in blocks as you scroll and sends sort, filter, and grouping to the server. The Infinite Row Model is the free option for large flat lists. CSV export is free; Excel export is Enterprise.
- **Pagination vs infinite scroll:** page numbers are good when users need a stable position or a link to "page 3". Block loading ("infinite") is better for scanning. On the server, use **keyset (cursor) pagination**, not `OFFSET`. `OFFSET` gets slow on deep pages and rows shift when new deals arrive.
- **Block request shape:**

```
Grid (only visible rows in DOM)
  │ scroll / sort / filter
  ▼
POST /deals/query
  { startRow: 200, endRow: 300,
    sort: [...], filter: {...} }
  ▼
API ── safe SQL, indexed ──► DB
  ◄── { rows: [...], lastRow: 104233 }
```

- **Safe sort and filter:** only allow known column names (an allow-list). Never build SQL by joining user strings.
- **Inline edit:** validate on the client for quick feedback (types, ranges). The server validates again; it is the source of truth.
- **Optimistic edit:** show the new value with a "saving" mark. On failure, roll back the cell and show the error on that cell.
- **Conflicts:** send the row version you started from.

```
PATCH /deals/42
If-Match: "v7"
{ "volumeMwh": 120 }

200 → new row, ETag "v8"
412 → someone saved v8 first
```

  Conflict UI: "Changed by Ana at 10:42. Yours: 120. Theirs: 110. Keep mine / Take theirs." (A `version` field in the body with a 409 response also works. Pick one style and use it everywhere.)
- **Spreadsheet-style editing:** a "3 unsaved changes · Save all / Discard" bar. Save all in one server transaction. Write an audit row for every change (who, when, old, new). Trading data needs this.
- **Permissions:** the entitlements API says which columns this user can edit. The grid makes other cells read-only, but the API still rejects the edit.
- **Numbers:** compute PnL on the server. JavaScript numbers are 64-bit floats, so send money and prices as strings or fixed decimals and only format them in the browser.
- **Export:** small = CSV of the current view in the browser. Large = a server job that applies the same filters and permissions, writes the file to blob storage, and returns a signed, short-lived link (see [Q11](#q11-design-a-flow-for-a-long-running-job-started-from-the-ui-submit-status-cancel--p1)).
- **Grid speed:** stable row IDs (so updates do not redraw everything), memoized column definitions, debounced filter input (~300 ms), and keep row data out of global state.

**Your angle:** The Load Deal and PnL UIs show deals and PnL results that traders check against their own numbers. In [S8](../AI%20Engineer/13-Behavioral-Story-Bank.md#s8) all 32 deals had to match the traders' workbook, so precision and display formatting mattered. Jupiter and AMP both use AG Grid. A frontend engineer built most of Jupiter's grid pages, and you built the live PnL Summary and Portfolio PnL history on top of your API. You also fixed daylight-saving hours across grids, charts and Excel exports. Jupiter uses AG Grid Enterprise with the **client-side row model** everywhere: about 720–745 hourly rows per month view, or 2000-row API pages loaded into memory. It uses tree data, grouping, range selection, status-bar sums and integrated charts. Overrides are checked as numbers inline before saving ([06 Q11](06-Jupiter-Load-Deal-Deep-Dive.md)). Fast permission checks ([S9](../AI%20Engineer/13-Behavioral-Story-Bank.md#s9)) make per-request column checks cheap. Details in [06](06-Jupiter-Load-Deal-Deep-Dive.md).

**Likely follow-ups:**
- *"What about 1 million rows?"* → Server-side model only. Never send 1M rows to a browser.
- *"Two traders edit the same deal?"* → Version check, 412/409, conflict UI, audit log.
- *"Prices change every second?"* → Batch updates, see [Q5](#q5-design-real-time-price-and-position-updates-in-the-ui--p1).
- *"Why not just paginate?"* → Fine for lookup screens. For analysis, users want to scroll and compare.
- *"How would you test it?"* → Component tests with mocked API; one E2E for edit-and-save ([Q9](#q9-what-is-your-frontend-testing-strategy-and-cicd-pipeline--p1)).

### Q2. Design an AI chat assistant UI: streaming answers with SQL, tables, charts, and citations.  `[P0]`

**Clarify first:** Who uses it, and for what decisions? Short answers or long reports? What output types (text, SQL, tables, charts)? Must answers show sources? Should users see cost? How long do we keep history?

**Say this first (~30 sec):**
"I treat it as a streaming app. The client POSTs the question, and the server streams events back on the same response: text tokens, then structured events like SQL, table, chart, citation, cost, and done. The UI appends tokens to the current message and renders each structured event with its own component. The user can stop, retry, and give thumbs up or down linked to a trace ID. History is saved on the server, so it works on any device and we can use real conversations for evaluation."

**If they dig deeper:**

```
UI ─ POST /chat {threadId, text} ─► API
UI ◄─ token · token · token ─────── API
UI ◄─ sql · table · citation ────── API
UI ◄─ cost · done {messageId} ───── API
Stop = AbortController + server cancel
```

- **Transport:** use `fetch()` with POST and read `response.body` as a stream, in SSE format (`data: {...}` blocks). Why not `EventSource`? Its constructor only takes a URL and a `withCredentials` option. So it is GET-only, and you cannot send an `Authorization` header or a JSON body.
- **WebSocket** only if you need two-way talk during the answer (voice, live interrupts). It costs more: your own reconnect, heartbeats, and auth.
- **Gateways and proxies:** turn off response buffering on the streaming route, and send a small heartbeat every ~15 s so idle timeouts do not close the stream.
- **Reading the stream:**

```ts
const res = await fetch("/api/chat", {
  method: "POST",
  headers: {
    "Content-Type": "application/json",
    Authorization: `Bearer ${token}`,
  },
  body: JSON.stringify({ threadId, text }),
  signal: controller.signal, // for Stop
});
const reader = res.body!
  .pipeThrough(new TextDecoderStream())
  .getReader();
let buf = "";
for (;;) {
  const { value, done } = await reader.read();
  if (done) break;
  buf += value;
  // split buf on "\n\n", parse each "data:" line,
  // keep the last partial block in buf
}
```

- **Typed events** (a TypeScript discriminated union, see [02](02-TypeScript-Fundamentals.md)):

```ts
type ChatEvent =
  | { type: "token"; text: string }
  | { type: "status"; text: string }
  | { type: "sql"; sql: string }
  | { type: "table"; columns: string[];
      rows: unknown[][] }
  | { type: "chart"; spec: ChartSpec }
  | { type: "citation"; id: string; url: string }
  | { type: "cost"; tokens: number; usd: number }
  | { type: "done"; messageId: string;
      traceId: string }
  | { type: "error"; code: string; msg: string };
```

- **Rendering safely:** model output is untrusted (prompt injection can produce HTML or bad links). Render markdown with raw HTML turned off, or sanitize it. Never use `dangerouslySetInnerHTML` on model text.
- **Charts:** the server sends a JSON chart spec that it has validated. The browser never runs code from the model.
- **SQL:** a code block with a copy button. **Tables:** a small grid.
- **Rendering fast:** do not re-render on every token. Buffer tokens and flush once per animation frame. Keep finished markdown blocks memoized and only re-parse the last block.
- **States:** thinking (before the first token) → status ("Querying Snowflake…") → streaming → done / error / stopped.
- **Stop:** `controller.abort()` in the browser. The server must also notice the disconnect and cancel the LLM call, or you keep paying for tokens. Save the partial answer marked "stopped".
- **Retry:** resend the same user message; keep the old answer as version 1 or replace it.
- **Feedback:** thumbs up/down plus an optional comment, saved with `messageId` and `traceId`. Bad answers become new eval cases.
- **Cost:** the server computes tokens and cost per turn; the UI only displays it (for example, for power users or admins).
- **History:** threads stored on the server; a sidebar list loaded page by page; the user message is added optimistically.
- **Auto-scroll:** follow new text, but stop if the user scrolls up to read.
- **Accessibility:** an `aria-live="polite"` region that announces the answer when it is done, not every token.

**Your angle:** [S1](../AI%20Engineer/13-Behavioral-Story-Bank.md#s1) is this exact product: the Load Deal AI chat UI renders the SQL, tables, and charts so users can check results, with citation checks, per-turn cost tracking, and a 20-question eval set. You built the Ask AI chat page yourself. It submits a job and polls for the answer, because the gateway buffers and cuts long connections and the load balancer drops idle ones after about four minutes. In October it moved to the chat library you built for Watt: SSE over a Redis event log, in short windows under the gateway limit, resuming from the last event ID, with polling as the fallback ([06 Q9](06-Jupiter-Load-Deal-Deep-Dive.md), [07 Q11](07-Watt-AI-Platform-Deep-Dive.md)). So you can compare polling and streaming from real experience. The event types: start, status, delta, part, final, error, reconnect, done. Stop sets a flag in Redis, and the runner saves the partial answer. "Showing the SQL was a trust decision: traders trust numbers they can check."

**Likely follow-ups:**
- *"SSE or WebSocket?"* → SSE format over fetch: one-way, plain HTTP, easy through gateways.
- *"How do you stop paying after Stop?"* → Server watches for disconnect and cancels the model call.
- *"How do you stop XSS from model output?"* → No raw HTML, sanitize, CSP, validated chart specs.
- *"How do you test a streaming UI?"* → Mock the stream (MSW or a fake `ReadableStream`) and assert each state.
- *"How do you show the answer is grounded?"* → Citations linked to sources, shown next to the claim.

### Q3. Design an app shell ("front door") for many internal apps: one sign-in, permission-driven navigation and UI.  `[P0]`

**Clarify first:** How many apps, and how many teams build them? Do apps need to release on their own schedule? Same tech stack? Do apps share data, or only sign-in and navigation? Are some apps more sensitive than others?

**Say this first (~30 sec):**
"The shell owns four things: sign-in, navigation, a shared layout, and loading each app. On start, the shell signs the user in and calls an entitlements API that returns the apps and UI features this user may see. The menu is built from that list, and each app loads only when opened. How we load apps depends on team independence: a monorepo with lazy routes for one team, Module Federation for several teams that deploy separately, and iframes only for legacy or untrusted apps. Hiding a button is only for user experience. Every API checks permissions again on the server."

**If they dig deeper:**

```
          ┌──────────── Shell ────────────┐
 sign-in  │ MSAL · menu · layout · errors │
          │ GET /me/entitlements          │
          └─────┬──────────┬──────────┬───┘
                ▼          ▼          ▼
              App A      App B      App C
              (lazy)     (lazy)     (lazy)
                │          │          │
                └────► API gateway ◄──┘
                   (token + permission
                    checked again)
```

- **How to load the apps:**

| Option | Good for | Cost |
|---|---|---|
| Monorepo, lazy routes | 1 team, shared types | all apps deploy together |
| Module Federation | many teams, own deploys | shared-version issues |
| npm packages | shared UI kit | shell rebuild per update |
| iframes | legacy, strong isolation | UX seams, postMessage |
| Separate SPAs, links | simplest | full reload between apps |

- **Module Federation (verified):** webpack 5 added it; Module Federation 2.0 adds a runtime, a manifest, type hints, and devtools, and supports webpack and Rspack. Main risk: two apps loading different React versions. Share React as a singleton.
- **Entitlements API:**

```json
{
  "apps": [
    { "id": "load-deal", "title": "Load Deal",
      "route": "/load-deal" }
  ],
  "features": ["deals.edit", "pnl.export"]
}
```

- Cache it for the session in the query cache. Refetch on window focus or every few minutes, so removed access disappears soon.
- **Feature checks in React:**

```tsx
function Can({ feature, children }: CanProps) {
  const { features } = useEntitlements();
  return features.has(feature) ? children : null;
}

<Can feature="deals.edit">
  <Button onClick={save}>Save</Button>
</Can>
```

- Also a route guard: no access → a clear "You don't have access. Ask X." page, not a blank screen.
- **Never trust the UI:** anyone can call the API with curl or edit JavaScript in DevTools. The gateway validates the token (issuer, audience, expiry). Each service checks the permission for that action and **fails closed** on any error.
- **Protecting the code itself:** if app bundles should not be public, the shell asks the backend for a **signed, short-lived URL** to the app's bundle. Users without access never download it, and a leaked link expires.
- **Shell–app contract:** each app exports one entry, such as `mount(el, { getToken, user, features, navigate })`, or a React component. Version this contract like an API.
- **Shared pieces:** one MSAL instance in the shell (apps get a `getToken()` function, not their own login), a shared design-system package, shared telemetry, and **one error boundary per app** so one broken app does not break the shell.
- **State between apps:** keep it small. Use the URL and simple events, not a shared global store. Coupled apps lose the benefit of splitting them.

**Your angle:** This is Watt, [S3](../AI%20Engineer/13-Behavioral-Story-Bank.md#s3). You designed the entitlements-driven app registry, the signed short-lived bundle links, UI-element-level permissions, and API-gateway routing, and you wrote the specs. A frontend engineer built the shell. You built the Admin tab and the shared admin-kit package, and two apps that plug into the shell: Data Validation and Ask Data. [S9](../AI%20Engineer/13-Behavioral-Story-Bank.md#s9): you took entitlement checks from 3–6 s to ~10 ms with Redis-first lookups and made them fail closed, which is why checking on every request is affordable. Watt loads each app with a plain dynamic `import()` of a signed link that lasts 5 minutes. There's no Module Federation and no iframe, and each app renders in its own shadow root. The link means only users with access can download an app's code. 4 apps are on it, and a new app needs no shell change. `[fill in: time to add a new app]`. Details in [07](07-Watt-AI-Platform-Deep-Dive.md).

**Likely follow-ups:**
- *"Access is removed while the user is logged in?"* → Server rejects at once; UI refetches entitlements on focus or on the first 403.
- *"Why not iframes everywhere?"* → Double loading, harder auth sharing, layout seams. Good only for isolation.
- *"How do you keep the design consistent?"* → Shared design-system package and layout from the shell.
- *"An app's bundle fails to load?"* → Error boundary with retry; the rest of the shell still works; alert on load failures.
- *"How do you onboard a new app?"* → Register it in the app registry with its entitlements; no shell code change.

### Q4. A dashboard or landing page takes 20 seconds to load. How do you make it fast?  `[P0]`

**Clarify first:** Is it slow on first visit, every visit, or for some users only? Which part is slow: the first paint or the data? How fresh must the data be (seconds, minutes, daily)?

**Say this first (~30 sec):**
"Measure first, then fix the biggest piece. I split the time into backend, network, and browser using the network panel, real-user monitoring, and backend traces. Backend fixes usually win the most: precompute expensive numbers, cache them in Redis, run independent queries in parallel, and remove N+1 calls. On the frontend, I start all independent requests at once instead of one after another, show the layout right away with skeletons, lazy-load heavy widgets, and split the code by route. I track LCP, INP, and CLS at the 75th percentile to prove it got better."

**If they dig deeper:**

```
Waterfall (slow):
user ─► perms ─► deals ─► pnl ─► chart

Parallel (fast):
user ─┬─► deals ─┐
      ├─► pnl ───┼─► render each as it lands
      └─► chart ─┘
```

- **Backend:**
  - Precompute: a scheduled or event-driven job writes summary rows or a Redis key.
  - Cache-aside with a TTL, plus explicit invalidation when new data loads.
  - Run independent queries in parallel (`asyncio.gather`, `CompletableFuture`).
  - Fewer warehouse reads. Combine queries; read from the summary table.
  - Fix permission lookups in the hot path (N+1 → one cached call).
- **One "page" endpoint vs many small calls:** one endpoint is one round trip, but the page waits for the slowest part. Many calls let fast widgets show first. Often the best answer is a few calls, grouped by speed.
- **Frontend:**
  - Start fetches at the route level, not inside child components that mount only after the parent's data arrives.
  - Stale-while-revalidate cache (TanStack Query): returning users see the last data at once, then fresh data.
  - Skeletons with fixed sizes, so nothing jumps (good CLS).
  - Code splitting with `React.lazy` + `Suspense` per route and per heavy widget (charts).
  - Hashed bundles with long CDN cache; compression.
  - Prefetch on hover for the next likely page.
- **Core Web Vitals (verified, measured at p75):**

| Metric | Measures | Good |
|---|---|---|
| LCP | loading | ≤ 2.5 s |
| INP | response to input | ≤ 200 ms |
| CLS | layout jumps | ≤ 0.1 |

- INP replaced FID as a Core Web Vital in March 2024. Do not say FID.
- **For internal dashboards,** LCP may fire on the skeleton. Add a custom metric, "time until data is visible", with `performance.mark()`.
- **INP problems:** long tasks (> 50 ms) block clicks. Fix with memoization, virtualization, moving heavy math to the server or a Web Worker, and splitting work into smaller tasks.
- **Keep it fast:** a bundle-size budget in CI and a RUM alert when p75 gets worse.
- **SSR?** Server rendering helps first paint, but for a logged-in dashboard the data is still the slow part. Fix the data path first.

**Your angle:** [S14](../AI%20Engineer/13-Behavioral-Story-Bank.md#s14): you took the AMP landing page from **about 10 s to 5 s** with Redis precompute, parallel calls, and entitlement fixes, and cut Snowflake reads from 13 to 3. [S9](../AI%20Engineer/13-Behavioral-Story-Bank.md#s9): entitlements 3–6 s → ~10 ms, because permissions were on the path of every page. [S4](../AI%20Engineer/13-Behavioral-Story-Bank.md#s4): cost queries 85.6 s → 8.8 s. Be honest: "Most of my wins were backend." `[fill in: how you measured before and after, any frontend changes (skeletons, parallel fetches, code splitting), and what the remaining 5 s is]`

**Likely follow-ups:**
- *"What is in the remaining 5 seconds?"* → Have a real breakdown ready. `[fill in]`
- *"How do you keep the cache fresh?"* → TTL plus invalidate on the data-load event; show "as of 10:05".
- *"How do you stop it getting slow again?"* → Budgets in CI, RUM alerts, a perf check in code review.
- *"Would SSR or Next.js help?"* → Some, for first paint. Not for slow data.

### Q5. Design real-time price and position updates in the UI.  `[P1]`

**Clarify first:** How often does data change (per second? per minute?) and how fresh must the screen be? How many users and symbols? Does the client only listen, or also send a lot?

**Say this first (~30 sec):**
"I pick the simplest transport that works. If updates every 10–30 seconds are fine, polling with ETags is simplest and passes every proxy. If the server pushes and the client only listens, SSE is simple and reconnects by itself. If the client also sends a lot, like subscribing to many symbols, I use WebSocket. Then the important part is the UI: prices can tick 100 times a second, but people cannot read that fast. I keep only the latest value per symbol, apply updates in batches a few times per second, update only changed cells, and show a 'stale' badge when the connection drops."

**If they dig deeper:**

| Option | Best when | Watch out |
|---|---|---|
| Polling | slow data, simple | wasted calls; use ETag / 304 |
| SSE | server → client only | GET only; 6-conn limit on HTTP/1.1 |
| WebSocket | two-way, high rate | own reconnect, auth, heartbeat |

- **SSE facts (verified, MDN):** the browser reconnects by itself; the server can set the wait with `retry:`. Each event can carry an `id:`, which the browser sends back on reconnect as `Last-Event-ID`, so the server can resume. Over HTTP/1.1 there is a limit of 6 connections per browser per domain, shared across tabs. HTTP/2 removes this problem.
- **Batch the updates:**

```ts
const latest = new Map<string, Tick>();
ws.onmessage = (e) => {
  const t: Tick = JSON.parse(e.data);
  latest.set(t.symbol, t); // keep newest only
};
setInterval(() => {
  if (latest.size === 0) return;
  const update = [...latest.values()];
  latest.clear();
  gridApi.applyTransactionAsync({ update });
}, 250);
```

- AG Grid's `applyTransactionAsync` also batches by itself (default every 50 ms).
- **Reconnect:** exponential backoff with jitter. After reconnect, fetch a **snapshot**, then apply deltas with **sequence numbers**. If a number is missing, fetch a new snapshot.
- **Subscribe only to what is visible** (the rows on screen), and unsubscribe on unmount.
- **Auth:** the browser `WebSocket` API cannot set custom headers. Use a cookie, or get a short-lived one-time ticket from an authenticated REST call. Check permissions for each subscription on the server.
- **Server fan-out:** services publish to Redis pub/sub or a managed service (for example, Azure Web PubSub or SignalR). Gateways push to connected clients.
- **Honest UI:** show "last updated 10:05:32". Grey out or badge prices when the connection is down. Never show a stale price as live.
- **Hidden tab:** pause or slow updates using the Page Visibility API.
- **Cell flash** on change is nice, but respect `prefers-reduced-motion`.

**Your angle:** Be honest. `[fill in: does any of your UIs have live updates? AMP has a market-data service; does the UI poll it?]` If not: "Our PnL runs in batches, so I haven't built a live price feed. Here is how I would do it." Then use your strengths: Redis (pub/sub and caching, [S9](../AI%20Engineer/13-Behavioral-Story-Bank.md#s9)), and event fan-out to many users from the Wayfair Slack alert app with 3,000+ users ([S12](../AI%20Engineer/13-Behavioral-Story-Bank.md#s12)).

**Likely follow-ups:**
- *"A laptop sleeps and wakes up?"* → Detect it (`online` / `visibilitychange` events), reconnect, snapshot, then deltas.
- *"1,000 users × 500 symbols?"* → Server-side fan-out, per-user subscriptions, conflation (latest value only).
- *"How do you test reconnection?"* → Kill the socket in a test; assert the stale badge and the resync.

### Q6. How do authentication and authorization work in a SPA with Entra ID (OIDC)?  `[P0]`

**Clarify first:** Internal staff only (one tenant)? How sensitive is the data? Can we run a small server component, or is it static hosting only?

**Say this first (~30 sec):**
"Use the authorization code flow with PKCE. With Entra ID that means MSAL: the SPA redirects to Entra, gets a code, and MSAL exchanges it for an ID token and an access token for our API. The SPA sends the access token as a Bearer header, and every API checks the signature, issuer, audience, expiry, and then permissions. For sensitive business apps I prefer a Backend-for-Frontend: the server does the OAuth flow and keeps the tokens, and the browser only gets an HttpOnly, Secure, SameSite cookie. The new IETF best practice for browser apps, RFC 10017, recommends the BFF most strongly for business apps."

**If they dig deeper:**

```
SPA ─ redirect + PKCE challenge ─► Entra ID
SPA ◄──────── code ──────────────── Entra ID
SPA ─ code + PKCE verifier ──────► Entra ID
SPA ◄─ ID token + access token ─── Entra ID
SPA ─ Bearer access token ───────► API
        API: check iss, aud, exp, scope,
        then the user's permissions
```

- **PKCE:** the app makes a random secret (verifier) and sends only its hash (challenge). A stolen code is useless without the verifier. Entra requires PKCE for SPAs, and the redirect URI must have type `spa`. The old implicit flow is not recommended.
- **ID token vs access token:** the ID token tells the SPA who the user is. The access token is for the API (its audience is the API). Never send the ID token to an API as proof of access.
- **Token storage (verified):** MSAL.js caches tokens in `sessionStorage` by default. `localStorage` shares sign-in across tabs; `memoryStorage` is the most private. Any XSS can read browser storage, so the real defense is preventing XSS (CSP, no raw HTML, sanitizing), or using a BFF.
- **Refresh (verified):** call `acquireTokenSilent()` before each API call. MSAL uses the cached token or the refresh token. For `spa` redirect URIs, Entra refresh tokens expire after **24 hours**. Then the app must run the code flow again, usually with no prompt if the Entra session is alive. Browsers that block third-party cookies (like Safari) break hidden-iframe renewal, so use a top-level redirect or a popup.
- **On a 401:** get a token silently once and retry. If that fails, send the user to sign in. Share one refresh promise, so ten parallel calls do not start ten refreshes.
- **BFF details:** session in a cookie (`HttpOnly; Secure; SameSite`); session store in Redis; the BFF adds the access token when it proxies to APIs. Because cookies are sent automatically, add CSRF protection (SameSite plus a custom header or anti-CSRF token). Cost: one more server to run.
- **RFC 10017 (Aug 2026) patterns, most to least secure:** BFF → token-mediating backend (the browser holds the access token, not the refresh token) → browser-only OAuth client.
- **Authorization:** use Entra app roles for coarse access. Put fine-grained permissions in your own entitlements service, cached in Redis, checked on every call. Large group lists do not fit well in tokens.
- **Logout:** clear the MSAL cache and end the Entra session (`logoutRedirect`), or clear the BFF session.

**Your angle:** Watt gives one sign-in for several AI apps ([S3](../AI%20Engineer/13-Behavioral-Story-Bank.md#s3)), and your shared entitlements service is fast and fails closed ([S9](../AI%20Engineer/13-Behavioral-Story-Bank.md#s9)). "Authentication says who you are. Authorization is my entitlements service, and it is checked on the server every time." Watt uses MSAL in the browser (redirect flow, tokens in session storage), not a BFF. The token is checked **twice**: at the gateway (Azure APIM), and again in every backend, because the pods can be reached directly ([07 Q6](07-Watt-AI-Platform-Deep-Dive.md)).

**Likely follow-ups:**
- *"Where do you store the token, and why?"* → sessionStorage via MSAL, or no token in the browser at all with a BFF. Explain the XSS trade-off.
- *"The token expires during a long form?"* → Silent refresh before submit; save a draft locally so nothing is lost.
- *"How do you prevent CSRF?"* → Only an issue with cookies: SameSite plus a custom header the attacker's page cannot set.
- *"How does the API know permissions?"* → Token gives identity and roles; the entitlements service gives fine-grained rights.

### Q7. How do you design the API for a UI? REST, GraphQL, or tRPC, plus pagination, errors, and versioning.  `[P0]`

**Clarify first:** What is the backend language? How many clients (one web app, or also mobile and other teams)? How fast does the schema change?

**Say this first (~30 sec):**
"With a Python FastAPI backend, I default to REST with OpenAPI. I generate the TypeScript client and types from the OpenAPI schema in CI, so a contract change breaks the frontend build, not production. I shape some endpoints around screens when it saves round trips, use cursor pagination for long lists, return one error format (RFC 9457 Problem Details), and prefer additive changes over new versions. GraphQL makes sense when many clients need very different shapes of the same data. tRPC needs TypeScript on the server, so it does not fit a Python backend."

**If they dig deeper:**

| Option | Good when | Cost |
|---|---|---|
| REST + OpenAPI | any backend; caching | over/under-fetching |
| GraphQL | many clients, varied shapes | caching, N+1, auth per field |
| tRPC | TS on both sides | TypeScript backend only |

- **Types from FastAPI (verified):** FastAPI publishes an OpenAPI 3.1 schema at `/openapi.json` from your Pydantic models. FastAPI's docs recommend Hey API for TypeScript clients:

```bash
npx @hey-api/openapi-ts \
  -i http://localhost:8000/openapi.json \
  -o src/client
```

- Use tags and set `generate_unique_id_function`, or the method names look like `createItemItemsPost`. In CI, regenerate and fail the build if the client changed without being committed.
- **Pagination:** offset (`?page=3`) is simple and gives page numbers, but it is slow on deep pages and rows shift. Cursor / keyset (`?after=<cursor>&limit=100`) is stable and fast with an index. Return `{ items, nextCursor }`. Make total counts optional; they can be expensive.
- **Errors (RFC 9457 Problem Details, `application/problem+json`):**

```json
{
  "type": "https://api.example.com/err/stale",
  "title": "Deal was changed by someone else",
  "status": 409,
  "detail": "Deal 42 is at version 8; you sent 7.",
  "traceId": "4bf92f3577b34da6a3ce929d0e0e4736",
  "errors": []
}
```

- **Map status codes to UI behavior:**
  - 400 / 422 → show field errors next to the inputs.
  - 401 → refresh the token or sign in again.
  - 403 → "no access" message; do not retry.
  - 409 / 412 → conflict UI.
  - 429 / 503 → retry with backoff.
  - 500 → generic message plus the trace ID.
- **Versioning:** prefer backward-compatible changes (add optional fields; never rename or remove without a deprecation period). Remember that **old browser tabs keep running old JavaScript**, so the API must support the previous client for a while. For a real break, add a new endpoint or `/v2`. Deploy the backend first.
- **Idempotency:** a submit button can be clicked twice. Accept an `Idempotency-Key` header on POSTs that create things.
- **Data formats:** ISO 8601 dates with time zone (energy data is full of time-zone and daylight-saving traps); decimals as strings for money and prices.
- **Screen endpoints (BFF-style aggregation)** for heavy screens; plain resource endpoints for everything else.

**Your angle:** This is your strongest area. You owned the Load Deal service API and wrote the Watt specs the frontend engineers built from ([S3](../AI%20Engineer/13-Behavioral-Story-Bank.md#s3)), across five AMP services ([S14](../AI%20Engineer/13-Behavioral-Story-Bank.md#s14)). "I write the contract first, so the frontend can start the same day against mocks." `[fill in: is the Load Deal backend FastAPI or Java? Do you generate TS types today? What error format and pagination style do you use?]`

**Likely follow-ups:**
- *"How do you avoid breaking the frontend?"* → Generated types in CI, additive changes, contract tests ([Q9](#q9-what-is-your-frontend-testing-strategy-and-cicd-pipeline--p1)).
- *"Why not GraphQL?"* → One main client and a Python backend; REST plus generated types gives most of the benefit with less to run.
- *"A field is slow to compute?"* → Move it to its own endpoint or precompute it; don't slow down the whole list.
- *"How do you document the API?"* → OpenAPI is the doc; FastAPI serves it; add examples to the models.

### Q8. How would you structure state management in a medium-size React app?  `[P0]`

**Clarify first:** How much data comes from the server vs is created in the UI? Do users share links to filtered views? Are there big forms?

**Say this first (~30 sec):**
"I split state by where it really lives. Server state, like deals, PnL, and entitlements, goes in a query cache such as TanStack Query, which handles caching, deduping, background refresh, and invalidation after saves. URL state, like filters, sort, tab, and selected deal ID, goes in the URL so links can be shared and the back button works. Local UI state, like an open dialog or a form draft, stays in the component. Only the small part left that is truly global, like current user, theme, and feature flags, goes in Context or a small store like Zustand. Most Redux code in older apps was really a hand-written server-state cache."

**If they dig deeper:**

| Kind | Example | Where |
|---|---|---|
| Server | deals, PnL rows | TanStack Query |
| URL | filters, sort, deal ID | search params |
| Form | edit draft, errors | form lib / reducer |
| Local UI | dialog open | `useState` |
| Global client | user, theme, flags | Context / Zustand |

- **Query keys include every input:**

```ts
const deals = useQuery({
  queryKey: ["deals", { book, date, filters }],
  queryFn: () => api.listDeals({ book, date, filters }),
  staleTime: 30_000,
});

// after a successful save:
queryClient.invalidateQueries({ queryKey: ["deals"] });
```

- Set `staleTime` per data type: entitlements for minutes, prices for seconds.
- **Derived state:** compute it, do not store it (for example, total PnL with `useMemo` from the rows). Stored copies get out of sync.
- **Context trap:** when a context value changes, every consumer re-renders. Split contexts, or use a store with selectors for fast-changing values. See [03](03-React-Fundamentals.md).
- **URL state:** parse and validate search params with a schema (for example, zod), with defaults. Keep large data out of the URL.
- **Forms:** a form library plus a validation schema; field types can come from the generated API types.
- **Optimistic updates:** TanStack Query `onMutate` with rollback in `onError`, or React 19 `useOptimistic`, which shows the temporary value only while the action is running and falls back by itself if it fails.
- **Big data:** let the grid own its row data. Do not copy 100k rows into a global store.

**Your angle:** Use the backend analogy, because it is true: "Server state in the browser is a cache in front of a database. The same rules apply as in Redis: clear keys, a TTL, and invalidate on write. I've done that on the server ([S9](../AI%20Engineer/13-Behavioral-Story-Bank.md#s9), [S14](../AI%20Engineer/13-Behavioral-Story-Bank.md#s14))." `[fill in: what the AMP or Load Deal UI uses today (Redux? React Query? Context?) and what you would change]`

**Likely follow-ups:**
- *"When would you still use Redux?"* → Large, complex client-only state with many writers, or a team that already knows it well.
- *"Where does 'selected deal' live?"* → In the URL (`/deals/42`), so refresh and share work.
- *"Unsaved changes and the user navigates away?"* → Route blocker plus `beforeunload` warning; optional local draft.
- *"How do you avoid extra re-renders?"* → Split contexts, selectors, memoization only where profiling shows a problem.

### Q9. What is your frontend testing strategy and CI/CD pipeline?  `[P1]`

**Say this first (~30 sec):**
"I use the 'testing trophy' idea. Fast unit tests for pure logic, like formatters and reducers. Most of the value comes from component tests with React Testing Library, which test what the user sees, with the network mocked by MSW. Contract checks keep frontend and backend in sync: generated types plus a breaking-change check on the OpenAPI schema. A small set of Playwright end-to-end tests covers the critical paths: sign in, load deals, edit and save, run a job. Every PR runs lint, type check, tests, and a build, and gets a preview environment. Production releases go behind feature flags with a fast rollback."

**If they dig deeper:**

| Level | Tool | Catches |
|---|---|---|
| Unit | Vitest / Jest | logic, formatting |
| Component | RTL + MSW | UI behavior, states |
| Contract | OpenAPI diff / Pact | API breaks |
| E2E | Playwright | full flows, auth |
| a11y | axe checks | labels, roles |

- **Test every state:** loading, empty, error, no permission, conflict. These are where bugs hide.
- **Query by role and label** (`getByRole("button", { name: "Save" })`), not CSS classes. This also checks accessibility.
- **Contract tests:** with one consumer, generated types plus a schema diff in CI are enough. With many consumers, consumer-driven contracts (Pact).
- **Stable E2E:** seeded test data, a test user with saved auth state, no fixed `sleep`; wait for UI conditions. Run a smoke set on each PR and the full set nightly.

```
PR ─► lint + typecheck ─► unit + component
   ─► build + bundle-size check
   ─► preview env ─► E2E smoke
merge ─► staging ─► prod (flag / canary)
```

- **Preview environments (verified):** Azure Static Web Apps builds one per pull request and deletes it when the PR closes. Warning: anyone with the URL can open it, so be careful with internal data.
- **SPA deploys:** hashed JS/CSS files cached for a long time; `index.html` not cached. Keep the old chunks for a while after a deploy; otherwise open tabs fail to lazy-load old chunks (in webpack apps this shows up as `ChunkLoadError`).
- **Feature flags** separate deploy from release. **Rollback** = point `index.html` back to the previous build.

**Your angle:** [S8](../AI%20Engineer/13-Behavioral-Story-Bank.md#s8): the 32-deal reconciliation with the traders' workbook is golden-data testing. Those deals can become a regression test set. [S1](../AI%20Engineer/13-Behavioral-Story-Bank.md#s1): the 20-question eval set is the same idea for AI. [S6](../AI%20Engineer/13-Behavioral-Story-Bank.md#s6): AI-assisted commits went from 36% to 80%, so review and test rules matter more. Honest fact for Jupiter: CI runs only lint today. You wrote 17 of the 25 UI test files and most API tests, but they run locally. Say that, then say how you'd add them to CI ([06 Q13](06-Jupiter-Load-Deal-Deep-Dive.md)). `[fill in: Watt's CI; your review rules for AI-written code]`

**Likely follow-ups:**
- *"How do you test permission-based UI?"* → Render with different entitlement fixtures; plus API tests proving the server rejects.
- *"How do you keep E2E tests from being flaky?"* → Seeded data, role selectors, no sleeps, retries only with a report.
- *"How do you test AI-written code?"* → Same bar: tests required, small PRs, human review.

### Q10. How do you add observability to a frontend and trace a user action to the backend?  `[P1]`

**Say this first (~30 sec):**
"Three parts: errors, real-user performance, and traces. Errors: catch them with error boundaries and global handlers, and send them with the release version and uploaded source maps so stack traces are readable. Real-user monitoring: page views, route changes, Core Web Vitals, and API latency as the user saw it. Traces: the browser adds a W3C `traceparent` header to API calls, so one click can be followed through the gateway, the services, and the database in one trace. Every error message shown to the user includes a short trace ID they can send to support."

**If they dig deeper:**

```
click "Save deal"
 └ browser span: ui.save
   └ PATCH /deals/42  (traceparent: 00-<id>-…)
     └ gateway span
       └ deal-service span
         ├ Redis span
         └ SQL span
```

- **On Azure (verified):** the Application Insights JavaScript SDK is Microsoft's supported browser path. It collects page views, fetch/XHR calls, and exceptions, and has a React plugin.
  - `enableAutoRouteTracking` logs SPA route changes as page views.
  - The default `distributedTracingMode` (`AI_AND_W3C`) adds `traceparent` to same-origin calls.
  - For an API on another domain, set `enableCorsCorrelation: true` and allow those headers in CORS.
- Microsoft says this SDK does not use OpenTelemetry, and OpenTelemetry's own docs call browser instrumentation experimental. Use OpenTelemetry on the server side. Sentry and Datadog are other common choices.
- **Business events:** "deal saved", "export started", "chat thumbs-down", "time until data visible". These answer product questions, not only technical ones.
- **Context on every event:** app version, route, feature flags, hashed user ID.
- **Privacy:** do not log trade details, prompt text, or personal data by default. Sample and scrub.
- **Alerts:** error rate by release (catches a bad deploy within minutes), p75 LCP / INP getting worse, API 5xx as seen from the browser.

**Your angle:** [S12](../AI%20Engineer/13-Behavioral-Story-Bank.md#s12): at Wayfair you worked on the Backstage observability platform, the Post-mortem Wizard, and a Slack SLO-alert app with 3,000+ users. [S1](../AI%20Engineer/13-Behavioral-Story-Bank.md#s1) / [S4](../AI%20Engineer/13-Behavioral-Story-Bank.md#s4): per-turn cost and a turn log for every AI interaction. Be honest: "My observability work has been backend and platform. For the browser I would add…" `[fill in: what frontend telemetry Watt / Load Deal has today, if any]`

**Likely follow-ups:**
- *"A user says 'the page is slow'. What do you do?"* → Find their session by user and time, look at the trace, split backend vs browser time.
- *"How do you link errors to a deploy?"* → Release version on every event; compare error rate before and after.
- *"What must you not log?"* → Tokens, personal data, trade details, full prompts.

### Q11. Design a flow for a long-running job started from the UI (submit, status, cancel).  `[P1]`

**Clarify first:** How long does a job run (seconds, minutes, hours)? Can a user start many? Who may see or cancel a job? Is the result a file, a table, or a status only?

**Say this first (~30 sec):**
"I never keep an HTTP request open for minutes. The UI POSTs the job with an idempotency key. The API validates it, writes a job row, puts a message on a queue, and returns 202 with a job ID and a status URL. Workers, for example Kubernetes Jobs scaled by KEDA from the queue length, pick it up and write progress to the job row. The UI polls the status endpoint with backoff, or listens with SSE, and shows queued, running with progress, succeeded, failed, or canceled. Cancel is a DELETE on the job, and the worker checks for it between steps. The job survives a page refresh because its state lives on the server."

**If they dig deeper:**

```
UI ─ POST /jobs (Idempotency-Key) ─► API
UI ◄─ 202 {jobId}, Location ──────── API
             API ─► queue ─► worker (KEDA)
UI ─ GET /jobs/{id} (poll or SSE) ─► API
             worker ─► writes progress ─┘
UI ─ DELETE /jobs/{id} (cancel) ───► API
```

- **Azure Asynchronous Request-Reply pattern (verified):** 202 Accepted with `Location` (the status URL) and `Retry-After` (how long to wait). The status endpoint returns 200 while running, and 303 See Other to the result when done. Cancel = `DELETE` on the status resource. Use RFC 9457 for failures.
- **States:** queued → running → succeeded / failed / canceled. Add **stuck detection**: if a worker stops sending heartbeats, mark the job failed or put it back on the queue.
- **Status body:** `status`, `percent`, `step`, `createdAt`, `lastUpdatedAt`, `error`, `resultUrl`.
- **Polling:** start at 1–2 s, back off to 5–10 s, stop at a final state, pause when the tab is hidden. Use SSE when progress is fine-grained or many people watch the same job.
- **UI:**
  - A "My jobs" list, so users can come back after a refresh.
  - A notification when a job finishes, even if the user moved to another page.
  - Disable the Run button after a click, plus the idempotency key on the server.
  - Show who started the job and when.
- **Cancel:** cooperative. The worker checks a cancel flag between steps and stops any running query. For a DAG, cancel the children too (cascade-cancel). Decide if partial results are rolled back or kept and marked.
- **Workers must be idempotent,** so a retry after a crash is safe.
- **Large results:** write to blob storage and return a signed, short-lived link.
- **KEDA ScaledJob (verified):** runs each event as a Kubernetes Job that processes it to completion. The KEDA docs say this is mainly for long-running executions.

**Your angle:** [S14](../AI%20Engineer/13-Behavioral-Story-Bank.md#s14): you built a **KEDA job-execution service from scratch**, with leader election, DAGs, cascade-cancel, and stuck-run recovery. That is the backend half of this design, so speak from experience. `[fill in: which jobs it runs (PnL runs? deal loads? validations?), typical duration, ScaledJob or ScaledObject, ]`. On Jupiter, a PnL recompute runs through Data Factory or a KEDA worker. A Redis lock blocks double clicks, and the UI shows a toast and the new run after a reload ([06 Q6](06-Jupiter-Load-Deal-Deep-Dive.md)).

**Likely follow-ups:**
- *"The user double-clicks Run?"* → Button disabled plus idempotency key; the same job ID comes back.
- *"The worker dies halfway?"* → Heartbeat timeout → retry from the last checkpoint or fail clearly; idempotent steps.
- *"How do you show progress for a DAG?"* → Per-node status from the job row; a simple step list, not a graph, for most users.
- *"Polling or WebSocket?"* → Polling first; it is simple and the job takes minutes anyway.

### Q12. Walk me through how you deliver a feature end to end, from spec to release.  `[P0]`

**Say this first (~30 sec):**
"I start from the user and the decision they need to make, and write a short spec: the user story, the screens, the API contract, the data changes, the permissions, and how we will know it works. I get the API contract agreed first, because then backend and frontend can work in parallel; the frontend uses mocks generated from the OpenAPI schema. I build in thin slices that go from database to UI, with tests, behind a feature flag. I release to a few users first, watch errors and usage, then turn it on for everyone and remove the flag."

**If they dig deeper:**

1. **Understand:** sit with users and watch the current workflow (for example, the traders' Excel workbook). Agree on one success metric.
2. **Spec:** a rough screen sketch, OpenAPI draft, data model, entitlement needed, edge cases, and non-functional needs (latency, audit).
3. **Contract first:** an OpenAPI PR reviewed by frontend and backend. Generate the TS client; add MSW mocks.
4. **Backend:** a backward-compatible migration (expand → migrate → contract), the endpoint, the permission check, tests.
5. **Frontend:** route, data hooks, components, every state (loading / empty / error / no access), keyboard and labels.
6. **Tests:** unit and component; one E2E for the main path; the contract check.
7. **Release:** demo on the preview env to real users, feature flag, staged rollout, dashboard.
8. **After:** check the success metric, remove the flag, write a short decision record.

- **Expand / contract migrations:** add the new column first, deploy code that writes both, backfill, switch reads, then drop the old column. Old and new code both work during the deploy.
- **Demo early:** misunderstandings are cheaper to fix in week 1 than after release.
- **Cut scope, not quality:** ship slice 1 in a week, then grow it.

**Your angle:** [S8](../AI%20Engineer/13-Behavioral-Story-Bank.md#s8): the PnL engine. You worked with the PM through 60+ discrepancies, wrote the rules down on 7 Confluence pages, proposed the whole-month basis, matched all 32 deals, and released in Aug 2026, saving 3 hours a day. [S3](../AI%20Engineer/13-Behavioral-Story-Bank.md#s3): spec first; the frontend engineers built from your specs. [M1](../AI%20Engineer/13-Behavioral-Story-Bank.md#m1): daily written instructions to the frontend engineers. [S1](../AI%20Engineer/13-Behavioral-Story-Bank.md#s1): an AI assistant shipped in 3 weeks. Honest close: "On my projects I usually owned spec, API, and data, and reviewed the UI. In this role I want to own the UI too." `[fill in: one UI decision you influenced, e.g., something you changed after reviewing a frontend PR]` See [01](01-Pitch-and-Full-Stack-Framing.md) for this framing.

**Likely follow-ups:**
- *"The spec changed halfway. What happened?"* → Use S8: rules written down and signed off; changes logged.
- *"How do you decide what goes into v1?"* → The smallest slice that moves the success metric.
- *"The frontend engineer disagrees with your API shape?"* → Listen to the screen's needs; often add a screen endpoint; agree in the OpenAPI PR.
- *"How do you work with designers?"* → Agree on states and edge cases early, not only the happy-path mockup.

## References

**Frameworks and patterns**
- [The RADIO framework (GreatFrontEnd)](https://www.greatfrontend.com/front-end-system-design-playbook/framework): the answer structure in the Primer.
- [Micro Frontends (martinfowler.com)](https://martinfowler.com/articles/micro-frontends.html): integration options and trade-offs (Q3).
- [Module Federation 2.0 guide](https://module-federation.io/guide/start/index.html): runtime, manifest, type hints; webpack and Rspack (Q3).
- [Asynchronous Request-Reply pattern (Azure Architecture Center)](https://learn.microsoft.com/en-us/azure/architecture/patterns/async-request-reply): 202, Location, Retry-After, 303, DELETE to cancel (Q11).
- [KEDA: scaling jobs](https://keda.sh/docs/latest/concepts/scaling-jobs/): ScaledJob for long-running executions (Q11).

**Performance**
- [Web Vitals (web.dev)](https://web.dev/articles/vitals): LCP, INP, CLS thresholds at p75 (Q4).
- [INP becomes a Core Web Vital on March 12 (web.dev)](https://web.dev/blog/inp-cwv-march-12): INP replaced FID (Q4).
- [Optimize long tasks (web.dev)](https://web.dev/articles/optimize-long-tasks): the 50 ms rule and yielding (Q4).
- [React `lazy`](https://react.dev/reference/react/lazy): code splitting (Q4).

**Data grids and state**
- [AG Grid row models](https://www.ag-grid.com/react-data-grid/row-models/): client-side vs infinite vs server-side vs viewport (Q1).
- [AG Grid Server-Side Row Model](https://www.ag-grid.com/react-data-grid/server-side-model/): lazy blocks; server sort and filter (Q1).
- [AG Grid DOM virtualisation](https://www.ag-grid.com/react-data-grid/dom-virtualisation/): row buffer, visible rows only (Q1).
- [AG Grid high-frequency updates](https://www.ag-grid.com/react-data-grid/data-update-high-frequency/): async transactions (Q5).
- [AG Grid Excel export](https://www.ag-grid.com/react-data-grid/excel-export/): Enterprise feature (Q1).
- [TanStack Virtual](https://tanstack.com/virtual/latest): virtualization for custom lists (Q1).
- [TanStack Query overview](https://tanstack.com/query/latest/docs/framework/react/overview): why server state is different (Q8).
- [React `useOptimistic`](https://react.dev/reference/react/useOptimistic) and [React 19 release post](https://react.dev/blog/2024/12/05/react-19): optimistic UI and Actions (Q1, Q8).

**Streaming and real time**
- [Using server-sent events (MDN)](https://developer.mozilla.org/en-US/docs/Web/API/Server-sent_events/Using_server-sent_events): `retry`, `id`, `text/event-stream` (Q2, Q5).
- [EventSource (MDN)](https://developer.mozilla.org/en-US/docs/Web/API/EventSource): the 6-connection limit on HTTP/1.1 (Q5).
- [Using readable streams (MDN)](https://developer.mozilla.org/en-US/docs/Web/API/Streams_API/Using_readable_streams): reading a fetch body as a stream (Q2).
- [AbortController (MDN)](https://developer.mozilla.org/en-US/docs/Web/API/AbortController): the Stop button (Q2).
- [WebSockets API (MDN)](https://developer.mozilla.org/en-US/docs/Web/API/WebSockets_API) (Q5).

**Auth and security**
- [Entra ID auth code flow](https://learn.microsoft.com/en-us/entra/identity-platform/v2-oauth2-auth-code-flow): PKCE for SPAs, `spa` redirect type, 24-hour SPA refresh tokens (Q6).
- [Single sign-on with MSAL.js](https://learn.microsoft.com/en-us/entra/identity-platform/msal-js-sso): `cacheLocation`, `ssoSilent` (Q6).
- [Third-party cookie blocking and SPAs (Entra)](https://learn.microsoft.com/en-us/entra/identity-platform/reference-third-party-cookies-spas) (Q6).
- [RFC 10017: OAuth 2.0 for Browser-Based Applications (Aug 2026)](https://www.rfc-editor.org/rfc/rfc10017): BFF vs token-mediating backend vs browser-only (Q6).
- [OWASP XSS Prevention Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Cross_Site_Scripting_Prevention_Cheat_Sheet.html): rendering untrusted text safely (Q2, Q6).

**APIs**
- [FastAPI: generating SDKs](https://fastapi.tiangolo.com/advanced/generate-clients/): OpenAPI 3.1 to TypeScript, operation IDs (Q7).
- [Hey API](https://heyapi.dev/): the TypeScript client generator FastAPI recommends (Q7).
- [tRPC docs](https://trpc.io/docs): type-safe APIs for full-stack TypeScript (Q7).
- [RFC 9457: Problem Details for HTTP APIs](https://www.rfc-editor.org/rfc/rfc9457): the error format (Q7).

**Testing, deploy, observability**
- [The testing trophy (Kent C. Dodds)](https://kentcdodds.com/blog/the-testing-trophy-and-testing-classifications) (Q9).
- [React Testing Library](https://testing-library.com/docs/react-testing-library/intro/), [MSW](https://mswjs.io/docs/), [Playwright](https://playwright.dev/docs/intro), [Pact](https://docs.pact.io/) (Q9).
- [Azure Static Web Apps PR preview environments](https://learn.microsoft.com/en-us/azure/static-web-apps/review-publish-pull-requests) (Q9).
- [Application Insights JavaScript SDK](https://learn.microsoft.com/en-us/azure/azure-monitor/app/javascript-sdk) and [its configuration](https://learn.microsoft.com/en-us/azure/azure-monitor/app/javascript-sdk-configuration): RUM, route tracking, W3C correlation (Q10).
- [OpenTelemetry for the browser](https://opentelemetry.io/docs/languages/js/getting-started/browser/): still experimental (Q10).
- [W3C Trace Context](https://www.w3.org/TR/trace-context/): the `traceparent` header (Q10).
