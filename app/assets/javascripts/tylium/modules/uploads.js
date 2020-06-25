document.addEventListener("turbolinks:load", function() {
  var $bar, $percent, $status;

  if ($('body.upload').length) {
    $bar = $('.progress-bar');
    $percent = $('.percent');
    $status = $('#status');

    $('form#new_upload').ajaxForm({
      resetForm: true,
      dataType: 'script',
      beforeSend: function() {
        var percentVal;
        $status.empty();
        percentVal = '0%';
        $bar.width(percentVal);
        $bar.addClass('bg-primary');
        return $percent.html(percentVal);
      },
      uploadProgress: function(event, position, total, percentComplete) {
        var percentVal;
        percentVal = percentComplete + '%';
        $bar.width(percentVal);
        $percent.html(percentVal);
        return $percent.css('color', '#fff;');
      },
      success: function() {
        var percentVal;
        percentVal = '100%';
        $bar.width(percentVal);
        $bar.removeClass('bg-primary').addClass('bg-success');
        return $percent.html(percentVal);
      }
    });

    var toggleStateDropdown = function(){
      var selectedValue = $('[data-behavior~=integration-select]').find('option:selected').val();
      var packagePlugin = 'Upload::Package';
      var templatePlugin = 'Upload::Template';

      if (selectedValue.includes(packagePlugin) || selectedValue.includes(templatePlugin)) {
        $('[data-tool-type~=third-party]').addClass('d-none');
        $('[data-tool-type~=dradis]').removeClass('d-none');
        $('[data-behavior~=state-select]').addClass('disabled').prop('disabled', 'disabled');
        $('[data-behavior~=state-select] option:eq(2)').prop('selected', true)
      }
      else {
        $('[data-tool-type~=third-party]').removeClass('d-none');
        $('[data-tool-type~=dradis]').addClass('d-none');
        $('[data-behavior~=state-select]').removeClass('disabled').prop('disabled', false);
      }
    }

    toggleStateDropdown();
    $('[data-behavior~=integration-select]').change(toggleStateDropdown);

    return $(':file').change(function() {
      var fileName;
      ConsoleUpdater.jobId = ConsoleUpdater.jobId + 1;
      fileName = this.value.split('\\').pop();
      $('#console').empty();
      $('#filename').text(fileName);
      $('#spinner').show();
      $('#result').data('id', ConsoleUpdater.jobId);
      $('#result').show();
      $('#item_id').val(ConsoleUpdater.jobId);
      $('[data-behavior~=file-label]').text(fileName);
      return $(this).closest('form').submit();
    });
  }
});
