document.addEventListener("turbolinks:load", function() {
  const $modal = $('[data-behavior~=image-modal]');
  const targetImgs = 'img[data-toggle=modal]';

  var images = [],
      index = 0

  function changeImage(direction) {
    if (direction == 'next' && index < images.length - 1) {
      index += 1;
    } else if (direction == 'prev' && index > 0) {
      index -= 1;
    }

    loadImage(index);
  }

  function loadImage(index) {
    $modal.find('[data-behavior~=modal-title]').text(images[index].title);
    $modal.find('[data-behavior~=image-modal-image]').attr('src', images[index].src);

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

  $('[data-behavior~=view-content]').on('click', targetImgs, function() {
    images = [];
    index = 0;

    if ($(this).parents('[data-behavior~=comment-feed]').length) {
      $(this).parents('[data-behavior~=comment-feed]').find('[data-behavior~=content-textile]').each(function() {
        $(this).find(targetImgs).each(function() {
          $this = $(this);
          images.push({title: $this.attr('alt'), src: $this.attr('src')});
        });
      });
    } else {
      $(this).parents('[data-behavior~=content-textile]').find(targetImgs).each(function() {
        $this = $(this);
        images.push({title: $this.attr('alt'), src: $this.attr('src')});
      });
    }

    $this = $(this);
    index = images.map(function(e){ return e.src }).indexOf($(this).attr('src'));

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
