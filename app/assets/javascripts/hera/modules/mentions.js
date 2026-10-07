((window) => {
  window.Mentions = {
    init: (elements) => {
      const metadata = document.querySelector('[data-behavior~=mentionable-users]');
      if (!metadata) return;

      const tribute = new Tribute({
        allowSpaces: false,
        menuItemTemplate: (item) => {
          const container = document.createElement('div');
          const image = document.createElement('img');
          image.src = item.original.avatar_path;
          image.width = 24;
          image.height = 24;
          image.alt = '';
          image.referrerPolicy = 'no-referrer';
          image.dataset.controller = 'gravatar';
          image.dataset.gravatarUrl = item.original.avatar_url;
          container.append(image, document.createTextNode(` ${item.original.value}`));
          return container.innerHTML;
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
  };
})(window);
