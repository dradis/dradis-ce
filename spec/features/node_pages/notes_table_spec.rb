require 'rails_helper'

describe 'node pages' do
  describe '#show notes table' do
    subject { page }

    before do
      login_to_project_as_user

      node = create(:node)
      @note = create(:note, node: node, text: "#[Title]#\nNote1\n\n#[Description]#\nn/a\n#[Extra]#\nExtra field")
      visit node_path(node, tab: 'notes-tab')
    end

    it 'displays column controls for Title, Created, Created by, Updated' do

      # Prime the element's text, as it is hidden by default
      find('.js-table-columns', visible: false).text(:all)

      expect(find('.js-table-columns', visible: false)).to have_text('Title')
      expect(find('.js-table-columns', visible: false)).to have_text('Created')
      expect(find('.js-table-columns', visible: false)).to have_text('Created by')
      expect(find('.js-table-columns', visible: false)).to have_text('Updated')
    end

    it 'displays custom columns based on Issue content' do
      # Prime the element's text, as it is hidden by default
      find('.js-table-columns', visible: false).text(:all)

      expect(@note.fields.keys).to include('Description', 'Extra')
      @note.fields.keys.each do |column|
        expect(find('.js-table-columns', visible: false)).to have_text(column)
      end
    end
  end
end
