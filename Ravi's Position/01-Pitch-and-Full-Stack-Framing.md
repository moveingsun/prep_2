# 01 · Pitch & Full-Stack Framing

[← Index](00-Index.md) · **Interview priority:** High · **Read time:** ~15 min, then say it out loud

> **Why this matters for this role:** Your old resume read as backend, data and AI. A full-stack interviewer will ask early, in some form, "How much frontend have you really done?" Your git history gives you a strong answer. Say it clearly in the first 5 minutes, and every React question after that feels like a conversation, not a test.

## Primer

### Your honest full-stack position
- **You are a backend-heavy full-stack engineer who writes production React + TypeScript.** Say it with confidence. The git history backs it up.
- **Frontend you wrote yourself (from git history, 2026):**
  - **Watt** (React 19, TS, Vite, Tailwind): about 239 commits across 4 UI repos, Aug–Nov. You built the **Data Validation UI** (rules, run history, monitors, chat pages) and **Ask Data UI** (you created it). You also built part of **Ask Knowledge** (uploads, PDF citation highlighting), the shell's **Admin tab**, and a shared **admin-kit** package used by 3 apps. You wrote **68 of the 102** UI test files.
  - **Jupiter** (React 19, TS, AG Grid): the **Ask AI chat page** (job polling, answers shown as SQL, tables and charts, history). You also moved **PnL Summary** from mock data to the live API, built **Portfolio PnL history** and the **Admin usage tab**, and fixed **daylight-saving bugs** in charts, grids and Excel exports.
  - **AMP** (React 18, TS, AG Grid, ECharts): the asset dashboard's **price and volume tabs**, filters and widgets, the **outage-management forms**, the admin forms for users and service principals, and **entitlement-based access checks**.
  - **Earlier:** custom **Backstage plugins in TypeScript** at Wayfair, the **beta Kronos UI** (Wayfair co-op), and Java UI components at Cerner.
- **Frontend that others built, where you did the design or review:**
  - The **Watt shell**: sign-in, sidebar, the entitlement-driven app list, and the shared chat-kit and ui-kit packages. A frontend engineer built it. You built the backend it calls and wrote the specs. chat-kit runs on **your chat API contract** (SSE over Redis).
  - **Most Jupiter pages:** a frontend engineer built them on your APIs. You approved 26 of their PRs.
  - **About two-thirds of AMP's UI commits** came from other engineers. You approved 60 of their PRs.
- **The rule:** use "I built" only for code you wrote. Use "I designed the API" or "I reviewed" for the rest. Interviewers catch exaggeration fast in a deep dive.

### Three things you want them to remember
1. **"He ships features from the database to the screen."** Ask AI on Jupiter, Data Validation on Watt.
2. **"He designs APIs and contracts that frontend code runs on."** The Watt chat contract, entitlements.
3. **"He makes the UI fast by fixing the real bottleneck."** AMP landing page ~10s → 5s, outage management 7s → 1s, entitlements 3–6s → ~10ms.

## Questions & answers

### Q1. Tell me about yourself.  `[P0]`
**Say this first (~60 sec):**
> "Hi, I'm Kurt. I'm a full-stack engineer with about eight years of experience. I started on the backend and data side, and now I build React and TypeScript frontends on top of my own APIs.
>
> At **Boston Energy Trading** I work on three products. On **Watt**, our AI platform, I built the React apps for Data Validation and Ask Data, and the streaming chat API that our shared chat UI runs on. On **Jupiter**, our Load Deal app, I built the PnL engine and API, and the AI assistant's chat page. It saves the trading desk **three hours a day**. On our **Asset Management Platform** I built dashboard and outage features, and cut the landing page from about **10 seconds to 5**.
>
> Before that I spent five years on **Wayfair's** data platform, where I also built Backstage plugins in TypeScript. And I started at **Cerner**, building healthcare UI.
>
> I want a full-stack role because I enjoy owning the whole feature, from the data to what the user sees."

**If they dig deeper:**
- Slow down on the numbers: 3 hours a day, 10 to 5 seconds.
- Stop after "what the user sees." Let them pick the thread.
- Keep AI to one sentence unless the role is AI-related. `[fill in: does this role involve AI?]`

