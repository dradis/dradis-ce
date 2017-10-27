jQuery ->
  if $('body.issues.index').length
    indexTable = new IndexTable('issue')

    onMergeSelected = (event) =>
      url = $(event.target).data('url')
      issues_to_merge = []

      $('.js-items-table').find(indexTable.selectedItemsSelector).each ->
        $row = $(this).parent().parent()

        id = @.name.split('_')[1]
        issues_to_merge.push(id)

      location.href = "#{url}?ids=#{issues_to_merge}"

    refreshToolbar = ->
      checked = $('input[type=checkbox]:checked.js-multicheck:visible').length
      if checked
        $('.js-table-actions').css('display', 'inline-block')
      else
        $('.js-table-actions').css('display', 'none')

      if checked > 1
        $('#merge-selected').css('display', 'inline-block')
      else
        $('#merge-selected').css('display', 'none')

    # Handle the merge issues button click
    $('#index-table').on('click', '#merge-selected', onMergeSelected)
    $('#index-table').on('click', '.js-select-all-items, input[type=checkbox].js-multicheck', refreshToolbar)
