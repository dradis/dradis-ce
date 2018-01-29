# IssueImporter
#
# This object handles making server requests to search for issues, presenting
# the results and adding them to the library.

@IssueImporter =
  query: ($form) ->
    $('.results').show()
    $('.results .loading:first').parent().show()
    $('.results .placeholder:first').parent().hide()

    $.post $('.import-box:first').data('url'), $form.serialize()

    $('.results .list-item').each (idx,item) ->
      if ($(item).children('.loading').length > 0)
        $(item).show()
      else if ($(item).children('.placeholder').length > 0)
        $(item).hide()
      else
        $(item).remove()

  submit: (path, issue_text) ->
    $.post path, {issue:{text: issue_text}}
    $('.results .loading').parent().show()

  addIssue: (content) ->
    $('.results .loading').parent().hide()
    $('#issues .issue-list').prepend($(content))

  addResults: (results) ->
    $('.results .loading').parent().hide()
    if results.length > 0
      $('.results .issue-list').append( $(results) )
    else
      $('.results .placeholder:first').parent().show()




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
      $(this).parents('.accordion-group').slideUp 300, ->
        $(this).remove()
