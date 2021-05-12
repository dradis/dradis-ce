class DradisDatatable {
  constructor(tableElement) {
    this.$table = $(tableElement);
    this.dataTable = null;
    this.tableHeaders = Array.from(this.$table[0].querySelectorAll('thead th, thead td'));
    this.$paths = this.$table.closest('[data-behavior~=datatable-paths]');
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

    var that = this;

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
            text: 'Delete',
            className: 'btn-danger d-none',
            name: 'bulkDeleteBtn',
            action: function (event, dataTable, node, config) {
              var destroyConfirmation = that.$paths.data('table-destroy-confirmation') || 'Are you sure?';
              var answer = confirm(destroyConfirmation);

              if (!answer) {
                return;
              }

              var destroyUrl = that.$paths.data('table-destroy-url');
              var selectedRows = dataTable.rows({ selected: true });
              var ids = selectedRows.ids().toArray().map(function(id) {
                // The dom id for <tr> is in the following format: <tr id="item_name-id"></tr>,
                // so we split it by the delimiter to get the id number.
                var idArray = id.split('-');
                return idArray[idArray.length - 1];
              });

              $.ajax({
                url: destroyUrl,
                method: 'DELETE',
                dataType: 'json',
                data: { ids: ids },
                success: function(data) {
                  that.handleBulkDeleteSuccess(selectedRows, data);
                },
                error: function() {
                  that.handleBulkDeleteError(selectedRows);
                }
              })
            }
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

  handleBulkDeleteSuccess(rows, data) {
    // remove() will remove the row internally and draw() will
    // update the table visually.
    rows.remove().draw();
    this.showBulkDeleteBtn(false);

    if (data.success) {
      if (data.jobId) {
        // background deletion
        this.showConsole(data.jobId);
      } else {
        // inline deletion
        this.showAlert(data.msg, 'success');
      }
    } else {
      this.showAlert(data.msg, 'error');
    }
  }

  handleBulkDeleteError(rows) {
    rows.nodes().toArray().forEach(function(tr) {
      tr.querySelectorAll('td')[2].innerHTML = '<span class="text-error">Please try again</span>';
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

  showBulkDeleteBtn(boolean) {
    if (!this.$paths.data('table-destroy-url').length) {
      return;
    }

    // https://datatables.net/reference/api/buttons()
    var bulkDeleteBtn = this.dataTable.buttons('bulkDeleteBtn:name');
    if (boolean) {
      bulkDeleteBtn[0].node.classList.remove('d-none');
    } else {
      bulkDeleteBtn[0].node.classList.add('d-none');
    }
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

  setupListeners() {
    var that = this;

    this.dataTable.on('select.dt', function(e, dt, type, indexes) {
      if (that.dataTable.rows({selected:true}).count() == that.dataTable.rows().count()) {
        $('#select-all').prop('checked', true);
      }

      if (that.dataTable.rows({selected:true}).count()) {
        that.showBulkDeleteBtn(true);
      }
    });

    this.dataTable.on('deselect.dt', function(e, dt, type, indexes) {
      $('#select-all').prop('checked', false);

      if (that.dataTable.rows({selected:true}).count() === 0) {
        that.showBulkDeleteBtn(false);
      }
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
