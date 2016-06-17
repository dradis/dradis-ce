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
