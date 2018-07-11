module CommentMacros
  include ActionView::RecordIdentifier

  def comment_feed
    '.comment-feed'
  end

  def show_comment_actions(comment)
    # edit/delete links only appear on mouse hover, and Capybara can't click
    # them when they're hidden.  Can't figure out how to 'hover' propery so
    # using this hack to show the links:
    hidden_element = "##{dom_id(comment)} .actions"
    page.execute_script("$('#{hidden_element}').css('visibility', 'visible')")
  end

  def click_edit_comment_link(comment)
    show_comment_actions(comment)
    within_comment(comment) { click_link 'Edit' }
  end

  def click_delete_comment_link(comment)
    show_comment_actions(comment)
    within_comment(comment) { click_link 'Delete' }
  end

  def have_comment(comment)
    have_selector "##{dom_id(comment)}"
  end

  def have_no_comment(comment)
    have_no_selector "##{dom_id(comment)}"
  end

  def submit_new_comment(content:)
    within 'form#new_comment' do
      fill_in :comment_content, with: content
      click_button 'Add comment'
    end
  end

  def within_comment(comment)
    within "##{dom_id(comment)}" do
      yield
    end
  end
end
