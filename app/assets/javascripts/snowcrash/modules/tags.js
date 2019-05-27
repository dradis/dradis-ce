(function ($) {
  const updateTag = function (el) {
    const $el = $(el).closest('tr');
    const color = $el.find('.tag-colorpicker').val();
    const tagName = $el.closest('tr').find('.tag-row-name').val();
    $el.find('.tag-name-hidden').val(setTagName(color, tagName));
    console.log($el.find('.tag-name-hidden').val());
    console.log("test");
    $el.find('form').submit();
  };

  const setTagName = function (color, tagName) {
    return `!${color.substr(1)}_${tagName}`;
  };

  const ready = function () {
    if ($('#tags-index').length === 0) return;    

    $('body').on('click', '#create-tag', function(event) {
      event.preventDefault;
      event.stopImmediatePropagation();
      const tagName = setTagName($("#tag_color").val(), $("#tag_name").val());
      $.post( $(this).data("url"), {tag: {name: tagName}} );     
      location.reload();
    });

    $('.tag-row-name').change(function() {
      updateTag(this);
    }).keypress(function(e){
      if([32,33,95,13].includes(e.which)) $(this).blur();
    });

    $('.tag-colorpicker').change(function() {
      updateTag(this);
    });
  };

  $(document).on('turbolinks:load', ready);
}(jQuery));
