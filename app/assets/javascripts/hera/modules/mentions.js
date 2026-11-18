((window) => {
  window.Mentions = {
    init: (elements) => {
      const metadata = document.querySelector('[data-fallback-image][name=mentionable-users]');
      if (!metadata) return;
      const fallbackImage = metadata.dataset.fallbackImage;

      const tribute = new Tribute({
        allowSpaces: false,
        menuItemTemplate: (item) => {
          const image = document.createElement('img');
          image.src = fallbackImage;
          image.width = 24;
          image.height = 24;
          image.alt = '';
          image.dataset.controller = 'gravatar';
          image.dataset.gravatarUrl = item.original.avatar_url;
          image.referrerPolicy = 'no-referrer';
          return `${image.outerHTML} ${item.string}`;
        },
        noMatchTemplate: () => '',
        selectTemplate: function(item) {
          if (!item) return null;

          const value = `${this.current.collection.trigger}${item.original.value}`;
          if (!this.range.isContentEditable(this.current.element)) return value;

          const mention = document.createElement('span');
          mention.className = 'tribute-mention';
          mention.textContent = value;
          return mention.outerHTML;
        },
        values: JSON.parse(metadata.content)
      });

      $('[data-behavior~=mentions-scroll]').on('scroll', () => {
        tribute.hideMenu();
      });

      tribute.attach(elements);
    }
  }
})(window);
