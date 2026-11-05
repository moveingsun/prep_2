# 03 · React Fundamentals

[← Index](00-Index.md) · **Interview priority:** High · **Read time:** ~60 min, then say the P0 answers out loud

> **Why this matters for this role:** You were told this interview is heavy on React and TypeScript. Your resume reads backend-first, so they will test whether your React is real and current. It is: you ship production React 19 + TypeScript on Watt and Jupiter. You win with two things: correct fundamentals in plain words, and an honest line between what you **built**, what you **designed**, and what **teammates built**. Your edge is where React meets the backend: API contracts, streaming, data fetching, caching, and permissions.

Related pages: [02 · TypeScript](02-TypeScript-Fundamentals.md) · [04 · Coding exercises](04-React-Coding-Exercises.md) · [05 · Frontend system design](05-Frontend-System-Design.md)

---

## Primer

### Versions to know (checked on react.dev, Nov 3, 2026)

- **React 19.3** is the latest release (Sept 9, 2026; npm shows 19.3.1).
- **React 19.2** (Oct 1, 2025) added `<Activity>` and `useEffectEvent`.
- **React 19.0** (Dec 5, 2024) added Actions, `useActionState`, `useOptimistic`, `use`, and `ref` as a prop.
- **React Compiler 1.0** is stable (Oct 7, 2025).
- **Create React App is deprecated** (Feb 14, 2025). react.dev now says: start with a framework (Next.js App Router, React Router, or Expo for native apps), or use a build tool like Vite, Parcel, or Rsbuild.
- **Next.js** is on 16.x (its docs show v16.4.5).
- **Error boundaries still need a class component** (or the `react-error-boundary` package). There is no Hook for them yet.

### Mental model: UI = f(state)

A component is a function. Props and state go in. A description of the UI (JSX) comes out.

You never change the screen yourself. You change **state**, and React works out what the DOM should look like.

### Each update has three steps

react.dev calls them **trigger → render → commit**.

```
 trigger: setState, parent render,
          or a new context value
               │
               ▼
 ┌───────────────────────────┐
 │ RENDER (pure, no DOM)     │
 │ call your components,     │
 │ get a new element tree,   │
 │ diff it with the old one. │
 │ Can pause or restart      │
 │ for Transitions.          │
 └─────────────┬─────────────┘
               ▼
 ┌───────────────────────────┐
 │ COMMIT (touches the DOM)  │
 │ apply only the changes,   │
 │ attach refs, run          │
 │ useLayoutEffect           │
 └─────────────┬─────────────┘
               ▼
        browser paints
               ▼
    useEffect callbacks run
```

"Re-render" means React **calls your function again**. It does not mean the DOM changes. The DOM changes only where the new output is different.

### What triggers a re-render

1. The component's **own state** changes (to a value that is not `Object.is`-equal to the old one).
2. Its **parent re-renders**. Children re-render by default, even with the same props, unless they are memoized (by hand or by the compiler).
3. A **context** it reads gets a new value.

What does **not** trigger one: changing `ref.current`, changing a normal variable, or mutating an object in state without creating a new one.

### Reconciliation in short

React compares the new tree with the old tree, **by position**:
- **Same type, same position:** keep the component and its state; update the props.
- **Different type:** remove the old subtree (its state is lost) and mount the new one.
- **Lists:** match children by `key`, not by position.

> **Rules of Hooks (memorize)**
> 1. Call Hooks only at the **top level**: not in `if`, loops, nested functions, or after an early `return`. React matches Hooks by call order.
> 2. Call Hooks only from **function components** or **custom Hooks** (names start with `use`).
> 3. The exception is **`use()`**. It can be called in `if` and loops, but not inside `try/catch`.
> 4. Rendering must be **pure**: no side effects, and no mutating props or state during render.
> 5. Turn on **`eslint-plugin-react-hooks`**. Its recommended preset now includes the compiler-powered rules.

---

## Questions & answers

### Q1. How much React have you actually written?  `[P0]`
**Say this first (~30 sec):** "I'm a backend-heavy full-stack engineer who writes production React and TypeScript. On our AI platform, Watt, I've made about 240 commits across four React 19 UI repos since August. I created the Ask Data UI, built the Data Validation UI's rules, run-history, monitor, and chat pages, and wrote about two-thirds of the UI test files. On our PnL engine, I built the Ask AI chat page and moved PnL Summary onto the live API. On AMP, I built dashboard tabs, forms, and access checks. I'm strongest where React meets the backend: API contracts, streaming, data fetching, and permissions."

**If they dig deeper:**
- Draw a clear line between what you built, what you designed, and what teammates built. Interviewers trust you more when you do.
- **Watt** (React 19, TypeScript, Vite, Tailwind, React Router, MSAL; hooks + Context, no state library; Recharts, Vega-Lite; Vitest + Testing Library; Datadog RUM):
  - **Built:** the Data Validation UI (rules, run history, monitors, chat pages); the Ask Data UI, which you created; part of the Ask Knowledge UI (uploads, PDF citation highlighting); the shell's Admin tab; and a shared **admin-kit** package used by 3 apps.
  - **Designed:** the chat API contract (SSE streaming over Redis) that the shared chat-kit runs on.
  - **A teammate built:** the shell itself (sign-in, sidebar, the entitlement-driven app list), chat-kit, and ui-kit.
- **Jupiter / Load Deal** (React 19, TypeScript, Vite, AG Grid, AG Charts, ApexCharts, Vega-Lite, Context, Dexie, MSAL, Vitest; FastAPI backend):
  - **Built:** the Ask AI chat page (job polling; SQL, table, and chart answers; history), PnL Summary moved from mock data to the live API, Portfolio PnL history, the Admin usage tab, and daylight-saving fixes across charts, grids, and Excel exports.
  - **A teammate built** most of the other pages.
