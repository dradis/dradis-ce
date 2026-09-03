(function (window) {
  class SelectTagDropdown {
    constructor($target) {
      this.$target = $target;
      this.init();
    }

    init() {
      $('[data-behavior~=tag-list]').val(this.$target.data('tag'));

      const $tagLabel = this.$target
        .closest('[data-behavior~=tag-input]')
        .find('[data-behavior~=tag-label]');

      $tagLabel.css('color', this.$target.css('color'));
      $tagLabel.html(this.$target.html());
    }
  }

  // Exposed so auto_save/local.js can restore the dropdown's selected tag
  // after reloading form data from localStorage.
  window.selectTagDropdown = ($target) => new SelectTagDropdown($target);

  // Called from initBehaviors() so the dropdown keeps working when the form is
  // rendered into a Turbo Frame, which doesn't fire turbo:load.
  window.initTagInput = (parentElement) => {
    $(parentElement)
      .find('[data-behavior~=tag-link]')
      .off('click.tagInput')
      .on('click.tagInput', (event) => {
        window.selectTagDropdown($(event.currentTarget));
        $('[data-behavior~=tag-list]').trigger('textchange');
      });
  };
})(window);
