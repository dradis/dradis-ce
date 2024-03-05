# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MappingMigrationService do
  describe '.call' do
    subject(:migrate_templates) { described_class.new.call }

    before do
      @templates_dir = Rails.root.join('spec/fixtures/files/templates/plugins/')
      templates_path = Pathname.new(@templates_dir)
      FileUtils.mkdir_p(templates_path)
      allow(Configuration).to receive(:paths_templates_plugins).and_return(templates_path)
      FileUtils.mkdir_p(templates_path.join('qualys'))
      FileUtils.cp(templates_path.join('evidence.template') , templates_path.join('qualys/evidence.template'))
    end

    after do
      FileUtils.rm_r(Rails.root.join('spec/fixtures/files/templates/plugins/qualys'))
    end

    it 'creates mappings and associated mapping fields' do
      migrate_templates

      if defined?(Dradis::Pro)
      else
        expect(Mapping.last.destination).to eq(nil)
      end
      expect(Mapping.last.source).to eq('vuln_evidence')
      expect(Mapping.last.mapping_fields.last.source_field).to eq('custom text')
      expect(Mapping.last.mapping_fields.last.destination_field).to eq('Custom')
      expect(Mapping.last.mapping_fields.first.destination_field).to eq('TestField')
      expect(Mapping.last.mapping_fields.first.content).to eq('{{ qualys[evidence.test_field] }}')
    end

    it 'renames .template files after migrating them to mappings' do
      expect(File.exist?(@templates_dir.join('qualys/evidence.template'))).to be true
      migrate_templates
      expect(File.exist?(@templates_dir.join('qualys/evidence.template.legacy'))).to be true
    end
  end
end
