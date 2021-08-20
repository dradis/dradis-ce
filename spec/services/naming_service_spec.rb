# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NamingService do
  let(:temp_path) { Rails.root.join('tmp', 'naming_service_spec') }

  describe '.name_file' do
    before do
      FileUtils.rm_rf(temp_path)
    end

    after do
      FileUtils.rm_rf(temp_path)
    end

    context 'file does not exist in directory' do
      it 'returns original filename' do
        result = described_class.name_file(
          original_filename: 'rails.png',
          pathname: temp_path
        )

        expect(result).to eq('rails.png')
      end
    end

    context 'file exists in the directory' do
      it 'returns a copy of the filename' do
        FileUtils.mkdir_p(temp_path)
        FileUtils.cp(Rails.root.join('spec/fixtures/files/rails.png'), temp_path.join('rails.png'))

        result = described_class.name_file(
          original_filename: 'rails.png',
          pathname: temp_path
        )

        expect(result).to eq('rails_copy-01.png')
      end
    end
  end
end
