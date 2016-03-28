class SearchController < ProjectScopedController
	include SearchHelper

  def index
    @search = Search.new(search_term: params[:q], scope: params[:scope])
  end
end
