# Capybara 3.40 resets Chrome between examples with
# Storage.clearDataForOrigin(origin: '*'), which current Chrome rejects as an
# invalid URL. Scope the clear to the test server's origin instead.
module ChromeStorageClearPatch
  def execute_cdp(cmd, **args)
    if cmd == 'Storage.clearDataForOrigin' && args[:origin] == '*'
      server = Capybara.current_session.server
      return unless server

      args[:origin] = server.base_url
    end

    super
  end
end

Capybara::Selenium::Driver::ChromeDriver.prepend(ChromeStorageClearPatch)