- **AMP** (React 18, TypeScript, Create React App, AG Grid, ECharts, Highcharts, Chart.js, embedded Power BI, Context, Dexie, MSAL, Datadog RUM):
  - **Built:** the asset dashboard's price and volume tabs, filters, and widgets; the outage-management forms; the admin user and service-principal forms; and entitlement-based access checks.
  - **Reviewed:** AMP UI work from a contract frontend engineer ([M1](../AI%20Engineer/13-Behavioral-Story-Bank.md#m1)). `[fill in: one real thing you caught in review]`
- **Wayfair:** you coded the very first version of Kronos as a co-op in 2018, and later custom Backstage plugins in TypeScript.
  - **Backstage** is Spotify's open-source framework for developer portals, now a CNCF project and still active. Wayfair teams used it as the frame for their UIs, so nobody rebuilt navigation, sign-in or the service catalog. Your plugins brought GitHub, PagerDuty, Datadog and Slack data into one place ([S12](../AI%20Engineer/13-Behavioral-Story-Bank.md#s12)).
  - **If they dig in:** "It was a few years ago, so I don't remember the plugin internals well. The idea was to build on a shared framework instead of reinventing the wheel. It's the same idea as our Watt shell." Don't invent details. Some interviewers know Backstage well.
- Lead with what you built, not the commit count. Use the numbers (239 commits, 4 repos, about two-thirds of the UI test files) only as support.
- Name the gap honestly: "Visual craft, like animation and design systems, is where I have less depth. A teammate built our shared ui-kit." And say it plainly: you haven't used Next.js or Server Components.
- If they ask what was hard about React for a backend engineer, one honest shape is: "Thinking in renders and snapshots instead of steps, and knowing when an effect is the wrong tool." `[adjust to your real experience]`

**Your angle:** [S1](../AI%20Engineer/13-Behavioral-Story-Bank.md#s1) (the Ask AI chat page is the UI of Load Deal AI), [S3](../AI%20Engineer/13-Behavioral-Story-Bank.md#s3), [S14](../AI%20Engineer/13-Behavioral-Story-Bank.md#s14), [M1](../AI%20Engineer/13-Behavioral-Story-Bank.md#m1). Pitch: [01](01-Pitch-and-Full-Stack-Framing.md). Deep dives: [06 · Jupiter](06-Jupiter-Load-Deal-Deep-Dive.md) and [07 · Watt](07-Watt-AI-Platform-Deep-Dive.md).
**Likely follow-ups:** "Walk me through the Ask Data UI you created." · "How does the chat-kit use your SSE contract?" (see [07](07-Watt-AI-Platform-Deep-Dive.md)) · "Why is AMP still on Create React App?" (Q16)

---

### Q2. What is the virtual DOM and reconciliation? Why do keys matter?  `[P0]`
**Say this first (~30 sec):** React keeps the UI as a tree of plain objects. When state changes, React renders a new tree, compares it with the previous one, and applies only the differences to the real DOM. That compare step is reconciliation. It uses two shortcuts: a different element type means "replace this subtree," and in a list, the `key` tells React which item is which. A stable key, like a database ID, lets React keep each row's state when the list is sorted or filtered. An array index as key breaks this: the state sticks to the position, not to the item.

**If they dig deeper:**
- The index-as-key bug:

```tsx
// Bug: delete or sort, and a row's
// typed note or "expanded" state
// moves to a different trade.
{trades.map((t, i) => (
  <TradeRow key={i} trade={t} />
))}

// Fix: a stable ID from the data.
{trades.map((t) => (
  <TradeRow key={t.tradeId} trade={t} />
))}
```

- Index as key is OK only for a static list: never sorted, filtered, inserted into, or edited.
- Never create keys during render (`Math.random()`, `crypto.randomUUID()`). Every render gets new keys, so React remounts every row. State and focus are lost, and it's slow.
- Keys only need to be unique among siblings, not across the whole app.
- **Key as a reset button:** `<DealForm key={dealId} />` gives a fresh form, with fresh state, when the deal changes.
- Position matters too. The same component type at the same spot keeps its state. If both branches of a ternary render `<Counter />` at the same place, the count is kept.
- "Virtual DOM" is the common interview term. react.dev talks about render and commit instead. The diff is a fast heuristic, not a perfect tree diff.

**Your angle:** "Trading screens sort and filter all the time. In a deal grid, the key must be the deal ID. With index keys, an expanded row or a row in edit mode would jump to a different deal after a sort. On a PnL screen, that's a real risk." Jupiter and AMP both use AG Grid, where `getRowId` plays the same role as `key`.
**Likely follow-ups:** "Is the virtual DOM what makes React fast?" (It makes updates predictable and usually fast enough. The real cost is usually rendering too much, not the diff.) · "What if two siblings share a key?" (React warns, and rows can be duplicated or dropped.)

---

### Q3. State vs props. What is one-way data flow? When do you lift state up?  `[P0]`
**Say this first (~30 sec):** Props are inputs from the parent, and the child treats them as read-only. State is a component's own memory; when it changes, the component re-renders. Data flows down through props. Changes flow up through callbacks that the parent passes down. When two siblings need the same data, I move the state up to their closest common parent and pass it down to both. That's "lifting state up," and it keeps one source of truth.

**If they dig deeper:**

```tsx
function DealsPage() {
  const [filter, setFilter] = useState('');
  return (
    <>
      <FilterBar
        value={filter}
        onChange={setFilter}
      />
      <DealTable filter={filter} />
    </>
  );
}
```

- Don't copy a prop into state (`useState(props.price)`). It won't update when the prop changes. If you only want a starting value, name the prop `initialPrice`.
- Don't store what you can compute. Write `const visible = deals.filter(...)` during render instead of keeping a second state.
- Keep state as low as possible, and as high as needed.
- Some state belongs in the **URL**: filters, the selected date, the active tab. Links become shareable, and the back button works.
- Passing props through many layers ("prop drilling")? Try composition first (pass `children`), then Context (Q9), then a store (Q19).
- Server data is a **cache of the backend**, not state you own (Q20).

**Your angle:** Backend analogy: "It's like a system of record. One owner writes; everyone else reads." You know the cost of two sources of truth from the PnL reconciliation ([S8](../AI%20Engineer/13-Behavioral-Story-Bank.md#s8)): 60+ discrepancies between the engine and the traders' workbook.
**Likely follow-ups:** "Where would you keep the selected report date?" (In the URL query string.) · "What is prop drilling, and how do you avoid it?"

---

### Q4. How does useState work? Explain functional updates, batching, and stale closures.  `[P0]`
**Say this first (~30 sec):** `useState` gives a component a value that survives re-renders, plus a setter. The setter doesn't change the variable right away. It queues an update, and the next render gets the new value. Each render sees its own snapshot. Since React 18, all updates in the same event are batched into one render, even inside promises and timeouts. When the next value depends on the previous one, I use the updater form, `setCount(c => c + 1)`, so I never build on an old snapshot.

**If they dig deeper:**
- State is a snapshot:

```tsx
const [count, setCount] = useState(0);

function addThree() {
  setCount(count + 1); // 0 + 1
  setCount(count + 1); // 0 + 1
  setCount(count + 1); // 0 + 1
} // next render: 1

function addThreeFixed() {
  setCount((c) => c + 1);
  setCount((c) => c + 1);
  setCount((c) => c + 1);
} // next render: 3
```

- Stale closure: a callback made in an old render still sees old values.

```tsx
// Bug: count is always 0 here, because
// the callback was created once.
useEffect(() => {
  const id = setInterval(() => {
    setCount(count + 1);
  }, 1000);
  return () => clearInterval(id);
}, []);

// Fix: use the updater form inside:
//   setCount((c) => c + 1);
```

- Immutability: React compares with `Object.is`. If you mutate and set the same object, React sees no change.

```tsx
// Wrong: same array, no re-render
rows.push(newRow);
setRows(rows);

// Right: new array / new object
setRows([...rows, newRow]);
setUser({ ...user, name });
```

- Lazy initial value: `useState(() => loadSavedLayout())` runs the function only on the first render.
- `useReducer` when several fields change together, or when you want named actions. The reducer is a pure function, so it's easy to unit test.
- TypeScript: `useState<Deal | null>(null)` when the initial value doesn't show the full type (see [02](02-TypeScript-Fundamentals.md)).

**Your angle:** Backend analogy: "The setter puts a message on a queue. React processes the queue on the next render."
**Likely follow-ups:** "Why does `console.log(count)` right after `setCount` print the old value?" · "useState vs useReducer?" · "What is automatic batching?"

---

### Q5. Explain useEffect: dependencies, cleanup, and race conditions.  `[P0]`
**Say this first (~30 sec):** An effect keeps a component in sync with something outside React: a WebSocket, a timer, a browser API, or a non-React chart library. It runs after React commits and the screen updates. The dependency array says when to re-sync. If any dependency changed, React runs the old cleanup, then the effect again. Cleanup also runs on unmount. When I fetch inside an effect, I handle the race: if the user switches from deal A to deal B, a slow response for A must not overwrite B. I abort the old request in the cleanup.

**If they dig deeper:**
- Dependency array:
  - No array: runs after every render.
  - `[]`: runs after the first mount; cleanup on unmount.
  - `[a, b]`: runs when `a` or `b` changed (`Object.is`).
- Never hide a dependency to stop re-runs. Let the lint rule list them, then fix the cause: move the object or function inside the effect, or use `useEffectEvent`.
- A race-safe fetch:

```tsx
useEffect(() => {
  const ctrl = new AbortController();
  fetch(`/api/deals/${dealId}`, {
    signal: ctrl.signal,
  })
    .then((r) => r.json())
    .then(setDeal)
    .catch((e) => {
      if (e.name !== 'AbortError') {
        setError(e);
      }
    });
  return () => ctrl.abort();
}, [dealId]);
```

- The effect function can't be `async`, because it must return a cleanup or nothing. Define an async function inside it and call it.
- `useLayoutEffect` runs before the browser paints. Use it only to measure layout (for example, a tooltip position) without a flicker.
- `useEffectEvent` (stable since React 19.2) lets an effect read the latest props or state without making them dependencies:

```tsx
// openPriceSocket is your own helper
const onTick = useEffectEvent((p: Price) => {
  setValue(p.last * units); // latest units
});

useEffect(() => {
  const ws = openPriceSocket(symbol);
  ws.onMessage((p) => onTick(p));
  return () => ws.close();
}, [symbol]); // units is not a dependency
```

- In development, StrictMode runs setup → cleanup → setup one extra time (Q18).

**Your angle:** Two real cases from your work:
- **Polling:** the Jupiter Ask AI page polls a job until the answer is ready. The poll must stop in the cleanup when the user leaves or asks a new question.
- **Streaming:** Watt chat answers stream over SSE, using the API contract you designed (a teammate's chat-kit reads the stream). An unclosed stream leaks a connection on every new question. It's the same resource leak you'd look for in backend code.
- **On the server**, a Watt stream closes on purpose at 170 seconds with a `reconnect` event, and Stop sets a flag in Redis ([07 Q11](07-Watt-AI-Platform-Deep-Dive.md)). On the client, Ask AI's poll stops with `clearTimeout` plus `AbortController.abort()`, and a run-ID counter makes any stale loop quit. It stops on done, error, 404, three failures in a row, the 10-minute cap, cancel (which also sends a DELETE), or unmount.

**Likely follow-ups:** "How do you avoid an infinite loop?" (Don't set state that is also a dependency without a guard. Avoid object or function dependencies that are new on every render.) · "Why not fetch in useEffect at all?" (Q20)

---

### Q6. When do you NOT need an effect?  `[P1]`
**Say this first (~30 sec):** Effects are an escape hatch for syncing with outside systems. Many effects in real code shouldn't exist; they add extra renders and bugs. Three common cases. If a value can be computed from props or state, compute it during render. If code runs because the user did something, put it in the event handler. If you need to reset state when a prop changes, use a `key`. And in React 19, form submissions go into Actions, not effects.

**If they dig deeper:**

```tsx
// Avoid: extra state + extra render
const [total, setTotal] = useState(0);
useEffect(() => {
  setTotal(sumPnl(rows));
}, [rows]);

// Better: compute during render.
// If it's slow, useMemo (or the compiler).
const total = sumPnl(rows);
```

- Event logic, like a POST on Save or analytics on Buy, belongs in the handler. There you know *why* it happened.
- Chains of effects (effect 1 sets A, which triggers effect 2 that sets B) are hard to follow. Compute in one place.
- To tell a parent about a change, call its callback in the same handler that sets your state.
- Fetching in an effect is allowed with a cleanup, but a data library, router loader, or Server Component is usually better (Q20).
- The newer lint rules (for example, `set-state-in-effect`) catch some of these patterns.

**Your angle:** "It's on my review checklist. An effect that only copies one state into another is a sign to simplify." `[fill in: a real case from your own Watt/Jupiter code or from reviewing AMP UI work (M1), or drop this line]`
**Likely follow-ups:** "How do you reset a form when the selected deal changes?" (`key={dealId}`) · "Where does a POST request go?" (In the event handler or an Action.)

---

### Q7. What is useRef for?  `[P1]`
**Say this first (~30 sec):** `useRef` gives a mutable box, `{ current }`, that survives re-renders but does **not** cause a re-render when you change it. Two uses. First, holding a DOM node, for focus, scrolling, measuring, or handing it to a non-React library. Second, holding a value that isn't shown on screen, like a timer ID or the current WebSocket. My rule: if it affects what's rendered, it's state; if not, it can be a ref. And don't read or write `ref.current` during render.

**If they dig deeper:**

```tsx
function SearchBox() {
  const inputRef =
    useRef<HTMLInputElement>(null);
  return (
    <>
      <input ref={inputRef} />
      <button
        onClick={() => inputRef.current?.focus()}
      >
        Focus
      </button>
    </>
  );
}
```

- **React 19:** `ref` is a normal prop for function components. `forwardRef` is no longer needed, and react.dev says it will be deprecated.

```tsx
type Props = React.ComponentPropsWithRef<'input'>;

function TextInput({ ref, ...rest }: Props) {
  return <input ref={ref} {...rest} />;
}
```

- React 19 ref callbacks can return a cleanup function.
- `useImperativeHandle` exposes a small API (like `focus()` or `scrollToRow(id)`) instead of the whole DOM node.
- TypeScript: in React 19 types, `useRef` requires an argument. Use `useRef<HTMLDivElement>(null)` for DOM refs.
- **React 19.3, Fragment refs:** put a `ref` on `<Fragment>` to focus or observe a group of children without adding a wrapper `<div>`.

**Your angle:** Grid and chart libraries are usually driven through a ref: the AG Grid API in Jupiter and AMP, and the embedded Power BI report in AMP. Yours: the **Doc Intelligence PDF viewer** (Sept 29). One ref holds the `div` that pdf.js draws into, and one holds the PDF controller, so it's destroyed on unmount. To reveal a citation, it scrolls the highlight to the center, waits about 400 ms for nearby pages to draw, then centers it again. Page holders are pre-sized, so pages drawing above don't push it off screen.
**Likely follow-ups:** "Why not keep the timer ID in state?" (It would cause a useless re-render.) · "What is `useImperativeHandle`?"

---

### Q8. When do you need useMemo, useCallback, and React.memo? How does the React Compiler change this?  `[P0]`
**Say this first (~30 sec):** `React.memo` skips re-rendering a component when its props are shallowly equal. `useMemo` caches a computed value. `useCallback` caches a function, so its identity stays the same between renders. They help only in specific cases: a really slow calculation, a value passed to a memoized child, or a value used as an effect dependency. Otherwise they add code for no gain. React Compiler 1.0, stable since October 2025, memoizes automatically at build time. So in new code I rely on the compiler, keep `useMemo` and `useCallback` as escape hatches, and measure with the Profiler first.

**If they dig deeper:**
- Why identity matters: `{} !== {}` and `() => {}` is a new function each render. A new prop value breaks `memo` on the child and re-runs effects.

```tsx
type RowProps = {
  deal: Deal;
  onSelect: (id: string) => void;
};

const Row = memo(function Row(
  { deal, onSelect }: RowProps
) {
  return (
    <tr onClick={() => onSelect(deal.id)}>
      <td>{deal.name}</td>
    </tr>
  );
});

function DealTable({ deals }: { deals: Deal[] }) {
  const [selected, setSelected] = useState('');
  // Same function every render, so
  // memo(Row) can skip unchanged rows.
  const onSelect = useCallback(
    (id: string) => setSelected(id),
    []
  );
  return deals.map((d) => (
    <Row key={d.id} deal={d} onSelect={onSelect} />
  ));
}
```

- **When not needed:** cheap work (filtering 100 items), components that render fast anyway, or props that change on every render anyway.
- **Better first moves:** move state down so fewer components re-render; pass JSX as `children` (a wrapper's state change doesn't re-render children created by its parent); remove unnecessary effects.
- **React Compiler:**
  - A build-time Babel plugin. It can memoize more precisely than you can by hand, even after an early `return`.
  - Works with React 17 and later (older versions need an extra runtime package).
  - Vite and Next.js offer compiler-enabled templates. Expo SDK 54+ has it on by default.
  - React's advice for existing code: leave existing `useMemo`/`useCallback` in place, or test carefully before removing them.
  - It relies on the Rules of React. Code that breaks them is skipped, and the lint rules point it out.
- `useCallback` doesn't make the function faster. The function is still created every render; React just returns the cached one.

**Your angle:** "Measure first, then cache. It's the same instinct as backend work." Be honest about [S14](../AI%20Engineer/13-Behavioral-Story-Bank.md#s14): the AMP landing page went from about 10s to 5s **mainly from backend work** (Redis precompute, parallel calls, entitlement fixes, Snowflake reads 13 → 3). Frontend memoization is small next to a slow API. The React Compiler is on only in the Watt shell (another engineer turned it on). It's off in the child apps and in Jupiter.
**Likely follow-ups:** "Does the compiler mean we can stop learning memo?" (No. You still need to know why re-renders happen and how to read the Profiler.) · "What's a shallow comparison?"

---

### Q9. When do you use Context, and what does it cost?  `[P0]`
**Say this first (~30 sec):** Context passes a value deep into the tree without passing props through every layer. It fits values that many components read and that change rarely: the current user, permissions, theme, locale, feature flags. The cost: when the value changes, **every** component that reads that context re-renders. So I keep the value stable, split fast-changing and slow-changing values into separate contexts, and I don't use Context for high-frequency data like live prices. For that I use a store with selectors, like Zustand or Redux.

**If they dig deeper:**

```tsx
type Perms = {
  can: (key: string) => boolean;
};

const PermsContext =
  createContext<Perms | null>(null);

export function usePerms(): Perms {
  const v = useContext(PermsContext);
  if (!v) throw new Error('No PermsProvider');
  return v;
}

type CanProps = {
  perm: string;
  children: ReactNode;
};

export function Can({ perm, children }: CanProps) {
  return usePerms().can(perm) ? children : null;
}

// React 19: render the context itself
<PermsContext value={perms}>
  <Can perm="deal.edit">
    <EditDealButton />
  </Can>
</PermsContext>
```

- **React 19:** `<Context value>` replaces `<Context.Provider>`, and `use(Context)` can be read inside an `if`. **React 19.3:** Server Components can render a Context imported from a `'use client'` file directly.
- **Split contexts:** `UserContext` (rarely changes) vs `SelectionContext` (changes on every click). Or put state and dispatch in two contexts, so components that only dispatch don't re-render.
- **Keep the value stable:** `value={{ user, logout }}` creates a new object each render, so all readers re-render. Wrap it in `useMemo` (or let the compiler do it).
- Context is a way to pass values, not a state manager. It has no selectors, middleware, or DevTools.
- Before reaching for Context, try composition: pass `children` or components as props.

**Your angle:** You use this pattern in production. Watt runs on hooks plus Context with **no state library**, and Jupiter and AMP use React Context too. On AMP, you built the **entitlement-based access checks** in the UI. On Watt, a teammate built the shell's entitlement-driven app list on the app registry you designed ([S3](../AI%20Engineer/13-Behavioral-Story-Bank.md#s3)). Key point: **hiding a button is only UX.** The API must still check every call and fail closed ([S9](../AI%20Engineer/13-Behavioral-Story-Bank.md#s9)). Real: most Watt apps have **no** Context. They get the user, token and permissions from the shell's host object at mount. Jupiter's contexts hold the auth user, entitlements (with a `hasAccess` check), settings, theme and deal summary. Yours: the PnL context (data, meta, loading, error, notFound, refresh), and you added month history and YTD to the Portfolio PnL context. Details in [07 · Watt](07-Watt-AI-Platform-Deep-Dive.md).
**Likely follow-ups:** "Context vs Redux?" (Q19) · "How do you stop every reader from re-rendering?" (Split the context, keep the value stable, or use a store with selectors.)

---

### Q10. What is a custom hook? Give an example.  `[P0]`
**Say this first (~30 sec):** A custom hook is a function whose name starts with `use` and that calls other hooks. It lets components share **stateful logic**, not the state itself. Each component that calls the hook gets its own copy of the state. I write one when two components repeat the same state-plus-effect pattern, or to give a clear name to messy logic, like `useDebouncedValue`, `useLivePrice(symbol)`, or `usePermission('deal.edit')`.

**If they dig deeper:**

```tsx
function useDebouncedValue<T>(
  value: T,
  ms = 300
): T {
  const [v, setV] = useState(value);
  useEffect(() => {
    const id = setTimeout(() => setV(value), ms);
    return () => clearTimeout(id);
  }, [value, ms]);
  return v;
}

// Search box over a big deal list
const query = useDebouncedValue(search, 250);
```

- Good custom hooks have one job, clear inputs and outputs, and generic types. Return a tuple for two values (like `useState`) or an object for more.
- Name a hook by its purpose. Avoid vague "lifecycle" hooks like `useMount` that hide what the effect syncs with.
- Test with `renderHook` from React Testing Library.
- Hooks share logic, not state. To share state, lift it up, or use Context or a store.

**Your angle:** Backend analogy: "It's like pulling repeated code into a shared library function." The next level up is a **shared package**: you built the admin-kit, used by 3 Watt apps, so you know what a stable, reusable API for components and hooks takes. Yours:
- `useCostReport` (admin-kit) loads the cost report. A newer query aborts the older request, and late answers are dropped.
- `useAskAiJob` (Jupiter) wraps create, poll and cancel for the Ask AI jobs API.
- `useVisual<T>` (Jupiter) returns one visual's rows from the PnL context.
- Also `useLoad<T>`, `useConversations` and `useJupiterChatClient`.

**Likely follow-ups:** "If two components call `useDebouncedValue`, do they share state?" (No.) · "How do you test a custom hook?" (`renderHook`, or test it through a small component.)

---

### Q11. Controlled vs uncontrolled inputs. How do you handle forms in React 19?  `[P0]`
**Say this first (~30 sec):** A **controlled** input gets its value from React state and changes through `onChange`, so React is the single source of truth. That's good for instant validation, formatting, or fields that depend on each other. An **uncontrolled** input keeps its value in the DOM, and I read it on submit with `FormData` or a ref. That means less code and fewer re-renders. In React 19, `<form action={fn}>` calls a function with the `FormData`, and `useActionState` gives me the result and an `isPending` flag. For big forms, like deal entry, I'd use react-hook-form with a Zod schema.

**If they dig deeper:**

```tsx
type Result = { error?: string; ok?: boolean };

async function save(
  prev: Result,
  form: FormData
): Promise<Result> {
  const qty = Number(form.get('qty'));
  if (!qty) return { error: 'Qty required' };
  await api.saveDeal({ qty });
  return { ok: true };
}

function DealForm() {
  const [state, formAction, pending] =
    useActionState(save, {});
  return (
    <form action={formAction}>
      <label htmlFor="qty">Quantity</label>
      <input id="qty" name="qty" />
      <button disabled={pending}>Save</button>
      {state.error && (
        <p role="alert">{state.error}</p>
      )}
    </form>
  );
}
```

- **Gotcha:** after a form action finishes without throwing, React resets the uncontrolled fields, even if you returned a validation error. Return the typed values in the state and use them as `defaultValue`, or use react-hook-form.
- `useFormStatus()` (from `react-dom`) lets a submit button deep inside the form read `pending`.
- `useOptimistic` shows the new value right away (for example, "Saved") and rolls it back if the Action fails.
- **react-hook-form:** uses uncontrolled inputs under the hood, so typing doesn't re-render the whole form. It validates through resolvers (Zod is common). Use its `Controller` for controlled third-party inputs like date pickers.
- Don't switch an input between controlled and uncontrolled (a `value` that starts as `undefined`). React warns. Use `value={x ?? ''}`.
- **Validation:** client checks are for UX; the server check is the real one. Share one schema between the backend and the UI, or generate types from OpenAPI.
- For prices and quantities, avoid floating-point surprises. Keep decimal strings or integer units, and let the backend do the math.

**Your angle:** On AMP you built the **outage-management forms** and the **admin user and service-principal forms**. "Validation must also live on the server" is your backend instinct, the same "never trust input" idea as the Data Validation Service ([S2](../AI%20Engineer/13-Behavioral-Story-Bank.md#s2)). Data Validation's forms are **controlled** with `useState`; run-filter rows are an array updated by index. Server errors show as a banner, and inline in the edit modal. **A gap you can own:** the client keeps FastAPI's `detail` only when it's a string, so a 422 field list falls back to the status text. The fix: map each field error to its input.
**Likely follow-ups:** "Why might a controlled input feel slow?" (Each keystroke re-renders a big parent. Move state down, or use uncontrolled inputs / react-hook-form.) · "What does `useOptimistic` do?"

---

### Q12. Lists and conditional rendering: what mistakes do you watch for?  `[P1]`
**Say this first (~30 sec):** For lists: `map` with a stable key from the data, and filter or sort before mapping. For conditions: an early `return` for big branches, a ternary for either-or, and `&&` for show-or-hide. The classic bug is `{count && <Badge />}`: when `count` is 0, React prints "0" on the screen. Use `count > 0 &&` or a ternary. And I always handle four states: loading, error, empty, and data.

**If they dig deeper:**

```tsx
function DealList(
  { deals, loading, error }: Props
) {
  if (loading) return <Spinner />;
  if (error) return <ErrorBox error={error} />;
  if (deals.length === 0) {
    return <p>No deals for this date.</p>;
  }
  return (
    <ul>
      {deals.map((d) => (
        <li key={d.id}>{d.name}</li>
      ))}
    </ul>
  );
}
```

- Use `<>…</>` fragments to avoid extra `<div>`s. Use `<Fragment key={…}>` when one item maps to several elements.
- **Hide vs unmount:** conditional rendering unmounts, so state is lost. CSS hiding keeps state but keeps effects running. React 19.2's `<Activity mode="hidden">` hides the UI, keeps its state, and stops its effects until it's visible again.
- Big lists: virtualize (Q21).

**Your angle:** The Jupiter Ask AI page you built shows each answer as SQL, a table, or a chart. That's conditional rendering by answer type. In TypeScript, a discriminated union with a `switch` on the type makes it safe (see [02](02-TypeScript-Fundamentals.md)). Honest: your first version used one result object with parallel arrays, not a union. The chat-kit version uses parts tagged by kind (sql, table, chart, suggestions), which is the union shown above. Also, the empty state matters in trading tools: "No deals for this date" is very different from "the load failed."
**Likely follow-ups:** "How do you keep a tab's state when the user switches tabs?" (Lift the state up, or use `<Activity>`.)

---

### Q13. What are error boundaries?  `[P1]`
**Say this first (~30 sec):** An error boundary catches errors thrown while rendering its children, shows a fallback UI, and reports the error. One broken widget then doesn't blank the whole page. As of React 19.3 there is still no Hook for this; you need a class component, so most teams use the `react-error-boundary` package. Boundaries don't catch errors in event handlers or in async code like a `setTimeout`. For those I use `try/catch` and show an error state.

**If they dig deeper:**

```tsx
import { ErrorBoundary } from 'react-error-boundary';

<ErrorBoundary
  fallback={<p>PnL chart failed to load.</p>}
  onError={(e) => reportError(e)}
  resetKeys={[dealId]}
>
  <PnlChart dealId={dealId} />
</ErrorBoundary>
```

- **Where to put them:** around each independent widget (chart, grid, chat panel), plus one at the route or app level.
- Errors thrown inside a Transition or Action, and rejected promises read with `use`, go to the nearest error boundary.
- React 19 root options `onCaughtError` and `onUncaughtError` are good places to send errors to monitoring.
- In the Next.js App Router, an `error.tsx` file is an error boundary for that route.
- `resetKeys` retries the render when a key changes (for example, a new deal).

**Your angle:** The Ask AI page you built for Load Deal AI ([S1](../AI%20Engineer/13-Behavioral-Story-Bank.md#s1)) renders SQL, tables, and charts from model output. A bad chart spec should break one message, not the whole conversation, so each answer deserves its own boundary. Send caught errors to Datadog RUM, which Watt and AMP already use. No boundary today; only the chart block has its own "failed" fallback. You'd add one boundary per answer, so one broken chart can't blank the whole chat. Backend parallel: bulkheads, so one failure doesn't spread.
**Likely follow-ups:** "Does an error boundary catch an error thrown in `onClick`?" (No.) · "How do you let the user retry?" (`resetKeys`, or the reset function passed to the fallback.)

---

### Q14. What do Suspense and lazy do? How do you code-split?  `[P1]`
**Say this first (~30 sec):** `<Suspense fallback>` shows a fallback while something inside isn't ready yet: lazy-loaded code, or data from a Suspense-enabled source, such as a framework, TanStack Query's `useSuspenseQuery`, or `use(promise)`. `lazy(() => import('./X'))` puts a component in its own JavaScript chunk that loads on first render. I split by route, and by heavy, rarely used widgets like a chart library or an admin page, so the first load is smaller.

**If they dig deeper:**

```tsx
const PnlChart = lazy(
  () => import('./PnlChart')
);

<Suspense fallback={<ChartSkeleton />}>
  <PnlChart dealId={id} />
</Suspense>
```

- **Where to put boundaries:** one big boundary gives one spinner for the page. Many small ones make parts pop in one by one. Group by what the user sees as one unit.
- Suspense does **not** see data fetched in an effect. Only Suspense-enabled sources trigger it.
- With a Transition, React keeps showing the old content instead of flashing the fallback again.
- With streaming SSR, the server sends HTML for ready parts first and streams each Suspense boundary as it resolves.
- `use(promise)`: the promise must come from a cache or a Server Component. A promise created during render is a new one every render.
- **React 19.3:** `<ViewTransition>` can animate fallback → content. `use(browser())` (from `react-dom`) skips server rendering for browser-only components; the server HTML shows the fallback.

**Your angle:** Your apps load several heavy chart libraries: AG Charts, ApexCharts, and Vega-Lite in Jupiter; ECharts, Highcharts, Chart.js, and embedded Power BI in AMP. Those are the first things to lazy-load, and having so many chart libraries in one app is itself a bundle-size topic. "Code splitting is like trimming a service's startup: load the heavy parts only when needed." Real examples: you lazy-load Vega-Lite on the Jupiter Ask AI page, two Jupiter grids are lazy-loaded, and on Watt each whole app is loaded with `import()` only for users who may use it.
**Likely follow-ups:** "Suspense vs an `isLoading` flag?" (Suspense is declarative: the parent decides where loading UI goes, and it can coordinate several children.)

---

### Q15. What is concurrent rendering? When do you use useTransition and useDeferredValue?  `[P1]`
**Say this first (~30 sec):** Since React 18, rendering can be interrupted. React can start a render, pause to handle something urgent like a keystroke, then continue or throw away the stale work. You opt in by marking updates as non-urgent. `useTransition` marks a state update as a Transition, so the input stays responsive and you get an `isPending` flag. `useDeferredValue` gives you a copy of a value that can lag behind, so a slow child renders with the old value while urgent updates go first. The classic case: typing in a filter box over a big grid.

**If they dig deeper:**

```tsx
function DealSearch({ deals }: Props) {
  const [q, setQ] = useState('');
  const dq = useDeferredValue(q);
  const stale = q !== dq;
  return (
    <>
      <input
        value={q}
        onChange={(e) => setQ(e.target.value)}
      />
      <div style={{ opacity: stale ? 0.6 : 1 }}>
        <DealTable deals={deals} query={dq} />
      </div>
    </>
  );
}
// DealTable must be memoized (by hand or
// by the compiler), or it re-renders anyway.
```

- **useTransition** when you own the setter (switching tabs, navigation). **useDeferredValue** when you only receive the value.
- **React 19:** a Transition can be an async function, which React calls an Action. `isPending` covers the whole async work.
- A text input's own state can't be a Transition; typing must update right away.
- **Not a replacement for debounce.** `useDeferredValue` does not reduce network requests. It helps with slow *rendering*. To send fewer requests, debounce.
- **React 19.3:** unrelated Transitions now render separately, so a slow one doesn't hold up the others.

**Your angle:** Trading grids with thousands of rows and a filter box are the textbook use case. Virtualization (Q21) usually comes first. Honest: no. None of your apps uses `useTransition` or `useDeferredValue`. Say: "I'd reach for it when a filter box makes a big list lag. Typing stays urgent, and the list updates as a transition."
**Likely follow-ups:** "useTransition vs debounce?" · "Why can't the input's own state be a Transition?"

---

### Q16. What's new in React 19, up to 19.3?  `[P0]`
**Say this first (~30 sec):** React 19, in December 2024, was about **Actions**: async functions in Transitions, where React tracks the pending state, errors, and optimistic updates for you. It added `useActionState`, `useOptimistic`, `useFormStatus`, `<form action>`, and the `use` API. It also made `ref` a normal prop and let you render `<Context>` directly as a provider. 19.2 added `<Activity>` and `useEffectEvent`. 19.3, in September 2026, made `<ViewTransition>` and Fragment refs stable. Separately, React Compiler 1.0 shipped in October 2025.

**If they dig deeper:**
- **19.0 (Dec 2024)**
  - Actions: `startTransition(async () => …)`.
  - `useActionState`, `useOptimistic`; `useFormStatus` in `react-dom`.
  - `<form action={fn}>`, which resets uncontrolled fields after success.
  - `use(promise)` and `use(context)`.
  - `ref` as a prop; ref callbacks can return a cleanup.
  - `<Context value>` as the provider.
  - `<title>`, `<meta>`, and `<link>` inside components are moved to `<head>`.
  - Server Components and Server Functions are stable for frameworks to build on.
  - Removed old APIs: `propTypes` checks, `defaultProps` on function components, string refs, legacy context, `ReactDOM.render`, and `findDOMNode`.
- **19.2 (Oct 2025)**
  - `<Activity>`: hide part of the UI and keep its state.
  - `useEffectEvent`.
  - `cacheSignal` (Server Components only).
  - React "Performance Tracks" in Chrome DevTools.
  - Partial Pre-rendering APIs (`prerender` + `resume`).
  - `eslint-plugin-react-hooks` v6 with flat config.
- **19.3 (Sept 2026)**
  - `<ViewTransition>` and `addTransitionType` are stable.
  - Fragment refs.
  - `use(browser())` to skip server rendering for one component.
  - Trusted Types support (protection against XSS).
  - Server Components can render a `<Context>` directly.
  - Unrelated Transitions no longer wait on each other.
- **Other news:** React now lives in the **React Foundation** under the Linux Foundation (launched Feb 2026). In Dec 2025 there was a critical security bug in React Server Components (remote code execution), fixed in 19.0.1, 19.1.2, and 19.2.1.
- **How you'd move AMP off Create React App** (a likely follow-up, since CRA is deprecated):
  1. Swap `react-scripts` for `vite` and `@vitejs/plugin-react`.
  2. Move `index.html` to the project root and point it at the entry file with `<script type="module">`.
  3. Rename env vars from `REACT_APP_*` to `VITE_*` and read them with `import.meta.env`.
  4. Move tests from CRA's Jest to Vitest, which has a Jest-like API.
  5. Check the dev proxy, SVG imports, path aliases, and the build folder (`build` → `dist`) in the deploy pipeline.
  6. Upgrade React 18 → 19 as a **separate** step: run the official codemods, fix removed APIs, and update `@types/react`.
  7. Ship in small PRs, and compare bundle size and test results before and after.

**Your angle:** You use React 19 in production: Watt and Jupiter are React 19 with Vite. AMP is still React 18 on Create React App, so you know both worlds and have a clear upgrade story (above). Honest: your apps don't use the newer APIs yet: no ref as a prop, `use()`, `useActionState` or `<Context>` as a provider, and Jupiter still has one `forwardRef`. You did use `useSyncExternalStore` in Data Validation. Say: "We run React 19, but our code uses the classic APIs. Here's where I'd use the new ones."
**Likely follow-ups:** "What is an Action?" · "What does `useOptimistic` do?" · "What's `<Activity>` for?" · "Why hasn't AMP moved to Vite yet, and what would you do first?"

---

### Q17. Server Components vs Client Components. When do you choose SSR, SSG, or CSR?  `[P1]`
**Say this first (~30 sec):** **CSR** is a single-page app: the browser downloads JavaScript and renders everything. It's simple to host and fine for internal apps behind login, but the first load is slower. **SSR** renders HTML on the server per request, then the browser "hydrates" it to make it interactive: faster first paint and SEO, but you run a server. **SSG** builds HTML at build time: fastest and cheapest, but only for content that's the same for everyone. **Server Components** are a different idea: components that run only on the server, can read data directly, and send no JavaScript to the browser. Client Components, marked `'use client'`, are the interactive parts.

**If they dig deeper:**

```tsx
// app/deals/page.tsx
// Server Component (default in App Router)
export default async function Page() {
  const deals = await db.deals.findMany();
  return <DealGrid deals={deals} />;
}

// DealGrid.tsx
'use client';
export function DealGrid(
  { deals }: { deals: Deal[] }
) {
  const [sort, setSort] = useState('name');
  // ...interactive grid
}
```

- `'use client'` marks where client code starts. Everything that file imports becomes client code too.
- Server → client props must be serializable. A Client Component can't import a Server Component, but it can receive one as `children`.
- There is **no** directive for Server Components. `'use server'` marks **Server Functions** (formerly called Server Actions) that the client can call. They are public HTTP endpoints, so authenticate and validate every call.
- **Trade-offs:** Server Components shrink the bundle and avoid request waterfalls, but add a server runtime, caching rules, and two mental models.
- **Hydration mismatch:** the server HTML differs from the first client render (for example, `Date.now()`, `window`, or the time zone). Render the same output on both sides, or use 19.3's `use(browser())`.
- React 19.2 **Partial Pre-rendering**: serve a static shell from a CDN, then fill in the dynamic parts.
- react.dev notes that its recommended frameworks also support plain CSR, SPA, and static export. You can add SSR per route later.

**Your angle:** All three apps you work on are client-rendered SPAs (Vite, or CRA on AMP) behind Microsoft sign-in with MSAL, and Jupiter talks to a FastAPI backend. For internal trading tools behind SSO, that is the right fit; SSR matters more for public pages, SEO, or slow devices. Backend-for-frontend instinct: "Server Components move the BFF layer into the component tree." Be honest: "I haven't used Server Components, but here's how I'd decide…"
**Likely follow-ups:** "Can a Server Component use `useState`?" (No.) · "What is hydration?" · "Why is a Server Function a security concern?"

---

### Q18. What does StrictMode do? Why do my effects run twice?  `[P1]`
**Say this first (~30 sec):** `<StrictMode>` adds extra checks in development only. It renders components one extra time to catch impure rendering. It runs effects setup → cleanup → setup to catch a missing cleanup, does the same for ref callbacks, and warns about deprecated APIs. Production is not affected. If the double run breaks something, like two WebSocket connections or a duplicate POST, that's a real bug the check found: the cleanup is missing, or the logic belongs in an event handler.

**If they dig deeper:**
- Don't "fix" it with a `useRef` "already ran" flag. Fix the cleanup.
- For true one-time app setup (for example, initializing analytics), run it at module level, outside components.
- A duplicate POST in dev means the POST belongs in an event handler or an Action (Q6).
- **React 19.3:** StrictMode now also double-runs effects during hydration, matching client-rendered apps.

**Your angle:** Backend analogy: "It's an idempotency test. A handler that breaks when it runs twice is fragile." You built stuck-run recovery in the KEDA job service ([S14](../AI%20Engineer/13-Behavioral-Story-Bank.md#s14)), so this idea is familiar. In your own UIs, StrictMode is exactly what would catch a chat stream or a job poll that starts twice without a cleanup.
**Likely follow-ups:** "Should we turn StrictMode off?" (No. Fix the bug it found.)

---

### Q19. How do you choose state management: local state, Context, Redux Toolkit, Zustand, or TanStack Query?  `[P0]`
**Say this first (~30 sec):** First I sort state by kind. **Server state**, like deals and positions, goes in a server-cache library like TanStack Query, or the framework's loaders. That removes most of what people used to put in Redux. **URL state**, like filters and the selected date, goes in the query string. **Local UI state** stays in `useState` near where it's used. For **shared client state**, I use Context if it changes rarely; Zustand for a small store with selectors; and Redux Toolkit for a big app with many developers that needs strict patterns, middleware, and DevTools.

**If they dig deeper:**

| Kind | Example | Tool |
|---|---|---|
| Server | deals, PnL | TanStack Query |
| URL | date, filters | router |
| Local UI | modal open | useState |
| Shared, slow | user, perms | Context |
| Shared, fast | selection | Zustand / RTK |
| Form | deal entry | react-hook-form |

- Zustand: a component re-renders only when the slice it selects changes.

```tsx
import { create } from 'zustand';

type SelState = {
  dealId?: string;
  select: (id: string) => void;
};

const useSel = create<SelState>()((set) => ({
  dealId: undefined,
  select: (id) => set({ dealId: id }),
}));

// Re-renders only when dealId changes
const dealId = useSel((s) => s.dealId);
```

- Redux Toolkit: `createSlice` and `configureStore` remove the old boilerplate. If you're already on Redux, RTK Query handles server state.
- `useSyncExternalStore` is the hook that store libraries use to subscribe safely with concurrent rendering.
- **Anti-pattern:** copying server data into Redux or Zustand and syncing it by hand. You get stale data and duplicated loading flags.
- **High-frequency data (price ticks):** don't push every tick through top-level React state. Buffer and flush a few times per second, or hand updates straight to the grid's transaction API (Q21).

**Your angle:** Your real answer: "Watt runs on hooks plus Context with no state library, and Jupiter and AMP use Context too. We didn't need Redux, because most shared data is server data, and the shared client state (user, permissions, selection) is small. Jupiter and AMP also cache data in the browser with Dexie, on IndexedDB." AMP's Dexie has one table of key, data and timestamp rows. A 24-hour TTL is checked on read, and the table is cleared at sign-in and logout. Today it holds only reference dropdown lists: on Mar 11, 2026 you stopped caching revenue, pricing and volume in the browser, for the same reason as Jupiter. The backend is the source of truth. Backend view: "TanStack Query is a read-through cache: a TTL (`staleTime`), invalidation on writes, and de-duplication. Same ideas as the Redis precompute in [S14](../AI%20Engineer/13-Behavioral-Story-Bank.md#s14) and the Redis-first entitlements in [S9](../AI%20Engineer/13-Behavioral-Story-Bank.md#s9)."
**Likely follow-ups:** "Why not Redux for everything?" · "Would you add TanStack Query to Watt? What would it replace?" · "How would you handle prices updating 10 times a second?"

---

### Q20. How do you fetch and cache data in React?  `[P0]`
**Say this first (~30 sec):** For server data I use a query library like TanStack Query instead of hand-written fetch effects. It gives me caching by key, de-duplication, retries, background refetch, stale-while-revalidate, and cancellation. On writes I run a mutation, then invalidate the related queries or update the cache optimistically. In a framework, I fetch in route loaders or Server Components, so data loads in parallel with code. That avoids request waterfalls.

**If they dig deeper:**

```tsx
function useDeal(id: string) {
  return useQuery({
    queryKey: ['deal', id],
    queryFn: ({ signal }) =>
      api.getDeal(id, { signal }),
    staleTime: 30_000,
  });
}

function useSaveDeal() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: api.saveDeal,
    onSuccess: (d) =>
      qc.invalidateQueries({
        queryKey: ['deal', d.id],
      }),
  });
}
```

- **Query keys** must include every input: `['pnl', date, book]`.
- **`staleTime`** (default 0) is how long data counts as fresh. **`gcTime`** (default 5 minutes) is how long unused data stays in memory.
- **Waterfalls:** a parent fetches, renders a child, and then the child fetches. That's serial. Fix it by fetching in parallel at the route level, prefetching on hover, or moving the fetch to the server.
- **Paging:** `placeholderData: keepPreviousData` keeps the old page on screen while the next one loads. Big grids should page on the server.
- **Real-time:** on a WebSocket message, call `setQueryData` or invalidate the query.
- **Polling a long job:** `refetchInterval` can be a function that returns `false` when the job is done. Polling stops when no component uses the query.

```tsx
useQuery({
  queryKey: ['job', jobId],
  queryFn: () => api.getJob(jobId),
  refetchInterval: (q) =>
    q.state.data?.status === 'done'
      ? false
      : 1000,
});
```

- **Streaming (SSE) for chat:** append chunks to state, and abort the stream in the cleanup. The browser's `EventSource` can't send custom headers, so with a bearer token (for example, from MSAL) teams often read the stream with `fetch` instead.
- **Backend side:** no frontend cache fixes a 20-second API. Shape the API around what the screen needs (an aggregate endpoint, paging, HTTP caching, precompute).

**Your angle:** This is your strongest area. Real examples:
- **Jupiter:** you moved PnL Summary from mock data to the live API, and built the Ask AI page's job polling.
- **Watt:** you designed the chat API contract (SSE streaming over Redis) that the shared chat-kit runs on.
- **AMP:** the landing page went ~10s → 5s **mostly through backend work**: Redis precompute, parallel calls, entitlement fixes, Snowflake reads 13 → 3 ([S14](../AI%20Engineer/13-Behavioral-Story-Bank.md#s14)). The lesson: shape the API around the screen.
- **Time is data too:** you fixed daylight-saving bugs across Jupiter's charts, grids, and Excel exports. Power markets have 23-hour and 25-hour days, so hourly data breaks easily. Root cause, on both sides: in the API, a `GROUP BY` on time and hour-ending summed the two 1 AM rows (a 2× spike); in the UI, chart points were built from New York wall-clock time, so both 1 AM hours merged. Fix: key every hourly row by date + hour-ending + EDT/EST, with one helper that turns the key into a fixed-offset time ([06 Q8](06-Jupiter-Load-Deal-Deep-Dive.md)).

**Likely follow-ups:** "Why did you poll in Jupiter but stream in Watt?" → "Our gateway cuts every request at a fixed time. Jupiter's Ask AI came first, so a job plus polling was the safe choice. Then I built a streaming library that closes each stream before the limit and resumes from the last event ID. Jupiter moved to it in October." · "What's a request waterfall?" · "A PnL calc takes 5 seconds. How do you keep the UI from feeling frozen?" (Skeletons, keep the previous data visible, show progress, cancel on navigation.)

---

### Q21. A page with a big trading grid feels slow. How do you find and fix the problem?  `[P0]`
**Say this first (~30 sec):** I measure first. I record the slow interaction with the React DevTools Profiler to see which components rendered, how often, and why. I use the browser's Performance panel, which has React tracks since 19.2, to find long tasks, and the Network tab for slow or serial requests. Fixes, in order: stop unnecessary re-renders; virtualize big lists so only visible rows are in the DOM; move heavy work off the render path; and batch high-frequency updates. For trading grids I'd use a grid built for this, like AG Grid, which updates rows by ID.

**If they dig deeper:**
- **Profiler:** turn on "Record why each component rendered" and "Highlight updates." Read the flame graph for the widest bars.
- **Virtualization:** 10,000 rows means 10,000+ DOM nodes. Windowing renders only the visible rows plus a small buffer. Options: TanStack Virtual, or AG Grid (on by default; it renders 10 extra rows above and below the view).
- **AG Grid with live data:**

```tsx
<AgGridReact<Deal>
  rowData={deals}
  columnDefs={cols}
  getRowId={(p) => p.data.dealId}
/>

// Live updates: send only the changed rows
gridRef.current?.api.applyTransactionAsync({
  update: changedDeals,
});
```

- `getRowId` works like a React `key`. Async transactions are batched (about every 50 ms) instead of replacing the whole `rowData` array.
- **Heavy calculations:** memoize, move them to the server, or use a Web Worker.
- **Measure in a production build.** Dev mode and StrictMode are slower on purpose.
- **Bundle size:** code-split (Q14) and check the bundle with an analyzer.
- **Core Web Vitals:** LCP (load), INP (responsiveness), CLS (layout shift).

**Your angle:** Jupiter and AMP both use AG Grid, and Watt and AMP send real-user data to **Datadog RUM** (page loads, slow interactions, errors). Two honest links. First, [S14](../AI%20Engineer/13-Behavioral-Story-Bank.md#s14): "On the AMP landing page, I measured where the time went end to end and fixed the biggest part first, and that was the backend." Second, [S9](../AI%20Engineer/13-Behavioral-Story-Bank.md#s9): "A grid that sends one request per row is the frontend version of the N+1 problem I fixed in the entitlements service." Your real practice: you analyze Datadog RUM data with Claude to see where users wait, and most of the slowness came from the backend, so that's where you fixed it. You haven't used the React Profiler. Say when you would: when the APIs are fast but a screen still renders slowly.
**Likely follow-ups:** "React Profiler vs Chrome Performance panel?" (The Profiler shows component renders; Chrome shows everything on the main thread.) · "How would you show 1,000 price updates per second?" (Batch them, update only changed cells by row ID, and never re-render the whole table.)

---

### Q22. How do you test React components?  `[P0]`
**Say this first (~30 sec):** I follow React Testing Library's idea: test what the user sees and does, not the implementation. I find elements by role and label, act with `user-event`, and check the visible result. I don't test internal state or which hooks ran, so refactors don't break tests. I run component tests with Vitest or Jest. I mock the network at the HTTP level with MSW, so components use their real fetch code. And I cover a few critical flows end to end with Playwright in a real browser.

**If they dig deeper:**

```tsx
test('shows error when qty is empty', async () => {
  const user = userEvent.setup();
  render(<DealForm />);
  await user.click(
    screen.getByRole('button', { name: /save/i })
  );
  expect(
    await screen.findByRole('alert')
  ).toHaveTextContent('Qty required');
});
```

```ts
// MSW handler (current docs import from
// 'msw/http')
import { http, HttpResponse } from 'msw/http';

export const handlers = [
  http.get('/api/deals/:id', ({ params }) =>
    HttpResponse.json({ id: params.id, qty: 5 })
  ),
];
```

- **Query priority:** `getByRole` first, then `getByLabelText` and `getByText`. `getByTestId` is the last resort.
- Use `findBy…` for async UI. Never use fixed sleeps.
- A bonus: role-based queries fail when markup isn't accessible, so tests push you toward good HTML.
- **Shape:** many fast component tests, some page-level tests with MSW, and a few E2E flows (log in, save a deal, permission checks).
- **Contract safety:** generate TypeScript types from the OpenAPI spec so the UI and API can't drift apart.
- Hooks: `renderHook`. Snapshot tests only for small, stable output.

**Your angle:** Strong, real evidence: you wrote **about two-thirds of the UI test files** across the Watt UI repos, with Vitest and Testing Library. Jupiter also uses Vitest. The 20-question eval set in Load Deal AI ([S1](../AI%20Engineer/13-Behavioral-Story-Bank.md#s1)) is the same philosophy: test the behavior users care about. No MSW: your tests use `vi.mock`, `vi.stubGlobal` for `fetch`, and `vi.fn`. **The one to describe:** Data Validation's conversation search test. With fake timers, it proves that three bursts of typing send **one** request after a 300 ms debounce, and that a slow older answer can't overwrite a newer one.
**Likely follow-ups:** "How do you test a component that fetches data?" (MSW plus `findBy…`.) · "What do you cover with E2E?" (The few flows that would hurt most if broken.)

---

### Q23. What are the basics of accessibility in React?  `[P1]`
**Say this first (~30 sec):** Start with semantic HTML: a real `<button>` for actions, `<a>` for navigation, a `<label>` linked to each input, headings in order, and `<table>` for tabular data. That gives you keyboard support and screen-reader names for free. Then check that everything works with the keyboard alone, that focus is visible and moves into a dialog and back, and that color isn't the only signal. Red and green PnL also needs a sign or an arrow. I add ARIA only when HTML has no native element, because bad ARIA is worse than none.

**If they dig deeper:**

```tsx
// Bad: no keyboard support, no role
<div onClick={save}>Save</div>

// Good
<button type="button" onClick={save}>
  Save
</button>

// An icon-only button needs a name
<button aria-label="Delete deal">
  <TrashIcon aria-hidden />
</button>
```

- In JSX it's `htmlFor`, not `for`. `useId` makes stable IDs for label/input pairs, and it's safe with SSR.
- Announce changes: `role="status"` for "Saved," `role="alert"` for errors.
- Data grids are hard to make accessible by hand. Use a grid library with keyboard navigation and check its accessibility docs.
- Tools: `eslint-plugin-jsx-a11y`, axe DevTools, Lighthouse, and VoiceOver on a Mac.
- W3C's guide says it directly: "No ARIA is better than bad ARIA."

**Your angle:** Trading users live on the keyboard, so keyboard support is a productivity feature, not only compliance. At Cerner ([S13](../AI%20Engineer/13-Behavioral-Story-Bank.md#s13)), the UI had to work with screen readers. In the Java UI you gave every button and box a description, so the reader could announce it. In React it's the same idea: a real `<button>` with text, or `aria-label` when there's only an icon. Wayfair had no accessibility requirement.
**Likely follow-ups:** "How do you make a modal accessible?" (The native `<dialog>` element, or: move focus in, trap it, close on Esc, return focus on close.)

---

### Q24. Class components vs function components. What do you do with legacy class code?  `[P2]`
**Say this first (~30 sec):** Function components with Hooks have been the standard since 2019, and react.dev recommends them for new code. Class components still work, and older codebases have them. The mapping is simple: `this.state` becomes `useState`, the mount/update/unmount methods become one `useEffect` with a cleanup, and `PureComponent` becomes `memo`. The one thing that still needs a class is an error boundary. I don't rewrite classes just for style; I convert one when I'm already changing it and there are tests around it.

**If they dig deeper:**

| Class | Function |
|---|---|
| `this.state` / `setState` | `useState` |
| `componentDidMount` etc. | `useEffect` + cleanup |
| `PureComponent` | `memo` |
| `createRef` | `useRef` |
| `componentDidCatch` | still a class |

- The thinking changes: classes ask "*when* does this run?" (lifecycle). Hooks ask "*what* should stay in sync?"
- No more `this` binding bugs.
- Higher-order components and render props are mostly replaced by custom Hooks.
- Before upgrading to React 19, look for removed APIs: string refs, legacy context, `defaultProps` on function components, and `ReactDOM.render`.

**Your angle:** AMP (React 18 on Create React App) is your real legacy codebase. It has no class components; the only class is a Dexie database class. "Same as a backend migration ([S11](../AI%20Engineer/13-Behavioral-Story-Bank.md#s11), Kronos to Kubernetes): move step by step, behind tests, highest value first." The CRA → Vite plan is in Q16.
**Likely follow-ups:** "What replaced HOCs?" (Custom Hooks.)

---

### Q25. How do you style React apps: CSS Modules, Tailwind, or CSS-in-JS?  `[P2]`
**Say this first (~30 sec):** **CSS Modules** are normal CSS files with class names scoped to one component: simple, with no runtime cost. **Tailwind** puts utility classes in the markup: fast to build a consistent UI and a small CSS output, but long class lists. **Runtime CSS-in-JS**, like styled-components or Emotion, writes styles in TypeScript with props. It's flexible, but it adds runtime cost, and with Server Components it only works in Client Components and needs extra setup. I follow the team's design system; for a new project I'd lean toward Tailwind or CSS Modules plus a component library.

**If they dig deeper:**
- Theming and dark mode: CSS variables work with any of these.
- Zero-runtime CSS-in-JS (for example, vanilla-extract or Panda CSS) generates CSS at build time.
- Component libraries (MUI, Ant Design, or Radix-based kits) save time on accessible widgets.
- Trading UIs need dense layouts, number alignment (`font-variant-numeric: tabular-nums`), and clear up/down colors.

**Your angle:** Watt uses **Tailwind**, with a shared ui-kit that a teammate built and that your apps use. Jupiter and AMP use Tailwind too. AMP has custom colors, a font and an extra-wide breakpoint (about 3,000 `className` uses), plus 12 global CSS files and about 106 inline styles, and no CSS modules or CSS-in-JS.

**Your Tailwind opinion** (keep only the points you agree with):
> "I like that the styles live next to the markup. I don't invent class names or hunt through CSS files, and when I delete a component, its styles go with it. The config gives everyone the same spacing and colors, which helped when contractors worked on the UI. It also works well with AI coding tools, because the class names are standard. What I dislike: long class lists make JSX hard to read, so I pull repeated pieces into small components. And it's easy to drift. On AMP we have Tailwind, plus 12 global CSS files and about a hundred inline styles, so there are three ways to style one thing. I'd pick one."

- **A gotcha to know:** Tailwind finds classes by reading your source as plain text. A class built at run time, like `` `text-${color}-600` ``, is never generated. Map each value to a full class name instead: `{ up: 'text-green-600', down: 'text-red-600' }` ([Tailwind docs](https://tailwindcss.com/docs/detecting-classes-in-source-files)).
**Likely follow-ups:** "How do you keep styles consistent across teams?" (Design tokens, a shared component library, and lint rules.)

---

## References
- [React Versions](https://react.dev/versions): the official list; confirms 19.3 is the latest.
- [Tailwind: detecting classes in source files](https://tailwindcss.com/docs/detecting-classes-in-source-files): why dynamic class names don't work (Q25).
- [React 19.3 release post](https://react.dev/blog/2026/09/09/react-19-3): View Transitions, Fragment refs, `browser()`, Trusted Types.
- [React 19.2 release post](https://react.dev/blog/2025/10/01/react-19-2): Activity, useEffectEvent, Performance Tracks, Partial Pre-rendering.
- [React v19 release post](https://react.dev/blog/2024/12/05/react-19): Actions, new hooks, ref as a prop, removed APIs.
- [React Compiler v1.0](https://react.dev/blog/2025/10/07/react-compiler-1): stable release and advice on useMemo/useCallback.
- [React Compiler introduction](https://react.dev/learn/react-compiler/introduction): what it does and how to adopt it.
- [Sunsetting Create React App](https://react.dev/blog/2025/02/14/sunsetting-create-react-app): why CRA is deprecated.
- [Creating a React App](https://react.dev/learn/creating-a-react-app): the recommended frameworks and the "from scratch" path.
- [Render and Commit](https://react.dev/learn/render-and-commit): the trigger → render → commit model.
- [Preserving and Resetting State](https://react.dev/learn/preserving-and-resetting-state): position, type, and key rules.
- [Rendering Lists](https://react.dev/learn/rendering-lists): why keys matter.
- [State as a Snapshot](https://react.dev/learn/state-as-a-snapshot) and [Queueing State Updates](https://react.dev/learn/queueing-a-series-of-state-updates): the useState mental model.
- [Sharing State Between Components](https://react.dev/learn/sharing-state-between-components): lifting state up.
- [Synchronizing with Effects](https://react.dev/learn/synchronizing-with-effects): effects, cleanup, and fetch races.
- [You Might Not Need an Effect](https://react.dev/learn/you-might-not-need-an-effect): the most-asked senior React article.
- [Separating Events from Effects](https://react.dev/learn/separating-events-from-effects): where useEffectEvent comes from.
- [Referencing Values with Refs](https://react.dev/learn/referencing-values-with-refs): refs vs state.
- [Passing Data Deeply with Context](https://react.dev/learn/passing-data-deeply-with-context): when to use Context.
- [Reusing Logic with Custom Hooks](https://react.dev/learn/reusing-logic-with-custom-hooks): naming and design of custom hooks.
- [Rules of Hooks](https://react.dev/reference/rules/rules-of-hooks): the official rules.
- [useActionState](https://react.dev/reference/react/useActionState) and [`<form>`](https://react.dev/reference/react-dom/components/form): React 19 forms.
- [useTransition](https://react.dev/reference/react/useTransition) and [useDeferredValue](https://react.dev/reference/react/useDeferredValue): concurrent features (and why deferring is not debouncing).
- [Suspense](https://react.dev/reference/react/Suspense) and [lazy](https://react.dev/reference/react/lazy): loading states and code splitting.
- [Activity](https://react.dev/reference/react/Activity): hiding UI while keeping state.
- [StrictMode](https://react.dev/reference/react/StrictMode): the development-only checks.
- [memo](https://react.dev/reference/react/memo): when memoization helps.
- [Component (class) reference](https://react.dev/reference/react/Component): error boundaries still need a class.
- [Server Components](https://react.dev/reference/rsc/server-components): the official explanation.
- [Critical security vulnerability in React Server Components (Dec 2025)](https://react.dev/blog/2025/12/03/critical-security-vulnerability-in-react-server-components): why Server Functions are a security surface.
- [React Developer Tools](https://react.dev/learn/react-developer-tools) and [React Performance Tracks](https://react.dev/reference/dev-tools/react-performance-tracks): profiling tools.
- [Next.js: Server and Client Components](https://nextjs.org/docs/app/getting-started/server-and-client-components): the App Router model.
- [Next.js: CSS-in-JS](https://nextjs.org/docs/app/guides/css-in-js): runtime CSS-in-JS only in Client Components.
- [react-error-boundary](https://github.com/bvaughn/react-error-boundary): the standard error boundary package.
- [TanStack Query overview](https://tanstack.com/query/latest/docs/framework/react/overview) and [caching guide](https://tanstack.com/query/latest/docs/framework/react/guides/caching): server state, `staleTime`, `gcTime`.
- [TkDodo: Practical React Query](https://tkdodo.eu/blog/practical-react-query): a maintainer's practical advice.
- [Redux Toolkit: Getting Started](https://redux-toolkit.js.org/introduction/getting-started) and [Zustand TypeScript guide](https://zustand.docs.pmnd.rs/learn/guides/beginner-typescript): client-state stores.
- [React Hook Form](https://react-hook-form.com/get-started): large forms with uncontrolled inputs.
- [AG Grid: DOM virtualisation](https://www.ag-grid.com/react-data-grid/dom-virtualisation/), [row IDs](https://www.ag-grid.com/react-data-grid/row-ids/), and [high-frequency updates](https://www.ag-grid.com/react-data-grid/data-update-high-frequency/): grids for trading data.
- [TanStack Virtual](https://tanstack.com/virtual/latest): headless list and table virtualization.
- [Testing Library: Guiding Principles](https://testing-library.com/docs/guiding-principles) and [query priority](https://testing-library.com/docs/queries/about/#priority): how to test like a user.
- [Mock Service Worker docs](https://mswjs.io/docs/), [Vitest guide](https://vitest.dev/guide/), and [Playwright intro](https://playwright.dev/docs/intro): the testing stack.
- [W3C APG: Read Me First](https://www.w3.org/WAI/ARIA/apg/practices/read-me-first/): "No ARIA is better than bad ARIA."
- [web.dev: Interaction to Next Paint (INP)](https://web.dev/articles/inp): the responsiveness Core Web Vital.
