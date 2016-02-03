class IssuesController < ProjectScopedController
  before_filter :find_issuelib
  before_filter :find_issues

  before_filter :find_or_initialize_issue, except: [:import, :index]
  before_filter :find_or_initialize_tags, except: [:destroy]
  before_filter :find_note_template, only: [:new]

  def index
  end

  def show
    # FIXME: re-enable Activities
    # @activities = @issue.activities.latest

    # We can't use the existing @nodes variable as it only contains root-level
    # nodes, and we need the auto-complete to have the full list.
    @nodes_for_add_evidence = Node.order(:label)
  end

  def new
  end

  def create
    @issue.author ||= current_user

    respond_to do |format|
      if @issue.save
        # FIXME: re-enable Activities
        # track_created(@issue)
        format.html { redirect_to @issue, notice: 'Issue added.' }
      else
        format.html { render 'new', alert: "Issue couldn't be added." }
      end
      format.js
    end
  end

  def edit
  end

  def update
    respond_to do |format|
      if @issue.update_attributes(issue_params)
        @modified = true
        # FIXME: re-enable Activities
        # track_updated(@issue)
        format.html { redirect_to @issue, notice: 'Issue updated' }
      else
        format.html { render "edit" }
      end
      format.js
      format.json
    end
  end

  def destroy
    respond_to do |format|
      if @issue.destroy
        # FIXME: re-enable Activities
        # track_destroyed(@issue)
        format.html { redirect_to issues_url, notice: 'Issue deleted.' }
        format.js

        # Issue table in Issues#index
        format.json
      else
        format.html { redirect_to issues_url, notice: "Error while deleting issue: #{@issue.errors}" }
        format.js

        # Issue table in Issues#index
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
      @issues = Issue.where(node_id: @issuelib.id).select('notes.id, notes.text, count(evidence.id) as affected_count').joins('LEFT OUTER JOIN evidence on notes.id = evidence.issue_id').group('notes.id').includes(:tags).sort
    end
  end

  def find_issuelib
    @issuelib = Node.issue_library
  end

  # if a :template param is passed, we try match it against the available
  # NoteTemplates to pre-populate the Issue's text in the :new action
  def find_note_template
    if params.key?(:template)
      begin
        @issue.text = NoteTemplate.find(params[:template]).content
      rescue
        # invalid template, no need to do anything about it
      end
    end
  end

  # Once a valid @issuelib is set by the previous filter we look for the Issue we
  # are going to be working with based on the :id passed by the user.
  def find_or_initialize_issue
    if params[:id]
      @issue = Issue.find(params[:id])
    elsif params[:issue]
      @issue = Issue.new(issue_params) do |i|
        i.node = @issuelib
      end
    else
      @issue = Issue.new(node: @issuelib)
    end
  end

  # Load all the colour tags in the project (those that start with !). If none
  # exist, initialize a set of tags.
  def find_or_initialize_tags
    @tags = Tag.where('name like ?', '!%')
    if @tags.empty?
      # Create a few default tags
      @tags << Tag.create(name: '!9467bd_Critical')
      @tags << Tag.create(name: '!d62728_High')
      @tags << Tag.create(name: '!ff7f0e_Medium')
      @tags << Tag.create(name: '!6baed6_Low')
      @tags << Tag.create(name: '!2ca02c_Info')
    end
  end

  def issue_params
    params.require(:issue).permit(:tag_list, :text)
  end
end
