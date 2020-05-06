class LocalAutoSave {
  constructor(target) {
    if (target.tagName !== 'FORM') { console.error('Can\'t initialize local auto save on anything but a form'); return; }
    this.target = target;
    this.key = target.dataset.autoSaveKey;
    this.cancelled = false;

    // List of available inputs: https://developer.mozilla.org/en-US/docs/Web/HTML/Element/input
    // Only permit these inputs to be saved so that it does not store unnecessary data in local cache
    this.permittedInputTypes = [
      'checkbox',
      'color',
      'date',
      'email',
      'hidden', // Needed for hidden tag_input in issues/form
      'number',
      'radio',
      'tel',
      'text'
    ];

    // Don't store authenticity_token and utf8
    this.excludedInputNames = ['utf8', 'authenticity_token'];

    this.init();
  }

  init() {
    this.behaviors();
    this.restoreData();
  }

  behaviors() {
    var that = this;

    this.target.addEventListener('submit', function(event) {
      localStorage.removeItem(that.key);
    });

    var clearCacheElement = this.target.querySelector('[data-behavior~=clear-local-auto-save]');

    if (clearCacheElement) {
      clearCacheElement.addEventListener('click', function(event) {
        that.cancelled = true;
        localStorage.removeItem(that.key);
      })
    }

    // Find all inputs in the form, then exclude based on excluded input types
    var formInputs = Array.from(this.target.querySelectorAll('input')).filter(function(input) {
      return that.permittedInputTypes.includes(input.getAttribute('type')) && !that.excludedInputNames.includes(input.name);
    })

    formInputs = formInputs.concat(Array.from(this.target.querySelectorAll('textarea, select')));

    formInputs.forEach(function(input) {
      // we're using a jQuery plugin for :textchange event, so need to use $()
      $(input).on('textchange change', that.debounce(that.setData.bind(that), 500));
    })
  }

  debounce(func, delay) {
    let debounceTimer;

    return function () {
      const context = this;
      const args = arguments;
      clearTimeout(debounceTimer);
      debounceTimer = setTimeout(() => func.apply(context, args), delay);
    };
  }

  getData() {
    var that = this;

    var data = new FormData(this.target)

    var hashBuilder = function(hash, dataArray) {
      // Don't store utf8 and authenticity_token inputs
      if (that.excludedInputNames.includes(dataArray[0])) { return hash; }

      // Check if name is an array, i.e. collection checkboxes
      if (dataArray[0].slice(-2) == '[]') {
        // When using collection checkboxes, rails/simple_form will create a hidden input with
        // the same name, i.e. <input type="hidden" name="card[assignee_ids][]" value="">
        // Don't store that hidden input
        if (!dataArray[1].length) { return hash; }

        // if array exist, push value to array, else create new array
        if (hash[dataArray[0]]) {
          hash[dataArray[0]].push(dataArray[1]);
        } else {
          hash[dataArray[0]] = [dataArray[1]];
        }
      } else {
        hash[dataArray[0]] = dataArray[1];
      }

      return hash;
    }

    return Array.from(data.entries()).reduce(hashBuilder, {});
  }

  restoreData() {
    var that = this;
    var data = JSON.parse(localStorage.getItem(this.key));

    if (data !== null) {
      for (let [key, value] of Object.entries(data)) {
        if (key.slice(-2) == '[]') {
          value.forEach(function(checkboxValue) {
            var input = that.target.querySelector(`[name='${key}'][value='${checkboxValue}']`);
            input.checked = true;
          })
        } else {
          // Query for inputs here first so that we don't query twice
          var inputs = that.target.querySelectorAll(`[name='${key}']`);

          if (inputs.length) {
            // Handle checking for radio button and check boxes
            if (['checkbox', 'radio'].includes(inputs[0].type)) {
              inputs.forEach(function(input) {
                if (input.value == value) {
                  input.checked = true;
                }
              });
            } else {
              inputs[0].value = value;
              $(inputs[0]).trigger('load-preview');
            }
          }
        }
      }

      // Restore tag input dropdown in isses/_form
      if (data['issue[tag_list]'] && data['issue[tag_list]'].length) {
        var hiddenInput = document.querySelector('#issue_tag_list')
        hiddenInput.value = data['issue[tag_list]']

        var dropdownBtnSpan = document.querySelector('#issues_editor .dropdown-toggle span.tag')
        var selectedDropdown = document.querySelector(`.js-taglink[data-tag='${data['issue[tag_list]']}']`)

        dropdownBtnSpan.innerHTML = selectedDropdown.innerHTML
        dropdownBtnSpan.style.color = selectedDropdown.style.color
      }
    }
  }

  setData() {
    if (!this.cancelled) {
      localStorage.setItem(this.key, JSON.stringify(this.getData()));
    }
  }
}
