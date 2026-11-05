# 08 · AG Grid

[← Index](00-Index.md) · **Interview priority:** High (Ravi: "heavy on AG Grid") · **Read time:** ~100 min, then type the 4 live-coding tasks (Q25–Q28) from memory

> **Why this matters for this role:** Ravi said this interview will be heavy on AG Grid, so expect both "explain it" questions and live coding. You have real grid experience to talk about. Jupiter runs AG Grid Enterprise 34.3.1: tree data, row grouping, set filters, cell selection and integrated charts. You rewrote its Portfolio PnL Flash Table, fixed the daylight-saving bug across the hourly grids and Excel exports, and built the Ask AI result table. AMP runs AG Grid Community 33.2.1, and you did its v33 cleanup. But other engineers built most of the grids in both apps. So: know the current API well, tell the DST story clearly, and be exact about what you built and what you reviewed.

Related pages: [03 · React](03-React-Fundamentals.md) (Q21: slow grid) · [04 · Coding](04-React-Coding-Exercises.md) (Q4: plain table, Q9: price ticker) · [05 · System design](05-Frontend-System-Design.md) (Q1: data grid, Q5: real-time) · [06 · Jupiter](06-Jupiter-Load-Deal-Deep-Dive.md)

---

## Primer

### The version this page targets

- **AG Grid 36.2.0** (Sept 16, 2026). This is the latest `ag-grid-community`, `ag-grid-react` and `ag-grid-enterprise` on npm (checked Nov 3, 2026). AG Charts is 14.2.0.
- Every code sample on this page was type-checked in strict mode (TypeScript 7.0.2, React 19.3) against 36.2.0. The `[fill in]`s are things only you or the company code can answer.
- **Your apps' versions:** Jupiter is on **34.3.1 Enterprise** (Oct 2025), with AG Charts Enterprise 12.3.1. AMP is on **33.2.1 Community** (Mar 2025). Both are past v33, so both register modules. But both still use the **legacy CSS themes** with `theme="legacy"`, not the Theming API this page uses. 36.2.0 still supports `theme: 'legacy'`.

| Version | Date | What changed |
|---|---|---|
| 32.2 | Sep 2024 | New `rowSelection` object |
| 33 | Dec 2024 | Modules required; Theming API |
| 34 | Jun 2025 | Editor validation; batch editing (E) |
| 35 | Dec 2025 | Formulas (E); 35.1 adds `AgGridProvider` |
| 36 | Jun 2026 | Dev validation opt-in; new scroll DOM |

(E) = Enterprise.

### Mental model

```
 rowData      columnDefs     options
 (Deal[])     (ColDef[])     (getRowId,
    │             │           theme...)
    └──────┬──────┴──────┬──────┘
           ▼             ▼
    ┌──────────────────────────┐
    │      <AgGridReact>       │──► events
    │ row model: group, filter,│   (cell edited,
    │ sort → draws ONLY the    │    selection...)
    │ visible rows and columns │
    └────────────┬─────────────┘
                 │ gridRef.current.api
                 ▼
     Grid API: applyTransaction,
     exportDataAsCsv, getState...
```

- You **describe** the grid with props: `rowData`, `columnDefs`, and grid options. When props change, the grid updates.
- You **command** the grid with the **Grid API**: `gridRef.current?.api`, or `event.api` inside `onGridReady` and other events. Use it for transactions, export, state, scrolling and flashing cells.
- **The grid owns its DOM.** It draws only the rows you can see, plus 10 above and 10 below (`rowBuffer`). Columns are virtualized too, with no buffer. As a safety limit it draws at most 500 rows.
- **Client-side pipeline** (in the order the docs give): group, filter, pivot, aggregate, sort, map. Then only the visible part is drawn.

### Minimal typed setup (v36)

```tsx
// main.tsx
import { createRoot } from 'react-dom/client';
import {
  AllCommunityModule,
  enableDevValidations,
} from 'ag-grid-community';
import { AgGridProvider } from 'ag-grid-react';
import { App } from './App';

// Full error text in dev only (not bundled since v36).
if (import.meta.env.DEV) enableDevValidations();

// Every free feature. Later, list single modules
// (e.g. TextFilterModule) to make the bundle smaller.
const modules = [AllCommunityModule];

createRoot(document.getElementById('root')!).render(
  <AgGridProvider modules={modules}>
    <App />
  </AgGridProvider>,
);
```

```tsx
// DealGrid.tsx
import { useMemo } from 'react';
import { AgGridReact } from 'ag-grid-react';
import {
  themeQuartz,
  type ColDef,
  type GetRowIdFunc,
} from 'ag-grid-community';
import type { Deal } from './types';

// Module scope: created once, so the reference is stable.
const theme = themeQuartz.withParams({
  accentColor: '#0b5cad',
  spacing: 6,
});
const getRowId: GetRowIdFunc<Deal> = ({ data }) =>
  data.dealId;

export function DealGrid({ deals }: { deals: Deal[] }) {
  const columnDefs = useMemo<ColDef<Deal>[]>(
    () => [
      { field: 'dealId', headerName: 'Deal' },
      { field: 'book' },
      { field: 'volumeMwh', headerName: 'MWh' },
      { field: 'pnl', headerName: 'PnL' },
      // { field: 'pnll' }  <- compile error
    ],
    [],
  );
  const defaultColDef = useMemo<ColDef<Deal>>(
    () => ({ filter: true, flex: 1, minWidth: 100 }),
    [],
  );

  return (
    // The grid fills its parent: give it a height.
    <div style={{ height: 500 }}>
      <AgGridReact<Deal>
        rowData={deals}
        columnDefs={columnDefs}
        defaultColDef={defaultColDef}
        getRowId={getRowId}
        theme={theme}
      />
    </div>
  );
}
```

- **Modules:** required since v33. `AgGridProvider` (v35.1+) gives modules to every grid inside it. Older code calls `ModuleRegistry.registerModules([...])` once at startup. Both work.
- **No CSS import.** Since v33 a theme is a JavaScript object (`themeQuartz`), and the grid injects its own CSS. Old code imported `ag-theme-quartz.css` and set a `className`. That is now called a "legacy" theme (`theme="legacy"`).
- **Types:** `ColDef<Deal>` makes `field` type-safe, so a typo is a compile error. `<AgGridReact<Deal>>` types the events and the API.
- **Height:** the grid fills its parent. A parent with no height gives a blank grid. Small grids can use `domLayout="autoHeight"`.
- **Enterprise:** install `ag-grid-enterprise`, use `AllEnterpriseModule` or single modules, and call `LicenseManager.setLicenseKey(...)` once at startup. Without a key you get a watermark and a console error. That's fine locally, but not allowed in production.

### Community vs Enterprise

| Community (free, MIT) | Enterprise (paid) |
|---|---|
| Client-side, infinite models | Server-side, viewport models |
| Text, number, date filters | Set filter, multi filter |
| Quick filter, external filter | Quick Access Toolbar |
| Cell editing + validation | Batch editing |
| CSV export | Excel + PDF export |
| Pinned rows, pagination | Grouping, aggregation, pivot |
| Custom renderers, editors | Grand total rows |
| Themes, ARIA, keyboard | Master/detail, tree data |
| Sorting, column pinning | Range selection, clipboard |
| | Status bar, tool panels |
| | Context menu |
| | Integrated charts, sparklines |

Jupiter uses Enterprise features: tree data, row grouping, set filters, cell selection (called range selection before v32.2), status-bar sums and integrated charts. All of them are in the right column. AMP is Community only.

### The four row models, one line each

- **Client-side** (default, Community): load all rows once; the grid sorts, filters and groups in the browser. Jupiter and AMP use it for every grid.
- **Infinite** (Community): loads blocks of rows as you scroll. The server sorts and filters. No grouping.
- **Server-side, "SSRM"** (Enterprise): blocks, plus groups that load when opened. The server sorts, filters, groups and aggregates. AG Grid says Enterprise users should prefer it to Infinite.
- **Viewport** (Enterprise): the server knows exactly which rows are on screen and pushes changes for them. The docs warn: don't use it unless you really need it.

### Words to recognize

**Columns**
- `columnDefs` / `ColDef<T>`: one object per column. `defaultColDef`: settings shared by all columns.
- `field`: which property to show. Dots mean a nested path (`price.last`). `colId`: the column's stable ID.
- `cellDataType`: `'text'`, `'number'`, `'boolean'`, `'date'`, `'dateString'`, `'dateTime'`, `'dateTimeString'`, `'bigint'`, `'object'`. It picks the default editor, filter, parser and formatter.

**Values**
- `valueGetter`: computes a cell's value (for example, volume × price).
- `valueFormatter`: turns the value into display text. The value doesn't change.
- `valueParser`: turns edited text into a value ("1,250" → 1250).
- `valueSetter`: writes an edited value back into the row data.

**Cells**
- `cellRenderer`: a React component drawn in a cell. `cellRendererParams`: extra props for it.
- `cellEditor`: the component used while editing. `cellEditorParams`: extra props for it.
- `cellClassRules` / `rowClassRules`: add a CSS class when a rule is true.

**Rows and data**
- `getRowId`: returns each row's stable ID, like a React `key`.
- **Row node** (`IRowNode`): the grid's wrapper around one data row (`node.data`, `node.rowPinned`, ...).
- **Transaction**: `{ add, update, remove }` sent with `api.applyTransaction`. `applyTransactionAsync` batches them.
- **Pinned rows**: `pinnedTopRowData` / `pinnedBottomRowData`, fixed rows such as totals. **Pinned columns**: `pinned: 'left'`.

**Enterprise words**
- `rowGroup`, `aggFunc` (`'sum'`, `'avg'`...), `pivot`, `grandTotalRow`, `treeData`, `masterDetail`, `cellSelection`, `statusBar`.

**Other**
- **Datasource**: your object that fetches row blocks (`IDatasource` for Infinite, `IServerSideDatasource` for SSRM).
- **Column state / grid state**: the user's layout (order, widths, sort, filters) as plain JSON.
- `context`: your own object that the grid passes to every callback.
- `readOnlyEdit`: the grid doesn't change your data on edit; it fires `cellEditRequest` instead.

### Questions to ask them about their AG Grid use

- Which version and edition (Community or Enterprise)? Any upgrade planned?
- Which row model, and how many rows does the biggest grid have?
- Do users edit in the grid? How are edits saved and checked?
- Do any grids update live? How often, and over what (WebSocket, SSE, polling)?
- Do you save users' layouts? Where?
- How do you test grids: jsdom, or Playwright in a real browser?
- Is there a shared grid wrapper with standard column types, formatters and a theme?
- What is the biggest grid problem today: speed, Excel export, or something else?

---

## Questions & answers

### Q1. How much AG Grid have you used, and what did you build with it?  `[P0]`
**Say this first (~30 sec):** "I've used AG Grid in two production React apps at BETM. Jupiter, our Load Deal app, runs AG Grid Enterprise 34 with the client-side row model: tree data, grouping, set filters, cell selection with status-bar sums, and integrated charts. Another engineer built most of those grids, and I reviewed their PRs. My own grid work: I rewrote the Portfolio PnL Flash Table, fixed the daylight-saving bug across the hourly grids and Excel exports, and built the Ask AI result table. On AMP, I did the version 33 upgrade cleanup."

**If they dig deeper:**
- Say clearly what you built and what you reviewed:
  - **Built:** the DST fix (Q14). Every hourly row is now keyed by date + hour ending + EDT/EST, so a day can have 23, 24 or 25 rows. The grids got a TZ column. Excel exports keep both 1 AM rows on the fall-back day, sorted by TZ.
  - **Built:** the **Portfolio PnL Flash Table** rewrite (Oct 22, 2026): a month accordion, pinned month rows, YTD, custom headers, and a row model with tests.
  - **Built:** the Ask AI result table and the Admin usage panel (Sep 2026) (Q22). `[fill in: how your code builds the column defs from the SQL result]`
  - **Built:** the PnL Summary grid sizing and data wiring (Jul–Aug 2026), and the ARR/MLC forecast labels and tooltips.
  - **Reviewed:** most other Jupiter grids (you approved 26 PRs). `[fill in: one real thing you caught in a grid PR]`
  - **AMP** (Community 33.2.1): 13 grids, 12 in Admin plus the File Center. Others built all of them. Your work was the **v33 cleanup** on Mar 4, 2026 (Q24).
- Jupiter facts you can use:
  - **Deal Pricing & Load** shows one month of hourly rows by default: about 720–745 rows, 200 per page.
  - The **long-term forecast** table fetches every API page (2,000 rows each) into memory, then shows 100 per page.
  - The **Flash Table** (30+ deal columns) turns **column virtualisation off**, so auto-size can measure every column (Q11).
  - **Live Deal Summary** has integrated charts. **Load Book** uses standalone AG Charts for awards vs hedges.
- Name the gap honestly: "I haven't built a server-side row model grid or a streaming grid in production. I know how they work, and I can show you."

