(function() {
  var copyOver = function($to, from, $typeTo, $typeFrom) {
    if ($to.val() === '' && from !== '') {
      $to.val(from.split('\n')[0] + '\n');
      $typeTo.val($typeFrom.val());

      // The click function we're in actually takes focus when clicked. If
      // we called focus within the function it gets cancelled out. We give
      // it a brief timout to allow it to occur after this function ends
      // but seemingly at the same time.
      setTimeout(function() {
        $to.focus();
      }, 0);
    }
  }

  document.addEventListener("turbolinks:load", function() {
    if ($('[data-behavior~=copy-node-label]').length) {
      $('[data-behavior~=copy-node-label]').click(function(eventData) {
        var $nodeType = $('#node_type_id'),
            $nodesType = $('#nodes_type_id'),

            $multi = $('#nodes_list'),
            $label = $('#node_label'),

            multiVal = $multi.val(),
            labelVal = $label.val();

        if ($(this).find('input').val() === 'one') {
          copyOver($label, multiVal, $nodeType, $nodesType);
        } else {
          copyOver($multi, labelVal, $nodesType, $nodeType);
        }
      });
    }
  });
}).call(this);
