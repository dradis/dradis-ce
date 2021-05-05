class DradisDatatable {
  constructor(tableId) {
    this.$table = $(tableId);
    this.dataTable = null;
    this.init();
  }

  init() {
    var dataTable = this.$table.DataTable({
      pageLength: 25,
      lengthChange: false
    });

    // Assign the instantiated DataTable as a DradisDatatable property
    this.dataTable = dataTable;
    this.behaviors();
  }

  behaviors() {
    var that = this;

    document.addEventListener('turbolinks:before-cache', function() {
      that.dataTable.destroy();
    });
  }
}
