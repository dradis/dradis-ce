
if Rails.env.sandbox?

  # Shared password
  ::Configuration.create!(name: 'admin:password', value: ::BCrypt::Password.create('dradis'))

  # Share Analytics
  ::Configuration.create!(name: 'admin:usage_sharing', value: 1)

  # Load Kit
  # Before we import the Kit we need at least 1 user
  User.create!(email: 'adama@dradis.com')

  kit_folder = Rails.root.join('lib', 'tasks', 'templates', 'welcome').to_s
  logger = Log.new.info('Loading Welcome kit...')
  kit_folder
  KitImportJob.perform_now(kit_folder, logger: logger)
else
  # Create a few default tags.
  Tag::DEFAULT_TAGS.each do |name|
    Tag.create!(name: name)
  end
end
