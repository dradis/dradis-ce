DradisDatatable.prototype.setupCheckboxListeners = function() {
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

DradisDatatable.prototype.areAllSelected = function() {
  return(
    this.dataTable.rows({selected:true}).count() == this.dataTable.rows().count()
  );
}
