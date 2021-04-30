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
      scrollX: true
    })

    //$(this).columns.adjust();
  });
});
