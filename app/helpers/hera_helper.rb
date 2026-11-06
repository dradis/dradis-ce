module HeraHelper
  include Hera::CEHelper
  include Hera::ProHelper if defined?(Dradis::Pro)
end
