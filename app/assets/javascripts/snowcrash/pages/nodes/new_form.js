(function() {
  document.addEventListener("turbolinks:load", function() {
    if ($('[data-behavior~=new-node]').length) {
      $('[data-behavior~=new-node]').click(function() {
        var $multi = $('#nodes_list');
        var labelVal = $('#node_label').val();

        if ($multi.val() === '' && labelVal !== '') {
          $multi.val(labelVal + '\r');

          $('#nodes_type_id').val($('#node_type_id').val());

          // The click function we're in actually takes focus when clicked. If
          // we called focus within the fucntion it gets cancelled out. We give
          // it a brief timout to allow it to occur after this function ends,
          // but seemingly at the same time.
          setTimeout(function() {
            $multi.focus();
          }, 0);
        }
      });
    }
  });
}).call(this);
