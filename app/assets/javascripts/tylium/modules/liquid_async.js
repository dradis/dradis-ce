document.addEventListener('turbolinks:load', function () {
  $('[data-behavior~=liquid-async]').each(function() {
    var that = this,
        data = { text: $(that).attr('data-content') };

    $.ajax($(that).attr('data-path'), {
      method: 'POST',
      headers: {
        "Accept": "text/html",
        "Content-Type": "application/json"
      },
      data: JSON.stringify(data)
    }).
    done(function(html){
      $(that).html(html);
    });
  });
});
