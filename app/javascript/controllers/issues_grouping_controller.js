import { Controller } from "@hotwired/stimulus"

// Loads the issues summary frame with the grouping the user last picked for
// this project, and remembers the choice when they pick another one.
export default class extends Controller {
  static values = { url: String, storageKey: String }

  connect() {
    const url = new URL(this.urlValue, window.location.origin)
    const grouping = localStorage.getItem(this.storageKeyValue)

    if (grouping) url.searchParams.set("grouping", grouping)

    this.element.src = url.toString()
  }

  change(event) {
    localStorage.setItem(this.storageKeyValue, event.target.value)
    event.target.form.requestSubmit()
  }
}
