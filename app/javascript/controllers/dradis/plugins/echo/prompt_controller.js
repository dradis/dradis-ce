import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    interactionId: String,
    prompt: String,
    responseId: String,
    url: String,
  }

  connect() {
    fetch(this.urlValue, {
      method: 'POST',
      headers: {
        'Accept': 'text/vnd.turbo-stream.html',
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content,
      },
      body: JSON.stringify({
        interaction_id: this.interactionIdValue,
        response_id: this.responseIdValue,
        prompt: this.promptValue
      })
    })
  }
}
