class IssuesTable extends ItemsTable

  afterInitialize: ->
    @$jsTable.on('click', '#merge-selected', @onMergeSelected)
    @$jsTable.on('click', '[data-behavior~=change-state]', @onStateChangeSelected)
    @$jsTable.on('click', '.js-taglink', @onTagSelected)

  onMergeSelected: (event) =>
    url = $(event.target).data('url')
    issues_to_merge = []

    $(@selectedItemsSelector).each ->
      $row = $(this).parent().parent()

      id = @.name.split('_')[2]
      issues_to_merge.push(id)

    location.href = "#{url}?ids=#{issues_to_merge}"

  onStateChangeSelected: (event) =>
    $target = $(event.target)
    stateColumnIndex = @columnIndices['state']
    targetState = $target.data('state')

    issues_to_update = []
    $(@selectedItemsSelector).each ->
      $row = $(this).parent().parent()
      $stateTD = $row.find('td').eq(stateColumnIndex)
      $stateTD.removeClass().addClass('loading').text('Loading...')

      id = @.name.split('_')[2]
      issues_to_update.push(id)

    that = this
    $.ajax $target.parent().data('url'), {
      method: 'PUT',
      data: { ids: issues_to_update, state: targetState },
      success: (data) ->
        $(that.selectedItemsSelector).each ->
          $row = $(this).parent().parent()
          $stateTD = $row.find('td').eq(stateColumnIndex)
          $stateTD.data('sort-value', targetState)
          $stateTD.removeClass('loading')

          # Capitalized
          $stateTD.text(targetState.charAt(0).toUpperCase() + targetState.slice(1))
    }

  onTagSelected: (event) =>
    that = this
    $target = $(event.target)
    tagColumnIndex = @columnIndices['tags']
    tagColIsHidden = !$('th[data-column=tags]').is(':visible')
    event.preventDefault()

    $(@selectedItemsSelector).each ->
      $this = $(this)

      $row = $this.parent().parent()
      $tagTD = $row.find('td').eq(tagColumnIndex)
      $tagTD.removeClass().addClass('loading').text('Loading...')

      url   = $this.data('url')
      data  = {}
      data[that.itemName] = { tag_list: $target.data('tag') }

      $.ajax url, {
        method: 'PUT',
        data: data,
        dataType: 'json',
        success: (data) ->
          $this.prop('checked', false)
          item_id = $this.val()

          $newTagTD = $(data.tag_cell)
          $newTagTD.hide() if tagColIsHidden
          $tagTD.replaceWith($newTagTD)
          # Update the link in the sidebar:
          $("##{that.itemName}_#{item_id}_link").replaceWith(data["#{that.itemName}_link"])
          if $(that.selectedItemsSelector).length == 0
            that.resetToolbar()

        error: (foo,bar,foobar) ->
          $($row.find('td')[tagColumnIndex]).replaceWith("<td class='text-error'>Please try again</td>")
      }

  refreshToolbar: =>
    checked = $(@selectedItemsSelector).length
    if checked
      $('.js-items-table-actions').css('display', 'inline-flex')
    else
      $('.js-items-table-actions').css('display', 'none')

    if checked > 1
      $('#merge-selected').css('display', 'inline-block')
    else
      $('#merge-selected').css('display', 'none')

document.addEventListener "turbolinks:load", ->
  if $('body.issues.index').length
    new IssuesTable('#issues-table', 'issue')
