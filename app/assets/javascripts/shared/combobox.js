class ComboBox {
  constructor($target) {
    if (!$target.is('select')) {
      console.error("Can't initialize a ComboBox on anything but a `select`");
      return;
    }

    this.$target = $target;

    this.init();
  }

  init() {
    const that = this;

    this.$target.addClass('d-none');

    this.$target.parent().append(
      '<div class="combobox" tabindex="0" data-behavior="combobox"></div>\
      <div class="combobox-menu" data-behavior="combobox-menu"></div>'
    );

    this.$combobox = this.$target.parent().find('[data-behavior~=combobox]');

    this.$comboboxMenu = this.$combobox.next('[data-behavior~=combobox-menu]');

    this.$target.find('option').each(function () {
      that.$comboboxMenu.append(
        `<div \
          class="combobox-option" \
          data-behavior="combobox-option" \
          data-value="${$(this).attr('value')}">\
            ${$(this).text()}\
        </div>`
      );
    });

    this.$comboboxOptions = this.$comboboxMenu.find(
      '[data-behavior~=combobox-option]'
    );

    const $initialOption = this.$comboboxOptions.filter(
      `[data-value="${this.$target.val()}"]`
    );

    this.selectOption($initialOption);
    this.behaviors();
  }

  behaviors() {
    const that = this;

    this.$combobox.on('focus', function () {
      that.$comboboxMenu.css('display', 'block');
    });

    this.$combobox.on('blur', function () {
      // Delay the hiding to allow click event to fire on options
      setTimeout(() => {
        that.$comboboxMenu.css('display', 'none');
      }, 150);
    });

    this.$comboboxOptions.each(function () {
      const $option = $(this);
      $(this).on('click', function (event) {
        event.stopPropagation();
        that.selectOption($option);
      });
    });
  }

  selectOption($option) {
    this.$combobox.text($option.text());
    this.$target.val($option.data('value'));
    this.$comboboxOptions.removeClass('selected');
    $option.addClass('selected');
  }
}
