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
| 3 | AG Grid usage in Jupiter and AMP | given to Kurt 2026-11-03 | Waiting |
| 4 | Follow-ups on page 07's `[confirm]`s | given to Kurt 2026-11-04 | Waiting |

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