**Your angle:** [M1](../AI%20Engineer/13-Behavioral-Story-Bank.md#m1) (you led and reviewed the frontend engineer's grid work) and [S8](../AI%20Engineer/13-Behavioral-Story-Bank.md#s8) (traders check the numbers against their workbook, so formats must match). The full Jupiter story is in [06](06-Jupiter-Load-Deal-Deep-Dive.md).
**Likely follow-ups:** "Why client-side everywhere?" (Q10) · "Tell me about the DST bug." (Q14) · "What would you change in those grids?" (Q10, Q11)

---

### Q2. How do you set up AG Grid in React with TypeScript? Why do stable references matter?  `[P0]`
**Say this first (~30 sec):** "I install `ag-grid-react`, which brings `ag-grid-community`, and I provide the modules once at the top, with `AgGridProvider` or `ModuleRegistry`. Modules are required since v33, and a theme is now a JavaScript object like `themeQuartz`, not a CSS file. I type the row: `ColDef<Deal>[]` for columns and `AgGridReact<Deal>`, so a wrong field name is a compile error. Then I keep `columnDefs`, `defaultColDef` and callbacks stable with `useMemo`, `useCallback`, or module scope. A new array on every render makes the grid re-apply the columns, and the user loses widths and sort."

**If they dig deeper:**
- The setup code is in the Primer. AG Grid's own React advice:
  - `rowData`: keep it in `useState` (or `useMemo` if it never changes).
  - `columnDefs`: `useState` if they change, otherwise `useMemo`.
  - Objects like `defaultColDef`, `sideBar`, `statusBar`: `useMemo`, never inline.
  - Callbacks like `isRowSelectable` or `getRowId`: `useCallback`, or define them outside the component.
  - Event handlers (`onCellClicked`): no hook needed, but watch for stale values.
  - Strings, numbers and booleans are compared by value, so they need nothing.
- **Getting the API:** `const gridRef = useRef<AgGridReact<Deal>>(null)` and then `gridRef.current?.api`. Or use `event.api` in `onGridReady`. Don't call the API before the grid is ready.
- **"Initial" options** are read once, when the grid starts: for example `rowModelType`, `initialState` and `context`. Changing the prop later does nothing. Some can be changed with `api.setGridOption(...)`.
- **`enableDevValidations()`** in development gives full error messages. Since v36 it is not in the default bundles, so production stays smaller.
- The React Compiler can memoize much of this for you. I still make grid inputs stable on purpose, because a grid that resets is a visible bug.

**Your angle:** Jupiter is React 19 + TypeScript + Vite + React Router 7. Its entry file registers `AllEnterpriseModule` plus integrated charts with AG Charts Enterprise, once, and sets the licence key there. Two lazy-loaded grids also register `AllCommunityModule`. That's redundant, because the Enterprise bundle already includes it. AMP does the opposite: most grids register only what they need (client-side row model, text filter, pagination). But one page registers `AllCommunityModule`, so every module is available app-wide once that page loads.
- **Licence keys:** a frontend licence key always ends up in the browser bundle. An env var only keeps it out of the repo.
**Likely follow-ups:** "My grid loses column widths when I type in a search box. Why?" (New `columnDefs` on every render: Q23.) · "`AgGridProvider` or `ModuleRegistry`?" (Same result. The provider scopes modules to part of the tree and is the newer, React-style way.)

---

### Q3. What does `getRowId` do? How should you update row data?  `[P0]`
**Say this first (~30 sec):** "`getRowId` gives the grid a stable ID for each row, like a React `key`. With it, the grid can match old and new data. When I pass a new `rowData` array, it works out what was added, changed and removed. It keeps selection, focus and scroll, and only redraws the changed rows. Without IDs, a new array means the grid throws everything away and starts again. The data must be immutable: a changed row is a new object, so the grid sees the change."

**If they dig deeper:**

```tsx
// A) React owns the data: a NEW array, and a NEW
//    object only for the row that changed.
setDeals((rows) =>
  rows.map((d) =>
    d.dealId === id ? { ...d, price } : d,
  ),
);

// B) The grid owns the data: send only changes.
gridRef.current?.api.applyTransaction({
  add: [newDeal],
  update: [changedDeal],
  remove: [closedDeal], // matched by row ID
});
```

```tsx
// Bug: same array, same object. React and the
// grid both see "nothing changed".
deal.price = 101;
setDeals(deals);
```

- **How the grid compares** a new `rowData` (from the docs):
  - New ID → add the row.
  - Same ID, different object → update the row.
  - Same ID, same object → no change.
  - ID missing from the new list → remove the row.
  - Row order then follows the new list, unless the grid is sorted.
- `getRowId` must return a **string**, be **unique**, and never change for a row. Use a composite key when needed: `${date}|${he}|${tz}` (your DST fix, Q14).
- **rowData vs transactions:** setting `rowData` with IDs makes the grid build a transaction for you, which costs a diff. For thousands of rows or frequent updates, send transactions directly. There is no async version of a `rowData` update.
- **Pick one owner.** Either React state owns the rows (new arrays with `setState`) or the grid owns them (transactions). If you mix them, the next `setState` can undo grid-only changes.
- Without IDs, transactions find rows by object reference (`===`). It works, but it's slower.
- By default, editing **changes your row objects in place**. See Q8 for `readOnlyEdit`.

**Your angle:** The DST fix is a row-ID story. Before the fix, two "1 AM" rows mapped to one instant, so they acted like one key. Now the key is date + hour ending + EDT/EST. Jupiter's hourly grids don't set `getRowId`; only two admin grids do. Rows are replaced as a whole from state, so the DST key lives in the data and the sort (Date, HE, TZ). If those grids moved to transactions, `getRowId` would have to return that same key, like `` `${date}|${he}|${tz}` ``. On AMP you fixed a real duplicate row ID: the File Center key needed the folder name too. See also [03 Q2](03-React-Fundamentals.md) on React keys.
**Likely follow-ups:** "What if two rows share an ID?" (The docs require unique IDs. Updates and selection can then hit the wrong row.) · "When would you NOT use `getRowId`?" (A read-only table that is always replaced as a whole, like an Ask AI result.)

---

### Q4. `valueGetter` vs `valueFormatter` vs `cellRenderer`: when do you use each?  `[P0]`
**Say this first (~30 sec):** "They are three layers. A `valueGetter` computes the cell's value, for example volume times price. Sorting, filtering, export and aggregation all use that value. A `valueFormatter` only changes the text you see, like 1234.5 to $1,234.50. The value stays a number, so sorting still works. A `cellRenderer` is a React component for rich content, like a badge or a button. I use the cheapest one that works. Each rendered cell is a React component, and that costs more when you scroll."

**If they dig deeper:**

```tsx
const usd = new Intl.NumberFormat('en-US', {
  style: 'currency',
  currency: 'USD',
}); // create once, not once per cell

export const columnDefs: ColDef<Deal>[] = [
  {
    colId: 'notional',
    headerName: 'Notional',
    // valueGetter: computes the VALUE. Sort, filter,
    // export and aggregation all use it.
    valueGetter: ({ data }) =>
      data ? data.volumeMwh * data.price : null,
    // valueFormatter: value -> display TEXT only.
    valueFormatter: ({ value }) =>
      value == null ? '' : usd.format(value),
  },
  // cellRenderer: a React component inside the cell.
  { field: 'status', cellRenderer: StatusBadge },
];
```

- **Order:** `field` or `valueGetter` → **value** → `valueFormatter` → **text**. A renderer gets both `value` and `valueFormatted`.
- A `valueGetter` must be **pure**: the grid may call it once and reuse the result. `valueCache` caches results for heavy getters.
- **Export** uses getters and formatters (`useValueFormatterForExport`, default `true`), but **not** renderers. A value that only a renderer draws won't be in the Excel file.
- **Renderer cost:** every visible cell with a renderer is a React component that mounts as you scroll. Keep renderers small. For slow ones, `cellRendererParams: { deferRender: true }` draws them after scrolling stops.
- **Handle `null`:** the value can be `null` or `undefined` for group rows or rows that haven't loaded. The v36 types say `TValue | null | undefined`.
- Related: `cellRendererSelector` picks a renderer per row; `cellDataType` gives built-in parsing and formatting by type.

**Your angle:** Formatting matters in Jupiter because traders compare the numbers with their own workbook ([S8](../AI%20Engineer/13-Behavioral-Story-Bank.md#s8)). Jupiter's shared formatters (another engineer's) give two decimals, accounting-style currency, ISO dates, and a red class for negatives. You wrote the Ask AI table formatter. On AMP you added formatters that join array values into comma lists, which fixed the grid's object-column warnings.
**Likely follow-ups:** "Why does my money column sort like text?" (The value is a formatted string. Keep a number and format with `valueFormatter`.) · "Can I sort by a computed column?" (Yes. Sorting uses the `valueGetter` result.)

---

### Q5. How do you write a custom cell renderer and a custom cell editor in React?  `[P0]`
**Say this first (~30 sec):** "A cell renderer is a normal React component. Its props are typed as `CustomCellRendererProps<TData, TValue>`: `value`, `valueFormatted`, `data`, `node`, the grid `api` and so on. I plug it in with `colDef.cellRenderer`. A cell editor is a controlled component: it gets `value` and `onValueChange`, and the grid saves the value when editing stops. Optional callbacks, like validation, go through the `useGridCellEditor` hook. I always handle `null` values and focus, and I try the built-in editors first."

**If they dig deeper:**

```tsx
// usd = the Intl.NumberFormat from Q4
import { useEffect, useRef } from 'react';
import {
  useGridCellEditor,
  type CustomCellEditorProps,
  type CustomCellRendererProps,
} from 'ag-grid-react';

export function PnlCell({
  value,
}: CustomCellRendererProps<Deal, number>) {
  if (value == null) return null; // e.g. group rows
  const neg = value < 0;
  return (
    <span className={neg ? 'pnl-neg' : 'pnl-pos'}>
      {neg ? '▼' : '▲'} {usd.format(value)}
    </span>
  );
}
```

```tsx
export function VolumeEditor({
  value,
  onValueChange,
}: CustomCellEditorProps<Deal, number>) {
  const ref = useRef<HTMLInputElement>(null);
  useEffect(() => ref.current?.focus(), []);

  // Optional callbacks for the grid (v34+ validation).
  useGridCellEditor({
    getValidationErrors: () =>
      value != null && value < 0
        ? ['Volume cannot be negative']
        : null,
  });

  return (
    <input
      ref={ref}
      type="number"
      value={value ?? ''}
      onChange={(e) =>
        onValueChange(
          e.target.value === ''
            ? null
            : Number(e.target.value),
        )
      }
    />
  );
}
```

```tsx
{ field: 'pnl', cellRenderer: PnlCell },
{
  field: 'volumeMwh',
  editable: true,
  cellEditor: VolumeEditor,
},
```

- **Built-in editors** (Community): text, large text, number, date, checkbox and select. The rich select editor (search, async values) is Enterprise.
- **Extra props:** `cellRendererParams` / `cellEditorParams`. **Per-row choice:** `cellRendererSelector` / `cellEditorSelector`.
- **Popup editor:** `cellEditorPopup: true` for big editors. It can't be used with full-row editing.
- **Keyboard:** by default, focus goes to the whole cell. A renderer with buttons must handle its own focus. `suppressMouseEventHandling` (in `cellRendererParams`) stops a button click from also selecting or editing the row.
- **Editors that need arrow keys** must stop them from reaching the grid: `event.stopPropagation()` or `colDef.suppressKeyboardEvent` (see Q28).
- Code from v31 or older used imperative editors (`getValue()` with `useImperativeHandle`). The current style is the controlled one above.
- A renderer is just a component, so you can unit test it alone, without a grid.

**Your angle:** You wrote four in Jupiter:
- a month group header that folds and unfolds
- a deal label cell: a month chevron, or an indented deal
- a forecast tooltip for unsettled ARR/MLC days
- a block-hours header tooltip on the hedge grid

Another engineer wrote the badges, links, action buttons and row-drag delete. Neither app has a custom cell editor.
**Likely follow-ups:** "How does a renderer call back into the page?" (A callback in `cellRendererParams`, or the grid `context`; watch for stale values, Q23.) · "How do you test a renderer?" (Render it alone with Testing Library.)

---

### Q6. How do sorting and filtering work? Which filters are Enterprise?  `[P0]`
**Say this first (~30 sec):** "Sorting is on by default: click a header, and Shift-click adds more columns. For filtering there are three kinds, and a row must pass all three. Column filters work per column: text, number and date in Community, and the set filter and multi filter in Enterprise. The quick filter is one search box across all columns. The external filter is my own logic, like a Book dropdown outside the grid. With `filter: true`, the grid picks the filter from the cell data type, and in Enterprise it uses the set filter."

**If they dig deeper:**

```tsx
const defaultColDef = useMemo<ColDef<Deal>>(
  () => ({
    filter: true, // Text/Number/Date by data type
    floatingFilter: true, // inputs under headers
  }),
  [],
);

// External filter: a "Book" dropdown outside the grid.
// New function references -> the grid re-filters.
const isExternalFilterPresent = useCallback(
  () => book !== 'ALL',
  [book],
);
const doesExternalFilterPass = useCallback(
  (node: IRowNode<Deal>) => node.data?.book === book,
  [book],
);

return (
  <AgGridReact<Deal>
    rowData={props.deals}
    columnDefs={props.cols}
    defaultColDef={defaultColDef}
    quickFilterText={search} // all columns
    isExternalFilterPresent={isExternalFilterPresent}
    doesExternalFilterPass={doesExternalFilterPass}
  />
);
```

- **Server-side data:** the Infinite and SSRM datasources receive `sortModel` and `filterModel` (Q27). You can read and set them with `api.getFilterModel()` / `api.setFilterModel()`.
- **Floating filters:** small inputs under the headers.
- **Quick filter tips:** debounce the input (~300 ms). Turn on `cacheQuickFilter` for big data. It searches visible columns only, unless you set `includeHiddenColumnsInQuickFilter`. For object values, give a `getQuickFilterText`, or you search `[object Object]`.
- The **external filter** works with the client-side row model only.
- **v34 change:** `getModel()` / `setModel()` on filter instances are deprecated. Use `api.getColumnFilterModel(col)` / `api.setColumnFilterModel(col, model)`.
- **Custom sort:** `comparator` on the column, for example to keep blanks last. **Absolute sort** (v35) sorts by size and ignores the sign: `sort: { direction: 'desc', type: 'absolute' }`. That's useful for "biggest PnL moves, up or down".

**Your angle:** Jupiter has Enterprise, so it uses set filters (Live Deal Summary, ST Forecast), floating and date filters (Price & Load, the hedge grid), and a quick filter (Flash Table). AMP is Community: text filters with custom floating filters on File Center, and a search box outside the grid on the Admin grids. **A real bug you fixed:** AMP had a set filter and grouping props but no Enterprise package, so they never worked; the grid only warned. You swapped the set filter for a text filter.
**Likely follow-ups:** "Filter a million rows?" (On the server, with the Infinite or SSRM model and database indexes.) · "Keep the user's filters?" (Grid state, Q16.)

---

### Q7. How does editing work: cell vs full-row, parsers, setters and validation?  `[P0]`
**Say this first (~30 sec):** "I turn editing on per column with `editable`, which can also be a function per row. The default is cell editing: double-click, Enter or F2 starts it, Enter saves, Escape cancels. Full-row editing, `editType: 'fullRow'`, edits the whole row and saves once. The value goes through steps: the editor returns a value, a `valueParser` turns text into the right type, then the grid writes it into the row with `field` or a `valueSetter`. Since v34, editors also validate, and `invalidEditValueMode` says whether to revert or block."

**If they dig deeper:**

```tsx
const columnDefs = useMemo<ColDef<Deal>[]>(
  () => [
    {
      field: 'volumeMwh',
      // editable can be a function per row
      editable: ({ data }) => data?.status !== 'Settled',
      cellEditor: 'agNumberCellEditor',
      cellEditorParams: { min: 0, precision: 2 },
    },
    {
      field: 'price',
      editable: true,
      cellEditor: 'agTextCellEditor',
      // typed text "$1,250.50" -> number 1250.5
      valueParser: ({ newValue, oldValue }) => {
        const n = Number(
          String(newValue).replace(/[$,]/g, ''),
        );
        return Number.isFinite(n) ? n : oldValue;
      },
    },
  ],
  [],
);

// Cross-field check for full-row editing (v34+).
const checkRow: GetFullRowEditValidationErrors = ({
  editorsState,
}) => {
  const vol = editorsState.find(
    (s) => s.colId === 'volumeMwh',
  );
  return vol && Number(vol.newValue) > 10_000
    ? ['Volume over 10,000 MWh needs approval']
    : null;
};

return (
  <AgGridReact<Deal>
    rowData={props.deals}
    columnDefs={columnDefs}
    editType="fullRow" // edit the whole row
    invalidEditValueMode="block" // stay in editor
    getFullRowEditValidationErrors={checkRow}
  />
);
```

- **Important default:** the grid **changes the row object in place** (`data[field] = newValue`). That's fine if the grid owns the data. If React state owns it, use `readOnlyEdit` (Q8).
- **Parser vs setter:** a parser converts ("$1,250" → 1250). A setter writes the value, for nested objects or fields that change together. A setter returns `true` if something changed.
- **Events:** `cellValueChanged` fires after a real change. It does not fire if the value is the same, if the edit was cancelled, or with `readOnlyEdit`. `rowValueChanged` fires once per row in full-row mode.
- **Validation (v34+):** the built-in editors check `min`, `max` and `maxLength`. `cellEditorParams.getValidationErrors` adds your own rules. `getFullRowEditValidationErrors` checks fields against each other. Errors show as a tooltip and are read out by screen readers.
- **Batch editing** (Enterprise, v34): `api.startBatchEdit()`, then `commitBatchEdit()` or `cancelBatchEdit()`. Good for "3 unsaved changes · Save all / Discard". Client-side row model only.
- `undoRedoCellEditing: true` gives Ctrl+Z / Ctrl+Y for edits.
- **The server checks again.** Client checks are only for fast feedback.

**Your angle:** Very little inline editing. Load Book has editable scenario cells, and Settings uses the built-in select editor. Price & Load overrides open a **modal** instead. `[fill in: why a modal, e.g. an override covers a range of hours or needs a reason]` AMP grids aren't editable at all. You built AMP's outage-management and admin forms, so you know the form side well.
**Likely follow-ups:** "Check a value against the server while typing?" (Debounce, show "checking", and check again on save.) · "Undo?" (`undoRedoCellEditing`.)

---

### Q8. How do you save an edit to the API, with an optimistic update and rollback?  `[P0]`
**Say this first (~30 sec):** "My approach: React owns the data, and I turn on `readOnlyEdit`, so the grid never changes the row objects. When the user finishes an edit, the grid fires `cellEditRequest`. I build the new row and put it in state right away, so the user sees it: that's the optimistic part. Then I call the API with the row's version. If the save fails or the version is old, I put the old row back and show an error. The server stays the source of truth."

**If they dig deeper:**

```tsx
const [deals, setDeals] = useState(props.initial);

// Swap one row by ID; new array + new object.
const put = (d: Deal) =>
  setDeals((rows) =>
    rows.map((r) => (r.dealId === d.dealId ? d : r)),
  );

const onCellEditRequest = useCallback(
  async (e: CellEditRequestEvent<Deal>) => {
    const field = e.colDef.field;
    if (!field) return;
    const before = e.data;
    const after: Deal = {
      ...before,
      [field]: e.newValue,
    };
    put(after); // 1. optimistic: show it now
    try {
      // 2. server checks rules + version (409/412)
      put(await saveDeal(after, before.version));
    } catch {
      put(before); // 3. rollback
      showError(`Deal ${before.dealId} not saved`);
    }
  },
  [],
);

return (
  <AgGridReact<Deal>
    rowData={deals}
    columnDefs={props.cols}
    getRowId={getRowId}
    readOnlyEdit // grid will NOT change row objects
    onCellEditRequest={onCellEditRequest}
  />
);
```

- `getRowId` matters here: the new array keeps the same IDs, so the grid updates one row and keeps scroll, selection and focus.
- **Conflicts:** send the version (`If-Match` / ETag). On 409 or 412, show "changed by someone else" and reload that row. Details in [05 Q1](05-Frontend-System-Design.md).
- **Race:** two quick edits on one row. Rolling back to `before` can undo the second edit. Fixes: queue saves per row, lock the row while saving, or roll back only if the row's version still matches.
- **Show "saving":** keep a set of pending IDs, and mark those cells with `cellClassRules`.
- **Other way:** the grid owns the data, and you call `api.applyTransaction({ update: [row] })` for both the optimistic change and the rollback.
- **Full-row edits:** save once in `onRowValueChanged`. **Batch edits** (Enterprise): one API call, one database transaction, one audit entry per change.
- For risky edits (money, trade bookings) it can be better to **wait** for the server and show a spinner. Optimistic is for low-risk edits.

**Your angle:** The backend part is your strength: version checks, and permission checks that fail closed ([S9](../AI%20Engineer/13-Behavioral-Story-Bank.md#s9)). "The UI makes a cell read-only; the API still rejects the edit." In Jupiter, overrides are saved from the modal through the override API, not cell by cell, and your DST fix put the date + HE + TZ key into those saves. `[fill in: how Load Book scenario edits are saved]`
**Likely follow-ups:** "Why not just update state after the API returns?" (It feels slow. But for risky edits, that's the safer choice.) · "What does the user see when it fails?" (The old value comes back, the cell can flash with `api.flashCells`, and an error message names the deal.)

---

### Q9. How does row selection work in the current API?  `[P1]`
**Say this first (~30 sec):** "Since v32.2, selection is one object: `rowSelection`, with `mode: 'singleRow'` or `'multiRow'`. Its options include `checkboxes`, `headerCheckbox`, `enableClickSelection`, `isRowSelectable`, and `selectAll`, which can be `'all'`, `'filtered'` or `'currentPage'`. The old strings `'single'` and `'multiple'`, and `checkboxSelection` on a column, are deprecated. I read the selection in `onSelectionChanged` with `api.getSelectedRows()`. Selection survives data updates only if I give `getRowId`."

**If they dig deeper:**

```tsx
const [selected, setSelected] = useState<Deal[]>([]);

const rowSelection = useMemo<RowSelectionOptions<Deal>>(
  () => ({
    mode: 'multiRow', // or 'singleRow'
    checkboxes: true,
    headerCheckbox: true,
    selectAll: 'filtered', // only rows that pass filters
    isRowSelectable: (node) =>
      node.data?.status !== 'Settled',
  }),
  [],
);

const onSelectionChanged = useCallback(
  (e: SelectionChangedEvent<Deal>) =>
    setSelected(e.api.getSelectedRows()),
  [],
);

return (
  <AgGridReact<Deal>
    rowData={props.deals}
    columnDefs={props.cols}
    rowSelection={rowSelection}
    onSelectionChanged={onSelectionChanged}
  />
);
```

- In `multiRow` mode, the checkboxes and the header checkbox are on by default. Selecting by clicking the row is off (`enableClickSelection: false`).
- Change the checkbox column (width, pinning) with `selectionColumnDef`.
- Keyboard: Space selects the focused row.
- **Infinite row model:** no select-all, and selection survives sorting and filtering only with `getRowId`.
- **Cell (range) selection is a different feature**, and it's Enterprise: `cellSelection: true`. The old `enableRangeSelection` is deprecated since v32.2. It powers status-bar sums and range charts.
- Selection is part of the grid state, so you can save and restore it (Q16).

**Your angle:** Jupiter uses **cell selection** (called range selection before v32.2) on Live Deal Summary, and the Load Book hedge grid shows a status-bar sum. No Jupiter grid uses row checkboxes. AMP's File Center does: multi-row checkboxes with select-all. In the v33 cleanup you moved AMP to the new click-selection option.
**Likely follow-ups:** "Let users select only the deals they may edit?" (`isRowSelectable`, and the server checks again.) · "Bulk action on 5,000 selected rows?" (Send the IDs, or the filter, to the server. Don't send 5,000 objects.)

---

### Q10. Which row model would you choose? How does a server-side datasource talk to the API?  `[P0]`
**Say this first (~30 sec):** "I start with how much data there is, and who does the work. If it fits in the browser, I use the client-side model: one fetch, then sorting, filtering and grouping are instant. If it doesn't fit, I load from the server in blocks: the infinite model in Community, or the server-side model in Enterprise, which also groups and aggregates on the server. Viewport is only for live data where the server must know exactly what's on screen. Jupiter uses client-side everywhere, which fits: a month of hourly rows is about 745."

**If they dig deeper:**

```ts
import type {
  IServerSideDatasource,
} from 'ag-grid-community';

// Enterprise: rowModelType="serverSide"
export const dealsSsrm: IServerSideDatasource<Deal> = {
  getRows: async (params) => {
    // request = startRow, endRow, sortModel,
    // filterModel, rowGroupCols, groupKeys, ...
    try {
      const res = await fetch('/api/deals/ssrm', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(params.request),
      });
      if (!res.ok) throw new Error(`HTTP ${res.status}`);
      const body: { rows: Deal[]; total?: number } =
        await res.json();
      params.success({
        rowData: body.rows,
        rowCount: body.total, // when known
      });
    } catch {
      params.fail(); // the grid can retry later
    }
  },
};
```

- **AG Grid's rule of thumb:** Community → client-side or Infinite. Enterprise → client-side or SSRM. Avoid Viewport unless you need it.
- **Request shape:** Infinite gets `startRow`, `endRow`, `sortModel` and `filterModel`. The SSRM `request` adds `rowGroupCols`, `groupKeys`, `valueCols`, `pivotCols` and `pivotMode`.
- **Server safety:** allow-list the sort columns, cap the block size, and apply entitlements on every request ([S9](../AI%20Engineer/13-Behavioral-Story-Bank.md#s9)). The FastAPI code is in Q27.
- Infinite asks by **row index**, so `OFFSET`/`LIMIT` fits naturally. A deep `OFFSET` gets slow on big tables. Keyset paging is faster but doesn't map directly to row indexes ([05 Q1](05-Frontend-System-Design.md)).
- For client-side, the limit is browser memory and download time, not the grid, because the DOM is virtualized.
- **Pagination is separate** from the row model: `pagination` + `paginationPageSize` work with client-side data too.

**Your angle:** These are real Jupiter facts. Use them:
- Client-side row model with Enterprise modules everywhere. Deal Pricing & Load: ~720–745 hourly rows, 200 per page.
- The long-term forecast table loads every API page (2,000 rows each) into memory before it shows 100 per page. The total row count isn't in the code. Other paged grids show 20 per page.
- A good design answer (you didn't build it, so say "I would"): "If that got slow, I'd measure first. Then I could show the first page right away and add the rest with `applyTransaction` as pages arrive. Or, since we already have Enterprise, move it to the server-side row model."

**Likely follow-ups:** "Why not SSRM everywhere?" (Every sort, filter and group becomes server work and API surface. For small data, client-side is simpler and instant.) · "One million rows?" (SSRM, never all rows in the browser: [05 Q1](05-Frontend-System-Design.md).)

---

### Q11. A big grid is slow. How do you make it fast?  `[P0]`
**Say this first (~30 sec):** "First I measure, with the React Profiler and the browser's Performance panel. Then the usual fixes. Keep grid inputs stable so the grid doesn't reset. Give `getRowId` so updates only touch changed rows. Use transactions for frequent updates, and `applyTransactionAsync` for very frequent ones; it batches them every 50 ms. Keep cell renderers light: use a `valueFormatter` where you can, and `deferRender` for slow renderers. Debounce the quick filter. And keep virtualization on, so the grid only draws what's visible."

**If they dig deeper:**

```tsx
const columnDefs = useMemo<ColDef<Deal>[]>(
  () => [
    { field: 'dealId' },
    { field: 'pnl' },
    {
      field: 'counterparty',
      cellRenderer: CounterpartyLink,
      // slow renderer: draw after scrolling stops
      cellRendererParams: { deferRender: true },
    },
  ],
  [],
);
const quick = useDebounce(search, 300); // 04 Q2

return (
  <AgGridReact<Deal>
    rowData={props.deals}
    columnDefs={columnDefs} // stable reference
    getRowId={getRowId} // updates by ID, not reset
    quickFilterText={quick}
    cacheQuickFilter // faster quick filter
    valueCache // cache valueGetter results
    asyncTransactionWaitMillis={100} // batch window
  />
);
```

- **Virtualization numbers:** 10 extra rows above and below (`rowBuffer`), no extra columns, and at most 500 rendered rows.
- **Turning virtualization off** draws everything. Only do it for small grids, printing, accessibility, or auto-sizing every column. (Auto-size can only measure columns that are rendered.)
- **Transactions on grouped data** only re-sort and re-aggregate the groups that changed. `deltaSort` helps when the data is big and the changes are small. `suppressModelUpdateAfterUpdateTransaction` stops rows from jumping while someone is reading or editing.
- `valueCache` for heavy getters. `cacheQuickFilter` for big data.
- Many grids on one page, most off screen: `enableContentVisibilityAuto` (v36.1).
- **Bundle size:** register only the modules you use, and lazy-load the grid page.
- Don't keep `rowData` in a global store that re-renders the whole page on every change.

**Your angle:** In Jupiter, the **Flash Table** turns column virtualisation off. Another engineer's code comment says why: auto-size can only measure columns with rendered cells, so with 30+ deal columns only the visible half got sized. The column count is small, so rendering every column is cheap. Your October rewrite kept it. The cost: every column's cells are in the DOM, so keep the rows per page small.
- **Your own grid fixes** (good "slow or broken grid" stories):
  - The current-hour check built a `Date` for every cell. You cached it for one second.
  - PnL grids used `autoHeight` and left white space. You set exact heights, and re-fit columns when data arrives late.
  - ARR/MLC grids collapsed to zero height because of a legend. You moved the legend into the panel header.
  - Flash Table height follows the visible rows, so filtering leaves no blank band.
- Also [S14](../AI%20Engineer/13-Behavioral-Story-Bank.md#s14): on AMP you measured end to end and fixed the biggest part first. More in [03 Q21](03-React-Fundamentals.md).
**Likely follow-ups:** "It's only slow when scrolling?" (Renderers: make them lighter, use `deferRender`, check `rowBuffer`.) · "It's slow to open?" (Usually the data fetch, not the grid. Check the Network tab first.)

---

### Q12. How do you show real-time price updates and flash the changed cells?  `[P1]`
**Say this first (~30 sec):** "One row per instrument, with `getRowId` returning the symbol. Updates come over a WebSocket or SSE. Prices can tick hundreds of times a second, but people can't read that fast. So I keep only the newest price per symbol, and push a batch a few times a second with `applyTransactionAsync`. The grid then updates only the cells that changed. To show the change, I set `enableCellChangeFlash` on the price columns, or use the built-in `agAnimateShowChangeCellRenderer`, which shows the change with an up or down arrow."

**If they dig deeper:**

```tsx
const columnDefs: ColDef<Quote>[] = [
  { field: 'symbol' },
  // flash the cell background when the value changes
  { field: 'last', enableCellChangeFlash: true },
  // or show "+0.25 ▲" next to the new value, then fade
  {
    field: 'bid',
    cellRenderer: 'agAnimateShowChangeCellRenderer',
  },
];
```

- **How flash works:** the grid adds the class `ag-cell-data-changed` (500 ms), then `ag-cell-data-changed-animation` (1,000 ms). Override them in CSS to change the color. Grid options `cellFlashDuration` and `cellFadeDuration` change the timing.
- **Flash on demand:** `api.flashCells({ rowNodes, columns })`, for example after a failed save (Q8).
- Flash doesn't show direction. For up/down colors, use the animate renderer, or `cellClassRules` that compare with the previous price stored in the row.
- `asyncTransactionWaitMillis` changes the batch window (default 50 ms). Call `flushAsyncTransactions()` when you need all updates applied, for example before an export.
- **Stale data:** show "last update 10:05:32", grey out prices when the socket is down, and resync with a snapshot after reconnecting ([05 Q5](05-Frontend-System-Design.md)).
- Respect `prefers-reduced-motion` (Q26 does).

**Your angle:** Be honest: neither app updates a grid live. Jupiter's grids load on mount, on a selection change, or from a Refresh button. One real detail: nothing re-renders the current-hour highlight on a timer, so it may not move when the hour rolls over. The fix: a timer at the next hour that calls `api.refreshCells({ force: true })`, which runs cell class rules again. If the highlight is a row rule, call `api.redrawRows()` instead. Your backend strength fits: Redis caching and pub/sub ([S9](../AI%20Engineer/13-Behavioral-Story-Bank.md#s9)) and fan-out to 3,000+ users ([S12](../AI%20Engineer/13-Behavioral-Story-Bank.md#s12)). Full code in Q26.
**Likely follow-ups:** "1,000 symbols, 10 updates a second each?" (Combine updates on the server, subscribe only to visible rows; Viewport model only at very large scale.) · "How do you test it?" (A fake WebSocket and fake timers; check the transactions.)

---

### Q13. Row grouping, aggregation, pivoting and total rows: what's Community and what's Enterprise?  `[P1]`
**Say this first (~30 sec):** "Grouping, aggregation, pivoting and grand total rows are all Enterprise. I set `rowGroup: true` on the columns to group by, and `aggFunc`, like `'sum'` or `'avg'`, on the value columns. `grandTotalRow` adds a total row, which can be pinned. In Community, I build the summary myself: compute the totals with `useMemo` and show them with `pinnedBottomRowData`. That row stays at the bottom and is not sorted or filtered. Jupiter uses Enterprise row grouping and status-bar sums."

**If they dig deeper:**

```tsx
// Community: compute the total row yourself.
const totals = useMemo(() => {
  let volumeMwh = 0;
  let pnl = 0;
  for (const d of deals) {
    volumeMwh += d.volumeMwh;
    pnl += d.pnl;
  }
  return [{ dealId: 'TOTAL', volumeMwh, pnl }];
}, [deals]);
const getRowStyle = (r: RowClassParams<Deal>) =>
  r.node.rowPinned ? { fontWeight: 600 } : undefined;

return (
  <AgGridReact<Deal>
    rowData={deals}
    columnDefs={props.cols}
    pinnedBottomRowData={totals} // not sorted/filtered
    getRowStyle={getRowStyle}
  />
);
```

```tsx
// Enterprise (RowGroupingModule): group + aggregate.
const columnDefs = useMemo<ColDef<Deal>[]>(
  () => [
    { field: 'book', rowGroup: true, hide: true },
    { field: 'counterparty' },
    { field: 'volumeMwh', aggFunc: 'sum' },
    { field: 'pnl', aggFunc: 'sum' },
  ],
  [],
);

return (
  <AgGridReact<Deal>
    rowData={props.deals}
    columnDefs={columnDefs}
    groupDefaultExpanded={1} // open first level
    grandTotalRow="pinnedBottom" // total, pinned
  />
);
```

- **Built-in `aggFunc`s:** sum, min, max, count, avg, first, last. Register custom ones by name with the `aggFuncs` grid option, so they also work in saved state.
- `groupDefaultExpanded`: 1 opens the first level, -1 opens all. `autoGroupColumnDef` styles the group column. `rowGroupPanelShow` lets users drag columns to group.
- **Totals:** `grandTotalRow` is `'top'`, `'bottom'`, `'pinnedTop'` or `'pinnedBottom'`. `groupTotalRow` adds a total under each group.
- **Status bar** (Enterprise): `statusBar` with `agAggregationComponent` shows totals (sum, average, count...) for the selected cells. That's Jupiter's "status-bar sums".
- **Pivot:** `pivotMode` plus `pivot: true` on a column, for example one column per month.
- **Pinned rows** are Community. v33.3 added user row pinning (`enableRowPinning`); pinning from the context menu is Enterprise.
- **Official numbers come from the server.** A sum of rounded rows can differ from a rounded total. Decide which one the business wants ([S8](../AI%20Engineer/13-Behavioral-Story-Bank.md#s8)).

**Your angle:** Live Deal Summary uses row grouping `[fill in: grouped by what]`. The Load Book hedge grid has a status-bar sum and pinned bottom totals. Your Flash Table has pinned month rows, column groups, and a month accordion you built with your own header and label cell. AMP removed its grouping: it was Enterprise-only.
**Likely follow-ups:** "Does a pinned total follow the filters?" (Not by itself. Recompute it in `onFilterChanged` with `api.forEachNodeAfterFilter`, or use Enterprise `grandTotalRow`.) · "Group 1 million rows?" (SSRM: the server groups.)

---

### Q14. How do you format numbers, money, dates and time zones? Tell me about the daylight-saving bug.  `[P0]`
**Say this first (~30 sec):** "For numbers I use a `valueFormatter` with one cached `Intl.NumberFormat`, and I keep the value a number so sorting works. Dates and times are where the real bugs live. In Jupiter I fixed one. On the fall-back day, the two 1 AM hours collapsed into one, because date plus hour ending was turned into New York local time, and that local time names only one instant. Now every hourly row is keyed by date, hour ending and EDT or EST, so a day can have 23, 24 or 25 rows. The grids got a TZ column, and the Excel export keeps both 1 AM rows, sorted by TZ."

**If they dig deeper:**

```ts
// Create formatters once (module scope), not per cell.
export const money = new Intl.NumberFormat('en-US', {
  style: 'currency',
  currency: 'USD',
  currencySign: 'accounting', // -1200 -> ($1,200.00)
});
export const mwh = new Intl.NumberFormat('en-US', {
  maximumFractionDigits: 1, // 12345.67 -> 12,345.7
});

// Show instants in the MARKET zone, with the zone
// name, never in the browser's own zone.
export const nyHour = new Intl.DateTimeFormat('en-US', {
  timeZone: 'America/New_York',
  month: '2-digit',
  day: '2-digit',
  hour: '2-digit',
  minute: '2-digit',
  hourCycle: 'h23',
  timeZoneName: 'short',
});
nyHour.format(new Date('2026-11-01T05:00:00Z'));
// -> "11/01, 01:00 EDT"
nyHour.format(new Date('2026-11-01T06:00:00Z'));
// -> "11/01, 01:00 EST"
```

```ts
// The bug, simplified: wall-clock text -> instant.
// In a New York browser, BOTH 1 AM hours of
// Nov 1, 2026 become the same instant (05:00Z).
const first = new Date('2026-11-01T01:00:00');
// The second 1 AM (EST, 06:00Z) can't be named this
// way, so one row overwrote the other.
```

```ts
// The fix: one row per market hour, keyed by
// date + hour ending + zone. 23, 24 or 25 rows a day.
export interface HourRow {
  date: string; // market day, '2026-11-01'
  he: number; // hour ending
  tz: 'EDT' | 'EST'; // which side of the change
  mw: number;
}

export const getHourId: GetRowIdFunc<HourRow> = ({
  data,
}) => `${data.date}|${data.he}|${data.tz}`;

// Default sort: date, then HE, then TZ.
// 'EDT' < 'EST' as text, so the first 1 AM (EDT)
// comes before the repeated one (EST).
export const hourCols: ColDef<HourRow>[] = [
  { field: 'date', sort: 'asc', sortIndex: 0 },
  {
    field: 'he',
    headerName: 'HE',
    sort: 'asc',
    sortIndex: 1,
  },
  {
    field: 'tz',
    headerName: 'TZ',
    sort: 'asc',
    sortIndex: 2,
  },
  {
    field: 'mw',
    headerName: 'MW',
    valueFormatter: (p) =>
      p.value == null ? '' : mwh.format(p.value),
  },
];
```

- **Rules I follow:**
  - Send instants as ISO 8601 with `Z` or an offset. Never parse a wall-clock string without a zone: `new Date('2026-11-01T01:00:00')` uses the browser's zone.
  - Format in the **market's** zone (`timeZone: 'America/New_York'`), not the user's, and show the zone name.
  - Never assume 24 hours. In 2026, March 8 had 23 hours and November 1 (this past Sunday) had 25.
  - Never build the hours by adding 1 hour to local midnight.
- **Spring forward is the mirror bug.** `2026-03-08T02:00` doesn't exist in New York. The browser moves it, so it becomes the same instant as 3 AM.
- **AG Grid date types:** `cellDataType: 'dateTime'` or `'dateTimeString'` use ISO formats by default. Override them for display.
- **Excel has no time zones.** Its dates are plain numbers, so the two 1 AM rows look the same in a date column. Keep a TZ (or UTC) column. For a real Excel date, AG Grid needs `dataType: 'DateTime'`, an ISO string and a `numberFormat` (Q15).
- **Test the DST days:** Nov 1, 2026 → 25 rows, EDT before EST. Mar 8, 2026 → 23 rows.
- **Backend side:** in Python, `datetime` uses `fold=1` for the second (repeated) hour, and `zoneinfo` respects it. Store the instant (UTC) for math, and keep date + HE + TZ for labels and keys.

**Your angle:** This is your best AG Grid story: a real bug that crossed the backend, the grids and the export. Tell it in STAR order:
- **Situation:** how it was found. `[fill in: who noticed, and what they saw]`
- **Root cause:** date + hour ending → New York local time → one instant for both 1 AM hours.
- **Where:** both sides, about 27 backend and 10 UI commits. `[fill in: where the bad conversion was]`
- **Fix:** the key, the TZ column, the export order.
- **Result:**
  - Price & Load and the long-term forecast got a TZ column after HE, sorted Date, HE, TZ.
  - The current-hour highlight matches the Eastern date, HE and TZ.
  - Hedge legs show wall-clock begin and end times.
  - Excel exports keep both 1 AM rows and carry TZ.
  - Tests: column placement and sort with TZ, the fall-back-day highlight, and the 25-row exports.

See also [06 Q2](06-Jupiter-Load-Deal-Deep-Dive.md).
**Likely follow-ups:** "Why not keep everything in UTC?" (UTC is right for storage and math. But traders think in market days and hour-ending labels, so you need both.) · "How did you test it?" (What you really did: unit tests for column placement and sort with TZ, the fall-back-day highlight, and a 25-row export.)

---

### Q15. CSV vs Excel export: what gets exported, and what can go wrong?  `[P1]`
**Say this first (~30 sec):** "CSV export is Community: `api.exportDataAsCsv()`. Excel export is Enterprise: `api.exportDataAsExcel()`, with real Excel types, styles and several sheets. PDF export is new in 36.2 and also Enterprise. By default, both export what the grid shows: the current sort, filter and column order. They use value getters and value formatters, but not cell renderers. For very large exports, I run a job on the server instead of building the file in the browser."

**If they dig deeper:**

```ts
// Excel/Sheets run cells that start with these
// characters as formulas ("CSV injection").
const RISKY = /^[=+\-@\t\r]/;

api.exportDataAsCsv({
  fileName: `deals-${today}.csv`,
  processCellCallback: ({ value, formatValue }) => {
    // We handle the cell, so format it ourselves.
    const text = formatValue(value);
    // Only text: negative numbers also start with "-".
    return typeof value === 'string' && RISKY.test(text)
      ? `'${text}`
      : text;
  },
});
```

```ts
// Enterprise (ExcelExportModule). Exports what the
// grid shows: sort, filter, column order.
api.exportDataAsExcel({
  fileName: 'deals.xlsx',
  sheetName: 'Deals',
});
```

- **Formatted vs raw:** formatters are used for export by default. Money exported as text can't be summed in Excel. For Excel, export the number and give it an Excel `numberFormat` through `excelStyles`.
- **Excel styles reuse your CSS class names:** classes from `cellClass` and `cellClassRules` are matched to `excelStyles` IDs. So `pnl-neg` can be red in Excel too.
- With `processCellCallback`, the formatter is not used. Call `formatValue` yourself (as above).
- **CSV injection:** cells that start with `=`, `+`, `-`, `@`, Tab or CR can run as formulas. Escape text cells, but not numbers. Negative numbers also start with "-".
- **Excel dates:** use `dataType: 'DateTime'` with ISO `yyyy-mm-ddThh:mm:ss` and a `numberFormat`, or the cell shows a plain number.
- **Choose what to export:** `columnKeys`, `allColumns`, `onlySelected`.
- With streaming data, call `flushAsyncTransactions()` before you export.

**Your angle:** Jupiter uses both kinds. Three grids use AG Grid's `exportDataAsExcel` (another engineer's). The rest use **exceljs**, also built by another engineer. You added the TZ sort and a Losses % fix, and rewrote the load forecast export for DST, so it keeps both 1 AM rows (Q14). AMP doesn't use grid export: exceljs + file-saver, and hand-built CSV. You fixed a hidden character in a volume table's CSV dates.
- **Why exceljs, if asked** (a likely reason, not in the code): a hand-built workbook can match a fixed layout. Grid export is best when the file should match the screen.
**Likely follow-ups:** "Export 2 million rows?" (A server job and a short-lived download link: [05 Q1](05-Frontend-System-Design.md).) · "What the user sees, or everything?" (Ask. Either way, the server applies filters and permissions too.)

---

### Q16. How do you save and restore a user's grid layout?  `[P1]`
**Say this first (~30 sec):** "The grid state API saves sort, filters, column order, widths, pinning, visibility, grouping, pagination and selection as one JSON object. I pass a saved object as `initialState`, which is read once when the grid starts, and I save changes from `onStateUpdated` or `api.getState()`. For finer control there's the column state API: `getColumnState` and `applyColumnState`. I store it per user and per grid, with a version in the key: in localStorage, or on the server so it follows the user."

**If they dig deeper:**

```tsx
// Version the key: old saved state can break
// after you change the columns.
const KEY = 'deals-grid-state-v2';

// initialState is read ONCE, when the grid starts.
const initialState = useMemo<GridState | undefined>(
  () => {
    try {
      const raw = localStorage.getItem(KEY);
      if (!raw) return undefined;
      return JSON.parse(raw) as GridState;
    } catch {
      return undefined; // private mode, bad JSON
    }
  },
  [],
);

const onStateUpdated = useCallback(
  (e: StateUpdatedEvent<Deal>) => {
    // sort, filter, column order/width/pinning...
    localStorage.setItem(KEY, JSON.stringify(e.state));
  },
  [],
);

return (
  <AgGridReact<Deal>
    rowData={props.deals}
    columnDefs={props.cols}
    initialState={initialState}
    onStateUpdated={onStateUpdated}
  />
);
```

- To apply state later, use `api.setState(state, propertiesToIgnore)`.
- Functions are removed from state. Register custom `aggFunc`s by name so they survive.
- **Give every column a `colId` or `field`.** A column with only a `valueGetter` gets an ID from its position, so after you reorder `columnDefs` its saved state can land on the wrong column.
- Debounce the saves, and handle bad or old state (try/catch, a versioned key).
- **Server layouts:** one endpoint per user + grid ID, and maybe shared "desk views".

**Your angle:** Two Jupiter grids do. Live Deal Summary saves its column state in session storage, and ST Forecast saves its state in local storage. Neither uses the grid's newer state API (`initialState`, `getState`). Nothing is saved per user on the server. "If traders wanted layouts on every machine, I'd add a per-user layout endpoint behind entitlements ([S9](../AI%20Engineer/13-Behavioral-Story-Bank.md#s9))."
**Likely follow-ups:** "A deploy renames a column?" (Versioned key, stable `colId`s, ignore unknown columns.) · "Why not save the row data too?" (State is the layout. Data comes fresh from the API.)

---

### Q17. How do you theme and style the grid? How do you show negative PnL in red?  `[P0]`
**Say this first (~30 sec):** "Since v33 the grid uses the Theming API. I import a built-in theme like `themeQuartz` and change it in code: `withParams` for colors, font and spacing, and `withPart`, for example for a dark color scheme. The grid injects the CSS, so there's no CSS file to import. For styling based on data I use `cellClassRules` and `rowClassRules`, which add a CSS class when a rule is true. For negative PnL: a `pnl-neg` class for red, plus a minus sign or parentheses, so color is not the only signal."

**If they dig deeper:**

```tsx
import {
  colorSchemeDark,
  themeQuartz,
  type ColDef,
  type RowClassParams,
} from 'ag-grid-community';
import type { Deal } from './types';

export const gridTheme = themeQuartz.withParams({
  accentColor: '#0b5cad',
  fontFamily: 'Inter, sans-serif',
  headerFontWeight: 600,
  spacing: 4, // denser rows for trading screens
});
export const gridThemeDark =
  gridTheme.withPart(colorSchemeDark);
```

```tsx
const columnDefs = useMemo<ColDef<Deal>[]>(
  () => [
    { field: 'dealId' },
    {
      field: 'pnl',
      // CSS class on the cell when the rule is true
      cellClassRules: {
        'pnl-neg': (c) => (c.value ?? 0) < 0,
        'pnl-pos': (c) => (c.value ?? 0) > 0,
      },
    },
  ],
  [],
);
const rowClassRules = useMemo(
  () => ({
    // grey out settled deals
    'row-settled': (r: RowClassParams<Deal>) =>
      r.data?.status === 'Settled',
  }),
  [],
);

return (
  <AgGridReact<Deal>
    rowData={props.deals}
    columnDefs={columnDefs}
    rowClassRules={rowClassRules}
    theme={props.dark ? gridThemeDark : gridTheme}
  />
);
```

```css
.pnl-neg { color: #b42318; }
.pnl-pos { color: #067647; }
.row-settled { opacity: 0.6; }
/* digits line up in number columns */
.ag-cell { font-variant-numeric: tabular-nums; }
```

- **Built-in themes:** Quartz (the default), Balham (spreadsheet look), Material and Alpine.
- **Dark mode:** switch theme objects, or set `data-ag-theme-mode="dark"` on `<body>` (theme modes).
- **Options:** cells have `cellStyle`, `cellClass` and `cellClassRules`. Rows have `rowClass`, `getRowClass`, `getRowStyle` and `rowClassRules`. I prefer classes to inline styles: CSS stays in one place, and the same classes drive Excel styles (Q15).
- **Old projects** use `theme="legacy"` and CSS files. Don't mix the two ways.
- **v36:** the scroll DOM changed. Old CSS aimed at containers like `.ag-body-viewport` or `.ag-center-cols-container` breaks. Style cells, not containers.
- AG Grid's Theme Builder on the website generates the parameters.

**Your angle:** Jupiter uses Tailwind 3 for the rest of the UI. Its grids use the **legacy CSS themes** (alpine, quartz on a few) with `theme="legacy"`. Dark mode swaps the wrapper to the dark theme class, and some grids remount when the theme changes. Negatives get a red class from the shared formatters. AMP uses legacy alpine everywhere. Moving both to the Theming API is a good upgrade step: one theme object, and dark mode through a color scheme, without a remount.
**Likely follow-ups:** "Why classes instead of `cellStyle`?" (One place for CSS, dark mode, and reuse in Excel.) · "Red in Excel too?" (Yes: an `excelStyles` entry with the same ID as the class.)

---

### Q18. Master/detail vs tree data: when do you use each?  `[P2]`
**Say this first (~30 sec):** "Both are Enterprise. Master/detail is for a parent row with a different kind of child list. For example, a deal row opens a second grid with its trades, and that grid has its own columns. Tree data is for one kind of row in a hierarchy, like portfolio, book and sub-book. Every level has the same columns, and parents can add up their children. I give the tree with `getDataPath`, a children field, or a parent ID."

**If they dig deeper:**

```tsx
const columnDefs = useMemo<ColDef<DealWithTrades>[]>(
  () => [
    // the expand arrow lives in this column
    {
      field: 'dealId',
      cellRenderer: 'agGroupCellRenderer',
    },
    { field: 'pnl' },
  ],
  [],
);
const detailCellRendererParams = useMemo(
  (): Partial<
    IDetailCellRendererParams<DealWithTrades, Trade>
  > => ({
    detailGridOptions: {
      columnDefs: [
        { field: 'tradeId' },
        { field: 'qty' },
      ],
    },
    getDetailRowData: (params) =>
      params.successCallback(params.data.trades),
  }),
  [],
);

return (
  <AgGridReact<DealWithTrades>
    rowData={props.deals}
    columnDefs={columnDefs}
    masterDetail // Enterprise: MasterDetailModule
    detailCellRendererParams={detailCellRendererParams}
  />
);
```

```tsx
// Enterprise: TreeDataModule
const getDataPath = useCallback<GetDataPath<Book>>(
  (b) => b.path,
  [],
);
const columnDefs = useMemo<ColDef<Book>[]>(
  () => [{ field: 'pnl', aggFunc: 'sum' }],
  [],
);
return (
  <AgGridReact<Book>
    rowData={props.books}
    columnDefs={columnDefs}
    treeData
    getDataPath={getDataPath}
    groupDefaultExpanded={-1} // expand all
  />
);
```

- **Master/detail:** `masterDetail`, `agGroupCellRenderer` on the first column, and `detailCellRendererParams` with `detailGridOptions` and `getDetailRowData`. `getDetailRowData` can fetch from the API when the row opens. Each detail is a full grid, so keep them small.
- **Tree data inputs:** a path (`getDataPath`), nested records (`treeDataChildrenField`), or rows with a parent ID (`treeDataParentIdField`).
- **Grouping vs tree data:** grouping makes groups from a column's values. Tree data uses a hierarchy that is already in the data.
- v34.1 allows tree data and master/detail together. For huge trees, SSRM can load children from the server.

**Your angle:** Jupiter uses tree data on ST Forecast and Load Book. `[fill in: what the levels are]` Neither app uses master/detail.
**Likely follow-ups:** "Keep rows open after a refresh?" (`getRowId`; the grid state also saves which groups are open.) · "Load children lazily?" (SSRM, or master/detail with a fetch in `getDetailRowData`.)

---

### Q19. How do you make a grid accessible and keyboard-friendly?  `[P1]`
**Say this first (~30 sec):** "AG Grid follows the ARIA grid pattern: `role="grid"`, or `treegrid` with grouping, plus `aria-rowindex`, `aria-colindex`, `aria-sort` and `aria-selected`. The keyboard works out of the box: arrows move, Tab moves across, Enter or F2 starts editing, Escape cancels, and Space selects a row. My job is the parts I add. Custom renderers must handle their own focus. Color needs a second signal, like a sign or an icon. And for screen-reader users I can turn on `ensureDomOrder` and use pagination, because with virtualization not every row is in the DOM."

**If they dig deeper:**

```tsx
<AgGridReact<Deal>
  rowData={props.deals}
  columnDefs={props.cols}
  ensureDomOrder // DOM order = visual order
  pagination // a small page of rows...
  paginationPageSize={50}
  suppressRowVirtualisation // ...so all can render
/>
```

- **Custom navigation:** `navigateToNextCell`, `tabToNextCell`, and `suppressKeyboardEvent` per column.
- Validation errors are read out by screen readers (v34+).
- Contrast comes from theme parameters. Test with axe and a screen reader (VoiceOver, JAWS).
- Don't put many tab stops inside each cell.
- More basics in [03 Q23](03-React-Fundamentals.md).

**Your angle:** Trading users work from the keyboard, so keyboard support is a speed feature, not only compliance. `[fill in: any accessibility requirement at BETM]`
**Likely follow-ups:** "How do you test it?" (A keyboard-only walk-through, plus axe in Playwright.)

---

### Q20. How do you test components that use AG Grid?  `[P1]`
**Say this first (~30 sec):** "Three layers. My own logic, like formatters, value getters, comparators and the datasource, is plain functions, so I unit test it without the grid. Renderers and editors are plain React components, so I test them alone with Testing Library. For the grid itself, AG Grid recommends end-to-end tests in a real browser, because jsdom has no layout: a 60-row grid there renders only about 11 rows. AG Grid's `setupAgTestIds` and `agTestIdFor` give stable test IDs for cells, by row ID and column ID."

**If they dig deeper:**

```tsx
import { render, screen } from '@testing-library/react';
import {
  AllCommunityModule,
  agTestIdFor,
  setupAgTestIds,
} from 'ag-grid-community';
import { AgGridProvider } from 'ag-grid-react';
import { beforeAll, expect, test } from 'vitest';
import { DealGrid } from './DealGrid';

// deals = 60 test rows; D-1 has pnl 3400.
beforeAll(() => setupAgTestIds()); // adds data-testid

test('shows the PnL of deal D-1', async () => {
  render(
    <AgGridProvider modules={[AllCommunityModule]}>
      <DealGrid deals={deals} />
    </AgGridProvider>,
  );
  // The grid renders after a tick: use findBy.
  const cell = await screen.findByTestId(
    agTestIdFor.cell('D-1', 'pnl'), // row ID, col ID
  );
  expect(cell.textContent).toBe('3400');
});
```

```ts
import { expect, test } from '@playwright/test';
import { agTestIdFor } from 'ag-grid-community';

test('edit volume and see it saved', async ({ page }) => {
  await page.goto('/deals'); // app calls setupAgTestIds()
  const cell = page.getByTestId(
    agTestIdFor.cell('D-42', 'volumeMwh'),
  );
  await cell.dblclick(); // start editing
  await page.keyboard.press('ControlOrMeta+A');
  await page.keyboard.type('120');
  await page.keyboard.press('Enter'); // commit
  await expect(cell).toHaveText('120');
  await expect(page.getByRole('alert')).toHaveCount(0);
});
```

- **Wait for the grid.** It renders after a tick, so use `findBy...`, not `getBy...`.
- **jsdom limits:** no layout, so only the row buffer renders (about 11 of 60 rows when this page's samples were checked). Off-screen rows don't exist. Use small test data, check with `api.getDisplayedRowCount()`, or use E2E. The docs also give an `innerText` polyfill if text is missing.
- `getGridApi('myGridId')` gets a grid's API in tests (set the `gridId` prop).
- **Don't select by the grid's CSS classes.** v36 changed the DOM, and old recorded tests broke. Use test IDs or roles (`role="gridcell"`).
- Call `setupAgTestIds()` only outside production.
- **E2E the flows that matter:** edit and save, export, filters, and the DST days.

**Your angle:** You wrote 68 of the 102 UI test files in Watt with Vitest + Testing Library. Jupiter also uses Vitest, but **no test mounts a grid**. Your tests cover the logic around the grids: column placement and sort with TZ, the fall-back-day highlight, the 25-row exports, row mappers and the Flash Table model. That's a fair answer: unit-test the pure logic, and test the grid itself in a real browser. AMP has 3 Jest utility tests, none for grids. A DST unit test is a great example: "Nov 1, 2026 has 25 rows, EDT before EST."
**Likely follow-ups:** "Why not snapshot the grid?" (Big, brittle, and virtualized.) · "How do you test the datasource?" (Mock `fetch` and check the request body and the rows passed to `successCallback`.)

---

### Q21. What are Integrated Charts, and how do they relate to AG Charts?  `[P2]`
**Say this first (~30 sec):** "AG Charts is AG Grid's separate charting library, with its own packages: `ag-charts-community`, `ag-charts-enterprise` and `ag-charts-react`, now version 14. You can use it alone, like any chart library. Integrated Charts is an Enterprise grid feature built on AG Charts: users select cells, right-click and make a chart, and the chart updates when the grid data changes. Since v33 you install AG Charts yourself and pass it in: `IntegratedChartsModule.with(AgChartsEnterpriseModule)`."

**If they dig deeper:**

```tsx
// Integrated Charts (Enterprise): users chart a
// selected cell range from inside the grid.
import {
  ClientSideRowModelModule,
} from 'ag-grid-community';
import {
  CellSelectionModule,
  IntegratedChartsModule,
} from 'ag-grid-enterprise';
import {
  AgChartsEnterpriseModule,
} from 'ag-charts-enterprise';

export const modules = [
  ClientSideRowModelModule,
  CellSelectionModule,
  IntegratedChartsModule.with(AgChartsEnterpriseModule),
];
// <AgGridReact cellSelection enableCharts ... />
```

```tsx
// Standalone AG Charts (its own package, v14).
import { useMemo } from 'react';
import { AgCharts } from 'ag-charts-react';
import {
  AllCommunityModule,
  ModuleRegistry,
  type AgCartesianChartOptions,
} from 'ag-charts-community';

ModuleRegistry.registerModules([AllCommunityModule]);

interface Point {
  he: number;
  awardsMw: number;
  hedgesMw: number;
}

export function AwardsVsHedges(
  { data }: { data: Point[] },
) {
  const options = useMemo<AgCartesianChartOptions>(
    () => ({
      data,
      series: [
        { type: 'line', xKey: 'he', yKey: 'awardsMw' },
        { type: 'line', xKey: 'he', yKey: 'hedgesMw' },
      ],
    }),
    [data],
  );
  return <AgCharts options={options} />;
}
```

- Turn it on with `enableCharts` and cell selection. Code can also create charts, for example with `api.createRangeChart(...)`.
- **Licence:** integrated Enterprise charts need the "Enterprise Bundle" licence (grid + charts). Without it you get integrated Community charts.
- **Sparklines** (Enterprise): tiny charts inside cells.
- AG Charts also uses modules: register `AllCommunityModule` from `ag-charts-community`.
- Chart libraries are big. Lazy-load chart pages ([03 Q14](03-React-Fundamentals.md)).

**Your angle:** Jupiter has integrated charts on the Live Deal Summary grid, and Load Book uses standalone AG Charts for awards vs hedges. It also uses ApexCharts and Vega-Lite ([06](06-Jupiter-Load-Deal-Deep-Dive.md)). Integrated charts need AG Charts Enterprise (12.3.1 here), registered with the grid in the entry file. `[fill in: who built these charts, and why AG Charts there]`
**Likely follow-ups:** "Integrated or standalone?" (Integrated: users explore ad hoc. Standalone: a fixed, designed chart.) · "Why three chart libraries?" ([06](06-Jupiter-Load-Deal-Deep-Dive.md))

---

### Q22. How do you show a table when you don't know the columns in advance?  `[P1]`
**Say this first (~30 sec):** "On my Ask AI page, each answer's result table is an AG Grid, so the columns aren't known in advance. They have to come from the result. What matters: build `columnDefs` from the result's column list in `useMemo`, keyed on the result. Set `cellDataType` from the SQL type, so numbers sort as numbers. Watch the names: AG Grid reads dots in `field` as nested paths, so a name like `T.PNL` breaks unless you set `suppressFieldDotNotation` or rename the fields. And format numbers the same way as the rest of the app."

**If they dig deeper:**

```tsx
import type { ColDef } from 'ag-grid-community';

type Row = Record<string, unknown>;
type ColType = 'number' | 'text' | 'date';
interface SqlResult {
  columns: { name: string; type: ColType }[];
  rows: Row[];
}

const TYPE = {
  number: 'number',
  text: 'text',
  date: 'dateString', // 'YYYY-MM-DD' strings
} as const;

export function ResultTable(
  { result }: { result: SqlResult },
) {
  // New result -> new columns. Same result -> same ref.
  const columnDefs = useMemo<ColDef<Row>[]>(
    () =>
      result.columns.map((c) => ({
        field: c.name,
        headerName: c.name,
        cellDataType: TYPE[c.type],
      })),
    [result],
  );

  return (
    <AgGridReact<Row>
      rowData={result.rows}
      columnDefs={columnDefs}
      // SQL names like "AVG(PRICE)" or "T.PNL":
      // treat dots as plain text, not nested paths.
      suppressFieldDotNotation
    />
  );
}
```

- **v36 shortcut:** `autoGenerateColumnDefs` (Community) builds columns from the first non-null row. It's quick, but you lose control of types, headers and formats, and it needs v36.
- **No natural row ID:** skip `getRowId`. The result is read-only and replaced as a whole.
- **Big results:** limit rows on the server (the agent uses a read-only database role) and show "first N rows".
- **AI output is untrusted text.** The grid shows values as text, so don't render HTML from it. If users export to CSV, escape formula characters (Q15).

**Your angle:** [S1](../AI%20Engineer/13-Behavioral-Story-Bank.md#s1): Load Deal AI's chat page shows the SQL, the result table and a chart. You built the result table and its formatter (Sep 2026). You also fixed a 130px blank band in dark mode by making the tall drop zone opt-in. `[fill in: how your code builds the column defs, and the row limit]` Say only what your code really does. For the rest, say "I would".
**Likely follow-ups:** "The model returns 100,000 rows?" (A server-side limit and paging.) · "Column order?" (Keep the SQL order.)

---

### Q23. "The grid doesn't update." What are the common AG Grid bugs in React?  `[P0]`
**Say this first (~30 sec):** "Most of them come from references and ownership. New `columnDefs` on every render reset column widths and sort. No `getRowId` means selection and scroll reset on every refresh. Mutating `rowData` means neither React nor the grid sees a change. Callbacks that captured old state show old values. And mixing React-owned `rowData` with grid transactions lets one undo the other. A blank grid is usually a parent with no height, or a missing module."

**If they dig deeper:**

```tsx
// Bug: new array every render -> the grid re-applies
// columns and can reset widths, order and sort.
const bad = [{ field: 'pnl' }] as ColDef<Deal>[];

// Fix: stable reference.
const good = useMemo<ColDef<Deal>[]>(
  () => [{ field: 'pnl' }],
  [],
);
```

```tsx
// A value that changes (FX rate) that renderers and
// valueGetters need: put it in the grid context.
const context = useMemo(() => ({ rate: 1 }), []);

const onRateChange = useCallback((next: number) => {
  const api = gridRef.current?.api;
  if (!api) return;
  api.setGridOption('context', { rate: next });
  api.refreshCells(); // context changes don't redraw
}, []);
```

- **Symptom → cause → fix:**
  - **Blank grid** → the parent has no height, or a module isn't registered → set a height; turn on `enableDevValidations()` to see the error.
  - **Widths or sort reset while typing** → new `columnDefs` every render → `useMemo` / `useState`.
  - **Selection lost after refresh** → no `getRowId` → add it.
  - **Grid doesn't update** → you mutated the same objects, or changed an "initial" option (`rowModelType`, `initialState`, `context`) after start → new objects, or `api.setGridOption`.
  - **Renderer shows old app state** → a callback in `cellRendererParams` was memoized with old state → use stable callbacks with functional `setState`, or the grid `context` + `refreshCells()`.
  - **Edits disappear after a re-fetch** → the grid changed your objects, then React sent old data → `readOnlyEdit` (Q8).
  - **Money sorts like text** → the value is a formatted string → keep numbers; use `valueFormatter`.
  - **Styling broke after an upgrade** → v33 themes or v36 DOM classes (Q24).
  - **Watermark in production** → Enterprise modules with no licence key.
  - **A value is missing in Excel** → only a renderer draws it (Q4).
  - **Two "1 AM" rows become one** → ambiguous times as keys (Q14).

**Your angle:** Use this as your review checklist. You approved 26 grid PRs on Jupiter ([M1](../AI%20Engineer/13-Behavioral-Story-Bank.md#m1)). Real grid bugs you fixed:
- **AMP:** grouping props and a set filter with no Enterprise package. They never worked. You removed them.
- **AMP:** a duplicate row ID on File Center. You added the folder name to the key.
- **Jupiter:** ARR/MLC grids collapsed to zero height because of a legend.
- **Jupiter:** a `Date` built for every cell in the current-hour check.
**Likely follow-ups:** "How do you stop these in review?" (The hooks lint rule, a shared grid wrapper with stable defaults, and dev validations on.)

---

### Q24. What changed in AG Grid v33–v36, and how would you upgrade an old grid?  `[P1]`
**Say this first (~30 sec):** "The big breaking release was v33, in December 2024. Modules became required, and themes moved from CSS files to the Theming API. Selection had already moved to the `rowSelection` object in 32.2. v34 added editor validation and batch editing. v35 added formulas, and 35.1 added `AgGridProvider`. v36, in June 2026, took dev validation out of the default bundles and changed the scroll DOM, so old CSS selectors and recorded tests can break. To upgrade, I go one major version at a time, run AG Grid's codemods, read each migration guide, and test the most important grids."

**If they dig deeper:**
- **v33 codemod:** `npx @ag-grid-devtools/cli@latest migrate --from=<old> --to=33.0`. Keep the old look first with `theme: "legacy"`, then move to the Theming API later.
- **v33:** the scoped `@ag-grid-community/*` packages were removed; use `ag-grid-community` / `ag-grid-enterprise`. Integrated charts and sparklines need `ag-charts-*` installed separately. With v33, AG Grid also started an LTS line for v32.
- **v34:** filter `getModel()` / `setModel()` deprecated → `api.getColumnFilterModel` / `api.setColumnFilterModel`.
- **v36:**
  - minimum TypeScript 5.8.3
  - the client-side row model is part of the core
  - call `enableDevValidations()` in development
  - container classes like `.ag-body-viewport` and `.ag-center-cols-container` were replaced
- **Plan:** a branch per major version, a visual check of each grid, and E2E tests for edit, filter and export.

**Your angle:** Jupiter is on **34.3.1 Enterprise** and AMP on **33.2.1 Community**. Both are past v33, but both still use legacy CSS themes. You did AMP's v33 cleanup yourself, on Mar 4, 2026, in 3 commits:
- removed Enterprise-only props that weren't registered
- fixed the selection deprecations and page-size mismatches
- added `theme="legacy"` to nine grids, and fixed a duplicate row ID

One AMP grid still lacks `theme="legacy"` and uses old selection props. **Next steps to 36:** the Theming API, a check for CSS that targets the old scroll containers, and `AgGridProvider`. For AMP, do it together with CRA → Vite ([03 Q16](03-React-Fundamentals.md)).
**Likely follow-ups:** "Why upgrade at all?" (Fixes, React 19 support, smaller bundles, new features.) · "How do you lower the risk?" (One major at a time, codemods, E2E on key flows.)

---

### Q25. Live coding: a PnL grid with formatted columns and red/green cells  `[P0]`
**Task (~25 min):** "Show PnL by book: Book, Region, MWh, Day PnL, MTD PnL. Show money as currency, negatives in red and positives in green, and add a total row."

**Say this first (~30 sec):** "I'll type the row first. Then memoized column defs, with one shared money formatter and `cellClassRules` for red and green. Negative numbers also get parentheses, so color is not the only signal. The total row is computed with `useMemo` and shown as a pinned bottom row, so this works in Community. I'll use the book as the row ID."

**If they dig deeper:**

```tsx
// PnlGrid.tsx
import { useMemo } from 'react';
import { AgGridReact } from 'ag-grid-react';
import type {
  CellClassParams,
  ColDef,
  GetRowIdFunc,
  RowClassParams,
  ValueFormatterParams,
} from 'ag-grid-community';

export interface PnlRow {
  book: string;
  region: string;
  volumeMwh: number;
  dayPnl: number;
  mtdPnl: number;
}

const money = new Intl.NumberFormat('en-US', {
  style: 'currency',
  currency: 'USD',
  currencySign: 'accounting', // ($1,200.00)
});
const mwh = new Intl.NumberFormat('en-US', {
  maximumFractionDigits: 1,
});

type Fmt = ValueFormatterParams<PnlRow, number>;
const fmtMoney = (p: Fmt) =>
  p.value == null ? '' : money.format(p.value);

type Cls = CellClassParams<PnlRow, number>;
const pnlRules = {
  'pnl-neg': (p: Cls) => (p.value ?? 0) < 0,
  'pnl-pos': (p: Cls) => (p.value ?? 0) > 0,
};

const pnlCol = (
  field: 'dayPnl' | 'mtdPnl',
  headerName: string,
): ColDef<PnlRow, number> => ({
  field,
  headerName,
  valueFormatter: fmtMoney,
  cellClassRules: pnlRules,
});

const getRowId: GetRowIdFunc<PnlRow> = ({ data }) =>
  data.book;

const rowClassRules = {
  'row-total': (p: RowClassParams<PnlRow>) =>
    p.node.rowPinned === 'bottom',
};

export function PnlGrid({ rows }: { rows: PnlRow[] }) {
  const columnDefs = useMemo<ColDef<PnlRow>[]>(
    () => [
      { field: 'book', pinned: 'left' },
      { field: 'region', filter: true },
      {
        field: 'volumeMwh',
        headerName: 'MWh',
        valueFormatter: (p) =>
          p.value == null ? '' : mwh.format(p.value),
      },
      pnlCol('dayPnl', 'Day PnL'),
      pnlCol('mtdPnl', 'MTD PnL'),
    ],
    [],
  );

  // Community total row: sum it yourself.
  const totals = useMemo<PnlRow[]>(() => {
    const sum = (k: 'volumeMwh' | 'dayPnl' | 'mtdPnl') =>
      rows.reduce((s, r) => s + r[k], 0);
    return [
      {
        book: 'Total',
        region: '',
        volumeMwh: sum('volumeMwh'),
        dayPnl: sum('dayPnl'),
        mtdPnl: sum('mtdPnl'),
      },
    ];
  }, [rows]);

  return (
    <div style={{ height: 480 }}>
      <AgGridReact<PnlRow>
        rowData={rows}
        columnDefs={columnDefs}
        getRowId={getRowId}
        pinnedBottomRowData={totals}
        rowClassRules={rowClassRules}
      />
    </div>
  );
}
```

```css
.pnl-neg { color: #b42318; }
.pnl-pos { color: #067647; }
.row-total { font-weight: 600; }
```

- Checked in jsdom for this page: −1200 shows as `($1,200.00)` with the `pnl-neg` class.
- **The pinned total ignores filters.** To follow them, recompute in `onFilterChanged` with `api.forEachNodeAfterFilter`, or use Enterprise `grandTotalRow` (Q13).
- The formatters live at module scope, so they're created once.
- `pinned: 'left'` keeps Book visible on narrow screens.

**Your angle:** The numbers must match the traders' workbook ([S8](../AI%20Engineer/13-Behavioral-Story-Bank.md#s8)), so the format rules (decimals, parentheses) come from the business.
**Likely follow-ups:** "Make the total follow the filters." · "Add a per-book trend chart in a cell." (Sparklines, Enterprise.) · "Red in the Excel export too." (`excelStyles` with the same class IDs.)

---

### Q26. Live coding: a live price grid with transactions and cell flash  `[P1]`
**Task (~25 min):** "Show symbols with bid, ask and last. A WebSocket sends ticks. Update the grid smoothly and flash the changes."

**Say this first (~30 sec):** "After the first render the grid owns the rows, so I update with transactions, not new `rowData`. `getRowId` is the symbol. In an effect I open the socket and keep only the newest quote per symbol in a Map. Every 250 ms I send one `applyTransactionAsync` with the adds and updates. The price columns flash on change. The cleanup closes the socket and stops the timer."

**If they dig deeper:**

```tsx
// LivePrices.tsx
import {
  useEffect,
  useMemo,
  useRef,
  useState,
} from 'react';
import { AgGridReact } from 'ag-grid-react';
import type {
  ColDef,
  GetRowIdFunc,
} from 'ag-grid-community';

export interface Quote {
  symbol: string;
  bid: number;
  ask: number;
  last: number;
  time: string;
}

const getRowId: GetRowIdFunc<Quote> = ({ data }) =>
  data.symbol;

export function LivePrices(props: {
  url: string;
  initial: Quote[];
}) {
  const { url } = props;
  const gridRef = useRef<AgGridReact<Quote>>(null);
  // Set once. After that the grid owns the rows and
  // we change them only with transactions.
  const [rowData] = useState(props.initial);

  const columnDefs = useMemo<ColDef<Quote>[]>(() => {
    const calm = window.matchMedia(
      '(prefers-reduced-motion: reduce)',
    ).matches;
    return [
      { field: 'symbol', pinned: 'left' },
      { field: 'bid', enableCellChangeFlash: !calm },
      { field: 'ask', enableCellChangeFlash: !calm },
      {
        field: 'last',
        cellRenderer: calm
          ? undefined
          : 'agAnimateShowChangeCellRenderer',
      },
      { field: 'time' },
    ];
  }, []);

  useEffect(() => {
    // Keep only the newest quote per symbol.
    const latest = new Map<string, Quote>();
    const ws = new WebSocket(url);
    ws.onmessage = (e: MessageEvent<string>) => {
      const q = JSON.parse(e.data) as Quote;
      latest.set(q.symbol, q);
    };

    // People can't read 100 ticks a second.
    // Push a batch 4 times a second.
    const timer = setInterval(() => {
      const api = gridRef.current?.api;
      if (!api || latest.size === 0) return;
      const add: Quote[] = [];
      const update: Quote[] = [];
      for (const q of latest.values()) {
        // update needs an existing row ID
        (api.getRowNode(q.symbol) ? update : add).push(q);
      }
      latest.clear();
      api.applyTransactionAsync({ add, update });
    }, 250);

    return () => {
      clearInterval(timer);
      ws.close();
    };
  }, [url]);

  return (
    <div style={{ height: 400 }}>
      <AgGridReact<Quote>
        ref={gridRef}
        rowData={rowData}
        columnDefs={columnDefs}
        getRowId={getRowId}
      />
    </div>
  );
}
```

- **Why check `getRowNode`:** an `update` for an ID the grid doesn't have is not applied, so new symbols must go in `add`.
- **StrictMode** runs effects twice in development: the socket opens, closes and opens again. The cleanup handles that.
- **Production extras:** reconnect with backoff, a "stale" badge, pause when the tab is hidden, and snapshot + sequence numbers on reconnect ([05 Q5](05-Frontend-System-Design.md)).
- **Test:** a fake `WebSocket` class and fake timers; check that one transaction carries many ticks.

**Your angle:** The same pattern without a grid is in [04 Q9](04-React-Coding-Exercises.md). Be honest that you haven't shipped this in production (Q12).
**Likely follow-ups:** "Show up/down colors." (`agAnimateShowChangeCellRenderer`, or compare with the previous price.) · "10,000 symbols?" (Subscribe only to visible rows; combine updates on the server.)

---

### Q27. Live coding: a server-backed grid with the infinite row model  `[P1]`
**Task (~30 min):** "A deals table with 2 million rows. Load rows as the user scrolls, and sort and filter on the server. Community only. Also sketch the API."

**Say this first (~30 sec):** "Two million rows can't go to the browser, and SSRM is Enterprise, so I use the infinite row model. The grid asks my datasource for blocks, with `startRow`, `endRow`, `sortModel` and `filterModel`. I POST that to a FastAPI endpoint. The endpoint allow-lists the sort columns, caps the block size, applies entitlements, and returns the rows plus `lastRow` once it knows the end. `getRowId` keeps selection across sorts."

**If they dig deeper:**

```tsx
// InfiniteDeals.tsx (Community: infinite row model)
import { useMemo } from 'react';
import { AgGridReact } from 'ag-grid-react';
import type {
  ColDef,
  GetRowIdFunc,
  IDatasource,
  SortModelItem,
} from 'ag-grid-community';
import type { Deal } from './types';

interface QueryBody {
  startRow: number;
  endRow: number;
  sort: SortModelItem[];
  filter: unknown;
}
interface QueryResult {
  rows: Deal[];
  lastRow: number | null; // null = not known yet
}

async function queryDeals(
  body: QueryBody,
): Promise<QueryResult> {
  const res = await fetch('/api/deals/query', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(body),
  });
  if (!res.ok) throw new Error(`HTTP ${res.status}`);
  return (await res.json()) as QueryResult;
}

// Module scope: one stable datasource object.
const datasource: IDatasource = {
  getRows: (p) => {
    queryDeals({
      startRow: p.startRow,
      endRow: p.endRow,
      sort: p.sortModel,
      filter: p.filterModel,
    })
      // lastRow -1 = "keep scrolling, more may come"
      .then((r) =>
        p.successCallback(r.rows, r.lastRow ?? -1),
      )
      .catch(() => p.failCallback());
  },
};

const getRowId: GetRowIdFunc<Deal> = ({ data }) =>
  data.dealId;

export function InfiniteDeals() {
  const columnDefs = useMemo<ColDef<Deal>[]>(
    () => [
      { field: 'dealId' },
      {
        field: 'book',
        filter: 'agTextColumnFilter',
        filterParams: { filterOptions: ['equals'] },
      },
      { field: 'tradeDate', sort: 'desc' },
      { field: 'pnl' },
    ],
    [],
  );

  return (
    <div style={{ height: 600 }}>
      <AgGridReact<Deal>
        rowModelType="infinite"
        datasource={datasource}
        cacheBlockSize={100} // rows per request
        maxBlocksInCache={20} // cap memory
        blockLoadDebounceMillis={150} // fast scroll
        getRowId={getRowId} // keeps selection
        columnDefs={columnDefs}
      />
    </div>
  );
}
```

```python
# deals_api.py (sketch)
from typing import Any, Literal

from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel, Field

router = APIRouter()

# Allow-list: grid column ID -> SQL column.
SORTABLE = {
    "dealId": "deal_id",
    "tradeDate": "trade_date",
    "pnl": "pnl",
}
MAX_BLOCK = 500


class SortItem(BaseModel):
    colId: str
    sort: Literal["asc", "desc"]


class DealQuery(BaseModel):
    startRow: int = Field(ge=0)
    endRow: int = Field(gt=0)
    sort: list[SortItem] = []
    filter: dict[str, Any] = {}


@router.post("/api/deals/query")
def query_deals(q: DealQuery, user=Depends(current_user)):
    size = min(q.endRow - q.startRow, MAX_BLOCK)
    order = []
    for s in q.sort:
        if s.colId not in SORTABLE:
            raise HTTPException(400, "bad sort column")
        order.append(f"{SORTABLE[s.colId]} {s.sort}")
    order.append("deal_id asc")  # stable paging
    book = q.filter.get("book", {}).get("filter")
    rows = repo.find_deals(  # entitlement-filtered
        user, book=book, order_by=order,
        offset=q.startRow, limit=size,
    )
    # Short block = we reached the end. This avoids
    # a COUNT(*) query on every scroll.
    last = None
    if len(rows) < size:
        last = q.startRow + len(rows)
    return {"rows": rows, "lastRow": last}
```

- Checked in jsdom with a mocked `fetch`: the first request had `startRow` 0, `endRow` 100, and one sort item for `tradeDate`, `desc`, with `type: 'default'`.
- **The sort item has a `type` field** (v35: `'default'` or `'absolute'`). Pydantic ignores unknown fields by default. If you support absolute sort, use `ABS(col)`.
- **`lastRow`:** `-1` means "unknown, keep scrolling". A number fixes the scrollbar. Returning a total on every block costs a `COUNT(*)`. A short last block tells you the end for free.
- **Settings:** `cacheBlockSize` (default 100), `maxBlocksInCache`, `maxConcurrentDatasourceRequests` (default 2), `blockLoadDebounceMillis`.
- **Refresh** after a save: `api.refreshInfiniteCache()`. A new datasource object resets the grid.
- **Limits:** no grouping, no select-all. Pagination works too (`pagination` + `paginationPageSize`).
- **SQL safety:** sort columns come from the allow-list, and the direction is checked by `Literal`. Filters become parameters, never joined strings.

**Your angle:** The backend half is your home ground: FastAPI, Snowflake, entitlements ([S9](../AI%20Engineer/13-Behavioral-Story-Bank.md#s9)), and the query-cost lessons from [S7](../AI%20Engineer/13-Behavioral-Story-Bank.md#s7). Mention keyset paging for deep scrolls ([05 Q1](05-Frontend-System-Design.md)).
**Likely follow-ups:** "Grouping by book?" (SSRM, Enterprise.) · "Make deep scrolls fast?" (Indexes on the sort columns; keyset paging; a cap on how deep you can go.) · "How do you test it?" (Mock `fetch`; check the body and the rows.)

---

### Q28. Live coding: a custom status renderer and editor  `[P0]`
**Task (~20 min):** "A Status column: show a colored badge. Let users change it with a dropdown. Settled rows are read-only, and users may only choose Open or Confirmed."

**Say this first (~30 sec):** "Two small components. The renderer gets the value typed as `DealStatus` and shows a badge with text. The editor is a controlled select: `value` and `onValueChange` come from the grid, and the allowed list comes from `cellEditorParams`. Validation goes through `useGridCellEditor`. `editable` is a function, so Settled rows can't be edited. In real code I'd try the built-in `agSelectCellEditor` first."

**If they dig deeper:**

```tsx
// StatusCells.tsx
import { useEffect, useRef } from 'react';
import type { ColDef } from 'ag-grid-community';
import {
  useGridCellEditor,
  type CustomCellEditorProps,
  type CustomCellRendererProps,
} from 'ag-grid-react';
import type { Deal, DealStatus } from './types';

const BADGE: Record<DealStatus, string> = {
  Open: 'badge badge-blue',
  Confirmed: 'badge badge-green',
  Settled: 'badge badge-grey',
};

// Renderer: text + color, never color alone.
export function StatusBadge({
  value,
}: CustomCellRendererProps<Deal, DealStatus>) {
  if (value == null) return null;
  return <span className={BADGE[value]}>{value}</span>;
}

// Extra props come from colDef.cellEditorParams.
interface StatusEditorParams {
  allowed: DealStatus[];
}
type EditorProps = StatusEditorParams &
  CustomCellEditorProps<Deal, DealStatus>;

export function StatusEditor({
  value,
  onValueChange,
  allowed,
}: EditorProps) {
  const ref = useRef<HTMLSelectElement>(null);
  useEffect(() => ref.current?.focus(), []);

  useGridCellEditor({
    getValidationErrors: () =>
      value && allowed.includes(value)
        ? null
        : ['Choose a valid status'],
  });

  return (
    <select
      ref={ref}
      value={value ?? ''}
      onChange={(e) =>
        onValueChange(e.target.value as DealStatus)
      }
      onKeyDown={(e) => {
        // Up/Down change the option; don't let the
        // grid move to another cell.
        const k = e.key;
        if (k === 'ArrowUp' || k === 'ArrowDown') {
          e.stopPropagation();
        }
      }}
    >
      {allowed.map((s) => (
        <option key={s} value={s}>
          {s}
        </option>
      ))}
    </select>
  );
}

export const statusCol: ColDef<Deal, DealStatus> = {
  field: 'status',
  cellRenderer: StatusBadge,
  cellEditor: StatusEditor,
  cellEditorParams: {
    allowed: ['Open', 'Confirmed'],
  } satisfies StatusEditorParams,
  editable: ({ data }) => data?.status !== 'Settled',
};
```

- **Arrow keys:** inside the select, Up and Down should change the option, so the editor stops them from reaching the grid.
- **Focus on mount**, so the keyboard works at once.
- **Built-ins:** `agSelectCellEditor` (Community) and `agRichSelectCellEditor` (Enterprise, with search).
- **Test:** render `StatusBadge` and `StatusEditor` alone with Testing Library; check the `onValueChange` calls.
- The server must still refuse edits to Settled deals.

**Your angle:** The read-only rule is a permission rule: the UI hides the action, and the API enforces it ([S9](../AI%20Engineer/13-Behavioral-Story-Bank.md#s9)).
**Likely follow-ups:** "Load the allowed statuses from the API?" (Pass them in through `cellEditorParams`, or use the rich select's async values.) · "Popup editor?" (`cellEditorPopup: true`.)

---

## References
- [npm registry: ag-grid-react latest](https://registry.npmjs.org/ag-grid-react/latest): shows the current version (36.2.0 on Nov 3, 2026).
- [AG Grid: What's New](https://www.ag-grid.com/react-data-grid/whats-new/): release dates and highlights, v33.3 to v36.2.
- [Upgrading to AG Grid 36](https://www.ag-grid.com/react-data-grid/upgrading-to-ag-grid-36/): dev validation, scroll DOM changes, TypeScript 5.8.3.
- [Upgrading to AG Grid 33](https://www.ag-grid.com/react-data-grid/upgrading-to-ag-grid-33/): modules, Theming API, codemods, removed packages.
- [Quick Start](https://www.ag-grid.com/react-data-grid/getting-started/) and [Modules](https://www.ag-grid.com/react-data-grid/modules/): `AgGridProvider`, bundles, `enableDevValidations`.
- [Community vs Enterprise](https://www.ag-grid.com/react-data-grid/community-vs-enterprise/): what needs a licence.
- [React best practices](https://www.ag-grid.com/react-data-grid/react-hooks/): `useState`, `useMemo`, `useCallback` for grid props.
- [TypeScript generics](https://www.ag-grid.com/react-data-grid/typescript-generics/): `TData`, `TValue`, `TContext`.
- [Row IDs](https://www.ag-grid.com/react-data-grid/row-ids/), [updating row data](https://www.ag-grid.com/react-data-grid/data-update-row-data/), [transactions](https://www.ag-grid.com/react-data-grid/data-update-transactions/), [high-frequency updates](https://www.ag-grid.com/react-data-grid/data-update-high-frequency/).
- [Value getters](https://www.ag-grid.com/react-data-grid/value-getters/), [value formatters](https://www.ag-grid.com/react-data-grid/value-formatters/), [value parsers](https://www.ag-grid.com/react-data-grid/value-parsers/), [value setters and read-only edit](https://www.ag-grid.com/react-data-grid/value-setters/).
- [Cell components](https://www.ag-grid.com/react-data-grid/component-cell-renderer/) and [cell editors](https://www.ag-grid.com/react-data-grid/cell-editors/): renderer props, `useGridCellEditor`.
- [Editing validation](https://www.ag-grid.com/react-data-grid/cell-editing-validation/), [full-row editing](https://www.ag-grid.com/react-data-grid/cell-editing-full-row/), [batch editing](https://www.ag-grid.com/react-data-grid/cell-editing-batch/).
- [Filtering](https://www.ag-grid.com/react-data-grid/filtering/), [quick filter](https://www.ag-grid.com/react-data-grid/filter-quick/), [external filter](https://www.ag-grid.com/react-data-grid/filter-external/), [set filter](https://www.ag-grid.com/react-data-grid/filter-set/).
- [Row selection](https://www.ag-grid.com/react-data-grid/row-selection/) and [multi-row selection](https://www.ag-grid.com/react-data-grid/row-selection-multi-row/).
- [Row models](https://www.ag-grid.com/react-data-grid/row-models/), [infinite row model](https://www.ag-grid.com/react-data-grid/infinite-scrolling/), [server-side row model](https://www.ag-grid.com/react-data-grid/server-side-model/), [viewport](https://www.ag-grid.com/react-data-grid/viewport/), [pagination](https://www.ag-grid.com/react-data-grid/row-pagination/).
- [DOM virtualisation](https://www.ag-grid.com/react-data-grid/dom-virtualisation/) and [column sizing](https://www.ag-grid.com/react-data-grid/column-sizing/): row buffer, 500-row cap, auto-size limits.
- [Highlighting changes (flashing cells)](https://www.ag-grid.com/react-data-grid/flashing-cells/).
- [Row grouping](https://www.ag-grid.com/react-data-grid/grouping/), [aggregation](https://www.ag-grid.com/react-data-grid/aggregation/), [pivoting](https://www.ag-grid.com/react-data-grid/pivoting/), [row pinning](https://www.ag-grid.com/react-data-grid/row-pinning/), [status bar](https://www.ag-grid.com/react-data-grid/status-bar/).
- [Cell data types](https://www.ag-grid.com/react-data-grid/cell-data-types/): `date`, `dateTime`, `dateTimeString` formats.
- [CSV export](https://www.ag-grid.com/react-data-grid/csv-export/) (includes the formula-injection warning), [Excel export](https://www.ag-grid.com/react-data-grid/excel-export/), [Excel data types](https://www.ag-grid.com/react-data-grid/excel-export-data-types/).
- [Grid state](https://www.ag-grid.com/react-data-grid/grid-state/) and [column state](https://www.ag-grid.com/react-data-grid/column-state/).
- [Theming](https://www.ag-grid.com/react-data-grid/theming/), [colors and dark mode](https://www.ag-grid.com/react-data-grid/theming-colors/), [cell styles](https://www.ag-grid.com/react-data-grid/cell-styles/), [row styles](https://www.ag-grid.com/react-data-grid/row-styles/).
- [Master/detail](https://www.ag-grid.com/react-data-grid/master-detail/) and [tree data](https://www.ag-grid.com/react-data-grid/tree-data/).
- [Accessibility](https://www.ag-grid.com/react-data-grid/accessibility/) and [keyboard navigation](https://www.ag-grid.com/react-data-grid/keyboard-navigation/).
- [Testing AG Grid](https://www.ag-grid.com/react-data-grid/testing/): test IDs, jsdom limits, Playwright.
- [Integrated charts](https://www.ag-grid.com/react-data-grid/integrated-charts/) and [AG Charts React quick start](https://www.ag-grid.com/charts/react/quick-start/).
- [Grid context](https://www.ag-grid.com/react-data-grid/context/): `setGridOption('context')` + `refreshCells()`.
- [Auto-generate columns (v36)](https://www.ag-grid.com/react-data-grid/auto-generate-columns/).
- [MDN: Intl.DateTimeFormat](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Intl/DateTimeFormat): `timeZone` and `timeZoneName`.
- [OWASP: CSV injection](https://owasp.org/www-community/attacks/CSV_Injection).
- [Story bank: S1, S7, S8, S9, S12, S14, M1](../AI%20Engineer/13-Behavioral-Story-Bank.md).
