# 04 · React Coding Exercises

[← Index](00-Index.md) · **Interview priority:** High · **Read time:** ~50 min (plus ~5 hours to re-type every exercise)

> **Why this matters for this role:** The interview is expected to be heavy on React and TypeScript, and a live coding exercise is likely. The interviewer watches *how* you work (clarify, plan, talk, handle errors, test) as much as the final code. These exercises cover the patterns that come up again and again. Most use energy-trading data (deals, positions, hub prices), so you can connect them to your AMP work. The concepts behind the code are in [03 · React Fundamentals](03-React-Fundamentals.md) and [02 · TypeScript Fundamentals](02-TypeScript-Fundamentals.md).

---

## Primer

### How to run a live-coding session

Use this shape for a 45-minute exercise. Say each step out loud.

1. **Clarify (2–4 min).** Repeat the task in your own words. Then ask:
   - "Can I see one example of the data?"
   - "Does the data come from props, a real API, or a mock?"
   - "Do you want loading, error, and empty states?"
   - "Can I use libraries? Does styling matter?"
2. **Sketch (2–3 min).** Write the types first. Then list state and components in a comment:
   ```
   // State: text, results, status
   // Derived: visibleRows (filter + sort)
   // Components: SearchBox, ResultList
   ```
3. **Happy path (15–20 min).** Get something on the screen fast. Hard-code data if the API is not ready. Run it often.
4. **Loading, error, and empty states (5 min).** Interviewers check these almost every time.
5. **Edge cases (5 min).** Empty input, fast typing, double clicks, unmount during a request, a very long list.
6. **Tests and accessibility (3–5 min).** Real `<label>` and `<button>` elements, keyboard use, `aria-*` only where needed. Name one or two tests you would write.
7. **"With more time…" (1 min).** End with 2–3 concrete next steps: tests, TanStack Query, virtualization, an error boundary.

**If you get stuck:** say what you expect, say what happens instead, and add a `console.log`. A slow, clear debug is much better than silence.

### Phrases to say while coding

Short and easy to say. Practice them out loud.

- "Let me repeat the task to make sure I understand it."
- "I'll write the types first. They are my plan."
- "This can be computed from props, so I won't put it in state."
- "I'll keep this state here. If another component needs it, I'll lift it up."
- "The new value depends on the old one, so I'll use the function form of setState."
- "This effect connects to something outside React, so it needs a cleanup."
- "I'll make the happy path work first. Then loading and errors."
- "Let me run it and check."
- "TypeScript says this can be `undefined`. Let me handle that case."
- "I don't remember the exact API name. At work I would check the docs. Is it OK if I look it up?"
- "I'll skip styling unless it matters to you."
- "Now let me check the edge cases: empty, error, and fast input."
- "With more time, I would add tests for … and …"

### TypeScript you will type in every exercise

```tsx
// Props: one type, then destructure
type Props = {
  deal: Deal;
  onSelect: (id: string) => void;
  children?: ReactNode;
};

// State: give a type when the start value is empty
const [rows, setRows] = useState<Deal[]>([]);
const [status, setStatus] =
  useState<"idle" | "loading" | "error">("idle");

// DOM ref: React 19 needs an initial value
const inputRef = useRef<HTMLInputElement>(null);

// Inline handlers infer the event type
<input onChange={(e) => setText(e.target.value)} />

// Named handlers need the type
function onSubmit(e: SubmitEvent<HTMLFormElement>) {
  e.preventDefault();
}
```

**Note on `SubmitEvent`:** current `@types/react` (19.2.10 and newer) uses `SubmitEvent` for form submit. Older versions (React 18) use `FormEvent`. `FormEvent` still compiles today but is marked deprecated. If the interview editor rejects one, use the other.

### Set up a practice project (10 minutes)

```bash
npm create vite@latest deals-practice -- --template react-ts
cd deals-practice
npm install
npm run dev
```

- Open http://localhost:5173. Put each exercise in `src/` and render it from `App.tsx`.
- Use Node.js 22.12 or newer (Vite needs 20.19+ or 22.12+; Vitest needs 22.12+).
- As of Nov 2026, the template ships React 19, TypeScript 7, Vite 8, and oxlint. `npm run lint` runs oxlint. `npm run build` also runs the type checker.
- **Mock data:** Vite serves files in `public/` as they are. Save `public/deals.json`, then `fetch("/deals.json")`.

**Add tests** (Vitest + React Testing Library):

```bash
npm i -D vitest jsdom @testing-library/react \
  @testing-library/dom @testing-library/user-event
```

Then update `vite.config.ts`:

```ts
/// <reference types="vitest/config" />
import react from "@vitejs/plugin-react";
import { defineConfig } from "vite";

export default defineConfig({
  plugins: [react()],
  test: { environment: "jsdom", globals: true },
});
```

Run `npx vitest`. `globals: true` also lets Testing Library clean up the DOM between tests automatically.

### One-week practice plan

- **Day 1:** Q1, Q2, Q3.
- **Day 2:** Q4, Q5.
- **Day 3:** Q6, Q7.
- **Day 4:** Q8, Q11.
- **Day 5:** Q9, Q10.
- **Day 6:** Re-type the `[P0]` exercises from memory. Use a 30-minute timer and talk out loud.
- **Day 7:** One mock session with a friend, or record yourself and watch it back.

**Tags on this page:** `[P0]` very likely in some form · `[P1]` good to have ready · `[P2]` bonus.

---

## Questions & answers

### Q1. Counter and toggle warm-up: why does "+2" add only 1?  `[P0]`
**Say this first (~30 sec):** "I'll build a counter with +1, −1, +2, and Reset, plus an on/off toggle. The count is one number in `useState`. When the next value depends on the previous one, I'll use the updater form, `setCount(c => c + 1)`. I'll also show why calling `setCount(count + 1)` twice adds only one."

**Requirements:**
- +1, −1 (never below 0), +2, Reset.
- A toggle ("Live prices: On/Off") that screen readers announce as pressed or not pressed.

```ts
// useToggle.ts
import { useCallback, useState } from "react";

export function useToggle(initial = false) {
  const [on, setOn] = useState(initial);
  const toggle = useCallback(() => setOn((v) => !v), []);
  // `as const` returns a tuple: [boolean, () => void]
  return [on, toggle] as const;
}
```

```tsx
// Counter.tsx
import { useState } from "react";
import { useToggle } from "./useToggle";

export function Counter() {
  const [count, setCount] = useState(0);
  const [live, toggleLive] = useToggle(false);

  // BUG: both lines read `count` from this render.
  // If count is 0, both say "set to 1". Result: 1.
  function addTwoBuggy() {
    setCount(count + 1);
    setCount(count + 1);
  }

  // FIX: the updater gets the latest queued value.
  function addTwo() {
    setCount((c) => c + 1);
    setCount((c) => c + 1);
  }

  return (
    <div>
      <p aria-live="polite">Count: {count}</p>
      <button
        onClick={() => setCount((c) => Math.max(0, c - 1))}
        disabled={count === 0}
      >
        -1
      </button>
      <button onClick={() => setCount((c) => c + 1)}>
        +1
      </button>
      <button onClick={addTwoBuggy}>+2 (buggy)</button>
      <button onClick={addTwo}>+2</button>
      <button onClick={() => setCount(0)}>Reset</button>
      <button aria-pressed={live} onClick={toggleLive}>
        Live prices: {live ? "On" : "Off"}
      </button>
    </div>
  );
}
```

**Why "+2 (buggy)" adds only 1:** `count` is a constant inside one render (a snapshot). Both calls say "set it to 0 + 1". React batches them, so the result is 1. The updater form queues "take the latest value and add 1" two times, so the result is 2.

**If they dig deeper:**
- **Batching:** React 18+ batches all state updates in the same event (also inside timeouts and promises) into one re-render.
- **Why `as const`:** without it, TypeScript types the return as `(boolean | (() => void))[]`, and the caller loses the types.
- **Why `useCallback` in `useToggle`:** `toggle` keeps the same identity between renders, so it is safe in dependency arrays and for `memo` children. The React Compiler can do this for you.
- **Accessibility:** `aria-pressed` turns a button into a toggle button. `aria-live="polite"` reads the new count.
- **A test that proves the bug and the fix:**

```tsx
// Counter.test.tsx
import { render, screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { describe, expect, it } from "vitest";
import { Counter } from "./Counter";

describe("Counter", () => {
  it("adds 2 with the updater form", async () => {
    const user = userEvent.setup();
    render(<Counter />);
    const btn = screen.getByRole("button", { name: "+2" });
    await user.click(btn);
    expect(screen.getByText("Count: 2")).toBeTruthy();
  });

  it("shows the bug: adds only 1", async () => {
    const user = userEvent.setup();
    render(<Counter />);
    await user.click(
      screen.getByRole("button", { name: "+2 (buggy)" }),
    );
    expect(screen.getByText("Count: 1")).toBeTruthy();
  });
});
```

