# Internal application Tags configurations are handled through this
# REST-enabled controller.

class Configurations::TagsController < AuthenticatedController
  include ProjectScoped

  def index
    @tags = Tag.all
  end
end
