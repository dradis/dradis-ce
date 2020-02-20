# jQuery.breadcrumbs
#
# This plugin reads the node ancestors from the tree and outputs them on the
# breadcrumbs div.

do ($ = jQuery, window, document) ->

  pluginName = "breadcrumbs"
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
      @$el.attr('data-breadcrumed', true)

    insertElement: (index,element) =>
      $parent = $(element)
      parent_label = $parent.data('label')
      parent_href = $parent.data('url')
      $new_li = $("<li class='breadcrumb-item'><a href=\"#{parent_href}\"></a></li>")
        .insertAfter(@$el.find('li:first'))
      $new_li.find('a:last').text(parent_label)


  $.fn[pluginName] = (options) ->
    @each ->
      unless $(@).data('breadcrumed')
        new Plugin(@, options)
