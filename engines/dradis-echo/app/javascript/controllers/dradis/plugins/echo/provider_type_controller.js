import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static values = { newPath: String };

  connect() {
    $(this.element).on('change.echo-provider-type', 'select', (event) => {
      const url = new URL(this.newPathValue, window.location.origin);
      url.searchParams.set('type', event.target.value);
      window.location = url.toString();
    });
  }

  disconnect() {
    $(this.element).off('change.echo-provider-type');
  }
}
