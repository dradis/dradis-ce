# frozen_string_literal: true

require 'spec_helper'
require 'active_model'

require_relative '../../app/models/project'

RSpec.describe Project do
  it 'has default ID 1' do
    expect(Project.new.id).to eq 1
  end

  it 'has default name "Dradis CE"' do
    expect(Project.new.name).to eq 'Dradis CE'
  end

  it 'allows id and name to be set on initialization' do
    project = Project.new(id: 5, name: 'Whatever')
    expect(project.id).to eq 5
    expect(project.name).to eq 'Whatever'
  end
end
