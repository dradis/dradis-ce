---
name: create-addon
description: Scaffold a new Dradis addon gem with the correct boilerplate structure. Ask questions to determine the addon type, name, description, and capabilities, then generate all required files in a new directory.
---

You are scaffolding a new Dradis addon. Follow these steps exactly.

## Step 1 — Gather information

Ask the user the following questions one group at a time. Keep the tone friendly and jargon-free. Wait for all answers in a group before moving to the next group.

**Group 1 — The basics:**

Ask these four questions together:

1. **What would you like to call your addon?** This can be a tool name, a product name, or just a short descriptive name. For example: "Custom Importer", "Custom Exporter", "ACME Risk Matrix". It will be used to name the addon directory and files.
2. **Describe what your addon does in one sentence.** For example: "Imports findings from our internal scanning tool into Dradis" or "Displays all project findings in a custom risk matrix table tailored to ACME's scoring methodology."
3. **Your name** — this will appear in the addon's metadata.
4. **Your email address** — also used in the addon's metadata.

---

**Group 2 — What should your addon do?**

Ask this as a simple choice. Frame it conversationally:

> Dradis addons can do one or more of the following things. Which fits what you're building?
>
> **Option A — Import files**
> Your addon will let users upload a file — any kind of file — and Dradis will read it and turn the contents into items in the project (like issues, notes, or evidence). Choose this if you have data in a file that you want to bring into Dradis automatically.
>
> **Option B — Export / generate reports**
> Your addon will take the data already in a Dradis project and produce an output file from it — for example, a custom HTML report, a CSV export, or any other format your team needs. Choose this if you want to generate something *from* Dradis.
>
> **Option C — Add new pages to Dradis**
> Your addon will add its own screens or interfaces inside the Dradis web app — for example, a custom risk matrix table, a team-specific findings view, or a bespoke workflow that only makes sense for your organisation. Choose this if you're building something that needs its own UI.
>
> **Option D — A combination**
> Mix and match any of the above. Just tell us which ones apply.

## Step 2 — Confirm before creating

Silently derive the following from the addon name:

- `<slug>` — lowercase, hyphenated (e.g. `custom-importer`, `acme-risk-matrix`)
- `<module_name>` — CamelCase (e.g. `CustomImporter`, `AcmeRiskMatrix`)
- `<plugin_name>` — underscored (e.g. `custom_importer`, `acme_risk_matrix`)

Then confirm with the user using only the details they gave you:

> Here's what I'll create:
>
> - **Name:** <addon name they provided>
> - **Description:** <description they provided>
> - **Type:** <what they chose — Import, Export, Custom pages, or a combination>
> - **Location:** `../plugins/dradis-<slug>/`
>
> Shall I go ahead?

## Step 3 — Generate files

Create all files inside `../plugins/dradis-<slug>/` (a sibling directory to `dradis-ce`, under a `plugins/` folder). Generate every file listed below with correct content based on the answers.

---

### Files to generate

#### `dradis-<slug>.gemspec`
```ruby
$:.push File.expand_path('../lib', __FILE__)
require 'dradis/plugins/<slug>/version'
version = Dradis::Plugins::<module_name>::VERSION::STRING

Gem::Specification.new do |spec|
  spec.platform    = Gem::Platform::RUBY
  spec.name        = 'dradis-<slug>'
  spec.version     = version
  spec.summary     = '<description>'
  spec.description = '<description>'

  spec.license  = 'GPL-2'
  spec.authors  = ['<author_name>']
  spec.email    = ['<author_email>']
  spec.homepage = 'https://dradis.com'

  spec.files         = `git ls-files`.split($\)
  spec.executables   = spec.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'dradis-plugins', '~> 4.0'

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'combustion', '~> 1.3'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec-rails'
end
```

#### `Gemfile`
```ruby
source 'https://rubygems.org'

gemspec
```

#### `Rakefile`
```ruby
require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task default: :spec
```

#### `lib/dradis-<slug>.rb`
```ruby
require 'dradis-plugins'

require 'dradis/plugins/<slug>'
```

