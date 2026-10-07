shared_examples 'a tab strip with memory' do
  it 'renders the controller with the expected storage key and Bootstrap tabs' do
    visit tab_memory_path

    selector = "[data-controller~='tab-memory'][data-local-storage-key='#{tab_memory_key}']"
    expect(page).to have_css(selector, count: 1, visible: :all)
    within(selector) do
      expect(page).to have_css('[data-bs-toggle="tab"]', visible: :all)
    end
  end
end
