# frozen_string_literal: true

class Project
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_reader :id, :name

  def initialize(id: 1, name: 'Dradis CE', **_attrs)
    @id   = id
    @name = name
  end

  def persisted?; true; end

  def nodes
    Node.all
  end

  def notes
    Note.all
  end

  # When Upload plugins create new nodes, they'll do so under this parent node
  def plugin_parent_node
    @plugin_parent_node ||= nodes.find_or_create_by(label: ::Configuration.plugin_parent_node)
  end

  # Security scanner output files uploaded via the Upload Manager use this node
  # as container
  def plugin_uploads_node
    @plugin_uploads_node ||= nodes.find_or_create_by(label: ::Configuration.plugin_uploads_node)
  end

end
