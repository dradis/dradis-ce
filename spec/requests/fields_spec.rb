require 'rails_helper'

describe 'fields#form' do
  before { login_as_user }

  context 'when a field has explicit list options and a blank value' do
    it 'defaults to a blank option instead of the first list option' do
      post form_fields_path, params: {
        source: "#[Risk]#\n",
        field_values: { 'Risk' => %w[High Medium Low] }
      }

      select = Nokogiri::HTML.fragment(response.body).at_css('select')

      expect(select.at_css('option[selected]')).to be_nil
      expect(select.css('option').first['value']).to eq('')
    end
  end
end
