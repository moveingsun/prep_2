# 07 · Watt (AI Platform) Deep Dive

[← Index](00-Index.md) · **Interview priority:** High · **Read time:** ~35 min, then draw it and say it out loud

> **Why this matters for this role:** Watt is a frontend-architecture story: one shell, many apps, one sign-in, and permissions sent down to the UI. Full-stack interviewers like to dig into exactly this: how apps are loaded, how the UI knows what to show, and why hiding a button is not security. It also has your strongest full-stack story: the streaming chat API that every chat app uses.

**Status:** filled from the company-session replies of Nov 3 and Nov 4 (code, git history and design docs). A few `[confirm]`s remain. Message #4 to the company session asks about them.

## Primer

### Who built what (from git history)
- **You, backend:**
  - the **app registry** in the entitlements service, and its design doc (12 commits)
  - the **signed bundle links** (the signing service)
  - the server side of **UI-element permissions** (sorting them per app)
  - most of the **gateway policies** for the app APIs, and backend auth
  - the **chat library**: SSE streaming over a Redis log (33 commits)
  - the per-app token scope and **on-behalf-of token exchange** for Ask Data
  - the app backends, and the cost endpoints
- **You, frontend** (about 239 commits across 4 UI repos, Aug–Nov 2026):
  - **Data Validation UI**, mostly yours
  - **Ask Data UI**: you created it
  - part of **Ask Knowledge**: uploads, PDF citation highlighting
  - the **admin-kit** package (13 commits), used by 3 apps
  - a fix in the shell's admin sections (expired links)
  - **68 of the 102** UI test files
- **Another engineer:**
  - the **shell**: loader, sign-in, app list, failure screens, health checks, Users & access
  - **ui-kit**
  - most of **chat-kit** (10 commits to your 5)
- **Both:** the shell contract, the package pipeline, the entitlements gateway policy.
- **How to say it:** "I built the platform's backend: the app registry, the signed bundle links and the permission rules. I also built the streaming chat library our chat apps use. On the frontend I built Data Validation and Ask Data, and the admin package. Another engineer built the shell, ui-kit and most of chat-kit."

### Frontend stack
React 19, TypeScript, Vite 8, Tailwind 4, React Router, MSAL (Microsoft Entra sign-in), hooks and Context (no state library), Recharts, Vega-Lite, Vitest + Testing Library, Datadog RUM.

