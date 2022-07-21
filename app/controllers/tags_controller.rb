class TagsController < ApplicationController
  include ProjectScoped

  def index
    @tags = Tag.all
  end

  def show
    @tag = Tag.find(params[:id])
  end

  def new
  end

  def create
  end

  def edit
  end

  def update
    if @tag.update(tag_params)
      track_updated(@tag, project: current_project)
    end
  end

  def destroy
  end

  private

  def tag_params
    params.require(:tag).permit(:name)
  end
end
