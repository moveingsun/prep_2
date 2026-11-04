# 07 · Watt (AI Platform) Deep Dive

[← Index](00-Index.md) · **Interview priority:** High · **Read time:** ~25 min, then draw it and say it out loud

> **Why this matters for this role:** Watt is a frontend-architecture story: one shell, many apps, one sign-in, and permissions that reach individual buttons. Full-stack interviewers like to dig into exactly this: how apps are loaded, how the UI knows what to show, and why hiding a button is not security. Watt is also where you wrote the most React this year, so it's your best place to show frontend depth.

**Status:** this page has the facts from your resume, the story bank and the company-session reply #1. Fill the remaining `[fill in]` gaps from reply #2.

## Primer

### Who built what (from git history)
- **You, backend:** the entitlements-driven **app registry**, **signed short-lived bundle links**, **UI-element-level permissions** and **API-gateway routing**. You also built the **chat API contract with SSE streaming over Redis**, the cost endpoints, permission caching for entitlement changes, and per-user warehouse tokens. You wrote the specs ([S3](../AI%20Engineer/13-Behavioral-Story-Bank.md#s3)).
- **You, frontend** (about 239 commits across 4 UI repos, Aug–Nov 2026):
  - **Data Validation UI**: rules, run history, monitors, chat pages
  - **Ask Data UI**: you created it
  - **Ask Knowledge UI**, part of it: uploads, PDF citation highlighting
  - **In the shell**: the Admin tab, plus a shared **admin-kit** package that 3 apps use for one cost-reporting page
  - **68 of the 102** UI test files
- **A frontend engineer:** the shell itself (scaffold, sign-in, sidebar, the entitlement-driven app list, health panel, Users & access), the shared **chat-kit** and **ui-kit** packages, and most of Ask Knowledge. chat-kit runs on **your** chat API contract.
- **How to say it:** "I built the platform backend and the chat API, and I built two of the apps on it, Data Validation and Ask Data, plus the admin package. A frontend engineer built the shell and the shared chat and UI kits."

### Frontend stack
React 19, TypeScript, Vite 8, Tailwind 4, React Router, MSAL sign-in, hooks and Context (no state library), Recharts, Vega-Lite, Vitest + Testing Library, Datadog RUM.

### Facts you can use
- Watt is BETM's **AI platform**: a **micro-frontend host**, one sign-in front door for AI apps such as Data Validation, Data Intelligence (Ask Data?) and Doc Intelligence (Ask Knowledge?). `[confirm the app names]`
- It uses the shared entitlements service: **3–6s → ~10ms**, fail-closed ([S9](../AI%20Engineer/13-Behavioral-Story-Bank.md#s9)).
- Data Intelligence cost queries went **85.6s → 8.8s** ([S4](../AI%20Engineer/13-Behavioral-Story-Bank.md#s4)).
- Results: `[fill in: number of apps onboarded, time to add a new app, users]`

### How it probably works (confirm every step from the reply)

```
 User signs in (MSAL)
        │
 Watt shell (React 19)
        │ 1. GET my apps
 App registry ── entitlements
        │ 2. list of allowed apps,
        │    each with a signed link
        │    that expires soon
 Shell loads the app bundle
  [fill in: dynamic import?
   Module Federation? iframe?]
        │ 3. app calls its API
 API gateway ── routes to app API
        │        (checks the token
        │         and permissions)
 App backends
```

1. The user signs in once. The shell asks the **registry**: "Which apps can this user use?"
2. The registry checks **entitlements** and returns only allowed apps. Each app comes with a **signed link to its frontend bundle that expires soon**. A user without access never even downloads that app's code. `[confirm]`
3. The shell loads the bundle and mounts the app. `[fill in: how]`
4. Inside an app, **UI-element permissions** decide which buttons, tabs or fields to show. `[fill in: how the UI gets them]`
5. Every API call goes through the **gateway**, and **the server checks permissions again**. The UI hides things for a clean screen. The server is the real security.

### The 2-minute walkthrough (use this order)
1. **Problem** (15 sec): each AI app needed its own sign-in and permission logic. Users and developers both paid for that.
2. **Architecture** (30 sec): draw the diagram above.
3. **One request, end to end** (30 sec): "A trader opens Watt and clicks Data Intelligence." Registry → signed link → bundle → app → gateway → API.
4. **One hard decision** (20 sec): why signed short-lived links, or why permissions down to UI elements.
5. **Result** (10 sec): `[fill in]`
6. **What you'd change** (15 sec): see Q11.

## Questions & answers

### Q1. What is Watt, and why did BETM need it?  `[P0]`
**Say this first (~30 sec):**
> "Watt is our AI platform: one front door for all our AI apps, like Data Validation, Ask Data and Ask Knowledge. Before Watt, `[fill in: each app had its own login and permission logic?]`. With Watt, users sign in once and see only the apps and features they're allowed to use. For developers, a new app plugs into the shell instead of rebuilding sign-in, navigation and permissions. I built the platform backend and the streaming chat API, and I built two of the apps on it in React."

**Your angle:** [S3](../AI%20Engineer/13-Behavioral-Story-Bank.md#s3).
**Likely follow-ups:** "How many apps are on it?" `[fill in]` · "Walk me through the architecture." (Q2)

---

### Q2. Walk me through the architecture.  `[P0]`
**Say this first (~30 sec):**
> "There are four parts. A React shell, which handles sign-in, navigation and layout. An app registry, which knows every app and, using entitlements, which user can use which app. Signed, short-lived links to each app's frontend bundle, so the shell can load only the apps you're allowed to see. And an API gateway that routes each app's API calls and checks permissions on the server."

**If they dig deeper:**
- Draw the diagram from the Primer.
- Frontend stack: React 19, TypeScript, Vite 8, Tailwind 4, React Router, MSAL, Vitest. `[fill in: gateway product, where bundles are stored]`
- Then go one level down into an app you built: "Inside Data Validation there are four areas: rules, run history, monitors and chat." `[fill in: how its pages, routes and data fetching are organized]`

**Your angle:** [S3](../AI%20Engineer/13-Behavioral-Story-Bank.md#s3), [S9](../AI%20Engineer/13-Behavioral-Story-Bank.md#s9).
**Likely follow-ups:** "Why not one big React app?" (Q4) · "How do you add a new app?" (Q3)

---

### Q3. How does the app registry work? How do you add a new app?  `[P0]`
**Say this first (~30 sec):**
> "Each app has an entry in the registry: `[fill in: e.g., ID, name, icon, route, bundle location, required entitlement, API route]`. When a user opens Watt, the shell asks the registry for the user's apps. The registry filters by entitlements and returns only the allowed ones. To add an app, a team `[fill in: builds its bundle, uploads it, adds a registry entry and an entitlement]`. It takes about `[fill in]`."

**If they dig deeper:**
- Where the registry data lives, and how it's cached: `[fill in]`
- How a new app version is released, and how to roll back: `[fill in]`

**Your angle:** [S3](../AI%20Engineer/13-Behavioral-Story-Bank.md#s3).
**Likely follow-ups:** "What if two apps need different React versions?" (Q4)

---

### Q4. Why signed short-lived bundle links? Why not one big app, or micro-frontends?  `[P0]`
**Say this first (~30 sec):**
> "We wanted two things: users should never download code for an app they can't use, and each app should ship on its own. A signed link that expires in `[fill in: minutes]` means the bundle URL can't be shared or reused later. One big React app would be simpler, but every user would download every app, and every team would have to release together. `[fill in: what you compared, e.g., iframes or Module Federation, and why you chose this]`."

**If they dig deeper:**
- **One app (monorepo):** simplest, shared state is easy. But one release train, and every user gets all the code.
- **iframes:** strong isolation. But hard to share sign-in, styling and navigation, and slower.
- **Module Federation / dynamic import of remote bundles:** independent releases and shared libraries. But more build and version complexity.
- Know which one Watt uses and say why. `[fill in]`

**Your angle:** [S3](../AI%20Engineer/13-Behavioral-Story-Bank.md#s3).
**Likely follow-ups:** "What happens if a link expires while the user is working?" (Q13) · "How do apps share React and the design system?"

---

### Q5. How do UI-element permissions work? Isn't hiding a button insecure?  `[P0]`
**Say this first (~30 sec):**
> "Hiding a button is not security, and we don't treat it as security. The server checks every API call. UI permissions are for the user: they show only what someone can do, so there are no buttons that always fail. The shell gets the user's permissions `[fill in: at sign-in? per app?]`, and components check them, for example `[fill in: a <Can permission='…'> wrapper or a usePermission hook]`."

**If they dig deeper:**
- A typed permission check in React is a clean answer if they ask for code: a `usePermission('deal.edit')` hook that reads from context.
- Entitlement checks are fast (about 10 ms) because of the Redis-first design ([S9](../AI%20Engineer/13-Behavioral-Story-Bank.md#s9)).
- Fail closed: if permissions can't load, show nothing extra, rather than everything.

**Your angle:** [S3](../AI%20Engineer/13-Behavioral-Story-Bank.md#s3), [S9](../AI%20Engineer/13-Behavioral-Story-Bank.md#s9).
**Likely follow-ups:** "How do permission changes reach a user who is already logged in?" (Q13)

---

### Q6. How does sign-in and auth work?  `[P1]`
**Say this first (~30 sec):**
> "Users sign in through MSAL in the shell `[confirm: with Entra ID]`. The shell gets a token and sends it with every API call. The gateway validates the token and routes the call. The app's backend checks entitlements again. Apps inside the shell don't handle sign-in themselves. They get the user and token from the shell."

**If they dig deeper:**
- Where the token is stored, and how it's refreshed: `[fill in]`
- How an app gets the token from the shell: `[fill in: React context? a shared SDK?]`

**Your angle:** [S3](../AI%20Engineer/13-Behavioral-Story-Bank.md#s3).
**Likely follow-ups:** "Why not store the token in localStorage?" ([05](05-Frontend-System-Design.md))

---

### Q7. You wrote the specs the frontend engineers built from. What was in them?  `[P0]`
**Say this first (~30 sec):**
> "Each spec had the goal, the API contract with request and response shapes, the permission rules, the error cases, and what 'done' looks like. `[fill in: one real example, e.g., the registry response shape]`. Writing it down meant the frontend engineers could build without waiting for me, even across time zones."

**If they dig deeper:**
- How you handled a spec change in the middle of the work: `[fill in]`
- How you reviewed their work: `[fill in]`

**Your angle:** [S3](../AI%20Engineer/13-Behavioral-Story-Bank.md#s3), [M1](../AI%20Engineer/13-Behavioral-Story-Bank.md#m1).
**Likely follow-ups:** "What did you get wrong in the spec?" `[fill in]`

---

### Q8. How did you make it fast?  `[P1]`
**Say this first (~30 sec):**
> "The biggest problem was permission checks. The shared entitlements service took 3–6 seconds, because of N+1 lookups. I removed them, added indexes, and made it Redis-first. Now a check takes about 10 milliseconds, for Watt and for AMP, Load Deal and Mobile too. On the frontend, `[fill in: lazy loading of app bundles, caching the registry response]`."

**Your angle:** [S9](../AI%20Engineer/13-Behavioral-Story-Bank.md#s9).
**Likely follow-ups:** "How do you invalidate the Redis cache when permissions change?"

---

### Q9. Do the AI apps share UI components, like the chat window?  `[P0]`
**Say this first (~30 sec):**
> "Yes, there are three shared packages. **ui-kit** has the common components. **chat-kit** is the chat window every app uses. It streams answers over SSE, and it runs on the chat API contract I designed. **admin-kit** is mine: it gives 3 apps the same cost-reporting admin page, on top of cost APIs I wrote. So a new AI app gets chat, admin and styling for free."

**If they dig deeper:**
- **The chat contract (yours):** `[fill in: the event types, e.g., token, citation, done, error; how a message ID ties events together; why Redis sits between the agent and the SSE endpoint]`
- **Why SSE and not WebSockets:** the server pushes and the client only sends new questions, so one-way streaming is enough. SSE works over plain HTTP and reconnects on its own. ([05](05-Frontend-System-Design.md))
- **How packages are shared:** `[fill in: a monorepo workspace? a private npm registry? how versions are managed]`
- **Designing a shared package:** a small, typed API (props and hooks), no app-specific logic, and its own tests.

**Your angle:** [S1](../AI%20Engineer/13-Behavioral-Story-Bank.md#s1), [S3](../AI%20Engineer/13-Behavioral-Story-Bank.md#s3).
**Likely follow-ups:** "How would you design a shared chat component?" ([05](05-Frontend-System-Design.md)) · "How do you release a breaking change to chat-kit?"

---

### Q10. Walk me through an app you built on Watt: Data Validation.  `[P0]`
**Say this first (~30 sec):**
> "Data Validation checks our data pipelines' outputs against their sources and flags mismatches. I built the backend solo, and I built the React app on Watt. It has four areas. Rules, where users define checks. Run history, to see each run's results. Monitors, for scheduled checks. And chat pages `[fill in: what users ask there]`. An LLM judge separates timing races from real defects, and nothing is written without a person confirming."

**If they dig deeper:**
- How the rules form handles validation and errors: `[fill in]`
- How run history handles many runs: `[fill in: paging? filters?]`
- What your tests cover. You wrote 68 of the platform's 102 UI test files. `[fill in: examples]`

**Your angle:** [S2](../AI%20Engineer/13-Behavioral-Story-Bank.md#s2).
**Likely follow-ups:** "How does the UI show that a human must confirm?" · "What did users find confusing?"

---

### Q11. What would you change if you built it again?  `[P0]`
**Say this first (~30 sec):**
> "`[fill in: your real answer]`. Good candidates: a typed SDK that apps use to get the user, token and permissions from the shell; contract tests between the shell and the apps; `[fill in]`."

**Likely follow-ups:** "Why didn't you do that the first time?"

---

### Q12. How do you version the contract between the shell and the apps?  `[P2]`
**Say this first (~30 sec):**
> "`[fill in]`. A good answer: the shell exposes a small, versioned interface to apps, for example the user, the token, permissions and navigation. Apps say which version they need in the registry. The shell supports the current and previous version during a migration."

---

### Q13. What can go wrong, and how does Watt handle it?  `[P1]`
**Say this first (~30 sec):**
> "Three cases. If the registry is down, `[fill in: the shell shows a clear error and retries]`. If a bundle link expires while the user is working, `[fill in: the shell asks for a fresh link]`. If someone's permissions change while they are logged in, `[fill in: refresh on the next call or on a timer]`. In every case the server still checks, so the worst result is a confusing screen, not a data leak."

**Your angle:** [S9](../AI%20Engineer/13-Behavioral-Story-Bank.md#s9) (fail-closed).
**Likely follow-ups:** "How do you know when these failures happen?" (monitoring) `[fill in]`

## References
- [Story bank: S3 · Watt specs](../AI%20Engineer/13-Behavioral-Story-Bank.md#s3)
- [Story bank: S9 · Entitlements service](../AI%20Engineer/13-Behavioral-Story-Bank.md#s9)
- [Story bank: S4 · Data Intelligence](../AI%20Engineer/13-Behavioral-Story-Bank.md#s4)
- [05 · Full-Stack & Frontend System Design](05-Frontend-System-Design.md): the app-shell, auth and AI-chat scenarios.
