import { Controller } from "@hotwired/stimulus"

// Drives the Echo conversation surface (sessions#show):
//   * keeps the transcript pinned to the newest message as chunks stream in,
//   * clears the composer after a successful send,
//   * mirrors the server's generating state onto the textarea.
// The Send button's disabled state is server-rendered by the broadcast
// _composer_state partial; here we only keep the textarea in step with it.
export default class extends Controller {
  static targets = ["messages", "input", "retryHint"]
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

  // On a freshly-created session the server deliberately did NOT start
  // generation (SEC-506 Bug 4): had it, ReplyJob's streaming-container broadcast
  // would have raced ahead of this element's <turbo-cable-stream-source>
  // subscription and been dropped. Now that we're connected — and thus
  // subscribed — POST to start the reply, so every chunk lands on a listening
  // socket. The POST round-trip comfortably outlasts the local subscribe
  // handshake, and the server re-checks reply_pending? so a reconnect can't
  // spawn a second reply.
  #triggerPendingReply() {
    if (!this.replyPendingValue || !this.hasReplyUrlValue) return

    fetch(this.replyUrlValue, {
      headers: { "X-CSRF-Token": this.#csrfToken() },
      method: "POST"
    }).then((response) => {
      if (!response.ok) this.#recoverFromFailedTrigger()
    }).catch(() => this.#recoverFromFailedTrigger())
  }

  // The trigger POST never reached a started reply (route blocked, offline, 5xx),
  // so no broadcast_composer_state (generating -> ... -> idle) will ever arrive to
  // release the first-paint lock. Recover entirely client-side so the composer
  // can't stick: unlock it, drop the never-resolving "thinking" sentinel, and
  // invite a manual retry — sending any message re-runs request_reply! (SEC-508).
  // The success branch leaves everything locked: a reply is genuinely coming and
  // the normal broadcasts own the rest.
  #recoverFromFailedTrigger() {
    const state = this.element.querySelector("[data-behavior~=echo-composer-state]")
    if (state) {
      state.dataset.generating = "false"
      state.querySelector("button[type=submit]")?.removeAttribute("disabled")
    }
    this.#syncGenerating()
    this.element.querySelector("[data-echo-pending-reply]")?.remove()
    if (this.hasRetryHintTarget) this.retryHintTarget.hidden = false
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