(`getByText` throws if nothing matches, so `toBeTruthy()` is enough. With `@testing-library/jest-dom` you would write `toBeInTheDocument()`.)

**Likely follow-ups:**
- "Add a step size." → Keep `step` in state, convert with `Number()`, and call `setCount(c => c + step)`.
- "Keep the count after a page refresh." → Read `localStorage` in a lazy initializer, `useState(() => …)`, and write it in an effect.
- "Two components need the count." → Lift the state up to their parent. Use context only if they are far apart.

---

### Q2. Debounced search box that fetches deals  `[P0]`
**Say this first (~30 sec):** "I'll keep the input text in state and make a debounced copy with a small `useDebounce` hook, so we search only after the user stops typing for 300 ms. An effect runs when the debounced query changes. It fetches with an `AbortController`, and the cleanup aborts the old request. The effect only stores the *answer*, tagged with the query it belongs to. Loading is derived: we have a query but no answer for it yet. So an old answer can never show for a new query."

**Requirements:**
- Search `/api/deals?q=…` as the user types, 300 ms after the last key.
- Empty input → no request and no results.
- Show "Searching…", an error, "No deals found", or the list.
- An old request must never overwrite newer results.

```ts
// useDebounce.ts
import { useEffect, useState } from "react";

// Returns `value`, but only after it stops
// changing for `ms` milliseconds.
export function useDebounce<T>(value: T, ms = 300): T {
  const [debounced, setDebounced] = useState(value);

  useEffect(() => {
    const id = setTimeout(() => setDebounced(value), ms);
    return () => clearTimeout(id); // reset on each change
  }, [value, ms]);

  return debounced;
}
```

```tsx
// DealSearch.tsx
import { useEffect, useState } from "react";
import { useDebounce } from "./useDebounce";

type Hit = { id: string; counterparty: string };

// The answer for one query: hits, or a failure.
type Answer =
  | { query: string; ok: true; hits: Hit[] }
  | { query: string; ok: false };

export function DealSearch() {
  const [text, setText] = useState("");
  const [answer, setAnswer] = useState<Answer>();
  const query = useDebounce(text.trim(), 300);

  useEffect(() => {
    if (!query) return;
    const ctrl = new AbortController();

    const search = async () => {
      try {
        const q = encodeURIComponent(query);
        const res = await fetch(`/api/deals?q=${q}`, {
          signal: ctrl.signal,
        });
        if (!res.ok) throw new Error(`HTTP ${res.status}`);
        const hits = (await res.json()) as Hit[];
        if (ctrl.signal.aborted) return;
        setAnswer({ query, ok: true, hits });
      } catch {
        if (ctrl.signal.aborted) return; // not an error
        setAnswer({ query, ok: false });
      }
    };

    search();
    return () => ctrl.abort(); // cancel the old request
  }, [query]);

  // Derived during render. No loading state to sync.
  const current =
    answer?.query === query ? answer : undefined;
  const loading = query !== "" && !current;

  return (
    <div>
      <label htmlFor="deal-search">Search deals</label>
      <input
        id="deal-search"
        type="search"
        value={text}
        onChange={(e) => setText(e.target.value)}
      />
      {loading && <p>Searching…</p>}
      {current?.ok === false && (
        <p role="alert">Search failed. Try again.</p>
      )}
      {current?.ok && current.hits.length === 0 && (
        <p>No deals found for {query}.</p>
      )}
      <ul>
        {current?.ok &&
          current.hits.map((h) => (
            <li key={h.id}>
              {h.id} · {h.counterparty}
            </li>
          ))}
      </ul>
    </div>
  );
}
```

**If they dig deeper:**
- **Three guards against races:** the cleanup aborts the old request; we check `ctrl.signal.aborted` before saving; and an answer shows only if its `query` matches the current one.
- **Why not `setLoading(true)` at the top of the effect?** Many tutorials do that, and it works. But it costs an extra render, and for one render the old results show next to the new query. React's lint rule `set-state-in-effect` now warns about it (the Vite template's oxlint does too). Deriving `loading` avoids both problems.
- **Abort is not an error:** an aborted fetch rejects with an `AbortError`. We ignore it, so the user never sees a false "Search failed".
- **Debounce vs throttle:** debounce waits until the user pauses (search boxes). Throttle runs at most once every N ms (scroll, live prices; see Q9).
- **UX:** here the old results disappear while loading. To reduce flicker, you can keep showing the last answer, faded, until the new one arrives. You can also require 2+ characters before searching.
- **Encoding:** `encodeURIComponent` stops a name like "A&B Energy" from breaking the URL.
- **Accessibility:** a real `<label>`, and `role="alert"` on the error. For a full autocomplete with arrow keys, follow the WAI-ARIA combobox pattern or use a library.
- **Testing:** mock `fetch` with `vi.fn()` (or MSW), type two letters quickly, wait for the result, and check that `fetch` was called once.

**Likely follow-ups:**
- "Cache results." → Keep a `Map<string, Hit[]>` in a `useRef`, or use TanStack Query with `queryKey: ["deals", query]`. It caches and removes duplicate requests for you.
- "Highlight the matching text." → Split the label on the query (case-insensitive) and wrap the match in `<mark>`.
- "Can you do it without `useEffect`?" → TanStack Query's `useQuery` with `enabled: query !== ""`.

---

### Q3. Generic `useFetch<T>` hook  `[P0]`
**Say this first (~30 sec):** "I'll write a generic hook, `useFetch<T>(url)`, that returns a discriminated union: idle, loading, success with data, or error. The caller checks `status`, and TypeScript narrows the type, so nobody can read `data` before it exists. The effect uses an `AbortController` for cleanup and race safety. Like Q2, it stores only the finished answer, tagged with its request, and derives idle and loading. I'll add `refetch`. In production I'd use TanStack Query, and I can explain why."

**Requirements:**
- `useFetch<T>(url: string | null)`. `null` means "don't fetch yet".
- Return the state plus `refetch()`.
- A new URL cancels the old request. Stale responses never update state.

```ts
// useFetch.ts
import { useEffect, useState } from "react";

export type FetchState<T> =
  | { status: "idle" }
  | { status: "loading" }
  | { status: "success"; data: T }
  | { status: "error"; error: Error };

// A finished answer, tagged with its request.
type Answer<T> = { key: string; state: FetchState<T> };

export function useFetch<T>(url: string | null) {
  const [reloads, setReloads] = useState(0);
  const [answer, setAnswer] = useState<Answer<T>>();
  const key = `${url} #${reloads}`;

  useEffect(() => {
    if (!url) return;
    const ctrl = new AbortController();
    // Save only if this request is still current.
    const finish = (state: FetchState<T>) => {
      if (!ctrl.signal.aborted) setAnswer({ key, state });
    };

    const load = async () => {
      try {
        const res = await fetch(url, {
          signal: ctrl.signal,
        });
        if (!res.ok) throw new Error(`HTTP ${res.status}`);
        // `as T` trusts the server. Validate if you can't.
        const data = (await res.json()) as T;
        finish({ status: "success", data });
      } catch (e) {
        const error =
          e instanceof Error ? e : new Error(String(e));
        finish({ status: "error", error });
      }
    };

    load();
    return () => ctrl.abort();
  }, [url, key]);

  // Idle and loading are derived, never stored.
  let state: FetchState<T> = { status: "loading" };
  if (!url) state = { status: "idle" };
  else if (answer?.key === key) state = answer.state;

  const refetch = () => setReloads((n) => n + 1);
  return { ...state, refetch };
}
```

```tsx
// PositionsPanel.tsx
import { useFetch } from "./useFetch";

type Position = { hub: string; mwh: number };
type Props = { book: string };

