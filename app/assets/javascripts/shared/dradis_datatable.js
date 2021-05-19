class DradisDatatable {
  constructor(tableElement) {
    this.$table = $(tableElement);
    this.dataTable = null;
    this.tableHeaders = Array.from(this.$table[0].querySelectorAll('thead th'));
    this.$paths = this.$table.closest('[data-behavior~=datatable-paths]');
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
            available: function(){
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
            text: 'Delete',
            className: 'btn-danger d-none',
            name: 'bulkDeleteBtn',
            action: this.bulkDelete.bind(this)
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

    this.unbindDataTable();
  }

  bulkDelete() {
    var that = this;
    var destroyConfirmation = that.$paths.data('table-destroy-confirmation') || 'Are you sure?';
    var answer = confirm(destroyConfirmation);

    if (!answer) {
      return;
    }

    var destroyUrl = that.$paths.data('table-destroy-url');
    var selectedRows = that.dataTable.rows({ selected: true });
    that.toggleBulkDeleteLoadingState(selectedRows, true);

    $.ajax({
      url: destroyUrl,
      method: 'DELETE',
      dataType: 'json',
      data: { ids: that.rowIds(selectedRows) },
      success: function(data) {
        that.handleBulkDeleteSuccess(selectedRows, data);
      },
      error: function() {
        that.handleBulkDeleteError(selectedRows);
      }
    })
  }

  toggleBulkDeleteLoadingState(rows, isLoading) {
    var bulkDeleteBtn = this.dataTable.buttons('bulkDeleteBtn:name');

    $(bulkDeleteBtn[0].node).toggleClass('disabled', isLoading);

    rows.nodes().toArray().forEach(function(tr) {
      if (isLoading) {
        $(tr).find('[data-behavior~=error-loading]').remove();
        $(tr).find('[data-behavior~=select-checkbox]').append('<div class="spinner-border spinner-border-sm text-primary" data-behavior="spinner"><span class="sr-only">Loading</div>');
      } else {
        $(tr).find('[data-behavior~=spinner]').remove();
      }
    })
  }

  handleBulkDeleteSuccess(rows, data) {
    var that = this;
    this.toggleBulkDeleteLoadingState(rows, false);

    // Remove links from sidebar
    that.rowIds(rows).forEach(function(id) {
      $(`#${that.itemName}_${id}_link`).remove();
    });

    // remove() will remove the row internally and draw() will
    // update the table visually.
    rows.remove().draw();

    this.toggleBulkDeleteBtn(false);

    if (data.success) {
      if (data.jobId) {
        // Background deletion
        this.showConsole(data.jobId);
      } else {
        // Inline deletion
        this.showAlert(data.msg, 'success');
      }
    } else {
      this.showAlert(data.msg, 'error');
    }
  }

  handleBulkDeleteError(rows) {
    this.toggleBulkDeleteLoadingState(rows, false);

    rows.nodes().toArray().forEach(function(tr) {
      $(tr).find('[data-behavior~=select-checkbox]').html('<span class="text-error pl-5" data-behavior="error-loading">Error. Try again</span>');
    })
  }

  showAlert(msg, klass) {
    this.$table.parent().find('.alert').remove();

    this.$table.parent().prepend(`
      <div class="alert alert-${klass}">
        <a class="close" data-dismiss="alert" href="javascript:void(0)">x</a>
        ${msg}
      </div>
    `);
  }

  toggleBulkDeleteBtn(isShown) {
    if (this.$paths.data('table-destroy-url') === undefined) {
      return;
    }

    // https://datatables.net/reference/api/buttons()
    var bulkDeleteBtn = this.dataTable.buttons('bulkDeleteBtn:name');

    $(bulkDeleteBtn[0].node).toggleClass('d-none', !isShown);
  }

  showConsole(jobId) {
    // the table may set the url to redirect to when closing the console
    var closeUrl = this.$paths.data('table-close-console-url');

    if (closeUrl) {
      $('#result').data('close-url', closeUrl);
    }

    // show console
    $('#modal-console').modal('show');
    ConsoleUpdater.jobId = jobId;
    $('#console').empty();
    $('#result').data('id', ConsoleUpdater.jobId);
    $('#result').show();

    // start console
    ConsoleUpdater.parsing = true;
    setTimeout(ConsoleUpdater.updateConsole, 1000);
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


  ///////////////////// Checkbox /////////////////////

  setupCheckboxListeners() {
    var that = this,
        $selectAllBtn = $(this.dataTable.buttons('#select-all').nodes()[0]);

    this.dataTable.on('select.dt deselect.dt', function() {
      $selectAllBtn.find('#select-all-checkbox').prop('checked', that.areAllSelected());

      if (that.areAllSelected()){
        $selectAllBtn.attr('title', 'Deselect all');
      }
      else {
        $selectAllBtn.attr('title', 'Select all');
      }

      var selectedCount = that.dataTable.rows({selected:true}).count();
      that.toggleBulkDeleteBtn(selectedCount !== 0);
    });

    // Remove default datatable button listener to make the checkbox "checking"
    // work, before adding our own click handler.
    $selectAllBtn.off('click.dtb').click( function (){
      if (that.areAllSelected()) {
        that.dataTable.rows().deselect();
      }
      else {
        that.dataTable.rows().select();
      }
    });
  }

  areAllSelected() {
    return(
      this.dataTable.rows({selected:true}).count() == this.dataTable.rows().count()
    );
  }
}
