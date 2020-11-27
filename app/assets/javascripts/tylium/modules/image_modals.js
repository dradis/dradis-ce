// A class to help the management and navigation of a pseudo image carousel.
// It accepts an existing modal element and binds events to it. Images are then
// added to the object. The modal will be manipulated to carousel the images
// that have been added.
class ImageModal {
  constructor(images = [], index = 0, $element) {
    this.$element = $element;
    this.images = images;
    this.index = index;

    this.init();
  }

  init() {
    this.fnClick = function(e) {
      this[$(e.target).data('direction')]();
    }.bind(this);

    this.fnKeys = function(e) {
      if (e.which == 39) {
        this.next();
      } else if (e.which == 37) {
        this.prev();
      }
    }.bind(this);

    this.$element.find('[data-direction]').click(this.fnClick)
    this.$element.keydown(this.fnKeys);
  }

  unbind() {
    this.$element.find('[data-direction]').unbind('click', this.fnClick);
    this.$element.unbind('keydown', this.fnKeys);
  }

  addImage(image) {
    var $image = $(image);
    this.images.push( { title: $image.attr('alt'), src: $image.attr('src') } );
    return image
  }

  next() {
    if (this.index + 1 < this.images.length) {
      this.index += 1;
      this.loadImage(this.index);
    }
  }

  prev() {
    if (this.index !== 0) {
      this.index -= 1;
      this.loadImage(this.index);
    }
  }

  setTitle(title) {
    this.$element.find('[data-behavior~=modal-title]').text(title);
  }

  setImage(src) {
    this.$element.find('[data-behavior~=image-modal-image]').attr('src', src);
  }

  getIndex(img) {
    var src = $(img).attr('src');
    return this.images.map(function(e){ return e.src }).indexOf(src)
  }

  loadImage(index) {
    this.index = index;
    var image = this.images[index];

    this.setTitle(image.title);
    this.setImage(image.src);
    this.resetChevrons(index);
  }

  resetChevrons(index) {
    if (index == this.images.length - 1) {
      this.$element.find('[data-direction~=next]').addClass('d-none');
    } else {
      this.$element.find('[data-direction~=next]').removeClass('d-none');
    }

    if (index == 0) {
      this.$element.find('[data-direction~=prev]').addClass('d-none');
    } else {
      this.$element.find('[data-direction~=prev]').removeClass('d-none');
    }
  }
}
