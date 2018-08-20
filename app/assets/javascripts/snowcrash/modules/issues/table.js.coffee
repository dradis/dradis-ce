class IssuesTable extends ItemsTable

  afterInitialize: ->
    @$jsTable.on('click', '.js-taglink', @onTagSelected)
    @$jsTable.on('click', '#merge-selected', @onMergeSelected)

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
          $("##{that.itemName}_#{item_id}").replaceWith(data["#{that.itemName}_link"])
          if $(that.selectedItemsSelector).length == 0
            that.resetToolbar()

        error: (foo,bar,foobar) ->
          $($row.find('td')[tagColumnIndex]).replaceWith("<td class='text-error'>Please try again</td>")
      }

  onMergeSelected: (event) =>
    url = $(event.target).data('url')
    issues_to_merge = []

    $(@selectedItemsSelector).each ->
      $row = $(this).parent().parent()

      id = @.name.split('_')[2]
      issues_to_merge.push(id)

    location.href = "#{url}?ids=#{issues_to_merge}"

  refreshToolbar: =>
    checked = $(@selectedItemsSelector).length
    if checked
      $('.js-items-table-actions').css('display', 'inline-block')
    else
      $('.js-items-table-actions').css('display', 'none')

    if checked > 1
      $('#merge-selected').css('display', 'inline-block')
    else
      $('#merge-selected').css('display', 'none')

document.addEventListener "turbolinks:load", ->
  if $('body.issues.index').length
    new IssuesTable('#issues-table', 'issue')
