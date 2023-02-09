# In Heroku, assets:precompile is run before the DB is provisioned causing a
#   ActiveRecord::ConnectionNotEstablished: connection to server at "127.0.0.1",
#   port 5432 failed: Connection refused
#
# We run into this problem because dradis-plugins uses a :enabled/disabled DB
# setting for each integration to decide whether to load them or not.
#
# See:
#   https://devcenter.heroku.com/articles/rails-asset-pipeline
#

Rails.application.reloader.to_prepare do
  # only Heroku sets this
  if ENV['DATABASE_URL']
    # DB isn't ready yet
    if !(ActiveRecord::Base.connection rescue false)
      # Empty the list of integrations.
      Dradis::Plugins::class_variable_set('@@enabled_list', [])
    end
  end
end