#### `lib/dradis/plugins/<slug>.rb`
```ruby
module Dradis::Plugins::<module_name>
  PLUGIN_NAME = :<plugin_name>
end

require 'dradis/plugins/<slug>/engine'
require 'dradis/plugins/<slug>/gem_version'
require 'dradis/plugins/<slug>/version'
```

If upload addon, also add:
```ruby
require 'dradis/plugins/<slug>/field_processor'
require 'dradis/plugins/<slug>/importer'
require 'dradis/plugins/<slug>/mapping'
```

#### `lib/dradis/plugins/<slug>/engine.rb`

The `provides` line reflects the user's chosen option(s):

- Import only: `provides :upload`
- Export only: `provides :export`
- Custom pages only: `provides :addon`
- Any combination: `provides :upload, :export` / `provides :upload, :addon` / etc.

```ruby
module Dradis::Plugins::<module_name>
  class Engine < ::Rails::Engine
    isolate_namespace Dradis::Plugins::<module_name>

    include ::Dradis::Plugins::Base
    description '<description>'
    provides :<capability>  # one or more of: :upload, :export, :addon
  end
end
```

If `provides :addon` or `provides :export` is included, add an initializer block to mount the engine:
```ruby
    initializer '<slug>.mount_engine' do |app|
      app.routes.prepend do
        mount Dradis::Plugins::<module_name>::Engine => '/', as: :<plugin_name>
      end
    end
```

#### `lib/dradis/plugins/<slug>/version.rb`
```ruby
require_relative 'gem_version'

module Dradis::Plugins::<module_name>
  module VERSION
    MAJOR = 0
    MINOR = 1
    TINY  = 0
    PRE   = nil

    STRING = [MAJOR, MINOR, TINY, PRE].compact.join('.')
  end
end
```

#### `lib/dradis/plugins/<slug>/gem_version.rb`
```ruby
module Dradis::Plugins::<module_name>
  def self.gem_version
    Gem::Version.new VERSION::STRING
  end
end
```

#### `lib/dradis/plugins/<slug>/importer.rb` (upload addons only)
```ruby
module Dradis::Plugins::<module_name>
  class Importer < Dradis::Plugins::Upload::Importer
    # Override the import method to process the uploaded file.
    #
    # The `params` hash includes:
    #   params[:file]    - path to the uploaded file (a Tempfile or String path)
    #   params[:project] - the current Dradis project
    #
    # Use content_service to create nodes, issues, and evidence:
    #   content_service.create_node(label: 'hostname')
    #   content_service.create_note(node: node, text: '#[Title]#\nValue')
    #   content_service.create_issue(text: '#[Title]#\nValue')
    #   content_service.create_evidence(issue: issue, node: node, content: '#[Port]#\n443')
    #
    # Use mapping_service to apply field mappings from templates:
    #   mapping_service.apply_mapping(source: :<entity>, data: object)
    def import(params = {})
      file_content = File.read(params[:file])

      # TODO: parse file_content and iterate over findings

      logger.info { 'Done.' }
    end
  end
end
```

#### `lib/dradis/plugins/<slug>/field_processor.rb` (upload addons only)
```ruby
module Dradis::Plugins::<module_name>
  class FieldProcessor < Dradis::Plugins::Upload::FieldProcessor
    # Map a Liquid template field name to a value from the source data object.
    #
    # `params[:data]` is the object you passed to mapping_service.apply_mapping.
    # `params[:field]` is the field name from the template (e.g. '<plugin_name>[entity.attribute]').
    #
    # Example:
    #   when '<plugin_name>[finding.title]' then object.title
    def value(params = {})
      _object = params[:data]
      _field  = params[:field]

      case params[:field]
      # TODO: add field mappings here
      # when '<plugin_name>[finding.title]' then object.title
      end
    end
  end
end
```

