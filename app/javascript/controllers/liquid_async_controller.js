import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  connect() {
    const data = { text: this.element.dataset.content }
    const spinner = this.element.previousElementSibling?.querySelector('[data-behavior~=liquid-spinner]')

    fetch(this.element.dataset.path, {
      method: 'POST',
      headers: {
        Accept: 'text/html',
        'Content-Type': 'application/json',
        'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content'),
      },
      body: JSON.stringify(data),
    })
      .then(response => response.text())
      .then(html => {
        $(this.element).html(html).trigger('dradis:liquid-rendered')
        this.element.dispatchEvent(
          new CustomEvent('dradis:liquid-rendered', { bubbles: true })
        )
        spinner?.classList.add('d-none')
      })
  }
}
