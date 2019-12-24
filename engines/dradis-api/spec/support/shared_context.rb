shared_context "https" do
  before do
    @env ||= {}
    @env["HTTPS"] = "on"
  end
end

shared_context "content_type: application/json" do
  before do
    @env ||= {}
    @env["CONTENT_TYPE"] = "application/json"
  end
end

shared_context "authorized API user" do
  before do
    @logged_in_as = User.find_or_create_by(email: 'rspec')
    @password     = 'rspec_pass'
    allow(Configuration).to \
      receive(:shared_password).and_return(::BCrypt::Password.create(@password))
    @env["HTTP_AUTHORIZATION"] = \
      ActionController::HttpAuthentication::Basic.encode_credentials(@logged_in_as.email, @password)
  end
end

shared_context "project scoped API" do
  let(:current_project) { Project.new }
end
