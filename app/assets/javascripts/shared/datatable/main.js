class DradisDatatable {
  constructor(tableElement) {
    this.$table = $(tableElement);
    this.$paths = this.$table.closest('[data-behavior~=datatable-paths]');

    this.dataTable = null;
    this.itemName = this.$table.data('item-name');
    this.localStorageKey = this.$table.data('local-storage-key');
    this.legacyStorageKey = this.$table.data('legacy-storage-key');
    this.tableHeaders = Array.from(this.$table[0].querySelectorAll('thead th'));

    if (localStorage.getItem(this.legacyStorageKey) !== null) {
      this.defaultColumns = localStorage.getItem(this.legacyStorageKey);
    }
    else {
      var defaultColumns = this.$table.data('default-columns') || [];
      this.defaultColumns = defaultColumns.concat(['select', 'actions']);
    }

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

    // Only show default columns on first load
    var hiddenColumnIndexes = [];
    if (localStorage.getItem(this.localStorageKey) === null) {
      this.tableHeaders.forEach(function(column, index) {
        var columnName = column.textContent.trim();

        if (!that.defaultColumns.includes(columnName.toLowerCase())) {
          hiddenColumnIndexes.push(index);
        }
      });
    }

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
            attr: {
              'data-behavior': 'table-action'
            },
            text: '<i class="fa fa-trash fa-fw"></i>Delete',
            className: 'text-danger d-none',
            name: 'bulkDeleteBtn',
            action: this.bulkDelete.bind(this)
          },
          {
            attr: {
              'data-behavior': 'table-action'
            },
            available: function() {
              return that.$paths.data('table-merge-url') !== undefined;
            },
            text: '<i class="fa fa-compress fa-fw"></i> Merge',
            name: 'mergeBtn',
            className: 'd-none',
            action: this.mergeSelected.bind(this)
          },
          {
            attr: {
              'data-behavior': 'table-action'
            },
            autoClose: true,
            available: function(){
              return that.$table.data('tags') !== undefined;
            },
            className: 'd-none',
            extend: 'collection',
            name: 'tagBtn',
            text: '<i class="fa fa-tags fa-fw"></i>Tag<i class="fa fa-caret-down fa-fw"></i>',
            buttons: this.setupTagButtons()
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
      columnDefs: [
        {
          targets: hiddenColumnIndexes,
          visible: false
        }
      ],
      dom: "<'row'<'col-lg-6'B><'col-lg-6'f>>" +
        "<'row'<'col-lg-12'tr>>" +
        "<'dataTables_footer_content'ip>",
      initComplete: function (settings) {
        settings.oInstance.wrap("<div class='table-wrapper'></div>");
      },
      lengthChange: false,
      pageLength: 25,
      stateSave: true,
      stateSaveCallback: function(settings, data) {
        localStorage.setItem(that.localStorageKey, JSON.stringify(data));
      },
      stateLoadCallback: function(settings) {
        return JSON.parse(localStorage.getItem(that.localStorageKey));
      },
      select: {
        selector: 'td.select-checkbox',
        style: 'multi'
      }
    });

    this.validateRecords();

    this.behaviors();
  }

  behaviors() {
    this.setupCheckboxListeners();
    this.setupMergeButtonToggle();
    this.setupTagButtonToggle();
    this.setupBulkDeleteButtonToggle();

    this.unbindDataTable();
  }

  toggleLoadingState(rows, isLoading) {
    var buttons = this.dataTable.buttons('[data-behavior~=table-action]').nodes();

    $(buttons).toggleClass('disabled', isLoading);

    rows.nodes().toArray().forEach(function(tr) {
      if (isLoading) {
        $(tr).find('[data-behavior~=error-loading]').remove();
        $(tr).find('[data-behavior~=select-checkbox]').append('<div class="spinner-border spinner-border-sm text-primary" data-behavior="spinner"><span class="sr-only">Loading</div>');
      } else {
        $(tr).find('[data-behavior~=spinner]').remove();
      }
    })
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
}
