class StaticPagesController < AuthenticatedController
  include ProjectScoped

  def issuelib_index; end

  def issuelib_import; end
end
