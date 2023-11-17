shared_examples 'liquid dynamic content' do |item_type, node_association|
  subject { page }

  if node_association
    it 'dynamically renders item properties' do
      visit polymorphic_path([current_project, record.node, record])
      should have_content("Liquid: #{record.fields["Title"]}")
      expect(find('.note-text-inner')).not_to have_content("Liquid: {{#{item_type}.fields['Title']}}")
    end
  else
    it 'dynamically renders item properties' do
      visit polymorphic_path([current_project, record])
      should have_content("Liquid: #{record.fields["Title"]}")
      expect(find('.note-text-inner')).not_to have_content("Liquid: {{#{item_type}.fields['Title']}}")
    end
  end
end

shared_examples 'liquid preview' do |item_type, node_association|
  if node_association
    it 'shows liquid content in the editor preview', js: true do
      visit polymorphic_path([:edit, current_project, record.node, record])
      click_link 'Source'
      should have_content("Liquid: #{record.fields["Title"]}")
    end
  else
  end
end
