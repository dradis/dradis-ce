require 'rails_helper'

describe 'Tag pages:' do
  subject { page }

  before do
    login_to_project_as_user
  end

  describe '#index', js: true do
    before do
      visit project_tags_path(current_project)
    end

    context 'without exisiting tags' do
      it 'renders empty state' do
        expect(page).to have_content('There are no tags created yet.')
      end
    end

    context 'with exisiting tags' do
      let!(:tags) { create_list(:tag, 3) }

      it 'renders new tag page when new tag button is clicked' do
        click_link 'New Tag'
        expect(current_path).to eq(new_project_tag_path(current_project))
      end
  
      it 'renders all tags' do
        tags.each do |tag|
          expect(page).to have_selector('tr', id: "tag-#{tag.id}")
        end
      end
  
      it 'renders actions' do
        expect(page).to have_selector('td.column-actions')
        expect(page).to have_selector('tr', text: 'Edit')
        expect(page).to have_selector('tr', text: 'Delete')
      end
  
      it 'renders edit tag page when new tag button is clicked' do
        page.find("tr#tag-#{tags.first.id}").click_link('Edit')
        expect(current_path).to eq(edit_project_tag_path(current_project, tags.first))
      end
  
      it 'deletes tag when delete button is clicked' do
        expect(Tag.count).to eq(3)
        page.accept_confirm do
          click_link(href: project_tag_path(current_project, tags.first))
        end
        expect(page).to have_content('Tag destroyed')
        expect(Tag.count).to eq(2)
      end
    end
  end

  describe '#new' do
    before do
      visit new_project_tag_path(current_project)
    end

    context 'valid name' do
      it 'creates tag' do
        fill_in :tag_name, with: '!9467bd_critical'
        expect { click_button('Create Tag') }.to change{ Tag.count }.by(1)
        expect(page).to have_content('Tag created')
      end
    end

    context 'invalid name' do
      it 'error occurs' do
        fill_in :tag_name, with: '!9467bd_'
        expect { click_button('Create Tag') }.to_not change{ Tag.count }
        expect(page).to have_content('Name Invalid format. eg !2ca02c_info')
      end
    end
  end

  describe '#edit' do
    let(:tag) { create(:tag) }

    before do
      visit edit_project_tag_path(current_project, tag)
    end

    it 'displays tag name' do
      expect(page).to have_field('Name', with: tag.name)
    end

    it 'updates tag when name is changed' do
      fill_in :tag_name, with: '!9467bd_test'
      expect do
        click_button 'Update Tag'
      end.to change { tag.reload.name }.from('!200abc_test').to('!9467bd_test')
    end
  end
end
