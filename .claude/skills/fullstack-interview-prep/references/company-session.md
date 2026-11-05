# Working with Kurt's company-laptop session

Kurt runs a separate Claude session on his BETM work laptop. It can read BETM's repos; this repo can't. Remote Control can't connect the two, so Kurt copies messages between them using his phone.

## How to write a message for it
- **Narrow lines** (about 40 characters) inside one code block, so it copies cleanly on a phone.
- **Always include these rules:** read-only (no edits, commits or pushes); only state what the code, git history or docs show, otherwise write "unsure"; public-safe (no code, internal URLs, hostnames, secrets, trade or customer data, or **people's names**; say "another engineer"); plain text with no tables.
- **Ask for the reply in parts** if it will be long (for example, "answer X now; when I say 'next', answer Y"), because Kurt copies each reply by hand.
- **Ask "who built it"** for each item, based on git authors. Honest ownership is the point.

## Message log
| # | Topic | Sent | Status |
|---|---|---|---|
| 1 | UI facts per project (stack, Kurt's commits, others' work, numbers) | 2026-11-03 | Answered 2026-11-03 → `knowledge.md` §3 |
| 2 | Design Q&A for Jupiter and Watt (28 questions) | 2026-11-03 | Jupiter part answered 2026-11-03 → page 06. Watt + BOTH answered 2026-11-04 → `knowledge.md` §3 and page 07 |
| 3 | AG Grid usage in Jupiter and AMP (+ items 12–15 added 2026-11-04) | sent 2026-11-04 (the 15-item version) | Answered 2026-11-04 (both parts) → `knowledge.md` §3, pages 08, 06, 07 |
| 4 | Follow-ups on page 07's `[confirm]`s | given to Kurt 2026-11-04 | Answered 2026-11-04 → `knowledge.md` §3 and page 07 |
| 5 | The last code-answerable `[fill in]`s (30 questions, parts A–C) | given to Kurt 2026-11-04 | All parts answered 2026-11-04 → `knowledge.md` §3 and pages 01–08 |

The first reply leaked a colleague's name. Remove names before you copy anything into the repo.

## Message 2: design Q&A (as given to Kurt)

```
Second request, for interview prep. The
interview will ask about the DESIGN of
Jupiter (Load Deal) and Watt. Using the
code, git history and docs in the repos,
answer the questions below as interview
Q&A.

For each question give:
- Q: the question
- A: a spoken answer, about 30 seconds,
  first person, simple English
- Details: 2-4 short bullets with
  concrete facts (libraries, patterns,
  numbers)
- Who built it: me / other engineer /
  both (use git authors)

JUPITER (Load Deal)
1. What problem does it solve, for which
   users, and what did they do before?
2. Architecture end to end: UI, API,
   services, jobs, data stores. Draw a
   small text diagram (max 40 chars
   wide).
3. Main UI screens, and what each does.
4. Folder structure, routing, shared
   components, and how API types are
   shared with the FastAPI backend.
5. How pages fetch and cache data. What
   is Dexie (IndexedDB) used for?
6. Why AG Charts, ApexCharts and
   Vega-Lite? Which page uses which?
7. API design: main resources,
   pagination, filtering, error format.
8. How a deal edit or upload is
   validated and saved (client and
   server).
9. Is a PnL run synchronous or a
   background job? How does the UI wait?
10. AG Grid: client- or server-side row
    model, and how many rows?
11. Ask AI: why job polling instead of
    streaming? How are history, SQL,
    tables and charts rendered?
12. The daylight-saving bug: root cause
    and fix, in charts, grids and Excel.
13. PnL Summary: how I moved it from
    mock data to the live API.
14. Tests: what the UI and API tests
    cover, roughly how many.
15. One sentence each: load deal,
    loads-through cutoff, whole-month
    basis.

WATT (BETM AI platform)
16. What problem it solves, which apps
    are on it, how many users.
17. Architecture end to end, as a small
    text diagram.
18. Sign-in: identity provider, where
    tokens live, refresh, and how apps
    get the user and token from the
    shell.
19. App registry: fields in an entry,
    where it's stored, how a new app is
    onboarded.
20. Signed short-lived bundle links: how
    they're made, how long they last,
    how the shell loads a bundle
    (dynamic import, Module Federation,
    iframe).
21. UI-element permissions: how the
    shell gets them, how components
    check them.
22. API gateway: product, routing, where
    permissions are checked again.
23. My chat API contract: SSE event
    types, message IDs, why Redis is in
    the middle, how Stop/cancel works.
24. How ui-kit, chat-kit and admin-kit
    are shared and versioned.
25. Data Validation UI: its pages, how
    the rules form validates, how run
    history handles many runs.
26. Failure cases: registry down,
    expired link, permissions change
    while the user is logged in.

BOTH
27. The 2 hardest technical problems in
    each project, and how they were
    solved.
28. 3 likely interviewer follow-up
    questions per project, with short
    answers.

Rules:
- Read-only. Don't edit, commit, or
  push.
- Only state what the code, git history
  or docs show. Otherwise write
  "unsure".
- Public-safe: no code, internal URLs,
  hostnames, secrets, trade/customer
  data, or people's names (say "another
  engineer").
- Plain text, no tables.
- Answer JUPITER now. When I say "next",
  answer WATT and BOTH.
```

## Message 3: AG Grid (as given to Kurt)

```
Third request, for interview prep. The
interview will be heavy on AG Grid.
Using the code and git history of the
Jupiter (Load Deal) and AMP UIs, tell
me how we use AG Grid.

For each app:
1. AG Grid version, and Community or
   Enterprise (check package.json and
   any license key setup, but don't
   show the key).
2. Modules registered, and the theme
   (Theming API or legacy CSS themes).
3. Row model: client-side, infinite,
   server-side or viewport? Typical
   row counts.
4. Features used: sorting, filters
   (which kinds), editing, selection,
   row grouping, aggregation, pivot,
   pinned rows/columns, master/detail,
   tree data, Excel/CSV export,
   integrated charts, state saving.
5. getRowId: used or not? How rowData
   is updated (replace, transactions,
   async transactions).
6. Custom cell renderers and editors:
   what they do, and which ones I
   wrote.
7. valueGetter / valueFormatter usage
   for numbers, money, dates and time
   zones. How my daylight-saving fix
   touched the grid and Excel export.
8. How column definitions are built
   and typed (ColDef<T>, shared
   helpers, useMemo).
9. Any grid performance problems, and
   how they were fixed.
10. How grids are tested, if at all.
11. The grid code I wrote myself (use
    git authors), in 3-5 bullets.
12. Excel export: AG Grid's own
    exportDataAsExcel, or another
    library? Who wrote it?
13. Does any grid update live (timer,
    polling, push), or only on load?
14. Jupiter turns column
    virtualisation off on one wide
    grid. Why? (commit message or
    comment)

Watt, one last question:
15. If a bad app version is rolled
    back by pointing the registry at
    the old version, would the
    5-minute sync point it at the
    newest version again?

Rules:
- Read-only. Don't edit, commit, or
  push.
- Only state what the code or git
  history shows. Otherwise "unsure".
- Public-safe: no code, internal URLs,
  hostnames, secrets, license keys,
  trade/customer data, or people's
  names (say "another engineer").
- Plain text, no tables.
- Answer JUPITER first. When I say
  "next", answer AMP and question 15.
```

## Message 4: Watt follow-ups (as given to Kurt)

```
Fourth request, short follow-ups for
interview prep. Answer each in 1-3
lines. If the code doesn't show it,
write "unsure".

1. Gateway limit: an early test saw a
   stream cut at 61.1 s, but the chat
   window is 170 s under a 180 s limit.
   Which gateway or route cut at 61 s?
   Was the limit raised later?
2. Jupiter Ask AI: an earlier answer
   said 40-second stream windows. Is
   that still true? Why not 170 s?
3. chat-kit client: EventSource or
   fetch streaming? How is the token
   sent? Are events checked at run
   time (zod, guards), or only typed?
4. Do Watt apps each bundle their own
   React, or share one? Does mount
   return an unmount function? Who
   makes the shadow root?
5. Do data routes (not only admin)
   check that the user has access to
   that app, or only the token?
6. The strict-ID Redis fix: what did
   the library change? (For example,
   Redis makes the IDs now.)
7. How is a bad app version rolled
   back?
8. Why was localStorage for tokens
   reverted?
9. Why does Data Validation use a
   hash router?
10. Is Doc Intelligence the same app
    as Ask Knowledge? What does the
    Memory app do, in one line?

Rules:
- Read-only. Don't edit, commit, or
  push.
- Public-safe: no code, internal URLs,
  hostnames, secrets, keys, trade or
  customer data, or people's names
  (say "another engineer").
- Plain text, no tables.
```

## Message 5: last code-answerable gaps (as given to Kurt)

Maps to: Part A → pages 02 and 03 (and 01 Q-state, 07 Q9); Part B → pages 06 and 08; Part C → pages 05, 04 and 07. Everything else left in the guide is Kurt-only (the company, his reasons, review and disagreement stories, opinions).

```
Fifth request, for interview prep:
the last gaps in my study guide. Use
the code, git history and docs of the
Watt app repos, Jupiter (Load Deal)
and AMP. Answer each in 1-3 lines,
and say who wrote it (me / another
engineer / both).

PART A: TypeScript and React (Watt
apps and Jupiter UI)
1. TypeScript version and "strict" in
   each tsconfig. Does CI run tsc
   (--noEmit or -b)? What else runs
   in each repo's CI?
2. Props: type or interface? Is it
   enforced by lint?
3. React Compiler on or off? Which
   React 19 features are used (ref
   as a prop, use(), useActionState,
   <Context> as provider)? Any
   useTransition/useDeferredValue?
4. What do the React contexts hold,
   in each app?
5. Name 2-3 custom hooks I wrote, and
   what each wraps.
6. How do Watt apps fetch and cache
   data (plain fetch, a shared hook,
   any cache)?
7. Data Validation forms: controlled
   or uncontrolled? How are 422/409
   server errors shown? How are
   create vs edit payloads typed? Is
   there a union type for rule or
   monitor kinds?
8. admin-kit: any generic component
   or hook typed by row?
9. A ref I wrote (for example,
   scrolling to a cited passage in
   the Ask Knowledge PDF viewer).
10. Any satisfies, mapped or
    conditional types, or .d.ts
    files I wrote? One "any", "as"
    or null fix I made.
11. How are permission keys typed in
    the Watt and AMP UIs?
12. API mocks in tests: MSW or
    vi.mock? One test of mine that's
    worth describing.

PART B: Jupiter
13. Ask AI page: how are the answer
    types modelled? The page's state
    names? Any error boundary? How
    does polling stop (clearTimeout,
    AbortController, a flag)? How
    are the result table's columns
    built from the SQL result, and
    is there a row limit?
14. Are PnL amounts sent as numbers
    or strings?
15. In one sentence, what does the
    PnL stored procedure compute?
16. How were the 72 blocking async
    handlers found (commit, doc)?
17. When do cached entitlements in
    session storage refresh, if
    permissions change mid-session?
18. Does Jupiter's gateway route
    allow 180 s streams?
19. Why do Price & Load overrides
    use a modal? How are Load Book
    scenario edits saved?
20. Live Deal Summary: grouped by
    what? Tree-data levels on ST
    Forecast and Load Book?
21. Who built the integrated charts
    and the Load Book AG Charts? Any
    reason recorded for AG Charts?
22. The DST bug: how was it found,
    and was the bad conversion in the
    API or the UI?
23. Why does CI run only lint, and
    why was Dexie removed? (commits,
    PRs or docs)
24. Does Jupiter send data to Datadog
    RUM or other frontend telemetry?

PART C: AMP, jobs and Watt
25. AMP: any class components? The
    styling approach? What does Dexie
    store, and how is it kept fresh?
26. AMP landing page ~10s -> 5s: how
    was it measured? Any frontend
    changes? What's in the remaining
    5 s?
27. AMP: which screens show deal or
    position tables? Sorting in the
    browser or on the server?
28. KEDA job service: which jobs run
    on it, typical duration,
    ScaledJob or ScaledObject?
29. Watt: how long did onboarding the
    newest app take (first to last
    commit)? Which teams use Watt,
    per the docs?
30. The Oct 21 strict-ID incident:
    how was the cause found?

Rules:
- Read-only. Don't edit, commit, or
  push.
- Only state what the code, git
  history or docs show. Otherwise
  "unsure".
- Public-safe: no code, internal URLs,
  hostnames, secrets, keys, trade or
  customer data, or people's names
  (say "another engineer").
- Plain text, no tables.
- Answer PART A now. When I say
  "next", answer PART B; "next"
  again, PART C.
```
