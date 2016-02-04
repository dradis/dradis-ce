# This class is used to store configuration options in the back-end database.
# Each Configuration object has a :name and a :value. Some configuration
# parameters can be accessed through the helper methods provided in this class.
class Configuration < ActiveRecord::Base
  # -- Relationships --------------------------------------------------------

  # -- Callbacks ------------------------------------------------------------

  # -- Validations ----------------------------------------------------------
  validates_presence_of :name, :value
  validates_uniqueness_of :name

  # -- Scopes ---------------------------------------------------------------

  # -- Class Methods --------------------------------------------------------
  # --------------------------------------------------------------- Misc admin:
  def self.emails_node
    find_by(name: 'admin:emails_node').value
  end

  def self.shared_password
    find_or_create_by(name: 'admin:password', value: 'improvable_dradis')
  end

  def self.session_timeout
    find_or_create_by(
      name: 'admin:session_timeout',
      value: 15
    ).value.to_i
  end


  # --------------------------------------------------------------- admin:paths
  def self.paths_templates_plugins
    find_or_create_by(
      name:  'admin:paths:templates:plugins',
      value: Rails.root.join('templates', 'plugins').to_s
    ).value
  end

  def self.paths_templates_reports
    find_or_create_by(
      name:  'admin:paths:templates:reports',
      value: Rails.root.join('templates', 'reports').to_s
    ).value
  end


  # ------------------------------------------------------------- admin:plugins

  # This setting is used by the plugins as the root of all the content the add.
  def self.plugin_parent_node
    find_or_create_by(
      name:  'admin:plugins:parent_node',
      value: 'plugin.output'
    ).value
  end

  # Retrieve the name of the Node used to associate file uploads.
  def self.plugin_uploads_node
    find_or_create_by(
      name:  'admin:plugins:uploads_node',
      value: 'Uploaded files'
    ).value
  end

  # -- Instance Methods -----------------------------------------------------
end
