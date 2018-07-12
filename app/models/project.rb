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

  # Returns or creates the Node that acts as container for the project's Issues
  def issue_library
    @issue_library ||= nodes.find_or_create_by(
      label: 'All issues',
      type_id: Node::Types::ISSUELIB
    )
  end

  def issues
    Issue.where(node_id: issue_library.id)
  end
end
