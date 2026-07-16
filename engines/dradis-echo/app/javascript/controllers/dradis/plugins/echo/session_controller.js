import { Controller } from "@hotwired/stimulus"

// Drives the Echo conversation surface (sessions#show):
//   * keeps the transcript pinned to the newest message as chunks stream in,
//   * clears the composer after a successful send,
//   * mirrors the server's generating state onto the textarea.
// The Send button's disabled state is server-rendered by the broadcast
// _composer_state partial; here we only keep the textarea in step with it.
export default class extends Controller {
  static targets = ["messages", "input"]

  connect() {
    this.#scrollToBottom()

    // Streaming appends arrive as childList/characterData mutations under
    // .echo-messages; keep the view pinned to the bottom as they land.
    this.messagesObserver = new MutationObserver(() => this.#scrollToBottom())
    this.messagesObserver.observe(this.messagesTarget, {
      childList: true, characterData: true, subtree: true
    })

    // The _composer_state partial is broadcast-replaced on every
    // idle<->generating flip; re-sync the textarea whenever it changes.
    this.#syncGenerating()
    this.stateObserver = new MutationObserver(() => this.#syncGenerating())
    this.stateObserver.observe(this.element, {
      attributeFilter: ["data-generating"], attributes: true, childList: true, subtree: true
    })
  }

  disconnect() {
    this.messagesObserver?.disconnect()
    this.stateObserver?.disconnect()
  }

  // Post over fetch so sending never navigates the Echo frame — the new user
  // message and Roslin's reply both arrive over the socket. Clear the box on OK.
  send(event) {
    event.preventDefault()
    if (this.#generating()) return

    const form = event.target
    fetch(form.action, {
      body: new FormData(form),
      headers: { "Accept": "text/vnd.turbo-stream.html", "X-CSRF-Token": this.#csrfToken() },
      method: "POST"
    }).then((response) => {
      if (response.ok) form.reset()
    })
  }

  #csrfToken() {
    return document.querySelector("meta[name=csrf-token]")?.content || ""
  }

  #generating() {
    const state = this.element.querySelector("[data-behavior~=echo-composer-state]")
    return state?.dataset.generating === "true"
  }

  #scrollToBottom() {
    if (this.hasMessagesTarget) this.messagesTarget.scrollTop = this.messagesTarget.scrollHeight
  }

  #syncGenerating() {
    if (this.hasInputTarget) this.inputTarget.disabled = this.#generating()
  }
}
