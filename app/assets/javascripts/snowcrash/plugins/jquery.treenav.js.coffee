# jQuery.treeNav
#
# This plugin handles the showing/hiding beviour of the nodes in the tree
# along with the 'Add node' and 'add subnode' forms.

do ($ = jQuery, window, document) ->

  pluginName = "treeNav"
  defaults =
    property: "value"

  # The actual plugin constructor
  class Plugin
    constructor: (@element, options) ->
      @settings = $.extend {}, defaults, options
      @_defaults = defaults
      @_name = pluginName
      @init()

    init: ->
      @$el = $(@element)
      @$el.on 'click', 'a.toggle', @toggleChildren
      path = window.location.pathname
      if NODE_ID_REGEX.test(path)
        nodeId = @getNodeIdFromPath(path)
        @openNode(nodeId)

    loadChildren: (target) =>
      if !target.siblings('.children').first().has('li.node').length
        $menu = target.siblings('.children')
        $.get(target.attr 'href')
        .fail ->
          $menu.find('li.loading').hide()
          $menu.find('li.error').show()


    openNode: (nodeId) =>
      node = @$el.find("li[data-node-id=#{nodeId}]")
      siblings = node.parent('ul.children')
      if siblings.length
        siblings.show().addClass('opened')
      parent = siblings.parent()
      parentNodeId = parent.data('node-id')
      parent.children('a.toggle').find('i').addClass('fa-caret-down').removeClass('fa-caret-right')

      @openNode(parentNodeId) if parentNodeId

    toggleChildren: (e) =>
      e.preventDefault()
      e.stopPropagation()
      target = $(e.currentTarget)
      children = target.siblings('.children').first()

      if children.hasClass('opened')
        children.slideUp(200)
      else
        that = this
        children.slideDown(200, -> that.loadChildren(target))

      children.toggleClass('opened')

      target.find('i')
        .toggleClass('fa-caret-right')
        .toggleClass('fa-caret-down')


    getNodeIdFromPath: (path) =>
      parseInt(path.match(NODE_ID_REGEX)[2], 10)

    NODE_ID_REGEX = /^(\/pro)?\/nodes\/(\d+)/



  $.fn[pluginName] = (options) ->
    @each ->
      if !$.data(@, "plugin_#{pluginName}")
        $.data(@, "plugin_#{pluginName}", new Plugin(@, options))
