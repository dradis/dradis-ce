class TagsController < AuthenticatedController
  include ActivityTracking
  include NodesSidebar
  include ProjectScoped

  before_action :find_or_initialize_tags, :paginate_tags, only: :index
  before_action :set_tag, except: [:index, :create]

  def index
    respond_to do |format|
      format.html
      format.json
    end
  end

  def create
    current_project.tags.create(tag_params)
    redirect_to project_tags_path
  end

  def update
    @tag.update_attributes(tag_params)    
    redirect_to project_tags_path
  end

  def destroy
    @tag.destroy
    redirect_to project_tags_path
  end

  private

  def tag_params
    params.require(:tag).permit(:name)
  end

  def find_or_initialize_tags
    @tags ||= current_project.tags.coloured
    return unless params[:name]
    @tags = @tags.where("LOWER(name) LIKE ?", "%#{params[:name].downcase}%")
  end

  def paginate_tags
    @tags = @tags.page(params[:page]).per(12)
  end

  def set_tag
    @tag = current_project.tags.find(params[:id])
  end
end