class TagsController < ApplicationController
  include ProjectScoped
  before_action :set_tag, only: [:show, :edit, :update, :destroy]

  # GET /tags
  # GET /tags.json
  def index
    @tags = Tag.all
  end

  # GET /tags/1
  # GET /tags/1.json
  def show
  end

  # GET /tags/new
  def new
    @tag = Tag.new
  end

  # GET /tags/1/edit
  def edit
  end

  # tag /tags
  # tag /tags.json
  def create
    @tag = Tag.new
    @tag.name = "!#{params[:tag][:color][1..-1]}_#{params[:tag][:tag_name]}"
    respond_to do |format|
      if @tag.save
        format.html { redirect_to project_tags_path(current_project), notice: 'tag was successfully created.' }
        format.json { render json: {name: @tag.name, color: @tag.color, display_name: @tag.display_name}, status: :created}
      else
        format.html { render :new }
        format.json { render json: @tag.errors, status: :unprocessable_entity }
      end
    end
  end


  # PATCH/PUT /tags/1
  # PATCH/PUT /tags/1.json
  def update
    @tag.name = "!#{params[:tag][:color][1..-1]}_#{params[:tag][:tag_name]}"
    respond_to do |format|
      if @tag.save
        format.html { redirect_to project_tags_path(current_project), notice: 'tag was successfully updated.' }
        format.json { render :show, status: :ok, location: @tag }
      else
        format.html { render :edit }
        format.json { render json: @tag.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tags/1
  # DELETE /tags/1.json
  def destroy
    @tag.destroy
    respond_to do |format|
      format.html { redirect_to project_tags_path(current_project), notice: 'tag was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_tag
      @tag = Tag.find(params[:id])
    end
end