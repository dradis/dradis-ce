class StaticPagesController < AuthenticatedController
  include ProjectScoped

  def issuelib_index; end

  def issuelib_import; end

  def styles_index
    render 'static_pages/styles/index'
  end
end
