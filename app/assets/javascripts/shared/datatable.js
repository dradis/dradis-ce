document.addEventListener('turbolinks:load', function() {
  $('[data-behavior~=datatable]').each(function() {
    $(this).DataTable({
      // https://datatables.net/reference/option/dom,
      // The 'dom' attribute defines the order of elements in a DataTable.
      dom: 'Bfrtip',
      pageLength: 25,
      lengthChange: false,
      buttons: {
        dom: {
          button: {
            tag: 'button',
            className: 'btn'
          }
        },
        buttons: [
          {
            extend: 'colvis',
            text: '<i class="fa fa-columns"></i><i class="fa fa-caret-down"></i>',
            titleAttr: 'Choose columns to show',
            className: 'btn',
          }
        ]
      }
    });
  });
});

// Un-bind DataTable on page unload.
document.addEventListener('turbolinks:before-cache', function() {
  $('[data-behavior~=datatable]').each(function() {
    $(this).DataTable().destroy();
  });
});
