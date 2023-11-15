shared_examples 'liquid dynamic content' do |item_type, node_association|
  before do
    issue = create(:issue, project: current_project)
    node = create(:node, project: current_project)
    create(:note, node: node)
    @liquid_evidence = create(:evidence, node: node, issue: issue)
    create(:tag, project: current_project)

    record.content = record.content + "\n" +
      "{% for issue in issues %}{{ issue.title }}, {% endfor %}\n" \
      "{% for node in nodes %}{{ node.label }}, {% endfor %}\n" \
      "{% for e in evidences %}{{ e.fields['EvidenceBlock1'] }}, {% endfor %}\n" \
      "{% for tag in tags %}{{ tag.name }}, {% endfor %}\n" \

    record.save

    @path =
      if node_association
        polymorphic_path([current_project, record.node, record])
      else
        polymorphic_path([current_project, record])
      end
  end

  it 'dynamically renders item properties' do
    visit @path
    expect(find('.note-text-inner')).to have_content("Liquid: #{record.fields["Title"]}")
    expect(find('.note-text-inner')).not_to have_content("Liquid: {{#{item_type}.fields['Title']}}")
  end

  it 'renders drops for project-related output' do
    visit @path
    current_project.issues.each do |issue|
      expect(find('.note-text-inner')).to have_content(issue.title)
    end
    current_project.nodes.user_nodes.each do |node|
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
