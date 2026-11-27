import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static values = { content: String, url: String }

  async connect() {
    this.abortController = new AbortController()
    const { signal } = this.abortController
    const spinner = this.element.previousElementSibling?.querySelector('[data-behavior~=liquid-spinner]')
    spinner?.classList.remove('d-none')

    try {
      const response = await fetch(this.urlValue, {
        method: 'POST',
        headers: {
          Accept: 'text/html',
          'Content-Type': 'application/json',
          'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content'),
        },
        body: JSON.stringify({ text: this.contentValue }),
        signal,
      })
      if (!response.ok) throw new Error(`Liquid preview failed: ${response.status}`)

      const html = await response.text()
      if (signal.aborted) return

      $(this.element).html(html)
      $(this.element).trigger('dradis:liquid-rendered')
      this.element.dispatchEvent(
        new CustomEvent('dradis:liquid-rendered', { bubbles: true })
      )
      spinner?.classList.add('d-none')
    } catch (error) {
      if (!signal.aborted) console.error(error)
    }
  }

  disconnect() {
    this.abortController?.abort()
  }
}
