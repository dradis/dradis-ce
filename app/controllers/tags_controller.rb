class TagsController < ApplicationController
  include ProjectScoped

  before_action :set_project
  before_action :set_tag, except: [:index, :new, :create]

  def index
    @tags = Tag.all
  end

  def new
    @tag = Tag.new
  end

  def edit
  end

  def create
    @tag = Tag.new(tag_params)
    respond_to do |format|
      if @tag.save
        format.html {redirect_to project_issues_path(current_project), notice: 'Tag created'}
        format.js
      else
        format.html do
          flash.now[:alert] = @tag.errors.full_messages.join('; ')
          redirect_to project_issues_path(current_project),
          alert: "Tag could not be created: #{@tag.errors.full_messages.join('; ')}"
        end
        format.js
      end
    end
  end

  def update

    if @tag.update(tag_params)
      redirect_to project_tag_path(id: @tag.id), notice: 'Tag updated'
    else
      redirect_to project_tags_path, alert: 'Something went wrong, tag could not be updated'
    end
  end

  def destroy
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
