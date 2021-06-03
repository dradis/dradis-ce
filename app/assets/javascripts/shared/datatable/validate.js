DradisDatatable.prototype.validateRecords = function() {
  if (this.$paths.data('table-validate-url') === undefined) {
    return;
  }

  var itemName = this.itemName;
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
