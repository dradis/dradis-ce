jQuery ->
  if $('#issues').length

    $('.js-add-evidence').popover
      container: $('#js-add-evidence-container .js-popover-container'),
      content: ->
        $('#js-add-evidence-container .content').html()
      ,
      html: true,
      title: 'Find node',
      trigger: 'manual'

    $('.js-add-evidence').click (e)->
      $(this).popover('show')
      $('#js-add-evidence-container .js-popover-container').find('input:text:visible:first').focus()

    $('#js-add-evidence-container .js-popover-container').on 'change', '#add-evidence', ->
      node_label  = $(this).val()
      label_index = $('#add-evidence').data('source').indexOf(node_label)

      if label_index != -1
        form_action = $('form#new-evidence').attr('action')
        node_id     = $('#add-evidence').data('ids')[label_index]

        $('.js-add-evidence').popover('hide')
        $('form#new-evidence').attr('action', form_action.replace(':node_id', node_id))
        $('form#new-evidence').submit()
      else
        alert('You need to choose a node that already exists in the project.')
    $('#js-add-evidence-container').on 'change', '#evidence_note_template', ->
      $('#evidence_content').val($(this).val())
    $('#js-add-evidence-container').on 'keyup', '#evidence_node', ->
      rule = new RegExp($(this).val(), 'i')
      $('#nodes label').hide();
      $('#nodes label').filter ->
        rule.test($(this).text())
      .show()
