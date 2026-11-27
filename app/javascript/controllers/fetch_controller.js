import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static values = { url: String }

  connect() {
    this.request = $.ajax(this.urlValue, { credentials: 'include' })
    this.request
      .always(() => {
        this.request = null
      })
      .done(html => {
        $(this.element).html(html).trigger('dradis:fetch')
        window.initBehaviors(this.element)
      })
  }

  disconnect() {
    this.request?.abort()
  }
}
