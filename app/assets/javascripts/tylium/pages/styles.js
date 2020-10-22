document.addEventListener( "turbolinks:load", function(){
  if ($('body.styles_tylium')) {
    new ItemsTable('#table-example', 'example')
  }
});
