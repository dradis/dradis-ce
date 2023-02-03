class SRFC {
  constructor(api, token) {
    this.api = api;
    this.token = token;
  }

  push(event, payload) {
    if ($('body').data('env') == 'development') {
      console.log('push(#{event})');
      console.log(payload);
    }

    $.ajax({
      url: this.api,
      method: 'GET',
      contentType: 'application/json',
      dataType: 'jsonp',
      data: {
        event,
        payload,
        srfc_token: this.token,
      },
      jsonpCallback: 'srfc_callback',
    });
  }
}
var api =  $('body').data('env') == 'development' ? '//localhost:3001/api/srfc' : '//portal.securityroots.com/api/srfc'
var token =  $('meta[name="srfc-token"]').attr('content')
var SRFC = new SRFC(api, token)

