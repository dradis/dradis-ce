document.addEventListener( "turbolinks:load", function(){

  document.querySelectorAll("[data-behavior~=auto-save]").forEach( function(item){
    var key  = item.dataset.autosaveKey;
    var data = "";

    if (typeof Storage !== "undefined" && Storage !== null) {
      data = JSON.parse(localStorage.getItem(key))
    } else {
      console.log("The browser doesn't support local storage of settings.")
    }

    if (data !== null) {
      if (item.value === "") {
        item.value = data;
        $(item).trigger('load-preview');
      } else {
        var response = confirm("There is data in your browser's cache for this form, but the field already contains some data. Would you like to overwrite the contents of the form with the saved data from the browser's cache?")
        if (response) {
          item.value = data;
          $(item).trigger('load-preview');
        }
      }
    } else {
      console.log("No data in localStorage for " + key);
    }

    // we're using a jQuery plugin for :textchange event, so need to use $()
    var timer;
    $(item).on("textchange", function(event, previousText) {
      clearTimeout(timer)

      timer = setTimeout(function(){
        if (typeof Storage !== "undefined" && Storage !== null) {
          localStorage.setItem(key, JSON.stringify(event.currentTarget.value));
        } else {
          console.log("The browser doesn't support local storage of settings.");
        }
      }, 1000);
    });

    item.form.addEventListener("submit", function(event){
      if (typeof Storage !== "undefined" && Storage !== null) {
        localStorage.removeItem(key);
      }
    });
  });
});