### Facts you can use
- **4 apps** are on Watt: Doc Intelligence, Data Intelligence (Ask Data), Data Validation and Memory. `[confirm: Doc Intelligence = the Ask Knowledge UI?]`
- **Users:** a dev/stage script grants 6 users. The production count is unknown. **Don't guess a number.** Say "an internal platform for `[fill in: which teams]`".
- **Before Watt:** the app list was a file built into the shell. Every signed-in user saw every app, and the app bundles could be downloaded **without signing in**.
- **Goal** (from your registry design doc): a user sees exactly the apps their AI role grants.
- **Chat library:** 3 apps adopted it the day after it shipped. Jupiter followed a week later.
- **AI turns take 2–5 minutes** (measured: 136–336 seconds).
- Entitlement checks: **3–6 s → ~10 ms**, fail-closed ([S9](../AI%20Engineer/13-Behavioral-Story-Bank.md#s9)).
- Data Intelligence cost queries: **85.6 s → 8.8 s** ([S4](../AI%20Engineer/13-Behavioral-Story-Bank.md#s4)).

### Architecture

```
Browser: Watt shell (React, MSAL)
  | 1. app list + signed links
  v
API gateway (Azure APIM)
  |--> Entitlements svc (Redis, SQL)
  |--> App APIs (FastAPI on AKS)
         |--> Redis turn log
         |--> each app's own stores
Blob store: versioned mount.js
  ^ 2. shell import()s the bundle
```

1. The shell signs the user in with **Microsoft Entra** (MSAL).
2. It asks the **entitlements service**, through the gateway, for the user's apps.
3. The service checks the token, reads the user's grants from **Redis or SQL**, and returns only the allowed apps. Each app comes with a **signed link to its bundle that lasts 5 minutes**, plus its UI elements.
4. The shell checks the link's host, then **`import()`s the bundle** and calls `mount(container, host)`. The app renders in its own **shadow root**, with its own CSS.
5. The app calls **its own FastAPI backend** through the gateway, with a token it gets from the shell. The gateway checks the token, and **the backend checks it again**.
6. In the background, a job runs **every 5 minutes** and points each app at its newest published version.

### The 2-minute walkthrough (use this order)
1. **Problem** (15 sec): every user saw every app, and the app code was public. Each app also had to solve sign-in and layout again.
2. **Architecture** (30 sec): draw the diagram.
3. **One request** (30 sec): "A user opens Watt and clicks Data Validation." Sign-in → app list → signed link → `import()` → `mount` → API call through the gateway.
4. **One hard problem** (30 sec): long AI answers against a gateway that cuts every request (Q11).
5. **Result** (10 sec): 4 apps on one shell. A new app needs no shell change. 3 apps adopted the chat library the next day.
6. **What you'd change** (15 sec): see Q14.

## Questions & answers

### Q1. What is Watt, and why did BETM need it?  `[P0]`
**Say this first (~30 sec):**
> "Watt is the one front door for our AI apps. Before it, the app list was a file built into the shell. Every signed-in user saw every app, and the app code could be downloaded without signing in. Now the shell signs you in once and shows only the apps your role grants. It also owns navigation, theme and telemetry, so each app team only builds its own screens. Four apps are on it today. I built the platform's backend and the streaming chat library, and two of the apps."

**If they dig deeper:**
- The 4 apps: Doc Intelligence, Data Intelligence (Ask Data), Data Validation and Memory.
- Users: be honest. "It's internal. I don't have a production user count I'd trust."

**Your angle:** [S3](../AI%20Engineer/13-Behavioral-Story-Bank.md#s3).
**Likely follow-ups:** "Walk me through the architecture." (Q2) · "How do you add an app?" (Q3)

---

### Q2. Walk me through the architecture.  `[P0]`
**Say this first (~30 sec):**
> "The browser loads the shell, which signs in with Microsoft Entra. It calls our entitlements service through Azure API Management. That service checks the token, reads the user's grants from Redis or SQL, and returns the app list, with a short-lived signed link to each app's bundle. The shell imports the bundle from blob storage and mounts it. Each app then calls its own FastAPI backend through the same gateway."

**If they dig deeper:**
- Draw the diagram from the Primer.
- **Each app has its own API path** on the gateway, under one product.
- **Backends run on AKS.** Chat apps share a **Redis turn log** (Q11).
- **Inside one app:** Data Validation has Create Rule and Diagnose chat pages, Run history, Monitors, Capabilities, and an admin bundle (Q10).

**Your angle:** [S3](../AI%20Engineer/13-Behavioral-Story-Bank.md#s3), [S9](../AI%20Engineer/13-Behavioral-Story-Bank.md#s9).
**Likely follow-ups:** "Why not one big React app?" (Q4) · "How do you add a new app?" (Q3)

---

### Q3. How does the app registry work? How do you add a new app?  `[P0]`
**Say this first (~30 sec):**
> "Each entry has a slug, label, icon, bundle link, API base URL, description, version, privilege, link expiry, UI elements and an optional admin entry. Static data lives in the service config. The live version is a database column that only one sync route writes. Access is one permission per app, granted to roles and cached in Redis. To add an app, you build its bundle, publish it to a versioned folder, add a config entry, create and grant the permission, and add its API to the gateway. The shell needs no change."

**If they dig deeper:**
- **The bundle contract:** contract version 1. The bundle exports `meta` and `mount`, plus an optional `admin.js`.
- **Releases:** bundles go to semver folders. The pipeline **refuses to overwrite** an existing version. A job runs the sync route every 5 minutes, and it points each app at its newest version.
- **Rollback:** `[confirm: re-point the version, or publish a new patch?]`
- **An app that isn't fully configured returns 503**, never a half-built entry. That's your rule.
- This replaced a registry file built into the shell, where every user got every app.

**Your angle:** [S3](../AI%20Engineer/13-Behavioral-Story-Bank.md#s3). You wrote the design doc and the server side. Another engineer built the shell's registry code.
**Likely follow-ups:** "How long does it take to add an app?" `[fill in]` · "What if two apps need different React versions?" (Q4)

---

### Q4. How does the shell load an app? Why not Module Federation or iframes?  `[P0]`
**Say this first (~30 sec):**
> "The entitlements service signs each link with an Azure user-delegation SAS, using its own managed identity, so there's no storage key. Each link is read-only, for one file, and lasts 5 minutes. The shell checks the link's host against an allow list, preloads it, and does a plain dynamic import of that URL. Then it calls `mount` with a container and a host object. The app renders in its own shadow root. There's no Module Federation and no iframe. It's one ES module with a two-function contract."

**If they dig deeper:**
- **Why this choice:** apps don't share build config, each app ships on its own, and the shadow root keeps CSS apart. **The docs don't record a formal comparison**, so say "we chose it for simplicity". Don't claim you compared the options.
- **Link details:** expiry is configurable from 1 to 60 minutes, and a link never outlives the 12-hour delegation key. The **admin bundle is signed only for admins**.
- **Bundles:** gzipped, cached as immutable for a year.
- **The options, if they ask:**
  - **One big app:** simplest. But one release for everyone, and every user downloads every app.
  - **iframes:** strongest isolation. But sign-in, theme and navigation are hard to share, and it's heavier.
  - **Module Federation:** can share libraries such as React. But all apps need matching build setups.
  - **`import()` of a URL (Watt):** simple and independent. Each bundle may carry its own copy of React. `[confirm]`
- **How you'd write the loader in an interview** (a sketch, not the real code):

```ts
const ORIGIN = 'https://bundles.example.net';

async function loadApp(
  entryUrl: string,
  el: HTMLElement,
  host: Host,
) {
  // Compare origins. startsWith() can be
  // fooled by look-alike hosts.
  if (new URL(entryUrl).origin !== ORIGIN) {
    throw new Error('Untrusted bundle host');
  }
  const mod: AppModule = await import(
    /* @vite-ignore */ entryUrl
  );
  mod.mount(el, host);
}
```

- **Two details to know:** `import()` fetches modules with CORS, so the storage must allow the shell's origin. And `/* @vite-ignore */` tells Vite the URL is only known at run time.

**Your angle:** [S3](../AI%20Engineer/13-Behavioral-Story-Bank.md#s3). You built the signing side. Another engineer built the loader.
**Likely follow-ups:** "What if a link expires while the user works?" (Q13) · "Do the apps share React?" `[confirm]`

---

### Q5. How do UI-element permissions work? Isn't hiding a button insecure?  `[P0]`
**Say this first (~30 sec):**
> "Hiding a button is not security. The server is the real check. UI permissions come in the same call as the app list. My server code sorts them. A path like /app-slug means access to the app. /app-slug/something goes into that app's own list. Anything else is a shell element, like the Admin tab, with a privilege level. The shell drops any entry it can't parse, so it fails closed. Small helpers then decide things like whether to show the Admin tab."

**If they dig deeper:**
- Each app gets **a snapshot of its list** when it mounts.
- **Honest gap:** no app reads its list yet. Today the shell uses these permissions (Admin tab, super admin, which apps you can manage). Say "the plumbing is there; the apps don't use it yet."
- **On the server:** every backend checks the token. Admin routes also re-check entitlements, with a 5-minute cache per user. A permission change must be allowed for **every domain** it touches.
- If they ask for code, a typed hook is a clean answer:

```ts
function useUiElement(name: string) {
  const { uiElements } = useHost();
  return uiElements.includes(name);
}
```

**Your angle:** [S3](../AI%20Engineer/13-Behavioral-Story-Bank.md#s3), [S9](../AI%20Engineer/13-Behavioral-Story-Bank.md#s9).
**Likely follow-ups:** "If I have a token but no access to an app, can I call its API?" `[confirm: does every data route re-check app access?]` · "How does a change reach a user who is already signed in?" (Q13)

---

### Q6. How does sign-in work, and how do apps get the token?  `[P0]`
**Say this first (~30 sec):**
> "We use Microsoft Entra through MSAL, with the redirect flow. Tokens live in session storage, so the session ends when the browser closes. A new tab tries a silent sign-in. Tokens refresh with a silent call, and fall back to a redirect. Child apps never touch MSAL. The shell passes them a host object with the user and a `getAuthToken` function. There's also a 22-hour session limit, with a warning 10 minutes before."

**If they dig deeper:**
- **The host object:** user, `getAuthToken(scopes)`, API base URL, gateway key, UI elements, theme, route and telemetry.
- **Ask Data asks for its own token scope.** Its backend swaps the user's token for a warehouse token for that user (on-behalf-of). You built that.
- **Local storage was tried and reverted.** It gave sign-in across tabs. `[fill in: why it was reverted]`
- **The 22-hour clock** is in local storage, so all tabs agree. The code says it's a convenience rule, not a security boundary.
- **"Isn't the gateway key in the browser a secret?"** No. In a browser app it can't be secret. It tells the gateway which product the call belongs to. The real check is the token, at the gateway and in every backend.

**Your angle:** [S3](../AI%20Engineer/13-Behavioral-Story-Bank.md#s3). Another engineer built shell sign-in. The contract was shared. The per-app scope and token exchange were yours.
**Likely follow-ups:** "Why not local storage?" · "Would you use a BFF?" ([05](05-Frontend-System-Design.md))

---

### Q7. You wrote the design docs. What was in them?  `[P0]`
**Say this first (~30 sec):**
> "The registry design doc started with one goal: a user sees exactly the apps their role grants. Then the entry fields, how access is granted and cached, and the error rules. For example: an app that isn't fully configured returns 503, never a half-built entry. For the chat contract, the Python library exports JSON Schemas, and chat-kit's TypeScript types are generated from them. So the frontend and backend share one source of truth."

**If they dig deeper:**
- A written contract let the frontend engineer build without waiting for you.
- How you handled a spec change mid-build: `[fill in]`
- How you reviewed their work: `[fill in]`

**Your angle:** [S3](../AI%20Engineer/13-Behavioral-Story-Bank.md#s3), [M1](../AI%20Engineer/13-Behavioral-Story-Bank.md#m1).
**Likely follow-ups:** "What did you get wrong in the spec?" `[fill in]`

---

### Q8. How did you make it fast?  `[P1]`
**Say this first (~30 sec):**
> "The biggest win was permission checks. The shared entitlements service took 3 to 6 seconds, because of N+1 lookups. I removed them, added indexes, and made it Redis-first. Now a check takes about 10 milliseconds. On the frontend, the browser only gets code for the apps you're allowed to use, through dynamic import. Bundles are gzipped, cached as immutable, and preloaded."

**If they dig deeper:**
- Admin routes cache each user's entitlements for 5 minutes.
- App health checks run every 60 seconds, **only while the tab is visible**.

**Your angle:** [S9](../AI%20Engineer/13-Behavioral-Story-Bank.md#s9).
**Likely follow-ups:** "How do you clear the cache when permissions change?" (the admin screen clears that user's server cache; Q13)

---

### Q9. How do the apps share UI code?  `[P0]`
**Say this first (~30 sec):**
> "Three npm packages under a private scope on our Azure Artifacts feed. ui-kit has the header, user menu and environment badge. chat-kit has the chat client, streaming, the chat page and PDF export. admin-kit, which is mine, renders cost reports. One pipeline runs when a merge touches the packages folder. It runs tests, type checks, lint and build, and publishes only if that version isn't on the feed yet. So you release by bumping the version in your PR."

**If they dig deeper:**
- **Versions:** ui-kit 0.1.0, chat-kit 0.1.10, admin-kit 1.1.0, shell contract 1.3.0. Apps use normal semver ranges.
- **A 0.x detail:** `^0.1.10` allows 0.1.x but not 0.2.0. In 0.x, a minor bump counts as breaking.
- **admin-kit** renders a versioned `CostReport` JSON Schema. Every backend serves it from the same admin cost route. The UI computes shares, cost per unit and totals.
- **chat-kit's types** are generated from the JSON Schemas your Python library exports.

**Your angle:** [S1](../AI%20Engineer/13-Behavioral-Story-Bank.md#s1), [S3](../AI%20Engineer/13-Behavioral-Story-Bank.md#s3). ui-kit: another engineer. admin-kit: you. chat-kit: both.
**Likely follow-ups:** "How do you ship a breaking change?" (a major version; apps move when ready) · "Why not a monorepo?"

---

### Q10. Walk me through an app you built: Data Validation.  `[P0]`
**Say this first (~30 sec):**
> "Data Validation checks our pipelines' outputs. It has two chat modes, Create Rule and Diagnose, plus Run history, Monitors for pipelines and datasets, a Capabilities page, and an admin bundle for the shell's Admin tab. The forms check required names, positive freshness values, and filter rows: no duplicates, at most 10. The server checks again with Pydantic and returns 422, for example for a bad cron or an unknown time zone. Run history is paged on the server, 25 at a time, with search, filters and sort."

**If they dig deeper:**
- **Human in the loop:** a chat change needs a confirm step. The server only runs an action that **exactly matches an open proposal**. Otherwise it returns 409.
- **Deleting a dataset still in use** returns 409, naming the suite that uses it.
- **Cost:** each run shows its LLM cost to 4 decimals. A judge call costs about $0.0004.
- **Routing:** a small hash router. `[confirm: so it doesn't fight the shell over the URL path?]`
- **Tests:** 22 UI test files (~124 cases). The service has ~130 test files, and its last run passed 2,295 tests.
- Another engineer moved the chat pages onto chat-kit in October.

**Your angle:** [S2](../AI%20Engineer/13-Behavioral-Story-Bank.md#s2).
**Likely follow-ups:** "How does the UI show that a human must confirm?" · "Why page on the server?"

---

### Q11. How do you stream a 5-minute AI answer through a gateway that cuts every request?  `[P0]`
This is your strongest full-stack story. You built it.

**Say this first (~30 sec):**
> "Our AI turns take 2 to 5 minutes, but the gateway cuts every request at a fixed time, even while data is flowing. So keep-alive pings can't help, and no connection can last a whole turn. I tried plain streaming, then polling a status key. The final design: the turn runs as a background job and writes every event to a Redis log. The client reads it over SSE. Each stream closes on purpose before the limit, and the client resumes from the last event ID. Any replica can serve it."

**If they dig deeper:**
- **Start:** a POST returns the conversation, turn and message IDs at once.
- **Events:** start, status, delta, part, final, error, reconnect, done. Each has a number that counts up within the turn.
- **Windows:** a stream closes at **170 seconds**, under the **180-second gateway limit**, with a `reconnect` event. Pings go every 15 seconds. On dev the window is 30 seconds, to force replica handovers.
  - `[confirm: an early test saw a cut at 61.1 seconds. Before the limit was raised, or another route?]`
  - `[confirm: Jupiter's Ask AI uses 40-second windows. Why?]`
- **Fallbacks:** after 5 failed reconnects, the client polls every 2 seconds. A page refresh or a second tab resumes the running turn.
- **Stop:** a stop call sets a flag in Redis. The runner stops at its next event, saves the partial answer as stopped, then sends final and done.
- **Safety:** keys are hashed. Values are encrypted (AES-GCM) when a secret is set. The log expires after 1 hour. A turn with no heartbeat for 30 seconds ends as lost.
- **Why Redis Streams, not pub/sub:** pub/sub keeps no history, so a reconnecting client would miss events. A stream is an ordered log you can read from any ID.
- **Why SSE, not WebSocket:** the server pushes and the client only asks. SSE is plain HTTP and has event IDs built in. The gateway's response buffering is off so events flow.
- **Adoption:** Ask Data, Doc Intelligence and Data Validation moved to it the next day. Jupiter a week later.

**Your angle:** [S1](../AI%20Engineer/13-Behavioral-Story-Bank.md#s1), [S3](../AI%20Engineer/13-Behavioral-Story-Bank.md#s3).
**Likely follow-ups:**
- "EventSource can't set an Authorization header. How does the client send the token?" `[confirm: EventSource or fetch streaming?]`
- "What if two replicas both run the same turn?"
- "How do you test it?" (Q12)

---

### Q12. Tell me about a production bug in that library.  `[P0]`
**Say this first (~30 sec):**
> "One day, every Jupiter Ask AI turn in production failed at its first event, with 'event log unavailable'. Production uses a geo-replicated Redis. It runs streams in strict ID mode, and it rejected the IDs we were setting. We shipped a hotfix the same day. Then I fixed the library and added a strict-ID fake to the tests, so this mode is now tested."

**If they dig deeper:**
- **Date:** Oct 21, 2026. The error was a 503.
- **Why strict mode exists:** active-active Redis copies data between regions asynchronously, so IDs chosen by clients could clash. Strict mode, the default, rejects full IDs that a client sets ([Redis docs](https://redis.io/docs/latest/operate/rs/databases/active-active/develop/data-types/streams/)).
- **The fix:** `[confirm: Redis now makes the IDs, and the turn's number moves into the event?]`
- **Lesson:** test against the same mode as production, not only a default fake.
- **Two more bugs you fixed:**
  - A repair step could overwrite a turn that had just finished with an empty answer. You made it re-read the store, and now repair only touches turns still running. It's a check-then-act race.
  - Polled events had no IDs, so clients got some events twice. You numbered every event.

**Your angle:** use this for "Tell me about a production incident."
**Likely follow-ups:** "How did you find the cause so fast?" `[fill in]` · "What alert would have caught it earlier?"

---

### Q13. What can go wrong, and how does Watt handle it?  `[P1]`
**Say this first (~30 sec):**
> "If the app list call fails, the shell shows a clear state for each case. A 401 retries sign-in once, then says 'Sign-in required'. A 403 says 'Access denied'. A 503 or a network error says 'Apps unavailable', with Try again. If a bundle link has expired, the shell gets a fresh list once and retries, then shows 'session timed out'. If permissions change, the user sees it on the next reload. The server still checks every call."

**If they dig deeper:**
- **The server never sends an unsigned link.** It returns 503 instead. That's your rule.
- **Health checks:** every 60 seconds while the tab is visible, with an 8-second timeout. A failure shows a red dot, a details panel and a notice bar.
- **Permission changes:** the admin screen clears the user's server cache, but **nothing pushes the change to an open tab**. Say so if asked, and say how you'd add it (Q14).
- **Your fix:** admin sections skip links that have already expired, and they share one refetch.
- Another engineer built most of the shell's failure handling.

**Your angle:** [S9](../AI%20Engineer/13-Behavioral-Story-Bank.md#s9) (fail-closed).
**Likely follow-ups:** "How do you know when these failures happen?" (health checks, Datadog RUM)

---

### Q14. What would you change if you built it again?  `[P0]`
**Say this first (~30 sec):**
> "Three things. First, push permission changes to open tabs. Today they apply on the next reload. Second, let apps use their UI-element lists through a typed hook, and make every data route re-check app access. Third, generate the shell contract types from one schema, the way chat-kit's types are generated, and add contract tests between the shell and the apps."

**If they dig deeper:**
- **Pushing changes:** send an "entitlements changed" event, or refetch on window focus and on the first 403.
- **Write decisions down:** the docs don't record why we chose `import()` over Module Federation. A one-page decision record would help the next engineer.
- Pick the one you believe in most. `[fill in: your real answer]`

**Likely follow-ups:** "Why didn't you do that the first time?" Honest answer: get apps onto the platform first, then harden.

---

### Q15. How do you version the contract between the shell and the apps?  `[P2]`
**Say this first (~30 sec):**
> "Each bundle declares its contract version in `meta`. We're on version 1. The shell contract package is at 1.3.0. Bundles live in immutable semver folders, and the pipeline won't overwrite one. A sync job points each app at its newest version. For a breaking change, I'd have the shell support the old and new contract versions during the move."

**A sketch of the contract** (not the real code):

```ts
type Host = {
  user: { id: string; name: string };
  getAuthToken(scopes?: string[]):
    Promise<string>;
  apiBaseUrl: string;
  uiElements: string[];
  // also: gateway key, theme, route,
  // telemetry
};

type AppModule = {
  meta: { contractVersion: 1 };
  mount(el: HTMLElement, host: Host): void;
};
```

`[confirm: does mount return an unmount function?]`

## References
- [Story bank: S3 · Watt specs](../AI%20Engineer/13-Behavioral-Story-Bank.md#s3)
- [Story bank: S9 · Entitlements service](../AI%20Engineer/13-Behavioral-Story-Bank.md#s9)
- [Story bank: S4 · Data Intelligence](../AI%20Engineer/13-Behavioral-Story-Bank.md#s4)
- [05 · Full-Stack & Frontend System Design](05-Frontend-System-Design.md): the app-shell, auth and AI-chat scenarios.
- [Azure Storage: user delegation SAS](https://learn.microsoft.com/en-us/rest/api/storageservices/create-user-delegation-sas) (Q4)
- [MSAL.js: single sign-on](https://learn.microsoft.com/en-us/entra/identity-platform/msal-js-sso) (Q6)
- [HTML spec: server-sent events](https://html.spec.whatwg.org/multipage/server-sent-events.html), including `Last-Event-ID` (Q11)
- [Redis: streams in Active-Active databases](https://redis.io/docs/latest/operate/rs/databases/active-active/develop/data-types/streams/): the strict ID mode (Q12)
