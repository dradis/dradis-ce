require 'rails_helper'

describe 'tags CRUD' do

  before(:each) do
    login_to_project_as_user
    @tag = create(:tag, name: "!2c0863_test1")
    @tag2 = create(:tag, name: "!00eeff_test2")
  end

  describe 'tags index page' do
    before(:each) do
      visit project_tags_path(current_project)
    end

    it 'shows all tags' do
      expect(page).to have_content(@tag.display_name)
      expect(page).to have_content(@tag2.display_name)
    end

    describe "clicking \'delete\'", js: true do
      let(:submit_form) do
        page.accept_confirm do
          within('.actions', match: :first) do
            find('.dots-dropdown').click
            click_link 'Delete'
          end
        end
        expect(page).to have_text "Tag deleted."
      end

      it 'deletes the Tag' do
        id = @tag.id
        submit_form
        expect(Tag.exists?(id)).to be false
      end
    end

    describe "clicking \'edit\'", js: true do
      let(:open_form) do
        within('.actions', match: :first) do
          find('.dots-dropdown').click
          click_link 'Edit'
        end
      end

      it 'edits the Tag' do
        open_form
        expect(page).to have_field :tag_name
        expect(page).to have_field :tag_color

        fill_in :tag_name, with: "testTag"
        click_button "Update"

        expect(Tag.first.display_name).to eq('Testtag')
      end

    end
  end

  describe 'issues index page', js: true do
    context 'with issue library' do
      let(:issuelib) { current_project.issue_library }

      it 'presents a link for adding a new tag' do
        list = ['Directory listings', 'Out-of-date Apache', 'Clear-text protocols']
        list.each do |title|
          issuelib.notes.create(
            category: Category.issue,
            author: 'rspec',
            text: "#[Title]#\n#{title}\n\n#[Description]#\nFoobar\n\n"
          )
        end

        visit project_issues_path(current_project)

        page.find('td.select-checkbox', match: :first).click
        click_button('Tag')
        within '.dt-button-collection' do
          click_link('Add new tag')
        end

        expect(page).to have_field :tag_name
        expect(page).to have_field :tag_color

        fill_in :tag_name, with: "tag1"
        fill_in :tag_color, with: "abc123"

        click_button "Create"
        expect(page).to have_text("Tag created")

        page.find('td.select-checkbox', match: :first).click
        click_button('Tag')
        within '.dt-button-collection' do
          expect(page).to have_link('Tag1')
        end
      end
    end
  end
end
