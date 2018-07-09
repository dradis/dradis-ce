require 'rails_helper'

RSpec.describe 'Issues pages' do
  let(:issuelib) do
    # Node.set_project_scope(@project.id)
    Node.issue_library
  end

  before do
    login_to_project_as_user
    @issue = issuelib.notes.create(
      category: Category.issue,
      author: 'rspec',
      text: "#[Title]#\nMultiple Apache bugs\n\n",
      node: create(:node, :with_project)
    )
    # @issue is currently loaded as a Note, not an Issue. Make sure it
    # has the right class: FIXME - ISSUE/NOTE INHERITANCE
    @issue = Issue.find(@issue.id)
    extra_setup
    create_activities
    create_comments
    visit project_issue_path(@project, @issue)
  end

  # No-op by default; override when needed (e.g. in shared examples)
  let(:create_activities) { nil }
  let(:create_comments) { nil }
  let(:extra_setup) { nil }

  context 'when there are host nodes with evidence' do
    let(:extra_setup) do
      host1 = create(:node, label: '10.0.0.1', type_id: Node::Types::HOST)
      host1.evidence.create(
        author: 'rspec',
        issue_id: @issue.id,
        content: "#[EvidenceBlock1]#\nThis apache is old!"
      )

      host2 = create(:node, label: '10.0.0.2', type_id: Node::Types::HOST)
      3.times do |i|
        host2.evidence.create(
          author: 'rspec',
          issue_id: @issue.id,
          content: "#[EvidenceBlock1]#\nThis apache is old (#{i})!"
        )
      end
    end

    it 'presents the list of hosts affected by a given issue'  do
      expect(find('.secondary-navbar-content')).to have_content('10.0.0.1')
      expect(find('.secondary-navbar-content')).to have_content('10.0.0.2 (3)')
    end

    it 'presents the evidence of the first node' do
      expect(page).to have_content('This apache is old!')
    end

    it 'presents the evidence of the other nodes on click', js: true do
      skip "enable when we move out from PhantomJS and support js 'fetch'"
      click_link 'Evidence'
      click_link '10.0.0.2 (3)'
      expect(page).to have_content('This apache is old (0)!')
    end
  end

  let(:trackable) { @issue }
  it_behaves_like 'a page with an activity feed'

  let(:commentable) { @issue }
  it_behaves_like "a page with a comments feed"

  describe "clicking 'delete'" do
    before { visit project_issue_path(@project, @issue) }

    let(:submit_form) { within('.note-text-inner') { click_link 'Delete' } }

    it 'deletes the issue' do
      id = @issue.id
      submit_form
      expect(Issue.exists?(id)).to be false
    end

    let(:model) { @issue }
    include_examples 'creates an Activity', :destroy

    include_examples 'deleted item is listed in Trash', :issue
    include_examples 'recover deleted item', :issue
  end

  describe 'add evidence', js: true do
    before do
      @node = Node.create!(label: '192.168.0.1')
      visit project_issue_path(@project, @issue)
      click_link('Evidence')
    end

    it 'displays evidence form when add link clicked' do
      expect(page).to have_selector('#js-add-evidence-container', visible: false)
      find('.js-add-evidence').click
      expect(page).to have_selector('#js-add-evidence-container', visible: true)
    end

    it 'filters nodes' do
      find('.js-add-evidence').click
      expect(all('#existing-node-list label').count).to be Node.user_nodes.count

      # find('#evidence_node').native.send_key('192')
      fill_in 'evidence_node', with: '192'

      expect(all('#existing-node-list label').count).to eq 1
    end

    it 'creates an evidence with the selected template for selected node' do
      find('.js-add-evidence').click
      check('192.168.0.1')
      select('Basic Fields', from: 'evidence_content')
      expect { click_button('Save Evidence') }.to change { Evidence.count }.by(1)
      evidence = Evidence.last
      expect(evidence.content).to eq(NoteTemplate.find('basic_fields').content.gsub("\n", "\r\n"))
      expect(evidence.node.label).to eq('192.168.0.1')
    end

    it 'creates an evidence for new nodes and existing nodes too' do
      find('.js-add-evidence').click
      fill_in 'Paste list of nodes', with: "192.168.0.1\r\n192.168.0.2\r\n192.168.0.3"
      expect { click_button('Save Evidence') }.to change { Evidence.count }.by(3).and change { Node.count }.by(2)

      # New nodes don't have a parent:
      Node.order('created_at ASC').last(2).each do |node|
        expect(node.parent).to be_nil
      end
    end

    specify 'new nodes can be assigned to a parent node' do
      find('.js-add-evidence').click
      select @node.label, from: 'Create new nodes under'
      fill_in 'Paste list of nodes', with: "aaaa\nbbbb\ncccc"
      expect { click_button('Save Evidence') }.to change { @node.children.count }.by(3)
    end
  end
end
