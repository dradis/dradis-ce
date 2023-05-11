shared_examples 'liquid dynamic content' do |item_type, node_association|
  let(:item) { create(item_type, content: "#[Title]#\nTitle\n\n#[Description]#\nLiquid: {{#{item_type}.fields['Title']}}") }

  if node_association
    it 'dynamically renders item properties' do
      visit polymorphic_path([current_project, item.node, item])
      expect(find('.note-text-inner')).to have_content("Liquid: #{item.fields["Title"]}")
      expect(find('.note-text-inner')).not_to have_content("Liquid: {{#{item_type}.fields['Title']}}")
    end
  else
    it 'dynamically renders item properties' do
      visit polymorphic_path([current_project, item])
      expect(find('.note-text-inner')).to have_content("Liquid: #{item.fields["Title"]}")
      expect(find('.note-text-inner')).not_to have_content("Liquid: {{#{item_type}.fields['Title']}}")
    end
  end
end
