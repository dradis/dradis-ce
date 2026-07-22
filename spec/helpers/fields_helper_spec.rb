require 'rails_helper'

describe FieldsHelper do
  describe '#render_dropdown?' do
    it 'returns false when there are no field options' do
      expect(helper.render_dropdown?('Risk', 'High')).to eq(false)
    end

    it 'returns false for a field with no matching options' do
      assign(:field_options, { 'Risk' => %w[High Medium Low] })
      expect(helper.render_dropdown?('Status', 'Open')).to eq(false)
    end

    it 'returns true when the value is blank' do
      assign(:field_options, { 'Risk' => %w[High Medium Low] })
      expect(helper.render_dropdown?('Risk', '')).to eq(true)
    end

    it 'returns true when the value matches one of the options' do
      assign(:field_options, { 'Risk' => %w[High Medium Low] })
      expect(helper.render_dropdown?('Risk', 'High')).to eq(true)
    end

    it 'returns false when the value does not match any of the options' do
      assign(:field_options, { 'Risk' => %w[High Medium Low] })
      expect(helper.render_dropdown?('Risk', '{{ issue.risk }}')).to eq(false)
    end
  end

  describe '#dropdown_options' do
    it 'returns the options for the given field' do
      assign(:field_options, { 'Risk' => %w[High Medium Low] })
      expect(helper.dropdown_options('Risk')).to eq(%w[High Medium Low])
    end
  end
end
