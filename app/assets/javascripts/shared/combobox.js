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
    this.debounceTimer = 250;
    this.allowFocusDelay = 150;

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
        `<div class="d-flex flex-column px-2 pt-1">\
          <label class="visually-hidden" for="combobox-filter-${idSuffix}">Filter options</label>\
          <input type="search" class="form-control mb-2" data-behavior="combobox-filter" id="combobox-filter-${idSuffix}" placeholder="Filter options...">\
          <span class="d-block text-secondary text-center d-none pe-none" data-behavior="no-results">No results.</span>
        </div>`
      );
      this.$filter = this.$comboboxMenu.find(
        '[data-behavior~=combobox-filter]'
      );
    }

    this.$target.children().each(function () {
      switch (this.tagName.toLowerCase()) {
        case 'option':
          that.appendOption(that.$comboboxMenu, $(this));
          break;

        case 'optgroup':
          that.$comboboxMenu.append(
            `<div class="combobox-optgroup" data-behavior="combobox-optgroup">\
              <span class="d-block px-2 py-1">${$(this).attr('label')}<span>\
            </div>`
          );

          $(this)
            .children('option')
            .each(function () {
              that.appendOption(
                that.$comboboxMenu
                  .find('[data-behavior~=combobox-optgroup]')
                  .last(),
                $(this)
              );
            });
          break;

        default:
          console.warn('Unexpected element: ', this.tagName);
          break;
      }
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
      if (that.$filter) {
        that.$filter.focus();
      }
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

    if (this.$filter) {
      this.$filter.on('textchange', function () {
        that.handleFiltering();
      });
    }
  }

  appendOption($parent, $option) {
    $parent.append(
      `<span \
        class="combobox-option" \
        data-behavior="combobox-option" \
        data-value="${$option.attr('value')}">\
          ${$option.text()}\
      </span>`
    );
  }

  handleFiltering() {
    clearTimeout(this.debounceTimeout);

    this.debounceTimeout = setTimeout(() => {
      const filterText = this.$filter.val().toLowerCase();
      let matchedOptions = 0;

      this.$comboboxOptions.each(function () {
        const $option = $(this),
          optionText = $option.text().toLowerCase(),
          isOption = $(this).is('[data-behavior~=combobox-option]'),
          isMatch = isOption && optionText.includes(filterText);

        $option.toggleClass('d-none', !isMatch);

        if (isMatch) {
          matchedOptions++;
        }
      });

      this.$comboboxMenu.find('[data-behavior~=combobox-optgroup]');

      this.$filter
        .next('[data-behavior~=no-results]')
        .toggleClass('d-none', matchedOptions > 0);
    }, this.debounceTimer);
  }

  hideMenu(element) {
    // Delay the hiding the menu to allow click events to fire on menu children
    setTimeout(() => {
      // Only hide the menu if the combobox nor it's children have focus
      if (!$(element).is(':focus') && !$(element).find(':focus').length) {
        this.$comboboxMenu.css('display', 'none');

        if (this.$filter) {
          this.$filter.val(null).trigger('textchange');
        }
      }
    }, this.allowFocusDelay);
  }

  selectOption($option) {
    this.$combobox.text($option.text());
    this.$target.val($option.data('value'));
    this.$comboboxOptions.removeClass('selected');
    $option.addClass('selected');
  }
}
