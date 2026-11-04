# 06 · Jupiter (Load Deal) Deep Dive

[← Index](00-Index.md) · **Interview priority:** High · **Read time:** ~25 min, then draw it and say it out loud

> **Why this matters for this role:** You heard that the interview will ask about the design of Load Deal. A project deep dive is where interviewers check that you really built what your resume says. They ask "why" three times in a row. You need a clear 2-minute walkthrough, one diagram you can draw from memory, and honest answers about who built which part.

**Status:** this page has the facts from your resume, the story bank and the company-session reply #1. Fill the remaining `[fill in]` gaps from reply #2.

## Primer

### Who built what (from git history)
- **You, backend:** the Load Deal service and the **PnL engine** ([S8](../AI%20Engineer/13-Behavioral-Story-Bank.md#s8)), PnL caching, the **Ask AI job API** (rate limits, cost per turn, a read-only agent database role), Jupiter admin entitlements, and the shared entitlements service ([S9](../AI%20Engineer/13-Behavioral-Story-Bank.md#s9)).
- **You, frontend** (Jul–Oct 2026):
  - the **Ask AI chat page**: job polling, answers shown as SQL, tables and charts, conversation history
  - **PnL Summary** moved from mock data to the live API
  - **Portfolio PnL history**
  - the **Admin usage tab**
  - **daylight-saving fixes** across forecast charts, grids and Excel exports
- **A frontend engineer:** most of the other pages. You approved 26 of their PRs ([M1](../AI%20Engineer/13-Behavioral-Story-Bank.md#m1)).
- **How to say it:** "I owned the backend and the PnL engine, and I built the AI chat page and the live PnL views. Our frontend engineer built most of the other screens, and I reviewed their PRs."

### Frontend stack
React 19, TypeScript, Vite 7, Tailwind 3, AG Grid and AG Charts, ApexCharts, Vega-Lite, React Context, Dexie (IndexedDB), MSAL sign-in, Vitest. Backend: FastAPI, Snowflake, ADF, Redis, Service Bus.
- **Be ready for:** "Why three chart libraries?" `[fill in: e.g., AG Charts inside grids, Vega-Lite for AI-generated charts, ApexCharts from earlier pages]` · "What is Dexie used for?" `[fill in: e.g., caching data in the browser's IndexedDB]`

### Facts you can use
- Released **Aug 2026**. Saves about **3 hours a day** of manual work.
- Before release, the PnL engine had to match the traders' Excel workbook. You and the PM resolved **60+ discrepancies**, documented on 7 Confluence pages. In the end **all 32 deals matched**.
- Example issues: a missing forward curve, and the loads-through cutoff rule. You proposed moving to a **whole-month basis**.
- Entitlement checks: **3–6s → ~10ms**, Redis-first, fail-closed.
- Load Deal AI: a Snowflake Cortex agent over a **semantic view**, a LangGraph agent with **citation checks**, a **20-question eval set**, and **per-turn cost tracking**. The chat UI shows the SQL, tables and charts.
- Domain knowledge base: 10 docs, about 100 sections. AI-assisted commits went from **36% to 80%** ([S6](../AI%20Engineer/13-Behavioral-Story-Bank.md#s6)).

### Domain words, in simple English
Check each one against how BETM uses it, and fix it in your own words.
- **Load deal:** a contract to supply electricity to customers' demand ("load"). The volume follows what the customers actually use. `[check]`
- **PnL:** profit and loss of the deals.
- **Forward curve:** market prices for future delivery periods, for example each future month. It's used to value deals that haven't settled yet.
- **Loads-through cutoff:** `[fill in: one sentence]`
- **Whole-month basis:** `[fill in: what it means and why it fixed mismatches]`

### Architecture (template; correct it from the reply)

```
 Trader / analyst (browser)
         │
 React 19 + TS (Vite)
 AG Grid, charts, MSAL
         │ HTTPS + token
 Gateway / auth  [fill in]
         │
 FastAPI (Load Deal API)
   ├─ entitlements (Redis, S9)
   ├─ PnL engine + cache
   └─ Ask AI job API
         │
 Snowflake (+ ADF loads)
```

Load Deal AI, alongside:

```
 Chat UI
   │
 LangGraph agent
   ├─ Cortex agent + semantic
   │  view (numbers, SQL)
   └─ knowledge base (rules)
      + citation check
```

### The 2-minute walkthrough (use this order)
1. **Problem and users** (15 sec): who used it, and what they did by hand before. `[fill in]`
2. **Architecture** (30 sec): draw the diagram above, top to bottom.
3. **One request, end to end** (30 sec): for example, "a trader opens a deal and sees its PnL". Follow it through UI → API → engine → data → back.
4. **One hard decision** (20 sec): for example, the whole-month basis, or how the UI handles slow calculations.
5. **Result** (10 sec): released Aug 2026, 32 of 32 deals matched, 3 hours a day saved.
6. **What you'd change** (15 sec): see Q10.

## Questions & answers

### Q1. Walk me through Jupiter end to end.  `[P0]`
**Say this first (~30 sec):**
> "Jupiter is our Load Deal platform. Traders use it to `[fill in: load and manage load deals]`, and it calculates PnL. Before, they did this in an Excel workbook, which took about three hours a day. I owned the backend and the PnL engine. The React UI calls our API, the API checks entitlements, then reads deal data and forward curves from `[fill in]` and runs the PnL engine. It went live in August 2026, and all 32 deals matched the traders' workbook."

**If they dig deeper:**
- Draw the diagram from the Primer while you talk.
- Follow one request through every layer (walkthrough step 3).
- Main screens: `[fill in: from reply #2]`

**Your angle:** [S8](../AI%20Engineer/13-Behavioral-Story-Bank.md#s8), [S1](../AI%20Engineer/13-Behavioral-Story-Bank.md#s1).
**Likely follow-ups:** "Why that architecture?" · "What was the hardest part?" (Q9) · "How does the UI get its data?" (Q3)

---

### Q2. What does the UI look like, and how is the frontend structured?  `[P0]`
**Say this first (~30 sec):**
> "It's React 19 with TypeScript on Vite, Tailwind for styling, AG Grid for the deal and PnL tables, and AG Charts, ApexCharts and Vega-Lite for charts. Shared state like the user and permissions lives in React Context. There's no Redux. Sign-in is MSAL. The main screens are `[fill in: e.g., deal list, deal upload, PnL Summary, Portfolio PnL history, Ask AI, Admin]`. I built Ask AI, the live PnL Summary, Portfolio PnL history and the Admin usage tab. Our frontend engineer built most of the others."

**If they dig deeper:**
- How server data is loaded and cached: `[fill in: plain fetch in hooks? Dexie (IndexedDB) for what?]`
- How the deal grid works: `[fill in: AG Grid client-side or server-side row model? how many rows?]`
- **Mock data → live API (your change):** say how you did it safely. `[fill in: e.g., kept the same TypeScript types, so swapping the data source didn't change the components]`
- **The daylight-saving bug (your fix):** a power day has 23 or 25 hours when the clocks change. Charts, grids and Excel exports showed the wrong hours. `[fill in: the root cause, e.g., converting local time vs UTC, or assuming 24 hours]`. This is a great "hard bug" story because it crosses backend, UI and export.
- If you don't know a detail of a page you didn't build, say so: "Our frontend engineer built that page. I believe it's X, and here's how I'd do it."

**Your angle:** [M1](../AI%20Engineer/13-Behavioral-Story-Bank.md#m1).
**Likely follow-ups:** "Why that state library?" ([03](03-React-Fundamentals.md)) · "How would you build the grid?" ([05](05-Frontend-System-Design.md))

---

### Q3. How does the frontend get and update data? Show me the API design.  `[P0]`
**Say this first (~30 sec):**
> "It's a `[fill in: REST?]` API. The main resources are `[fill in: deals, PnL results, curves]`. I designed the request and response shapes with the UI screens in mind, so one screen needs one or two calls, not ten. Errors come back in one standard format, so the UI can show a clear message. `[fill in: how types are shared with the frontend, e.g., OpenAPI-generated TypeScript types]`."

**If they dig deeper:**
- Pagination and filtering for large deal lists: `[fill in]`
- Updates: how a deal edit is saved and validated. Are both client and server validating? `[fill in]`
- Caching: `[fill in: Redis? HTTP cache headers? client cache?]`

**Your angle:** [S9](../AI%20Engineer/13-Behavioral-Story-Bank.md#s9), [S14](../AI%20Engineer/13-Behavioral-Story-Bank.md#s14).
**Likely follow-ups:** "REST or GraphQL, and why?" ([05](05-Frontend-System-Design.md)) · "How do you version the API?"

---

### Q4. How does the PnL engine work, and how did you prove the numbers were right?  `[P0]`
**Say this first (~30 sec):**
> "The engine takes each deal's volumes and prices, values them against the forward curve, and produces PnL by `[fill in: period / deal / book]`. The proof was matching the traders' own workbook. At first it didn't match. I worked with the PM through more than 60 discrepancies, and wrote every rule down on Confluence, for example a missing forward curve and the loads-through cutoff. I proposed a whole-month basis, and in the end all 32 deals matched."

**If they dig deeper:**
- Most mismatches were in the business rules, not in the code. Writing each rule down and getting sign-off was what unblocked the work.
- How it's tested now: `[fill in: regression tests with known deals?]`
- Performance: how long a full PnL run takes. `[fill in]`

**Your angle:** [S8](../AI%20Engineer/13-Behavioral-Story-Bank.md#s8).
**Likely follow-ups:** "How do you stop it from breaking again?" · "What if the workbook was wrong?"

---

### Q5. How are permissions handled, in the UI and on the server?  `[P1]`
**Say this first (~30 sec):**
> "The server always enforces access. The UI only hides what the user can't use, for a cleaner screen, and it's never the real security. Every API call goes through our shared entitlements service. I made it Redis-first and fixed N+1 lookups, so a check went from 3–6 seconds to about 10 milliseconds. It also fails closed: if the check errors, access is denied."

**If they dig deeper:**
- How the UI learns the user's permissions: `[fill in: one call at login? per page?]`
- What happens when permissions change while the user is logged in. `[fill in]`

**Your angle:** [S9](../AI%20Engineer/13-Behavioral-Story-Bank.md#s9).
**Likely follow-ups:** "Why fail closed? What does the user see?" · "How do you cache permissions safely?"

---

### Q6. How does the UI handle slow calculations or large data?  `[P1]`
**Say this first (~30 sec):**
> "`[fill in: is a PnL run synchronous, or a background job?]`. For slow work we use a job: the UI submits, gets a job ID, shows progress, and polls for the result. Ask AI works this way, and I built both sides of it. On AMP I built a KEDA job-execution service with cascade-cancel and stuck-run recovery, so I know the backend side of that pattern well. For large lists, `[fill in: paging or virtualization in the grid]`."

**If they dig deeper:**
- Polling vs Server-Sent Events for job status, and why. ([05](05-Frontend-System-Design.md))
- What the user sees while waiting: a skeleton, a progress bar, the last good result.

**Your angle:** [S14](../AI%20Engineer/13-Behavioral-Story-Bank.md#s14).
**Likely follow-ups:** "What if the user closes the tab during a run?"

---

### Q7. Load Deal AI: how does the assistant and its chat UI work?  `[P0]`
**Say this first (~30 sec):**
> "Traders ask questions in plain English. Numbers go to a Snowflake Cortex agent over a semantic view, so the model writes SQL against agreed definitions instead of guessing. Business rules come from a curated knowledge base. A LangGraph agent coordinates this and checks that every answer cites its sources. I built the chat page in React too. It submits the question as a job, polls for the result, and shows the SQL, the result table and a chart, so users can check the answer. I built it in three weeks, with a 20-question eval set and cost tracking for every turn."

**If they dig deeper:**
- **The job API (yours):** each question becomes a job, with rate limits, cost per turn, and a **read-only database role** for the agent, so it can never change data.
- **Why polling here and SSE in Watt?** `[fill in: your real reason, e.g., Ask AI answers come back whole after the agent runs SQL, so polling is simpler; Watt chat streams tokens, so SSE]`
- How tables and charts are rendered: `[fill in: AG Grid for the table? Vega-Lite spec for the chart?]`
- Conversation history: where it's stored, and how it's loaded. `[fill in]`
- Results: `[fill in: eval pass rate, cost per turn, users]`

**Your angle:** [S1](../AI%20Engineer/13-Behavioral-Story-Bank.md#s1), [S4](../AI%20Engineer/13-Behavioral-Story-Bank.md#s4).
**Likely follow-ups:** "How would you build streaming in React?" ([04](04-React-Coding-Exercises.md)) · "How do you stop wrong numbers?"

---

### Q8. How did you test Jupiter?  `[P1]`
**Say this first (~30 sec):**
> "Three levels. The business acceptance test was matching the traders' workbook: 32 of 32 deals. For code, `[fill in: unit tests on the PnL rules, API tests]`. For the AI assistant, the 20-question eval set, which I ran on every prompt or model change. On the UI, Vitest `[fill in: what the UI tests cover]`."

**If they dig deeper:**
- If the UI had few tests, say so and say what you'd add: React Testing Library for key screens, and one Playwright test for "open a deal and see PnL".

**Your angle:** [S8](../AI%20Engineer/13-Behavioral-Story-Bank.md#s8), [S1](../AI%20Engineer/13-Behavioral-Story-Bank.md#s1).
**Likely follow-ups:** "What's your test strategy for a new frontend?" ([05](05-Frontend-System-Design.md))

---

### Q9. What was the hardest problem?  `[P0]`
**Say this first (~30 sec):**
> "Getting the PnL engine to match the traders' workbook. The code worked, but the business rules were unclear. Each mismatch could be a bug in my code, a rule nobody had written down, or a mistake in the workbook. I worked through more than 60 of them with the PM, wrote every rule down, and got sign-off. That's how we reached 32 of 32."

**If they dig deeper:**
- One specific mismatch, from start to finish: `[fill in: the missing forward curve or the loads-through cutoff]`
- A technical alternative, if they want code: `[fill in: a hard bug or performance problem]`

**Your angle:** [S8](../AI%20Engineer/13-Behavioral-Story-Bank.md#s8).
**Likely follow-ups:** "What would you do differently?" (Q10)

---

### Q10. What would you change if you built it again?  `[P0]`
**Say this first (~30 sec):**
> "`[fill in: your real answer]`. Good candidates: write the business rules down as test cases from day one, so reconciliation is automatic; share TypeScript types with the frontend from an OpenAPI spec; `[fill in]`."

**If they dig deeper:**
- Pick one change and explain the trade-off: what it would cost, and what it would save.

**Your angle:** [S8](../AI%20Engineer/13-Behavioral-Story-Bank.md#s8).
**Likely follow-ups:** "Why didn't you do that the first time?" Honest answer: time pressure, and the rules weren't known yet.

---

### Q11. How did you work with the frontend engineer on Jupiter?  `[P1]`
**Say this first (~30 sec):**
> "When my manager left, I led the frontend engineer day to day. Every evening I wrote down what to build next, why, and what 'done' looks like. In the morning we had a short check-in, and I reviewed every PR. When an API change was needed, `[fill in: how you handled it]`."

**Your angle:** [M1](../AI%20Engineer/13-Behavioral-Story-Bank.md#m1).
**Likely follow-ups:** "Give an example of PR feedback you gave." `[fill in]`

---

### Q12. How did you release it safely?  `[P2]`
**Say this first (~30 sec):**
> "`[fill in: parallel run with the workbook? a pilot user? a feature flag?]`. We only switched after all 32 deals matched. After release, `[fill in: monitoring, alerts, how issues are reported]`."

**Likely follow-ups:** "What happened in the first week after release?"

## References
- [Story bank: S1 · Load Deal AI](../AI%20Engineer/13-Behavioral-Story-Bank.md#s1)
- [Story bank: S8 · PnL engine reconciliation](../AI%20Engineer/13-Behavioral-Story-Bank.md#s8)
- [Story bank: S9 · Entitlements service](../AI%20Engineer/13-Behavioral-Story-Bank.md#s9)
- [Story bank: M1 · Leading three contractors](../AI%20Engineer/13-Behavioral-Story-Bank.md#m1)
- [05 · Full-Stack & Frontend System Design](05-Frontend-System-Design.md): the general versions of these design questions.
