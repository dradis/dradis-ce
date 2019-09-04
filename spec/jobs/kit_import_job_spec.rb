# frozen_string_literal: true

require 'rails_helper'

RSpec.describe KitImportJob do
  describe '#perform' do

    before(:each) do
      file     = File.new(Rails.root.join('spec', 'fixtures', 'files', 'templates', 'kit.zip'))
      tmp_dir = Rails.root.join('tmp', 'rspec')
      @user    = create(:user)

      conf = Configuration.find_or_initialize_by(name: 'admin:paths:note_templates')
      folder = tmp_dir.join('notes')
      conf.value = folder.to_s
      conf.save!
      FileUtils.mkdir_p folder

      ['methodologies', 'projects', 'reports'].each do |item|
        conf = Configuration.find_or_initialize_by(name: "admin:paths:templates:#{item}")
        folder = tmp_dir.join(item)
        conf.value = folder
        conf.save!
        FileUtils.mkdir_p folder
      end

      allow(NoteTemplate).to receive(:pwd).and_return(
        Pathname.new(Configuration.paths_templates_notes)
      )
      allow(Methodology).to receive(:pwd).and_return(
        Pathname.new(Configuration.paths_templates_methodologies)
      )

      described_class.new.perform(file: file, logger: Log.new.write('Testing...'))
    end

    after(:all) do
      Rails.root.join('tmp', 'rspec')
    end

    it 'imports kit content' do
      # issue template
      expect(NoteTemplate.find('issue')).to_not be_nil

      # evidence template
      expect(NoteTemplate.find('evidence')).to_not be_nil

      # methodology template
      expect(Methodology.find('OWASPv4-methodology')).to_not be_nil

      # project template
      expect(Pathname.new(Configuration.paths_templates_projects) \
        .join('OWASPv4-blank-project-template.xml').file?).to be true

      # report template files
      expect(Pathname.new(Configuration.paths_templates_reports) \
        .join('html_export').join('OWASPv4.v0.3.html.erb').file?).to be true

      # sample project
      project = Project.find(1)
      expect(project.issues.count).to eq 8
    end
  end
end
