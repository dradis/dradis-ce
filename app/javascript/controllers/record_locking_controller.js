import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static values = { path: String }

  // Keep the request alive while the Cancel link navigates away.
  release() {
    if (!this.pathValue) return

    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content

    fetch(this.pathValue, {
      method: 'DELETE',
      keepalive: true,
      headers: { 'X-CSRF-Token': csrfToken },
    })
  }
}
