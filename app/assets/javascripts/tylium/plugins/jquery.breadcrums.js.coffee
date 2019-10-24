# jQuery.breadcrums
#
# This plugin reads the node ancestors from the tree and outputs them on the
# breadcrums div.

do ($ = jQuery, window, document) ->

  pluginName = "breadcrums"
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
      node_id = @$el.find("li:last").data('node-id')
      $tree_node = @settings.tree.find("[data-node-id='#{node_id}']")
      $tree_node.parents('[data-node-id]').each @insertElement

    insertElement: (index,element) =>
      $parent = $(element)
      parent_label = $parent.data('label')
      parent_href = $parent.data('url')
      $new_li = $("<li><a href=\"#{parent_href}\"></a> <span class=\"divider\">/</span></li>")
        .insertAfter(@$el.find('li:first'))
      $new_li.find('a:last').text(parent_label)


  $.fn[pluginName] = (options) ->
    @each ->
      if !$.data(@, "plugin_#{pluginName}")
        $.data(@, "plugin_#{pluginName}", new Plugin(@, options))
