shared_examples 'liquid dynamic content' do |item_type, node_association|

  before do
    @path = if node_association
      polymorphic_path([current_project, record.node, record])
    else
      polymorphic_path([current_project, record])
    end
    visit @path
  end

  it 'dynamically renders item properties', js: true do
    expect(page).to have_no_css('span.text-nowrap', text: 'Loading liquid dynamic content', wait: 10)

    expect(find('.note-text-inner')).to have_content("Liquid: #{record.title}")
    expect(find('.note-text-inner')).not_to have_content("Liquid: {{#{item_type}.title}}")
  end
end

shared_examples 'liquid preview' do |item_type, node_association|
  before do
    @path = if node_association
      polymorphic_path([:edit, current_project, record.node, record])
    else
      polymorphic_path([:edit, current_project, record])
    end
    visit @path
    click_link 'Source'
  end

  it 'renders project-level liquid content in the editor preview' do
    expect(find('.note-text-inner')).to have_content("Project: #{current_project.name}")
  end

  it 'renders record-specific liquid content in the editor preview' do
    expect(find('.note-text-inner')).to have_content("Liquid: #{record.title}")
  end
end
