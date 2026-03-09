# CLAUDE.md — Dradis Framework

## Project overview

Dradis Community Edition (CE) is a Ruby on Rails application for collaborative security assessment reporting.

- **Rails 8.0**, Ruby 3.4, SQLite3, Importmaps (no Webpack)
- **Authentication:** Warden (custom strategies, not Devise). Default scope only — never pass `scope: :user`.
- **Authorization:** CanCanCan 3.0 with role-based bit mask (`:admin`, `:author`, `:contributor`, `:disabled`)
- **Jobs:** Resque (queue adapter) + SolidQueue (recurring/scheduled via `config/recurring.yml`)
- **Frontend:** Bootstrap 5, Stimulus 3, Turbo (Drive is disabled, but Frames and Streams are used), jQuery 3, Font Awesome 6 Free


## Common commands

```bash
# Run full test suite
bundle exec rspec

# Run a single spec file
bundle exec rspec spec/path/to/spec.rb

# Run engine specs
bundle exec rspec engines/<engine-name>/spec/

# Lint changed files only (CI style — compares against target branch)
bin/rubocop-ci origin/develop false

# Database
bin/rails db:prepare
bin/rails db:migrate

# Dev server (port 3000)
bin/dev
```

You can restart with `touch tmp/restart.txt`


## Project structure

```
app/                        # Main Rails app
  controllers/concerns/     # Authentication, EventPublisher, ProjectScoped, etc.
  models/concerns/          # Eventable, Archivable, HasFields, etc.
  services/                 # ActivityService, ProjectCloneService, etc.
  jobs/                     # ApplicationJob subclasses
  presenters/               # View presenters
  drops/                    # Liquid template drops
engines/
  dradis-api/               # CE API engine (in-project resource)
  ...
config/
  initializers/warden_*.rb  # Warden strategies (numbered for load order)
  recurring.yml             # SolidQueue scheduled jobs
spec/
  support/                  # Test helpers, macros, shared contexts
  factories/                # FactoryBot factories
  features/                 # Capybara feature specs (Selenium + Firefox headless)
```

### Controller hierarchy

```
ApplicationController                          # includes Authentication, Turbo::Redirection
  protect_from_forgery with: :exception
  └── SetupRequiredController
      └── AuthenticatedController              # before_action :login_required
          └── Admin::AdminController           # before_action :admin_required
          └── [most app controllers]
          └── Engine controllers (e.g. Dradis::CE::API::V1::IssuesController)
```

### Controller concerns

- `ProjectScoped` — sets `current_project` from URL; required for most project-scoped controllers
- `EventPublisher` — provides `publish_event(name, payload)` for activity tracking
- `Mentioned` — enables @mention detection (pairs with `Notified`)
- `Notified` — provides `broadcast_notifications(action:, notifiable:, user:)` for in-app notifications
- `LiquidEnabledResource` — enables Liquid template preview for resources with text content

### Nested resource controllers

We try to adhere to a RESTful convention. Try to identify "hidden" sub-resources. For instance, instead of:

```
resources :inline_threads do
  member do
    post :resolve
    post :reopen
  end
end
```

We can extract the `Resolution` resource (not a DB-backed model) and have a more RESTful approach:

- controllers/qa/inline_threads/resolutions_controller.rb # QA::InlineThreads::ResolutionsController

Routes use the `controller:` option to map to the namespaced controller:

```ruby
resources :inline_threads do
  resource :resolution, only: [:create, :destroy], controller: 'inline_threads/resolutions'
end
```


## Key patterns

**Event publishing:** Controllers `include EventPublisher` and call `publish_event('namespace.action', ...)`. Models `include Eventable`. Events route through `ActiveSupport::Notifications` and `ActivityService.subscribe_namespace`.

Event name convention: `'issue.created'`, `'comment.destroyed'`, `'inline_thread.resolved'`.

> **Deprecated:** `ActivityTracking` (`track_created`, `track_destroyed`, `track_activity`,
> `track_state_change`) — do not use in new code. Use `EventPublisher` + `publish_event` instead.

