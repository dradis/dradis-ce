document.addEventListener('turbolinks:load', function() {
  $('[data-behavior~=datatable]').each(function() {
    $(this).DataTable({
      pageLength: 25,
      lengthChange: false
    });
  });
});

// Un-bind DataTable on page unload.
document.addEventListener('turbolinks:before-cache', function() {
  $('[data-behavior~=datatable]').each(function() {
    $(this).DataTable().destroy();
  });
});
