require 'rails_helper'

describe FieldsHelper do
  describe '#dropdown_options' do
    context 'when the field has explicit list options' do
      it 'returns the options when the value is blank' do
        assign(:field_values, { 'Risk' => %w[High Medium Low] })
        expect(helper.dropdown_options('Risk', '')).to eq(%w[High Medium Low])
      end

      it 'returns the options when the value matches one of them' do
        assign(:field_values, { 'Risk' => %w[High Medium Low] })
        expect(helper.dropdown_options('Risk', 'High')).to eq(%w[High Medium Low])
      end

      it 'returns nil when the value does not match any of the options' do
        assign(:field_values, { 'Risk' => %w[High Medium Low] })
        expect(helper.dropdown_options('Risk', '{{ issue.risk }}')).to be_nil
      end

      it 'falls back to the pipe-value check for a different field with no explicit options' do
        assign(:field_values, { 'Risk' => %w[High Medium Low] })
        expect(helper.dropdown_options('Status', 'Open | Closed')).to eq(['Open', 'Closed'])
      end
    end

    context 'when the field has no explicit list options' do
      it 'returns nil when the value is not pipe-separated' do
        expect(helper.dropdown_options('OS', 'Linux')).to be_nil
      end

      it 'returns the split values when the value is pipe-separated' do
        expect(helper.dropdown_options('OS', 'Linux | OSX | Windows')).to eq(['Linux', 'OSX', 'Windows'])
      end

      it 'returns nil when the pipe-separated value contains Liquid filters' do
        expect(helper.dropdown_options('OS', "{{ os | join: ' | ' }}")).to be_nil
      end
    end
  end
end
