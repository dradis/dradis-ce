class SearchController < ProjectScopedController
	include SearchHelper
  before_action :set_scope

  def index
    @search = Search.new(query: params[:q], scope: @scope, page: params[:page])
  end

  private
  def set_scope
    @scope = if params[:scope].blank? ||
                  !%{all evidence issues nodes notes}.include?(params[:scope])
               :all
             else
               params[:scope].to_sym
             end
  end
end
