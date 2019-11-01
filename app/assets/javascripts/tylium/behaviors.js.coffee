# behaviors.js
#
# In this file we bind general-purpose jQuery plugins with the corresponding
# elements in the page in an unobtrusive way.
#
# The current list of plugins:
#   * jQuery.fileUpload  - handles attachment uploads (gem: jquery-fileupload-rails)
#   * jQuery.Textile     - handles the note editor (/vendor/)

document.addEventListener "turbolinks:load", ->
  # --------------------------------------------------- Standard jQuery plugins
  # Activate jQuery.fileUpload
  $('.jquery-upload').fileupload
    dropZone: $('#drop-zone')
    destroy: (e, data) ->
      if confirm('Are you sure?\n\nProceeding will delete this attachment from the associated node.')
        $.blueimp.fileupload.prototype.options.destroy.call(this, e, data)

    paste: (e, data)->
      $.each data.files, (index, file) ->
        filename = prompt('Please provide a filename for the pasted image', 'screenshot-XX.png') || 'unnamed.png'
        # Clone file object, edit, then reapply to the data object
        newFile = new File [file], filename, { type: file.type }
        data.files[index] = newFile

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
    $this   = $(this)
    term    = $this.data('term')
    $modal  = $('#try-pro')
    $iframe = $('#try-pro iframe')
    url     = $iframe.data('url')

    if $this.data('url')
      url = $this.data('url')
      $modal.css('width', '80%')
      $modal.css('margin-left', '-40%')

      title = switch term
        when 'boards' then '[<span>Dradis Pro feature</span>] Advanced boards and task assignment'
        when 'contact-support' then '[<span>Dradis Pro feature</span>] Dedicated Support team'
        when 'issuelib' then '[<span>Dradis Pro feature</span>] Integrated library of vulnerability descriptions'
        when 'projects' then '[<span>Dradis Pro feature</span>] Work with multiple projects'
        when 'remediation' then '[<span>Dradis Pro feature</span>] Integrated remediation tracker'
        when 'training-course' then 'Dradis Training Course'
        when 'try-pro' then 'Upgrade to Dradis Pro'
        when 'word-reports' then '[<span>Dradis Pro feature</span>] Custom Word reports'
        when 'excel-reports' then '[<span>Dradis Pro feature</span>] Custom Excel reports'
        when 'node-boards' then '[<span>Dradis Pro feature</span>] Node-level methodologies'

      $modal.find('.modal-header h3').html(title)
    else
      $modal.css('width', '700px')
      $modal.css('margin-left', '-350px')
      $modal.find('.modal-header h3').text('Dradis Framework editions')

    url = url +
              '?utm_source=ce&utm_medium=app&utm_campaign=try-pro&utm_term=' +
              term

    $iframe.attr('src', url)
    $('#try-pro').modal()

    # Wait for the animations to finish before resizing the .modal-body
    $modal.on 'shown', ->
      $header      = $modal.find('.modal-header')
      $body        = $modal.find('.modal-body')
      modalheight  = parseInt($modal.css('height'))
      headerheight = parseInt($header.css('height')) + parseInt($header.css('padding-top')) + parseInt($header.css('padding-bottom'))
      bodypaddings = parseInt($body.css('padding-top')) + parseInt($body.css('padding-bottom'))
      height       = modalheight - headerheight - bodypaddings - 5 # fudge factor

      $body.css('height', "#{height}px")

  if !(/^\/projects\/1(\/|$)/.test(window.location.pathname))
    $('[data-behavior~=project-teaser]').removeClass('d-none')

  if ($poller = $("#activities-poller")).length
    unless ActivitiesPoller.initialized
      ActivitiesPoller.init($poller)
      ActivitiesPoller.poll()

  # Disable form buttons after submitting them.
  $('form').submit (ev)->
    $('input[type=submit]', this).attr('disabled', 'disabled').val('Processing...')

  # Search form
  $('.navbar-nav .form-search').hover ->
    $('.navbar-nav .search-query').focus() 

  $('.form-search .btn').on 'click', (e)->
    e.preventDefault()
    if $('.navbar-nav .search-query').val() != ''
      $('.navbar-nav .form-search').submit()
    else 
      $('.navbar-nav .search-query').effect( "shake", { direction: "left", times: 2, distance: 5}, 'fast' );

  $('.navbar-nav .search-query').on 'keypress', (e)->
    if e.which == 13
      if $('.navbar-nav .search-query').val() != ''
        $('.navbar-nav .form-search').submit();
        $('.navbar-nav .seach-querty').val('Searching...') 
        return false;
      else
        $('.navbar-nav .search-query').effect( "shake", { direction: "left", times: 2, distance: 5}, 'fast' );

  # Collapsable div in sidebar collections
  if $('[data-behavior~=collapse-collection]').length
    $('[data-behavior~=collapse-collection]').click ->
      $this = $(this)
      $this.find('[data-behavior~=toggle-chevron]').toggleClass('fa-chevron-down fa-chevron-up')

      if $this.is('[data-behavior~=import-box]')
        $($this.data('target')).find("input[type='text']:first").focus()

  # Close nav collapse menu when nav dropdown menu is opened
  $('[data-behavior~=close-collapse]').on 'click', ->
    $('[data-behavior~=navbar-collapse]').collapse 'hide'
    return
