class TagsController < AuthenticatedController
  load_and_authorize_resource
  include ProjectScoped
  include ActivityTracking

  def index; end

  def new; end

  def create
    if @tag.save
      track_created(@tag, project: @project)
      redirect_to project_tags_path(current_project), notice: 'Tag created'
    else
      redirect_to project_tags_path(current_project), alert: @tag.errors.full_messages.join('; ')
    end
  end

  def edit; end

  def update
    if @tag.update(tag_params)
      track_updated(@tag, project: @project)
      redirect_to project_tags_path(current_project), notice: 'Tag updated'
    else
      redirect_to project_tags_path(current_project), alert: @tag.errors.full_messages.join('; ')
    end
  end

  def destroy
    @tag.destroy
    track_destroyed(@tag, project: @project)
    redirect_to project_tags_path(current_project), notice: 'Tag destroyed'
  end

  private

  def tag_params
    modified_params = params.require(:tag).permit(:name, :color)
  end
end
