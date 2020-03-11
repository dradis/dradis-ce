# Internal application Tags configurations are handled through this
# REST-enabled controller.

class Configurations::TagsController < AuthenticatedController
  include ProjectScoped

  before_action :set_tag, only: [:edit, :update, :destroy]

  def index
    @tags = Tag.all
  end

  def new
    @tag_form = TagForm.new
  end

  def create
    @tag_form = TagForm.new(tag_form_params)

    if @tag_form.save
      redirect_to project_configurations_tags_path(current_project), notice: 'Tag added.'
    else
      render :new
    end
  end

  def edit
    @tag_form = TagForm.new(id: @tag.id, color: @tag.color, name: @tag.display_name)
  end

  def update
    @tag_form = TagForm.new(tag_form_params.merge(id: @tag.id))

    if @tag_form.save
      redirect_to project_configurations_tags_path(current_project), notice: 'Tag updated.'
    else
      render :edit
    end
  end

  def destroy
    @tag.destroy
    redirect_to project_configurations_tags_path(current_project), notice: 'Tag deleted.'
  end

  private

  def tag_form_params
    params.require(:tag_form).permit(:name, :color)
  end

  def set_tag
    @tag = Tag.find(params[:id])
  end
end
