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
