jQuery ->
  if $('body.upload').length
    # Enable Ajax file uploads via 3rd party plugin
    $bar = $('.bar');
    $percent = $('.percent');
    $status = $('#status');
    $('form#new_upload').ajaxForm({
      resetForm: true
      dataType: 'script'
      beforeSend: ->
          $status.empty();
          percentVal = '0%';
          $bar.width(percentVal)
          $percent.html(percentVal);
      uploadProgress: (event, position, total, percentComplete)->
          percentVal = percentComplete + '%';
          $bar.width(percentVal)
          $percent.html(percentVal);
      success: ->
          percentVal = '100%';
          $bar.width(percentVal)
          $percent.html(percentVal);
    });

    $(':file').change ->
      ConsoleUpdater.jobId = ConsoleUpdater.jobId + 1
      $('#console').empty()
      $('#filename').text(this.value)
      $('#spinner').show()
      $('#result').data('id', ConsoleUpdater.jobId)
      $('#result').show()
      $('#item_id').val(ConsoleUpdater.jobId)

      $(this).closest('form').submit()
      # Can't use this, because Rails UJS doesn't kick in (missing CSRF)
      # $(this).closest('form').trigger('submit.rails');
