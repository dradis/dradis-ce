class LocalAutoSave {
  constructor(target) {
    if (target.tagName !== 'FORM') { console.log('Can\'t initialize local auto save on anything but a form'); return; }
    this.target = target;
    this.key = target.dataset.autoSaveKey;

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
        localStorage.removeItem(that.key);
      })
    }

    // Find all inputs in the form, then exclude base on excluded input types
    var formInputs = Array.from(this.target.querySelectorAll('input')).filter(function(input) {
      return that.permittedInputTypes.includes(input.getAttribute('type')) && !that.excludedInputNames.includes(input.name);
    })

    formInputs = formInputs.concat(Array.from(this.target.querySelectorAll('textarea, select')));

    var setData = this.debounce(function() {
      localStorage.setItem(that.key, JSON.stringify(that.getData()));
    }, 500);

    formInputs.forEach(function(input) {
      // we're using a jQuery plugin for :textchange event, so need to use $()
      $(input).on('textchange change', setData);
    })
  }

  debounce(func, wait, immediate) {
    var timeout;

    return function() {
      var context = this, args = arguments;

      var later = function() {
        timeout = null;
        if (!immediate) func.apply(context, args);
      };
      var callNow = immediate && !timeout;

      clearTimeout(timeout);
      timeout = setTimeout(later, wait);
      if (callNow) func.apply(context, args);
    };
  }

  getData() {
    var that = this;

    var hashBuilder = function(hash, serializedField) {
      // Don't store utf8 and authenticity_token inputs
      if (that.excludedInputNames.includes(serializedField.name)) { return hash; }

      // Check if name is an array, i.e. collection checkboxes
      if (serializedField.name.slice(-2) == '[]') {

        // When using collection checkboxes, rails/simple_form will create a hidden input with
        // the same name, i.e. <input type="hidden" name="card[assignee_ids][]" value="">
        // Don't store that hidden input
        if (!serializedField.value.length) { return hash; }

        // if array exist, push value to array, else create new array
        if (hash[serializedField.name]) {
          hash[serializedField.name].push(serializedField.value);
        } else {
          hash[serializedField.name] = [serializedField.value];
        }
      } else {
        hash[serializedField.name] = serializedField.value;
      }

      return hash;
    }

    // serializeArray() is a jquery method that returns an array of objects with key and value attributes.
    // i.e. [{ name: 'card[name]', value: 1 }, { name: 'card[description]', value: 2 }]
    return $(this.target).serializeArray().reduce(hashBuilder, {});
  }

  restoreData() {
    var data = JSON.parse(localStorage.getItem(this.key));

    if (data !== null) {
      for (let [key, value] of Object.entries(data)) {
        if (key.slice(-2) == '[]') {
          value.forEach(function(checkboxValue) {
            var input = this.target.querySelector(`[name='${key}'][value='${checkboxValue}']`);
            input.checked = true;
          })
        } else {
          // Query for inputs here first so that we don't query twice
          var inputs = this.target.querySelectorAll(`[name='${key}']`);

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
    } else {
      console.log('No data in localStorage for ' + this.key);
    }
  }
}

document.addEventListener('turbolinks:load', function() {
  document.querySelectorAll('[data-behavior~=local-auto-save]').forEach(function(form) {
    new LocalAutoSave(form);
  });
});
