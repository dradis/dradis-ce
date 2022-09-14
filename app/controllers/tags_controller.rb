class TagsController < AuthenticatedController
  include ProjectScoped
  include ActivityTracking
  include MultipleDestroy

  before_action :set_columns, only: :index
  load_and_authorize_resource

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

  def set_columns
    default_field_names = ['Tag'].freeze
    extra_field_names = ['Created', 'Updated'].freeze

    @default_columns = default_field_names
    @all_columns = default_field_names | extra_field_names
  end
end