**Engine registration:** Each engine inherits from `Dradis::Plugins::Base`, provides `:addon`, and registers Warden strategies / controller extensions in initializers.

**API authentication chain:** Warden strategies are tried in order. For scoped API keys: `:api_key_auth` checks `dradis_{prefix}_{secret}` tokens first, then `:api_token` falls back to legacy Bearer/Basic auth.


## Dradis field syntax

Notes and Issues store content with field markers: `#[FieldName]#`. A typical `notes.text` looks like:

    #[Title]#
    SQL Injection in Login

    #[Description]#
    The application is vulnerable to...

`FieldParser` extracts these into key/value pairs. The rendered HTML strips the `#[...]#` markers
entirely — field names appear as headings or bold text, values as body text. This means:

- Raw text positions ≠ rendered DOM positions (markers add characters not visible in HTML)
- User text selections in the browser will never include `#[` or `]#`
- Any code that maps between raw text and rendered HTML must account for this offset


## Code style

RuboCop is configured with `DisabledByDefault: true` — only explicitly enabled cops apply. Key rules:

- **Single-quoted strings** unless interpolation is needed
- **2-space indentation**, no tabs
- **No shorthand hash syntax** (`EnforcedShorthandSyntax: never`) — use `{ name: name }` not `{ name: }`
- **Spaces** around operators, after commas/colons, around `=` in default params, before block braces, inside block braces (no space), inside hash literals (space)
- **`&&`/`||`** over `and`/`or`
- **Empty lines** around class/module/method bodies: none allowed
- Excluded from linting: `**/templates/**/*`, `**/vendor/**/*`, `db/schema.rb`
- **Alphabetical order within sections** — `include` statements, method definitions, SCSS `@import` directives, and similar declarations are sorted alphabetically within their logical section. In models, sections are defined using comments (e.g. Relationships, Callbacks, Validations, Instance Methods (public then private)). Only sort within a section, not across sections.

### Custom inflections (important for Zeitwerk)

Defined in `config/initializers/inflections.rb`:

- `evidence` is **uncountable** (never `evidences`)
- Acronyms: `IP`, `IPs`, `JSON`, `OS`, `OSs`, `QA`, `RTP`

**Zeitwerk naming consequence:** Rails treats `API` as an implicit acronym. Files under `api_keys/` expect class names like `APIKey`, `APIKeysController`, `APIToken` — **not** `ApiKey`, `ApiKeysController`, `ApiToken`.


## HTML/ERB conventions

- **Always use Rails helpers** — never raw HTML tags for assets or links:
  - `<%= image_tag 'image.png' %>` not `<img src="/assets/image.png">`
  - `<%= link_to 'Label', some_path %>` not `<a href="/some-path/">`
- **DOM IDs must be unique.** Take extra care in loops and partials loaded repeatedly via AJAX — use the record ID or another unique value to scope them (e.g. `dom_id(record)`).


## CSS/SASS conventions

### File organization

Stylesheets live under `app/assets/stylesheets/<layout>/` (e.g. `tylium/`), following a modified SMACSS structure:

```
tylium/
├── smacss/
│   ├── base/        # default element styles (html, body, a, h2, buttons, etc.)
│   ├── layout/      # page-section styles (main, footer, etc.)
│   ├── modules/     # one file per reusable component (navbar, sidebar, forms, alerts, etc.)
│   └── variables.scss  # SASS variables for colors, spacing, fonts
├── vendor/          # third-party CSS (Bootstrap, etc.) — no new additions without team approval
└── theme.scss       # manifest — imports all other stylesheets
```

Stylesheets shared across multiple layouts go in `app/assets/stylesheets/shared/`.

### Rules

