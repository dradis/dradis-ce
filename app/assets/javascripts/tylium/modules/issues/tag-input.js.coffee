class @SelectTagDropdown
  constructor: (@$target) ->
    @init()

  init: ->
   

document.addEventListener "turbolinks:load", ->
  $.fn.selectpicker.Constructor.BootstrapVersion = '4';
  $('#issue_tag_list').selectpicker({
    liveSearch: true
  });