export function PositionsPanel({ book }: Props) {
  const q = encodeURIComponent(book);
  const res = useFetch<Position[]>(
    `/api/positions?book=${q}`,
  );

  if (res.status === "idle" || res.status === "loading") {
    return <p>Loading positions…</p>;
  }
  if (res.status === "error") {
    return (
      <p role="alert">
        Could not load positions ({res.error.message}).{" "}
        <button onClick={res.refetch}>Retry</button>
      </p>
    );
  }
  // TypeScript knows res.data exists here.
  if (res.data.length === 0) return <p>No positions.</p>;
  return (
    <ul>
      {res.data.map((p) => (
        <li key={p.hub}>
          {p.hub}: {p.mwh} MWh
        </li>
      ))}
    </ul>
  );
}
```

**If they dig deeper:**
- **Why a union, not three fields:** separate `isLoading`, `error`, and `data` fields allow impossible mixes, like "loading and error at the same time". A union makes those states impossible to write.
- **How `refetch` works:** it bumps `reloads`, which changes `key`. The stored answer no longer matches, so the state is "loading" in the same render, and the effect runs again.
- **`as T` is a promise, not a check.** The server can send anything. At a trust boundary, validate with a schema library such as Zod: `PositionList.parse(json)`.
- **Why the URL is a string:** strings are compared by value. If the hook took an options object, a new object on each render would re-run the effect every time.
- **StrictMode (development only)** runs effect → cleanup → effect on mount. You will see one cancelled request in the Network tab. That is expected, and it proves the cleanup works.
- **Why TanStack Query in production:** this hook has no caching, no de-duplication of the same request, no retries, no refetch when the window gets focus, no pagination helpers, and no mutations. TanStack Query has all of these:

```ts
// usePositions.ts
import { useQuery } from "@tanstack/react-query";

type Position = { hub: string; mwh: number };

async function getPositions(
  book: string,
  signal: AbortSignal,
): Promise<Position[]> {
  const q = encodeURIComponent(book);
  const res = await fetch(`/api/positions?book=${q}`, {
    signal,
  });
  if (!res.ok) throw new Error(`HTTP ${res.status}`);
  return (await res.json()) as Position[];
}

export function usePositions(book: string) {
  return useQuery({
    queryKey: ["positions", book],
    queryFn: ({ signal }) => getPositions(book, signal),
    staleTime: 30_000, // data counts as fresh for 30 s
  });
}
```

(It needs a `QueryClientProvider` at the app root. In a component: `const { data, isPending, error } = usePositions(book);`.)

**Likely follow-ups:**
- "Add a POST that saves a deal." → A separate function (or TanStack's `useMutation`). After success, refetch or invalidate the list.
- "Use Suspense instead of a loading state?" → TanStack's `useSuspenseQuery` (or React 19's `use(promise)`). Loading moves to a `<Suspense fallback>` boundary, and errors go to an error boundary.

---

### Q4. Sortable, filterable deals table  `[P0]`
**Say this first (~30 sec):** "The deals come in as props. State holds only what the user controls: the filter text and the sort (column and direction). The visible rows are derived: filter, then sort, inside `useMemo`. Columns are a typed config array, so each `key` must be a real field of `Deal`. Clicking a header sorts ascending; clicking it again sorts descending."

**Requirements:**
- Columns: ID, counterparty, volume, price, date.
- Filter by counterparty, case-insensitive.
- Click a header to sort; click again to reverse.
- Show "No deals match" when the result is empty.

```ts
// deals.ts
export type Deal = {
  id: string;
  counterparty: string;
  volume: number; // MWh
  price: number; // $/MWh
  date: string; // ISO, e.g. "2026-11-03"
};

export type SortKey = keyof Deal;
export type SortDir = "asc" | "desc";

export type Column = {
  key: SortKey; // must be a real field of Deal
  label: string;
  format?: (d: Deal) => string;
};

export const COLUMNS: Column[] = [
  { key: "id", label: "ID" },
  { key: "counterparty", label: "Counterparty" },
  { key: "volume", label: "Volume (MWh)" },
  {
    key: "price",
    label: "Price ($/MWh)",
    format: (d) => d.price.toFixed(2),
  },
  { key: "date", label: "Date" },
];

export function compareBy(key: SortKey) {
  return (a: Deal, b: Deal): number => {
    const x = a[key];
    const y = b[key];
    if (typeof x === "number" && typeof y === "number") {
      return x - y;
    }
    return String(x).localeCompare(String(y));
  };
}
```

```tsx
// DealsTable.tsx
import { useMemo, useState } from "react";
import type { AriaAttributes } from "react";
import { COLUMNS, compareBy } from "./deals";
import type { Deal, SortDir, SortKey } from "./deals";

type Sort = { key: SortKey; dir: SortDir };
type Props = { deals: Deal[] };

// Reuse React's own type for the aria-sort values.
function ariaSort(
  active: boolean,
  dir: SortDir,
): AriaAttributes["aria-sort"] {
  if (!active) return "none";
  return dir === "asc" ? "ascending" : "descending";
}

export function DealsTable({ deals }: Props) {
  const [filter, setFilter] = useState("");
  const [sort, setSort] = useState<Sort>({
    key: "date",
    dir: "desc",
  });

  // Derived data: compute it, don't store it.
  const rows = useMemo(() => {
    const f = filter.trim().toLowerCase();
    const sign = sort.dir === "asc" ? 1 : -1;
    const cmp = compareBy(sort.key);
    return deals
      .filter((d) =>
        d.counterparty.toLowerCase().includes(f),
      )
      .sort((a, b) => sign * cmp(a, b)); // sorts the copy
  }, [deals, filter, sort]);

  function toggleSort(key: SortKey) {
    setSort((s) =>
      s.key === key && s.dir === "asc"
        ? { key, dir: "desc" }
        : { key, dir: "asc" },
    );
  }

  const headers = COLUMNS.map((c) => {
    const on = sort.key === c.key;
    return (
      <th key={c.key} aria-sort={ariaSort(on, sort.dir)}>
        <button onClick={() => toggleSort(c.key)}>
          {c.label}
          {on && (sort.dir === "asc" ? " ▲" : " ▼")}
        </button>
      </th>
    );
  });

  return (
    <div>
      <label htmlFor="cp-filter">Counterparty</label>
      <input
        id="cp-filter"
        value={filter}
        onChange={(e) => setFilter(e.target.value)}
      />
      <table>
        <thead>
          <tr>{headers}</tr>
        </thead>
        <tbody>
          {rows.map((d) => (
            <tr key={d.id}>
              {COLUMNS.map((c) => (
                <td key={c.key}>
                  {c.format ? c.format(d) : d[c.key]}
                </td>
              ))}
            </tr>
          ))}
        </tbody>
      </table>
      {rows.length === 0 && <p>No deals match.</p>}
    </div>
  );
}
```

**If they dig deeper:**
- **Don't store derived data.** Keeping `filteredRows` in state and syncing it with an effect causes an extra render and can be out of date. Compute it instead.
- **`useMemo` is an optimization, not a rule.** For 200 rows it barely matters. For 50,000 rows it helps. The React Compiler can add memoization automatically.
- **Never sort props in place.** `deals.sort()` would change the parent's array. Here `filter()` already returns a new array. Otherwise use `[...deals].sort()` or `deals.toSorted()`.
- **Stable keys:** `key={d.id}`, never the index, because sorting moves rows.
- **ISO dates** like `2026-11-03` sort correctly as strings. Other date formats need real date parsing.
- **Accessibility:** the sort control is a real `<button>` inside the `<th>`, and `aria-sort` tells screen readers the current order.
- **Large data:** for 10k+ rows, virtualize (TanStack Virtual) or move sort, filter, and paging to the server. A grid library (AG Grid, TanStack Table) is a fair choice for trading screens.
- **Testing:** render three deals, click "Price", read the first row, click again, and check that the order reversed.

**Your angle:** You owned AMP's services and React UI for over a year, and you built the Load Deal service. `[fill in: which AMP screens show deal or position tables, and whether sorting/filtering happens in the browser or on the server]`. See [06 · Jupiter Load Deal Deep Dive](06-Jupiter-Load-Deal-Deep-Dive.md).

**Likely follow-ups:**
- "Filter on more fields." → `[d.id, d.counterparty].some(v => v.toLowerCase().includes(f))`.
- "Sort by two columns." → Keep an array of sorts. Compare by each in order and return the first non-zero result.
- "Add a total volume row." → `rows.reduce((sum, d) => sum + d.volume, 0)`. It is derived, so no new state.

---

### Q5. Add pagination (and infinite scroll) to the table  `[P1]`
**Say this first (~30 sec):** "I'll write a generic `usePagination<T>(items, size)` hook. It keeps only the page number in state; the page count and the current slice are derived. If a filter makes the list shorter, I clamp the page during render, so we never show an empty page. Then a small `Pager` component. If you want infinite scroll instead, I'll watch a sentinel element at the bottom of the list with an `IntersectionObserver` and load the next batch from its callback."

**Requirements:**
- 20 rows per page, Previous / Next, "Page X of Y".
- Buttons are disabled at the first and last page.
- Changing the filter goes back to page 1.

```ts
// usePagination.ts
import { useState } from "react";

