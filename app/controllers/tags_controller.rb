class TagsController < ApplicationController

    before_action :set_tag, only: [:edit, :update, :show, :destroy]

    def index
        @tags = Tag.all
    end

    def show
    end

    def new
        @tag = Tag.new
    end

    def create
        @tag = Tag.create(tag_params)
        if @tag.save
            redirect_to new_project_issue_path(current_project)
        else
            render 'new'
        end
    end

    def edit
    end

    def update
        if @tag.update(tag_params)
            redirect_to tags_path
        else
            render 'edit'
        end
    end

    def destroy
        @tag.destroy
        redirect_to tags_path
    end

    
    private

        def set_tag
            @tag = Tag.find(params[:id])
        end

        def tag_params
            params.require(:tag).permit(:name)
        end

        def current_project
            @current_project ||= Project.new
        end

end
