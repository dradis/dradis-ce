document.addEventListener('turbolinks:load', function() {
  // https://stackoverflow.com/a/34896387
  document.addEventListener('click', function(e) {
    var element = e.target;

    if(element && element.dataset.behavior.includes('cancel-comment')) {
      var comment = e.target.parentNode.parentNode.parentNode;

      var form = comment.querySelector("form");
      form.remove();

      comment.querySelector(".content").style.display = '';
      comment.querySelector('[data-action~=edit]').style.display = '';
    }
  });
})
