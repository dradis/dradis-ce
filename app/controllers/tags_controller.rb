class TagsController < ApplicationController
  include ProjectScoped

  before_action :set_project
  before_action :set_tag, except: [:index, :new, :create]

  def index
    @tags = Tag.all
  end

  def show
    # @tag = Tag.find(params[:id])
  end

  def new
    @tag = Tag.new
  end

  def edit
    # @tag = Tag.find(params[:id])
  end

  def create
    @tag = Tag.new(tag_params)

    if @tag.save
    redirect_to project_tag_path(id: @tag.id), notice: 'Tag created'
    else
      redirect_to project_tags_path, alert: 'Something went wrong'
    end
  end

  def update
    # @tag = Tag.find(params[:id])

    if @tag.update(tag_params)
      redirect_to project_tag_path(id: @tag.id), notice: 'Tag updated'
    else
      redirect_to project_tags_path, alert: 'Something went wrong, tag could not be updated'
    end
  end

  def destroy
    # @tag = Tag.find(params[:id])
    respond_to do |format|
      if @tag.destroy
        format.html { redirect_to project_tags_path(current_project), notice: 'Tag deleted.' }
      else
        format.html { redirect_to project_tag_path(project: current_project, id: @tag.id), notice: "Error while deleting tag: #{@tag.errors}" }
      end
    end
  end

  private

  def set_tag
    @tag = Tag.find(params[:id])
  end

  def set_project
    @project = current_project
  end

  def tag_params
    params.require(:tag).permit(:name, :type, :color, :nickname)
  end
end
