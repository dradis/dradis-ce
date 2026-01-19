module Dradis::Sandbox
  class Engine < ::Rails::Engine
    isolate_namespace Dradis::Sandbox

    # Hook into the framework
    include ::Dradis::Plugins::Base
    provides :addon
    description 'Dradis CE Sandbox'
  end
end
