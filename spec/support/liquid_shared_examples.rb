shared_examples 'liquid dynamic content' do |item_type, node_association|
  subject { page }

  before do
    @path = node_association ?
      polymorphic_path([current_project, record.node, record]) : polymorphic_path([current_project, record])
    visit @path
  end

  it 'dynamically renders item properties' do
    should have_content("Liquid: #{record.title}")
    expect(find('.note-text-inner')).not_to have_content("Liquid: {{#{item_type}.title}}")
  end
end

shared_examples 'liquid preview' do |item_type, node_association|
  subject { page }

  before do
    @path = node_association ?
      polymorphic_path([:edit, current_project, record.node, record]) : polymorphic_path([:edit, current_project, record])
    visit @path
    click_link 'Source'
  end

  describe 'project assigns' do
    it 'shows liquid content in the editor preview', js: true do
      should have_content("Project: #{project.name}")
    end
  end

  describe 'record-specific assigns' do
    it 'shows liquid content in the editor preview', js: true do
      should have_content("Liquid: #{record.title}")
    end
  end
end
