shared_examples "a form with a help button" do
  describe "clicking the 'help' button", js: true do
    before { find("form .btn-help").click }
    it "displays Textile help" do
      expect(page).to have_selector "h3", text: "Text styles"
      expect(page).to have_selector "h3", text: "Block Code (bc.)"
      expect(page).to have_selector "h3", text: "Lists"
      expect(page).to have_selector "h3", text: "Miscellaneous"
      expect(page).to have_selector "h3", text: "Further help"
    end
  end
end
