class TagsController < AuthenticatedController
  include ProjectScoped
  include ActivityTracking

  before_action :set_columns, only: :index
  load_and_authorize_resource

  def index
    @tags = current_project.tags
  end

  def new; end

  def create
    if @tag.save
      track_created(@tag)
      redirect_to request.referer, notice: 'Tag created.'
    else
      redirect_to request.referer, alert: @tag.errors.full_messages.join('; ')
    end
  end

  def edit; end

  def update
    if @tag.update(tag_params)
      track_updated(@tag)
      redirect_to project_tags_path(current_project), notice: 'Tag updated.'
    else
      redirect_to project_tags_path(current_project), alert: @tag.errors.full_messages.join('; ')
    end
  end

  def destroy
    if @tag.destroy
      track_destroyed(@tag)
      redirect_to project_tags_path(current_project), alert: 'Tag deleted.'
    else
      redirect_to project_tags_path(current_project), alert: @tag.errors.full_messages.join('; ')
    end
  end

  private

  def tag_params
    modified_params = params.require(:tag).permit(:display_name, :color)
    modified_params[:name] = "#{modified_params[:color].gsub('#', '!')}_#{modified_params[:display_name]}"
    modified_params.except(:color, :display_name)
  end

  def set_columns
    default_field_names = ['Tag'].freeze
    extra_field_names = ['Color code', 'Created', 'Updated'].freeze

    @default_columns = default_field_names
    @all_columns = default_field_names | extra_field_names
  end
end
