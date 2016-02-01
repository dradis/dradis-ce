# jQuery.treeModal
#
# This plugin handles the node-selection modal tree (used for the Move node)
# operatio. See ./app/views/nodes/modals/

do ($ = jQuery, window, document) ->

  pluginName = "treeModal"

  # The actual plugin constructor
  class Plugin
    constructor: (@element) ->
      @_name = pluginName
      @init()

    init: ->
      @$el = $(@element)
      @$tree = @$el.find('.tree-modal-box')

      @$nodeParentIdHiddenInput = @$el.find("#node_parent_id")

      @disableSubmitBtn()

      current_node_container = "#node_#{@$el.data('node-id')}"

      @isDescendedFromCurrentNode = ($nodeLink) ->
        $nodeLink.parents(current_node_container).length > 0

      @$el.find("input[name='node_move_destination']").click(@selectMoveDestination)

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

      # Select the right radio button. Use 'click' instead of setting the
      # 'checked' property directly so that the associated actions get
      # triggered as well.
      @$el.find("#node_move_destination_node").click()

      $nodeLink = $(e.currentTarget)

      # Nodes can't be moved underneath one of their own descendants:
      if @isDescendedFromCurrentNode($nodeLink)
        @markAsInvalid($nodeLink)
        return false

      @makeActiveSelection($nodeLink)

      selectedNodeId = $nodeLink.parent().data('node-id')
      @$nodeParentIdHiddenInput.val(selectedNodeId)

      @$el.find('#current-selection').text($nodeLink.text())
      @enableSubmitBtn()


    selectMoveDestination: (e) =>
      $radio = $(e.currentTarget)
      if $radio.val() == "root"
        # Use 'visibility' instead of hide() so the modal's height doesn't
        # change
        @prepareForMoveToRoot()
      else
        @prepareForMoveToNode()
        @disableSubmitBtn()


    prepareForMoveToRoot: ->
      @$el.find("#move-under").hide()
      @$el.find("#move-to-root").show()
      @$el.find("#node_parent_id").val(null)
      @enableSubmitBtn()
      @$el.find("#current-selection").text("")
      @$el.find(".active-selection").removeClass("active-selection")


    prepareForMoveToNode: ->
      @$el.find("#move-under").show()
      @$el.find("#move-to-root").hide()


    disableSubmitBtn: ->
      @$el.find(".btn-primary").prop("disabled", true)


    enableSubmitBtn: ->
      @$el.find(".btn-primary").prop("disabled", false)





  $.fn[pluginName] = ->
    @each ->
      if !$.data(@, "plugin_#{pluginName}")
        $.data(@, "plugin_#{pluginName}", new Plugin(@))
