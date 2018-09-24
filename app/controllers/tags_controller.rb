# This controller exposes the REST operations required to manage the Tag
# resource.
class TagsController < AuthenticatedController
  include ActivityTracking
  include ConflictResolver
  include ProjectScoped

  def index
    @tags = Tag.all
    @columns = %w(Name Color Created Updated)
  end

  def new
    @tag = Tag.new
  end
end
