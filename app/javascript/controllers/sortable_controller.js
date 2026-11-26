import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['handle'];
  static values = { url: String };

  connect() {
    $(this.element).sortable({
      axis: 'y',
      containment: 'parent',
      cursor: 'grabbing',
      handle: '[data-sortable-target~=handle]',
      update: () => {
        $.post(
          this.urlValue,
          $(this.element).sortable('serialize', { key: 'sorted_ids[]' })
        );
      },
    });
  }

  disconnect() {
    $(this.element).sortable('destroy');
  }
}
