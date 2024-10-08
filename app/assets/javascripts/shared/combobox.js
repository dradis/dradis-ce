class ComboBox {
  constructor($target) {
    if (!$target.is('select')) {
      console.error("Can't initialize a ComboBox on anything but a `select`");
      return;
    }

    this.$target = $target;

    this.allowFocusDelay = 150;
    this.config = (this.$target.data('combobox-config') || '')
      .split(' ')
      .filter(Boolean);
    this.debounceTimer = 250;
    this.isMultiSelect = this.$target.attr('multiple');

    this.init();
  }

  init() {
    const that = this;

    this.$target
      .addClass('d-none')
      .wrap('<div class="position-relative"></div>');

    this.$comboboxContainer = this.$target.parent();

    this.$comboboxContainer.append(
      `<div class="combobox ${
        this.isMultiSelect ? 'multiple' : ''
      }" tabindex="0" data-behavior="combobox"></div>\
      <div class="combobox-menu" data-behavior="combobox-menu"></div>`
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

    this.selectOptions($initialOption);
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
        that.selectOptions($option);
      });
    });

    if (this.$filter) {
      this.$filter.on('textchange', function () {
        that.handleFiltering();
      });
    }

    this.$target.on('change', function () {
      let $options = [];

      if (that.isMultiSelect) {
        $(this)
          .val()
          .forEach(function (value) {
            $options.push(
              that.$comboboxOptions.filter(`[data-value="${value}"]`)
            );
          });
        that.$comboboxOptions.removeClass('selected');
        that.$combobox.find('.combobox-multi-option').remove();
      } else {
        $options = that.$comboboxOptions.filter(
          `[data-value="${$(this).val()}"]`
        );
      }

      that.selectOptions($options);
    });
  }

  appendOption($parent, $option) {
    $parent.append(
      `<span\
        class="combobox-option ${$option.attr('disabled') ? 'disabled' : ''}"\
        data-behavior="combobox-option"\
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
          isOption = $option.is('[data-behavior~=combobox-option]'),
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

  selectOptions(options) {
    const that = this;

    if (!Array.isArray(options)) {
      options = [options];
    }

    options.forEach(function ($option) {
      if (that.isMultiSelect) {
        if (
          that.$combobox.find(`[data-option-value="${$option.data('value')}"]`)
            .length
        ) {
          return;
        }

        that.$combobox.append(
          `<div class="combobox-multi-option" data-option-value="${$option.data(
            'value'
          )}">\
            <span>${$option.text()}</span>\
            <div class="unselect-multi-option" data-behavior="unselect-multi-option">\
              <i class="fa-solid fa-xmark"></i>\
              <span class="visually-hidden">Unselect option</span>\
            </div>\
          </div>`
        );

        that.$combobox
          .children()
          .last()
          .find('[data-behavior~=unselect-multi-option]')
          .on('click', function () {
            that.unselectMultiOption($(this).parent());
          });

        let selectedValues = that.$target.val() || [];
        selectedValues.push($option.data('value'));
        that.$target.val(selectedValues);
      } else {
        that.$combobox.text($option.text());
        that.$target.val($option.data('value'));
        that.$comboboxOptions.removeClass('selected');
      }

      $option.addClass('selected');
    });
  }

  unselectMultiOption($option) {
    let selectedValues = this.$target.val();
    const valueToRemove = $option.data('option-value');

    selectedValues = selectedValues.filter(function (value) {
      return value != valueToRemove;
    });

    this.$target.val(selectedValues);
    this.$target.trigger('change');
  }
}