export function usePagination<T>(items: T[], size = 20) {
  const [page, setPage] = useState(1);
  const pageCount = Math.max(
    1,
    Math.ceil(items.length / size),
  );
  // Clamp during render. If a filter shrinks the list,
  // we never show an empty page. No effect needed.
  const current = Math.min(page, pageCount);
  const start = (current - 1) * size;

  return {
    page: current,
    pageCount,
    pageItems: items.slice(start, start + size),
    setPage,
  };
}
```

```tsx
// Pager.tsx
type Props = {
  page: number;
  pageCount: number;
  onChange: (page: number) => void;
};

export function Pager(props: Props) {
  const { page, pageCount, onChange } = props;
  return (
    <nav aria-label="Pagination">
      <button
        onClick={() => onChange(page - 1)}
        disabled={page <= 1}
      >
        Previous
      </button>
      <span aria-live="polite">
        Page {page} of {pageCount}
      </span>
      <button
        onClick={() => onChange(page + 1)}
        disabled={page >= pageCount}
      >
        Next
      </button>
    </nav>
  );
}
```

**Wire it into `DealsTable` (Q4):**

```tsx
// After `rows` is computed:
const { page, pageCount, pageItems, setPage } =
  usePagination(rows, 20);

// Filter input: go back to page 1.
onChange={(e) => {
  setFilter(e.target.value);
  setPage(1);
}}

// In <tbody>, map `pageItems` instead of `rows`.
// Under the table:
<Pager
  page={page}
  pageCount={pageCount}
  onChange={setPage}
/>
```

**Variant: infinite scroll.** A hook calls a function when a sentinel `<div>` at the bottom of the list comes on screen:

```ts
// useOnVisible.ts
import { useEffect, useRef } from "react";

// Calls `onVisible` when the element comes on
// screen. Pass a memoized callback (useCallback).
export function useOnVisible(onVisible: () => void) {
  const ref = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const el = ref.current;
    if (!el) return;
    const io = new IntersectionObserver(
      (entries) => {
        if (entries[0]?.isIntersecting) onVisible();
      },
      { rootMargin: "200px" }, // start a bit early
    );
    io.observe(el);
    return () => io.disconnect();
  }, [onVisible]);

  return ref;
}
```

```tsx
// DealsFeed.tsx
import { useCallback, useState } from "react";
import type { Deal } from "./deals";
import { useOnVisible } from "./useOnVisible";

const BATCH = 50;
type Props = { rows: Deal[] };

export function DealsFeed({ rows }: Props) {
  const [shown, setShown] = useState(BATCH);
  const hasMore = shown < rows.length;

  // A new callback after each batch makes the hook
  // observe again. If the sentinel is still on
  // screen, the next batch loads too.
  const loadMore = useCallback(() => {
    if (hasMore) setShown(shown + BATCH);
  }, [hasMore, shown]);
  const sentinelRef = useOnVisible(loadMore);

  return (
    <>
      <ul>
        {rows.slice(0, shown).map((d) => (
          <li key={d.id}>
            {d.id} · {d.counterparty} · {d.volume} MWh
          </li>
        ))}
      </ul>
      {/* Always render the sentinel. */}
      <div ref={sentinelRef} />
      {hasMore && (
        <button onClick={loadMore}>Load more</button>
      )}
    </>
  );
}
```

**If they dig deeper:**
- **Reset the page in the event handler, not in an effect.** `setPage(1)` next to `setFilter(...)` is simpler and avoids an extra render. Do the same in `toggleSort`.
- **Client vs server paging:** client paging is fine for a few thousand rows already in memory. For more, the server pages: `?page=3&size=50` (offset) or `?after=<lastId>` (cursor, which stays correct when new deals arrive). Sort and filter must then go to the server too.
- **With TanStack Query:** `useInfiniteQuery` + `fetchNextPage` for infinite scroll; `placeholderData: keepPreviousData` so page buttons don't flash a loading state.
- **Load in the observer callback, not in an effect:** "the sentinel became visible" is an event, so we act on it right there. An effect that watches an `inView` boolean and calls `setShown` would cost an extra render and trigger the `set-state-in-effect` lint warning.
- **Why re-observe after each batch:** the observer fires when the sentinel *crosses* the edge. If one batch does not fill the screen, the sentinel never leaves, and nothing would fire again. A new `loadMore` (because `shown` changed) re-creates the observer, and a new observer always reports the current state once.
- **Why the "Load more" button:** keyboard and screen-reader users need a way to load more without scrolling.
- **Infinite scroll trade-offs:** the footer is hard to reach, you can't share a link to "page 7", and the DOM keeps growing (virtualize long lists). For a trading blotter, page buttons or a virtualized grid are usually better.
- **Accessibility:** `<nav aria-label="Pagination">` and `aria-live` on "Page X of Y".

**Likely follow-ups:**
- "Let the user pick the page size." → Put `size` in state, and reset to page 1 when it changes.
- "Keep the page in the URL." → Use `URLSearchParams` (or the router's search params) instead of `useState`, so refresh and shared links work.

---

### Q6. Task list with `useReducer`  `[P0]`
**Say this first (~30 sec):** "Tasks are an array in state. There are four kinds of change (add, toggle, rename, delete), so I'll use `useReducer` with a discriminated-union `Action` type. The reducer is a pure function. It returns new arrays and objects and never mutates. Each row is a `TaskItem` with its own `editing` flag, and keys are stable IDs."

**Requirements:**
- Add a task (ignore blank input), mark it done, edit the title, delete it.
- Show how many tasks are left.

```ts
// tasks.ts
export type Task = {
  id: string;
  title: string;
  done: boolean;
};

export type Action =
  | { type: "added"; id: string; title: string }
  | { type: "toggled"; id: string }
  | { type: "renamed"; id: string; title: string }
  | { type: "deleted"; id: string };

// Pure: same input, same output. No side effects.
export function tasksReducer(
  tasks: Task[],
  action: Action,
): Task[] {
  switch (action.type) {
    case "added": {
      const { id, title } = action;
      return [...tasks, { id, title, done: false }];
    }
    case "toggled":
      return tasks.map((t) =>
        t.id === action.id ? { ...t, done: !t.done } : t,
      );
    case "renamed":
      return tasks.map((t) =>
        t.id === action.id
          ? { ...t, title: action.title }
          : t,
      );
    case "deleted":
      return tasks.filter((t) => t.id !== action.id);
    default:
      // Compile error if a new action is not handled.
      return action satisfies never;
  }
}
```

```tsx
// TaskList.tsx
import {
  useReducer,
  useState,
  type SubmitEvent,
} from "react";
import { tasksReducer } from "./tasks";
import { TaskItem } from "./TaskItem";

export function TaskList() {
  const [tasks, dispatch] = useReducer(tasksReducer, []);
  const [title, setTitle] = useState("");
  const left = tasks.filter((t) => !t.done).length;

  function add(e: SubmitEvent<HTMLFormElement>) {
    e.preventDefault();
    const clean = title.trim();
    if (!clean) return;
    // Make the ID here, not inside the reducer.
    const id = crypto.randomUUID();
    dispatch({ type: "added", id, title: clean });
    setTitle("");
  }

  return (
    <section>
      <h2>End-of-day checklist</h2>
      <form onSubmit={add}>
        <label htmlFor="new-task">New task</label>
        <input
          id="new-task"
          value={title}
          onChange={(e) => setTitle(e.target.value)}
        />
        <button type="submit" disabled={!title.trim()}>
          Add
        </button>
      </form>
      <ul>
        {tasks.map((t) => (
          <TaskItem
            key={t.id}
            task={t}
            dispatch={dispatch}
          />
        ))}
      </ul>
      <p>
        {left} of {tasks.length} left
      </p>
    </section>
  );
}
```

```tsx
// TaskItem.tsx
import { useState, type Dispatch } from "react";
import { EditTitle } from "./EditTitle";
import type { Action, Task } from "./tasks";

type Props = { task: Task; dispatch: Dispatch<Action> };

export function TaskItem({ task, dispatch }: Props) {
  const [editing, setEditing] = useState(false);
  const { id, title, done } = task;

  if (editing) {
    return (
      <li>
        <EditTitle
          initial={title}
          onSave={(t) => {
            dispatch({ type: "renamed", id, title: t });
            setEditing(false);
          }}
          onCancel={() => setEditing(false)}
        />
      </li>
    );
  }

  return (
    <li>
      <label>
        <input
          type="checkbox"
          checked={done}
          onChange={() => dispatch({ type: "toggled", id })}
        />
        {done ? <s>{title}</s> : title}
      </label>
      <button
        onClick={() => setEditing(true)}
        aria-label={`Edit ${title}`}
      >
        Edit
      </button>
      <button
        onClick={() => dispatch({ type: "deleted", id })}
        aria-label={`Delete ${title}`}
      >
        Delete
      </button>
    </li>
  );
}
```

```tsx
// EditTitle.tsx
import { useState, type SubmitEvent } from "react";

