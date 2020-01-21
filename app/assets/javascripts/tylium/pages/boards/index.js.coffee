document.addEventListener "turbolinks:load", ->

  if $('body.boards.index').length

    $('.js-board-modal').on 'click', (e)->
      e.preventDefault()
      $($(this).attr('href')).modal()

      false

    # when creating a new board and we select a template:
    # - choose the "from template" radio
    # - if board name is empty, populate it with the selected option
    $('select#template').on 'change', ->
      $('#use_template_yes').prop('checked', true)

      selected_option = $('select#template option:selected').text()
      if !$('[data-behavior~=new-board-name]').val()
        # empty board name, use the selected one by default
        $('[data-behavior~=new-board-name]').val(selected_option)
      else if $('select#template option').filter(-> this.text == $('[data-behavior~=new-board-name]').val()).length
        # not empty board name, but it was one of the templates, use the selected one
        $('[data-behavior~=new-board-name]').val(selected_option)

    # when we clik the "From template" radio, also populate the name input with
    # the template name
    $('input#use_template_yes').on 'click', ->
      selected_option = $('select#template option:selected').text()
      $('[data-behavior~=new-board-name]').val(selected_option)
