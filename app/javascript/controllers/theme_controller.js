import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["autoIcon", "lightIcon", "darkIcon", "autoItem", "lightItem", "darkItem"]

  connect() {
    this.preference = this.element.dataset.theme || "auto"
    this.applyPreference(this.preference)

    this.osChangeHandler = (e) => {
      if (this.preference === "auto") {
        this.element.dataset.theme = e.matches ? "dark" : "light"
      }
    }
    window.matchMedia("(prefers-color-scheme: dark)").addEventListener("change", this.osChangeHandler)
  }

  disconnect() {
    window.matchMedia("(prefers-color-scheme: dark)").removeEventListener("change", this.osChangeHandler)
  }

  select({ params: { name } }) {
    this.preference = name
    this.applyPreference(name)
    this.persist(name)
  }

  applyPreference(preference) {
    this.element.dataset.theme = preference === "auto"
      ? (window.matchMedia("(prefers-color-scheme: dark)").matches ? "dark" : "light")
      : preference

    this.updateUI(preference)
  }

  updateUI(preference) {
    this.autoIconTarget.classList.toggle("d-none", preference !== "auto")
    this.lightIconTarget.classList.toggle("d-none", preference !== "light")
    this.darkIconTarget.classList.toggle("d-none", preference !== "dark")

    this.autoItemTarget.classList.toggle("active", preference === "auto")
    this.lightItemTarget.classList.toggle("active", preference === "light")
    this.darkItemTarget.classList.toggle("active", preference === "dark")
  }

  persist(theme) {
    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content

    fetch("/preferences", {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": csrfToken,
      },
      body: JSON.stringify({ preferences: { theme } }),
    })
  }
}