type Props = {
  initial: string;
  onSave: (title: string) => void;
  onCancel: () => void;
};

// Mounted only while editing, so `draft` starts
// fresh from `initial` every time. No reset code.
export function EditTitle(props: Props) {
  const { initial, onSave, onCancel } = props;
  const [draft, setDraft] = useState(initial);

  function save(e: SubmitEvent<HTMLFormElement>) {
    e.preventDefault();
    const clean = draft.trim();
    if (clean) onSave(clean);
    else onCancel();
  }

  return (
    <form onSubmit={save}>
      <input
        aria-label="Task title"
        value={draft}
        autoFocus
        onChange={(e) => setDraft(e.target.value)}
        onKeyDown={(e) => {
          if (e.key === "Escape") onCancel();
        }}
      />
      <button type="submit">Save</button>
      <button type="button" onClick={onCancel}>
        Cancel
      </button>
    </form>
  );
}
```

**If they dig deeper:**
- **Immutable updates:** `map` returns a new array with one new object, `filter` removes, and spread adds. React compares by reference, so a mutation like `tasks.push(...)` would not re-render.
- **Why the ID is made in the event handler:** reducers must be pure. In development, StrictMode calls reducers twice to catch side effects. `crypto.randomUUID()` inside the reducer would create two different IDs.
- **`satisfies never`:** if someone adds a new action type and forgets its `case`, the build fails.
- **Local vs lifted state:** `editing` lives in `TaskItem` and `draft` lives in `EditTitle`, because nobody else needs them. `tasks` lives in `TaskList` because the "left" counter needs it.
- **Mount = fresh state:** `EditTitle` exists only while editing, so `useState(initial)` starts from the current title each time. You don't need an effect to "reset" the draft.
- **Keys:** with `key={index}`, deleting the first row would move the second row's edit state onto the wrong task.
- **Testing:** the reducer is a plain function, so test it without React: `tasksReducer([], { type: "added", id: "1", title: "Confirm PJM trades" })`.
- **Accessibility:** a real `<form>` (Enter submits), a label on every input, and button names that include the task title ("Delete Confirm PJM trades").
- **`autoFocus`:** fine here, because the user just clicked Edit. Some accessibility lint rules warn about `autoFocus` in general, so be ready to explain the choice.

**Likely follow-ups:**
- "Save tasks to the server." → Optimistic update: dispatch first, call the API, and roll back on error (or TanStack's `useMutation` with `onMutate`).
- "Add All / Active / Done filters." → A `filter` state, then derive the visible list.
- "A deeply nested component needs `dispatch`." → Put `dispatch` in a context. It is stable, so consumers don't re-render for nothing.

---

### Q7. "New deal" form with validation  `[P0]`
**Say this first (~30 sec):** "I'll keep all field values in one state object of strings, because inputs give strings. Validation is a pure function, `validate(values)`, that returns an error per field. Errors are derived on each render, not stored. I show a field's error after the user leaves that field. Submit is disabled while the form is invalid or saving. Every input has a label, and errors are linked with `aria-describedby`."

**Requirements:**
- Counterparty (required), volume (more than 0), price (any number, because power prices can go negative), delivery date (required).
- Show errors after blur. Disable Submit until the form is valid.
- Handle "saving" and a failed save.

```ts
// dealForm.ts
import type { Deal } from "./deals";

// Inputs give strings, so form values are strings.
export type FormValues = {
  counterparty: string;
  volume: string;
  price: string;
  date: string;
};
export type Field = keyof FormValues;
export type Errors = Partial<Record<Field, string>>;
export type NewDeal = Omit<Deal, "id">;

export const EMPTY: FormValues = {
  counterparty: "",
  volume: "",
  price: "",
  date: "",
};

// Careful: Number("") is 0, not "missing".
function toNumber(s: string): number | null {
  if (s.trim() === "") return null;
  const n = Number(s);
  return Number.isFinite(n) ? n : null;
}

// Pure function: easy to unit test.
export function validate(v: FormValues): Errors {
  const errors: Errors = {};
  if (!v.counterparty.trim()) {
    errors.counterparty = "Counterparty is required.";
  }
  const volume = toNumber(v.volume);
  if (volume === null || volume <= 0) {
    errors.volume = "Volume must be more than 0.";
  }
  // Power prices can be negative. Only require a number.
  if (toNumber(v.price) === null) {
    errors.price = "Price must be a number.";
  }
  if (!v.date) errors.date = "Delivery date is required.";
  return errors;
}

export function toNewDeal(v: FormValues): NewDeal {
  return {
    counterparty: v.counterparty.trim(),
    volume: Number(v.volume),
    price: Number(v.price),
    date: v.date,
  };
}
```

```tsx
// NewDealForm.tsx
import { useState, type SubmitEvent } from "react";
import {
  EMPTY,
  toNewDeal,
  validate,
  type Field,
  type NewDeal,
} from "./dealForm";

type Props = { onSave: (deal: NewDeal) => Promise<void> };
type Touched = Partial<Record<Field, boolean>>;

export function NewDealForm({ onSave }: Props) {
  const [values, setValues] = useState(EMPTY);
  const [touched, setTouched] = useState<Touched>({});
  const [saving, setSaving] = useState(false);
  const [saveError, setSaveError] = useState("");

  const errors = validate(values); // derived, not state
  const isValid = Object.keys(errors).length === 0;

  async function submit(e: SubmitEvent<HTMLFormElement>) {
    e.preventDefault();
    if (!isValid || saving) return;
    setSaving(true);
    setSaveError("");
    try {
      await onSave(toNewDeal(values));
      setValues(EMPTY);
      setTouched({});
    } catch {
      setSaveError("Could not save the deal. Try again.");
    } finally {
      setSaving(false);
    }
  }

  // A render helper (a plain function), NOT a
  // component defined inside a component.
  function field(
    name: Field,
    label: string,
    type = "text",
  ) {
    const err = touched[name] ? errors[name] : undefined;
    const errId = `${name}-error`;
    return (
      <div>
        <label htmlFor={name}>{label}</label>
        <input
          id={name}
          type={type}
          value={values[name]}
          onChange={(e) => {
            const value = e.target.value;
            setValues((v) => ({ ...v, [name]: value }));
          }}
          onBlur={() =>
            setTouched((t) => ({ ...t, [name]: true }))
          }
          aria-invalid={err ? true : undefined}
          aria-describedby={err ? errId : undefined}
        />
        {err && <p id={errId}>{err}</p>}
      </div>
    );
  }

  return (
    <form onSubmit={submit} noValidate>
      {field("counterparty", "Counterparty")}
      {field("volume", "Volume (MWh)", "number")}
      {field("price", "Price ($/MWh)", "number")}
      {field("date", "Delivery date", "date")}
      {saveError && <p role="alert">{saveError}</p>}
      <button type="submit" disabled={!isValid || saving}>
        {saving ? "Saving…" : "Save deal"}
      </button>
    </form>
  );
}
```

**If they dig deeper:**
- **Derived errors:** `errors` is computed from `values` on every render, so it can never be out of date.
- **Why `field()` is a function, not a component inside a component:** if I wrote `const Field = () => …` inside `NewDealForm`, React would see a *new component type* on every render. It would remount the input on each key press, and the cursor would jump out.
- **A disabled button has a cost:** it does not say *why* it is disabled. Many accessible forms keep Submit enabled, show all errors on submit, and move focus to the first invalid field. Ask which style they prefer.
- **`noValidate`** turns off the browser's own error pop-ups so only our messages show. `type="number"` still gives a number keyboard on phones.
- **Client validation is for UX only.** The API must validate again. Show server field errors next to the right fields.
- **Production forms:** React Hook Form + a Zod schema is a common pair: fewer re-renders and one place for the rules.
- **Testing:** type into the fields with user-event, check that Save becomes enabled, submit, and check that `onSave` got numbers, not strings.

**Likely follow-ups:**
- "Use React Hook Form?" → Yes for big forms. It uses uncontrolled inputs (fewer re-renders) and supports schema resolvers. I'd follow the team's standard.
- "React 19 form actions?" → `<form action={fn}>` with `useActionState` gives you pending state and the result. It fits server-backed forms well.
- "Delivery date can't be in the past." → ISO dates compare as strings: `v.date < todayIso` → error.

---

### Q8. Accessible modal dialog  `[P1]`
**Say this first (~30 sec):** "I'll render the modal in a portal on `document.body`, so parent CSS like `overflow: hidden` can't clip it. It has `role="dialog"`, `aria-modal`, and `aria-labelledby` pointing at its title. When it opens, focus moves inside. Tab stays inside. Escape and a backdrop click close it. When it closes, focus returns to the button that opened it. In production I'd use the native `<dialog>` element or a tested library like Radix or React Aria."

**Requirements:**
- Props: `open`, `title`, `onClose`, `children`.
- Escape, a click outside, and the Close button all close it.
- Focus moves in, stays in (Tab wraps around), and returns to the opener.

```ts
// focusTrap.ts
import type { KeyboardEvent } from "react";

