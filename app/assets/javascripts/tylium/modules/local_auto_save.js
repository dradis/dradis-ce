document.addEventListener( "turbolinks:load", function(){

  document.querySelectorAll("[data-behavior~=local-auto-save").forEach( function(form){
    var key  = form.dataset.autoSaveKey;
    var data = "";

    if (typeof Storage !== "undefined" && Storage !== null) {
      data = JSON.parse(localStorage.getItem(key))
    } else {
      console.log("The browser doesn't support local storage of settings.")
    }

    if (data !== null) {
      for (let [key, value] of Object.entries(data)) {
        form.querySelector(`[name='${key}']`).value = value
      }
    } else {
      console.log("No data in localStorage for " + key);
    }

    // List of available inputs: https://developer.mozilla.org/en-US/docs/Web/HTML/Element/input
    // Exclude these inputs so that it does not store unnecessary data in local cache
    var excludedInputTypes = ["button", "file", "hidden", "image", "password", "reset", "submit"]

    // Find all inputs and textareas of form, then exclude base on excluded input types
    var formInputs = Array.from(form.querySelectorAll("input, textarea")).filter(function(input) {
      return !excludedInputTypes.includes(input.getAttribute("type"))
    })

    var timer;

    formInputs.forEach(function(input) {
      // we're using a jQuery plugin for :textchange event, so need to use $()

      $(input).on("textchange", function(event, previousText) {
        timer = setTimeout(function(){
          if (typeof Storage !== "undefined" && Storage !== null) {
            localStorage.setItem(key, JSON.stringify(getData(formInputs)));
          } else {
            console.log("The browser doesn't support local storage of settings.");
          }
        }, 1000);
      })
    })

    function getData(formInputs) {
      var reducer = function(hash, input) {
        hash[input.name] = input.value;
        return hash
      }

      return formInputs.reduce(reducer, {})
    }
  });
});
