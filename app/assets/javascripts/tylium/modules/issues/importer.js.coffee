# IssueImporter
#
# This object handles making server requests to search for issues, presenting
# the results and adding them to the library.

@IssueImporter =
  submit: (path, issue_text) ->
    $.post path, {issue:{text: issue_text}}

document.addEventListener "turbolinks:load", ->
  if $('#issues').length
    # Detect if we're displaying results of a query and toggle the widget
    if $('.results').length
      $('.import-toggle').click();
      $('.import-box').find("input:text[value!='']").focus();
      $('.import-box').find('.control-group').removeClass('error');

    # Style as error if input has not length
    $('input.search-query').on 'blur', ->
      if $(this).val().length > 0
        $(this).closest('.control-group').removeClass('error')
      else
        $(this).closest('.control-group').addClass('error')

    # Clicking on 'add-issue' triggers a call to Issues#create
    $('.results').on 'click', 'a.add-issue', (e) ->
      e.preventDefault()
      IssueImporter.submit $(this).attr('href'), $(this).data('text')
      $(this).parents('tr').remove()