#### `lib/dradis/plugins/<slug>/mapping.rb` (upload addons only)
```ruby
module Dradis::Plugins::<module_name>
  module Mapping
    # DEFAULT_MAPPING defines the default Liquid templates used when importing.
    # Keys are entity types (matching your importer), values are field-to-template maps.
    # Template variables use the syntax: {{ <plugin_name>[entity.attribute] }}
    DEFAULT_MAPPING = {
      issue: {
        'Title'       => '{{ <plugin_name>[issue.title] }}',
        'Description' => '{{ <plugin_name>[issue.description] }}'
      },
      evidence: {
        'Output' => '{{ <plugin_name>[evidence.output] }}'
      }
    }.freeze

    SOURCE_FIELDS = {
      issue: %w[
        issue.title
        issue.description
      ],
      evidence: %w[
        evidence.output
      ]
    }.freeze
  end
end
```

Adjust entity names and fields based on the user's answers about their data model.

#### `templates/` (upload addons only)

Create both sample files. Use the Dradis `#[FieldName]#` syntax.

**`templates/issue.sample`:**
```
#[Title]#
{{ <plugin_name>[issue.title] }}

#[Description]#
{{ <plugin_name>[issue.description] }}
```

**`templates/evidence.sample`:**
```
#[Output]#
{{ <plugin_name>[evidence.output] }}
```

#### `spec/spec_helper.rb`
```ruby
ENV['RAILS_ENV'] ||= 'test'

require 'combustion'
Combustion.initialize! :all

require 'rspec/rails'

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
end
```

#### `spec/dradis/plugins/<slug>/importer_spec.rb` (upload addons only)
```ruby
require 'spec_helper'

describe Dradis::Plugins::<module_name>::Importer do
  pending 'add importer specs here'
end
```

#### `spec/fixtures/files/.gitkeep`
Empty placeholder file so the fixtures directory is tracked.

#### `.gitignore`
```
*.gem
*.rbc
.bundle
.config
.yardoc
Gemfile.lock
InstalledFiles
_yardoc/
coverage/
doc/
lib/bundler/man/
pkg/
rdoc/
spec/reports/
test/tmp/
test/version_tmp/
tmp/
```

#### `LICENSE`
```
Copyright (c) <year> <author_name>

This software is open source and available under the GNU General Public License
version 2 (GPL-2). See https://www.gnu.org/licenses/old-licenses/gpl-2.0.html
```

#### `CHANGELOG.md`
```markdown
# Changelog

## [Unreleased]

### Added
- Initial release
```

#### `README.md`
```markdown
# dradis-<slug>

<description>

## Installation

Add to your Dradis `Gemfile`:

```ruby
gem 'dradis-<slug>'
```

Then run:

```
bundle install
```

## Usage

<!-- TODO: describe how to use this addon -->

## Development

```
bundle exec rspec
```

## License

GPL-2. See [LICENSE](LICENSE).
```

---

## Step 4 — Export addon extras (`:export` capability)

If the addon provides `:export`, scaffold these additional files:

#### `lib/dradis/plugins/<slug>/exporter.rb`
```ruby
module Dradis::Plugins::<module_name>
  class Exporter < Dradis::Plugins::Export::Base
    # Override the export method to generate your output file.
    #
    # Use `project` to access the current Dradis project.
    # Use `content_service` to read nodes, issues, notes, and evidence.
    # Use `logger` to write progress messages.
    #
    # Return the path to the generated file, or the file content as a string.
    def export(args = {})
      # TODO: build and return your export output
      logger.info { 'Done.' }
    end
  end
end
```

Also add the require to `lib/dradis/plugins/<slug>.rb`:
```ruby
require 'dradis/plugins/<slug>/exporter'
```

#### `app/controllers/dradis/plugins/<slug>/reports_controller.rb`
```ruby
module Dradis::Plugins::<module_name>
  class ReportsController < Dradis::Plugins::Export::BaseController
  end
end
```

#### `config/routes.rb`
```ruby
Dradis::Plugins::<module_name>::Engine.routes.draw do
  resources :projects, only: [] do
    resource :report, only: [:create], path: '/export/<slug>/reports'
  end
end
```

---

## Step 5 — Custom pages addon extras (`:addon` capability)

