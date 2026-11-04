# 02 · TypeScript Fundamentals

[← Index](00-Index.md) · **Interview priority:** High · **Read time:** ~45 min

> **Why this matters for this role:** You heard this interview is heavy on React and TypeScript. Every React answer and every live-coding exercise will be in TypeScript, so the interviewer will check that you can read, write, and explain types without stopping to think. Your honest frame: **a backend-heavy full-stack engineer who writes production React + TypeScript.** You have real UI code on Watt (React 19, TS, Vite; 239 commits across 4 UI repos), Jupiter (React 19, TS, Vite), and AMP (React 18, TS, CRA). Your strongest angle is the line between backend and frontend: typed API contracts and runtime validation, because you build both sides.

---

## Primer

### How TypeScript works: 5 facts

1. **TypeScript = JavaScript + types.** The compiler checks your types, then removes them. Browsers and Node.js only run plain JavaScript.
2. **Types exist only at compile time.** At runtime there are no types, no checks, and no reflection. `JSON.parse()` and `response.json()` return `any`. A type on API data is a promise you make, not a check (Q16).
3. **Structural typing.** Two types match if their *shapes* match, not their names. Java is nominal (names matter). Python's `Protocol` is the closest thing you already know.
4. **Checking and building are two separate jobs.** In a Vite app, esbuild strips the types *without* checking them. `tsc --noEmit` does the real check, in your editor and in CI. Vite's docs say this directly: it does not type-check.
5. **Strict mode** turns on the checks that matter most: null checks, no implicit `any`, and more. Since TypeScript 6.0, `strict` is on by default.

**Inference:** you write fewer types than you expect. Annotate function parameters, exported functions, and public APIs. Let TypeScript infer local variables.

### Where TypeScript is in Nov 2026

*Verified Nov 3, 2026 on the TypeScript blog and npm.*

- **TypeScript 7.0** (July 2026) is the current stable version. npm `latest` is **7.0.2**.
  - The compiler and editor service were ported to **Go** ("native TypeScript").
  - Full builds are typically **8–12× faster**, and it uses multiple CPU cores.
  - The type-checking rules are the same as 6.0.
- **TypeScript 6.0** (March 2026) was the **last JavaScript-based** version. It was a "bridge" to 7.0:
  - New defaults: `strict: true`, `module: esnext`, `target` = latest ES version, `types: []`.
  - Deprecated old options: `target: es5`, `moduleResolution: node`, `baseUrl`, AMD/UMD modules. In 7.0 these are now errors.
- **TypeScript 7.1** is in **beta** (Oct 20, 2026). Its big addition is a new programmatic API. Until it ships, tools that embed the compiler (typescript-eslint, Vue/Svelte/Astro editor tooling) still run on 6.0 through the `@typescript/typescript6` package.
- **Node.js runs `.ts` files directly** by stripping the types (stable since Node v25.2.0 and v24.12.0). It only supports "erasable" syntax, so no `enum` and no `namespace` with code. The TS flag `erasableSyntaxOnly` enforces the same rule.

**If asked:** "TS 7 is the Go port: same type system, about ten times faster builds. 6.0 was the bridge release that made `strict` the default." `[fill in: which TS version Watt and Jupiter are on today]`

### What you know → TypeScript

| You know | TypeScript |
|---|---|
| Python `Protocol` | every type (structural) |
| Python `TypedDict` | `type` / `interface` |
| Python `Literal["a"]` | `"a"` literal type |
| Python `X \| None` | `X \| null` |
| Python `Any` | `any` |
| Python `object` | `unknown` |
| Python `NoReturn` | `never` |
| Python `TypeIs` | `x is T` predicate |
| Pydantic model | zod schema |
| Java `<T extends X>` | same syntax |
| Java interface | interface, but structural |

### Syntax to recognize on sight

```ts
let id: string | number;      // union
type AB = A & B;              // intersection
type P = { x?: number };      // optional prop
type R = { readonly id: string };
let xs: string[];             // = Array<string>
let t: [string, number];      // tuple
let f: (n: number) => string; // function type
function same<T>(x: T): T     // generic
type K = keyof Deal;          // key names
type V = Deal["price"];       // indexed access
type C = typeof config;       // type of a value
type M = { [K in keyof T]: boolean }; // mapped
type Z = T extends string ? 1 : 0;    // conditional
type E = T extends (infer U)[] ? U : T; // infer
type Url = `/api/${string}`;  // template literal
const m = ["GET"] as const;   // readonly literals
x!.name                       // non-null assertion
x as Deal                     // type assertion
cfg satisfies Config          // check, keep type
(v: unknown): v is Deal       // type predicate
(v: unknown): asserts v       // assertion function
user?.book?.name              // optional chaining
qty ?? 0                      // nullish fallback
import type { Deal } from "./api";
```

---

## Questions & answers

### Q1. What is TypeScript, and what happens to your types at runtime?  `[P0]`
**Say this first (~30 sec):** TypeScript is JavaScript with a static type system on top. The compiler checks the types and then erases them, so at runtime it is plain JavaScript with no type information. I get two things from it: bugs caught before the code runs, and safe refactoring with good editor support. The limit is that types only protect code I control. Anything that comes from outside, like an API response, must be validated at runtime.

**If they dig deeper:**
- **Erased means erased:**
  ```ts
  type Deal = { id: string; price: number };
  const d = (await res.json()) as Deal;
  // No runtime check happens here.
  // If price is missing, you find out later.
  ```
- **Structural, not nominal:** any object with `id: string` and `price: number` *is* a `Deal`. No `implements` needed.
- **Not 100% safe, on purpose:** `any`, `as`, and `arr[i]` (assumed never `undefined`) can all hide bugs. `strict` plus `noUncheckedIndexedAccess` closes most of the gaps.
- **A few features do generate code:** `enum`, `namespace`, and constructor parameter properties. That is why Node's type stripping and `erasableSyntaxOnly` reject them.
- **Version:** TS 7 (July 2026) is the Go port, about 10× faster builds, same type system.

**Your angle:** Bridge from what you know. "Java checks types at compile time and keeps them at runtime. Python keeps runtime types but only checks hints with a tool like mypy. TypeScript checks at compile time and keeps nothing at runtime. So at the edges of the app I validate, like Pydantic does in Python." Then make it concrete: "I write TypeScript every week on our Watt and Jupiter UIs, both React 19 with Vite." `[fill in: is strict on in the Watt and Jupiter tsconfig?]`
**Likely follow-ups:** "Then why use it?" (refactoring safety, editor help, contracts between teams) · "How do you validate API data?" (Q16)

---

