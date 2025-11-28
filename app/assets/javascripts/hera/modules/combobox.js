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

    if (this.config.includes('no-combobox')) {
      return;
    }

    this.debounceTimer = 250;
    this.isMultiSelect = this.$target.attr('multiple');

    // Generate a unique identifier for the combobox element
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
    this.setupMutationObserver();
  }

  appendCustomOption(value) {
    const sanitizedValue = $('<div>').text(value).html();
    this.$target.append(
      `<option value="${sanitizedValue}">${sanitizedValue}</option>`,
    );

    if (this.isMultiSelect) {
      let selectedValues = this.$target.val() || [];
      selectedValues.push(sanitizedValue);
      this.$target.val(selectedValues).trigger('change');
    } else {
      this.$target.val(sanitizedValue).trigger('change');
    }
  }

  appendOption($parent, $option) {
    const disabled = $option.attr('disabled') ? 'disabled' : '';
    const escapedText = $('<div>').text($option.text()).html();
    const value = $option.attr('value');

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
      >${escapedText}</span>`,
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
      </div>`,
    );

    $optgroup.children('option').each((_, option) => {
      this.appendOption(
        this.$comboboxMenu.find('[data-behavior~=combobox-optgroup]').last(),
        $(option),
      );
    });
  }

  attachEventListeners() {
    // Using event delegation on the container so that if options are updated,
    // the listener remains attached.

    this.$comboboxContainer.off('.combobox'); // detach previous handlers

    this.$comboboxContainer.on('focusout.combobox', (event) => {
      // Hide menu if the newly focused element is outside of the ComboBox
      if (!$(event.relatedTarget).closest(this.$comboboxContainer).length) {
        this.hideMenu();
      }
    });

    this.$combobox.on('click.combobox', () => {
      this.showMenu();
    });

    this.$combobox.on('keydown.combobox', (event) => {
      if (event.key === 'Enter' || event.key === ' ') {
        this.showMenu();
        event.preventDefault();
      }
    });

    this.$comboboxMenu
      .off('.combobox') // remove any previous namespaced events
      .on(
        'click.combobox keydown.combobox',
        '[data-behavior~=combobox-option]',
        (event) => {
          if (
            event.type === 'click' ||
            event.key === 'Enter' ||
            event.key === ' '
          ) {
            this.handleOptionSelection($(event.currentTarget), event);
          } else if (event.key === 'ArrowDown' || event.key === 'ArrowUp') {
            this.handleArrowNavigation(event);
          }
        },
      )
      .on(
        'click.combobox keydown.combobox',
        '[data-behavior~=add-option]',
        (event) => {
          if (
            event.type === 'click' ||
            event.key === 'Enter' ||
            event.key === ' '
          ) {
            this.handleAddingCustomOption();
            event.preventDefault();
          }
        },
      );

    // Delegated event listener for the filter input
    this.$comboboxMenu
      .off('input.combobox', '[data-behavior~=combobox-filter]')
      .on('input.combobox', '[data-behavior~=combobox-filter]', () => {
        this.handleFiltering();
      });

    this.$target.off('.combobox').on('change.combobox', (event) => {
      // Store the value that triggered this change so we can revert if there
      // is a handler that cancels the change
      const valueBeforeHandlers = $(event.currentTarget).data(
        'combobox-value-before',
      );

      // Use setTimeout to let other handlers run first, then check if value was reverted
      setTimeout(() => {
        const currentValue = this.$target.val();

        // If value was reverted back by another handler, update UI to match
        if (
          JSON.stringify(currentValue) === JSON.stringify(valueBeforeHandlers)
        ) {
          this.refreshComboboxFromSelectValue();
          return;
        }

        // Otherwise proceed with normal update
        this.refreshComboboxFromSelectValue();
      }, 0);
    });

    this.$combobox.on(
      'click.combobox',
      '[data-behavior~=unselect-multi-option]',
      (event) => {
        event.stopPropagation();
        this.unselectMultiOption($(event.currentTarget).parent());
        this.$combobox.blur();
      },
    );
  }

  setupMutationObserver() {
    const observer = new MutationObserver((mutations) => {
      mutations.forEach((mutation) => {
        // Handle changes to the `disabled` attribute of the target select
        if (mutation.attributeName === 'disabled') {
          const isDisabled = !!this.$target.attr('disabled');
          this.$combobox.toggleClass('disabled', isDisabled);
        }

        // Ensure changes to options are reflected in the combobox
        if (mutation.type === 'childList') {
          const currentFilter = this.$filter?.val();

          this.$comboboxMenu.empty();
          this.setupFilter();
          this.populateOptions();

          if (currentFilter) {
            this.$filter?.val(currentFilter).trigger('input');
          }

          this.refreshComboboxUI();
        }
      });
    });

    observer.observe(this.$target[0], {
      attributes: true,
      childList: true,
    });
  }

  buildDom() {
    this.$target
      .addClass('d-none')
      .wrap(
        `<div class="combobox-container" data-behavior="combobox-container"></div>`,
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
      this.$filter?.val(null).trigger('input');
    } else {
      this.hideMenu();
    }
  }

  handleArrowNavigation(event) {
    event.preventDefault();

    const $options = this.$comboboxOptions.not('.disabled');
    const $focusedOption = this.$comboboxMenu.find(
      '[data-behavior~=combobox-option]:focus',
    );

    let newIndex = $options.index($focusedOption);

    if (event.key === 'ArrowDown') {
      newIndex = newIndex < $options.length - 1 ? newIndex + 1 : 0;
    } else if (event.key === 'ArrowUp') {
      newIndex = newIndex > 0 ? newIndex - 1 : $options.length - 1;
    }

    $options.eq(newIndex).focus();
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
          </div>`,
        );

        fetch(url + '?query=' + filterText)
          .then((response) => response.json())
          .then((data) => {
            if (data.length) {
              data.forEach((option) => {
                const $option = $(
                  `<option value="${option[1]}">${option[0]}</option>`,
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
    if ($option.hasClass('disabled')) {
      return;
    }

    const value = $option.data('value');

    this.$target.data('combobox-value-before', this.$target.val());

    if (this.isMultiSelect) {
      let selectedValues = this.$target.val() || [];

      if ($option.hasClass('selected')) {
        // Remove value from selection
        selectedValues = selectedValues.filter((v) => v != value);
      } else {
        // Add value to selection
        selectedValues.push(value);
      }

      this.$target.val(selectedValues).trigger('change');
    } else {
      this.$target.val(value).trigger('change');
      this.hideMenu();
    }

    if (event) event.preventDefault();
  }

  hideMenu() {
    this.$comboboxMenu.css('display', 'none');
    this.$combobox.attr('aria-expanded', 'false');
    this.$filter?.val(null).trigger('input');
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
      '[data-behavior~=combobox-option]',
    );
  }

  reinitialize() {
    const $existingContainer = this.$target.parent(),
      $targetParent = $existingContainer.parent(),
      $targetSelect = this.$target.clone();

    $targetSelect.appendTo($targetParent);
    $existingContainer.remove();
    this.$target = $targetSelect;
  }

  updateComboboxUI(options) {
    if (!Array.isArray(options)) {
      options = [options];
    }

    if (this.isMultiSelect) {
      this.updateMultiSelectUI(options);
    } else {
      this.updateSingleSelectUI(options[0]);
    }
  }

  updateMultiSelectUI($options) {
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
        </div>`,
      );

      $option.addClass('selected');
      $option.attr('aria-selected', 'true');
    });
  }

  updateSingleSelectUI($option) {
    this.$combobox.html($option.html());
    this.$combobox.attr('style', $option.attr('style') || '');

    var value = $option.data('value');
    if (value && value.length && value != 'undefined') {
      // If the selected value is not present in the original select, add it.
      if (!this.$target.find('option[value="' + value + '"]').length) {
        this.$target.find('option:last').val(value);
      }
    }

    this.$comboboxOptions.removeClass('selected');
    this.$comboboxOptions.attr('aria-selected', 'false');
    $option.addClass('selected');
    $option.attr('aria-selected', 'true');
  }

  setInitialSelection() {
    let $initialOption = this.$comboboxOptions.filter(
      `[data-value="${this.$target.val()}"]`,
    );

    if (!$initialOption.length) {
      if (this.isMultiSelect) {
        $initialOption = [];
      } else {
        $initialOption = this.$comboboxOptions.first();
      }
    }

    this.updateComboboxUI($initialOption);
    this.$combobox.toggleClass(
      'disabled',
      !!this.$target.attr('disabled')?.length,
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
          </span>`,
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

  refreshComboboxUI() {
    let $options = [];

    if (this.isMultiSelect) {
      const currentValues = this.$target.val() || [];
      currentValues.forEach((value) => {
        const $option = this.$comboboxOptions.filter(`[data-value="${value}"]`);
        if ($option.length) {
          $options.push($option);
        }
      });
      this.$comboboxOptions.removeClass('selected');
      this.$combobox.find('[data-behavior~=combobox-multi-option]').remove();
    } else {
      $options = this.$comboboxOptions.filter(
        `[data-value="${this.$target.val()}"]`,
      );
    }

    this.updateComboboxUI($options);
  }

  refreshComboboxFromSelectValue() {
    this.$comboboxOptions = this.$comboboxMenu.find(
      '[data-behavior~=combobox-option]',
    );

    let $options = [];

    if (this.isMultiSelect) {
      const currentValues = this.$target.val() || [];
      currentValues.forEach((value) => {
        const $option = this.$comboboxOptions.filter(`[data-value="${value}"]`);
        if ($option.length) {
          $options.push($option);
        }
      });
      this.$comboboxOptions.removeClass('selected');
      this.$combobox.find('[data-behavior~=combobox-multi-option]').remove();
    } else {
      $options = this.$comboboxOptions.filter(
        `[data-value="${this.$target.val()}"]`,
      );
    }

    this.updateComboboxUI($options);
  }
}
