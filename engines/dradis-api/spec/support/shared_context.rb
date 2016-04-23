shared_context "https" do
  before { @env = { "HTTPS" => "on" } }
end

shared_context "authenticated API user" do
  before do
    pw ='rspec_pass'
    allow(Configuration).to \
      receive(:shared_password).and_return(::BCrypt::Password.create(pw))
    @env["HTTP_AUTHORIZATION"] = \
      ActionController::HttpAuthentication::Basic.encode_credentials('rspec', pw)
  end
end
