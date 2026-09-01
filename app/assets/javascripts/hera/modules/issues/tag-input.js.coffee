class @SelectTagDropdown
  constructor: (@$target) ->
    @init()

  init: ->
    $('#issue_tag_list').val(@$target.data('tag'))
    $span = @$target.closest('.tag-input').find('.dropdown-toggle span.tag')
    $span.css('color', @$target.css('color'))
    $span.html(@$target.html())

# Called from initBehaviors() so the dropdown keeps working when the form is
# rendered into a Turbo Frame, which doesn't fire turbo:load.
@initTagInput = (parentElement) ->
  $(parentElement)
    .find('.js-taglink')
    .off('click.tagInput')
    .on 'click.tagInput', (e) ->
      $target = $(e.currentTarget)
      new SelectTagDropdown($target)
      $('#issue_tag_list').trigger('textchange')
