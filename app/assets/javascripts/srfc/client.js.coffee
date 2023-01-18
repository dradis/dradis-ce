# Security Roots Fleet Control
# (c) Security Roots 2015
# http://securityroots.com/
#
# Version log:
#   * v0.0.1 [2015-11-12] - Initial implementation
#
# References:
#   Mastering the Module Pattern
#   http://toddmotto.com/mastering-the-module-pattern/
#
#   JavaScript Module Pattern: In-Depth
#   http://www.adequatelygood.com/JavaScript-Module-Pattern-In-Depth.html
#
#   Essential JavaScript Namespacing Patterns
#   http://addyosmani.com/blog/essential-js-namespacing/
#
#   Module Pattern in JavaScript and CoffeeScript
#   https://robots.thoughtbot.com/module-pattern-in-javascript-and-coffeescript

class @SRFC
  @options: {
    api:   '//portal.securityroots.com/api/srfc',
    token: null
  }

  # We need this because the <body> tag may only contain the data-env attribute
  # once the DOM is loaded
  @init: ->
    @options.api   = '//localhost:3001/api/srfc' if $('body').data('env') == 'development'
    @options.token = $('meta[name="srfc-token"]').attr('content')

  @push: (event, payload) ->
    if $('body').data('env') == 'development'
      console.log("push(#{event})")
      console.log(payload)

    # We have to use JSONP for the cross-domain call.
    $.ajax
      type: 'GET',
      url: @options.api,
      async: false,
      contentType: "application/json",
      dataType: 'jsonp',
      data: {
        event: event,
        payload: payload,
        srfc_token: @options.token
      },
      jsonpCallback: 'srfc_callback',


jQuery ->
  SRFC.init()
