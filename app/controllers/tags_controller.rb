class TagsController < ApplicationController
  include ProjectScoped
  include ActivityTracking

  before_action :set_project
  before_action :set_tag, except: [:index, :new, :create]

  def index
    @tags = Tag.all
  end

  def new
    @tag = Tag.new
  end

  def create
    @tag = Tag.new(tag_params)
    
    respond_to do |format|
      if @tag.save
        track_created(@tag, project: @project)

        format.html {redirect_to project_issues_path(current_project), notice: 'Tag created'}
      else
        format.html do
          redirect_to project_issues_path(current_project),
          alert: "Tag could not be created: #{@tag.errors.full_messages.join('; ')}"
        end
      end
    end
  end

  def edit
    # format color for edit form
    @color = @tag.color.split("#").last
  end

  def update
    respond_to do |format|

      if @tag.update(tag_params)
        track_updated(@tag, project: @project)

        format.html {redirect_to project_tags_path(current_project), notice: 'Tag updated'}
        format.js
      else
        format.html do
          redirect_to project_tags_path(current_project),
          alert: "Tag could not be updated: #{@tag.errors.full_messages.join('; ')}"
        end
      end
    end
  end

  def destroy
    respond_to do |format|
      if @tag.destroy
        track_destroyed(@tag, project: @project)
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
    tag_params = params.require(:tag).permit(:name, :color)
    new_tag_params = tag_params.dup
    # format tag name for db - makes form more user-friendly
    new_tag_params[:name] = "!#{new_tag_params[:color]}_#{new_tag_params[:name]}"
    new_tag_params.delete(:color)

    new_tag_params
  end

end
