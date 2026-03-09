import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["autoIcon", "lightIcon", "darkIcon", "autoItem", "lightItem", "darkItem"]

  connect() {
    this.preference = this.element.dataset.theme || "auto"
    this.updateUI(this.preference)
  }

  select({ params: { name } }) {
    this.preference = name
    this.element.dataset.theme = name
    this.updateUI(name)
    this.persist(name)
  }

  updateUI(preference) {
    if (!this.hasAutoIconTarget) return

    this.autoIconTarget.classList.toggle("d-none", preference !== "auto")
    this.lightIconTarget.classList.toggle("d-none", preference !== "light")
    this.darkIconTarget.classList.toggle("d-none", preference !== "dark")

    this.autoItemTarget.classList.toggle("active", preference === "auto")
    this.lightItemTarget.classList.toggle("active", preference === "light")
    this.darkItemTarget.classList.toggle("active", preference === "dark")
  }

  persist(theme) {
    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content
    fetch(this.preferencesPathValue, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": csrfToken,
      },
      body: JSON.stringify({ preferences: { theme } }),
    })
  }
}
