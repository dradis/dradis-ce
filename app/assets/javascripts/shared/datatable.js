document.addEventListener('turbolinks:load', function() {
  $('[data-behavior~=datatable]').each(function() {
    var defaultColumns = $(this).data('defaultColumns');
    var hiddenColumnsIndexes = [];

    var excludeColvisColumns = $(this).data('excludeColvisColumns');
    var colvisColumnsIndexes = [];

    $(this).find('thead th, thead td').each(function(index, element) {
      // Hide certain options in ColumnVisibility dropdown.
      if (excludeColvisColumns && !excludeColvisColumns.includes(element.textContent)) {
        colvisColumnsIndexes.push(index);
      }

      // Hide certain columns on load.
      if (defaultColumns && !defaultColumns.includes(element.textContent)) {
        hiddenColumnsIndexes.push(index)
      }
    });

    var dataTable = $(this).DataTable({
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
            text: '<i class="fa fa-columns mr-1"></i><i class="fa fa-caret-down"></i>',
            titleAttr: 'Choose columns to show',
            className: 'btn',
            columns: colvisColumnsIndexes
          }
        ]
      },
      columnDefs: [
        {
          targets: hiddenColumnsIndexes,
          visible: false
        }
      ]
    });
  });
});

// Un-bind DataTable on page unload.
document.addEventListener('turbolinks:before-cache', function() {
  $('[data-behavior~=datatable]').each(function() {
    $(this).DataTable().destroy();
  });
});
