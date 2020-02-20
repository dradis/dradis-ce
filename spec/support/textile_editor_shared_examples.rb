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
