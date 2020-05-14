document.addEventListener( "turbolinks:load", function(){

  // var $dateHeader = $('[data-behavior~=activity-date-header]')

  // remove date header if the previous date header is the same
  // $dateHeader.each(function() {
  //   var currentDate = $(this).find('[data-behavior~=activity-day-value]').text();
  //   var prevDate = $(this).prevAll('[data-behavior~=activity-date-header]:first').find('[data-behavior~=activity-day-value]').text();

  //   if (prevDate.length && currentDate == prevDate) {
  //     $(this).remove();
  //   }
  // });

  // select activities between visible date headers and group them together
  // $dateHeader.each(function() {
  //   $(this).nextUntil($dateHeader).wrapAll('<div class="activities-group" data-behavior="activities-group"></div>');
  // });

  // move every other activity group to the right side
  // $('[data-behavior~=activities-group]:odd').addClass('ml-auto');
});
