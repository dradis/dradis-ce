# IssueImporter
#
# This object handles making server requests to search for issues, presenting
# the results and adding them to the library.

@IssueImporter =
  submit: (path, entry_id, issue_text, state) ->
    $.post path, { 
      entry_id: entry_id,
      issue: {
        text: issue_text, 
        state: state
      }
    }

document.addEventListener "turbo:load", ->
  if $('[data-behavior~=import-box]').length
    if $('[data-behavior~=import-issues-results]').length && $('[data-behavior=dradis-datatable]').length
      query = $('[data-behavior~=import-issues-results]').attr('data-query') || '';

      datatables_filter = $('.dataTables_filter input');
      datatables_filter.val(query);
      datatables_filter.focus();

      table = $('[data-behavior=dradis-datatable]').DataTable();
      table.search(query).draw();

    # Clicking on 'add-issue' triggers a call to Issues#create
    $('[data-behavior~=import-issues-results]').on 'click', '[data-behavior~=add-issue]', (e) ->
      issueTitle = $(this).parents('tr').find('td:first-child').text()

      e.preventDefault()
      IssueImporter.submit $(this).attr('href'), $(this).data('entry-id'), $(this).data('text'), $(this).data('state')
      $(this).parents('tr').remove()

      # Show confirmation
      $('[data-behavior~=success-alert]').remove()
      $("
      <div class='alert alert-success mt-0' data-behavior='success-alert'>#{issueTitle} issue added.</div>
      ").insertAfter($('[data-behavior~=import-issues-breadcrumb]'));
