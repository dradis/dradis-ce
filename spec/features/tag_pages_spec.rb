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
    end
  end
end
