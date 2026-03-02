import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["darkIcon", "lightIcon"]

  connect() {
    const stored = this.element.dataset.theme

    if (!stored || stored === "auto") {
      const prefersDark = window.matchMedia("(prefers-color-scheme: dark)").matches
      this.applyTheme(prefersDark ? "dark" : "light")
    } else {
      this.applyTheme(stored)
    }

    // Keep in sync when the OS preference changes (and no explicit preference is set)
    window.matchMedia("(prefers-color-scheme: dark)").addEventListener("change", (e) => {
      if (!this.element.dataset.theme || this.element.dataset.theme === "auto") {
        this.applyTheme(e.matches ? "dark" : "light")
      }
    })
  }

  toggle() {
    const current = this.element.dataset.theme
    const next = current === "dark" ? "light" : "dark"
    this.applyTheme(next)
    this.persist(next)
  }

  applyTheme(theme) {
    this.element.dataset.theme = theme

    if (this.hasDarkIconTarget && this.hasLightIconTarget) {
      if (theme === "dark") {
        this.darkIconTarget.classList.add("d-none")
        this.lightIconTarget.classList.remove("d-none")
      } else {
        this.darkIconTarget.classList.remove("d-none")
        this.lightIconTarget.classList.add("d-none")
      }
    }
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