const FOCUSABLE = [
  "a[href]",
  "button:not([disabled])",
  "input:not([disabled])",
  "select:not([disabled])",
  "textarea:not([disabled])",
  '[tabindex]:not([tabindex="-1"])',
].join(",");

// Keep Tab and Shift+Tab inside the dialog.
export function trapTab(e: KeyboardEvent<HTMLElement>) {
  if (e.key !== "Tab") return;
  const box = e.currentTarget;
  const items =
    box.querySelectorAll<HTMLElement>(FOCUSABLE);
  const first = items[0];
  const last = items[items.length - 1];
  if (!first || !last) {
    e.preventDefault(); // nothing to focus: stay here
    return;
  }
  const active = document.activeElement;
  if (e.shiftKey && (active === first || active === box)) {
    e.preventDefault();
    last.focus();
  } else if (!e.shiftKey && active === last) {
    e.preventDefault();
    first.focus();
  }
}
```

```tsx
// Modal.tsx
import {
  useEffect,
  useId,
  useRef,
  type ReactNode,
} from "react";
import { createPortal } from "react-dom";
import { trapTab } from "./focusTrap";

type Props = {
  open: boolean;
  title: string;
  onClose: () => void;
  children: ReactNode;
};

export function Modal(props: Props) {
  const { open, title, onClose, children } = props;
  const titleId = useId();
  const panelRef = useRef<HTMLDivElement>(null);

  // Open: move focus in. Close: give it back.
  useEffect(() => {
    if (!open) return;
    const opener = document.activeElement;
    panelRef.current?.focus();
    return () => {
      if (opener instanceof HTMLElement) opener.focus();
    };
  }, [open]);

  if (!open) return null;

  return createPortal(
    <div
      className="backdrop"
      onClick={(e) => {
        // Close only on clicks on the backdrop itself.
        if (e.target === e.currentTarget) onClose();
      }}
    >
      <div
        ref={panelRef}
        role="dialog"
        aria-modal="true"
        aria-labelledby={titleId}
        tabIndex={-1}
        className="panel"
        onKeyDown={(e) => {
          if (e.key === "Escape") onClose();
          trapTab(e);
        }}
      >
        <h2 id={titleId}>{title}</h2>
        {children}
        <button onClick={onClose}>Close</button>
      </div>
    </div>,
    document.body,
  );
}
```

**Use it:**

```tsx
const [open, setOpen] = useState(false);

<button onClick={() => setOpen(true)}>Cancel deal</button>
<Modal
  open={open}
  title="Cancel deal D-1024?"
  onClose={() => setOpen(false)}
>
  <p>This cannot be undone.</p>
</Modal>
```

```css
.backdrop {
  position: fixed;
  inset: 0;
  display: grid;
  place-items: center;
  background: rgb(0 0 0 / 0.4);
}
.panel { background: white; padding: 1.5rem; }
```

**If they dig deeper:**
- **Why a portal:** the modal escapes `overflow: hidden` and z-index stacking problems in parent elements. React events still bubble through the *React* tree, not the DOM tree.
- **Backdrop check:** `e.target === e.currentTarget` is true only for clicks on the backdrop itself, so clicks inside the panel don't close it. No `stopPropagation` needed.
- **Escape on the panel, not on `document`:** no global listener, and the effect does not depend on `onClose`. (If it did, an inline `onClose` from the parent would re-run the effect on every render and break the focus logic.)
- **A real app also needs:** body scroll lock, and the `inert` attribute on the rest of the page so screen readers can't reach it.
- **Lint note:** accessibility lint rules (jsx-a11y) may say "prefer `<dialog>` over `role="dialog"`". That is the native version below.
- **Native `<dialog>`** with `showModal()` gives you the top layer, Escape to close, a `::backdrop`, and an inert page behind it, all for free:

```tsx
// NativeDialog.tsx
import { useEffect, useRef, type ReactNode } from "react";

type Props = {
  open: boolean;
  onClose: () => void;
  children: ReactNode;
};

export function NativeDialog(props: Props) {
  const { open, onClose, children } = props;
  const ref = useRef<HTMLDialogElement>(null);

  useEffect(() => {
    const dialog = ref.current;
    if (!dialog) return;
    if (open && !dialog.open) dialog.showModal();
    if (!open && dialog.open) dialog.close();
  }, [open]);

  // Escape closes the dialog and fires "close".
  return (
    <dialog ref={ref} onClose={onClose}>
      {children}
    </dialog>
  );
}
```

- **Testing:** open it and check that focus is inside (`document.activeElement`). Press Escape with user-event and check `onClose` was called. Check that focus went back to the opener.

**Likely follow-ups:**
- "Build tabs instead." → `role="tablist"`, each tab `role="tab"` with `aria-selected` and `aria-controls`, and each panel `role="tabpanel"`. Arrow keys move between tabs. Only the active tab has `tabIndex={0}` ("roving tabindex").
- "Ask before closing if there are unsaved changes." → `onClose` goes to the parent, and the parent decides. The modal stays simple.

---

### Q9. Live price ticker  `[P1]`
**Say this first (~30 sec):** "The feed is a `subscribe(onTick)` function that returns an unsubscribe function, the same shape as a WebSocket wrapper. A `usePrices` hook subscribes in an effect and unsubscribes in the cleanup. Ticks can arrive hundreds of times per second, so I buffer them in a plain variable and copy them into state every 500 ms. That limits re-renders to two per second. Each row keeps the previous price, so I can show green or red and flash the cell."

**Requirements:**
- Show hub, price, and change. Update live.
- Up is green with ▲. Down is red with ▼.
- No leaks after unmount.
- Don't re-render on every tick.

```ts
// priceFeed.ts
export type Tick = { hub: string; price: number };
type Listener = (tick: Tick) => void;

const HUBS = ["PJM-W", "ERCOT-N", "NYISO-J", "ISONE-H"];

// Mock feed: one random tick every 50 ms.
// Same contract as a socket: subscribe() returns
// an unsubscribe function.
export function subscribe(onTick: Listener) {
  const last = new Map<string, number>();
  const timer = setInterval(() => {
    const i = Math.floor(Math.random() * HUBS.length);
    const hub = HUBS[i] ?? "PJM-W";
    const prev = last.get(hub) ?? 45;
    const move = (Math.random() - 0.5) * 2;
    const price = Math.round((prev + move) * 100) / 100;
    last.set(hub, price);
    onTick({ hub, price });
  }, 50);
  return () => clearInterval(timer);
}

// A real WebSocket version has the same shape.
export function subscribeWs(
  url: string,
  onTick: Listener,
) {
  const ws = new WebSocket(url);
  ws.onmessage = (e: MessageEvent<string>) => {
    onTick(JSON.parse(e.data) as Tick);
  };
  return () => ws.close();
}
```

```ts
// usePrices.ts
import { useEffect, useState } from "react";
import { subscribe } from "./priceFeed";

export type Row = { price: number; prev: number };
type Rows = Record<string, Row>;

// Ticks can arrive 100s of times a second. Buffer
// them and re-render at most once every `ms`.
export function usePrices(ms = 500) {
  const [rows, setRows] = useState<Rows>({});

  useEffect(() => {
    let buffer: Record<string, number> = {};
    const unsubscribe = subscribe((t) => {
      buffer[t.hub] = t.price; // keep only the latest
    });

    const timer = setInterval(() => {
      const batch = buffer;
      buffer = {};
      if (Object.keys(batch).length === 0) return;
      setRows((old) => {
        const next = { ...old };
        for (const [hub, price] of Object.entries(batch)) {
          const prev = old[hub]?.price ?? price;
          next[hub] = { price, prev };
        }
        return next;
      });
    }, ms);

    return () => {
      unsubscribe();
      clearInterval(timer);
    };
  }, [ms]);

  return rows;
}
```

```tsx
// PriceTicker.tsx
import { usePrices } from "./usePrices";

const ARROW = { up: "▲", down: "▼", flat: "" } as const;

