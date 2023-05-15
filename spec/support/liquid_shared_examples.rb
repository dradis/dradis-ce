shared_examples 'liquid dynamic content' do |item_type, node_association|

  if node_association
    it 'dynamically renders item properties' do
      visit polymorphic_path([current_project, record.node, record])
      expect(find('.note-text-inner')).to have_content("Liquid: #{record.fields["Title"]}")
      expect(find('.note-text-inner')).not_to have_content("Liquid: {{#{item_type}.fields['Title']}}")
    end
  else
    it 'dynamically renders item properties' do
      visit polymorphic_path([current_project, record])
      expect(find('.note-text-inner')).to have_content("Liquid: #{record.fields["Title"]}")
      expect(find('.note-text-inner')).not_to have_content("Liquid: {{#{item_type}.fields['Title']}}")
    end
  end
end
