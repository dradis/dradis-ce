document.addEventListener( "turbolinks:load", function(){
  console.log('auto_save loaded');

  document.querySelectorAll("[data-behavior~=auto-save]").forEach( function(item){
    console.log(item);

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
      } else {
        var response = confirm("There is data in your browser's cache for this form, but the field already contains some data. Would you like to overwrite the contents of the form with the saved data from the browser's cache?")
        if (response) {
          item.value = data;
        }
      }
    } else {
      console.log("No data in localStorage for " + key);
    }

    var timer;

    $(item).on("textchange", function(event, previousText) {
      console.log('textchange');
      console.log(event);

      clearTimeout(timer)

      timer = setTimeout(function(){
        console.log("Saving to localStorage...");
        console.log(event.currentTarget.value);
        if (typeof Storage !== "undefined" && Storage !== null) {
          localStorage.setItem(key, JSON.stringify(event.currentTarget.value));
        } else {
          console.log("The browser doesn't support local storage of settings.");
          console.log("Column selection can't be saved.");
        }
      }, 1000);
    });
  });
});
