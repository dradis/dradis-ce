module ActivityMacros
  extend ActiveSupport::Concern

  include ActionView::RecordIdentifier

  def activity_feed
    ".activity-feed"
  end

  def have_activity(activity)
    have_selector "##{dom_id(activity)}"
  end

  # NOTE: If the tests fail randomly with a message along the lines of "an
  # error occurred in an after hook: unable to find User with id x" - make sure
  # that POLLING_INTERVAL_MS in
  # app/assets/javascripts/tylium/modules/poller.js.coffee is set to a value
  # that's longer than a couple of seconds. (It's 10 seconds by default, but
  # you might want to reduce this temporarily to help with manual testing.)
  #
  # Basically, when the polling interval is very low, sometimes the poller will
  # make an AJAX call *after* RSpec has finished the example (and thus cleaned
  # out the database) but *before* Poltergeist has finished closing down - meaning
  # that the polling method is being called while the database is empty, so it
  # will raise an error (and make the test fail with a very obscure failure
  # message.).
  #
  # You have been warned
  def call_poller
    page.execute_script "ActivitiesPoller.request()"
  end

  def within_sidebar
    within(".secondary-navbar") { yield }
  end

end
