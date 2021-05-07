class DradisDatatable {
  constructor(selector) {
    this.$table = $(selector);
    if (!this.$table.length) {
      console.warn('Table not found.');
      return;
    }

    this.dataTable = null;
    this.tableHeaders = Array.from(this.$table[0].querySelectorAll('thead th, thead td'));
    this.init();
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
            columns: colvisColumnIndexes
          }
        ]
      }
    });
    this.behaviors();
  }

  behaviors() {
    this.hideColumns();
    this.unbindDataTable();
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
