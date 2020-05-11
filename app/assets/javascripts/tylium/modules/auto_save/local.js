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
    this.excludedInputNames = ['utf8', 'authenticity_token', '_method'];

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
    var data = new FormData(this.target);
    var dataArray = Array.from(data).filter(function(dataElement) {
      return !that.excludedInputNames.includes(dataElement[0] );
    });

    return dataArray;
  }

  restoreData() {
    var that = this;
    var data = JSON.parse(localStorage.getItem(this.key));

    if (data !== null) {
      // Deserialization of form data
      // Reference: https://wildwolf.name/store-formdata-object-in-localstorage/
      for (var item of data) {
        var name = item[0];
        var element   = that.target.elements[name];

        // Skip loop if element is undefined
        if (!element) { continue }

        // RadioNodeList is an array of checkboxes or radio buttons
        if (element instanceof RadioNodeList) {
          console.log(element)
          element.forEach(function(radioNodeListElement) {
            if (['checkbox', 'radio'].includes(radioNodeListElement.type)) {
              if (radioNodeListElement.value == item[1]) {
                radioNodeListElement.checked = true
              }
            }
          })
        } else if (element.type === 'checkbox') {
          if (element.value == item[1]) {
            element.checked = true
          }
        } else if (element.type === 'file') {
          element.value = '';
        } else {
          element.value = item[1];
          $(element).trigger('load-preview');
        }
      }
    }
  }

  setData() {
    if (!this.cancelled) {
      localStorage.setItem(this.key, JSON.stringify(this.getData()));
    }
  }
}
