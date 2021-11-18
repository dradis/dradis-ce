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
          text: '',
          tag: 'div',
          className: 'divider'
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

DradisDatatable.prototype.addEvidence = function(template_name) {
  return function() {
    console.log(template_name, 'was selected!')
  }.bind(this);
}
