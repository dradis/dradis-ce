import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["console"]
  static values = { itemId: String, statusUrl: String }

  connect() {
    this.afterId = 0
    this.pollTimer = null
  }

  disconnect() {
    clearTimeout(this.pollTimer)
  }

  itemIdValueChanged() {
    if (!this.itemIdValue) return
    this.afterId = 0
    clearTimeout(this.pollTimer)
    this.poll()
  }

  async poll() {
    const url = new URL(this.statusUrlValue, window.location.origin)
    url.searchParams.set('item_id', this.itemIdValue)
    url.searchParams.set('after', this.afterId)

    let data
    try {
      const response = await fetch(url.toString(), {
        headers: { 'Accept': 'application/json' }
      })
      if (!response.ok) return
      data = await response.json()
    } catch (_e) {
      return
    }

    data.logs.forEach(log => {
      const p = document.createElement('p')
      p.className = 'log'
      p.dataset.id = log.id
      p.textContent = log.text
      this.consoleTarget.appendChild(p)
    })

    if (data.logs.length > 0) {
      this.afterId = data.after
    }

    if (data.working) {
      this.pollTimer = setTimeout(() => this.poll(), 2000)
    } else {
      this.dispatch('complete', { bubbles: true })
    }
  }
}
