# jQuery.confirmator
#
# This plugin displays a 'Sure you want to leave?' message if the editor has
# been changed.

do ($ = jQuery, window, document) ->

  pluginName = "confirmator"
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
      @$el.data('original-text', @$el.val())
      @$el.on 'textchange', @onChange

    onChange: (event, previousText) ->
      if $(this).data('original-text') == $(this).val()
        console.log('removed')
        window.onbeforeunload = null
      else
        console.log('installed')
        window.onbeforeunload = $.data(@, "plugin_#{pluginName}").onExit

    onExit: (e)->
      console.log('onexit')
      event = e || window.event
      message = 'Any text will block the navigation and display a prompt'

      # For IE6-8 and Firefox prior to version 4
      event.returnValue = message

      # For Chrome, Safari, IE8+ and Opera 12+
      message

    onToggle: (event)->
      console.log('oh no, we toggled away!')

  $.fn[pluginName] = (options) ->
    @each ->
      if !$.data(@, "plugin_#{pluginName}")
        $.data(@, "plugin_#{pluginName}", new Plugin(@, options))
