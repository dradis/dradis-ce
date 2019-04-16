# Resque::Plugins::Status::Hash.expire_in = (24 * 60 * 60) # 24hrs in seconds
#
# logfile = File.open(File.join(Rails.root, 'log', 'resque.log'), 'a')
# logfile.sync = true
# Resque.logger = Logger.new(logfile)
# Resque.logger.level = Logger::INFO
# Resque.logger.info "Resque Logger Initialized"
# # Resque::Server.use(Rack::Auth::Basic) do |user, password|
# #   user == 'admin' && password == 'dradispro'
# # end
