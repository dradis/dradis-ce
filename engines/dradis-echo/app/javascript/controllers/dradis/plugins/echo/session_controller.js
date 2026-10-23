import { Controller } from "@hotwired/stimulus"

// Drives the Echo conversation surface (sessions#show):
//   * keeps the transcript pinned to the newest message as chunks stream in,
//   * clears the composer after a successful send,
//   * mirrors the server's generating state onto the textarea.
// The Send button's disabled state is server-rendered by the broadcast
// _composer_state partial; here we only keep the textarea in step with it.
export default class extends Controller {
  static targets = ["messages", "input"]
  static values = { replyUrl: String, replyPending: Boolean }

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

    this.#triggerPendingReply()
  }

  disconnect() {
    this.messagesObserver?.disconnect()
    this.stateObserver?.disconnect()
    clearTimeout(this.sendErrorTimeout)
  }

  // Post over fetch so sending never navigates the Echo frame — the new user
  // message and Roslin's reply both arrive over the socket. Clear the box on OK;
  // on a non-OK response or a network error, keep the text and warn the user so
  // a failed send isn't silently swallowed.
  send(event) {
    event.preventDefault()
    if (this.#generating()) return

    const form = event.target
    this.#clearSendError()

    fetch(form.action, {
      body: new FormData(form),
      headers: { "Accept": "text/vnd.turbo-stream.html", "X-CSRF-Token": this.#csrfToken() },
      method: "POST"
    }).then((response) => {
      if (response.ok) {
        form.reset()
      } else {
        this.#showSendError()
      }
    }).catch(() => this.#showSendError())
  }

  // Surfaces a send failure inline without clearing the composer, so the user
  // can retry the same text. Auto-dismisses; a fresh failure replaces it.
  #showSendError() {
    this.#clearSendError()

    const alert = document.createElement("div")
    alert.className = "alert alert-danger echo-send-error"
    alert.setAttribute("role", "alert")
    alert.dataset.behavior = "echo-send-error"
    alert.textContent = "Your message couldn't be sent. Check your connection and try again."

    this.element.insertBefore(alert, this.element.firstChild)
    this.sendErrorTimeout = setTimeout(() => this.#clearSendError(), 8000)
  }

  #clearSendError() {
    clearTimeout(this.sendErrorTimeout)
    this.element.querySelector("[data-behavior~=echo-send-error]")?.remove()
  }

  // On a freshly-created session the server did NOT start generation: it would
  // have raced ReplyJob's streaming-container broadcast ahead of this element's
  // <turbo-cable-stream-source> subscription and dropped it. Now that we're
  // subscribed, POST to start the reply so every chunk lands on a listening
  // socket. The server re-checks reply_pending? so a reconnect can't spawn a
  // second reply.
  #triggerPendingReply() {
    if (!this.replyPendingValue || !this.hasReplyUrlValue) return

    fetch(this.replyUrlValue, {
      headers: { "X-CSRF-Token": this.#csrfToken() },
      method: "POST"
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
