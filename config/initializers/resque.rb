logfile = File.open(File.join(Rails.root, 'log', 'resque.log'), 'a')
logfile.sync = true
Resque.logger = Logger.new(logfile)
Resque.logger.level = Logger::INFO
Resque.logger.info 'Resque Logger Initialized'
Resque.redis = ENV['REDIS_URL'] || 'localhost:6379'