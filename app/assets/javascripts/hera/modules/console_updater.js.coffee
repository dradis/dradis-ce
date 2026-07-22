@ConsoleUpdater =
  jobId: ''
  parsing: false
  failureCount: 0
  maxFailures: 5

  updateConsole: ->
    unless ConsoleUpdater.parsing
      # danger will robinson, this is only valid for Export workers
      if $('#download').length
        $('#download').attr('disabled', false).text('Download');

      return

    after = 0
    if $('.log').length
      after = $('#console p:last-child').data('id')

    url = $('#result').data('url')

    $.get(
      url,
      {item_id: ConsoleUpdater.jobId, after: after},
      null,
      'script'
    ).done(->
      # Reset on every success so the cap only trips on consecutive failures,
      # not ones accumulated over the whole polling session.
      ConsoleUpdater.failureCount = 0
    ).fail ->
      ConsoleUpdater.failureCount += 1

      if ConsoleUpdater.failureCount < ConsoleUpdater.maxFailures
        setTimeout(ConsoleUpdater.updateConsole, 2000)
      else
        $('#console').append('<p class="log text-error">Lost connection while checking progress. Please refresh the page to check the current status.</p>')
