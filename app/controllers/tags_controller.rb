class TagsController < AuthenticatedController
  include ProjectScoped

  before_action :find_or_initialize_tags, :paginate_tags, only: :index
  before_action :set_tag, except: :index

  def index
    respond_to do |format|
      format.html
      format.json
    end
  end

  def create
  end

  def show
  end

  def update
  end

  def destroy
  end

  private

  def find_or_initialize_tags
    @tags ||= current_project.tags.coloured
    return unless params[:name]
    @tags = @tags.where("LOWER(name) LIKE ?", "%#{params[:name].downcase}%")
  end

  def paginate_tags
    @tags = @tags.page(params[:page]).per(10)
  end

  def set_tag    
    @tag = current_project.tags.find(params[:id])
  end
end