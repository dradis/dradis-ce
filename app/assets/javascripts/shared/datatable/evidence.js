DradisDatatable.prototype.setupEvidenceButtons = function() {
  if (this.$table.data('evidence-templates') === undefined){
    return [];
  }

  // Setup evidence button collection
  var templates = this.$table.data('evidence-templates'),
      templateButtons = [
        {
          text: 'Blank',
          action: this.addEvidence('blank')
        },
        {
          tag: 'div',
          className: 'divider p-0'
        }
      ];

  templates.forEach(function(template){
    var template_id = template[0],
        template_name = template[1];

    templateButtons.push({
      text: template_name,
      action: this.addEvidence(template_id)
    });
  }.bind(this));

  return templateButtons;
}

DradisDatatable.prototype.addEvidence = function(template_id) {
  return function() {
    console.log(template_id, 'was selected!')
  }.bind(this);
}


DradisDatatable.prototype.setupEvidenceCountListener = function() {
  var that = this;
  that.$table.on('dradis:datatable:draw', function() {
    $('[data-behavior~=evidence-count]').text(that.dataTable.rows().count());
  });
}
