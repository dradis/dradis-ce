document.addEventListener "turbolinks:load", ->

  # Nodes#show shortcuts
  if $('body.nodes').length
    # Save current note / issue
    $(document).bind 'keydown', 'Meta+s', ->
      alert 'TODO: implement save'
      false

    $(document).bind 'keydown', 'Meta+o', ->
      $(".dropdown-toggle[data-name='notes']").click()
      false

    $(document).bind 'keydown', 'Meta+i', ->
      $(".dropdown-toggle[data-name='issues']").click()
      false