class StylesTyliumController < AuthenticatedController
  include ProjectScoped

  layout 'tylium'

  def index; end
end
