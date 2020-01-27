# https://github.com/hassox/warden/wiki/Examples
# https://github.com/hassox/rails_warden
# http://team.skroutz.gr/posts/skroutz-warden/
# http://railscasts.com/episodes/305-authentication-with-warden

Warden::Manager.serialize_into_session do |user|
  user.id
end

Warden::Manager.serialize_from_session do |id|
  User.find_by_id(id)
end

# A simple db-backed strategy that uses the User.authenticate() method.
Warden::Strategies.add(:shared_password) do
  def valid?
    params['login'] || params['password']
  end

  def authenticate!
    username = params.fetch('login', nil)
    password = params.fetch('password', nil)

    if not ( username.blank? || password.nil? || ::BCrypt::Password.new(::Configuration.shared_password) != password )
      user = User.find_or_create_by(email: username)
      success!(user)
    else
      fail 'Invalid credentials.'
    end
  end
end

# A simple db-backed strategy that uses the User.authenticate() method.
Warden::Strategies.add(:db) do
  def valid?
    params['login'] || params['password']
  end
  def authenticate!
    if (user = User.enabled.authenticate(params['login'], params['password']))
      success!(user)
    else
      fail! 'Invalid credentials.'
    end
  end
end

Rails.configuration.middleware.use Warden::Manager do |manager|
  manager.default_strategies :shared_password
  manager.failure_app = ->(env) { SessionsController.action(:failure).call(env) }
end
