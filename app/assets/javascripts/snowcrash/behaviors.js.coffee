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

    paste: (e, data)->
      $.each data.files, (index, file) ->
        if (!file.name?)
          file.name = prompt('Please provide a filename for the pasted image', 'screenshot-XX.png') || 'unnamed.png'


  # Initialize clipboard.js:
  clipboard = new Clipboard('.js-attachment-url-copy')

  clipboard.on 'success', (e) ->
    $btn = $(e.trigger)
    e.clearSelection()
    $btn.tooltip
      placement: 'bottom'
      title:     'Copied attachment URL to clipboard!',
      trigger:   'manual'
    $btn.tooltip('show')


  clipboard.on 'error', (e) ->
    actionKey = if e.action == 'cut' then 'X' else 'C'
    if /Mac/i.test(navigator.userAgent)
      actionMsg = 'Press ⌘-' + actionKey + ' to '+ e.action
    else
      actionMsg = 'Press Ctrl-' + actionKey + ' to ' + e.action

    $btn = $(e.trigger)

    $btn.tooltip
      placement: 'bottom'
      title:     actionMsg
      trigger:   'manual'
    $btn.tooltip('show')


  $(".attachments-box").on "mouseleave", ".js-attachment-url-copy", ->
    $this = $(this)
    $this.tooltip("hide") if $this.data("tooltip")


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

  $('.js-try-pro').on 'click', ->
    term    = $(this).data('term')
    $iframe = $('#try-pro iframe')
    url     = $iframe.data('url') +
              '?utm_source=ce&utm_medium=app&utm_campaign=try-pro&utm_term=' +
              term

    $iframe.attr('src', url)
    $('#try-pro').modal()



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


  # Search form
  $('#js-search-form-toggle').on 'click', (e)->
    e.preventDefault()
    $('.navbar .form-search').toggleClass('hide')
    $('.navbar .search-query').focus()
    $(this).hide()

  $('.navbar .search-query').on 'blur', ->
    # Without this, the form will be hidden before the user has a chance to
    # click on the submit button with the mouse.
    setTimeout ->
      $('.navbar .form-search').toggleClass('hide')
      $('#js-search-form-toggle').show()
    , 10

  $('.navbar .btn-search').on 'click', ->
    $('.form-search').submit()

  # Table filtering
  $('.js-table-filter').on 'keyup', ->
    rex = new RegExp($(this).val(), 'i')
    $('tbody tr').hide();
    $('tbody tr').filter( ->
      rex.test($(this).text());
    ).show();
