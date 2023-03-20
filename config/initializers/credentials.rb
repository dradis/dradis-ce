# 1. Purge old secret_token file
secret_token_path = Rails.root.join('config', 'shared', 'secret_token')
if secret_token_path.exist?
  secret_token_path.unlink
end


# 2. Create an internal encrypted credentials file if none exists
config_path = Rails.root.join('config', 'shared', 'credentials.yml.enc')
key_path = config_path.dirname.join('master.key')

if !config_path.exist? | config_path.zero?
  warn "The file #{config_path} does not exists or is empty."
  warn "Generating a new file and writing to #{config_path}; this will invalidate the previous Rails sessions."

  # For good measure
  FileUtils.mkdir_p(config_path.dirname)

  require 'securerandom'
  contents = {
    active_record_encryption: {
      primary_key: SecureRandom.alphanumeric(32),
      deterministic_key: SecureRandom.alphanumeric(32),
      key_derivation_salt: SecureRandom.alphanumeric(32)
    },
    secret_key_base: SecureRandom.hex(64)
  }.to_yaml

  key = ActiveSupport::EncryptedConfiguration.generate_key
  key_path.binwrite(key)
  key_path.chmod 0600

  enc_conf = ActiveSupport::EncryptedConfiguration.new(config_path: config_path, key_path: key_path, env_key: 'RAILS_MASTER_KEY', raise_if_missing_key: true)
  enc_conf.write(contents)
end

# 2. Load the custom internal credentials file.
#
# From ./bin/rails credentials:help
#
# In addition to that, the default credentials lookup paths can be overridden through
# `config.credentials.content_path` and `config.credentials.key_path`.
#   encrypted_settings.yml.enc
Rails.application.config.credentials.content_path = config_path
Rails.application.config.credentials.key_path = key_path
