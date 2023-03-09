DradisDatatable.prototype.setupStateButtons = function() {
  if (this.$paths.data('table-state-url') === undefined){
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
      url: this.$paths.data('table-state-url'),
      method: 'PUT',
      data: { ids: that.rowIds(selectedRows), state: newState },
      beforeSend: function (){
        that.toggleLoadingState(selectedRows, true);
      },
      success: function(){
        that.toggleLoadingState(selectedRows, false);
        that.toggleStateBtn(false);

        selectedRows.deselect().remove().draw();

        $('[data-behavior="qa-alert"]').remove();
        $('.page-title').after(`
          <div class="alert alert-success" data-behavior="qa-alert">
            <a class="close" data-dismiss="alert" href="javascript:void(0)">x</a>
            Successfully set the issues as ${newState}!
          </div>
        `);
      },
      error: function(){
        that.toggleLoadingState(selectedRows, false);

        console.log('Update state error!');
      }
    });

  }.bind(this);
}

DradisDatatable.prototype.setupStateButtonToggle = function() {
  if (this.$paths.data('table-state-url') === undefined) {
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
