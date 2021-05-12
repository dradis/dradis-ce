class DradisDatatable {
  constructor(tableElement) {
    this.$table = $(tableElement);
    this.dataTable = null;
    this.tableHeaders = Array.from(this.$table[0].querySelectorAll('thead th, thead td'));
    this.init();
    this.setupListeners();
  }

  init() {
    // Remove dropdown option for <th> columns that has data-colvis="false" in colvis button
    var colvisColumnIndexes = [];
    this.tableHeaders.forEach(function(column, index) {
      if(column.dataset.colvis != 'false') {
        colvisColumnIndexes.push(index);
      }
    });

    // Assign the instantiated DataTable as a DradisDatatable property
    this.dataTable = this.$table.DataTable({
      autoWidth: false,
      buttons: {
        dom: {
          button: {
            tag: 'button',
            className: 'btn'
          }
        },
        buttons: [
          {
            extend: 'selectAll',
            text: '<input type="checkbox" id="select-all" />',
            titleAttr: 'Select all'
          },
          {
            extend: 'colvis',
            text: '<i class="fa fa-columns mr-1"></i><i class="fa fa-caret-down"></i>',
            titleAttr: 'Choose columns to show',
            className: 'btn',
            columns: colvisColumnIndexes
          }
        ]
      },
      dom: "<'row'<'col-lg-6'B><'col-lg-6'f>>" +
        "<'row'<'col-lg-12'tr>>" +
        "<'dataTables_footer_content'ip>",
      initComplete: function (settings) {
        settings.oInstance.wrap("<div class='table-wrapper'></div>");
      },
      lengthChange: false,
      pageLength: 25,
      select: {
        selector: 'td:first-child',
        style: 'multi'
      }
    });

    this.behaviors();
  }

  behaviors() {
    this.hideColumns();
    this.unbindDataTable();
  }

  setupListeners() {
    var that = this;

    this.dataTable.on('select.dt', function(e, dt, type, indexes) {
      if (that.dataTable.rows({selected:true}).count() == that.dataTable.rows().count()) {
        $('#select-all').prop('checked', true);
      }
    });

    this.dataTable.on('deselect.dt', function(e, dt, type, indexes) {
      $('#select-all').prop('checked', false);
    });
  }

  hideColumns() {
    // Hide <th> columns that has data-visible="false"
    var that = this;
    that.tableHeaders.forEach(function(column, index) {
      if (column.dataset.visible == 'false') {
        var dataTableColumn = that.dataTable.column(index);
        dataTableColumn.visible(false);
      }
    });
  }

  unbindDataTable() {
    var that = this;

    document.addEventListener('turbolinks:before-cache', function() {
      that.dataTable.destroy();
    });
  }
}
