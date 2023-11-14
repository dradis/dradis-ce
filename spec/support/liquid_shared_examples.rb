shared_examples 'liquid dynamic content' do |item_type, node_association|
  before do
    @issue = create(:issue, project: current_project)
    @node = create(:node, project: current_path)
    @note = create(:note, node: @node)
    @evidence = create(:evidence, node: @node, issue: @issue)
    create(:tag, project: current_project)

    record.content = record.content + "\n" +
      "{% for issue in issues %}{{ issue.fields['Title'] }}, {% endfor %}\n" \
      "{% for note in notes %}{{ note.fields['Title'] }}, {% endfor %}\n" \
      "{% for node in nodes %}{{ node.label }}, {% endfor %}\n" \
      "{% for e in evidence %}{{ e.fields['EvidenceBlock1'] }}, {% endfor %}\n" \
      "{% for tag in tags %}{{ tag.name }}, {% endfor %}\n" \

    record.save
  end

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

  it 'renders drops for project-related output' do
    visit polymorphic_path([current_project, record])
    current_project.issues.each do |issue|
      expect(find('.note-text-inner')).to have_content(issue.title)
    end
    current_project.notes.each do |note|
      expect(find('.note-text-inner')).to have_content(note.title)
    end
    current_project.nodes.each do |node|
      expect(find('.note-text-inner')).to have_content(node.label)
    end
    current_project.evidence.each do |evidence|
      expect(find('.note-text-inner')).to have_content(evidence.fields['EvidenceBlock1'])
    end
    current_project.tags.each do |tag|
      expect(find('.note-text-inner')).to have_content(tag.name)
    end
  end
end
