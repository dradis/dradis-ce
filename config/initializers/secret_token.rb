# Be sure to restart your server when you modify this file.

# Your secret key is used for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!

# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
# You can use `rake secret` to generate a secure secret key.

# Snippet taken from:
#   http://daniel.fone.net.nz/blog/2013/05/20/a-better-way-to-manage-the-rails-secret-token/#comment-902714581
secret_token_path = Rails.root.join('config', 'shared')
secret_token_file = secret_token_path.join('secret_token')
secret_token = (secret_token_file.exist? and secret_token_file.read.chomp) || (
  warn "The file #{secret_token_path} does not exists or is empty."
  warn "Generating a new secret token and writing to #{secret_token_path}; this will invalidate the previous Rails sessions."

  # For good measure
  FileUtils.mkdir_p(secret_token_path)

  require 'securerandom'
  SecureRandom.hex(64).tap do |token|
    secret_token_file.open('w') { |io| io.write token }
  end
)

# Make sure your secret_key_base is kept private
# if you're sharing your code publicly.
Dradis::Application.secrets.secret_key_base = secret_token
