import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['agentSwitch', 'envVarsContainer', 'envVarTemplate', 'tool'];

  connect() { this.update(); }
  toggle() { this.update(); }

  addRow() {
    const row = this.envVarTemplateTarget.content.cloneNode(true);
    this.envVarsContainerTarget.appendChild(row);
    this.envVarsContainerTarget.lastElementChild.querySelector('input').focus();
  }

  removeRow(event) {
    event.currentTarget.closest('[data-env-var-row]')?.remove();
  }

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
