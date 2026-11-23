import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  connect() {
    $(this.element).sortable({
      axis: 'y',
      containment: 'parent',
      cursor: 'grabbing',
      handle: '.fa-grip-vertical',
      update: function () {
        $.post(
          $(this).data('sort-url'),
          $(this).sortable('serialize', { key: 'sorted_ids[]' })
        );
      },
    });
  }
}
