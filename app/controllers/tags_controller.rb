# This controller exposes the REST operations required to manage the Tag
# resource.
class TagsController < AuthenticatedController
  include ConflictResolver
  include ProjectScoped

  before_action :find_or_initialize_tag, except: [:index]

  def index
    @tags = Tag.all
    @columns = %w(Name Color Uses Created Updated)
  end

  def new
  end

  def create
    @tag.name = TagNamer.new(name: params[:tag][:name], color: params[:color]).execute
    if @tag.save
      redirect_to project_tags_path(current_project), notice: 'Tag created'
    else
      render :new
    end
  end

  def edit
    @color = @tag.color
    @tag.name = @tag.display_name
  end

  def update
    @tag.name = TagNamer.new(name: params[:tag][:name], color: params[:color]).execute
    if @tag.save
      redirect_to project_tags_path(current_project), notice: 'Tag updated'
    else
      render :edit
    end
  end

  def destroy
    if @tag.destroy
      redirect_to project_tags_path(current_project), notice: 'Tag deleted'
    else
      redirect_to project_tags_note_path(current_project), alert: 'Could not delete tag'
    end
  end

  private

  def find_or_initialize_tag
    @tag = params[:id] ? Tag.find(params[:id]) : Tag.new
  end
end
