window.Mentions = {
  init: function(elements) {
    tribute = new Tribute({
      allowSpaces: function() { return false },
      menuItemTemplate: function(item) {
        return '<img src="' + item.original.avatar_url + '" width="24px" height="24px" > ' + item.string
      },
      noMatchTemplate: function() { return '' },
      values: JSON.parse($('meta[name=mentionable-users]').attr('content'))
    });

    $('.main-content').scroll(function(){
      tribute.hideMenu();
    });

    tribute.attach(elements);
  }
}