### Q2. `type` vs `interface`: what's the difference, and which do you use?  `[P0]`
**Say this first (~30 sec):** For an object shape, they are almost the same. The real differences: `type` can name *any* type, like unions, tuples, and mapped types, while `interface` only describes object shapes. `interface` supports declaration merging, and `extends` gives a clear error when properties conflict. My rule is to follow the team's convention. With no convention, I use `type` for props and unions, and `interface` for object contracts that others may extend.

**If they dig deeper:**
- Only `type` can do these:
  ```ts
  type Status = "draft" | "booked"; // union
  type Pair = [string, number];     // tuple
  type Flags<T> = { [K in keyof T]: boolean };
  ```
- Only `interface` merges, which is how you add fields to a library or global type (Q19):
  ```ts
  interface Window { appConfig: AppConfig }
  ```
- **Conflicts:** `interface B extends A` with a clashing property is an error right away. `type B = A & {…}` silently makes that property `never`.
- **Performance:** the TypeScript team's performance guide prefers interfaces over large intersections, because the checker caches interface relationships. This only matters in very large codebases.
- **The handbook's heuristic** is "use `interface` until you need features from `type`". Many React codebases do the opposite. Being consistent matters more than the choice.

**Your angle:** A senior answer picks a rule and gives the reason. Use the codebases you work in: `[fill in: do Watt and Jupiter use type or interface for props? Is it enforced by lint?]`
**Likely follow-ups:** "Can an interface extend a type?" (yes, if the type is an object shape) · "When is declaration merging useful?" (adding fields to `Window` or a library type)

---

### Q3. `any` vs `unknown` vs `never`?  `[P0]`
**Say this first (~30 sec):** `any` turns off type checking for a value, and it spreads: whatever you read from it is also `any`. `unknown` also accepts any value, but you can't use it until you narrow it, so it's the safe choice for data with an unknown shape, like parsed JSON or a caught error. `never` is the type with no values. It appears for functions that always throw, for impossible branches, and in exhaustive checks.

**If they dig deeper:**
```ts
let a: any = JSON.parse(s);
a.foo.bar();   // compiles, may crash

let u: unknown = JSON.parse(s);
u.foo;         // error: 'u' is of type 'unknown'
if (typeof u === "string") u.trim(); // OK

function fail(msg: string): never {
  throw new Error(msg);
}
type X = string & number;  // never
```
- **Catch variables:** under `strict`, `catch (e)` gives `e: unknown`. Narrow with `e instanceof Error`.
- **As sets of values:** `unknown` = all values (top type). `never` = no values (bottom type). `any` = "switch off the checker", which is why it's unsafe.
- **In code review:** flag new `any`. Ask for `unknown` plus narrowing, or a real type. The lint rule is `@typescript-eslint/no-explicit-any`.

