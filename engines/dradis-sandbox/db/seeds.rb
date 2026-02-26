# The main purpose of this file is to bypass the instance Setup wizard.

if defined?(Dradis::Pro)
else
  # Shared password
  ::Configuration.create!(name: 'admin:password', value: ::BCrypt::Password.create('dradis'))

  # Before we import the Kit we need at least 1 user
  User.create!(email: 'adama@dradis.com')
end

# Share Analytics
::Configuration.create!(name: 'admin:usage_sharing', value: 1)

# Load Kit
kit_folder = Rails.root.join('lib', 'tasks', 'templates', 'welcome').to_s
logger = Log.new.info('Loading Welcome kit...')
KitImportJob.perform_now(kit_folder, logger: logger)
