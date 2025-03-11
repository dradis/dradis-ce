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
    this.isMultiSelect = this.$target.attr('multiple');
    this.idSuffix = Math.random().toString(36).substring(2);

    this.init();
  }

  init() {
    if (this.isAlreadyInitialized()) {
      this.reinitialize();
    }

    this.buildDom();
    this.setupFilter();
    this.populateOptions();
    this.setInitialSelection();
    this.attachEventListeners();
  }

  appendCustomOption(value) {
    this.$target.append(`<option value="${value}">${value}</option>`);

    const $option = this.$target.children().last();

    this.appendOption(this.$comboboxMenu, $option);

    this.$comboboxOptions = this.$comboboxMenu.find(
      '[data-behavior~=combobox-option]'
    );

    this.selectOptions(this.$comboboxOptions.last());
  }

  appendOption($parent, $option) {
    const disabled = $option.attr('disabled') ? 'disabled' : '';
    const value = $option.attr('value') || $option.text();

    const {
      comboboxOptionIcon: iconClass,
      comboboxOptionIconColor: iconColor,
      comboboxOptionColor: optionColor,
    } = $option.data();

    $parent.append(
      `<span
        aria-selected="false"
        class="combobox-option ${disabled}"
        data-behavior="combobox-option"
        data-value="${value}"
        id="combobox-option-${this.idSuffix}-${value}"
        role="option"
        tabindex="${disabled ? '-1' : '0'}"
      >
        ${$option.text()}
      </span>`
    );

    const $appendedOption = $parent.children().last();

    if (iconClass) {
      $appendedOption.prepend(`<i class="${iconClass} fa-fw me-1"></i>`);

      if (iconColor) {
        $appendedOption.find('i').attr('style', `color: ${iconColor}`);
      }
    }

    if (optionColor) {
      $appendedOption.attr('style', `color: ${optionColor}`);
    }

    if (disabled) {
      $appendedOption.attr('aria-disabled', 'true');
    }
  }

  appendOptgroup($optgroup) {
    this.$comboboxMenu.append(
      `<div class="combobox-optgroup" data-behavior="combobox-optgroup">
        <span class="d-block px-2 py-1">${$optgroup.attr('label')}<span>
      </div>`
    );

    $optgroup.children('option').each((_, option) => {
      this.appendOption(
        this.$comboboxMenu.find('[data-behavior~=combobox-optgroup]').last(),
        $(option)
      );
    });
  }

  attachEventListeners() {
    this.$comboboxContainer.on('focusout', (event) => {
      // Hide menu if the newly focused element is outside of the ComboBox
      if (!$(event.relatedTarget).closest(this.$comboboxContainer).length) {
        this.hideMenu();
      }
    });

    this.$combobox.on('click', () => {
      this.showMenu();
    });

    this.$combobox.on('keydown', (event) => {
      if (event.key === 'Enter' || event.key === ' ') {
        this.showMenu();
        event.preventDefault();
      }
    });

    this.$comboboxMenu.on(
      'click keydown',
      '[data-behavior~=combobox-option]',
      (event) => {
        if (
          event.type === 'click' ||
          event.key === 'Enter' ||
          event.key === ' '
        ) {
          this.handleOptionSelection($(event.currentTarget), event);
        }
      }
    );

    this.$comboboxMenu.on('keydown', '[data-behavior~=add-option]', (event) => {
      if (event.key === 'Enter' || event.key === ' ') {
        this.handleAddingCustomOption();
        event.preventDefault();
      }
    });

    this.$addOption?.on('click', () => this.handleAddingCustomOption());

    this.$filter?.on('textchange', () => this.handleFiltering());

    this.$target.on('change', (event) => {
      let $options = [];

      if (this.isMultiSelect) {
        $(event.currentTarget)
          .val()
          .forEach((value) => {
            $options.push(
              this.$comboboxOptions.filter(`[data-value="${value}"]`)
            );
          });
        this.$comboboxOptions.removeClass('selected');
        this.$combobox.find('[data-behavior~=combobox-multi-option]').remove();
      } else {
        $options = this.$comboboxOptions.filter(
          `[data-value="${$(event.currentTarget).val()}"]`
        );
      }

      this.selectOptions($options);

      this.$combobox.toggleClass(
        'disabled',
        !!$(event.currentTarget).attr('disabled')?.length
      );
    });

    this.$combobox.on(
      'click',
      '[data-behavior~=unselect-multi-option]',
      (event) => {
        event.stopPropagation();
        this.unselectMultiOption($(event.currentTarget).parent());
        this.$combobox.blur();
      }
    );
  }

  buildDom() {
    this.$target
      .addClass('d-none')
      .wrap(
        `<div class="combobox-container" data-behavior="combobox-container"></div>`
      );

    this.$comboboxContainer = this.$target.parent();

    this.$comboboxContainer.append(`
      <div 
        class="combobox ${this.isMultiSelect ? 'multiple' : ''}" 
        tabindex="0" 
        role="combobox"
        aria-expanded="false"
        aria-owns="combobox-menu-${this.idSuffix}" 
        aria-controls="combobox-menu-${this.idSuffix}" 
        aria-haspopup="listbox" 
        aria-autocomplete="list"
        data-behavior="combobox">
      </div>
      <div 
        class="combobox-menu" 
        role="listbox" 
        id="combobox-menu-${this.idSuffix}" 
        ${this.isMultiSelect ? 'aria-multiselectable="true"' : ''} 
        data-behavior="combobox-menu">
      </div>
    `);

    this.$combobox = this.$comboboxContainer.find('[data-behavior~=combobox]');
    this.$comboboxMenu = this.$combobox.next('[data-behavior~=combobox-menu]');
  }

  handleAddingCustomOption() {
    this.appendCustomOption(this.$filter.val());
    if (this.isMultiSelect) {
      this.$filter?.val(null).trigger('textchange');
    } else {
      this.hideMenu();
    }
  }

  handleFiltering() {
    clearTimeout(this.debounceTimeout);

    this.debounceTimeout = setTimeout(() => {
      const filterText = this.$filter.val().toLowerCase();

      if (this.config.includes('remote-filter')) {
        const url = this.$target.data('url');

        this.$comboboxMenu.find('[data-behavior~=spinner]').remove();
        this.$comboboxMenu.find('[data-behavior~=combobox-option]').remove();

        this.$comboboxMenu.append(
          `<div class="py-2 text-center" data-behavior="spinner">
            <div class="spinner-border text-primary">
              <span class="visually-hidden">Loading</span>
            </div>
          </div>`
        );

        fetch(url + '?query=' + filterText)
          .then((response) => response.json())
          .then((data) => {
            if (data.length) {
              data.forEach((option) => {
                const $option = $(
                  `<option value="${option[1]}">${option[0]}</option>`
                );

                this.appendOption(this.$comboboxMenu, $option);
              });
            } else {
              this.$filter
                .next('[data-behavior~=no-results]')
                .toggleClass('d-none', true);
            }
            this.$comboboxMenu.find('[data-behavior~=spinner]').remove();
          });
      } else {
        let matchedOptions = 0;

        this.$comboboxOptions.each((_, option) => {
          const $option = $(option),
            isOption = $option.is('[data-behavior~=combobox-option]'),
            isMatch =
              isOption && $option.text().toLowerCase().includes(filterText);

          $option.toggleClass('d-none', !isMatch);

          if (isMatch) matchedOptions++;
        });

        if (this.config.includes('add-options')) {
          this.$addOption.find('strong').text(this.$filter.val());
          this.$addOption.toggleClass('d-none', matchedOptions > 0);
        } else {
          this.$filter
            .next('[data-behavior~=no-results]')
            .toggleClass('d-none', matchedOptions > 0);
        }
      }
    }, this.debounceTimer);
  }

  handleOptionSelection($option, event) {
    if ($option.hasClass('selected') && this.isMultiSelect) {
      const $unselectedOption = this.$combobox.find(
        `[data-option-value="${$option.data('value')}"]`
      );
      this.unselectMultiOption($unselectedOption);
    } else {
      this.selectOptions($option);
    }
    this.$target.trigger('change');
    if (!this.isMultiSelect) this.hideMenu();

    if (event) event.preventDefault();
  }

  hideMenu() {
    this.$comboboxMenu.css('display', 'none');
    this.$combobox.attr('aria-expanded', 'false');
    this.$filter?.val(null).trigger('textchange');
  }

  isAlreadyInitialized() {
    return this.$target.parent().is('[data-behavior~=combobox-container]');
  }

  populateOptions() {
    this.$target.children().each((_, child) => {
      if (child.tagName.toLowerCase() === 'option') {
        this.appendOption(this.$comboboxMenu, $(child));
      } else if (child.tagName.toLowerCase() === 'optgroup') {
        this.appendOptgroup($(child));
      }
    });

    this.$comboboxOptions = this.$comboboxMenu.find(
      '[data-behavior~=combobox-option]'
    );
  }

  reinitialize() {
    this.$comboboxContainer.remove();
    this.init();
  }

  selectMultiOptions($options) {
    $options.forEach(($option) => {
      if (
        this.$combobox.find(`[data-option-value="${$option.data('value')}"]`)
          .length
      ) {
        return;
      }

      this.$combobox.append(
        `<div 
          class="combobox-multi-option"
          data-behavior="combobox-multi-option"
          data-option-value="${$option.data('value')}"
        >
          <span>${$option.text()}</span>
          <div class="unselect-multi-option" data-behavior="unselect-multi-option">
            <i class="fa-solid fa-xmark"></i>
            <span class="visually-hidden">Unselect option</span>
          </div>
        </div>`
      );

      let selectedValues = this.$target.val() || [];
      selectedValues.push($option.data('value'));
      this.$target.val(selectedValues);
      $option.addClass('selected');
      $option.attr('aria-selected', 'true');
    });
  }

  selectOptions(options) {
    if (!Array.isArray(options)) {
      options = [options];
    }

    if (this.isMultiSelect) {
      this.selectMultiOptions(options);
    } else {
      this.selectSingleOption(options[0]);
    }
  }

  selectSingleOption($option) {
    this.$combobox.html($option.html());
    this.$combobox.attr('style', $option.attr('style') || '');
    this.$target.val($option.data('value'));
    this.$comboboxOptions.removeClass('selected');
    this.$comboboxOptions.attr('aria-selected', 'false');
    $option.addClass('selected');
    $option.attr('aria-selected', 'true');
  }

  setInitialSelection() {
    let $initialOption = this.$comboboxOptions.filter(
      `[data-value="${this.$target.val()}"]`
    );

    $initialOption = $initialOption.length
      ? $initialOption
      : this.$comboboxOptions.first();

    this.selectOptions($initialOption);
    this.$combobox.toggleClass(
      'disabled',
      !!this.$target.attr('disabled')?.length
    );
  }

  setupFilter() {
    if (this.config.includes('no-filter')) return;

    this.$comboboxMenu.append(`
      <div class="d-flex flex-column pt-1">
        <label class="visually-hidden" for="combobox-filter-${this.idSuffix}">Filter options</label>
        <input type="search" class="form-control mx-2 mb-2 w-auto" data-behavior="combobox-filter" id="combobox-filter-${this.idSuffix}" placeholder="Filter options...">
        <span class="d-block text-secondary text-center d-none pe-none" data-behavior="no-results">No results.</span>
      </div>
    `);

    this.$filter = this.$comboboxMenu.find('[data-behavior~=combobox-filter]');

    if (this.config.includes('add-options')) {
      this.$filter.parent().append(
        `<span class="combobox-option d-none" data-behavior="add-option" tabindex="0">
          <i class="fa-solid fa-plus me-1"></i>
          Create <strong>${this.$filter.val()}</strong> option
          </span>`
      );

      this.$filter.attr('placeholder', 'Filter or create options...');
      this.$addOption = this.$filter.siblings('[data-behavior~=add-option]');
    }
  }

  showMenu() {
    this.$comboboxMenu.css('display', 'block');
    this.$combobox.attr('aria-expanded', 'true');
    this.$filter?.focus();
  }

  unselectMultiOption($option) {
    const valueToRemove = $option.data('option-value'),
      selectedValues = this.$target
        .val()
        .filter((value) => value != valueToRemove);
    this.$target.val(selectedValues).trigger('change');
  }
}
