# This class is used to store configuration options in the back-end database.
# Each Configuration object has a :name and a :value. Some configuration
# parameters can be accessed through the helper methods provided in this class.
class Configuration < ApplicationRecord
  # -- Relationships --------------------------------------------------------

  # -- Callbacks ------------------------------------------------------------

  # -- Validations ----------------------------------------------------------
  validates_presence_of :name, :value
  validates_uniqueness_of :name

  # -- Scopes ---------------------------------------------------------------

  # -- Class Methods --------------------------------------------------------
  # --------------------------------------------------------------- Misc admin:
  def self.mail_host
    create_with(value: 'dradis-framework.dev')
      .find_or_create_by(name: 'admin:mail_host').value
  end

  def self.max_deleted_inline
    create_with(value: 15)
      .find_or_create_by(name: 'admin:max_deleted_inline').value.to_i
  end

  def self.session_timeout
    create_with(value: 15)
      .find_or_create_by(name: 'admin:session_timeout').value.to_i
  end

  def self.shared_password
    create_with(value: 'improvable_dradis')
      .find_or_create_by(name: 'admin:password').value
  end

  def self.signups_enabled?
    create_with(value: 0)
      .find_or_create_by(name: 'admin:signups_enabled').value.to_i == 1
  end

  # --------------------------------------------------------------- admin:paths
  def self.paths_templates
    @@paths_templates ||= Rails.root.join('storage', 'templates')
  end

  def self.paths_templates_methodologies
    create_with(value: paths_templates.join('methodologies').to_s)
      .find_or_create_by(name: 'admin:paths:templates:methodologies').value
  end

  def self.paths_templates_notes
    create_with(value: paths_templates.join('notes').to_s)
      .find_or_create_by(name: 'admin:paths:templates:notes').value
  end

  def self.paths_templates_plugins
    create_with(value: paths_templates.join('plugins').to_s)
      .find_or_create_by(name: 'admin:paths:templates:plugins').value
  end

  def self.paths_templates_projects
    create_with(value: paths_templates.join('projects').to_s)
      .find_or_create_by(name: 'admin:paths:templates:projects').value
  end

  def self.paths_templates_reports
    create_with(value: paths_templates.join('reports').to_s)
      .find_or_create_by(name: 'admin:paths:templates:reports').value
  end

  # ------------------------------------------------------------- admin:plugins

  # This setting is used by the plugins as the root of all the content the add.
  def self.plugin_parent_node
    create_with(value: 'plugin.output')
      .find_or_create_by(name: 'admin:plugins:parent_node').value
  end

  # Retrieve the name of the Node used to associate file uploads.
  def self.plugin_uploads_node
    create_with(value: 'Uploaded files')
      .find_or_create_by(name: 'admin:plugins:uploads_node').value
  end

  # -- Instance Methods -----------------------------------------------------
end
