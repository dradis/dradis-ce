class SFRCClient {
  push(event, payload) {
    var api = '//portal.securityroots.com/api/srfc';
    var token = $('meta[name="srfc-token"]').attr('content');
    if ($('body').data('env') == 'development') {
      api = '//localhost:3001/api/srfc';
      console.log('push(#{event})');
      console.log(payload);
    }

    $.ajax({
      url: '//gorest.co.in/public/v2/users/601/posts',
      method: 'GET',
      contentType: 'application/json',
      dataType: 'jsonp',
      data: {
        event,
        payload,
        srfc_token: token,
      },
      jsonpCallback: 'srfc_callback',
    });
  }
}

var SRFC = new SFRCClient();
