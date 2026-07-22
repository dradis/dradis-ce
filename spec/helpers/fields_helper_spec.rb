require 'rails_helper'

describe FieldsHelper do
  describe '#render_dropdown?' do
    context 'when the field has explicit list options' do
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

      it 'returns false for a field with no matching options' do
        assign(:field_options, { 'Risk' => %w[High Medium Low] })
        expect(helper.render_dropdown?('Status', 'Open')).to be_falsey
      end
    end

    context 'when the field has no explicit list options' do
      it 'returns false when the value is not pipe-separated' do
        assign(:allow_dropdown, true)
        expect(helper.render_dropdown?('OS', 'Linux')).to eq(false)
      end

      it 'returns false when dropdowns are not allowed, even if pipe-separated' do
        assign(:allow_dropdown, false)
        expect(helper.render_dropdown?('OS', 'Linux | OSX | Windows')).to eq(false)
      end

      it 'returns true when dropdowns are allowed and the value is pipe-separated' do
        assign(:allow_dropdown, true)
        expect(helper.render_dropdown?('OS', 'Linux | OSX | Windows')).to eq(true)
      end

      it 'returns false when the pipe-separated value contains Liquid filters' do
        assign(:allow_dropdown, true)
        expect(helper.render_dropdown?('OS', "{{ os | join: ' | ' }}")).to eq(false)
      end
    end
  end

  describe '#dropdown_options' do
    it 'returns the explicit list options for the given field, when present' do
      assign(:field_options, { 'Risk' => %w[High Medium Low] })
      expect(helper.dropdown_options('Risk', 'High')).to eq(%w[High Medium Low])
    end

    it 'falls back to splitting the value on pipes, when no explicit options exist' do
      expect(helper.dropdown_options('OS', 'Linux | OSX | Windows')).to eq(['Linux', 'OSX', 'Windows'])
    end
  end
end
