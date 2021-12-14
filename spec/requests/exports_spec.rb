require 'rails_helper'

describe 'export' do
  let(:ce_login) do
    @project = create(:project)
    @user = create(:user, :admin)
    Configuration.create(name: 'admin:password', value: ::BCrypt::Password.create('rspec_pass'))
    post session_path, params: { login: @user.email, password: 'rspec_pass' }
  end

  let(:pro_login) do
    login_to_project_as_user
  end

  before { defined?(Dradis::Pro) ? pro_login : ce_login }

  it 'prevents invalid templates' do
    export = post project_export_path(
      @project, plugin: 'html_export', route: 'root', template: 'foobar'
    )

    expect(export).to redirect_to(project_export_manager_path(@project))
  end
end
