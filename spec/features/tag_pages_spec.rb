require 'rails_helper'

describe 'Tag pages' do
  subject {page}

  context 'as authenticated user' do
    before { login_to_project_as_user }

    describe "index page" do
      it 'presents a list of all existing tags in the library' do
        tags = create_list(:tag, 3)
        visit project_tags_path(current_project)
        expect(current_path).to eq(project_tags_path(current_project))
        tags.each do |tag|
          expect(page).to have_content(tag.display_name)
        end
      end

      it 'presents a link to add a new tag' do
        visit project_tags_path(current_project)
        expect(page).to have_xpath("//a[@href='#{new_project_tag_path(current_project)}']")
      end
    end

    describe "new page" do
      let(:submit_form) { click_button 'Create Tag' }

      before do
        visit new_project_tag_path(current_project)
      end

      it 'presents a form to create a new tag' do
        visit new_project_tag_path(current_project)
        expect(current_path).to eq(new_project_tag_path(current_project))
        expect(page).to have_field(:tag_name)
        expect(page).to have_field(:color)
      end

      context 'submitting the form with valid information' do
        it 'creates a new tag and returns to the tags index' do
          fill_in :tag_name, with: 'Awesome'
          fill_in :color, with: '#123456'
          expect { submit_form }.to change { Tag.count }.by(1)
          expect(current_path).to eq(project_tags_path(current_project))
          expect(page).to have_content('Tag created')
          expect(page).to have_content('Awesome')
        end
      end

      context 'submitting the form with invalid information' do
        it 'does not create a new tag, and returns an error message' do
          expect { submit_form }.to change { Tag.count }.by(1)
          expect(current_path).to eq(new_project_tag_path(current_project))
          expect(page).to have_content('Tag created')
          expect(page).to have_content('Awesome')
        end
      end
    end
  end
end
