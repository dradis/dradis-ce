class Issues::MergeController < IssuesController

  def new
    @issues = []

    if params[:ids]
      ids = params[:ids].split(',')
      @issues = Issue.where(id: ids)
    end

    if @issues.count <= 1
      redirect_to issues_url,
        alert: 'You need to select at least two issues to merge.'
    end
  end

  def create
    count = 0
    if params[:sources]

      # create new issue if existing issue not given
      if @issue.new_record?
        @issue.author ||= current_user.email
        if @issue.save && @issue.update_attributes(issue_params)
          track_created(@issue)
          tag_issue_from_field_content(@issue)
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
          redirect_to @issue, notice: "#{count} issues merged into #{@issue.title}."
        else
          redirect_to issues_url, alert: "Issues couldn't be merged."
        end
      }
      format.json
    end
  end

end
