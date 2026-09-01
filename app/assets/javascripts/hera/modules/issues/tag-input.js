window.SelectTagDropdown = class SelectTagDropdown {
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
};

// Called from initBehaviors() so the dropdown keeps working when the form is
// rendered into a Turbo Frame, which doesn't fire turbo:load.
window.initTagInput = (parentElement) => {
  $(parentElement)
    .find('[data-behavior~=tag-link]')
    .off('click.tagInput')
    .on('click.tagInput', (event) => {
      const $target = $(event.currentTarget);
      new window.SelectTagDropdown($target);
      $('[data-behavior~=tag-list]').trigger('textchange');
    });
};
