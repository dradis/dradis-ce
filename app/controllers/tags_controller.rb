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
      render :new
    end
  end

  def edit; end

  def update
    if @tag.update(tag_params)
      track_updated(@tag, project: @project)
      redirect_to project_tags_path(current_project), notice: 'Tag updated'
    else
      render :edit
    end
  end

  def destroy
    @tag.destroy
    track_destroyed(@tag, project: @project)
    redirect_to project_tags_path(current_project), notice: 'Tag destroyed'
  end

  private

  def tag_params
    modified_params = params.require(:tag).permit(:display_name, :color)
    modified_params[:name] = "#{modified_params[:color].gsub('#', '!')}_#{modified_params[:display_name]}"
    modified_params.except(:color, :display_name)
  end
end
