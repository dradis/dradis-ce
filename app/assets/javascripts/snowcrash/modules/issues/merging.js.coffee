jQuery ->
  if ($('body.issues.merging').length)

    $('.change-merge-option').click ->
      $('.merge-option').toggle()
      $("input[name='id']").prop('disabled', (i,v) -> !v)
      false

   $('.expand').click ->
     $(@).next().toggle()
     text = "collapse"
     text = "expand" if $(@).find('small').html() == "collapse"
     $(@).find('small').html(text)
     false
