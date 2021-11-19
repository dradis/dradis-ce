DradisDatatable.prototype.setupEvidenceCountListener = function() {
  var that = this;
  that.$table.on('dradis:datatable:draw', function() {
    $('[data-behavior~=evidence-count]').text(that.dataTable.rows().count());
  });
}
