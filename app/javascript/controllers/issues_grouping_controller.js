import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["select"]
  static values = { projectId: Number }

  connect() {
    const stored = localStorage.getItem(this.storageKey)

    if (stored && this.hasOption(stored)) {
      this.selectTarget.value = stored
    }

    this.updateFrameSrc(this.selectTarget.value)
  }

  change() {
    const grouping = this.selectTarget.value

    localStorage.setItem(this.storageKey, grouping)
    this.updateFrameSrc(grouping)
  }

  hasOption(value) {
    return !!this.selectTarget.querySelector(`option[value="${CSS.escape(value)}"]`)
  }

  updateFrameSrc(grouping) {
    const frame = document.querySelector('[data-behavior~="issues-summary"]')
    if (!frame) return

    const url = new URL(frame.src, window.location.origin)
    url.searchParams.set("grouping", grouping)
    frame.src = url.toString()
  }

  get storageKey() {
    return `project.pro.${this.projectIdValue}.issues_grouping`
  }
}
