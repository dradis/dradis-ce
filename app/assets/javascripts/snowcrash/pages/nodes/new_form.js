(function() {
  document.addEventListener("turbolinks:load", function() {
    if ($('[data-behavior~=multi-node]').length) {
      $('[data-behavior~=multi-node]').click(function() {
        var $multi = $('#nodes_list');
        var labelVal = $('#node_label').val();

        if ($multi.val() === '' && labelVal !== '') {
          $multi.val(labelVal + '\n');

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

    if ($('[data-behavior~=one-node]').length) {
      $('[data-behavior~=one-node]').click(function() {
        var multiVal = $('#nodes_list').val();
        var $label = $('#node_label');

        if ($label.val() === '' && multiVal !== '') {
          $label.val(multiVal.split('\n')[0]);

          $('#node_type_id').val($('#nodes_type_id').val());

          // The click function we're in actually takes focus when clicked. If
          // we called focus within the fucntion it gets cancelled out. We give
          // it a brief timout to allow it to occur after this function ends,
          // but seemingly at the same time.
          setTimeout(function() {
            $label.focus();
          }, 0);
        }
      });
    }
  });
}).call(this);
