document.addEventListener( "turbolinks:load", function(){

  // hide date header if the previous date header is the same
  $('[data-behavior~=activity-date-header]').each(function() {
    var currentDate = $(this).find('[data-behavior~=activity-day-value]').text();
    var prevDate = $(this).prevAll('[data-behavior~=activity-date-header]:first').find('[data-behavior~=activity-day-value]').text();

    if (prevDate.length && currentDate == prevDate) {
      $(this).addClass('d-none').attr('data-visible', 'hidden');
    }
  })

  // select activities between visible date headers and group them together
  $('[data-behavior~=activity-date-header]').not('[data-visible~=hidden]').each(function() {
    $(this).nextUntil($('[data-behavior~=activity-date-header]').not('[data-visible~=hidden]')).wrapAll('<div class="activities-group" data-behavior="activities-group"></div>')
  })

  // move every other activity group to the right side
  $('[data-behavior~=activities-group]:odd').addClass('ml-auto');
})
