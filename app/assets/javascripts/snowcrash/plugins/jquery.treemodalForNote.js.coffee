# jQuery.treeModal
#
# This plugin handles the node-selection modal tree FOR NOTES
# operation. See ./app/views/nodes/modals/

do ($ = jQuery, window, document) ->

  pluginName = "treeModalForNote"

  # The actual plugin constructor
  class Plugin
    constructor: (@element) ->
      @_name = pluginName
      @init()

    init: ->
      @$el = $(@element)
      @$tree = @$el.find('.tree-modal-for-note-box')
      @$el.find('.add-subnode').hide()

      @$nodeIdHiddenInput = @$el.find("#note_node_id")

      @disableSubmitBtn()

      current_node_container = "#node_#{@$el.data('node-id')}"
      @$el.find("input[name='note_move_destination']").click(@selectMoveDestination)

      # When the user selects a node to move to...
      # Bind to $tree rather than to the individual links, because not all
      # links will be present on page load (most are lazy-loaded)
      linkSelector = "a:not('.invalid-selection'):not('.toggle')"
      @$tree.on "click", linkSelector, @selectNode


    markAsInvalid: ($nodeLink) ->
      # This will prevent the click handler from being called again for this
      # particular link:
      $nodeLink.addClass('invalid-selection').attr('href', 'javascript:void(0)')


    makeActiveSelection: ($nodeLink) =>
      @$el.find('.active-selection').removeClass('active-selection')
      $nodeLink.addClass('active-selection')


    selectNode: (e) =>
      e.preventDefault()

      $nodeLink = $(e.currentTarget)

      # Nodes can't be moved underneath one of their own descendants:
      @makeActiveSelection($nodeLink)

      selectedNodeId = $nodeLink.parent().data('node-id')
      @$nodeIdHiddenInput.val(selectedNodeId)

      @$el.find('#current-selection').text($nodeLink.text())
      @enableSubmitBtn()


    selectMoveDestination: (e) =>
        @prepareForMoveToNode()
        @disableSubmitBtn()


    prepareForMoveToNode: ->
      @$el.find("#move-under").show()


    disableSubmitBtn: ->
      @$el.find(".btn-primary").prop("disabled", true)


    enableSubmitBtn: ->
      @$el.find(".btn-primary").prop("disabled", false)


  $.fn[pluginName] = ->
    @each ->
      if !$.data(@, "plugin_#{pluginName}")
        $.data(@, "plugin_#{pluginName}", new Plugin(@))
