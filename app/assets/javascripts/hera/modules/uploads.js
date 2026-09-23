document.addEventListener('turbo:load', function () {
  if ($('body.upload').length) {
    // Enable Ajax file uploads via 3rd party plugin
    const $bar = $('.progress-bar');
    const $percent = $('.percent');
    const $status = $('[data-behavior~=status]');

    $('[data-behavior~=new-upload]').ajaxForm({
      dataType: 'script',
      beforeSend: function () {
        $status.empty();
        const percentVal = '0%';
        $bar.width(percentVal);
        $bar.addClass('bg-primary');
        $percent.html(percentVal);
      },
      uploadProgress: function (event, position, total, percentComplete) {
        const percentVal = percentComplete + '%';
        $bar.width(percentVal);
        $percent.html(percentVal);
        $percent.css('color', '#fff;');
      },
      success: function () {
        const percentVal = '100%';
        $bar.width(percentVal);
        $bar.removeClass('bg-primary').addClass('bg-success');
        $percent.html(percentVal);
      },
    });

    $(':file').change(function () {
      const fileName = this.value.split('\\').pop();
      $('[data-behavior~=console]').empty();
      $('[data-behavior~=filename]').text(fileName);
      $('[data-behavior~=spinner]').show();
      $('[data-behavior~=file-label]').text(fileName);

      $(this).closest('form').submit();
      // Can't use this, because Rails UJS doesn't kick in (missing CSRF)
      // $(this).closest('form').trigger('submit.rails');
    });

    const $uploader = $('[data-behavior~=tool-select]');
    $uploader.change(function () {
      const uploader = $(this).val();
      new RTPValidation({
        rtpId: $('[data-behavior~=rtp-validation]').data('rtp-id'),
        uploader: uploader,
      });
    });
  }
});
