class TagsController < ApplicationController
  include ActivityTracking
  include ProjectScoped

  before_action :set_or_initialize_tag

  def create
    respond_to do |format|
      if @tag.update(tag_params)
        track_created(@tag)

        format.html { redirect_to project_issues_path(current_project), notice: 'Tag added.' }
      else
        format.html { redirect_to project_issues_path(current_project), alert: "Tag couldn't be added. #{@tag.errors.full_messages.join("\n")}" }
      end
    end
  end

  def update
    respond_to do |format|
      if @tag.update(tag_params)
        @modified = true
        track_updated(@tag)
        format.html { redirect_to project_issues_path(current_project), notice: 'Tag updated' }
      else
        format.html { redirect_to project_issues_path(current_project), alert: "Error while updating tag: #{@tag.errors.full_messages.join("\n")}" }
      end
    end
  end

  def destroy
    respond_to do |format|
      if @tag.destroy
        track_destroyed(@tag)
        format.html { redirect_to project_issues_path(current_project), notice: "Tag deleted." }
      else
        format.html { redirect_to project_issues_path(current_project), notice: "Error while deleting tag: #{@tag.errors.full_messages.join("\n")}" }
      end
    end
  end

  private

  def set_or_initialize_tag
    if params[:id]
      @tag = Tag.find(params[:id])
    else
      @tag = Tag.new(name: '!555555_tag')
    end
  end

  def tag_params
    params.require(:tag).permit(:display_name, :color)
  end
end
