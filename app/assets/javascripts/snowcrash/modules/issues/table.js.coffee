class IssuesTable extends IndexTable
  constructor: ->
    super('issue')
    $('#index-table').on('click', '.js-taglink', @onTagSelected)
    $('#index-table').on('click', '#merge-selected', @onMergeSelected)

  onTagSelected: (event) =>
    that = this
    $target = $(event.target)
    event.preventDefault()

    $('.js-items-table').find(@selectedItemsSelector).each ->
      $this = $(this)

      $row = $this.parent().parent()
      $($row.find('td')[that.tagColumnIndex]).replaceWith("<td class=\"loading\">Loading...</td>")

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

          $($row.find('td')[that.tagColumnIndex]).replaceWith(data.tag_cell)
          $("##{that.itemName}_#{item_id}").replaceWith(data["#{that.itemName}_link"])
          if $(@selectedItemsSelector).length == 0
            that.resetToolbar()

        error: (foo,bar,foobar) ->
          $($row.find('td')[that.tagColumnIndex]).replaceWith("<td class='text-error'>Please try again</td>")
      }

  onMergeSelected: (event) =>
    url = $(event.target).data('url')
    issues_to_merge = []

    $('.js-items-table').find(@selectedItemsSelector).each ->
      $row = $(this).parent().parent()

      id = @.name.split('_')[2]
      issues_to_merge.push(id)

    location.href = "#{url}?ids=#{issues_to_merge}"

  refreshToolbar: ->
    checked = $('input[type=checkbox]:checked.js-multicheck:visible').length
    if checked
      $('.js-table-actions').css('display', 'inline-block')
    else
      $('.js-table-actions').css('display', 'none')

    if checked > 1
      $('#merge-selected').css('display', 'inline-block')
    else
      $('#merge-selected').css('display', 'none')

document.addEventListener "turbolinks:load", ->
  if $('body.issues.index').length
    new IssuesTable
