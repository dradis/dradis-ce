# frozen_string_literal: true

class Project
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_reader :id, :name

  # -- Class Methods --------------------------------------------------------
  def self.find(id)
    new(id: id)
  end

  # -- Instance Methods -----------------------------------------------------
  def initialize(id: 1, name: 'Dradis CE', **_attrs)
    @id   = id
    @name = name
  end

  def persisted?; true; end

  def evidence
    Evidence.all
  end

  def issues
    Issue.where(node_id: issue_library.id)
  end

  # Returns or creates the Node that acts as container for the project's Issues
  def issue_library
    @issue_library ||= nodes.find_or_create_by(
      label: 'All issues',
      type_id: Node::Types::ISSUELIB
    )
  end

  def nodes
    Node.all
  end

  def notes
    Note.all
  end

  def tags
    Tag.all
  end

  def boards
    Board.all
  end

  # Returns or creates the Node that acts as container for all Methodologies in
  # a given project
  def methodology_library
    @methodology_library ||= nodes.find_or_create_by(
      label: 'Methodologies',
      type_id: Node::Types::METHODOLOGY
    )
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

  # If an item is recovered from the trash, but we can't reassign it to its
  # Node because its Node has also been deleted, it will be assigned to this
  # node:
  def recovered
    @recovered ||= nodes.find_or_create_by(label: 'Recovered')
  end
end
