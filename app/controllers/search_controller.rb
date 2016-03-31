class SearchController < ProjectScopedController
	include SearchHelper

  def index
    params[:scope] = "all" if params[:scope].blank?
    @search = Search.new(search_term: params[:q], scope: params[:scope])
  end
end
