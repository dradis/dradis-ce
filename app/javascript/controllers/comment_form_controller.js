import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static values = { invalid: Boolean }

  connect() {
    this.element.querySelectorAll('[data-behavior~=rich-toolbar]').forEach((textarea) => {
      new EditorToolbar($(textarea))
      textarea.addEventListener('focus', () => {
        window.lastActiveEditor = $(textarea).data('editorToolbar')
      })
    })

    Mentions.init(this.element.querySelectorAll('[data-behavior~=mentionable]'))

    const autoSave = new LocalAutoSave(this.element)

    // LocalAutoSave drops the draft on submit. When the server sends the form
    // back with errors, store it again so a reload doesn't lose it.
    if (this.invalidValue) autoSave.setData()
  }

  // Posting a comment subscribes its author to the record.
  showSubscribed({ detail: { success } }) {
    if (!success) return

    document.querySelectorAll('[data-behavior~=subscribe]').forEach((link) => link.classList.add('d-none'))
    document.querySelectorAll('[data-behavior~=unsubscribe]').forEach((link) => link.classList.remove('d-none'))
  }
}
