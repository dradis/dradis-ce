class DradisDatatable {
  constructor(tableElement) {
    this.$table = $(tableElement);
    if (!this.$table.length) {
      console.warn('Table not found.');
      return;
    }
    this.dataTable = null;
    this.$paths = this.$table.closest('[data-behavior~=paths]');
    this.tableHeaders = Array.from(this.$table[0].querySelectorAll('thead th, thead td'));
    this.init();
    this.setupListeners();
  }

  init() {
    var that = this;

    var colvisColumnIndexes = this.tableHeaders.reduce(function(indexes, column, index) {
      if(column.dataset.colvis != 'false') {
        indexes.push(index);
      }
      return indexes;
    }, []);

    // Assign the instantiated DataTable as a DradisDatatable property
    this.dataTable = this.$table.DataTable({
      // https://datatables.net/reference/option/dom,
      // The 'dom' attribute defines the order of elements in a DataTable.
      dom: 'Bfrtip',
      pageLength: 25,
      lengthChange: false,
      columnDefs: [ {
        orderable: false,
        className: 'select-checkbox',
        targets:   0
      } ],
      select: {
        selector: 'td:first-child',
        style: 'multi'
      },
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
              var destroyUrl = that.$paths.data('destroy-url');
              var selectedRows = dataTable.rows({ selected: true });
              var ids = selectedRows.ids().toArray();
              $.ajax({
                url: destroyUrl,
                method: 'DELETE',
                dataType: 'json',
                data: { ids: ids },
                success: function(data) {
                  // remove() will remove the row internally and draw() will
                  // update the table visually.
                  selectedRows.remove().draw();
                  that.showBulkDeleteBtn(false);

                  if (data.success) {
                    if (data.jobId) {
                      // background deletion
                      that.showConsole(data.jobId);
                    } else {
                      // inline deletion
                      that.showAlert(data.msg, 'success');
                    }
                  } else {
                    that.showAlert(data.msg, 'error');
                  }
                },
                error: function() {
                  selectedRows.nodes().toArray().forEach(function(tr) {
                    tr.querySelectorAll('td')[2].innerHTML = '<span class="text-error">Please try again</span>';
                  })
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
      }
    });

    this.behaviors();
  }

  behaviors() {
    this.unbindDataTable();
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
    var closeUrl = this.$paths.data('close-console-url');

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

  unbindDataTable() {
    var that = this;

    that.hideColumns();

    document.addEventListener('turbolinks:before-cache', function() {
      that.dataTable.destroy();
    });
  }

  hideColumns() {
    var that = this;
    that.tableHeaders.forEach(function(column, index) {
      if (column.dataset.visible == 'false') {
        var dataTableColumn = that.dataTable.column(index);
        dataTableColumn.visible(false);
      }
    });
  }
}
