# 1. Purge old secret_token file
secret_token_path = Rails.root.join('config', 'shared', 'secret_token')
if secret_token_path.exist?
  secret_token_path.unlink
end

# 2. Create an internal encrypted credentials file if none exists
content_path = Rails.application.config.credentials.content_path
key_path = Rails.application.config.credentials.key_path

if !content_path.exist? | content_path.zero?
  warn "The file #{content_path} does not exists or is empty."
  warn "Generating a new file and writing to #{content_path}; this will invalidate the previous Rails sessions."

  # For good measure
  FileUtils.mkdir_p(content_path.dirname)

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

  enc_conf = ActiveSupport::EncryptedConfiguration.new(config_path: content_path, key_path: key_path, env_key: 'RAILS_MASTER_KEY', raise_if_missing_key: true)
  enc_conf.write(contents)

  # We need to manually set Rails.application.credentials here
  # so that the credentials are accessible immediately after being created.
  # Since this file is run after railties sets Rails.application.credentials,
  # Without this line, credentials are nil until a reboot
  Rails.application.credentials = enc_conf
end
