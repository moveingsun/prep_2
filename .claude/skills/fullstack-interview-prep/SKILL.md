---
name: fullstack-interview-prep
description: Kurt Wang's full-stack engineer interview prep (the "Ravi's Position" guide, his full-stack resume, and the BETM projects Watt, Jupiter/Load Deal and AMP). Use this skill whenever Kurt asks to continue, update, or study for the full-stack interview; pastes a reply from his company-laptop Claude session; asks for a mock interview, quiz, React/TypeScript/AG Grid coding drill, or project deep-dive practice; wants the resume changed or re-rendered as PDF; or mentions Ravi, Watt, Jupiter, Load Deal, AMP, AG Grid, or the 7-day plan, even if he doesn't name the guide.
---

# Full-stack interview prep (Kurt Wang)

Kurt is preparing for a full-stack engineer interview that Ravi referred him to. It will be heavy on **React + TypeScript**, **AG Grid**, and the **design of his own projects** (Jupiter/Load Deal and Watt). This skill holds everything an earlier session learned, so you can continue without re-asking him.

## Read first
1. `references/knowledge.md`: the facts. It covers the candidate, the interview, who built what at BETM, the confirmed numbers, the resume files and the open items. **Read it before you answer anything about Kurt's experience.**
2. `Ravi's Position/00-Index.md`: the study guide, its 7-day plan and its open-items checklist.
3. `CLAUDE.md` (repo root): the page template and conventions. They apply to `Ravi's Position/` as well.
4. Read `references/company-session.md` only when you're preparing a message for, or processing a reply from, Kurt's company-laptop session.

## Rules that matter most
- **Honesty over polish.** Kurt is coached never to exaggerate. "I built" is only for code the git history shows he wrote. Use "I designed / specced / reviewed" for the rest. If a detail is unknown, write `[fill in: …]` rather than inventing it. Interviewers check claims in deep dives, and one exaggeration found out costs more than a modest true claim.
- **Use the confirmed numbers.** Kurt corrected some resume claims; they are listed in `knowledge.md` → "Confirmed claims". Never bring back the old versions: "sole full-time engineer" or "20s → 5s". The PnL Summary 4.5–5.1s → 3.6s number is allowed in the guide as an event-loop story, but never on the resume.
- **No colleague names** in the repo, the resume or the docs. Write "a frontend engineer" or "another engineer". Replies from the company session have leaked a name before. Remove it when you copy facts over.
- **Plain English, phone-friendly.** Kurt is a non-native speaker and reads the guide in the GitHub mobile app. Keep sentences short, avoid idioms, keep code lines under about 60 characters, and use narrow tables.
- **Verify versions before you state them** (React, TypeScript, AG Grid, Next.js). Check npm or the official docs. `knowledge.md` lists what was verified and when.

## Common tasks

### Process a reply from the company-laptop session
Kurt pastes text that his work-laptop Claude session produced from BETM's repos.
1. Remove people's names, internal URLs and hostnames.
2. Compare it against `knowledge.md`. If it contradicts an earlier fact or a resume claim, **ask Kurt** before changing anything that he will say out loud or send.
3. Update the matching pages: Jupiter → `06-…`, Watt → `07-…`, AG Grid → `08-…`, general design → `05-…`, pitch and framing → `01-…`. Replace `[fill in]`s with the facts, and keep "who built it" accurate.
4. Add the new durable facts to `references/knowledge.md` (and log the date the reply came in).
5. Run the checks (below), then commit and push only if Kurt asks.

### Mock interview / quiz / drills
- **Quiz:** ask one `[P0]` question at a time from the relevant page. Don't show the answer first. Score his spoken answer from 1 to 5 on structure, specificity (numbers, names of tech), use of his own story, and length (~30–60 sec). Give 2–3 short coaching bullets, then have him retry.
- **Coding drill:** give an exercise from `04-React-Coding-Exercises.md` or `08-AG-Grid.md` without its solution. Let him type a solution. Review it like an interviewer: correctness, TypeScript types, hook rules, loading/error/empty states, keys, cleanup, accessibility. Then compare it with the page's solution.
- **Deep-dive drill:** act as the interviewer: "Walk me through Jupiter." Follow every answer with "why?" or "what would you change?" up to three levels deep. Then point out any place where he overclaimed or went vague.

### Change or re-render the resume
- The 1-page PDF (the one sent to Ravi) is built from `Resume/resume_fullstack_1page.html`. The 2-page text also lives in a Claude Doc (link in `knowledge.md`).
- After editing the HTML, run `bash .claude/skills/fullstack-interview-prep/scripts/render_resume.sh Resume/resume_fullstack_1page.html Resume/Kurt_Wang_Resume_FullStack_1page.pdf`. It prints the page count. If the count is over 1, tighten the bullets that wrap by only a word or two. Then read the PDF to check it.
- `Resume/` is git-excluded and exists only on Kurt's Mac. A cloud session won't have it, so say so instead of guessing.
- Don't use the Claude Doc's own PDF export to send the resume. It renders at about 5 pages.

### Checks before you finish an edit
```
python3 tools/check_links.py . <scratchpad>/urls.txt
grep -rn -i "<any colleague name you saw>" "Ravi's Position" "AI Engineer"
```
Curl every new external URL (the command is in `CLAUDE.md`).
