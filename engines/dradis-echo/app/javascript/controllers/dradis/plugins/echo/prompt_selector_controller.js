import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ['frame']

  connect() {
    $(this.element).on('change.echo-prompt-selector', 'select', (event) => {
      const url = event.target.value
      if (url) this.frameTarget.src = url
    })
  }

  disconnect() {
    $(this.element).off('change.echo-prompt-selector')
  }
}
