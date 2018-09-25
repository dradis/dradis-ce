# This controller exposes the REST operations required to manage the Tag
# resource.
class TagsController < AuthenticatedController
  include ConflictResolver
  include ProjectScoped

  before_action :find_or_initialize_tag, except: [:index]

  def index
    @tags = Tag.all
    @columns = %w(Name Color Created Updated)
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

  private

  def find_or_initialize_tag
    @tag = params[:id] ? Tag.find(params[:id]) : Tag.new
  end
end
