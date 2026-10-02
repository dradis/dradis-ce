document.addEventListener('turbo:load', () => {
  if ($('[data-behavior~=import-box]').length) {
    if ($('[data-behavior~=import-issues-results]').length && $('[data-behavior=dradis-datatable]').length) {
      const query = $('[data-behavior~=import-issues-results]').attr('data-query') || '';

      const datatablesFilter = $('.dataTables_filter input');
      datatablesFilter.val(query);
      datatablesFilter.focus();

      const table = $('[data-behavior=dradis-datatable]').DataTable();
      table.search(query).draw();
    }

    // Clicking on 'add-issue' triggers a call to Issues#create
    $('[data-behavior~=import-issues-results]').on('click', '[data-behavior~=add-issue]', function (e) {
      const issueTitle = $(this).parents('tr').find('td:first-child').text();

      e.preventDefault();
      $.post($(this).attr('href'), {
        entry_id: $(this).data('entry-id'),
        issue: {
          text: $(this).data('text'),
          state: $(this).data('state')
        }
      });
      $(this).parents('tr').remove();

      // Show confirmation
      $('[data-behavior~=success-alert]').remove();
      $("<div class='alert alert-success mt-0' data-behavior='success-alert'></div>")
        .text(`${issueTitle} issue added.`)
        .insertAfter($('[data-behavior~=import-issues-breadcrumb]'));
    });
  }
});
