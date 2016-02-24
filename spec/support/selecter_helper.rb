module SelecterHelper

  # Capybara's 'select' matcher doesn't work for <select> tags which have
  # been styled by jQuery.selector. Use this method to do it the long way:
  # Takes the same arguments as the most basic use case for Capybara's select
  # (`select "Option", from: :id_of_select_tag)
  #
  # NOTE: You ONLY need to use this on tests which are tagged with `js: true`.
  # On non-javascript tests, selecter won't have been run so the regular
  # `select` method will work.
  def selecter_select(value, opts={})
    from = opts.fetch(:from).to_s.strip
    from = "#" << from unless /\A#/ =~ from
    # The real <select> tag is hidden; selecter wraps it in its own <div>
    selecter = find(from, visible: false).find(:xpath, "..")
    # Click the selecter to show the dropdown:
    selecter.click
    # Click the specific option to select it:
    within(selecter) { find("span.selecter-item", text: /\A#{value}\z/).click }
  end

end
