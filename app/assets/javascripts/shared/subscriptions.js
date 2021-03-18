class Subscriptions {
  constructor() {
    this.init();
  }

  init() {
    if ($('[data-behavior~=subscription-actions]').length) {
      var subscribed = $('[data-behavior~=subscription-actions]').data('subscribed');

      if (subscribed) {
        $('[data-behavior=unsubscribe]').removeClass('d-none');
      } else {
        $('[data-behavior=subscribe]').removeClass('d-none');
      }
    }
  }
}
