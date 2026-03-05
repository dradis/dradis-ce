# CLAUDE.md — Dradis Pro

## Project overview

Dradis Community Edition (CE) is a Ruby on Rails application for collaborative security assessment reporting.

- **Rails 8.0**, Ruby 3.4, MySQL (mysql2), Importmaps (no Webpack)
- **Authentication:** Warden (custom strategies, not Devise). Default scope only — never pass `scope: :user`.
- **Authorization:** CanCanCan 3.0 with role-based bit mask (`:admin`, `:author`, `:contributor`, `:disabled`)
- **Jobs:** Resque (queue adapter) + SolidQueue (recurring/scheduled via `config/recurring.yml`)
- **Frontend:** Bootstrap 5, Stimulus, Turbo (Drive is disabled, but Frames and Streams are used), jQuery, Font Awesome 6


## Common commands

    ```bash
    # Run full test suite
    bundle exec rspec

    # Run a single spec file
    bundle exec rspec spec/path/to/spec.rb

    # Run engine specs
    bundle exec rspec engines/dradispro-api/spec/

    # Lint (full)
    bundle exec rubocop

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
  dradispro-api/            # Pro API — v1/v2/v3 endpoints, API key management
  dradispro-bi/             # Business intelligence / analytics
  dradispro-issuelib/       # Issue library
  dradispro-rules/          # Rules Engine
  dradispro-results_portal/ # External Results Portal
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
          └── Engine controllers (e.g. Dradis::Pro::API::APIKeysController)
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

## Code style

RuboCop is configured with `DisabledByDefault: true` — only explicitly enabled cops apply. Key rules:

- **Single-quoted strings** unless interpolation is needed
- **2-space indentation**, no tabs
- **No shorthand hash syntax** (`EnforcedShorthandSyntax: never`) — use `{ name: name }` not `{ name: }`
- **Spaces** around operators, after commas/colons, around `=` in default params, before block braces, inside block braces (no space), inside hash literals (space)
- **`&&`/`||`** over `and`/`or`
- **Empty lines** around class/module/method bodies: none allowed
- Excluded from linting: `**/templates/**/*`, `**/vendor/**/*`, `db/schema.rb`


## Custom inflections (important for Zeitwerk)

Defined in `config/initializers/inflections.rb`:

- `evidence` is **uncountable** (never `evidences`)
- Acronyms: `IP`, `IPs`, `JSON`, `OS`, `OSs`, `QA`, `RTP`

**Zeitwerk naming consequence:** Rails treats `API` as an implicit acronym. Files under `api_keys/` expect class names like `APIKey`, `APIKeysController`, `APIToken` — **not** `ApiKey`, `ApiKeysController`, `ApiToken`.


## JavaScript conventions

- JS lives under `app/assets/javascripts/hera/`
  - `./pages/` — scripts specific to a single view (e.g. `users.js`, `api_keys.js`)
  - `./modules/` — reusable snippets triggered across unrelated pages
- New page scripts must be added to the `hera.js` sprockets manifest (`//= require hera/pages/...`); there is no `require_tree`.
- **Never use inline `<script>` tags in views.** Always extract to the appropriate location above.
- Prefer **vanilla JS** over jQuery (jQuery is loaded but legacy). Never use CoffeeScript (`.coffee` files exist but are legacy).
- Page scripts use `turbo:load` (not `DOMContentLoaded`) and guard on body CSS classes:

  ```js
  document.addEventListener('turbo:load', function () {
    if (document.querySelector('body.controller_path.action_name')) {
      // ...
    }
  });
  ```

- Body classes come from controller_path.gsub('/', '-') and action_name (see HeraHelper#body_css).
- Interactive elements use data-behavior attributes for JS hooks (e.g. data-behavior="api-key-full-access").


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


## Changelogs

Two changelogs, both follow the template in `CHANGELOG.template`:

- **`CHANGELOG`** — CE (Community Edition) changes. Features that land in CE first are recorded here.
- **`CHANGELOG.pro`** — Pro-only changes. If a CE change also applies to Pro, it gets migrated here too.

Entries use **future tense** verbs and are grouped under the relevant section heading from the template (e.g. `REST/JSON API enhancements`, `Bug fixes`, `Reporting enhancements`). Keep entries to a single line per feature. Do not create a new version header — add to the existing `[v#.#.#]` block at the top.

Example:

```
REST/JSON API enhancements:
API keys: add multiple, per-user, scoped keys for agentic workflows
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


## Key patterns

**Event publishing:** Controllers `include EventPublisher` and call `publish_event('namespace.action', ...)`. Models `include Eventable`. Events route through `ActiveSupport::Notifications` and `ActivityService.subscribe_namespace`.

Event name convention: `'issue.created'`, `'comment.destroyed'`, `'inline_thread.resolved'`.

> **Deprecated:** `ActivityTracking` (`track_created`, `track_destroyed`, `track_activity`,
> `track_state_change`) — do not use in new code. Use `EventPublisher` + `publish_event` instead.

**Engine registration:** Each Pro engine inherits from `Dradis::Plugins::Base`, provides `:addon`, and registers Warden strategies / controller extensions in initializers.

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


## Git workflow

- Primary branch: `develop`
- Feature branches: topic branches off `develop`
- Sub-branch rules: `topic/feature` (e.g. `api_keys/model`)
- Commit format: `(#TICKET) Short imperative statement` with body explaining the problem and fix
- CI runs: bundler-audit, ruby-audit, brakeman, rubocop (changed files), rspec (4 parallel nodes)
- Feature branch PRs into `develop` should have a Summary describing the full feature, not just the last commit
- `db/schema.rb` hygiene: Only commit schema changes from your own migrations.
- Do not add `Co-Authored-By` lines to commit messages.
