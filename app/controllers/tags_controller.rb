class TagsController < AuthenticatedController
  load_and_authorize_resource
  include ProjectScoped

  def index; end

  def new; end

  def create
    if @tag.save
      redirect_to project_tags_path(current_project), notice: 'Tag created'
    else
      render :new
    end
  end

  def edit; end

  def update
    if @tag.update(tag_params)
      redirect_to project_tags_path(current_project), notice: 'Tag updated'
    else
      render :edit
    end
  end

  def destroy
    @tag.destroy
    redirect_to project_tags_path(current_project), notice: 'Tag destroyed'
  end

  private

  def tag_params
    params.require(:tag).permit(:name)
  end
end
