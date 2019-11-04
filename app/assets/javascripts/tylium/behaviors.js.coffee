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

      title = switch term
        when 'boards' then 'Advanced boards and task assignment <span>(Dradis Pro feature)</span>'
        when 'contact-support' then 'Dedicated Support team <span>(Dradis Pro feature)</span>'
        when 'issuelib' then 'Integrated library of vulnerability descriptions <span>(Dradis Pro feature)</span>'
        when 'projects' then 'Work with multiple projects <span>(Dradis Pro feature)</span>'
        when 'remediation' then 'Integrated remediation tracker <span>(Dradis Pro feature)</span>'
        when 'word-reports' then 'Custom Word reports <span>(Dradis Pro feature)</span>'
        when 'excel-reports' then 'Custom Excel reports <span>(Dradis Pro feature)</span>'
        when 'node-boards' then 'Node-level methodologies <span>(Dradis Pro feature)</span>'
        when 'training-course' then 'Dradis Training Course'
        when 'try-pro' then 'Upgrade to Dradis Pro'

      $modal.find('.modal-header h3').html(title)
    else
      $modal.find('.modal-header h3').text('Dradis Framework editions')

    url = url + '?utm_source=ce&utm_medium=app&utm_campaign=try-pro&utm_term=' + term

    $iframe.attr('src', url)
    $('#try-pro').modal()

  # If project id is changed in project path
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
    $('.navbar-nav .search-query').val('').focus() 

  submitSearch = ->
    if $('.navbar-nav .search-query').val() != ''
      $('.navbar-nav .form-search').submit()
      $('.navbar-nav .search-query').val('Searching...') 
      return false
    else 
      $('.navbar-nav .search-query').effect( "shake", { direction: "left", times: 2, distance: 5}, 'fast' );

  $('.form-search .btn').on 'click', (e)->
    e.preventDefault()
    submitSearch()

  $('.navbar-nav .search-query').on 'keypress', (e)->
    if e.which == 13
      submitSearch()

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
