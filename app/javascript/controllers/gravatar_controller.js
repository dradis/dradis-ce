import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  connect() {
    const url = this.element.dataset.gravatarUrl
    if (!url || url === this.element.getAttribute('src')) return

    // Keep the local image visible until the remote image has loaded successfully.
    this.image = new Image()
    this.image.referrerPolicy = 'no-referrer'
    this.onLoad = () => { this.element.src = this.image.src }
    this.image.addEventListener('load', this.onLoad, { once: true })
    this.image.src = url
  }

  disconnect() {
    this.image?.removeEventListener('load', this.onLoad)
  }
}
