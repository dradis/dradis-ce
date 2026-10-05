document.addEventListener "turbo:load", ->
  # Delegated so they also reach the add subnode form, which a Turbo Frame
  # loads after the page
  $(document).on "click", "[data-behavior~=add-node-radio]", ->
    $this  = $(this)
    $modal = $this.closest(".modal")
    isOne  = $this.val() == "one"
    $modal.find(".add_one_node_form").toggle(isOne)
    $modal.find(".add_multiple_nodes_form").toggle(!isOne)

  $(document).on "click", "[data-behavior~=add-node-submit]", ->
    $(this).attr('disabled', 'disabled').val('Processing...')
    $(this).closest(".modal").find("form:visible").submit()

  $(document).on "submit", "[data-behavior~=add-multiple-nodes-form]", (e) ->
    $modal = $(this).closest(".modal")
    unless $modal.find(".nodes_list").val().trim()
      e.preventDefault()
      $(".modal_add_node_submit_btn").removeAttr('disabled').val('Add')
      $(".add_multiple_nodes_error").show()

  if $('body.nodes.show').length
    $('[data-behavior~=services-extras-link]').first().addClass('active')
    $('[data-behavior~=services-extras-tab-pane]').first().addClass('active')
