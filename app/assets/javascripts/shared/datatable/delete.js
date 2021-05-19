DradisDatatable.prototype.bulkDelete = function() {
  var that = this;
  var destroyConfirmation = that.$paths.data('table-destroy-confirmation') || 'Are you sure?\n\nProceeding will delete the selected item(s).';
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

DradisDatatable.prototype.toggleBulkDeleteLoadingState = function(rows, isLoading) {
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

DradisDatatable.prototype.handleBulkDeleteSuccess = function(rows, data) {
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

DradisDatatable.prototype.handleBulkDeleteError = function(rows) {
  this.toggleBulkDeleteLoadingState(rows, false);

  rows.nodes().toArray().forEach(function(tr) {
    $(tr).find('[data-behavior~=select-checkbox]').html('<span class="text-error pl-5" data-behavior="error-loading">Error. Try again</span>');
  })
}

DradisDatatable.prototype.showAlert = function(msg, klass) {
  this.$table.parent().find('.alert').remove();

  this.$table.parent().prepend(`
    <div class="alert alert-${klass}">
      <a class="close" data-dismiss="alert" href="javascript:void(0)">x</a>
      ${msg}
    </div>
  `);
}

DradisDatatable.prototype.setupBulkDeleteButtonToggle = function() {
  if (this.$paths.data('table-destroy-url') === undefined) {
    return;
  }

  this.dataTable.on('select.dt deselect.dt', function() {
    var selectedCount = this.dataTable.rows({selected:true}).count();
    this.toggleBulkDeleteBtn(selectedCount !== 0);
  }.bind(this));

}

DradisDatatable.prototype.toggleBulkDeleteBtn = function(isShown) {
  // https://datatables.net/reference/api/buttons()
  var bulkDeleteBtn = this.dataTable.buttons('bulkDeleteBtn:name');
  $(bulkDeleteBtn[0].node).toggleClass('d-none', !isShown);
}

DradisDatatable.prototype.showConsole = function(jobId) {
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
