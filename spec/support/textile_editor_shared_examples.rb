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

shared_examples 'a textile form view' do
  before do
    visit action_path
  end

  it 'add fields in the form', js: true do
    within '.textile-form' do
      click_link 'Add field'
    end

    expect(find('[name="item_form[field_name_1]"]')).to_not be nil
    expect(all('.textile-form-field').count).to eq(2)
  end

  it 'remove fields in the form', js: true do
    within '.textile-form-field' do
      click_link 'Delete'
    end
    expect(all('.textile-form-field').count).to eq(0)
  end

  it 'updates the item when submitted', js: true do
    fill_in('item_form[field_name_0]', with: 'Title')
    fill_in('item_form[field_value_0]', with: 'Test Issue')

    find('input[type="submit"]').click

    expect(Issue.last.text).to eq("#[Title]#\nTest Issue")
  end
end