function direction(change: number): keyof typeof ARROW {
  if (change > 0) return "up";
  if (change < 0) return "down";
  return "flat";
}

export function PriceTicker() {
  const rows = usePrices(500);
  const entries = Object.entries(rows).sort(([a], [b]) =>
    a.localeCompare(b),
  );

  if (entries.length === 0) return <p>Connecting…</p>;

  return (
    <table>
      <caption>Live hub prices ($/MWh)</caption>
      <thead>
        <tr>
          <th scope="col">Hub</th>
          <th scope="col">Price</th>
          <th scope="col">Change</th>
        </tr>
      </thead>
      <tbody>
        {entries.map(([hub, { price, prev }]) => {
          const change = price - prev;
          const dir = direction(change);
          return (
            <tr key={hub}>
              <th scope="row">{hub}</th>
              {/* New key on each price: flash replays */}
              <td key={price} className={`flash ${dir}`}>
                {price.toFixed(2)}
              </td>
              <td className={dir}>
                {ARROW[dir]} {change.toFixed(2)}
              </td>
            </tr>
          );
        })}
      </tbody>
    </table>
  );
}
```

```css
.up { color: #137333; }
.down { color: #c5221f; }
.flash { animation: flash 0.8s ease-out; }
@keyframes flash {
  from { background: #fff3b0; }
}
@media (prefers-reduced-motion: reduce) {
  .flash { animation: none; }
}
```

**If they dig deeper:**
- **Cleanup is the main point.** Without it, every mount opens another subscription. In development, StrictMode mounts twice to catch exactly this bug.
- **Why the buffer is a plain variable, not state:** writing to it should not cause a render. (Use a `useRef` if other code needs to read it.)
- **Throttle, not debounce:** a ticker needs steady updates. Debounce would freeze the screen while prices keep moving.
- **Functional `setRows(old => …)`:** the interval callback is created once, so reading `rows` directly would give a stale value.
- **The `key={price}` trick:** a new key makes React create a new `<td>`, so the CSS flash animation plays again.
- **Rendering cost:** wrap a `PriceRow` component in `memo` so only changed rows re-render, and virtualize if there are hundreds of rows. For very high rates, keep prices in an external store and read them with `useSyncExternalStore`.
- **Accessibility:** don't put `aria-live` on a fast table; it would read every tick. Don't use color alone; the arrows carry the meaning too. Respect `prefers-reduced-motion`.
- **Real WebSocket concerns:** reconnect with backoff, subscribe again after reconnect, a heartbeat to detect a dead connection, and a "stale" badge when data is old. Use one shared socket for the app, not one per component.
- **Testing:** `vi.useFakeTimers()`, mock `subscribe`, push a few ticks, advance 500 ms, then check the row text and class.

**Your angle:** You work at an energy trading firm, so you can explain *why* this matters: a stale price can lead to a bad trading decision. `[fill in: any real-time or intraday data you have handled at BETM, if any]`.

**Likely follow-ups:**
- "Use `useSyncExternalStore`." → The store keeps the latest prices and notifies listeners. Components call `useSyncExternalStore(store.subscribe, store.getSnapshot)`. The snapshot must be a new object only when data changes.
- "Pause when the browser tab is hidden." → Listen to `visibilitychange` and skip flushes while `document.hidden` is true.
- "Add a small price chart per hub." → Keep the last N prices per hub and draw an SVG `<polyline>`.

---

### Q10. Streaming chat (AI assistant style)  `[P1]`
**Say this first (~30 sec):** "When the user sends a message, I add two messages to state: the user's message and an empty assistant message. Then I POST with `fetch` and read `response.body` as a stream. Each text chunk is appended to the assistant message with a functional update. One `AbortController` powers the Stop button and also cancels on unmount. The message list scrolls to the bottom as text arrives."

**Requirements:**
- Send a message. The answer appears piece by piece.
- Stop cancels the stream and keeps the partial text.
- Show an error if the request fails.
- Keep the newest text in view.

```ts
// useChat.ts
import { useEffect, useRef, useState } from "react";

export type Message = {
  id: string;
  role: "user" | "assistant";
  text: string;
};

export function useChat(url: string) {
  const [messages, setMessages] = useState<Message[]>([]);
  const [streaming, setStreaming] = useState(false);
  const [error, setError] = useState("");
  const ctrlRef = useRef<AbortController | null>(null);

  // Cancel the stream if the component unmounts.
  useEffect(() => () => ctrlRef.current?.abort(), []);

  async function send(text: string) {
    const botId = crypto.randomUUID();
    setMessages((m) => [
      ...m,
      { id: crypto.randomUUID(), role: "user", text },
      { id: botId, role: "assistant", text: "" },
    ]);
    setError("");
    setStreaming(true);
    const ctrl = new AbortController();
    ctrlRef.current = ctrl;

    const append = (chunk: string) =>
      setMessages((m) =>
        m.map((msg) =>
          msg.id === botId
            ? { ...msg, text: msg.text + chunk }
            : msg,
        ),
      );

    try {
      const res = await fetch(url, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ message: text }),
        signal: ctrl.signal,
      });
      if (!res.ok || !res.body) {
        throw new Error(`HTTP ${res.status}`);
      }
      const reader = res.body
        .pipeThrough(new TextDecoderStream())
        .getReader();
      while (true) {
        const { done, value } = await reader.read();
        if (done) break;
        append(value);
      }
    } catch {
      if (!ctrl.signal.aborted) {
        setError("The answer failed. Please try again.");
      }
    } finally {
      setStreaming(false);
      ctrlRef.current = null;
    }
  }

  const stop = () => ctrlRef.current?.abort();
  return { messages, streaming, error, send, stop };
}
```

```tsx
// ChatPanel.tsx
import {
  useEffect,
  useRef,
  useState,
  type SubmitEvent,
} from "react";
import { useChat } from "./useChat";

const NAME = { user: "You", assistant: "AI" } as const;

