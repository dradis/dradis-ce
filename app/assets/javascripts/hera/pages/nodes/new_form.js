(function() {
  document.addEventListener('turbo:load', function() {
    var copyOver = function($to, fromVal, $typeTo, typeFromVal) {
      if ($to.val() === '' && fromVal !== '') {
        $to.val(fromVal.trim().split('\n')[0] + '\n');
        $typeTo.val(typeFromVal);

        // The click function we're in actually takes focus when clicked. If
        // we called focus within the function it gets cancelled out. We give
        // it a brief timout to allow it to occur after this function ends
        // but seemingly at the same time.
        setTimeout(function() {
          $to.focus();
        }, 0);
      }
    }

    if ($('[data-behavior~=copy-node-label]').length) {
      $('[data-behavior~=copy-node-label]').click(function() {
        var $modal = $(this).parents('[data-behavior~=add-node]'),
            $nodeType = $modal.find('[data-behavior~=node-icon]'),
            $nodesType = $modal.find('[data-behavior~=nodes-icon]'),
            $multi = $modal.find('[data-behavior~=nodes-list]'),
            $label = $modal.find('[data-behavior~=node-label]');

        if ($(this).find('input').val() === 'one') {
          copyOver($label, $multi.val(), $nodeType, $nodesType.val());
        } else {
          copyOver($multi, $label.val(), $nodesType, $nodeType.val());
        }
      });
    }
  });
})();

// One modal adds both top-level nodes and subnodes. Links that add a subnode
// carry the parent node, links that add a top-level node carry nothing.
document.addEventListener('show.bs.modal', (event) => {
  const modal = event.target;

  if (!modal.matches('[data-behavior~=add-node]')) return;

  const { parentId = '', parentLabel = '' } = event.relatedTarget.dataset;
  const isSubnode = Boolean(parentId);

  modal.querySelectorAll('[data-behavior~=parent-node-id]').forEach((input) => {
    input.value = parentId;
  });
  modal.querySelector('[data-behavior~=parent-node-label]').textContent = parentLabel;
  modal.querySelector('[data-behavior~=top-level-node-title]').hidden = isSubnode;
  modal.querySelector('[data-behavior~=subnode-title]').hidden = !isSubnode;
});
