jQuery ->
  if ($('body.merge.new').length)

    $('.issue-toggle').click ->
      $(this).find('i').toggleClass('fa-chevron-down fa-chevron-up')
