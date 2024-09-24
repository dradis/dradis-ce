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
      <div class="combobox-options" data-behavior="combobox-options"></div>'
    );

    this.$combobox = this.$target.parent().find('[data-behavior~=combobox]');

    this.$comboboxOptions = this.$combobox.next(
      '[data-behavior~=combobox-options]'
    );

    this.$target.find('option').each(function () {
      that.$comboboxOptions.append(
        `<div \
          class="combobox-option" \
          data-behavior="combobox-option" \
          data-value="${$(this).attr('value')}">\
            ${$(this).text()}\
        </div>`
      );
    });

    if (this.$target.find('option[selected]').length) {
      this.$combobox.text(this.$target.find('option[selected]').text());
    } else {
      this.$combobox.text(this.$comboboxOptions.children().first().text());
    }

    this.behaviors();
  }

  behaviors() {
    const that = this;

    this.$combobox.on('focus', function () {
      that.$comboboxOptions.css('display', 'block');
    });

    this.$combobox.on('blur', function () {
      that.$comboboxOptions.css('display', 'none');
    });
  }
}
