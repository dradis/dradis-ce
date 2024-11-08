DradisDatatable.prototype.setupReorderListener = function () {
  const table = this.dataTable;
  table.on('row-reorder', function (e, diff, edit) {
    for (var i = 0, ien = diff.length; i < ien; i++) {
      console.log('Reorder Occurred:');
      console.log(
        `Row ${diff[i].oldData} updated to be in position ${diff[i].newData}`
      );
      console.log('Event Data', e);
      console.log('Diff Data', diff);
      console.log('Edit Data', edit);
      console.log('----------');
    }
  });
};
