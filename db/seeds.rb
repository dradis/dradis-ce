
if Rails.env.sandbox?

  # Shared password
  setting = ::Configuration.find_by_name('admin:password')
  setting.value = ::BCrypt::Password.create('dradis')
  setting.save

  # Share Analytics
  setting = ::Configuration.new(name: 'admin:usage_sharing')
  setting.value = 1
  setting.save

  # Load Kit
  # Before we import the Kit we need at least 1 user
  User.create!(email: 'adama@dradis.com')

  kit_folder = Rails.root.join('lib', 'tasks', 'templates', 'welcome').to_s
  logger = Log.new.info('Loading Welcome kit...')
  kit_folder
  KitImportJob.perform_later(kit_folder, logger: logger)
else
  # Create a few default tags.
  Tag::DEFAULT_TAGS.each do |name|
    Tag.create!(name: name)
  end
end
