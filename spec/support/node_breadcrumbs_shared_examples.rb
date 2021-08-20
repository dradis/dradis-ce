# These are shared examples for breadcrumbs of notes and evidence in a node.
# For the first argument pass in the action (:new, :edit, :show), and
# pass the ActiveRecord class (Note, Evidence), as the second argument, e.g.:
#
#     include_examples "nodes pages breadcrumbs", :new, Note
#
# For the 'show' and 'edit' actions, define a let variable called 'model'
# which returns the model, e.g.:
#
#     let(:model) { @note }
#     include_examples "nodes pages breadcrumbs", :edit, Note
#
# (We can't pass @note in directly, as it doesn't exist in the scope where
# include_examples is called.)

shared_examples 'nodes pages breadcrumbs' do |action, klass|
  it 'displays breadcrumbs' do
    expect(page).to have_selector('.breadcrumb li a', text: 'Nodes')
    expect(page).to have_selector('.breadcrumb li a', text: @node.label)
    expect(page).to have_selector('.breadcrumb li a', text: klass.to_s.pluralize)
  end

  it 'redirects to node page when node label breadcrumb is clicked' do
    find('.breadcrumb li a', text: @node.label).click
    expect(page).to have_current_path(project_node_path(current_project, @node))
  end

  it 'redirects to node page with tab params when node label breadcrumb is clicked' do
    find('.breadcrumb li a', text: klass.to_s.pluralize).click
    expect(page).to have_current_path(
      project_node_path(current_project, @node, tab: "#{klass.to_s.pluralize.downcase}-tab")
    )
  end
  
  if action == :show
    it 'displays breadcrumbs dropdown' do
      expect(page).to have_selector('.dots-container .dropdown.dots-dropdown')
    end
  end

  if action == :new
    let(:params) { { } }

    it 'shows correct active breadcrumb' do
      expect(page).to have_selector('.breadcrumb li.active', text: "New #{klass.to_s}")
    end
  else
    it 'shows correct active breadcrumb' do
      expect(page).to have_selector(
        '.breadcrumb li.active', text: model.title
      )
    end
  end
end
