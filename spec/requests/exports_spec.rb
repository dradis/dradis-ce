require 'rails_helper'

describe 'export' do
  before do
    @project = create(:project)
    @user = create(:user, :admin)
    Configuration.create(name: 'admin:password', value: ::BCrypt::Password.create('rspec_pass'))
    post session_path, params: { login: @user.email, password: 'rspec_pass' }
  end

  it 'prevents invalid templates' do
    export = post project_export_path(
      @project, plugin: 'html_export', route: 'root', template: 'foobar'
    )

    expect(export).to redirect_to(project_export_manager_path(@project))
  end
end
