# behaviors.js
#
# In this file we bind general-purpose jQuery plugins with the corresponding
# elements in the page in an unobtrusive way.
#
# The current list of plugins:
#   * jQuery.fileUpload  - handles attachment uploads (gem: jquery-fileupload-rails)
#   * jQuery.Textile     - handles the note editor (/vendor/)

jQuery ->
  # --------------------------------------------------- Standard jQuery plugins
  # Activate jQuery.fileUpload
  $('.jquery-upload').fileupload
    dropZone: $('#drop-zone')
    destroy: (e, data) ->
      if confirm('Are you sure?')
        $.blueimp.fileupload.prototype.options.destroy.call(this, e, data);

  # Start: a patch to implement #144
  # https://github.com/securityroots/dradispro-tracker/issues/144
    paste: (e, data) ->
      record = sessionStorage.getItem('attachments.last-upload')

      $.each data.files, (index, file) ->
        if (record == null)
          type = '.' + file.type.split('/').pop()
        else
          last = record.split(/[-\.]+/)
          type = '.' + last.pop()
          flag = parseInt(last.pop())

          if (JSON.parse(localStorage.getItem('attachments.auto-increasing')))
            ++flag

        noname = 'unnamed' + type
        myname = 'Risk-Issue-Page-1'

        if !isNaN(flag)
          last.push(flag)
          myname = last.join('-')

        file.name = prompt('Please provide a filename for the pasted image', myname + type) || noname

        if (JSON.parse(localStorage.getItem('attachments.quick-pasting')))
          if (file.name == noname)
            data.files = []
          else
            data.autoUpload = true

    always: (e, data) ->
      $.each data.files, (index, file) ->
        sessionStorage.setItem('attachments.last-upload', file.name)

  # initialize clipboard.js
  clipboard = new Clipboard('.lnk-copy')

  clipboard.on 'success', (e) ->
    last = e.text.replace(/\!/g, '').split('/').pop()
    sessionStorage.setItem('attachments.last-upload', last)
    e.clearSelection()

  # implement image preview
  $('a[download]').each ->
    ext = this.href.split('.').pop()
    img = ['bmp', 'jpeg', 'jpg', 'png']

    if ($.inArray(ext.toLowerCase(), img) > -1)
      $(this).attr('data-placement', 'right')
      $(this).attr('data-toggle', 'tooltip')
      $(this).attr('title', '<img src="' + this.href + '">')

  $('[data-toggle="tooltip"]').tooltip
    animated: true
    delay: {show: 800, hide: 100}
    html: true

  # quick pasting event
  $('#quick-pasting').prop('checked', JSON.parse(localStorage.getItem('attachments.quick-pasting')))
  $('#auto-increasing').prop('checked', JSON.parse(localStorage.getItem('attachments.auto-increasing')))

  $('.enhanced-switch').each ->
    $(this).on 'change', () ->
      localStorage.setItem('attachments.' + this.id, JSON.stringify($(this).is(':checked')))
  # End


  # -------------------------------------------------------- Our jQuery plugins
  # Activate jQuery.Textile
  $('.textile').textile()

  # Activate jQuery.breadCrums
  $('.breadcrumb').breadcrums
    tree: $('.main-sidebar .tree-navigation')

  # Activate jQuery.treeNav
  $('.tree-navigation').treeNav()

  # Activate jQuery.treeModal
  $('.modal-node-selection-form').treeModal()


  # ------------------------------------------------------- Bootstrap behaviors

  # Focus first input on modal window display.
  # Note: Bootstrap 3 uses the 'shown.bs.modal' event name.
  # See:
  #   ./app/views/nodes/modals/
  $('.modal').on 'shown', ->
    $(this).find('input:text:visible:first').focus()


  # ------------------------------------------------------ Non-plugin behaviors

  # Close button that hides instead of removing the container
  # We don't need this any more
  # $("[data-hide]").on 'click', ->
  #   $(this).closest("." + $(this).data('hide')).hide();

  # Offline Gravatars
  if $('.gravatar img').length
    $('.gravatar img').each ->
      $this = $(this)
      img = new Image()
      img.onerror = ->
        $this.attr('src', $this.data('fallback-image'))
      img.src = $this.attr('src')

  if ($poller = $("#activities-poller")).length
    ActivitiesPoller.init($poller)
    ActivitiesPoller.poll()

  # Disable form buttons after submitting them.
  $('form').submit (ev)->
    $('input[type=submit]', this).attr('disabled', 'disabled').val('Processing...');
