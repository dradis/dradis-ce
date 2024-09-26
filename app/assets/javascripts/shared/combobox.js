class ComboBox {
  constructor($target) {
    if (!$target.is('select')) {
      console.error("Can't initialize a ComboBox on anything but a `select`");
      return;
    }

    this.$target = $target;
    this.config = (this.$target.data('combobox-config') || '')
      .split(' ')
      .filter(Boolean);

    this.init();
  }

  init() {
    const that = this;

    this.$target
      .addClass('d-none')
      .wrap('<div class="position-relative"></div>');

    this.$comboboxContainer = this.$target.parent();

    this.$comboboxContainer.append(
      '<div class="combobox" tabindex="0" data-behavior="combobox"></div>\
      <div class="combobox-menu" data-behavior="combobox-menu"></div>'
    );

    this.$combobox = this.$comboboxContainer.find('[data-behavior~=combobox]');

    this.$comboboxMenu = this.$combobox.next('[data-behavior~=combobox-menu]');

    if (this.config.includes('filter')) {
      const idSuffix = Math.random().toString(36);
      this.$comboboxMenu.append(
        `<div class="d-flex">\
          <label class="visually-hidden" for="combobox-filter-${idSuffix}">Filter options</label>\
          <input type="search" class="form-control mx-2 mb-1" data-behavior="combobox-filter" id="combobox-filter-${idSuffix}" placeholder="Filter options...">\
        </div>`
      );
    }

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

    let $initialOption = this.$comboboxOptions.filter(
      `[data-value="${this.$target.val()}"]`
    );

    $initialOption = $initialOption.length
      ? $initialOption
      : this.$comboboxOptions.first();

    this.selectOption($initialOption);
    this.behaviors();
  }

  behaviors() {
    const that = this;

    this.$combobox.on('focus', function () {
      that.$comboboxMenu.css('display', 'block');
    });

    this.$comboboxContainer.on('focusout', function () {
      that.hideMenu(this);
    });

    this.$comboboxOptions.each(function () {
      const $option = $(this);
      $(this).on('click', function (event) {
        event.stopPropagation();
        that.selectOption($option);
      });
    });
  }

  hideMenu(element) {
    // Delay the hiding the menu to allow click events to fire on menu children
    setTimeout(() => {
      // Only hide the menu if the combobox nor it's children have focus
      if (!$(element).is(':focus') && !$(element).find(':focus').length) {
        this.$comboboxMenu.css('display', 'none');
      }
    }, 150);
  }

  selectOption($option) {
    this.$combobox.text($option.text());
    this.$target.val($option.data('value'));
    this.$comboboxOptions.removeClass('selected');
    $option.addClass('selected');
  }
}
