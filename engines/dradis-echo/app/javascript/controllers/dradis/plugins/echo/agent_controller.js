import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['agentSwitch', 'tool'];

  connect() { this.update(); }
  toggle() { this.update(); }

  update() {
    const agentEnabled = this.hasAgentSwitchTarget ? this.agentSwitchTarget.checked : true;

    this.toolTargets.forEach((card) => {
      const toolSwitch = card.querySelector('[data-tool-switch]');
      const toolFields = card.querySelector('[data-tool-fields]');
      const enabled    = agentEnabled && (toolSwitch?.checked ?? true);

      if (toolSwitch) toolSwitch.disabled = !agentEnabled;
      card.classList.toggle('tool-disabled', !agentEnabled);

      if (toolFields) {
        toolFields.querySelectorAll('input, select, textarea').forEach((el) => {
          el.disabled = !enabled;
        });
      }
    });
  }
}
