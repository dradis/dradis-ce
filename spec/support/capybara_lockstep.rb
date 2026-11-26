# Wires capybara-lockstep into the app Capybara serves, so nothing test-only
# lives in the layouts or the Rails environment config.

# capybara-lockstep needs its JavaScript snippet in every page's <head>. This
# Rack middleware injects it into HTML responses served to Capybara.
class LockstepScriptInjection
  include Capybara::Lockstep::Helper

  def initialize(app)
    @app = app
  end

  def call(env)
    status, headers, body = @app.call(env)
    return [status, headers, body] unless html?(headers)

    html = +''
    body.each { |chunk| html << chunk }
    body.close if body.respond_to?(:close)

    html.sub!(/<head[^>]*>/i) { |tag| "#{tag}<script>#{capybara_lockstep_js}</script>" }

    headers.delete_if { |key, _| key.casecmp?('content-length') }
    [status, headers, [html]]
  end

  private

  def html?(headers)
    headers.any? { |key, value| key.casecmp?('content-type') && value.to_s.include?('text/html') }
  end
end

app = Capybara.app
Capybara.app = Rack::Builder.new do
  # Lets lockstep also wait for server requests still in progress.
  use Capybara::Lockstep::Middleware
  use LockstepScriptInjection
  run app
end.to_app

# capybara-lockstep only waits for the browser and server *before* the next
# Capybara command. Specs often interact and then assert on the database
# (e.g. `expect { click_button 'Save' }.to change(Issue, :count)`), which isn't
# a Capybara command, so we also wait *after* each interaction.
module SynchronizeAfterInteraction
  %i[
    click double_click drag_to right_click select_option send_keys set unselect_option
  ].each do |meth|
    define_method(meth) do |*args, **kwargs, &block|
      super(*args, **kwargs, &block).tap { Capybara::Lockstep.synchronize }
    end
  end
end

Capybara::Node::Element.prepend(SynchronizeAfterInteraction)
