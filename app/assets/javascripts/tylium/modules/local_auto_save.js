document.addEventListener('turbolinks:load', function() {
  document.querySelectorAll('[data-behavior~=local-auto-save]').forEach(function(form) {
    var key  = form.dataset.autoSaveKey;
    var data = JSON.parse(localStorage.getItem(key));

    if (data !== null) {
      for (let [key, value] of Object.entries(data)) {
        if (key.slice(-2) == '[]') {
          value.forEach(function(checkboxValue) {
            var input = form.querySelector(`[name='${key}'][value='${checkboxValue}']`);
            input.checked = true;
          })
        } else {
          // Query for inputs here first so that we don't query twice
          var inputs = form.querySelectorAll(`[name='${key}']`);

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
      console.log('No data in localStorage for ' + key);
    }

    // List of available inputs: https://developer.mozilla.org/en-US/docs/Web/HTML/Element/input
    // Exclude these inputs so that it does not store unnecessary data in local cache
    var excludedInputTypes = ['button', 'file', 'image', 'password', 'reset', 'submit'];

    // Don't store authenticity_token and utf8
    var excludedHiddenInputNames = ['utf8', 'authenticity_token'];

    // Find all inputs and textareas of form, then exclude base on excluded input types
    var formInputs = Array.from(form.querySelectorAll('input, textarea, select')).filter(function(input) {
      return !excludedInputTypes.includes(input.getAttribute('type')) && !excludedHiddenInputNames.includes(input.name);
    })

    var setData = debounce(function() {
      localStorage.setItem(key, JSON.stringify(getData(formInputs)));
      console.log(getData(formInputs))
    }, 500);

    formInputs.forEach(function(input) {
      // we're using a jQuery plugin for :textchange event, so need to use $()
      $(input).on('textchange change', setData);
    })

    function getData() {
      var hashBuilder = function(hash, serializedField) {
        // Don't store utf8 and authenticity_token inputs
        if (excludedHiddenInputNames.includes(serializedField.name)) {
          return hash;
        }

        // Check if name is an array, i.e. collection checkboxes
        if (serializedField.name.slice(-2) == '[]') {
          // When using collection checkboxes, rails/simple_form will create a hidden input with
          // the same name
          if (!serializedField.value.length) {
            return hash;
          }
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

      // serializeArray() returns an array of objects with key and value attributes.
      // i.e. [{ name: 'card[name]', value: 1 }, { name: 'card[description]', value: 2 }]
      return $(form).serializeArray().reduce(hashBuilder, {});
    }

    function debounce(func, wait, immediate) {
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
    };

    form.addEventListener('submit', function(event) {
      localStorage.removeItem(key);
    });

    document.querySelectorAll('[data-behavior~=clear-local-auto-save]').forEach(function(element) {
      element.addEventListener('click', function(event) {
        localStorage.removeItem(key);
      })
    });
  });
});
