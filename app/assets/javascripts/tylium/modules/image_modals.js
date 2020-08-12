document.addEventListener("turbolinks:load", function() {
  const $modal = $('[data-behavior~=image-modal]');
  var images = [],
      index = 0,
      titles = [];

  function buildArrays($element) {
    titles.push($element.attr('alt'));
    images.push($element.attr('src'));
  }

  function changeImage(direction) {
    if (direction == 'next' && index < images.length - 1) {
      index += 1;
    } else if (direction == 'prev' && index > 0) {
      index -= 1;
    }

    loadImage(index);
  }

  function loadImage(index) {
    $modal.find('[data-behavior~=modal-title]').text(titles[index]);
    $modal.find('[data-behavior~=image-modal-image]').attr('src', images[index]);

    if (index == images.length - 1) {
      $('[data-direction~=next]').addClass('d-none');
    } else {
      $('[data-direction~=next]').removeClass('d-none');
    }

    if (index == 0) {
      $('[data-direction~=prev]').addClass('d-none');
    } else {
      $('[data-direction~=prev]').removeClass('d-none');
    }
  }

  $('[data-behavior~=content-textile] img').each(function() {
    $(this).attr('data-toggle', 'modal').attr('data-target', '[data-behavior~=image-modal]');
  });

  $('[data-behavior~=content-textile] img').click(function() {
    images = [];
    index = 0;
    titles = [];

    if ($(this).parents('[data-behavior~=comment-feed]').length) {
      $(this).parents('[data-behavior~=comment-feed]').find('[data-behavior~=content-textile]').each(function() {
        $(this).find('img').each(function() {
          buildArrays($(this));
        });
      });
    } else {
      $(this).parents('[data-behavior~=content-textile]').find('img').each(function() {
        buildArrays($(this));
      });
    }

    index = images.indexOf($(this).attr('src'));

    loadImage(index);
  });

  $('[data-direction]').click(function() {
    if ($(this).is('[data-direction~=next]')) {
      changeImage('next');
    } else if ($(this).is('[data-direction~=prev]')) {
      changeImage('prev');
    }
  });

  $($modal).keydown(function(e) {
    if (e.which == 39) {
      changeImage('next');
    } else if (e.which == 37) {
      changeImage('prev');
    }
  });
});
