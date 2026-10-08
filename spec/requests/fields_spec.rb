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

  it 'passes the editor id on to the Add field link' do
    post form_fields_path, params: { source: "#[Title]#\nTitle\n", editor_id: '2' }

    link = Nokogiri::HTML.fragment(response.body).at_css('[data-behavior~=add-field]')

    expect(link['href']).to include('editor_id=2')
  end
end

describe 'fields#field' do
  before { login_as_user }

  it 'adds the field to the editor it was requested from' do
    get field_fields_path(format: :js), params: { index: 3, editor_id: '2' }, xhr: true

    expect(response.body).to include('[data-textile-editor-id="2"]')
    expect(response.body).to include('item_form[field_name_3]')
  end
end
