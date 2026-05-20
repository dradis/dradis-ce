import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  connect() {
    this._switchFields($(this.element).find('select[name="provider[type]"]').val());
  }

  switch(event) {
    this._switchFields(event.target.value);
  }

  _switchFields(type) {
    $(this.element).find('[data-provider-fields]').each((_, el) => {
      const active = el.dataset.providerFields === type;
      $(el).toggle(active);
      $(el).find('input, select, textarea').prop('disabled', !active);
    });
  }
}
