DradisDatatable.prototype.setupStateButtons = function() {
  if (this.$paths.data('state-url') === undefined){
    return [];
  }

  var states = ['Draft', 'Published'],
    stateButtons = [];

  states.forEach(function(state){
    var $stateElement = $(`<span>${state}</span>`);

    stateButtons.push({
      text: $stateElement,
      action: this.updateIssueState(state)
    });
    }.bind(this)
  );

  return stateButtons;
};

DradisDatatable.prototype.updateIssueState = function(newState) {
  return function() {
    var that = this;
    var selectedRows = this.dataTable.rows({ selected: true });

    $.ajax({
      url: this.$paths.data('state-url'),
      method: 'PUT',
      data: { ids: that.rowIds(selectedRows), state: newState },
      beforeSend: function (){
        that.toggleLoadingState(selectedRows, true);
      },
      success: function(){
        that.toggleLoadingState(selectedRows, false);

        selectedRows.deselect().remove().draw();

        that.toggleStateBtn(false);
      },
      error: function(){
        that.toggleLoadingState(selectedRows, false);

        console.log('Update state error!');
      }
    });

  }.bind(this);
}

DradisDatatable.prototype.setupStateButtonToggle = function() {
  if (this.$paths.data('state-url') === undefined) {
    return;
  }

  this.dataTable.on('select.dt deselect.dt', function() {
    var selectedCount = this.dataTable.rows({selected:true}).count();
    this.toggleStateBtn(selectedCount !== 0);
  }.bind(this));

}

DradisDatatable.prototype.toggleStateBtn = function(isShown) {
  var stateBtn = this.dataTable.buttons('stateBtn:name');
  $(stateBtn[0].node).toggleClass('d-none', !isShown);
}
