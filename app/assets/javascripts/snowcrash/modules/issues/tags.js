(function ($) {
  const updateTagBtn = function () {
    $('#issue_tag_list').val($(this).data('tag'));
    $('#tag-btn').html($(this).html()).css("color", $(this).css("color"));
    showTagBtn();
  };

  const showTagBtn = function () {
    $('#tag-result').hide();
    $("#tag_search").hide();
    $('#tag-btn').show();
  };

  const delay = function (fn, ms) {
    let timer = 0;
    return function(...args) {
      clearTimeout(timer);
      timer = setTimeout(fn.bind(this, ...args), ms || 0);
    };
  };

  const createTag = function (value, color, name) {
    return `
      <li>
        <a class="js-taglink" style="color: ${color}" 
          data-tag="${value}" href="javascript:void(0)">
          <i class="icon fa fa-tag"></i>
          ${name}
        </a>
      </li>`;
  };

  const fillResults = function (tags) {
    let tagResults = "";  
    tags.forEach(function(tag) {
      tagResults += createTag(tag.value, tag.color, tag.name);
    });
    $("#tag-result").html($.parseHTML(tagResults)).show();
    $('#tag-loading').hide();
  };

  const ready = function () {
    if ($('#issues_editor').length === 0) return;

    showTagBtn();    
    $('#issues_editor').on('click', ".js-taglink", updateTagBtn);    

    $('#tag-btn').click(function(e) {
      e.preventDefault();
      $(this).hide();
      $("#tag_search").show().focus();      
    });

    $("#tag_search").keyup(delay(function() {
      $('#tag-loading').show();
      if ($(this).val().length) {
        return $.get($(this).data('url'), {name: $(this).val()}, function(data) {fillResults(data);});
      } else {
        $("#tag-result").hide();
        $('#tag-loading').hide();
      }
    }, 500));

    $("body").click(function(e) {
      if ($(e.target).parents(".tag-wrap").length) return;
      showTagBtn();
    });
  };

  $(document).on('turbolinks:load', ready);
}(jQuery));

