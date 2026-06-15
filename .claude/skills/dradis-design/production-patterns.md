# Dradis (Hera) — Production UI Patterns

Decision rules for building UI **in the `dradis-ce` codebase**. The repo already
holds the styles and markup; this file holds the **judgment** the codebase
doesn't state — *which* pattern is correct and *when*. Every rule here is verified
against the actual source (file references included).

> **Canonical markup lives in the repo, not here.** Before building any component,
> open the in-repo **Hera Style Guide** — `app/views/styles/index.html.erb` (route:
> `/styles`) — and copy the real markup from its reveal-code blocks. This file tells
> you which option to pick; the style guide tells you the exact tags/classes. Never
> invent markup a component in the style guide already defines.

---

## 0. Editions & white-labeling (CE vs Pro) — color rules

Pro extends CE; the **only design difference is the brand color**. Structure,
components, and every rule below are identical across editions.

- **Never hardcode a brand hex** (green *or* blue). Use `$brand-*` / `var(--brand-*)`
  and the semantic tokens. CE compiles the green ramp; Pro's `_colors.scss`
  `@import 'pro_colors'` swaps `$brand-100`–`900` to blue (`#1570cb` primary), and
  because `themes.scss` references `$brand-*`, the whole UI recolors automatically.
- **White-labeling (Pro):** a customer can override the brand on key chrome via
  `--white-label-bg` / `--white-label-text` (body gets `.white-labeled`). So any
  brand-colored chrome (navbar, primary surfaces) **must** use `.bg-primary` /
  `.white-label-bg` / `.white-label-text` — never a literal brand color — or
  white-labeling silently breaks. Verified against `hera/modules/_white_label.scss`.
- **Edition branching in server code:** use `defined?(Dradis::Pro)` (the existing
  codebase convention).

---

## 1. Page scaffold (index / show pages)

Verified against `app/views/issues/index.html.erb`.

- Wrap each page section in **`<div class="content-container">`** (white surface, grey
  border, radius, uniform padding). This is the **default** page wrapper.
- Page title is **`<h4 class="header-underline">`**, with the page-level action(s) in a
  **`<span class="actions">`** *inside* the heading.
- Breadcrumbs go through `content_for :breadcrumbs` as `<ol class="breadcrumb">`.
- Sidebar (when present) goes through `content_for :sidebar`.
- Page title text via `content_for :title`.
- **Show pages** may lead with a tab bar (`<ul class="tabs-container nav nav-tabs main-tabs">`,
  each tab a `nav-link` with a `fa-*` glyph), then a single `content-container` holding the
  `tab-content`. The dots menu for page-level actions sits as the last `<li>` in the tab bar.
  Verified against `nodes/show.html.erb`.

```erb
<% content_for :title, 'Issues summary' %>
<div class="content-container">
  <h4 class="header-underline">Issues
    <span class="actions pt-1">
      <div class="action"><!-- primary action, see §2 --></div>
    </span>
  </h4>
  <!-- table (§5) or empty state (§6) -->
</div>
```

---

## 2. Buttons vs. links vs. actions (the #1 drift source)

The split is **by context, not by "navigate vs. act."** Verified against
`issues/_table.html.erb`, `issues/_actions.erb`, `issues/index.html.erb`,
`hera/modules/_buttons.scss`.

**A. Form & emphasis actions → real buttons.**
- `btn btn-primary` for the single main action of a form/view (submit, save).
- `btn btn-secondary` / `btn btn-outline-*` for lower emphasis.
- `btn btn-danger` **only** for a destructive action presented as a button (rare; the
  usual destructive affordance is a link — see D).
- **One `btn-primary` per view.** Sentence case, verb-first label ("Save changes").

