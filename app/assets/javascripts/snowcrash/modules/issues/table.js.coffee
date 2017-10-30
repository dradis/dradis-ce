class IssuesTable extends IndexTable
  constructor: ->
    super('issue')
    $('#index-table').on('click', '#merge-selected', @onMergeSelected)

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

jQuery ->
  if $('body.issues.index').length
    new IssuesTable
