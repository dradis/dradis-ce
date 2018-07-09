App.comment = App.cable.subscriptions.create "CommentChannel",
  connected: ->
    # Called when the subscription is ready for use on the server

  disconnected: ->
    # Called when the subscription has been terminated by the server


  # Called when there's incoming data on the websocket for this channel
  received: (data) ->
    event = new CommentEvent(data)
    event.process() if event.isRelevant()


class CommentEvent
  constructor: (data) ->
    @$feed     = $("[data-commentable='#{data.comment_feed_id}']")
    @action    = data.action
    @commentId = data.comment_id
    @html      = data.html

  # We need to make sure that the comment we've been notified about belongs
  # on the currently-viewed page
  isRelevant: ->
    @$feed.length != 0

  updateCounters: ->
    count = $(".comments-list div.comment").length
    $("#comments_feed_no_comments").toggle(count == 0)
    $("#comments-count-badge").text(count)

  process: ->
    if @action == 'create'
      @$feed.find(".comments-list").append(@html)
      @$feed.find("#comment_form_submit_btn")
        .attr('value', 'Add comment')
        .attr('disabled', false)
      @$feed.find(".new_comment #comment_content").val('')
    else if @action == 'update'
      @$feed.find("#comment_#{@commentId}").replaceWith(@html)
    else if @action == 'destroy'
      @$feed.find("#comment_#{@commentId}").remove()
    @updateCounters()


