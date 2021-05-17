class DradisDatatable {
  constructor(tableElement) {
    this.$table = $(tableElement);
    this.dataTable = null;
    this.tableHeaders = Array.from(this.$table[0].querySelectorAll('thead th, thead td'));
    this.$paths = this.$table.closest('[data-behavior~=datatable-paths]');
    this.init();
  }

  init() {
    var that = this;

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
            autoClose: true,
            available: function(){
              return that.$table.data('tags') !== undefined;
            },
            className: 'd-none',
            extend: 'collection',
            name: 'tagBtn',
            text: '<i class="fa fa-tags"></i>Tag<i class="fa fa-caret-down"></i>',
            buttons: this.setupTagButtons()
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
    that.toggleLoadingState(selectedRows, false, 'bulkDeleteBtn');

    $.ajax({
      url: destroyUrl,
      method: 'DELETE',
      dataType: 'json',
      data: { ids: that.selectedIds() },
      success: function(data) {
        that.handleBulkDeleteSuccess(selectedRows, data);
      },
      error: function() {
        that.handleBulkDeleteError(selectedRows);
      }
    })
  }

  toggleLoadingState(rows, isLoading, buttonName) {
    var button = this.dataTable.buttons(buttonName + ':name');

    $(button[0].node).toggleClass('disabled', !isLoading);

    rows.nodes().toArray().forEach(function(tr) {
      $(tr).find('[data-behavior~=select-checkbox]').append('<div class="spinner-border spinner-border-sm text-primary"><span class="sr-only">Loading</div>');
    })
  }

  handleBulkDeleteSuccess(rows, data) {
    this.toggleLoadingState(rows, true, 'bulkDeleteBtn');

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
    this.toggleLoadingState(rows, true, 'bulkDeleteBtn');

    rows.nodes().toArray().forEach(function(tr) {
      $(tr).find('[data-behavior~=select-checkbox]').html('<span class="text-error pl-5">Error. Try again</span>');
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
    if (!this.$paths.data('table-destroy-url') === undefined) {
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

  selectedIds() {
    var selectedRows = this.dataTable.rows({ selected: true });
    var ids = selectedRows.ids().toArray().map(function(id) {
      // The dom id for <tr> is in the following format: <tr id="item_name-id"></tr>,
      // so we split it by the delimiter to get the id number.
      var idArray = id.split('-');
      return idArray[1];
    });

    return ids;
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


  ///////////////////// Tagging /////////////////////

  setupTagButtons() {
    if (this.$table.data('tags') === undefined){
      return [];
    }

    // Setup tag button collection
    var tags = this.$table.data('tags'),
      tagButtons = [];

    tags.forEach(function(tag){
      var tagColor = tag[1],
        tagFullName = tag[2],
        tagName = tag[0],
        $tagElement = $('<i>').addClass('fa fa-tag').css('color', tagColor).text(tagName);

      tagButtons.push({
        text: $tagElement[0],
        action: this.tagIssue(tagFullName)
      });
    }.bind(this));

    return tagButtons;
  }

  tagIssue(tagFullName) {
    return function() {
      var that = this;
      var selectedRows = this.dataTable.rows({ selected: true });

      selectedRows.every( function(index) {
        var row = that.dataTable.row(index),
          $tr = $(row.node()),
          url = $tr.data('tag-url');

        $.ajax({
          url: url,
          method: 'PUT',
          data: { issue: { tag_list: tagFullName } },
          dataType: 'json',
          success: function(data){
            var tagColumn = that.dataTable.column($('th:contains(Tags)')),
              tagIndex = tagColumn.index('visible');

            that.toggleLoadingState(row, true, 'tagBtn');
            row.deselect();

            // Replace the current tag with the new tag in the table
            var $newTagTD = $(data.tag_cell);
            if (!tagColumn.visible()) { $newTagTD.hide(); }
            $tr.find('td').eq(tagIndex).replaceWith($newTagTD);
          },
          error: function(){
            that.toggleLoadingState(row, true, 'tagBtn');

            $tr.find('.select-checkbox').html('<span class="text-error">Please try again</span>');
          },
          always: function(){
            that.toggleLoadingState(row, false, 'tagBtn');
          }
        });
      });
    }.bind(this);
  }

  toggleTagBtn(isShown) {
    if (this.$table.data('tags') === undefined){
      return;
    }

    var tagBtn = this.dataTable.buttons('tagBtn:name');
    $(tagBtn[0].node).toggleClass('d-none', !isShown);
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
      that.toggleTagBtn(selectedCount !== 0);
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
