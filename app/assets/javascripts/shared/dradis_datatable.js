class DradisDatatable {
  constructor(selector) {
    this.$table = $(selector);
    this.dataTable = null;
    this.init();
  }

  init() {
    // Assign the instantiated DataTable as a DradisDatatable property
    this.dataTable = this.$table.DataTable({
      pageLength: 25,
      lengthChange: false
    });;
    this.behaviors();
  }

  behaviors() {
    this.unbindDataTable();
  }

  unbindDataTable() {
    var that = this;

    document.addEventListener('turbolinks:before-cache', function() {
      that.dataTable.destroy();
    });
  }
}
