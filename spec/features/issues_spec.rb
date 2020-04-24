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

      describe 'new page', js: true do
        let(:submit_form) { click_button 'Create Issue' }

        let(:action_path) { new_project_issue_path(current_project) }
        it_behaves_like 'a textile form view', Issue

        context 'submitting the form with valid information' do
          before do
            visit new_project_issue_path(current_project)
            click_link 'Source'
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
            click_link 'Source'

            # Manually update the textarea, otherwise we will get a timeout
            execute_script("$('#issue_text').val('#{'a' * 65536}')")
          end

          it "doesn't create a new Issue" do
            expect { submit_form }.not_to change { current_project.issues.count }
          end

          include_examples "doesn't create an Activity"

          it 'shows the form again with an error message' do
            submit_form
            should have_selector '.alert.alert-error'
          end
        end

        context 'when passed a note template', js: true do
          it 'preloads the editor with the template' do
            template_path = Rails.root.join('spec/fixtures/files/note_templates/')
            allow(NoteTemplate).to receive(:pwd).and_return(template_path)

            template_content = File.read(template_path.join('simple_note.txt'))
            visit new_project_issue_path(current_project, template: 'simple_note')

            expect(find_field('item_form[field_name_0]').value).to include('IPAddress')
            expect(find_field('item_form[field_name_1]').value).to include('Hostname')
            expect(find_field('item_form[field_name_2]').value).to include('OS')
            expect(page).to have_select('item_form[field_value_2]')
          end
        end

        context 'when the issue has a Tags field' do
          it 'tags the issue with the corresponding tag if only one is present' do
            tag_field = '!f89406_private'
            visit new_project_issue_path(current_project)
            click_link 'Source'
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
            click_link 'Source'
            fill_in :issue_text,
              with: "#[Title]#\nRspec issue\n\n#[Tags]#\n#{tag_field}\n\n"

            expect { submit_form }.to change { current_project.issues.count }.by(1)
            issue = current_project.issues.last
            expect(issue.tags.count).to eq(1)
            expect(issue.tag_list).to eq(tag_field.split(', ').first)
          end
        end

        describe 'local caching' do
          let(:add_tags) do
            @tag_1 = create(:tag, name: '!9467bd_critical')
            @tag_2 = create(:tag, name: '!d62728_high')
          end

          let(:textarea_content) { 'textarea_content '}
          let(:textarea_content_for_template) { 'textarea_content_for_template '}

          before do
            add_tags
            visit new_project_issue_path(current_project)
            click_link 'Source'
            fill_in :issue_text, with: textarea_content

            no_tag = page.find('.dropdown-toggle span.tag')
            no_tag.click

            click_on @tag_1.display_name
            sleep 1 # Needed for setTimeout function in local_auto_save.js
          end

          context 'when issue is not saved' do
            it 'prefill fields with cached data' do
              visit root_path
              visit new_project_issue_path(current_project)
              click_link 'Source'

              aggregate_failures do
                expect(page.find_field('issue[text]').value).to eq textarea_content
                expect(page).to have_button(@tag_1.display_name)
              end
            end
          end

          context 'when issue is saved' do
            it 'clears cached data' do
              click_button 'Create Issue'
              visit new_project_issue_path(current_project)
              click_link 'Source'

              expect(page.find_field('issue[text]').value).to eq ''
            end
          end

          context 'when "Cancel" link is clicked' do
            it 'clears cached data' do
              click_link 'Cancel'

              visit new_project_issue_path(current_project)
              click_link 'Source'

              expect(page.find_field('issue[text]').value).to eq ''
            end
          end

          context 'with template' do
            before do
              template_path = Rails.root.join('spec/fixtures/files/note_templates/')
              allow(NoteTemplate).to receive(:pwd).and_return(template_path)
            end

            let(:params)  { { template: 'simple_note' } }

            it 'prefills fields with cached data' do
              visit new_project_issue_path(current_project, params)
              click_link 'Source'
              fill_in :issue_text, with: textarea_content_for_template
              sleep 1 # Needed for setTimeout function in local_auto_save.js

              visit root_path
              visit new_project_issue_path(current_project, params)
              click_link 'Source'

              expect(page.find_field('issue[text]').value).to eq textarea_content_for_template
            end

            context 'when blank issue is filled then navigated to new template issue' do
              it 'does not prefill fields with cached data of blank issue' do
                visit new_project_issue_path(current_project, params)
                click_link 'Source'

                expect(page.find_field('issue[text]').value).not_to eq textarea_content
              end
            end

            context 'when template is filled then navigated to new blank issue' do
              it 'does not prefill new blank issue form with template data' do
                visit new_project_issue_path(current_project, params)
                click_link 'Source'
                fill_in :issue_text, with: textarea_content_for_template
                sleep 1 # Needed for setTimeout function in local_auto_save.js

                visit new_project_issue_path(current_project)
                click_link 'Source'

                expect(page.find_field('issue[text]').value).not_to eq textarea_content_for_template
              end
            end
          end
        end
      end

      describe 'edit page', js: true do
        let(:submit_form) { click_button 'Update Issue' }

        let(:action_path) { edit_project_issue_path(current_project, @issue) }
        let(:item) { @issue }
        it_behaves_like 'a textile form view', Issue

        before do
          issuelib = current_project.issue_library
          @issue = create(:issue, node: issuelib, updated_at: 2.seconds.ago)
          visit edit_project_issue_path(current_project, @issue)
          click_link 'Source'
        end

        describe 'submitting the form with valid information' do
          let(:new_content) { "#[Description]#\r\nNew info" }
          before do
            fill_in :issue_text, with: new_content
          end

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

        context 'submitting the form with invalid information' do
          before do
            # Manually update the textarea, otherwise we will get a timeout
            execute_script("$('#issue_text').val('#{'a' * 65536}')")
          end

          it "doesn't update the issue" do
            expect { submit_form }.not_to change { @issue.reload.text }
          end

          include_examples "doesn't create an Activity"

          it 'shows the form again with an error message' do
            submit_form
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
            expect(find('.secondary-sidebar-content')).to have_content('10.0.0.1')
            expect(find('.secondary-sidebar-content')).to have_content('10.0.0.2 (3)')
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

        describe "clicking 'delete'", js: true do
          before { visit project_issue_path(current_project, @issue) }

          let(:submit_form) do
            page.accept_confirm do
              within('.note-text-inner') { click_link "Delete" }
            end
            expect(page).to have_text "Issue deleted." # forces waiting
          end

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

            template_path = Rails.root.join('spec/fixtures/files/note_templates/')
            allow(NoteTemplate).to receive(:pwd).and_return(template_path)

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
            within('#existing-node-list') do
              current_project.nodes.user_nodes.each do |n|
                expect(page).to have_text n.label
              end
            end
            expect(all('#existing-node-list label').count).to be current_project.nodes.user_nodes.count

            # find('#evidence_node').native.send_key('192.')
            fill_in 'evidence_node', with: '192\.'

            expect(all('#existing-node-list label').count).to eq 1
          end

          it 'creates an evidence with the selected template for selected node' do
            find('.js-add-evidence').click
            check('192.168.0.1')
            select('Simple Note', from: 'evidence_content')
            expect { click_button('Save Evidence') }.to change { Evidence.count }.by(1)
            evidence = Evidence.last
            expect(evidence.content).to eq(NoteTemplate.find('simple_note').content.gsub("\n", "\r\n"))
            expect(evidence.node.label).to eq '192.168.0.1'
          end

          it 'creates an evidence for new nodes and existing nodes too' do
            find('.js-add-evidence').click
            fill_in 'Paste list of nodes', with: "192.168.0.1\r\n192.168.0.2\r\n192.168.0.3"
            expect do
              click_button('Save Evidence')
              expect(page).to have_text 'Evidence added for selected nodes.'
            end.to change { Evidence.count }.by(3).and change { Node.count }.by(2)

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

          it 'tracks "create" activities for new evidence and nodes' do
            find('.js-add-evidence').click
            # one new node, one existing node:
            fill_in 'Paste list of nodes', with: "#{@node.label}\r\naaaa"
            expect do
              click_button('Save Evidence')
              expect(page).to have_text 'Evidence added for selected nodes.'
            end.to change { enqueued_activity_tracking_jobs.size }.by(3)

            jobs = enqueued_activity_tracking_jobs.last(3)
            expect(enqueued_job_args(jobs, 'action')).to eq Array.new(3, 'create')
            expect(enqueued_job_args(jobs, 'trackable_type')).to \
              match_array(%w[Evidence Evidence Node])
          end

          it 'assigns the current user as the evidence author' do
            find('.js-add-evidence').click
            check('192.168.0.1')
            select('Simple Note', from: 'evidence_content')
            expect { click_button('Save Evidence') }.to change { Evidence.count }.by(1)
            expect(@node.reload.evidence.last.author).to eq(@logged_in_as.email)
          end

          # we need to filter by job class because a NotificationsReaderJob
          # will also be enqueued
          def enqueued_activity_tracking_jobs
            ActiveJob::Base.queue_adapter.enqueued_jobs.select do |hash|
              hash[:job] == ActivityTrackingJob
            end
          end

          def enqueued_job_args(job_hashes, key)
            job_hashes.map { |h| h[:args].map { |h2| h2[key] } }.flatten
          end
        end
      end
    end
  end
end
