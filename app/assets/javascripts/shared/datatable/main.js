class DradisDatatable {
  constructor(tableElement) {
    this.$table = $(tableElement);
    this.$paths = this.$table.closest('[data-behavior~=datatable-paths]');

    this.dataTable = null;
    this.tableHeaders = Array.from(this.$table[0].querySelectorAll('thead th'));
    this.itemName = this.$table.data('item-name');

    this.init();
  }

  init() {
    var that = this;

    // Disable ability to toggle column visibility that has data-column-visible="false"
    var columnVisibleIndexes = [];
    this.tableHeaders.forEach(function(column, index) {
      if(column.dataset.columnVisible != 'false') {
        columnVisibleIndexes.push(index);
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
            available: function() {
              return that.$table.find('[data-behavior~=select-checkbox]').length;
            },
            attr: {
              id: 'select-all'
            },
            name: 'selectAll',
            text: '<label for="select-all-checkbox" class="sr-only">Select all"</label><input type="checkbox" id="select-all-checkbox" />',
            titleAttr: 'Select all'
          },
          {
            text: '<i class="fa fa-trash fa-fw"></i>Delete',
            className: 'text-danger d-none',
            name: 'bulkDeleteBtn',
            action: this.bulkDelete.bind(this)
          },
          {
            available: function() {
              return that.$paths.data('table-merge-url') !== undefined;
            },
            text: '<i class="fa fa-compress fa-fw"></i> Merge',
            name: 'mergeBtn',
            className: 'd-none',
            action: this.mergeSelected.bind(this)
          },
          {
            extend: 'colvis',
            text: '<i class="fa fa-columns mr-1"></i><i class="fa fa-caret-down"></i>',
            titleAttr: 'Choose columns to show',
            className: 'btn',
            columns: columnVisibleIndexes
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
        selector: 'td.select-checkbox',
        style: 'multi'
      }
    });

    this.validateRecords();

    this.behaviors();
  }

  behaviors() {
    this.hideColumns();

    this.setupCheckboxListeners();
    this.setupMergeButtonToggle();
    this.setupBulkDeleteButtonToggle();

    this.unbindDataTable();
  }

  hideColumns() {
    // Hide columns that has data-hide-on-load="true" on page load
    var that = this;
    that.tableHeaders.forEach(function(column, index) {
      if (column.dataset.hideOnLoad == 'true') {
        var dataTableColumn = that.dataTable.column(index);
        dataTableColumn.visible(false);
      }
    });
  }

  rowIds(rows) {
    var ids = rows.ids().toArray().map(function(id) {
      // The dom id for <tr> is in the following format: <tr id="item_name-id"></tr>,
      // so we split it by the delimiter to get the id number.
      return id.split('-')[1];
    });
    return ids;
  }

  unbindDataTable() {
    var that = this;

    document.addEventListener('turbolinks:before-cache', function() {
      that.dataTable.destroy();
    });
  }

  validateRecords() {
    if (this.$paths.data('table-validate-url') === undefined) {
      return;
    }

    var itemName = this.$table.data('item-validate-name');
    var itemsToValidate = [];

    if (itemName !== undefined) {
      var capitalizedItemType = itemName[0].toUpperCase() + itemName.slice(1);

      itemsToValidate = this.rowIds(this.dataTable.rows());

      if (itemsToValidate.length > 0) {
        $.ajax({
          url: this.$paths.data('table-validate-url'),
          method: 'POST',
          dataType: 'script',
          data: { ids: itemsToValidate, resource_type: capitalizedItemType },
          beforeSend: function() {
            $('[data-behavior~=validate-column]').addClass('loading');
          },
          success: function() {
            $('[data-behavior~=validate-column]').removeClass('loading');
          }
        });
      }
    }
  }
}
