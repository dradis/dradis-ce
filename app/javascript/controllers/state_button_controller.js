import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['label', 'record', 'toggle']

  select({ currentTarget, params }) {
    if (currentTarget.disabled) return

    const state = currentTarget.value
    this.labelTarget.textContent = params.label
    $(this.recordTarget).attr('data-state', state).data('state', state)

    bootstrap.Dropdown.getInstance(this.toggleTarget)?.hide()
  }
}