**B. Page-header "New {Record}" action → an anchor, not a button.**
On index pages the primary "New X" is a **`link_to` anchor** with a `fa-plus` icon,
placed in the header `.actions` span — frequently a templates dropdown. It is **not**
a `btn-primary`.
```erb
<span class="actions pt-1">
  <div class="action">
    <div class="dropdown">
      <%= link_to 'javascript:void(0)', class: 'dropdown-toggle', data: { bs_toggle: 'dropdown' } do %>
        <i class="fa-solid fa-plus me-1"></i>New Issue
      <% end %>
      <!-- templates dropdown -->
    </div>
  </div>
</span>
```

**C. Row / table-cell / dots-menu item actions → anchors with icon + label.**
Edit, View History, Send to, etc. are **`link_to` anchors**, each with a `fa-* fa-fw`
icon and a label — **not** buttons.
```erb
<%= link_to edit_project_issue_path(current_project, issue) do %>
  <i class="fa-solid fa-pencil"></i> Edit
<% end %>
```

**D. Destructive actions → styled as error text (`text-error-hover`), never a button.**
The **invariant**: destructive actions use `class: 'text-error-hover'` (or
`'dropdown-item text-error-hover'` in a menu), a `fa-trash` icon, and the label
"Delete" — and are **never** `button_to` or `<button>`. There are **two sanctioned
mechanisms**, pick by how much confirmation the action needs:

*D1 — Inline confirm link* (Issues, Evidence). A `method: :delete` anchor with a
`data-confirm` that **spells out the consequence**:
```erb
<%= link_to [current_project, issue],
    method: :delete,
    data: { confirm: "Are you sure?\n\nProceeding will delete this issue and any associated evidence." },
    class: 'text-error-hover' do %>
  <i class="fa-solid fa-trash"></i> Delete
<% end %>
```

*D2 — Modal trigger* (Nodes). When the delete needs a richer confirmation dialog,
the trigger opens a modal instead:
```erb
<a href="#modal_delete_node" class="dropdown-item text-error-hover" tabindex="-1" data-bs-toggle="modal">
  <i class="fa-solid fa-trash fa-fw"></i> Delete
</a>
```

Verified against `issues/_table.html.erb`, `issues/_actions.erb`,
`evidence/_actions.html.erb` (D1) and `nodes/show.html.erb` (D2).

**D-modals. Non-destructive menu actions that open a modal** (Add subnode, Rename,
Move, Merge) follow the same trigger shape — an anchor with `data-bs-toggle="modal"`,
a `fa-* fa-fw` icon, and a label — just without `text-error-hover`:
```erb
<a href="#modal_rename_node" class="dropdown-item" tabindex="-1" data-bs-toggle="modal">
  <i class="fa-solid fa-pencil fa-fw"></i> Rename
</a>
```

**E. `btn-link` (button that looks like a plain text link).**
Defined in `_buttons.scss` but **currently unused** in the app. Treat as a rare,
sanctioned exception. **Never** hand-roll a link-looking button with ad-hoc CSS or
utility classes — if you truly need one, use `.btn.btn-link` and nothing else.

---

## 3. Cards vs. content-container

Verified against `app/views/styles/index.html.erb` (Cards & Content Container).

- **`content-container`** = the default wrapper for **each section of a page**. Use it
  unless the content is specifically a set of like items. Optional `header-underline` heading.
- **`card`** = **multiple items of the same category** (e.g. the three "add issues"
  methods). Variations: `card-header bg-primary` (emphasis) or `bg-default`; or a
  header-less card. Separate in-card actions with an `<hr>`.
- **Decision:** repeated peers of one category → cards. Anything else → content-container.
- **Don't** nest `content-container`s inside cards, and don't use a card as a one-off
  page section.

---

## 4. Forms

Verified against `app/views/styles/index.html.erb` (Form Elements) and `issues/_form.html.erb`.

- Field group: `<div class="mb-3">` wrapping `<label class="form-label">` + control.
- Controls: `form-control` (text/textarea), `form-select` (selects; combobox via
  `data-combobox-config`).
- Validation states: `is-valid` / `is-invalid` on the control.
- Submit: `btn btn-primary` (one per form). `disabled` for disabled inputs.
- Labels are sentence case.

---

## 5. Tables (index data)

Verified against `issues/_table.html.erb`.