**Your angle:** [S14](../AI%20Engineer/13-Behavioral-Story-Bank.md#s14), [S8](../AI%20Engineer/13-Behavioral-Story-Bank.md#s8), [S3](../AI%20Engineer/13-Behavioral-Story-Bank.md#s3).
**Likely follow-ups:** "Tell me about the AMP UI" (Q3) · "How much React have you written?" (Q2) · "Walk me through Jupiter" ([06](06-Jupiter-Load-Deal-Deep-Dive.md)).

---

### Q2. Are you more frontend or backend? How strong is your React?  `[P0]`
**Say this first (~30 sec):**
> "My background is backend, and that's still my deepest skill. But this year most of my commits have been React and TypeScript. On our AI platform I built the Data Validation app and the Ask Data app, with React 19, Vite and Tailwind, and I wrote about two-thirds of the platform's UI test files. On Jupiter I built the AI chat page and the live PnL views. So I'm a full-stack engineer whose backend side is stronger. I'm working to close that gap."

**If they dig deeper:**
- Give one concrete React detail only a builder knows. `[fill in: pick one, e.g., how the Ask AI page polls a job and renders SQL, tables and charts; how PDF citation highlighting works; how the daylight-saving bug showed up in charts and Excel]`
- Your stack: React 18/19, TypeScript, Vite (and Create React App on AMP), Tailwind, React Router, hooks and Context (**no Redux**), AG Grid, Recharts / ECharts / Vega-Lite, MSAL, Vitest + Testing Library.
- If asked "why no state library?": server data lives in the API and is fetched per page. Shared client state is small (the user, permissions, theme), so Context is enough. `[fill in: confirm how Watt apps fetch and cache data]`
- If asked to rate yourself, say a number and a reason: "About 7 out of 10 on React. Strong on hooks, data-heavy pages, typed APIs and testing. Less experience with SSR, Next.js and design systems."

**Your angle:** [S3](../AI%20Engineer/13-Behavioral-Story-Bank.md#s3), [S1](../AI%20Engineer/13-Behavioral-Story-Bank.md#s1), [S14](../AI%20Engineer/13-Behavioral-Story-Bank.md#s14).
**Likely follow-ups:** a React knowledge check ([03](03-React-Fundamentals.md)) · "What would you need to ramp up on?"

---

### Q3. Walk me through a feature you built end to end, from database to UI.  `[P0]`
**Say this first (~30 sec):**
> "The Ask AI feature on Jupiter. Traders wanted to ask questions about load deals in plain English. I built every layer. The agents use Snowflake Cortex with a semantic view, and LangGraph with citation checks. A job API takes each question, with rate limits, a read-only database role and cost tracking per turn. The React chat page sends the question, polls the job, and shows the answer as SQL, a table and a chart, with conversation history. The hard part was `[fill in: e.g., slow answers, so the job + polling design; or rendering many answer types]`. I built it in three weeks."

**If they dig deeper:**
- Use this order: problem → data → API → UI → hard part → result.
- **Why a job and polling, not one long request?** Answers can take `[fill in: seconds]`. A job gives retries, rate limits, cost logging and a clean "still working" state in the UI. On Watt you later used SSE streaming for chat. Be ready to compare the two ([05](05-Frontend-System-Design.md)).
- **Backup example:** the Watt admin cost page. You wrote the cost APIs and a shared admin-kit package, and 3 apps now use the same page.
- Mention loading and error states, and how you tested it (Vitest + Testing Library).

**Your angle:** [S1](../AI%20Engineer/13-Behavioral-Story-Bank.md#s1), [S3](../AI%20Engineer/13-Behavioral-Story-Bank.md#s3).
**Likely follow-ups:** "How did you manage state on that page?" · "How did you test it?" · "What would you change?"

---

### Q4. Why a full-stack role? Why this company?  `[P0]`
**Say this first (~30 sec):**
> "I already work across the stack, and the work I enjoy most is owning a feature all the way to the user. On AMP, the users only saw the UI. They didn't care how fast my API was if the page still felt slow. I want a role where that whole path is my job. And `[fill in: one specific reason about this company or team]`."

**If they dig deeper:**
- `[fill in: what you know about the company, its product, and the team]`
- Don't say "I want to leave AI" or "I'm tired of backend." Say what you want *more* of.

**Your angle:** [S14](../AI%20Engineer/13-Behavioral-Story-Bank.md#s14).
**Likely follow-ups:** "Why leave after about 16 months?" (Q8) · "Where do you want to be in 3 years?"

---

### Q5. How do you work with frontend engineers and designers?  `[P1]`
**Say this first (~30 sec):**
> "I start with a written contract. For Watt, I wrote specs with the API shape, the permission rules and the edge cases, so the frontend engineers could build without waiting for me. When my manager left, I led a frontend engineer and two other contractors day to day. Every evening I wrote down what to build next and what 'done' meant, and every day I reviewed their PRs."

**If they dig deeper:**
- What was in a spec: endpoints, request and response types, error cases, loading states, permission rules. `[fill in: one real spec section]`
- How you handled a spec change mid-build. `[fill in]`

**Your angle:** [S3](../AI%20Engineer/13-Behavioral-Story-Bank.md#s3), [M1](../AI%20Engineer/13-Behavioral-Story-Bank.md#m1).
**Likely follow-ups:** "Give an example of a disagreement with a frontend engineer." `[fill in: C1]`

---

### Q6. Tell me about a time you made something faster for users.  `[P1]`
**Say this first (~30 sec):**
> "The AMP landing page took about 10 seconds. I measured first. Most of the time was on the server: too many Snowflake reads and slow permission checks. I precomputed results into Redis, ran independent calls in parallel, and cut Snowflake reads from 13 to 3. I also fixed the entitlement service, which went from 3–6 seconds to about 10 milliseconds. The page went to 5 seconds."

**If they dig deeper:**
- Say clearly that it was mostly backend work. Then add what you'd also do on the frontend today: skeleton screens, code splitting, caching with TanStack Query, and measuring with Core Web Vitals.
- `[fill in: any frontend change you made, e.g., fewer requests, lazy loading]`

**Your angle:** [S14](../AI%20Engineer/13-Behavioral-Story-Bank.md#s14), [S9](../AI%20Engineer/13-Behavioral-Story-Bank.md#s9).
**Likely follow-ups:** "How did you measure it?" · "What's the slowest part now?"

---

### Q7. Have you used Next.js / Redux / GraphQL / a design system?  `[P1]`
**Say this first (~30 sec):**
> "Not in production. `[fill in: what you did use]`. I know the trade-offs: `[one line on the tool]`. I've picked up new tools quickly before. For example, I built Load Deal AI with LangGraph and Snowflake Cortex in three weeks."

**If they dig deeper:**
- Use this pattern for any tool you haven't used: **honest "no" → what you used instead → the trade-off → how you'd ramp up.**
- One-line trade-offs are in [03](03-React-Fundamentals.md) and [05](05-Frontend-System-Design.md).

**Your angle:** [S1](../AI%20Engineer/13-Behavioral-Story-Bank.md#s1) (fast learning).
**Likely follow-ups:** "How would you learn it in your first month?"

---

### Q8. Why are you leaving after about 16 months?  `[P1]`
**Say this first (~30 sec):**
> `[fill in: your real reason, said positively]`. A safe shape: "I've learned a lot. I own big systems and I've shipped real impact. But I'm on a very small team, so I've hit the limit of what one person can do. I want to grow on a stronger engineering team, with more frontend work."

**If they dig deeper:**
- Never criticize BETM or your manager.
- If your manager's resignation is part of the reason, say it neutrally: "My manager left, and that changed the team."

**Your angle:** [S14](../AI%20Engineer/13-Behavioral-Story-Bank.md#s14), [M1](../AI%20Engineer/13-Behavioral-Story-Bank.md#m1).
**Likely follow-ups:** "What are you looking for in your next team?"

## References
- [Behavioral Story Bank](../AI%20Engineer/13-Behavioral-Story-Bank.md): the full STAR stories behind every "Your angle" link.
- [AI Engineer guide, 01 · Role & Pitch](../AI%20Engineer/01-Role-Company-and-Your-Pitch.md): the longer pitch and the honest framing of gaps.
- [AI Engineer guide, 15 · Self-introduction](../AI%20Engineer/15-Final-Day-Cheat-Sheet.md): the AI version of the pitch, with delivery tips that also apply here.
