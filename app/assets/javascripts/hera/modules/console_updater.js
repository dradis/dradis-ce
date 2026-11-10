const ConsoleUpdater = {
  jobId: '',
  parsing: false,

  updateConsole() {
    if (!ConsoleUpdater.parsing) {
      // danger will robinson, this is only valid for Export workers
      if ($('#download').length) {
        $('#download').attr('disabled', false).text('Download');
      }

      return;
    }

    let after = 0;
    if ($('.log').length) {
      after = $('#console p:last-child').data('id');
    }

    const url = $('#result').data('url');

    $.get(
      url,
      { item_id: ConsoleUpdater.jobId, after: after },
      null,
      'script'
    );
  }
};

// Global, as console/status.js.erb, upload/create.js.erb and datatable/delete.js use it
window.ConsoleUpdater = ConsoleUpdater;
