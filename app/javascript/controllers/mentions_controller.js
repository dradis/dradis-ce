import { Controller } from '@hotwired/stimulus'

// The bundled Tribute has no detach API. Reuse one instance and menu for the
// document, reading candidates from the active editor rather than the page.
let tribute

export default class extends Controller {
  connect() {
    tribute ||= new Tribute({
      allowSpaces: false,
      menuItemTemplate: (item) => {
        const image = document.createElement('img')
        image.src = tribute.current.element.dataset.mentionsFallbackImageValue
        image.width = 24
        image.height = 24
        image.alt = ''
        image.dataset.controller = 'gravatar'
        image.dataset.gravatarUrl = item.original.avatar_url
        image.referrerPolicy = 'no-referrer'
        return `${image.outerHTML} ${item.string}`
      },
      noMatchTemplate: () => '',
      selectTemplate: (item) => item ? `@${item.original.value}` : null,
      values: (_text, callback) => {
        callback(JSON.parse(tribute.current.element.dataset.mentionsUsersValue))
      }
    })

    if (!this.element.hasAttribute('data-tribute')) tribute.attach(this.element)
    this.onScroll = (event) => {
      // Tribute scrolls the document to reveal its menu and repositions it on
      // window scroll. Only dismiss it when an editor's nested container moves.
      if (event.target instanceof Element && event.target.contains(this.element) && tribute.current.element === this.element) {
        tribute.hideMenu()
      }
    }
    document.addEventListener('scroll', this.onScroll, true)
  }

  disconnect() {
    document.removeEventListener('scroll', this.onScroll, true)
    if (tribute.current.element === this.element) {
      tribute.hideMenu()
      tribute.current = {}
    }
  }
}
