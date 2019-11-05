# Defaults
ActionMailer::Base.default_url_options[:host] = 'dradis-framework.dev'
ActionMailer::Base.default_url_options[:script_name] = '' if Rails.env.production?

config_path = Rails.root.join('config/smtp.yml')

if File.exist?(config_path)
  config = YAML.load_file(config_path)[Rails.env]

  ActionMailer::Base.smtp_settings = config['smtp_settings'].symbolize_keys
  ActionMailer::Base.default_url_options = config['default_url_options'].symbolize_keys
end
