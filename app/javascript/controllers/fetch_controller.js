import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static values = { url: String }

  connect() {
    $.ajax(this.urlValue, { credentials: 'include' }).done(html => {
      $(this.element).html(html).trigger('dradis:fetch')
      window.initBehaviors(this.element)
    })
  }
}