**Your angle:** In [M1](../AI%20Engineer/13-Behavioral-Story-Bank.md#m1) you reviewed the frontend contractors' pull requests, and you write UI code and tests yourself. If it's true, give one real example. `[fill in: an any, as, or missing null check you flagged in review or fixed in your own code]`
**Likely follow-ups:** "When is `any` acceptable?" (during a JS-to-TS migration, with a comment and a ticket) · "`void` vs `never`?" (`void` returns nothing useful; `never` never returns at all)

---

### Q4. Explain union and intersection types.  `[P0]`
**Say this first (~30 sec):** A union `A | B` means the value is *one of* these types, so until I narrow it, I can only use what they have in common. An intersection `A & B` means the value is *all of* them at once, so it has every property from both. The names feel backwards at first: a union of object types gives you *fewer* safe properties, and an intersection gives you *more*. In React I use unions for state with different modes, and intersections to combine prop types.

**If they dig deeper:**
```ts
type Cash = { kind: "cash"; amount: number };
type Swap = { kind: "swap"; legs: number };

function show(d: Cash | Swap) {
  d.kind;    // OK: on both
  d.amount;  // error: does not exist on 'Swap'
}

type WithId = { id: string };
type Row = Cash & WithId; // kind, amount, id
```
- **Impossible intersections become `never`:** `string & number` is `never`. `{ a: string } & { a: number }` gives `a: never`.
- **Common React use:**
  ```ts
  type Props = ComponentProps<"button"> & {
    variant: "primary" | "ghost";
  };
  ```
- **Set view:** a union allows *more* values, so you know *less* about any one value.
- **Python:** `A | B` is the same idea. Python typing has no built-in intersection type.

**Your angle:** On AMP you built the admin forms for users *and* service principals. "A principal is a user or a service principal" is a natural union type. `[fill in: how the form types handled the two kinds]` Python bridge: `Optional[X]` is just `X | None`, the same as `string | null` in TS.
**Likely follow-ups:** "How do you use a union safely?" (narrowing, Q5) · "What's a discriminated union?" (Q6)

---

### Q5. How does narrowing work? Which type guards do you use?  `[P0]`
**Say this first (~30 sec):** Narrowing is TypeScript following my `if` checks and making a type more specific inside each branch. The built-in guards are `typeof` for primitives, `instanceof` for classes like `Date` or `Error`, `in` to check that a property exists, equality checks like `=== null`, and checks on a shared literal field. When those aren't enough, I write a custom type predicate (`x is Deal`) or an assertion function that throws if the check fails.

**If they dig deeper:**
```ts
function fmt(v: string | number | Date | null) {
  if (v === null) return "-";          // equality
  if (typeof v === "string") return v; // typeof
  if (v instanceof Date) {             // instanceof
    return v.toISOString();
  }
  return v.toFixed(2);                 // number
}
```
- **`in` narrowing:**
  ```ts
  type Ok = { data: Deal[] };
  type Err = { error: string };

  function handle(r: Ok | Err) {
    if ("error" in r) return r.error;
    return r.data.length;
  }
  ```
- **Custom type predicate:**
  ```ts
  function isDeal(x: unknown): x is Deal {
    return typeof x === "object" && x !== null
      && "id" in x && typeof x.id === "string";
  }
  ```
  TS *trusts* the predicate. If the body is wrong, the type is wrong. For API data, a schema library (Q16) is safer than hand-written guards.
- **Assertion function:**
  ```ts
  function assertDefined<T>(
    v: T, msg: string,
  ): asserts v is NonNullable<T> {
    if (v == null) throw new Error(msg);
  }

  assertDefined(user, "no user");
  user.name; // non-null from here on
  ```
- **Truthiness trap:** `if (qty)` also removes `0` and `""`. For numbers, check `qty != null`.
- **Since TS 5.5:** `arr.filter((x) => x !== null)` infers a type predicate, so the result type no longer includes `null`.

**Your angle:** Python bridge: mypy narrows on `isinstance()` the same way, and `TypeGuard` / `TypeIs` are Python's version of `x is T`.
**Likely follow-ups:** "Predicate vs assertion function?" (a predicate returns a boolean and narrows inside the `if`; an assertion throws and narrows everything after the call) · "Why `== null`?" (it matches both `null` and `undefined`)

---

### Q6. What is a discriminated union, and how do you make a `switch` exhaustive?  `[P0]`
**Say this first (~30 sec):** A discriminated union is a union of object types that share one literal field, like `status` or `kind`. Checking that field tells TypeScript exactly which variant I have. It's my default way to model UI state, because it makes impossible states impossible: you can't have `data` and `error` at the same time. For exhaustiveness, the `default` branch passes the value to a function that takes `never`. If someone adds a new variant later, every `switch` that doesn't handle it becomes a compile error.

**If they dig deeper:**
```ts
type Load<T> =
  | { status: "idle" }
  | { status: "loading" }
  | { status: "success"; data: T }
  | { status: "error"; error: string };

function label(s: Load<Deal[]>): string {
  switch (s.status) {
    case "idle": return "Not started";
    case "loading": return "Loading…";
    case "success": return `${s.data.length} deals`;
    case "error": return s.error;
    default: return assertNever(s);
  }
}

function assertNever(x: never): never {
  throw new Error(`Unexpected: ${JSON.stringify(x)}`);
}
```
- **Add `{ status: "cancelled" }` and you get:** "Argument of type '{ status: "cancelled"; }' is not assignable to parameter of type 'never'."
- **Compare with optional fields:**
  ```ts
  type Bad<T> = {
    loading: boolean;
    data?: T;
    error?: string;
  };
  // loading AND error both set? Allowed. Bug.
  ```
- **Same pattern elsewhere:** `useReducer` actions (`{ type: "add" } | { type: "remove"; id: string }`), API results, and zod's `safeParse` result (`{ success: true; data } | { success: false; error }`).
- **Watch out for backend enums:** if the backend adds a new status before the frontend updates, the runtime value matches no case. Handle unknown values at the boundary (Q16, Q18).

**Your angle:** You have two real examples. On Jupiter you built the Ask AI chat page ([S1](../AI%20Engineer/13-Behavioral-Story-Bank.md#s1)): it polls a job, and an answer can be SQL, a table, or a chart. Both the job state and the answer type are natural discriminated unions. On Watt, the Data Validation UI shows run history, and runs have statuses too. `[fill in: the real state names, and how you typed the answer variants]` Use these instead of a made-up example.
**Likely follow-ups:** "Model this with `useReducer`." (see [03 · React Fundamentals](03-React-Fundamentals.md)) · "How does `assertNever` help at runtime?" (it throws with the bad value, so you see it in logs)

---

### Q7. Explain generics and constraints.  `[P0]`
**Say this first (~30 sec):** Generics let me write one function or type that works for many types while keeping the link between input and output. `first<T>(items: T[]): T | undefined` returns the same type it receives, not `any`. A constraint with `extends` limits what `T` can be, like `T extends { id: string }`, so I can safely read `item.id`. Type parameters can have defaults, like `ApiResponse<T = unknown>`. Usually TypeScript infers `T` from the arguments, so callers rarely write it.

**If they dig deeper:**
```ts
function byId<T extends { id: string }>(
  items: T[],
): Record<string, T> {
  return Object.fromEntries(
    items.map((i) => [i.id, i]),
  );
}

function getProp<T, K extends keyof T>(
  obj: T, key: K,
): T[K] {
  return obj[key];
}
getProp(deal, "volumeMwh"); // number
getProp(deal, "volumeMhw"); // error: not a key

type ApiResponse<T = unknown> = {
  data: T;
  requestId: string;
};
```
- **A common live-coding ask, `groupBy`:**
  ```ts
  function groupBy<T, K extends PropertyKey>(
    items: T[],
    keyOf: (item: T) => K,
  ): Partial<Record<K, T[]>> {
    const out: Partial<Record<K, T[]>> = {};
    for (const item of items) {
      const k = keyOf(item);
      (out[k] ??= []).push(item);
    }
    return out;
  }
  ```
  ES2024 also has a built-in `Object.groupBy` with the same return type.
- **Handbook rule:** "Type parameters should appear twice." If `T` is used only once, you probably don't need a generic.
- **Newer tools:** `const` type parameters (TS 5.0) infer literal types: `<const T>(x: T)`. `NoInfer<T>` (TS 5.4) stops inference from one argument.
- **Java/Python:** same idea as Java's `<T extends Comparable<T>>` and Python's `TypeVar` with a `bound`. Like Java, type arguments are erased at runtime. Unlike Java, matching is structural.

**Your angle:** Shared packages are where generics really pay off. On Watt you built a shared admin-kit package that 3 apps use ([S3](../AI%20Engineer/13-Behavioral-Story-Bank.md#s3)). `[fill in: any generic component or hook in admin-kit, e.g., a table, form, or data hook typed by row]` A typed API client, `get<T>(path, schema)`, is the other classic example.
**Likely follow-ups:** "Write a generic hook." (practice in [04 · React Coding Exercises](04-React-Coding-Exercises.md)) · "What does `K extends keyof T` mean?" (K must be one of T's key names, Q8)

---

### Q8. What do `keyof`, `typeof`, and indexed access types do?  `[P1]`
**Say this first (~30 sec):** They let me *derive* types instead of writing them twice. `keyof T` gives the union of T's property names. `typeof value`, in a type position, gives the type of a JavaScript value. `T["key"]` reads the type of one property, and `T[number]` reads the element type of an array. Together they let me write a list once, as a constant, and get the matching type automatically.

**If they dig deeper:**
```ts
type Deal = { id: string; price: number };
type DealKey = keyof Deal;   // "id" | "price"
type Price = Deal["price"];  // number

const STATUSES = ["draft", "booked", "settled"] as const;
type Status = (typeof STATUSES)[number];
// "draft" | "booked" | "settled"

const config = { retries: 3, baseUrl: "/api" };
type Config = typeof config;
// { retries: number; baseUrl: string }
```
- **Two different `typeof`s:** `typeof x === "string"` in an expression is the JavaScript runtime operator. `type C = typeof config` is the TypeScript type operator. Same word, different jobs.
- **Gotcha:** for `{ [k: string]: number }`, `keyof` gives `string | number`, because JavaScript turns number keys into strings.
- **Why it matters:** add `"cancelled"` to the array and the `Status` type, the dropdown options, and the exhaustive `switch` checks all update together.

**Your angle:** Any fixed list in your UIs works. `[fill in: e.g., rule or monitor types in the Data Validation UI, or tab names on the AMP asset dashboard]`
**Likely follow-ups:** "What's `keyof typeof obj`?" (the key names of a runtime object; common with `as const` objects, Q11)

---

### Q9. Which utility types do you use most?  `[P0]`
**Say this first (~30 sec):** Daily: `Partial` and `Required` flip optional fields. `Pick` and `Omit` select or remove fields. `Record<K, V>` is a typed dictionary. `ReturnType` and `Parameters` read a function's types, `Awaited` unwraps a Promise, and `NonNullable` removes `null` and `undefined`. The main use is deriving related types from one model, like a create payload and an update payload from the same `Deal` type, so they can't drift apart.

**If they dig deeper:**

| Utility | Result |
|---|---|
| `Partial<T>` | all props optional |
| `Required<T>` | all props required |
| `Readonly<T>` | all props readonly |
| `Pick<T, K>` | only keys K |
| `Omit<T, K>` | all keys except K |
| `Record<K, V>` | keys K, values V |
| `Exclude<U, X>` | drop union members |
| `Extract<U, X>` | keep union members |
| `NonNullable<T>` | drop null/undefined |
| `ReturnType<F>` | function's return |
| `Parameters<F>` | params as a tuple |
| `Awaited<T>` | unwrap a Promise |

```ts
type Deal = {
  id: string;
  counterparty: string;
  volumeMwh: number;
  createdAt: string;
};

type NewDeal = Omit<Deal, "id" | "createdAt">;
type DealPatch = Partial<NewDeal>;
type DealRow = Pick<Deal, "id" | "counterparty">;
type DealsById = Record<string, Deal>;

declare function loadDeals(): Promise<Deal[]>;
type Loaded = Awaited<ReturnType<typeof loadDeals>>;
// Deal[]
```
- **Gotchas:**
  - `Omit` doesn't check the key exists: `Omit<Deal, "typo">` compiles.
  - `Partial` is shallow: nested objects stay required.
  - `Omit` on a union type does not apply to each member, so a discriminated union loses its variants.
- **Under the hood:** `Partial<T>` is just `{ [K in keyof T]?: T[K] }` (Q10).

**Your angle:** You built real create and edit forms: rules and monitors in the Watt Data Validation UI, and the outage-management and admin forms on AMP. That is where `Omit` and `Partial` pay off. `[fill in: how you typed the create vs edit payloads in one of them]`
**Likely follow-ups:** "Implement `Partial` yourself." (Q10) · "`Exclude` vs `Omit`?" (`Exclude` removes members of a union; `Omit` removes keys of an object)

---

### Q10. Explain mapped types and conditional types with `infer`, in simple terms.  `[P1]`
**Say this first (~30 sec):** A mapped type is a *for-loop over keys*: it builds a new object type by going through each key of another type. A conditional type is an *if-statement for types*: `T extends U ? X : Y`. `infer` lets a conditional type *capture* part of a type, like a capture group in a regex. Most built-in utility types are written this way. In app code I mostly read these in library types, and I write them only when they remove real duplication.

**If they dig deeper:**
- **Mapped:**
  ```ts
  type MyPartial<T> = { [K in keyof T]?: T[K] };
  type Flags<T> = { [K in keyof T]: boolean };
  type Mutable<T> = {
    -readonly [K in keyof T]: T[K];
  };
  ```
- **Renaming keys with `as`:**
  ```ts
  type Getters<T> = {
    [K in keyof T & string as `get${Capitalize<K>}`]:
      () => T[K];
  };
  // Getters<{ id: string }>
  //   = { getId: () => string }
  ```
- **Conditional + `infer`:**
  ```ts
  type ElementOf<T> =
    T extends (infer U)[] ? U : T;
  type A = ElementOf<Deal[]>;  // Deal

  type MyReturn<T> =
    T extends (...a: any[]) => infer R ? R : never;

  type MyExclude<T, U> = T extends U ? never : T;
  ```
- **Distribution:** when `T` is a union, the conditional runs once per member. `ElementOf<string[] | number[]>` is `string | number`. That's how `Exclude` drops members. Write `[T] extends [U]` to turn it off.
- **Template literal types:** `` `on${Capitalize<"click">}` `` is `"onClick"`. Useful for event names and route strings.
- **Use sparingly:** complex type-level code is hard for teammates to read and slows the checker.

**Your angle:** Honest framing, if it's true for you: "I'm comfortable reading these and I've written simple ones. In app code I prefer plain, clear types over clever ones." `[fill in: a mapped or conditional type you actually wrote, if any]`
**Likely follow-ups:** "Write `DeepPartial<T>`." (`{ [K in keyof T]?: T[K] extends object ? DeepPartial<T[K]> : T[K] }`) · "What does `infer` do?" (captures part of a type for use in the true branch)

---

### Q11. What are literal types and `as const`? `enum` or a union of strings?  `[P1]`
**Say this first (~30 sec):** A literal type is one exact value used as a type, like `"GET"` or `42`. `const x = "GET"` gets the literal type, but `let x = "GET"` widens to `string`, and so do object properties. `as const` stops the widening: everything becomes readonly and literal. For a fixed set of values I prefer a union of string literals over `enum`. A union has no runtime code, works with plain strings from JSON, and fits the "erasable syntax" direction of modern tools. If I need the values at runtime, I use an `as const` object and derive the type from it.

**If they dig deeper:**
- **Widening, and the error it causes:**
  ```ts
  type Method = "GET" | "POST";
  declare function send(m: Method): void;

  const req = { method: "GET" };
  send(req.method);
  // error: Argument of type 'string' is not
  // assignable to parameter of type 'Method'.

  const req2 = { method: "GET" } as const;
  send(req2.method); // OK: type is "GET"
  ```
- **The enum replacement:**
  ```ts
  export const DealStatus = {
    Draft: "draft",
    Booked: "booked",
  } as const;

  export type DealStatus =
    (typeof DealStatus)[keyof typeof DealStatus];
  // "draft" | "booked"
  ```
- **Enum downsides:** enums emit JavaScript, so Node's type stripping and `erasableSyntaxOnly` reject them. A string enum won't accept a plain string (`enum Color { Red = "RED" }`, then `const c: Color = "RED"` is an error), so JSON data needs casts. `const enum` causes problems in per-file builds (`isolatedModules`).
- **Enum upsides:** a named runtime object, and some teams like the `Status.Draft` style.
- **Other fixes for widening:** an explicit annotation (`const req: { method: Method }`) or `satisfies` (Q12).

**Your angle:** Permission keys are a good example, and you built the UI side yourself: entitlement-based access checks on AMP, and the Admin tab in the Watt shell. Both sit on the shared entitlements service ([S9](../AI%20Engineer/13-Behavioral-Story-Bank.md#s9)). A union like `"deal:edit" | "deal:view"` catches typos at compile time. `[fill in: how permission keys are typed in the AMP and Watt UIs]`
**Likely follow-ups:** "Type of `["a", "b"] as const`?" (`readonly ["a", "b"]`) · "Can you loop over a union at runtime?" (no; start from an `as const` array, Q8)

---

### Q12. `satisfies` vs a type annotation vs `as`: when do you use each?  `[P1]`
**Say this first (~30 sec):** An annotation, `const x: T = …`, checks the value *and* changes its type to `T`, so I lose the specific details. `satisfies T`, added in TS 4.9, checks the value against `T` but *keeps the inferred type*, so I get both validation and precise types. `as T` is an assertion: it tells the compiler "trust me" and checks very little. My order of preference: inference, then annotation or `satisfies`, and `as` only as a last resort, usually right after a runtime check.

**If they dig deeper:**
```ts
type Route = { path: string; auth: boolean };

const a: Record<string, Route> = {
  home: { path: "/", auth: false },
};
a.hmoe; // no error: any string key is allowed

const b = {
  home: { path: "/", auth: false },
  deals: { path: "/deals", auth: true },
} satisfies Record<string, Route>;
b.hmoe; // error: Property 'hmoe' does not exist
type Page = keyof typeof b; // "home" | "deals"
```
- **`as` hides bugs easily:**
  ```ts
  const d = {} as Deal;  // compiles
  d.price.toFixed(2);    // crashes at runtime
  ```
  TS only blocks `as` between types that don't overlap at all ("Conversion of type 'number' to type 'string' may be a mistake…"). `as unknown as X` gets around even that. In review, a double cast is a warning sign.
- **Reasonable uses of `as`:** `as const`, test fixtures, and a value that was just validated. For DOM elements, `instanceof HTMLInputElement` is safer than `as`.
- **Combined:** `as const satisfies Record<string, Route>` gives readonly literals *and* a check.

**Your angle:** Config objects are where `satisfies` fits best: route tables, feature flags, chart settings. Watt and Jupiter use React Router, Recharts, and Vega-Lite, which all take config objects. `[fill in: a route table or chart config in your code where satisfies fits, or already used]`
**Likely follow-ups:** "What's the `!` operator?" (an `as` for null: "not null, trust me"; same risks) · "When is `as` unavoidable?" (some generic code where TS can't follow the logic)

---

### Q13. What's the type error here? (Structural typing and excess property checks)  `[P1]`

```ts
type Point = { x: number; y: number };
function draw(p: Point) { /* ... */ }

draw({ x: 1, y: 2, z: 3 });   // (1)

const p3 = { x: 1, y: 2, z: 3 };
draw(p3);                     // (2)
```

**Say this first (~30 sec):** Line (1) is an error: "Object literal may only specify known properties, and 'z' does not exist in type 'Point'." Line (2) compiles. TypeScript is structural, so any object with at least `x` and `y` as numbers is a valid `Point`, and extra properties are normally fine. The excess property check is a special rule *only for fresh object literals*, because an unknown key written directly in a literal is usually a typo. Once the object is in a variable, the rule no longer applies.

**If they dig deeper:**
- **What a type really promises:** "has *at least* these fields", not "has *only* these fields".
- **Security consequence:** extra fields can leak.
  ```ts
  type PublicUser = { id: string; name: string };
  function toJson(u: PublicUser) {
    return JSON.stringify(u);
  }
  const user = { id: "1", name: "Kurt", pwHash: "x" };
  toJson(user); // compiles, and sends pwHash
  ```
  Pick fields explicitly, or parse with a schema. zod's `z.object` strips unknown keys by default; `z.strictObject` rejects them.
- **When you need nominal types**, for example IDs that are all strings but must not be mixed, use a "brand":
  ```ts
  type DealId = string & { readonly __brand: "DealId" };
  type UserId = string & { readonly __brand: "UserId" };
  declare function loadDeal(id: DealId): void;
  loadDeal(userId); // error
  ```
- **Functions are structural too:** a callback with fewer parameters is fine where more are offered. That's why `arr.map((x) => …)` works without the index.

**Your angle:** Same instinct as your fail-closed entitlements work ([S9](../AI%20Engineer/13-Behavioral-Story-Bank.md#s9)): a type is not a security check, so be explicit about what leaves the system. Java bridge: "In Java, two classes with the same fields are different types. In TypeScript, they are the same type."
**Likely follow-ups:** "Can a type reject extra keys?" (not reliably; validate at runtime with a strict schema) · "Why does `Object.keys` return `string[]`?" (Q20c)

---

### Q14. What does this print? (`||` vs `??`, optional chaining, strict null checks)  `[P0]`

```ts
type Pos = {
  volume: number | null;
  book?: { name: string };
};
const pos: Pos = { volume: 0 };

console.log(pos.volume || 100); // (1)
console.log(pos.volume ?? 100); // (2)
console.log(pos.book?.name);    // (3)
console.log(pos.book.name);     // (4)
```

**Say this first (~30 sec):** (1) prints `100`, because `||` treats every falsy value as missing, including `0`. (2) prints `0`, because `??` only falls back on `null` or `undefined`. (3) prints `undefined`: optional chaining stops at the missing `book` instead of throwing. (4) doesn't compile under `strictNullChecks`: "'pos.book' is possibly 'undefined'." Without strict mode it would compile and then throw a TypeError at runtime.

**If they dig deeper:**
- **`strictNullChecks`** (part of `strict`): `null` and `undefined` are no longer allowed in every type, so you must handle them. That removes JavaScript's most common crash.
- **Optional chaining stops the whole chain:** `a?.b.c` returns `undefined` if `a` is nullish, without evaluating `.c`. It also works for calls, `onSave?.()`, and indexes, `rows?.[0]`.
- **`??=`** assigns only when the left side is nullish: `cache[key] ??= compute()`.
- **Mixing:** `a ?? b || c` is a syntax error. You must add parentheses.
- **Non-null assertion:** `pos.book!.name` compiles but crashes if `book` is missing. Prefer a check.
- **Optional vs `| undefined`:** `book?: X` means the key may be missing. `book: X | undefined` means the key must exist but may hold `undefined`. The `exactOptionalPropertyTypes` flag enforces the difference.

**Your angle:** In trading data, `0` is a real value. A zero volume or zero PnL is not "missing", and `value || default` would silently replace it. You built PnL screens on Jupiter (PnL Summary on the live API, Portfolio PnL history) on top of your PnL engine ([S8](../AI%20Engineer/13-Behavioral-Story-Bank.md#s8)), so this shows you think about data correctness, not just syntax. `[fill in: a real null-vs-zero case you handled, if any]`
**Likely follow-ups:** "`null` vs `undefined` in practice?" (JSON and APIs use `null`; JS uses `undefined` for missing; pick one convention per API) · "Why not turn strict off?" (you lose the main benefit of TypeScript)

---

### Q15. Which `tsconfig.json` settings matter, and why?  `[P1]`
**Say this first (~30 sec):** First, `strict: true` for the core safety checks; it's the default since TS 6.0. Second, `noUncheckedIndexedAccess`, so `arr[i]` and `record[key]` include `undefined`; it isn't part of `strict`, but I turn it on. `target` sets which JavaScript syntax version to output. `module` and `moduleResolution` control imports: `bundler` for apps built with Vite or Next.js, `nodenext` for Node.js code. In a bundled React app I also set `noEmit`, because the bundler builds the code and `tsc` only type-checks.

**If they dig deeper:**
```jsonc
{
  "compilerOptions": {
    "strict": true,
    "noUncheckedIndexedAccess": true,
    "target": "es2022",
    "lib": ["es2022", "dom"],
    "module": "esnext",
    "moduleResolution": "bundler",
    "jsx": "react-jsx",
    "noEmit": true,
    "isolatedModules": true,
    "verbatimModuleSyntax": true,
    "skipLibCheck": true,
    "types": ["vite/client"]
  },
  "include": ["src"]
}
```
- **What `strict` turns on:** `strictNullChecks`, `noImplicitAny`, `strictFunctionTypes`, `strictPropertyInitialization`, `useUnknownInCatchVariables`, and a few more.
- **`noUncheckedIndexedAccess` in action:**
  ```ts
  const prices: number[] = [];
  const p = prices[0];  // number | undefined
  p.toFixed(2);  // error: 'p' is possibly 'undefined'
  ```
- **`target` vs `lib`:** `target` is the syntax TS outputs. `lib` is which built-in APIs TS believes exist. Neither adds polyfills.
- **`isolatedModules` / `verbatimModuleSyntax`:** every file must compile on its own, which esbuild and SWC need. In practice: write `import type { Deal }` for type-only imports.
- **TS 6/7 changes to know:** `types` now defaults to `[]`, so list the global types you need (`"node"`, `"vite/client"`). `baseUrl`, `moduleResolution: "node"`, and `target: "es5"` are errors in 7.0.
- **Moving a JS codebase to TS:** `allowJs`, convert file by file, be strict on new code, and use `// @ts-expect-error` (not `@ts-ignore`), which itself errors once the problem is fixed.

**Your angle:** You work with both build styles. Watt and Jupiter use Vite, so the type check must run as its own step: `[fill in: does CI run tsc --noEmit or tsc -b?]`. AMP uses Create React App, which the React team deprecated for new apps in Feb 2025, so moving it to Vite is a good "what would you improve?" answer. If strict is off anywhere: "I'd turn it on gradually, folder by folder, and track the error count down to zero."
**Likely follow-ups:** "Does your build type-check?" (Vite doesn't; run `tsc --noEmit` or `tsc -b` in CI) · "What's `skipLibCheck`?" (skip checking `.d.ts` files in `node_modules`; faster builds)

---

### Q16. The API response has a type. Is it safe? How do you handle runtime boundaries?  `[P0]`
**Say this first (~30 sec):** No. `response.json()` returns `any`, and a type on it is only a promise, not a check. If the backend changes a field, the UI breaks far from the cause. So at every boundary (API responses, `localStorage`, URL params, WebSocket messages, and LLM output) I validate at runtime with a schema library like zod. I infer the TypeScript type *from* the schema, so there is one source of truth. For our own backend, I also generate types from its OpenAPI spec, so both sides share one contract.

**If they dig deeper:**
```ts
import { z } from "zod";

const Deal = z.object({
  id: z.string(),
  volumeMwh: z.number(),
  status: z.enum(["draft", "booked"]),
  createdAt: z.iso.datetime(),
});
type Deal = z.infer<typeof Deal>;

async function getDeal(id: string): Promise<Deal> {
  const res = await fetch(`/api/deals/${id}`);
  if (!res.ok) throw new Error(`HTTP ${res.status}`);
  return Deal.parse(await res.json());
}
```
- **`parse` vs `safeParse`:** `parse` throws. `safeParse` returns a discriminated union, `{ success: true; data } | { success: false; error }`. Use `safeParse` to show an error state instead of crashing.
- **Fail early and clearly:** a validation error says "`volumeMwh`: expected number, received string". Without it, you get `NaN` in a chart three screens later. Log validation failures to monitoring.
- **Where:** in one API layer or data-fetching hook, not in each component. Components then receive trusted, typed data.
- **Generated types from OpenAPI:** openapi-typescript (types, plus `openapi-fetch` for a typed client), Hey API, or Orval. Codegen catches drift at *build* time; runtime validation catches what *actually* arrives.
- **Cost trade-off:** parsing very large payloads costs CPU. For trusted internal APIs with codegen, some teams validate only critical data. I'd always validate money fields and anything from outside the company.
- **Current tools:** zod 4 is the current major version. Valibot and ArkType are alternatives, and many libraries accept any of them through the "Standard Schema" interface.

**Your angle:** This is your strongest topic, so lead with it. You designed the Watt chat API contract (SSE streaming over Redis) that the shared chat-kit package runs on, so every streamed event is JSON arriving at the UI boundary. chat-kit's TypeScript types are **generated from the JSON Schemas your Python library exports**, so the client and server share one contract. `[confirm: does the client also check events at run time (zod or guards)?]` Your backend work has the same mindset: the Data Validation Service never writes without human confirmation ([S2](../AI%20Engineer/13-Behavioral-Story-Bank.md#s2)), and entitlement checks fail closed ([S9](../AI%20Engineer/13-Behavioral-Story-Bank.md#s9)). LLM output is one more untrusted input.
**Likely follow-ups:** "What happens when validation fails in production?" (error state in the UI, log with the request ID, alert if the rate jumps) · see [05 · Frontend System Design](05-Frontend-System-Design.md) for the data layer

---

### Q17. How do you type React components: props, children, events, state, refs?  `[P0]`
**Say this first (~30 sec):** Props are a plain object type on the function parameter, and `children` is `React.ReactNode`. For events I use React's event types, like `React.ChangeEvent<HTMLInputElement>`. `useState` infers from the initial value, so I only pass a type when the initial value isn't enough, like `useState<Deal | null>(null)`. A DOM ref is `useRef<HTMLInputElement>(null)`. To wrap a native element I use `ComponentProps<"button">`, and generic components keep the item type for lists and tables.

**If they dig deeper:**

*(`React.X` names assume `import type * as React from "react"`, or import the names directly.)*

```tsx
type CardProps = {
  title: string;
  onSelect?: (id: string) => void;
  children?: React.ReactNode;
};

function Card({ title, children }: CardProps) {
  return <section><h2>{title}</h2>{children}</section>;
}
```
- **Events:**
  ```tsx
  function onChange(
    e: React.ChangeEvent<HTMLInputElement>,
  ) {
    setQuery(e.target.value);
  }
  ```
  Inline handlers need no annotation: `onChange={(e) => setQuery(e.target.value)}` infers the type. In current `@types/react` (19.x), `FormEvent` is marked deprecated. Use `React.SubmitEvent<HTMLFormElement>` for `onSubmit`.
- **State with unions:**
  ```tsx
  const [deal, setDeal] = useState<Deal | null>(null);
  const [tab, setTab] = useState<"info" | "pnl">("info");
  ```
- **Refs (React 19 types):** `useRef` now requires an argument. `useRef<HTMLInputElement>(null)` gives `RefObject<HTMLInputElement | null>`, so check for `null` before use. For a mutable value like a timer ID: `useRef<number | null>(null)`. In React 19, `ref` is a normal prop for function components, so new code doesn't need `forwardRef`.
- **Wrap a native element:**
  ```tsx
  type ButtonProps = React.ComponentProps<"button"> & {
    variant: "primary" | "ghost";
  };
  ```
- **Generic component:**
  ```tsx
  type ListProps<T> = {
    items: T[];
    getKey: (item: T) => string;
    render: (item: T) => React.ReactNode;
  };

  function List<T>(
    { items, getKey, render }: ListProps<T>,
  ) {
    return (
      <ul>
        {items.map((i) => (
          <li key={getKey(i)}>{render(i)}</li>
        ))}
      </ul>
    );
  }
  ```
  In a `.tsx` file, a generic *arrow* function needs `<T,>` so the parser doesn't read it as JSX.
- **`React.FC`:** fine to use, but most teams type props on the parameter directly. Since React 18's types, `FC` no longer adds `children` for you.

**Your angle:** You have many real components to choose from: the Data Validation pages and the Ask Data UI (which you created) on Watt, uploads and PDF citation highlighting in Ask Knowledge, and the Ask AI chat page on Jupiter. Watt uses hooks and context with no state library, so typed context is a real example for you. You also wrote 68 of Watt's 102 UI test files (Vitest + Testing Library). `[fill in: one component, and how its props, state, and refs were typed]` More React depth: [03 · React Fundamentals](03-React-Fundamentals.md). Practice: [04 · React Coding Exercises](04-React-Coding-Exercises.md).
**Likely follow-ups:** "How do you type a custom hook's return?" (an object, or a tuple with `as const`) · "How do you type context?" (`createContext<Value | null>(null)` plus a hook that throws if the value is `null`)

---

### Q18. Python backend, React + TypeScript frontend: how do you keep types in sync?  `[P0]`
**Say this first (~30 sec):** I make the API contract the single source of truth. In a Python backend like FastAPI, Pydantic models generate an OpenAPI spec automatically. In CI, I generate TypeScript types and a typed client from that spec, so a backend change that breaks the frontend fails the build, not production. At runtime I still validate critical responses (Q16). If both sides were TypeScript, I could share types or zod schemas directly in a monorepo, but with Python, OpenAPI is the bridge.

**If they dig deeper:**
```
Pydantic models (Python)
     │  FastAPI generates
     ▼
openapi.json  (the contract, in git)
     │  codegen in CI
     ▼
TS types + typed client (React)
     │  tsc --noEmit
     ▼
build fails if the UI breaks
```
- **Tools:** openapi-typescript (types, plus `openapi-fetch`), Hey API (used in FastAPI's own docs), or Orval (can also generate React Query hooks and zod schemas).
- **Keep it honest in CI:** regenerate on every backend change, and fail the build if the committed types are out of date.
- **Breaking-change rules:** adding a field or endpoint is safe. Removing or renaming a field, or changing its type, is breaking. Version the API, or use expand-and-contract: add the new field, move clients, then remove the old one.
- **New enum values:** an older frontend may receive a status it doesn't know. Handle an "unknown" case in the UI instead of crashing.
- **Types that don't map one-to-one:**
  - Python `datetime` → JSON string → TS `string`, not `Date`. Parse it on purpose.
  - Python `Decimal` and big integers: JS numbers are 64-bit floats, exact only up to 2^53 − 1. Send money and large IDs as strings, or confirm the range is safe.
  - `None` → `null`.
  - A field with a default is optional in a request but always present in a response. FastAPI with Pydantic v2 generates separate `-Input` and `-Output` schemas for this.
- **Errors are part of the contract:** type the error body too (for example, FastAPI's `422` validation error shape), so the UI can show field-level messages.

**Your angle:** This is your best full-stack story, because you work on both sides of the contract.
- **Watt:** you designed the chat API contract (SSE streaming over Redis) that the shared chat-kit package runs on, then built UIs on top of it yourself ([S3](../AI%20Engineer/13-Behavioral-Story-Bank.md#s3)). `[fill in: how the event types are defined on the TS side]`
- **Jupiter:** the backend is FastAPI, which is exactly the diagram above. You moved PnL Summary from mock data to the live API ([S8](../AI%20Engineer/13-Behavioral-Story-Bank.md#s8)). `[fill in: are the TS types generated from FastAPI's OpenAPI or written by hand? Are PnL amounts sent as numbers or strings?]`
- **Datetimes:** you fixed daylight-saving bugs across Jupiter's charts, grids, and Excel exports. That is the "datetime crosses the boundary" problem in real life. `[fill in: the root cause and the fix]`
- **Deep dives:** [06 · Jupiter Load Deal](06-Jupiter-Load-Deal-Deep-Dive.md) and [07 · Watt AI Platform](07-Watt-AI-Platform-Deep-Dive.md).

**Likely follow-ups:** "What if the backend has no spec?" (write zod schemas on the frontend as the contract, and add contract tests) · "How do you ship a breaking API change with no downtime?" (expand-and-contract, versioning, feature flags)

---

### Q19. What are declaration files (`.d.ts`) and DefinitelyTyped?  `[P2]`
**Say this first (~30 sec):** A `.d.ts` file holds only types, no implementation. It describes JavaScript code so TypeScript can check calls into it. A library gets types in one of three ways: it ships its own `.d.ts` files, which most modern packages do; the community publishes them on DefinitelyTyped as `@types/<package>`; or I write a small declaration myself for an untyped library or a global variable.

**If they dig deeper:**
- **Community types:** `npm i -D @types/lodash`. React's types are also there, as `@types/react`.
- **Your own declaration:**
  ```ts
  // src/types/legacy-chart.d.ts
  declare module "legacy-chart" {
    export function render(
      el: HTMLElement, data: number[],
    ): void;
  }
  ```
- **Non-code imports:**
  ```ts
  declare module "*.svg" {
    const url: string;
    export default url;
  }
  ```
- **Adding to a global type (augmentation):**
  ```ts
  declare global {
    interface Window { appConfig: AppConfig }
  }
  export {};
  ```
- **TS 6/7 note:** `types` defaults to `[]`, so global packages like `@types/node` must be listed in `tsconfig`.
- **Library authors:** `declaration: true` makes `tsc` emit `.d.ts` files, and `package.json` points to them through `"types"` or `"exports"`.

**Your angle:** At Wayfair you wrote custom Backstage plugins in TypeScript. Today, Watt and Jupiter use Vite, which ships its own client types (`vite/client`). `[fill in: any library you had to declare types for, e.g., a chart or PDF library]` If none, say so: "Beyond `@types` packages, I haven't needed to."
**Likely follow-ups:** "`@types/x` vs types bundled in the package?" (bundled types are released with the code, so they stay in sync)

---

### Q20. Code quiz: what happens here?  `[P1]`
Three short snippets interviewers like. Say your answer out loud before you read it.

**(a) Does it compile? What happens at runtime?**
```ts
type User = { name: string };
const raw = '{"nmae":"Kurt"}';
const u: User = JSON.parse(raw);
console.log(u.name.toUpperCase());
```
**Answer:** It compiles, because `JSON.parse` returns `any`. At runtime `u.name` is `undefined`, so it throws "TypeError: Cannot read properties of undefined (reading 'toUpperCase')". Types are erased, so validate untrusted data (Q16).

**(b) Where is the type error?**
```ts
function size(x: string | string[] | null) {
  if (typeof x === "object") {
    return x.length;
  }
  return x.length;
}
```
**Answer:** The *first* `x.length`: "'x' is possibly 'null'." In JavaScript, `typeof null` is `"object"`, so inside that branch `x` is `string[] | null`. Fix: use `Array.isArray(x)`, or check `x !== null` first. This example is from the TypeScript handbook.

**(c) What's the type of `keys`, and why does the loop fail?**
```ts
type Prices = { peak: number; offPeak: number };
const p: Prices = { peak: 50, offPeak: 30 };

const keys = Object.keys(p);
for (const k of keys) {
  console.log(p[k]);
}
```
**Answer:** `keys` is `string[]`, not `("peak" | "offPeak")[]`. So `p[k]` errors: "Element implicitly has an 'any' type because expression of type 'string' can't be used to index type 'Prices'." The reason is structural typing (Q13): a value typed `Prices` may have *more* keys at runtime, so TS won't promise only these keys. Fixes: loop over a known list (`const KEYS = ["peak", "offPeak"] as const`), or cast when you know the object is exact: `Object.keys(p) as (keyof Prices)[]`.

**Your angle:** Practice these out loud. Interviewers care more about the *why* (erasure, `typeof null`, structural typing) than the exact error text.
**Likely follow-ups:** "How would you fix (a) properly?" (schema validation, Q16) · "Why doesn't TS make `Object.keys` return `keyof T`?" (extra keys may exist at runtime)

---

## References
- [TypeScript Handbook](https://www.typescriptlang.org/docs/handbook/intro.html): the official guide; the "Handbook" section covers everything on this page.
- [Handbook: Everyday Types](https://www.typescriptlang.org/docs/handbook/2/everyday-types.html): unions, aliases vs interfaces (with the "use interface until you need type" heuristic), assertions, literal types.
- [Handbook: Narrowing](https://www.typescriptlang.org/docs/handbook/2/narrowing.html): every type guard, discriminated unions, `never` exhaustiveness, and the `typeof null` example (Q20b).
- [Handbook: More on Functions](https://www.typescriptlang.org/docs/handbook/2/functions.html): generic functions and the "type parameters should appear twice" rule.
- [Handbook: Object Types](https://www.typescriptlang.org/docs/handbook/2/objects.html): optional and readonly properties, excess property checks, intersections.
- [Handbook: Creating Types from Types](https://www.typescriptlang.org/docs/handbook/2/types-from-types.html): `keyof`, `typeof`, indexed access, conditional, mapped, and template literal types.
- [Utility Types reference](https://www.typescriptlang.org/docs/handbook/utility-types.html): every built-in utility type with examples.
- [TSConfig reference](https://www.typescriptlang.org/tsconfig/): every compiler option, including `noUncheckedIndexedAccess` and `moduleResolution`.
- [TypeScript 4.9 release notes](https://www.typescriptlang.org/docs/handbook/release-notes/typescript-4-9.html): the `satisfies` operator.
- [TypeScript 5.5 release notes](https://www.typescriptlang.org/docs/handbook/release-notes/typescript-5-5.html): inferred type predicates (the `filter` change).
- [TypeScript Playground](https://www.typescriptlang.org/play): test any snippet on your phone.
- [Announcing TypeScript 7.0](https://devblogs.microsoft.com/typescript/announcing-typescript-7-0/): the Go port, speed numbers, new defaults, and what's now an error.
- [Announcing TypeScript 6.0](https://devblogs.microsoft.com/typescript/announcing-typescript-6-0/): the bridge release; `strict` on by default.
- [Announcing TypeScript 7.1 Beta](https://devblogs.microsoft.com/typescript/announcing-typescript-7-1-beta/): the new API and the release timeline.
- [TypeScript performance wiki](https://github.com/microsoft/TypeScript/wiki/Performance): why interfaces can be faster than intersections.
- [Node.js: Modules: TypeScript](https://nodejs.org/api/typescript.html): running `.ts` files with type stripping, and the "erasable syntax only" rule.
- [Vite: TypeScript](https://vite.dev/guide/features.html#typescript): Vite transpiles but does not type-check.
- [React: Using TypeScript](https://react.dev/learn/typescript): official guide to typing props, hooks, and events.
- [React 19 release post](https://react.dev/blog/2024/12/05/react-19): `ref` as a prop, no more `forwardRef` for new code.
- [React TypeScript Cheatsheet](https://react-typescript-cheatsheet.netlify.app/): community reference for typing React patterns.
- [Zod docs](https://zod.dev/) and [Zod API: objects](https://zod.dev/api): schemas, `z.infer`, `safeParse`, and `z.strictObject`.
- [Standard Schema](https://standardschema.dev/): the shared interface that zod, Valibot, and ArkType implement.
- [openapi-typescript](https://openapi-ts.dev/): generate TS types and a typed fetch client from an OpenAPI spec.
- [Hey API](https://heyapi.dev/) and [Orval](https://github.com/orval-labs/orval): OpenAPI client generators (hooks and zod schemas too).
- [FastAPI: Generating SDKs](https://fastapi.tiangolo.com/advanced/generate-clients/): FastAPI's own guide to TypeScript clients.
- [FastAPI: Separate OpenAPI schemas for input and output](https://fastapi.tiangolo.com/how-to/separate-openapi-schemas/): the `-Input` / `-Output` schema behavior with Pydantic v2.
- [MDN: Number.MAX_SAFE_INTEGER](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Number/MAX_SAFE_INTEGER): why large IDs and money need care in JS.
- [DefinitelyTyped](https://github.com/DefinitelyTyped/DefinitelyTyped): the home of `@types/*` packages.
- [Total TypeScript: type vs interface](https://www.totaltypescript.com/type-vs-interface-which-should-you-use): a well-known take on Q2.
- [Type Challenges](https://github.com/type-challenges/type-challenges): practice problems for mapped and conditional types (Q10), easy level first.
