import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  connect() {
    if (this.combobox) return

    this.combobox = new ComboBox($(this.element))
  }
}
