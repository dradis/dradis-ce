require 'rails_helper'

describe 'Issues pages' do
  subject { page }

  it 'should require authenticated users' do
    Configuration.create(name: 'admin:password', value: 'rspec_pass')
    visit project_issues_path(project_id: 1)
    expect(current_path).to eq(login_path)
    expect(page).to have_content('Access denied.')
  end

  context 'as authenticated user' do

    before { login_to_project_as_user }

    context 'with an Issue library' do
      let(:issuelib) { current_project.issue_library }

      describe 'index page' do
        it 'presents a link to add new issue' do
          visit project_issues_path(current_project)
          expect(page).to have_xpath("//a[@href='#{new_project_issue_path(current_project)}']")
        end

        it 'shows an *empty list* message if none have been assigned' do
          visit project_issues_path(current_project)
          expect(current_path).to eq(project_issues_path(current_project))
          expect(page).to have_content('nothing yet')
        end

        it 'presents a list of all existing issues in the library' do
          list = ['Directory listings', 'Out-of-date Apache', 'Clear-text protocols']
          list.each do |title|
            issuelib.notes.create(
              category: Category.issue,
              author: 'rspec',
              text: "#[Title]#\n#{title}\n\n#[Description]#\nFoobar\n\n"
            )
          end

          visit project_issues_path(current_project)
          expect(current_path).to eq(project_issues_path(current_project))
          list.each do |title|
            expect(page).to have_content(title)
          end
        end

      end

      describe 'merge page', js: true do

        before do
          # create 2 issues
          create(:issue, node: current_project.issue_library)
          create(:issue, node: current_project.issue_library)

          visit project_issues_path(current_project)

          # click > 1 issue checkboxes
          page.all('input.js-multicheck').each(&:click)

          # click the merge button
          find('#merge-selected').click
        end

        it 'merges issues into an existing one' do
          expect(page).to have_content "You're merging 2 Issues into a target Issue"

          click_button 'Merge issues'

          expect(page).to have_content('1 issue merged into ')
        end

        it 'merges issues into a new one' do
          expect(page).to have_content "You're merging 2 Issues into a target Issue"

          # new issue form should not be visible yet
          expect(page).to have_selector('#new_issue', visible: false)

          choose('Merge into a new issue')

          # new issue form should be visible now
          expect(page).to have_selector('#new_issue', visible: true)

          # click button like this because the button may be moving down
          # due to bootstrap accordion unfold transition
          find_button('Merge issues').trigger('click') # click_button "Merge issues"

          expect(page).to have_content('2 issues merged into ')

          expect(Issue.last.author).to eq(@logged_in_as.email)
        end

        let(:submit_form) {
          click_button 'Merge issues'
        }
        include_examples 'deleted item is listed in Trash', :issue
      end

      describe 'new page' do
        let(:submit_form) { click_button 'Create Issue' }

        context 'submitting the form with valid information' do
          before do
            visit new_project_issue_path(current_project)
            fill_in :issue_text,
              with: "#[Title]#\nRspec issue\n\n#[Description]#\nNew description\n\n"
          end

          it 'creates a new Issue under the Issue library with the right Category and Author'  do
            expect { submit_form }.to change { current_project.issues.count }.by(1)
            issue = current_project.issues.last
            expect(current_path).to eq(project_issue_path(current_project, issue))
            expect(page).to have_content('Rspec issue')

            expect(issue.category).to eq(Category.issue)
            expect(issue.author).to eq(@logged_in_as.email)
          end

          include_examples 'creates an Activity', :create, Issue

        end

        context 'submitting the form with invalid information' do
          before do
            visit new_project_issue_path(current_project)
            fill_in :issue_text, with: 'a' * 65536
          end

          it "doesn't create a new Issue" do
            expect { submit_form }.not_to change { current_project.issues.count }
          end

          include_examples "doesn't create an Activity"

          it 'shows the form again with an error message' do
            submit_form
            should have_field :issue_text
            should have_selector '.alert.alert-error'
          end
        end

        context 'when passed a note template' do
          it 'preloads the editor with the template' do
            template_path = Rails.root.join('spec/fixtures/files/note_templates/')
            allow(NoteTemplate).to receive(:pwd).and_return(template_path)

            template_content = File.read(template_path.join('simple_note.txt'))
            visit new_project_issue_path(current_project, template: 'simple_note')

            expect(find_field('issue[text]').value).to include(template_content)
          end
        end

        context 'when the issue has a Tags field' do
          it 'tags the issue with the corresponding tag if only one is present' do
            tag_field = '!f89406_private'
            visit new_project_issue_path(current_project)
            fill_in :issue_text,
              with: "#[Title]#\nRspec issue\n\n#[Tags]#\n#{tag_field}\n\n"

            expect { submit_form }.to change { current_project.issues.count }.by(1)
            issue = current_project.issues.last
            expect(issue.tags.count).to eq(1)
            expect(issue.tag_list).to eq(tag_field)
          end

          it 'tags the issue with the first tag if more than one are present' do
            tag_field = '!f89406_private, !468847_public'
            visit new_project_issue_path(current_project)
            fill_in :issue_text,
              with: "#[Title]#\nRspec issue\n\n#[Tags]#\n#{tag_field}\n\n"

            expect { submit_form }.to change { current_project.issues.count }.by(1)
            issue = current_project.issues.last
            expect(issue.tags.count).to eq(1)
            expect(issue.tag_list).to eq(tag_field.split(', ').first)
          end
        end
      end

      describe 'edit page' do
        let(:submit_form) { click_button 'Update Issue' }

        before do
          issuelib = current_project.issue_library
          @issue = create(:issue, node: issuelib, updated_at: 2.seconds.ago)
          visit edit_project_issue_path(current_project, @issue)
        end

        describe 'submitting the form with valid information' do
          let(:new_content) { 'New info' }
          before { fill_in :issue_text, with: new_content }

          let(:submit_form) { click_button 'Update Issue' }

          it 'updates and shows the issue' do
            submit_form
            expect(@issue.reload.text).to eq new_content
            expect(current_path).to eq project_issue_path(current_project, @issue)
          end

          let(:model) { @issue }
          include_examples 'creates an Activity', :update

          it "creates a version with the user's email as 'whodunnit'" do
            with_versioning do
              submit_form
              expect(@issue.reload.versions.last.whodunnit).to eq @logged_in_as.email
            end
          end

          let(:column) { :text }
          let(:record) { @issue }
          it_behaves_like 'a page which handles edit conflicts'
        end

        describe 'submitting the form with invalid information' do
          before { fill_in :issue_text, with: 'a' * 65536 }

          it "doesn't update the issue" do
            expect { submit_form }.not_to change { @issue.reload.text }
          end

          include_examples "doesn't create an Activity"

          it 'shows the form again with an error message' do
            submit_form
            should have_field :issue_text
            should have_selector '.alert.alert-error'
          end
        end
      end

      describe 'show page' do
        before do
          @issue = issuelib.notes.create(
            category: Category.issue,
            author: 'rspec',
            text: "#[Title]#\nMultiple Apache bugs\n\n",
            node: create(:node, :with_project)
          )
          # @issue is currently loaded as a Note, not an Issue. Make sure it
          # has the right class:
          @issue = Issue.find(@issue.id)
          extra_setup
          visit project_issue_path(current_project, @issue)
        end

        let(:extra_setup) do
          create_activities
          create_comments
        end
        let(:create_activities) { nil }
        let(:create_comments) { nil }

        context 'when there are host nodes with evidence' do
          let(:extra_setup) do
            host1 = create(:node, label: '10.0.0.1', project: current_project, type_id: Node::Types::HOST)
            host1.evidence.create(
              author: 'rspec',
              issue_id: @issue.id,
              content: "#[EvidenceBlock1]#\nThis apache is old!"
            )

            host2 = create(:node, label: '10.0.0.2', project: current_project, type_id: Node::Types::HOST)
            3.times do |i|
              host2.evidence.create(
                author: 'rspec',
                issue_id: @issue.id,
                content: "#[EvidenceBlock1]#\nThis apache is old (#{i})!",
                node: create(:node, project: current_project)
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
        it_behaves_like 'a page with a comments feed'

        let(:subscribable) { @issue }
        it_behaves_like 'a page with subscribe/unsubscribe links'

        describe "clicking 'delete'" do
          before { visit project_issue_path(current_project, @issue) }

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
            @node = current_project.nodes.create!(label: '192.168.0.1')
            visit project_issue_path(current_project, @issue)
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

            # find('#evidence_node').native.send_key('192.')
            fill_in 'evidence_node', with: '192\.'

            expect(all('#existing-node-list label').count).to eq 1
          end

          it 'creates an evidence with the selected template for selected node' do
            find('.js-add-evidence').click
            check('192.168.0.1')
            select('Basic Fields', from: 'evidence_content')
            expect { click_button('Save Evidence') }.to change { Evidence.count }.by(1)
            evidence = Evidence.last
            expect(evidence.content).to eq(NoteTemplate.find('basic_fields').content.gsub("\n", "\r\n"))
            expect(evidence.node.label).to eq '192.168.0.1'
          end

          it 'creates an evidence for new nodes and existing nodes too' do
            find('.js-add-evidence').click
            fill_in 'Paste list of nodes', with: "192.168.0.1\r\n192.168.0.2\r\n192.168.0.3"
            expect { click_button('Save Evidence') }.to change { Evidence.count }.by(3).and change { Node.count }.by(2)

            # New nodes don't have a parent:
            current_project.nodes.order('created_at ASC').last(2).each do |node|
              expect(node.parent).to be_nil
            end
          end

          it 'assigns new nodes to the right parent' do
            find('.js-add-evidence').click
            fill_in 'Paste list of nodes', with: "#{@node.label}\r\naaaa"
            select @node.label, from: 'Create new nodes under'
            expect do
              click_button('Save Evidence')
            end.to change { Evidence.count }.by(2).and change { Node.count }.by(1)

            # bug fix: existing nodes don't have their parent changed
            expect(@node.reload.parent).to be_nil # bug fix
            new_node = current_project.nodes.find_by!(label: 'aaaa')
            expect(new_node.parent).to eq @node
          end
        end
      end
    end
  end
end
