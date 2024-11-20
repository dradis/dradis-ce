class TagsController < AuthenticatedController
  include ProjectScoped
  include ActivityTracking
  include Sortable

  before_action :set_columns, only: :index
  load_and_authorize_resource

  def index
    @tags = current_project.tags
  end

  def new; end

  def create
    @tag.project = current_project
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
      redirect_to project_tags_path(current_project), notice: 'Tag deleted.'
    else
      redirect_to project_tags_path(current_project), alert: @tag.errors.full_messages.join('; ')
    end
  end

  private

  def sortable_class
    Tag
  end

  def sortable_records
    current_project.tags
  end

  def tag_params
    modified_params = params.require(:tag).permit(:name, :color)
    modified_params[:name] = "#{modified_params[:color].gsub('#', '!')}_#{modified_params[:name]}"
    modified_params.except(:color)
  end

  def set_columns
    default_field_names = ['Sort', 'Name'].freeze
    extra_field_names = ['Color', 'Created', 'Updated'].freeze

    @default_columns = default_field_names
    @all_columns = default_field_names | extra_field_names
  end
end