- **Use SASS variables** for colors, spacing, and fonts — reference `smacss/variables.scss`, never hardcode values.
- **No ID selectors** — they add unnecessary specificity. Use classes.
- **No inline `style` attributes** on HTML elements.
- **Avoid `!important`** — revisit the CSS specificity instead.
- **Use relative units** (`rem`, `em`, `ch`, etc.) — avoid `px`.
- **Sort selectors alphabetically** within a file (where it doesn't break the cascade).
- **Sort declarations alphabetically** within each rule block.
- **Use SASS asset helpers**, not plain `url()`:
  - `background: image-url('image.png')` not `background: url(/assets/image.png)`
  - `src: font-url('Font.ttf')` not `src: url('Font.ttf')`


## JavaScript conventions

### File organization

JS lives under `app/assets/javascripts/<layout>/` (e.g. `hera/`):

```
hera/
├── pages/      # page-specific scripts — guarded at page level
├── modules/    # reusable component scripts — guarded at component level
├── vendor/     # third-party libraries (no new additions without team approval)
├── behaviors.js        # shared functionality used across multiple views in this layout
└── hera.js             # sprockets manifest — explicitly requires all scripts (no require_tree)
```

Scripts shared across multiple layouts (Hera, Application, Setup, etc.) go in `app/assets/javascripts/shared/`.

New scripts must be explicitly added to the layout manifest (`//= require hera/pages/my_script`). Never use inline `<script>` tags in views.

### Language

- Write **vanilla JS**, optionally using jQuery. Always use **ES6+ syntax** (arrow functions, `const`/`let`, template literals, destructuring, etc.).
- Never use CoffeeScript for new code.
- To convert existing CoffeeScript: submit a standalone PR (CoffeeScript → vanilla JS only, no feature changes), merge to `develop`, then branch off for your feature.
- **Do not add new JS dependencies** without a team discussion. If needed, make a case first.
- Prefer **Stimulus controllers** over plain JS modules when the behaviour is tied to DOM elements or component lifecycle (connect/disconnect). Use a plain module only for stateless utilities or logic not tied to a specific element.

### Element selection

Always select elements via `data` attributes. Never use CSS classes, IDs, or element type selectors as JS hooks.

```js
// ✅
document.querySelector('[data-behavior~=my-action]')
// ❌
document.querySelector('.my-class')
document.querySelector('#my-id')
document.querySelector('button')
```

If you encounter class/ID selectors in existing code, refactor them to `data-behavior`.

### Event handling

Never use inline event handlers. Always use `addEventListener`.

```js
// ✅
element.addEventListener('click', handleClick);
// ❌ <button onclick="handleClick()">
```

### Turbo and initialization

Always use `turbo:load` — never `DOMContentLoaded`, `window.onload`, or `$(document).ready()`.

**Page-level guard** (scripts in `pages/` — run only on the intended page):

```js
document.addEventListener('turbo:load', function () {
  if ($('body.controller-name.action-name').length) {
    // page-specific code
  }
});
```

Body classes come from `controller_path.gsub('/', '-')` and `action_name` (see `HeraHelper#body_css`).

**Component-level guard** (scripts in `modules/` — run whenever the component is present):

```js
document.addEventListener('turbo:load', function () {
  if ($('[data-behavior~=my-component]').length) {
    // component code
  }
});
```


## Testing conventions

- **RSpec 7** with FactoryBot, Shoulda Matchers, DatabaseCleaner
- **Feature specs:** Selenium with Firefox headless (`Capybara.javascript_driver = :firefox`)
- **CSRF is disabled** in test env (`allow_forgery_protection = false`) — no CSRF meta tag is rendered
- **Warden test helpers:**
  - Feature specs: `include Warden::Test::Helpers` → `login_as(user)` (no scope arg!) + `Warden.test_reset!`
  - Controller specs: `sign_in(user)` from `spec/support/controller_helpers.rb` (mocks `request.env['warden']`)
  - Request specs: `include Warden::Test::Helpers` → `login_as(user)` (same as feature specs)
- **Controller macros:** `login_as_user` in `spec/support/controller_macros.rb` mocks `authenticated?` and `current_user`
- **DataTables in feature specs:** Action columns often use `data-column-visible="false"`. Use `visible: :all` to find hidden links, or `execute_script` to submit forms directly.


## Git workflow

### Branches

- `main` — current release. `develop` — next release. All work branches off `develop`.
- Delete branches after they are merged.
- Branch naming: `entity/imperative-verb-description`

| Type | Branches from | Merges into | Example |
|------|--------------|-------------|---------|
| Task | `develop` | `develop` | `notifications/confirm-access-before-notifying` |
| Feature | `develop` | `develop` | `qa/add-qa` |
| Feature task (isolated) | feature branch | feature branch | `qa/add-inline-comments` |
| Feature task (dependent) | previous task branch | previous task branch | `qa/add-issues-show` → `qa/add-issues-index` → `qa/add-issues` (base) → feature |
| Release | `develop` | `main` | `release/v4.19.0` |
| Hotfix | `main` | `main` | `hotfix/fix-login-redirect` |

### Commits

- Keep commits small and focused on a single logical change. Avoid unrelated changes in the same commit.
- **Before committing:** run `bin/rubocop-ci develop false`. Do not commit if it fails.
- Commit message format: `imperative-verb description` — max 80 characters.
- Describe the **why**, not the what. The code shows what changed; the message should explain the reason.
  - ❌ `add text-wrap class to card`
  - ✅ `prevent card content from overflowing parent`
- Do not add `Co-Authored-By` lines to commit messages.

### Pull requests

- PR title follows the same format as commit messages.
- Fill in the PR description using the template at `.github/pull_request_template.md`.
- Feature branch PRs should have a Summary describing the full feature, not just the last commit.
- CI must be green before merging. If `develop` CI is red, investigate before merging.

### Other

- `db/schema.rb` hygiene: only commit schema changes from your own migrations.
- **Migrations:** use `t.references` (not `t.integer` or `t.bigint`) for FK columns — generates the correct type and adds the index automatically.
- CI runs: bundler-audit, ruby-audit, brakeman, rubocop (changed files), rspec (4 parallel nodes).


## Changelogs

Two changelogs, both follow the template in `CHANGELOG.template`:

- **`CHANGELOG`** — CE (Community Edition) changes. Features that land in CE first are recorded here.
- **`CHANGELOG.pro`** — Pro-only changes. If a CE change also applies to Pro, it gets migrated here too.

Entries are grouped under the relevant section heading from the template (e.g. `REST/JSON API enhancements`, `Bugs Fixed`, `Reporting enhancements`). Keep entries to a single line. Do not create a new version header — add to the existing `[v#.#.#]` block at the top.

**Entry format:** `Module/Entity: description` — always lead with the module, tool, or entity, followed by a colon and the description.

**Feature entries:** description starts with a future tense verb — frame it as "What will this upgrade do to my instance?" (add, update, remove, etc.).

**Bugs Fixed entries:** do not start with "fixed" — it's redundant. Describe what the fix does, still answering "What will this upgrade do to my instance?"

```
REST/JSON API enhancements:
API keys: add multiple, per-user, scoped keys for agentic workflows

Bugs Fixed:
Evidence: redirect back to the correct view when canceling an edit
Editor: insert images at the cursor position when dragging and dropping or copying and pasting
```


## Acceptance testing

After a feature is complete, developers write an acceptance testing plan for the Support / Customer Success team. These testers are familiar with the product but not the codebase. The plan goes in the task tracker under the "Acceptance" section.

Format:

> **How to test**
> (Steps to test functionality, described in detail for someone not familiar with this part of the application / code base)

Guidelines:
- Write numbered step-by-step instructions a non-developer can follow in the browser
- State prerequisites (user role, seed data needed)
- Cover the happy path first, then edge cases and error states
- For API features, include concrete `curl` examples with expected responses
- Include what the tester should verify at each step (flash messages, UI state changes, DB side effects)
- Distinguish between what should succeed and what should be rejected (e.g. out-of-scope API calls returning 403)
