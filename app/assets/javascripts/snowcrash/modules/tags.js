(function ($) {
  const ready = function () {
    if ($('#tags-index').length === 0) return;
    $('.btn_save').hide();
    $('.btn_cancel').hide(); 

    const submitRow = function (url, value) {
      $.ajax({
        url : url,
        data : JSON.stringify({name: value}),
        type : 'PATCH',
        contentType : 'application/json',
        processData: false,
        dataType: 'json'
      });
      location.reload();
    }

    $(document).on('click', '#create-tag', function(event) {
      event.preventDefault;
      event.stopImmediatePropagation();
      const tagName = `!${$("#tag_color").val().substr(1)}_${$("#tag_name").val()}`;
      $.post( $(this).data("url"), {tag: {name: tagName}} );     
      location.reload();         
    });

    // Code below is a modified version of www.codewithmark.com's blog post

    // Make div editable
    $(document).on('click', '.row_data', function(event) {
      event.preventDefault(); 
      if($(this).attr('edit_type') == 'button') return false;
      $(this).closest('div').attr('contenteditable', 'true');
      $(this).addClass('bg-warning').css('padding','5px');
      $(this).focus();
    });

    // Save single field
    $(document).on('focusout', '.row_data', function(event) {
      event.preventDefault();
      if($(this).attr('edit_type') == 'button') return false;
      var row_id = $(this).closest('tr').attr('row_id'); 
      var row_div = $(this)       
      .removeClass('bg-warning')
      .css('padding','');
      var col_name = row_div.attr('col_name'); 
      var col_val = $.trim(row_div.html());
      var arr = {}; 
      var tbl_row = $(this).closest('tr');
      var url = $(tbl_row).data('url');
      tbl_row.find('.row_data').each(function(index, val) 
      {   
        var col_name = $(this).attr('col_name');  
        var col_val  =  $.trim($(this).html().replace(/&nbsp;/g, ''));
        arr[col_name] = col_val;
      });
      submitRow(url ,`!${arr["color"].substr(1)}_${arr["display_name"]}`);
      
    });

    $(document).on('click', '.btn_edit', function(event) {
      event.preventDefault();
      var tbl_row = $(this).closest('tr');
      var row_id = tbl_row.attr('row_id');
      tbl_row.find('.btn_save').show();
      tbl_row.find('.btn_cancel').show();
      tbl_row.find('.btn_edit').hide(); 
      tbl_row.find('.row_data')
      .attr('contenteditable', 'true')
      .attr('edit_type', 'button')
      .addClass('bg-warning')
      .css('padding','3px')

      tbl_row.find('.row_data').each(function(index, val) {  
        $(this).attr('original_entry', $(this).html());
      });     
    });

    $(document).on('click', '.btn_cancel', function(event) {
      event.preventDefault();
      var tbl_row = $(this).closest('tr');
      var row_id = tbl_row.attr('row_id');
      tbl_row.find('.btn_save').hide();
      tbl_row.find('.btn_cancel').hide();
      tbl_row.find('.btn_edit').show();      
      tbl_row.find('.row_data')
      .attr('edit_type', 'click')
      .removeClass('bg-warning')
      .css('padding','') 

      tbl_row.find('.row_data').each(function(index, val) 
      {   
        $(this).html( $(this).attr('original_entry') ); 
      });  
    });
    
    $(document).on('click', '.btn_save', function(event) {
      event.preventDefault();
      var tbl_row = $(this).closest('tr');
      var row_id = tbl_row.attr('row_id');
      tbl_row.find('.btn_save').hide();
      tbl_row.find('.btn_cancel').hide();      
      tbl_row.find('.btn_edit').show();
      tbl_row.find('.row_data')
      .attr('edit_type', 'click')
      .removeClass('bg-warning')
      .css('padding','') 

      var url = $(tbl_row).data('url');
      var arr = {}; 
      tbl_row.find('.row_data').each(function(index, val) 
      {   
        var col_name = $(this).attr('col_name');  
        var col_val  =  $.trim($(this).html().replace(/&nbsp;/g, ''));
        arr[col_name] = col_val;
      });

      submitRow(url ,`!${arr["color"].substr(1)}_${arr["display_name"]}`);
      $.extend(arr, {id:row_id});
    });
  }

  $(document).on('turbolinks:load', ready);
}(jQuery));





  


  