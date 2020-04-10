shared_examples 'a form with a help button' do
  describe "clicking the 'help' button", js: true do
    before { find('form .btn-help').click }
    it 'displays Textile help' do
      expect(page).to have_selector 'h5', text: /Text styles/i
      expect(page).to have_selector 'h5', text: /Block Code \(bc.\)/i
      expect(page).to have_selector 'h5', text: /Lists/i
      expect(page).to have_selector 'h5', text: /Miscellaneous/i
      expect(page).to have_selector 'h5', text: /Further help/i
    end
  end
end

shared_examples 'a textile form view' do |klass|
  before do
    visit action_path

    required_form if defined?(required_form)
  end

  it 'add fields in the form', js: true do
    current_field_count = all('.textile-form-field').count

    within '.textile-form' do
      click_link 'Add field'
    end

    expect(page).to have_css('.textile-form-field', count: current_field_count + 1)
  end

  it 'remove fields in the form', js: true do
    expect {
      find('[data-behavior=textile-form-field]', match: :first).hover
      within '[data-behavior~=textile-form-field]', match: :first do
        click_link 'Delete'
      end
    }.to change{ all('.textile-form-field').count }.by(-1)
  end

  it 'saves the item when submitted', js: true do
    fill_in('item_form[field_name_0]', with: 'Title')
    fill_in('item_form[field_value_0]', with: 'Test Item')

    within '.form-actions' do
      find('[type="submit"]').click
    end

    updated_item = defined?(item) ? item : klass.last

    if klass == Evidence || klass == Note
      show_path = [current_project, updated_item.node, updated_item]
      content_attribute = :content
    elsif klass == Issue
      show_path = [current_project, updated_item]
      content_attribute = :text
    elsif klass == Card
      show_path = [current_project, updated_item.list.board, updated_item.list, updated_item]
      content_attribute = :description
    end

    expect(page).to have_current_path(polymorphic_path(show_path), ignore_query: true)
    expect(updated_item.reload.send(content_attribute)).to include("#[Title]#\nTest Item")
  end
end
