require 'rails_helper'

# The shared password step only exists in CE.
describe 'Setup::Passwords', if: !defined?(Dradis::Pro) do
  def submit_password(password, confirmation)
    post setup_password_path, params: {
      configuration_shared_password_form: { password: password, password_confirmation: confirmation }
    }
  end

  it 'saves the shared password and moves on to the next step' do
    submit_password('rspec_pass', 'rspec_pass')

    expect(response).to redirect_to(new_setup_analytics_path)
    expect(::BCrypt::Password.new(::Configuration.shared_password)).to eq('rspec_pass')
  end

  it 'shows the error under the password field when it is blank' do
    submit_password('', '')

    expect(response).to have_http_status(:unprocessable_entity)
    expect(response.body).to include('Please review the problems below:')
    expect(response.body).to include('Password can&#39;t be blank')
  end

  it 'shows the error under the confirmation field when it does not match' do
    submit_password('rspec_pass', 'other_pass')

    expect(response).to have_http_status(:unprocessable_entity)
    expect(response.body).to include('Password confirmation doesn&#39;t match Password')
  end

  it 'rejects a submission without a confirmation' do
    post setup_password_path, params: { configuration_shared_password_form: { password: 'rspec_pass' } }

    expect(response).to have_http_status(:unprocessable_entity)
    expect(response.body).to include('Password confirmation can&#39;t be blank')
    expect(::Configuration.shared_password).to eq('improvable_dradis')
  end
end
