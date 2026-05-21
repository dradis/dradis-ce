import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ['issueInteractionConfig', 'languageToolConfig']

  connect() {
    this.toggleIssueInteractionConfig();
    this.toggleLanguageToolConfig();
  }

  toggleIssueInteractionConfig() {
    const enabled = this.element.querySelector('[data-issue-interaction-master]').checked;
    this.issueInteractionConfigTarget.classList.toggle('d-none', !enabled);
  }

  toggleLanguageToolConfig() {
    const enabled = this.element.querySelector('[data-language-tool-master]').checked;
    this.languageToolConfigTarget.classList.toggle('d-none', !enabled);
  }
}
