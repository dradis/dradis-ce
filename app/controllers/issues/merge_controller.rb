class Issues::MergeController < IssuesController

  def new
    @issues = []

    if params[:ids]
      ids = params[:ids].split(',')
      @issues = Issue.where(id: ids)
    end

    if @issues.count <= 1
      redirect_to projects_issues_url(current_project),
        alert: 'You need to select at least two issues to merge.'
    end
  end

  def create
    count = 0
    if params[:sources]

      # create new issue if existing issue not given
      if @issue.new_record?
        @issue.author ||= current_user.email
        if @issue.save && @issue.update(issue_params)
          track_created(@issue)
          @issue.tag_from_field_content!
        end
      end

      if @issue.persisted?
        source_ids = params[:sources].map(&:to_i) - [@issue.id]
        count = @issue.merge source_ids
      end

    end

    respond_to do |format|
      format.html {
        if count > 0
          redirect_to [current_project, @issue], notice: "#{count} #{'issue'.pluralize(count)} merged into #{@issue.title}."
        else
          redirect_to project_issues_path(current_project), alert: "Issues couldn't be merged."
        end
      }
      format.json
    end
  end

end
