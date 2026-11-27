import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['label', 'record', 'toggle']

  disconnect() {
    if (!this.hasToggleTarget) return

    const dropdown = bootstrap.Dropdown.getInstance(this.toggleTarget)
    dropdown?.hide()
    dropdown?.dispose()
  }

  select({ currentTarget, params }) {
    if (currentTarget.disabled) return

    const state = currentTarget.value
    this.labelTarget.textContent = params.label
    $(this.recordTarget).attr('data-state', state).data('state', state)

    bootstrap.Dropdown.getInstance(this.toggleTarget)?.hide()
  }

  toggleTargetConnected(toggle) {
    if (toggle.getAttribute('aria-expanded') === 'true') {
      bootstrap.Dropdown.getOrCreateInstance(toggle).hide()
    }
  }
}
