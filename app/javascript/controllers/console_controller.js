import { Controller } from '@hotwired/stimulus'

// Dispatches `console:connected` and `console:finished` for the page using it
export default class extends Controller {
  static targets = ['lines', 'source', 'status']

  connect() {
    this.linesObserver = new MutationObserver(() => {
      this.element.scrollTop = this.element.scrollHeight
    })
    this.linesObserver.observe(this.linesTarget, { childList: true })
  }

  disconnect() {
    this.linesObserver.disconnect()
    this.sourceObserver?.disconnect()
  }

  // Turbo marks its stream source `connected` once the subscription is confirmed
  sourceTargetConnected(element) {
    if (element.hasAttribute('connected')) return this.dispatch('connected')

    this.sourceObserver = new MutationObserver(() => {
      if (!element.hasAttribute('connected')) return

      this.sourceObserver.disconnect()
      this.dispatch('connected')
    })
    this.sourceObserver.observe(element, { attributeFilter: ['connected'] })
  }

  statusTargetConnected(element) {
    const { state } = element.dataset
    if (state === 'completed' || state === 'failed') {
      this.dispatch('finished', { detail: { state } })
    }
  }
}
