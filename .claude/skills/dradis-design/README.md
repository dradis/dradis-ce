# Dradis Design System

A design system for **Dradis Framework — Community Edition (CE)**, the open-source
collaboration framework and penetration-testing report generator built by
[Security Roots](https://securityroots.com). This system captures the brand,
visual foundations, and UI vocabulary of the Dradis product so designers and
agents can produce on-brand interfaces, mockups, and prototypes.

> The Dradis product theme is internally named **"Hera."** Most class names,
> color scales, and component conventions in this system trace directly to the
> `hera` stylesheet tree in the codebase.

---

## What is Dradis?

Dradis is an **open-source collaboration framework and penetration testing
report generator** that helps InfoSec teams streamline reporting workflows. It
imports data from security tools (Burp Suite, Nessus, Nmap, OpenVAS, Qualys,
Metasploit, and many more), centralizes findings, and automates the tedious
parts of security report writing so testers can focus on analysis and
recommendations.

**Core value proposition:** *Generate consistent, professional pentest reports
faster — with less manual work.*

### Editions
- **Community Edition (CE)** — open-source, GPLv2. Single-project, self-hosted.
  This design system is built from CE.
- **Professional Edition (Pro)** — commercial. Adds multi-project management,
  teams, report automation, content blocks, QA workflows, and client
  collaboration. CE surfaces tasteful "Try Pro" upsells throughout.

### Core domain vocabulary
Designers should know these product nouns — they appear all over the UI:
- **Project** — a single security assessment / engagement.
- **Issue** — a vulnerability or finding (Title, Description, Recommendation,
  CVEs, etc.). Issues are what end up in the report.
- **Evidence** — proof attached to an issue, tied to a node.
- **Node** — a target in scope (host, IP, app component). Shown in a tree sidebar.
- **Methodology / Board** — a Kanban-style checklist of testing tasks (lists + cards).
- **Tag** — colored classification on issues (often severity: Critical/High/etc.).
- **Issue Library** — reusable catalog of findings for consistency across projects.
- **Remediation Tracker** — tickets for tracking fixes.
- **QA** — quality-assurance review state for issues (Draft → Ready for review → Published).

---

## Sources

This system was reverse-engineered from the **dradis-ce** codebase (Ruby on
Rails + Bootstrap 5 + Stimulus/Turbo). Key source locations (paths within the
attached `dradis-ce/` repo):

| Concern | Source |
|---|---|
| Color palette (source of truth) | `app/assets/stylesheets/hera/modules/_colors.scss` |
| Theme tokens (light/dark) | `app/assets/stylesheets/hera/themes.scss` |
| Base element styles + fonts | `app/assets/stylesheets/hera/base.scss` |
| Variables (spacing, sizing) | `app/assets/stylesheets/hera/variables.scss` |
| Buttons | `app/assets/stylesheets/hera/modules/_buttons.scss` |
| Navigation (main + sub nav) | `app/assets/stylesheets/hera/modules/navigation/_navigation.scss` |
| Sidebar | `app/assets/stylesheets/hera/modules/_sidebar.scss` |
| Boards / Kanban | `app/assets/stylesheets/hera/views/boards.scss` |
| Layout shell | `app/views/layouts/hera.html.erb` |
| Logos & fonts | `app/assets/images/`, `app/assets/fonts/` |

- **Public site:** https://dradis.com
- **GitHub:** https://github.com/dradis/dradis-ce
- **Icons:** Font Awesome 6.4.0 Free (via `font-awesome-sass` gem)
- **Type:** Proxima Nova (Light + Regular) — `.otf` files copied into `fonts/`

---

## CONTENT FUNDAMENTALS

How Dradis writes copy. The voice is that of a **practical, no-nonsense tool
made by security people for security people** — competent, direct, lightly
encouraging, never marketing-fluffy inside the product.

**Voice & tone**
- **Direct and instructional.** Copy explains what a thing is *for*, then how to
  use it. Empty states teach: *"Use issues to represent vulnerabilities or
  findings. Issues contain general information, such as: Title, Description,
  Recommendation, CVE's, etc."*
- **Second person.** Addresses the user as "you/your": *"Centralize security
  assessments and keep up with the progress of each engagement,"* *"Maintain a
  library of findings that can be easily accessed."*
- **Action-oriented page titles.** Big H1s are imperatives: *"Manage your
  projects," "Build Your Issue Library."* A supporting H2 expands on the benefit.
- **Confident, not hypey.** No exclamation marks, no superlatives in-product.
  Benefit statements are concrete ("less manual work", "consistency across all
  of your projects") rather than aspirational.

**Casing**
- **Page H1s:** mostly sentence case (*"Manage your projects"*), occasionally
  title case (*"Build Your Issue Library"*). Lean sentence case for new copy.
- **Buttons & nav:** Title Case for primary actions (*"New Issue," "New
  Project," "Add a list…"*), often prefixed with a `+` icon.
- **Section headers** (`.header-underline`): Sentence case (*"Issues so far,"
  "Methodology progress," "Recent activity"*).
- **Table column heads:** Title Case (*Name, Issues, Evidence, Nodes, Affected*).

**Mechanics**
- **Ellipses for affordances:** "Add a task…", "Add a list…", "Choose any user
  name you want".
- **Pluralize honestly:** "1 Issue" / "3 Issues" (the app uses `pluralize`).
- **Confirmations are blunt and explain consequences:** *"Are you sure?
  Proceeding will delete this issue and any associated evidence."*
- **Pro upsells** are framed as helpful tooltips, not nags: *"Dradis Pro: Track
  project status to manage your team's workload at a glance."*

**Emoji:** **None.** Never used in product. Iconography is carried entirely by
Font Awesome glyphs. Don't introduce emoji.

---

## VISUAL FOUNDATIONS

Dradis CE is a **dense, utilitarian, Bootstrap-5 application UI** — built for
information density and long working sessions, not marketing flourish. The
aesthetic is clean, bordered, and green-forward.

**Color**
- **Brand green is the identity.** `--brand-500 #1d8749` is *primary*: primary
  buttons, links, active states, the logo. A full 50→900 brand scale exists.
- **The navbar is the most recognizable brand surface:** a soft light-green bar
  (`--brand-200 #a5cfb6`) with dark-green text (`--brand-700 #11512c`) and a
  `--brand-400` bottom border. Active items get a 5px brand-700 top border.
- **Semantic colors** map to security/QA meaning: red `#cc293b` (danger/delete),
  mint green `#85d783` (success), yellow `#e1cd30` (warning), orange `#cc6829`
  (severity accents). Each has a 100→900 scale.
- **Lavender** (`#8261d5`) is a special accent — teams, Pro badges, the secondary
  brand pop.
- **Greys** are warm-neutral (`#f4f4f4`→`#282828`). Backgrounds are white/near-white;
  secondary surfaces use `--grey-100`.
- **Tags drive issue color:** issue severity cards are tinted by user-defined tag
  colors (inline `style="background: <tag.color>"`), so the issue list is a
  rainbow of severity bands.

**Theming**
- **Full light + dark themes**, switched via `data-theme` on `<html>` and driven
  entirely by CSS custom properties (`--primary-bg`, `--text-default`,
  `--border-color`, …). Auto-follows OS via `prefers-color-scheme`. Any new
  component should reference semantic vars, never hard-coded hex, so it themes
  for free.

**Type**
- **Proxima Nova** throughout. `ProximaNovaLight` (400) is the body face;
  `ProximaNovaRegular` (500) is used for **bold text, headings, form labels,
  table headers, and `<strong>`**. There is no third weight — "bold" = swap to
  Regular.
- Body size `0.95rem`. Headings scale h1 `2rem` → h6 `1rem` (slightly smaller
  below 1200px). Headings are tight (`line-height 1.2`), understated, rarely huge.
- Monospace only for code blocks (`<pre>`, `<code>`), which get a brand-100 chip
  background and brand-colored text.

**Spacing & layout**
- Base spacing unit is **`1.5rem`** (`--margin` / `--padding`).
- App shell is a CSS grid: sticky top nav (one or two rows), optional left
  **node sidebar** (14rem), main content, optional right **secondary sidebar**
  (~17.5rem). Sidebars collapse to a 0.25rem rail.
- Content lives in **`.content-container`** cards: white bg, `1px` border,
  **5px radius**, `1.5rem` padding.

**Borders, radii & shadows**
- **Borders do the heavy lifting**, not shadows. Almost every surface is defined
  by a `1px solid var(--border-color)` (light grey). This is a *bordered*,
  low-elevation design.
- **Radii:** `5px` for content containers/cards, `0.25rem` for buttons & badges,
  `3px` for Kanban board lists/cards. Pills (`50rem`) only for circular avatars.
- **Shadows are minimal.** A soft `1px 1px 5px rgba(grey,0.5)` on dropdowns; a
  pronounced `0 20px 30px rgba(33,55,74,0.2)` *only* on actively-dragged Kanban
  cards. No ambient drop shadows on resting cards.
- **Focus ring:** `0 0 0 0.2rem rgba(brand,0.5)` — a green glow on focus-visible.

**Backgrounds**
- **Flat color only.** No gradients, no hero photography, no textures or
  patterns in the app UI. Surfaces are white, grey-100, or brand-tinted.
- The footer is a thin `--brand-100` strip with a `--brand-300` top border.

**Motion & states**
- **Subtle, fast, functional.** Standard transition is `color/background 0.2s
  ease-in-out`. No bounces, no large entrance animations, no parallax.
- **Hover:** links go darker (`--text-link-hover`); buttons darken their fill
  ~10% (`darken($color, 10%)`); list rows tint to `--primary-bg-subtle`; row
  action icons fade in from `opacity: 0.25`.
- **Press/active:** same darkened fill as hover (no shrink/scale transforms).
- **Drag:** Kanban cards lift with the heavy shadow and `cursor: grabbing`.

**Avatars & imagery**
- User avatars are **circular** (Gravatar-style, `border-radius: 50%`), shown in
  overlapping stacks with a "+N" overflow chip. The default `avatar.png` is a
  flat grey silhouette. There is essentially no decorative photography.

---

## ICONOGRAPHY

- **Primary system: Font Awesome 6.4.0 Free.** This is *the* icon language of
  Dradis. Used pervasively via `<i class="fa-solid …">`, `fa-regular`, and
  `fa-brands`. It is **self-hosted** at `assets/fa/all.min.css` (with webfonts in
  `assets/fa/webfonts/`) — the exact same family and version the product ships,
  so artifacts render offline. Link it relatively (e.g. `assets/fa/all.min.css`).
- **Common glyphs** (memorize these — they ARE the product's visual shorthand):
  - `fa-bug` — Issues / findings (the signature Dradis icon)
  - `fa-brands fa-trello` — Methodologies / boards
  - `fa-sitemap` — Nodes
  - `fa-flag` — Evidence
  - `fa-cloud-arrow-up` — Upload
  - `fa-file-export` — Export
  - `fa-regular fa-handshake` — QA
  - `fa-regular fa-folder-open` — Project overview
  - `fa-plus` — New / create (prefixes most primary buttons)
  - `fa-pencil` / `fa-trash` / `fa-copy` / `fa-box-archive` — row actions
  - `fa-check` (green) / `fa-times` (red) / `fa-triangle-exclamation` (yellow) — status
  - `fa-bars`, `fa-chevron-up`, `fa-caret-up`, `fa-grip-vertical` — chrome/controls
- **Icon coloring:** icons inherit text color by default; semantic icons are
  tinted (`fa-check` green, `fa-times` red, `fa-info-circle` brand). Issue icons
  take their tag's color inline.
- **Brand logos** (in `assets/`):
  - `logo_small.png` — the standalone "A" mark (interlocking green ribbons +
    dark band). Used in the navbar.
  - `logo_full_small.png` — full lockup: the mark + "Dradis" wordmark + "CE".
  - The mark reads as a stylized **"A"** built from folded green ribbons with a
    charcoal band woven through it.
- **No emoji. No custom SVG icon set.** A few tiny legacy "silk" PNG icons
  (`accept/pencil/stop`) exist for inline table-edit states but are vestigial —
  prefer Font Awesome equivalents.

---

## Index / Manifest

Root files:
- **`README.md`** — this file. Brand context, content + visual foundations, iconography.
- **`colors_and_type.css`** — the complete token layer: raw palette, semantic
  light/dark theme tokens, font-faces, and base element styles. **Import this
  first** in any artifact.
- **`SKILL.md`** — Agent-Skill manifest for using this system in Claude Code.
- **`fonts/`** — Proxima Nova `.otf` files (Light, Regular).
- **`assets/`** — logos, favicon, default avatar, loading spinner, check mark,
  and self-hosted **Font Awesome 6.4** (`assets/fa/`).
- **`preview/`** — design-system specimen cards (rendered in the Design System tab).

UI kits:
- **`ui_kits/dradis-app/`** — the Dradis CE web application: shell (nav + sidebar),
  Projects index, Project Overview dashboard, Issues table, Issue detail, and
  the Methodologies Kanban board, plus reusable buttons, badges, cards, forms,
  and a login screen. `index.html` is an interactive click-through.

---

## Caveats / Substitutions
- **Fonts:** Proxima Nova ships as `.otf` in the repo and is copied into
  `fonts/`. It is a commercial typeface; if you need a Google-Fonts fallback for
  portability, the closest free match is **Montserrat** (or system-ui).
- **Icons** are self-hosted Font Awesome 6.4 (same version as the gem), in `assets/fa/`.
- This system is derived from **CE**; Pro-only screens (multi-project dashboard,
  content blocks, full QA workflow) are represented only where CE exposes them
  as teasers.
