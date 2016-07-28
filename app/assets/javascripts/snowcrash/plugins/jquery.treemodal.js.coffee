# jQuery.treeModal
#
# This plugin handles the node-selection modal tree (used for Move node and Move note)
# operatio. See ./app/views/nodes/modals/

do ($ = jQuery, window, document) ->

  pluginName = "treeModal"
  defaults =
    type: "node"

  # The actual plugin constructor
  class Plugin
    constructor: (@element, options) ->
      @_name = pluginName
      @options = $.extend {}, defaults, options
      @init()

    init: ->
      @$el = $(@element)
      @$tree = @$el.find('.tree-modal-box')

      context = this
      $('a[href$="#modal_move"]').click ->
        context.updateForm(this)

      @disableSubmitBtn()

      current_node_container = "#node_#{@$el.data('node-id')}"

      @isDescendedFromCurrentNode = ($nodeLink) ->
        if @options.type == "note"
          $nodeLink.parent(current_node_container).length > 0
        else
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

    updateForm: (e) ->
      @options.type = $(e).data("move")
      @options.node_id = $(e).data("move-node-id")
      @options.note_id = $(e).data("move-note-id") || undefined
      @options.original_updated_at = $(e).data("move-original-updated-at") || undefined
      @options.title = $(e).data("move-note-title") || undefined
      @options.label = $(e).data("move-node-label") || undefined

      if @options.type == "note"
        @$nodeParentIdHiddenInput = @$el.find("#note_node_id")

        # change form action /nodes/5/notes/5
        @$el.attr('action', '/nodes/' + @options.node_id + '/notes/' + @options.note_id);
        # disable node_parent_id
        @$el.find("#node_parent_id").prop("disabled", true)
        # enable note_node_id and add value
        @$el.find("#note_node_id").prop("disabled", false).val(@options.note_id)
        # enable note_original_updated_at and add value
        @$el.find("#note_original_updated_at").prop("disabled", false).val(@options.original_updated_at)
        # select #node_move_destination_node
        @$el.find("#node_move_destination_node").prop("checked", true)
        # hide #move-to-root
        @$el.find("#move-to-root").hide()
        # hide .moveNodeOnly
        @$el.find(".moveNodeOnly").hide()
        # update #myModalLabel text
        @$el.find("#myModalLabel").html("Move " + @options.title + " note")
        # update #myModalText text
        @$el.find("#myModalText").html("Where do you want to move the <strong>" + @options.title + "</strong> note?")
      else
        @$nodeParentIdHiddenInput = @$el.find("#node_parent_id")

        # change action /nodes/5
        @$el.attr('action', '/nodes/' + @options.node_id)
        # enable node_parent_id and add value
        @$el.find("#node_parent_id").prop("disabled", false).val(@options.node_id)
        # disable note_node_id
        @$el.find("#note_node_id").prop("disabled", true)
        # disable note_original_updated_at
        @$el.find("#note_original_updated_at").prop("disabled", true)
        # show #move-to-root
        @$el.find("#move-to-root").show()
        # show .moveNodeOnly
        @$el.find(".moveNodeOnly").show()
        # update #myModalLabel text
        @$el.find("#myModalLabel").html("Move " + @options.label + " node")
        # update #myModalText text
        @$el.find("#myModalText").html("Where do you want to move the <strong>" + @options.label + "</strong> node?")

  $.fn[pluginName] = (options) ->
      @each ->
        if !$.data(@, "plugin_#{pluginName}")
          $.data(@, "plugin_#{pluginName}", new Plugin(@, options))