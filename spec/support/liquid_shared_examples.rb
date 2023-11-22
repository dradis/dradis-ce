shared_examples 'liquid dynamic content' do |item_type, node_association|

  before do
    @path = node_association ?
      polymorphic_path([current_project, record.node, record]) : polymorphic_path([current_project, record])
    visit @path
  end

  it 'dynamically renders item properties' do
    expect(find('.note-text-inner')).to have_content("Liquid: #{record.title}")
    expect(find('.note-text-inner')).not_to have_content("Liquid: {{#{item_type}.title}}")
  end
end

shared_examples 'liquid preview' do |item_type, node_association|

  before do
    @path = node_association ?
      polymorphic_path([:edit, current_project, record.node, record]) : polymorphic_path([:edit, current_project, record])
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
