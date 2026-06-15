---
name: dradis-design
description: Use this skill for ANY Dradis CE (Community Edition) UI work — building or changing views, forms, index/show pages, cards, empty states, buttons, tables in the dradis-ce codebase, OR creating CE mocks/slides/prototypes. Carries the design judgment the codebase doesn't state: which button/link/card pattern to use and when, voice/casing, glyph vocabulary, plus a pre-flight checklist to prevent design inconsistencies. Use it whenever a non-designer is implementing UI so the result stays on-brand. For Pro-only screens (dashboard, teams, QA workflow, content blocks, remediation tracker, contributors portal) use the dradis-pro-design skill alongside this one.
user-invocable: true
---

Read the `README.md` file within this skill, and explore the other available files.

If creating visual artifacts (slides, mocks, throwaway prototypes, etc), create static HTML files for the user to view. If working on production code, read the rules here to become an expert in designing with this brand.

## ⚠️ Two modes — pick the right one

**Mode A — Throwaway HTML (mocks, slides, prototypes):** import `colors_and_type.css`, use the `var(--token)` names, inline styles are fine. For icons use Font Awesome 6 via CDN (`https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css`). Self-contained and disposable.

**Mode B — Production code in the Dradis repo (the common case):** READ **`production-patterns.md`** FIRST — it is the heart of this skill. It holds the verified decision rules (buttons vs. links vs. destructive actions, cards vs. content-container, page scaffold, forms, tables, empty states), a glyph/voice/casing reference, a **pre-flight checklist**, and an anti-pattern list — all checked against the real source. Then:
- **Canonical markup = the in-repo Hera Style Guide**, `app/views/styles/index.html.erb` (route `/styles`). Copy real markup from its reveal-code blocks; `production-patterns.md` tells you *which* option to pick and when. Never invent markup the style guide already defines.
- DO NOT import `colors_and_type.css` and DO NOT copy hex values. The repo already defines every token in `hera/modules/_colors.scss` and `themes.scss`; this skill's CSS is a *mirror for mocks only*. Use existing SASS vars (`$brand-500`) and custom properties (`var(--text-default)`).
- Follow the repo's `CLAUDE.md` rules: no inline `style`, no ID selectors, no `!important`, `rem` not `px` (px OK for borders), alphabetical sorting, `data-behavior` for JS/CSS hooks, SMACSS file placement.
- `README.md` is supporting reference for tone and "what good looks like" — translate intent into the repo's Bootstrap 5 + Stimulus + ERB conventions.

If the user invokes this skill without any other guidance, ask them what they want to build or design, ask some questions, and act as an expert designer who outputs HTML artifacts _or_ production code, depending on the need.

## Quick orientation
- **`production-patterns.md`** — **READ FIRST for any production/codebase UI work.** Verified decision rules (buttons/links/destructive actions, cards vs. content-container, page scaffold, forms, tables, empty states), glyph/voice/casing reference, pre-flight checklist, anti-patterns.
- **`README.md`** — full brand context: product overview, content fundamentals (voice/tone/casing), visual foundations, and iconography.
- **`colors_and_type.css`** — import this in any HTML artifact. It defines the raw palette, light/dark semantic theme tokens, the Proxima Nova `@font-face` rules, and base element styles. Reference semantic vars (`var(--brand-500)`, `var(--text-default)`, `var(--border-color)`) — never hard-code hex except for user-defined tag/severity colors.

## The essentials (so you don't have to re-derive them)
- **Brand color:** CE primary = green `#1d8749` (brand-500), navbar light-green `#a5cfb6` / text `#11512c`. Pro swaps the ramp green→blue — see the `dradis-pro-design` skill.
- **Type:** Proxima Nova. Body = Light 400 at ~0.95rem; bold/headings = Regular 500. No emoji, ever.
- **Surfaces:** white/grey-100 backgrounds, `1px` borders (borders > shadows), 5px radius on containers, 0.25rem on buttons, 3px on board cards. Flat colors — no gradients, no hero imagery.
- **Icons:** Font Awesome 6. Signature glyphs: `fa-bug` (issues), `fa-brands fa-trello` (methodologies), `fa-sitemap` (nodes), `fa-flag` (evidence), `fa-plus` (new).
- **Voice:** direct, instructional, second-person, confident-not-hypey. Imperative page titles ("Manage your projects"), teaching empty states.
- **Domain nouns:** project (engagement), issue (finding/vuln), evidence, node (target), methodology/board, tag (severity), Issue Library, QA states (Draft → Ready for review → Published).

## CE upsell pattern
CE surfaces locked Pro features as disabled links/buttons with `class="js-try-pro"`, `data-term`, and `data-url`. The `try_pro` JS intercepts clicks and shows an upsell modal. This pattern is CE-only — never use it in dradis-pro.

## Pro
Pro extends CE — the only visual difference is the brand color (green→blue). All CE patterns, components, and voice rules apply to Pro. For Pro-only screens and the brand swap, use the `dradis-pro-design` skill alongside this one.

## When loading assets from HTML
Place your artifact next to `colors_and_type.css` and import it with a relative path. For Font Awesome, use the CDN: `https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css`. For the Proxima Nova font, `colors_and_type.css` includes `@font-face` rules that reference `fonts/proximanova-*.otf` — if those files aren't present, the stack falls back to Montserrat (closest free match) or `system-ui`.
