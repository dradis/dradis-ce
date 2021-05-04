document.addEventListener('turbolinks:load', function() {
  $('[data-behavior~=datatable]').each(function() {
    $(this).DataTable({
      autoWidth: false,
      dom: "<'row'<'col-lg-6'><'col-lg-6'f>>" +
      "<'row'<'col-lg-12'tr>>" +
      "<'dataTables_footer_content'lip>",
      fixedHeader: {
        header: true,
        headerOffset: $('[data-behavior~=navbar]').height() //FIXME: header is not fixed/sticky.
      },
      initComplete: function () {  
        $('[data-behavior~=datatable]').wrap("<div class='table-wrapper'></div>");            
      },
      pageLength: 25,
    });
  });
});

// Un-bind DataTable on page unload.
document.addEventListener('turbolinks:before-cache', function() {
  $('[data-behavior~=datatable]').each(function() {
    $(this).DataTable().destroy();
  });
});
