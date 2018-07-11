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
end
