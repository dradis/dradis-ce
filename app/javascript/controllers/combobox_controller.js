import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  connect() {
    if (this.combobox) return

    this.combobox = new ComboBox($(this.element))
    this.dispatch('ready')
  }

  disconnect() {
    // Wrapping the select makes Stimulus disconnect it before reconnecting it.
    if (this.element.isConnected) return

    this.combobox?.destroy()
    this.combobox = null
  }
}
