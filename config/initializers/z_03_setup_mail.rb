# Soon to be deprecated smtp.yml-based SMTP config for VM deployments.
# Remove this file when VM deployment support is dropped.
#
# This initializer is only used if
# - SMTP_ADDRESS is not set
# - config/smtp.yml exists
return if ENV['SMTP_ADDRESS'].present?

config_path = Rails.root.join('config/smtp.yml')
return unless config_path.exist?

config = YAML.load_file(config_path, aliases: true)[Rails.env.to_s]
return unless config

ActionMailer::Base.default_options = config['default_options'].symbolize_keys
ActionMailer::Base.default_url_options = config['default_url_options'].symbolize_keys
ActionMailer::Base.deliver_later_queue_name = :dradis_mailers
ActionMailer::Base.smtp_settings = config['smtp_settings'].symbolize_keys

ActionMailer::Base.asset_host = config['default_url_options']['host'] if Rails.env.production?
