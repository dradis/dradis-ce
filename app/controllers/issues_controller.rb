class IssuesController < AuthenticatedController
  include ActivityTracking
  include ContentFromTemplate
  include ConflictResolver
  include Mentions
  include MultipleDestroy
  include NotificationsReader
  include ProjectScoped

  before_action :find_issuelib
  before_action :find_issues, except: [:destroy]

  before_action :find_or_initialize_issue, except: [:import, :index]
  before_action :find_or_initialize_tags, except: [:destroy]

  def index
    @columns = @issues.map(&:fields).map(&:keys).uniq.flatten | ['Title', 'Tags', 'Affected', 'Created', 'Created by', 'Updated']
  end

  def show
    @activities = @issue.commentable_activities.latest

    # We can't use the existing @nodes variable as it only contains root-level
    # nodes, and we need the auto-complete to have the full list.
    @nodes_for_add_evidence = current_project.nodes.user_nodes.order(:label)

    @affected_nodes = Node.joins(:evidence)
                        .select('nodes.id, label, type_id, count(evidence.id) as evidence_count, nodes.updated_at')
                        .where('evidence.issue_id = ?', @issue.id)
                        .group('nodes.id')
                        .sort_by { |node, _| node.label }

    @first_node      = @affected_nodes.first
    @first_evidence  = Evidence.where(node: @first_node, issue: @issue)

    load_conflicting_revisions(@issue)

    @subscription = @issue.subscription_for(user: current_user)
    read_item_notifications(@issue, current_user)
  end

  def new
    # See ContentFromTemplate concern
    @issue.text = template_content if params[:template]
  end

  def create
    @issue.author ||= current_user.email

    respond_to do |format|
      if @issue.save &&
          # FIXME: need to fix Taggable concern.
          #
          # For some reason we can't save the :tags before we save the model,
          # so first we save it, then we apply the tags.
          #
          # See #find_or_initialize_issue()
          #
          @issue.update_attributes(issue_params)


        track_created(@issue)
        # Only after we save the issue, we can create valid taggings (w/ valid
        # taggable IDs)
        tag_issue_from_field_content(@issue)

        format.html { redirect_to [current_project, @issue], notice: 'Issue added.' }
      else
        format.html { render 'new', alert: 'Issue couldn\'t be added.' }
      end
      format.js
    end
  end

  def edit
  end

  def update
    respond_to do |format|
      updated_at_before_save = @issue.updated_at.to_i

      if @issue.update_attributes(issue_params)
        @modified = true
        check_for_edit_conflicts(@issue, updated_at_before_save)
        track_updated(@issue)
        format.html { redirect_to project_issue_path(current_project, @issue), notice: 'Issue updated' }
      else
        format.html { render 'edit' }
      end
      format.js
      format.json
    end
  end

  def destroy
    respond_to do |format|
      if @issue.destroy
        track_destroyed(@issue)
        format.html { redirect_to project_issues_path(current_project), notice: 'Issue deleted.' }
        format.json
      else
        format.html { redirect_to project_issues_path(current_project), notice: "Error while deleting issue: #{@issue.errors}" }
        format.json
      end
    end
  end

  def import
    importer = IssueImporter.new(params)
    @results = importer.query()

    @plugin = importer.plugin
    @filter = importer.filter
    @query = params[:query]
  end

  private

  def find_issues
    # We need a transaction because multiple DELETE calls can be issued from
    # index and a TOCTOR can appear between the Note read and the Issue.find
    Note.transaction do
      @issues = Issue.where(node_id: @issuelib.id).select('notes.id, notes.author, notes.text, count(evidence.id) as affected_count, notes.created_at, notes.updated_at').joins('LEFT OUTER JOIN evidence on notes.id = evidence.issue_id').group('notes.id').includes(:tags).sort
    end
  end

  def find_issuelib
    @issuelib = current_project.issue_library
  end

  # Once a valid @issuelib is set by the previous filter we look for the Issue we
  # are going to be working with based on the :id passed by the user.
  def find_or_initialize_issue
    if params[:id]
      @issue = Issue.find(params[:id])
    elsif params[:issue]
      @issue = Issue.new(issue_params.except(:tag_list)) do |i|
        i.node = @issuelib
      end
    else
      @issue = Issue.new(node: @issuelib)
    end
  end

  # Load all the colour tags in the project (those that start with !). If none
  # exist, initialize a set of tags.
  def find_or_initialize_tags
    @tags = current_project.tags.where('name like ?', '!%')
  end

  def issue_params
    params.require(:issue).permit(:tag_list, :text)
  end

  # This method inspect the issues' Tag field and if present tags the issue
  # accordingly.
  def tag_issue_from_field_content(issue)
    # If the Issue already has tags (e.g. from the HTML form), or if it doesn't
    # have a Tags field, bail.
    return if @issue.tags.any?
    return unless issue.fields['Tags'].present?

    # For now we just care about the first tag
    if (tag_name = issue.fields['Tags'].split(',').first)
      issue.tag_list = tag_name
      issue.save
    end
  end
end
