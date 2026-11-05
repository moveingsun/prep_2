# Full-Stack Engineer: Interview Prep Index

**Target:** **Full Stack Engineer** at **Dodge & Cox**, about **Tue Nov 10, 2026**. Ravi, your former manager at BETM, joined Dodge & Cox and invited you to interview for his team. The role doesn't involve AI today. `[fill in: exact date, format, interviewers]`

> **Ravi is on your side.** He knows your BETM work and wants you on his team. The other interviewers don't know it yet, so give them the clear, exact version: the same story Ravi would tell about you.

**What you heard:** heavy on **React + TypeScript** and **AG Grid** (Ravi), plus the **design of Load Deal (Jupiter) and Watt**.

> This guide has the same layout as the [AI Engineer guide](../AI%20Engineer/00-Index.md). Stories S1–S14 and M1 live in the [Behavioral Story Bank](../AI%20Engineer/13-Behavioral-Story-Bank.md). This guide links to them; it doesn't copy them.

## How to use this guide
- Every Q&A follows the same pattern: **Say this first** (~30 sec spoken answer) → **If they dig deeper** → **Your angle** → **Likely follow-ups**.
- Tags: `[P0]` very likely in this interview · `[P1]` likely in a technical round · `[P2]` depth / bonus.
- `[fill in: …]` marks details only you know, or that the company-laptop session will find. **Pages 06 and 07 depend on those details.** They are the most valuable prep for this interview.
- Practice **out loud**. For coding, **type the solutions from memory**. Reading is not practice.

## Likely interview shape `[fill in: confirm with recruiter]`
1. **Intro and background** (5–10 min) → [01](01-Pitch-and-Full-Stack-Framing.md)
2. **React / TypeScript / AG Grid questions** (10–15 min) → [02](02-TypeScript-Fundamentals.md), [03](03-React-Fundamentals.md), [08](08-AG-Grid.md)
3. **Live coding in React + TS, probably with AG Grid** (20–45 min) → [04](04-React-Coding-Exercises.md), [08](08-AG-Grid.md)
4. **Project deep dive: Load Deal or Watt** (15–20 min) → [06](06-Jupiter-Load-Deal-Deep-Dive.md), [07](07-Watt-AI-Platform-Deep-Dive.md)
5. **Design questions** ("how would you build…") → [05](05-Frontend-System-Design.md)
6. **Your questions** (5 min)

## Pages

| # | Page | Priority |
|---|---|---|
| 01 | [Pitch & Full-Stack Framing](01-Pitch-and-Full-Stack-Framing.md) | **High** |
| 02 | [TypeScript Fundamentals](02-TypeScript-Fundamentals.md) | **High** |
| 03 | [React Fundamentals](03-React-Fundamentals.md) | **High** |
| 04 | [React Coding Exercises](04-React-Coding-Exercises.md) | **High** |
| 05 | [Full-Stack & Frontend System Design](05-Frontend-System-Design.md) | Medium-High |
| 06 | [Jupiter (Load Deal) Deep Dive](06-Jupiter-Load-Deal-Deep-Dive.md) | **High** |
| 07 | [Watt (AI Platform) Deep Dive](07-Watt-AI-Platform-Deep-Dive.md) | **High** |
| 08 | [AG Grid](08-AG-Grid.md) | **Very high** (Ravi) |

## 7-day plan (Wed Nov 4 → Tue Nov 10)

About **2–3 hours a day**. If the interview date moves, keep the order and shift the days.

**Day 1 · Wed 11/4: framing + TypeScript basics**
- Send the research message to the company-laptop session (see "Open items" below).
- [01](01-Pitch-and-Full-Stack-Framing.md): write your full-stack pitch. Say it out loud 3 times.
- [02](02-TypeScript-Fundamentals.md): Primer + all `[P0]` questions.

**Day 2 · Thu 11/5: TypeScript finish + React core**
- [02](02-TypeScript-Fundamentals.md): the `[P1]` questions. Answer the "what is the type error" questions without looking.
- [03](03-React-Fundamentals.md): Primer + the first half of the `[P0]` questions (rendering, state, effects, hooks).
- [04](04-React-Coding-Exercises.md): set up the Vite practice project. Do exercises 1–2.

**Day 3 · Fri 11/6: React finish + AG Grid basics**
- [03](03-React-Fundamentals.md): the rest of the `[P0]` questions (performance, React 19, Server Components, testing).
- [08](08-AG-Grid.md): Primer + the `[P0]` questions. Ravi said the interview is heavy on AG Grid, so give this the most time today.
- [04](04-React-Coding-Exercises.md): exercises 3–4. Time yourself: 25 min each.

**Day 4 · Sat 11/7: Jupiter (Load Deal) deep dive**
- [06](06-Jupiter-Load-Deal-Deep-Dive.md): fill in every `[fill in]` from the company-session reply.
- Draw the architecture from memory on paper. Then give the 2-minute walkthrough out loud.
- [08](08-AG-Grid.md): type the AG Grid coding tasks from memory. Jupiter uses AG Grid, so connect each feature to a screen you know.
- [05](05-Frontend-System-Design.md): the data-grid, dashboard and long-running-job scenarios. They are the general versions of Jupiter's design.

**Day 5 · Sun 11/8: Watt deep dive**
- [07](07-Watt-AI-Platform-Deep-Dive.md): draw it, then give the 2-minute walkthrough out loud. Practice Q11 and Q12 most: they're your strongest stories.
- [05](05-Frontend-System-Design.md): the app-shell, auth and AI-chat scenarios. They are the general versions of Watt.
- [04](04-React-Coding-Exercises.md): exercises 5–10 (pick 3).

**Day 6 · Mon 11/9: mock interview**
- Ask Claude for a mock round: 1 AG Grid coding task and 1 React exercise from scratch (25 min each), 1 project deep dive with follow-ups, and 5 random `[P0]` questions (at least 2 on AG Grid).
- Redo anything you scored low on.

**Day 7 · Tue 11/10: light review**
- Read every line of the new resume. Be ready to explain each bullet for 2 minutes.
- Read only the **Say this first** parts of the `[P0]` questions.
- Prepare 3 questions to ask. Sleep early.

## Open items
- [x] **Company-session reply #1** (UI facts for Watt, Jupiter and AMP). Pages 01, 05, 06 and 07 are updated with it.
- [x] **New resume:** the full-stack version is in the "Kurt Wang Resume" Claude Doc (first tab).
- [x] **3 resume claims confirmed:** AMP is now "owned … leading contract engineers" (not "sole"); the PnL latency number is removed; the AMP landing page is **~10s → 5s** everywhere.
- [x] **Company-session reply #2** (design Q&A for Jupiter and Watt): applied to pages 01–07 on Nov 3–4.
- [x] **Company-session reply #4** (short follow-ups): applied to pages 07, 06, 05 and 02 on Nov 4.
- [x] **Company-session reply #3** (how Jupiter and AMP use AG Grid): applied to pages 08, 06 and 07 on Nov 4. The `[fill in]`s left are things only you know.
- [ ] Interview date, format and interviewer names.
