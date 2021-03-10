module Mentioned
  extend ActiveSupport::Concern

  included do
    before_action :mentionable_users_for_tributes, only: :show
    before_action :mentionable_users_for_pipeline, only: [:show, :create, :update]
  end

  protected

  def find_mentionable_users
    @mentionable_users ||= current_project.testers_for_mentions
  end

  # For mentionable users in comment textarea select.
  # Only called in show action of resources that has commentable,
  # e.g. CardsController, IssuesController.
  # You can override this method in controllers that includes this concern.
  def mentionable_users_for_tributes
    @mentionable_users_for_tributes ||= current_project.testers_for_mentions
  end

  # For mentionable users when displaying comment.
  # Passed into comment pipeline.
  def mentionable_users_for_pipeline
    @mentionable_users_for_pipeline ||= begin
      if params[:controller] == 'comments'
        if commentable.respond_to?(:project)
          commentable.project.testers_for_mentions
        else
          []
        end
      else
        current_project.testers_for_mentions
      end
    end
  end

  def commentable
    @commentable ||= begin
      if params[:controller] == 'comments'
        @comment.commentable
      else
        instance_variable_get("@#{controller_name.singularize}")
      end
    end
  end
end