- `tag.table class: 'table table-striped mb-0'` with `data-behavior="dradis-datatable"`.
- First column = `select-checkbox`; last column = `column-actions` holding the row's
  Edit (anchor) + Delete (delete-link, §2D).
- Hidden utility columns use `data-column-visible="false"`.
- Select via `data` attributes (`data-behavior`), never classes/IDs (repo JS convention).

---

## 6. Empty states

Verified against `app/views/styles/index.html.erb` (Empty States), `issues/index.html.erb`,
`issues/_empty_state_actions.html.erb`.

- Render the shared partial: `render 'shared/empty_state', name:, docs_link:, text:, actions_partial:`.
- Anatomy: SVG icon (`empty-state-icon`) → title **"You don't have any {record} yet"** →
  one-line `{record}` description → optional CTA / `empty-state-docs-link` ("More about {record}").
- The `text:` teaches what the record is *for* (instructional voice), it doesn't just say "no data".
- Multi-method empty states (like Issues) use a row of `card add-issues` cards, one per method.

---

## 7. Voice, casing, glyphs

- **Voice:** direct, instructional, second-person, confident-not-hypey. Page/section
  titles are imperative or plain nouns ("Issues", "Manage your projects"). Empty states teach.
- **Casing:** sentence case for buttons, labels, menu items, titles. Not Title Case, not ALL CAPS.
- **No emoji** in product UI.
- **Glyphs (Font Awesome 6):** `fa-bug` = issues, `fa-brands fa-trello` = methodologies,
  `fa-sitemap` = nodes, `fa-flag` = evidence, `fa-plus` = new, `fa-pencil` = edit,
  `fa-trash` = delete, `fa-history` = history, `fa-ellipsis-h` = dots menu. Use `fa-fw`
  for fixed-width alignment in menus.
- **Domain nouns:** project (engagement), issue (finding/vuln), evidence (uncountable —
  never "evidences"), node (target), methodology/board, tag (severity), Issue Library,
  QA states (Draft → Ready for review → Published).

---

## 8. Pre-flight checklist (run before finishing any UI change)

Self-check these — they catch the drift that actually happens:

1. **Markup copied from the Hera Style Guide** (`/styles`), not invented?
2. **One `btn-primary`** in the view, and is it the genuine main action?
3. **Right action affordance for context** — form action = button; page-header "New X" =
   header anchor; row/menu actions = `link_to` anchors with icon+label?
4. **Destructive action** = `text-error-hover` + `fa-trash` + "Delete", via either a
   `method: :delete` confirm-link or a modal trigger — never `button_to`/`<button>`?
5. **Container choice correct** — `content-container` for a page section, `card` only for
   repeated like items?
6. **Styling via existing SASS vars / classes** — no inline `style`, no ID selectors, no
   ad-hoc hex (no literal brand green/blue — use `$brand-*`), no `!important`, and
   brand-colored chrome uses `.bg-primary`/`.white-label-*` so white-labeling survives?
7. **Copy** in sentence case, instructional voice, correct domain nouns, no emoji?
8. **JS/CSS hooks via `data-behavior`**, not classes or IDs?

---

## 9. Anti-patterns (don't)

- ❌ A bare `<button>`/`<a>` styled to look like a text link via custom CSS (use `btn-link` if ever needed).
- ❌ `btn-primary` on more than one action in a view.
- ❌ A `btn-primary` for the index-page "New X" action (it's a header anchor).
- ❌ `button_to` / `<button>` for Delete (the convention is a `text-error-hover` `method: :delete` link **or** a modal trigger).
- ❌ A `card` used as a generic one-off page section (use `content-container`).
- ❌ Title Case or ALL CAPS labels; emoji in UI; "evidences".
- ❌ Hardcoded hex (except user-defined tag/severity colors) or inline styles. A literal
  brand green/blue is always wrong — use `$brand-*`; it breaks the other edition and white-labeling.
- ❌ Selecting elements by class/ID in JS instead of `data-behavior`.
