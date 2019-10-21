config = YAML.load_file(Rails.root.join('config/smtp.yml'))[Rails.env]

ActionMailer::Base.smtp_settings = config['smtp_settings']
ActionMailer::Base.default_url_options = config['default_url_options']
ActionMailer::Base.default_url_options[:script_name] = '' if Rails.env.production?