export function ChatPanel() {
  const { messages, streaming, error, send, stop } =
    useChat("/api/chat");
  const [input, setInput] = useState("");
  const logRef = useRef<HTMLDivElement>(null);

  // Keep the newest text in view.
  useEffect(() => {
    const log = logRef.current;
    if (log) log.scrollTop = log.scrollHeight;
  }, [messages]);

  function submit(e: SubmitEvent<HTMLFormElement>) {
    e.preventDefault();
    const text = input.trim();
    if (!text || streaming) return;
    setInput("");
    send(text);
  }

  return (
    <section aria-label="Trading assistant">
      <div ref={logRef} role="log" aria-busy={streaming}>
        {messages.map((m) => (
          <p key={m.id}>
            <strong>{NAME[m.role]}:</strong> {m.text}
          </p>
        ))}
      </div>
      {error && <p role="alert">{error}</p>}
      <form onSubmit={submit}>
        <label htmlFor="chat-input">Message</label>
        <input
          id="chat-input"
          value={input}
          onChange={(e) => setInput(e.target.value)}
        />
        {streaming ? (
          <button type="button" onClick={stop}>
            Stop
          </button>
        ) : (
          <button type="submit" disabled={!input.trim()}>
            Send
          </button>
        )}
      </form>
    </section>
  );
}
```

(Give the log a fixed height and `overflow-y: auto` in CSS so it scrolls inside the panel.)

**If they dig deeper:**
- **The read loop:** `pipeThrough(new TextDecoderStream())` turns bytes into text. It also handles a multi-byte character that is split across two chunks. `reader.read()` returns `{ done, value }`.
- **Real LLM APIs often send SSE** (lines like `data: {...}` with a blank line between events), not raw text. Then you buffer the text, split on blank lines, and parse each `data:` line. The browser's `EventSource` supports only GET, so for a POST body you use `fetch` plus a small parser (or a library such as the Vercel AI SDK).
- **Why functional updates:** many chunks can arrive between renders. `m => m.map(...)` always appends to the latest text.
- **Performance:** one state update per chunk is fine at normal speed. For very fast streams, buffer and flush once per animation frame with `requestAnimationFrame`.
- **Polite auto-scroll:** only scroll if the user is already near the bottom. If they scrolled up to read, don't pull them down.
- **Accessibility:** `role="log"` announces new messages politely. `aria-busy` while streaming asks screen readers to wait for the full answer instead of reading every chunk.
- **Security:** React escapes text, so plain text is safe. If you render Markdown, sanitize it. Never pass raw model output to `dangerouslySetInnerHTML`.
- **History:** this demo sends only the new message. A real chat sends the conversation, or a conversation ID that the server uses to load memory.
- **Testing:** mock `fetch` to return `new Response(stream)` where the stream sends "Hel" then "lo". Check that the text becomes "Hello". jsdom has no layout, so scroll checks belong in a browser test (Playwright).

**Your angle:** You built the backend for the Watt AI Shell and wrote the specs the frontend engineers implemented, so you know the server side of this connection. `[fill in: did Watt stream tokens? SSE or plain chunks? How did cancel work on the server?]` See [07 · Watt AI Platform Deep Dive](07-Watt-AI-Platform-Deep-Dive.md).

**Likely follow-ups:**
- "Regenerate the last answer." → Remove the last assistant message and call `send` again with the last user text.
- "Show a typing indicator." → While `streaming` is true and the last message text is `""`, show "Thinking…".
- "Render Markdown and code blocks." → `react-markdown` with sanitizing. Wrap finished messages in `memo` so only the streaming one re-renders.

---

### Q11. Quick-fire: find the bug  `[P0]`
**Say this first (~30 sec):** Interviewers often paste broken code and ask "What's wrong?" Answer in three parts: name the bug, say why it happens, and give the fix. Each one below takes under a minute.

**1. Index as key**

```tsx
{deals.map((d, i) => (
  <DealRow key={i} deal={d} />
))}
```

**Why:** when rows are sorted, added, or deleted, React matches rows by position. Row state (an open editor, a checkbox) jumps to the wrong deal. **Fix:** `key={d.id}`.

**2. Effect without cleanup**

```tsx
useEffect(() => {
  const id = setInterval(refresh, 5000);
}, []);
```

**Why:** the timer keeps running after unmount. In development, StrictMode shows two timers. **Fix:** add `return () => clearInterval(id);`.

**3. Stale closure**

```tsx
useEffect(() => {
  const id = setInterval(() => {
    setSeconds(seconds + 1); // always 0 + 1
  }, 1000);
  return () => clearInterval(id);
}, []);
```

**Why:** the callback captured `seconds` from the first render. **Fix:** `setSeconds((s) => s + 1)`.

**4. Mutating state**

```tsx
function addDeal(d: Deal) {
  deals.push(d);
  setDeals(deals);
}
```

**Why:** it is the same array, so React sees no change and skips the render. You also changed the old state. **Fix:** `setDeals((prev) => [...prev, d]);`.

**5. Object in the dependency array**

```tsx
const filters = { book, hub };
useEffect(() => {
  load(filters).then(setRows);
}, [filters]);
```

**Why:** `filters` is a new object on every render, so the effect runs every render. `setRows` causes a render, so it loops forever. **Fix:** depend on `[book, hub]` and build the object inside the effect.

**6. Component defined inside a component**

```tsx
function DealForm() {
  const [name, setName] = useState("");
  const NameInput = () => (
    <input
      value={name}
      onChange={(e) => setName(e.target.value)}
    />
  );
  return <NameInput />;
}
```

**Why:** `NameInput` is a new component type on every render, so React remounts the input and it loses focus after each key. **Fix:** move it outside and pass props, or just inline the `<input>`.

**7. Derived state synced with an effect**

```tsx
const [total, setTotal] = useState(0);
useEffect(() => {
  setTotal(deals.reduce((s, d) => s + d.volume, 0));
}, [deals]);
```

**Why:** an extra render, and the total is wrong for one render. React's `set-state-in-effect` lint rule flags this. **Fix:** `const total = deals.reduce(...)` during render. Add `useMemo` only if it is slow.

**8. `&&` with a number**

```tsx
{deals.length && <DealsTable deals={deals} />}
```

**Why:** when the length is 0, React renders the text "0". **Fix:** `deals.length > 0 && …`.

**9. Async effect function**

```tsx
useEffect(async () => {
  setRows(await getDeals());
}, []);
```

**Why:** an effect must return a cleanup function or nothing. An async function returns a Promise, and TypeScript reports an error. **Fix:** define an async function inside the effect and call it. Add an abort or "ignore" flag for races (Q3).

**If they dig deeper:**
- Most of these bugs come from two ideas: **each render sees a snapshot of state**, and **React compares by reference** (`Object.is`).

**Likely follow-ups:**
- "How do you catch these automatically?" → TypeScript strict mode, the React hooks lint rules (`rules-of-hooks`, `exhaustive-deps`, `set-state-in-effect`), StrictMode in development, and the React Compiler's checks.

---

## References
- [Vite: Getting started](https://vite.dev/guide/): the `npm create vite@latest` command and supported Node versions.
- [Vitest: Getting started](https://vitest.dev/guide/) and [Vitest config](https://vitest.dev/config/): test setup in `vite.config.ts`.
- [React Testing Library intro](https://testing-library.com/docs/react-testing-library/intro/) and [query priority](https://testing-library.com/docs/queries/about/#priority): why `getByRole` comes first.
- [Testing Library: user-event](https://testing-library.com/docs/user-event/intro): realistic typing and clicking in tests.
- [React: Queueing a series of state updates](https://react.dev/learn/queueing-a-series-of-state-updates): the "+2 adds 1" bug from Q1.
- [React: You might not need an effect](https://react.dev/learn/you-might-not-need-an-effect): derived state, resetting state, and fetching (Q4, Q5, Q11).
- [React: Synchronizing with effects](https://react.dev/learn/synchronizing-with-effects): cleanup, StrictMode double-run, and fetch races (Q2, Q3, Q9).
- [React lint rule: set-state-in-effect](https://react.dev/reference/eslint-plugin-react-hooks/lints/set-state-in-effect): why Q2, Q3, and Q5 derive loading instead of calling `setLoading(true)` in an effect.
- [React: Reusing logic with custom hooks](https://react.dev/learn/reusing-logic-with-custom-hooks): `useDebounce`, `useFetch`, `usePrices`.
- [React: Extracting state logic into a reducer](https://react.dev/learn/extracting-state-logic-into-a-reducer): the Q6 pattern.
- [React: Updating arrays in state](https://react.dev/learn/updating-arrays-in-state): immutable add, remove, and replace.
- [React: Rendering lists](https://react.dev/learn/rendering-lists): why keys must be stable.
- [React: Preserving and resetting state](https://react.dev/learn/preserving-and-resetting-state): why a component defined inside a component loses state (Q7, Q11).
- [React: createPortal](https://react.dev/reference/react-dom/createPortal): the Q8 modal.
- [React: useSyncExternalStore](https://react.dev/reference/react/useSyncExternalStore): the Q9 follow-up.
- [React: useActionState](https://react.dev/reference/react/useActionState): React 19 form actions (Q7 follow-up).
- [React: StrictMode](https://react.dev/reference/react/StrictMode): why effects and reducers run twice in development.
- [React Compiler](https://react.dev/learn/react-compiler): automatic memoization.
- [React: Using TypeScript](https://react.dev/learn/typescript) and the [React TypeScript Cheatsheet](https://react-typescript-cheatsheet.netlify.app/): typing props, events, and hooks.
- [TanStack Query overview](https://tanstack.com/query/latest/docs/framework/react/overview) and [infinite queries](https://tanstack.com/query/latest/docs/framework/react/guides/infinite-queries): the production version of Q3 and Q5.
- [TanStack Virtual](https://tanstack.com/virtual/latest): virtualizing long lists and tables.
- [MDN: AbortController](https://developer.mozilla.org/en-US/docs/Web/API/AbortController): cancelling fetch requests.
- [MDN: Intersection Observer API](https://developer.mozilla.org/en-US/docs/Web/API/Intersection_Observer_API): the Q5 infinite scroll.
- [MDN: Using readable streams](https://developer.mozilla.org/en-US/docs/Web/API/Streams_API/Using_readable_streams): the Q10 read loop.
- [MDN: Using server-sent events](https://developer.mozilla.org/en-US/docs/Web/API/Server-sent_events/Using_server-sent_events): the SSE format that LLM APIs use.
- [MDN: The dialog element](https://developer.mozilla.org/en-US/docs/Web/HTML/Reference/Elements/dialog): the native modal.
- [WAI-ARIA APG: Modal dialog pattern](https://www.w3.org/WAI/ARIA/apg/patterns/dialog-modal/): focus rules for Q8.
- [WAI-ARIA APG: Tabs pattern](https://www.w3.org/WAI/ARIA/apg/patterns/tabs/): the Q8 follow-up.
- [WAI-ARIA APG: Sortable table example](https://www.w3.org/WAI/ARIA/apg/patterns/table/examples/sortable-table/): `aria-sort` in Q4.
- [WAI-ARIA APG: Combobox pattern](https://www.w3.org/WAI/ARIA/apg/patterns/combobox/): a full autocomplete (Q2 follow-up).
- [Zod](https://zod.dev/): runtime validation of API responses and forms.
