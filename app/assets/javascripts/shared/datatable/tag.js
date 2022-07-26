DradisDatatable.prototype.setupTagButtons = function() {
  if (this.$table.data('tags') === undefined){
    return [];
  }

  // Setup tag button collection
  var tags = this.$table.data('tags'),
    tagButtons = [];

  tags.forEach(function(tag){
    var tagColor = tag[1],
      tagFullName = tag[2],
      tagName = tag[0],
      $tagElement = $(`<i class="fa fa-tag fa-fw"></i><span>${tagName}</span></span>`).css('color', tagColor);

    tagButtons.push({
      text: $tagElement,
      action: this.tagIssue(tagFullName)
    });
  }.bind(this));
  
  // push 'add new tag' and 'manage tags' options onto end of tagButtons list
  tagButtons.push({
    text: $('<hr><i href="#modal-tag-new" data-target="#modal-tag-new" data-toggle="modal" class="fa fa-plus fa-fw"></i><span>Add new tag</span>').css('color', '##2CA02C'),
    action: function(){
      $("#modal-tag-new").appendTo("body").modal("show")
    }.bind(this)
  }, 
  {
    text: $('<i href="/projects/1/tags" id="manageTags" class="fa fa-list fa-fw"></i><span>Manage Tags</span>').css('color', '#000000'),
    action: function(){
      const btn = document.getElementById("manageTags")
      link = btn.getAttribute('href');
      window.location.href = link
    }.bind(this)
  });

  return tagButtons;
}

DradisDatatable.prototype.tagIssue = function(tagFullName) {
  return function() {
    var that = this;
    var selectedRows = this.dataTable.rows({ selected: true });

    selectedRows.every( function(index) {
      var row = that.dataTable.row(index),
        $tr = $(row.node()),
        url = $tr.data('tag-url');

      $.ajax({
        url: url,
        method: 'PUT',
        data: { issue: { tag_list: tagFullName } },
        dataType: 'json',
        beforeSend: function (){
          that.toggleLoadingState(row, true);
        },
        success: function (data){
          // Replace the current tag with the new tag in the table
          $tr.find('td[data-behavior~=tag]').replaceWith($(data.tag_cell));

          // Replace the tags in the sidebar
          var itemId = $tr.attr('id').split('-')[1];
          $('#issue_' + itemId + '_link').replaceWith(data['issue_link']);

          row.deselect();
          that.toggleLoadingState(row, false);
        },
        error: function(){
          $tr.find('[data-behavior~=select-checkbox]').html('<span class="text-error pl-5" data-behavior="error-loading">Error. Try again</span>');
          that.toggleLoadingState(row, false);
        }
      });
    });
  }.bind(this);
}

DradisDatatable.prototype.setupTagButtonToggle = function() {
  if (this.$table.data('tags') === undefined) {
    return;
  }

  this.dataTable.on('select.dt deselect.dt', function() {
    var isHidden = this.dataTable.rows({selected:true}).count() < 1;
    var tagBtn = this.dataTable.buttons('tagBtn:name');
    $(tagBtn[0].node).toggleClass('d-none', isHidden);
  }.bind(this));
}
