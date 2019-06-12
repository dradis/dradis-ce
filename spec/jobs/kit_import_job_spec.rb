# frozen_string_literal: true

require 'rails_helper'

RSpec.describe KitImportJob do
  describe '#perform' do

    before(:each) do
      file     = File.new(Rails.root.join('spec', 'fixtures', 'files', 'templates', 'kit.zip'))
      tmp_dir = Rails.root.join("tmp", "rspec")
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
      allow(ProjectTemplate).to receive(:pwd).and_return(
        Pathname.new(Configuration.paths_templates_projects)
      )

      described_class.new.perform(file: file, logger: Log.new.write('Testing...'))
    end

    after(:all) do
      Rails.root.join("tmp", "rspec")
    end

    it 'imports kit content' do
      # issue template
      expect(NoteTemplate.find('issue')).to_not be_nil

      # evidence template
      expect(NoteTemplate.find('evidence')).to_not be_nil

      # methodology template
      expect(Methodology.find('OWASPv4_Testing_Methodology')).to_not be_nil

      # project template
      expect(ProjectTemplate.find_template('dradis-template-welcome')).to_not be_nil

      # report template files
      word_template_properties = ReportTemplateProperties.find_by(template_file: 'dradis_welcome_template.v0.5.docm')
      expect(word_template_properties).to_not be_nil
      expect(ReportTemplateProperties.find_by(template_file: 'dradis_template-excel-simple.v1.3.xlsx')).to_not be_nil
      expect(ReportTemplateProperties.find_by(template_file: 'html_welcome_report.html.erb')).to_not be_nil

      # report template properties
      expect(word_template_properties.content_blocks.keys).to match_array(['Conclusion', 'Scope'])
      expect(word_template_properties.issue_fields.map(&:name)).to match_array(['Issue Field 1', 'Issue Field 2'])
      expect(word_template_properties.evidence_fields.map(&:name)).to match_array(['Evidence Field 1', 'Evidence Field 2'])
      expect(word_template_properties.document_properties).to match_array(['dradis.project', 'dradis.client'])

      # rules engine
      expect(Dradis::Pro::Rules::Rules::AndRule.find_by(name: 'Nessus N/A CVSS to 0.0')).to_not be_nil
      expect(Dradis::Pro::Rules::Rules::AndRule.find_by(name: 'Nessus: Tag Critical')).to_not be_nil
      expect(Dradis::Pro::Rules::Rules::AndRule.find_by(name: 'Nessus: Tag High')).to_not be_nil
      expect(Dradis::Pro::Rules::Rules::AndRule.find_by(name: 'Nessus: Tag Medium')).to_not be_nil
      expect(Dradis::Pro::Rules::Rules::AndRule.find_by(name: 'Nessus: Tag Low')).to_not be_nil
      expect(Dradis::Pro::Rules::Rules::AndRule.find_by(name: 'Nessus: Tag Info')).to_not be_nil

      # sample project
      project = Project.find_by(name: 'dradis-export-welcome')
      expect(project).to_not be_nil
      expect(project.owners.first).to eq @user
    end
  end
end
