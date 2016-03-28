class SearchesController < ApplicationController
  def index
    @search = Search.new(search_term: params[:q])
  end
end