If the addon provides `:addon` (and does not already have a `config/routes.rb` from the export step), scaffold:

#### `config/routes.rb`
```ruby
Dradis::Plugins::<module_name>::Engine.routes.draw do
  # TODO: add routes
  # root to: 'dashboard#index'
end
```

#### `app/controllers/dradis/plugins/<slug>/application_controller.rb`
```ruby
module Dradis::Plugins::<module_name>
  class ApplicationController < ::AuthenticatedController
    include ::ProjectScoped
  end
end
```

#### `app/views/dradis/plugins/<slug>/placeholder/index.html.erb`
```erb
<div>
  <h1>Your addon is working!</h1>
  <p>This is a placeholder view for the <strong>dradis-<slug></strong> addon.</p>
  <p>When you're ready to build your UI, here's where to start:</p>
  <ul>
    <li>Delete or rename <code>app/controllers/dradis/plugins/<slug>/placeholder_controller.rb</code> and replace it with your own controller.</li>
    <li>Add your views under <code>app/views/dradis/plugins/<slug>/</code>.</li>
    <li>Update <code>config/routes.rb</code> to point at your new controller.</li>
  </ul>
</div>
```

Also scaffold the matching placeholder controller so the view is reachable when the gem is first loaded:

#### `app/controllers/dradis/plugins/<slug>/placeholder_controller.rb`
```ruby
module Dradis::Plugins::<module_name>
  class PlaceholderController < ApplicationController
    def index
    end
  end
end
```

And update `config/routes.rb` to point at it as the root:
```ruby
Dradis::Plugins::<module_name>::Engine.routes.draw do
  root to: 'placeholder#index'
end
```

## Step 6 — Initialize git and show summary

After generating all files, run:
```
cd ../plugins/dradis-<slug> && git init && git add -A && git commit -m 'initial scaffold'
```


Then show the user a friendly summary — avoid technical jargon. List the files that were created and give them clear next steps:

> Your addon scaffold is ready at `../plugins/dradis-<slug>/`.
>
> **What was created:**
> *(show a file tree)*
>
> **Technical details** (useful if you're working with a developer):
> - Gem name: `dradis-<slug>`
> - Ruby module: `Dradis::Plugins::<module_name>`
>
> **What to do next:**

Show only the steps relevant to the addon type(s) the user chose:

**If they chose Import (Option A or D with import):**
> 1. Open `lib/dradis/plugins/<slug>/importer.rb` — this is where you write the logic to read the uploaded file and turn its contents into issues and evidence in Dradis.
> 2. Open `lib/dradis/plugins/<slug>/mapping.rb` — this controls which fields get imported and what they're called in Dradis.
> 3. Open `templates/issue.sample` and `templates/evidence.sample` — these are the default templates Dradis uses when displaying imported data. Edit the field names to match your data.
> 4. If your addon needs a library to help read a specific file format, add it to `dradis-<slug>.gemspec` under `spec.add_dependency`.

**If they chose Export (Option B or D with export):**
> 1. Open `lib/dradis/plugins/<slug>/exporter.rb` — this is where you write the logic to take data from a Dradis project and produce your output file.
> 2. The `export` method has access to everything in the project — issues, evidence, nodes, and notes. Build your output however you need.

**If they chose Custom pages (Option C or D with custom pages):**
> 1. Visit your addon's root URL in Dradis to see the placeholder page — it confirms everything is wired up correctly.
> 2. Open `app/views/dradis/plugins/<slug>/` — replace the placeholder with your real views here.
> 3. Open `config/routes.rb` — swap out the placeholder route for your real routes.
> 4. Add controllers under `app/controllers/dradis/plugins/<slug>/` — inherit from `ApplicationController` to get authentication and project scoping for free.

**For all addon types, finish with:**
> - To use your addon with a local Dradis installation, add this line to the Dradis `Gemfile`:
>   ```ruby
>   gem 'dradis-<slug>', path: '../plugins/dradis-<slug>'
>   ```
>   Then run `bundle install` inside the Dradis directory.
> - When you're ready to share your addon, publish it to RubyGems or share the directory directly.
