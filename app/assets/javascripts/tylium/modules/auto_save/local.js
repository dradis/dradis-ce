class LocalAutoSave {
  constructor(target) {
    if (target.tagName !== 'FORM') { console.error('Can\'t initialize local auto save on anything but a form'); return; }
    this.target = target;
    this.key = target.dataset.autoSaveKey;
    this.cancelled = false;

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

    this._debounceTimer = 500;

    this.target.querySelectorAll('input, textarea, select').forEach(function(input) {
      // we're using a jQuery plugin for :textchange event, so need to use $()
      $(input).on('textchange change', that.handleTextChange.bind(that));
    })
  }

  handleTextChange() {
    clearTimeout(this._debounceTimer);

    this._debounceTimer = setTimeout(function() {
      this.setData();
    }.bind(this), this._debounceTimer);
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
        if (!element) { continue; }

        // RadioNodeList is an array of checkboxes or radio buttons
        if (element instanceof RadioNodeList) {
          element.forEach(function(radioNodeListElement) {
            if (['checkbox', 'radio'].includes(radioNodeListElement.type)) {
              if (radioNodeListElement.value === item[1]) {
                radioNodeListElement.checked = true;
              }
            }
          })
        } else if (element.type === 'checkbox') {
          if (element.value === item[1]) {
            element.checked = true;
          }
        } else if (element.type === 'file') {
          element.value = '';
        } else {
          element.value = item[1];
          $(element).trigger('load-preview');
        }

        this.restoreTagInputDisplay(data);
      }
    }
  }

  restoreTagInputDisplay(data) {
    var tagInputData = data.find(function(item) {
      return item[0] === 'issue[tag_list]';
    })

    if (tagInputData) {
      var hiddenInput = document.querySelector('#issue_tag_list');
      hiddenInput.value = tagInputData[1];

      var $target = $(`.js-taglink[data-tag='${tagInputData[1]}']`);
      new SelectTagDropdown($target)
    }
  }

  setData() {
    if (!this.cancelled) {
      localStorage.setItem(this.key, JSON.stringify(this.getData()));
    }
  }
}
