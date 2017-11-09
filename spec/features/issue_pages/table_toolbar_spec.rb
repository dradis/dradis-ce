require 'rails_helper'

describe 'issue table' do

  describe 'toolbar', js: true do
    subject { page }

    before do
      login_to_project_as_user

      @issue1 = create(:issue, text: "#[Title]#\r\ntest1\r\n\r\n#[Description]#\r\nnone1\r\n")
      @issue2 = create(:issue, text: "#[Title]#\r\ntest2\r\n\r\n#[Description]#\r\nnone2\r\n")

      visit issues_path
    end

    context 'when Select All is clicked' do
      before do
        find('.js-index-table-select-all').click
      end

      it 'selects all issues' do
        all('input[type=checkbox].js-multicheck').each do |el|
          expect(el['checked']).to be true
        end
      end

      it 'shows the issue actions bar' do
        expect(find('.js-index-table-actions')).to be_visible
      end
    end

    context 'when clicking issues' do
      it 'displays action buttons (delete, tag ...) if 1 issue is clicked' do
        expect(find('.js-index-table-actions', visible: :all)).to_not be_visible
        check "checkbox_issue_#{@issue1.id}"
        expect(find('.js-index-table-actions')).to be_visible
      end

      it 'displays merge button if more than 1 issues clicked' do
        check "checkbox_issue_#{@issue1.id}"
        expect(page).to have_selector('#merge-selected', visible: false)
        check "checkbox_issue_#{@issue2.id}"
        expect(page).to have_selector('#merge-selected', visible: true)
      end

      it 'resets toolbar after applying tags' do
        check "checkbox_issue_#{@issue1.id}"
        expect(page).to have_css('.js-index-table-actions')
        find('#tag-selected').click
        find('a[data-tag="!6baed6_low"]').click
        expect(page).to_not have_css('.js-index-table-actions')
        @issue1.reload
        expect(@issue1.tags.first.name).to eq '!6baed6_low'
      end

      it 'resets toolbar after deleting issues' do
        check "checkbox_issue_#{@issue1.id}"
        expect(page).to have_css('.js-index-table-actions')
        find('#delete-selected').click
        expect(page).to_not have_css('.js-index-table-actions')
        expect(Issue.exists?(@issue1.id)).to be false
      end
    end

    context 'when filtering issues' do
      it 'does not delete filtered issues' do
        find('.js-table-filter').set('1')
        expect(page).to have_selector("#issue_#{@issue2.id}_link", visible: false)
        find('#select-all').click
        find('#delete-selected').click
        expect(page).to_not have_selector("#checkbox_issue_#{@issue1.id}")
        expect(Issue.exists?(@issue1.id)).to be false
        expect(Issue.exists?(@issue2.id)).to be true
      end
    end

    context 'when deleting issues' do
      it 'successfully deletes multiple issues' do
        find('#select-all').click
        find('#delete-selected').click
        expect(page).to_not have_selector("#issue_#{@issue1.id}_link")
        expect(Issue.exists?(@issue1.id)).to be false
        expect(Issue.exists?(@issue2.id)).to be false
      end
    end
  end
end
