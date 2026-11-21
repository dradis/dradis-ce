DradisDatatable.prototype.setupValidation = function() {
  if (this.$paths.data('table-validate-url') == undefined) {
    return;
  }

  this.setupValidationListeners();
  this.validateRecords();
}

DradisDatatable.prototype.setupValidationListeners = function() {
  // Subscribe to ValidationsChannel
  this.$table.trigger('dradis:datatable:validation');

  var that = this;

  this.dataTable.on('column-visibility.dt', function (e, settings, columnIndex, visible) {
    if (that.validationColumnIndex() == columnIndex && visible && !that.hasValidationTriggered()) {
      that.validateRecords();
    }
  });
}

DradisDatatable.prototype.validateRecords = function() {
  if (!this.isValidationColumnVisible()) {
    return;
  }

  this.$table.data('validation-triggered', true);

  const resourceType = this.validationResourceType();
  var itemsToValidate = [];

  if (resourceType !== undefined) {
    itemsToValidate = this.rowIds(this.dataTable.rows());

    if (itemsToValidate.length > 0) {
      $.ajax({
        url: this.$paths.data('table-validate-url'),
        method: 'POST',
        dataType: 'script',
        data: { ids: itemsToValidate, resource_type: resourceType },
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

DradisDatatable.prototype.hasValidationTriggered = function() {
  return this.$table.data('validation-triggered');
}

DradisDatatable.prototype.isValidationColumnVisible = function() {
  return this.dataTable.column(this.validationColumnIndex()).visible();
}

// Tables whose item name is not a model name (e.g. issue_1_evidence) set
// data-validation-resource-type. Others fall back to the capitalized item name.
DradisDatatable.prototype.validationResourceType = function() {
  const resourceType = this.$table.data('validation-resource-type');

  if (resourceType !== undefined) {
    return resourceType;
  }

  if (this.itemName !== undefined) {
    return `${this.itemName[0].toUpperCase()}${this.itemName.slice(1)}`;
  }
}

DradisDatatable.prototype.validationColumnIndex = function() {
  return this.tableHeaders.findIndex(function(th) {
    return th.dataset.column == 'validation';
  });
}
