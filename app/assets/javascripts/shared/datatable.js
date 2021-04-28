document.addEventListener('turbolinks:load', function() {
  $('[data-behavior~=datatable]').each(function() {
    $(this).DataTable();
  });
});
