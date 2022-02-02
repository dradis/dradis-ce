require 'rails_helper'

describe 'export' do

  before { login_to_project_as_user }

  it 'prevents invalid templates' do
    export = post project_export_path(
      @project, plugin: 'html_export', route: 'root', template: 'foobar'
    )

    expect(export).to redirect_to(project_export_manager_path(@project))
  end
end
