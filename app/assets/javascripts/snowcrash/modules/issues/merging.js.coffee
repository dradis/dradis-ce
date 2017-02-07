jQuery ->
  if ($('body.issues.merging').length)

    $('.js-change-merge-option').click ->
      $('.merge-option').toggle()
      $("input[name='id']").prop('disabled', (i,v) -> !v)
      false

    $('.issue-toggle').click ->
      $(this).find('i').toggleClass('fa-chevron-down fa-chevron-up')
