import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.observer = new MutationObserver(() => {
      this.element.scrollTop = this.element.scrollHeight
    })
    this.observer.observe(this.element, { childList: true })
  }

  disconnect() {
    this.observer.disconnect()
  }
}
