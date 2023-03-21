# This is a temporary wrapper to provide ActiveRecord Encryption from Rails 7.
# After we bump to Rails 7 we can delete this file and replace all affected
# columns with calls to .encrypt
#
# We'll also have to replace calls to #set_<column> and #get_<column> with
# regular setters and getters, as ActiveRecord Encryption handles them
# transparently.
#
# See:
#   https://guides.rubyonrails.org/active_record_encryption.html
#   https://github.com/rails/rails/blob/7-0-stable/activerecord/lib/active_record/encryption/
#
#   ActiveRecord::Encryption::Cipher::Aes256Gcm
#   ActiveRecord::Encryption::KeyGenerator
#   ActiveRecord::Encryption::MessageSerializer

module EncryptedColumn
  extend ActiveSupport::Concern

  class_methods do
    def encrypted_column(name)
      serialize name, JSON

      define_method "get_#{name}".to_sym do
        value = send(name)
        decrypt(value.with_indifferent_access) unless value.nil?
      end

      define_method "set_#{name}".to_sym do |value|
        send("#{name}=", encrypt(value))
      end
    end
  end

  private
  CIPHER_TYPE = 'aes-256-gcm'.freeze

  def encrypt(clear_text)
    validate_keys!

    cipher = OpenSSL::Cipher.new(CIPHER_TYPE)
    cipher.encrypt
    cipher.key = key
    iv = cipher.random_iv
    cipher.iv = iv

    encrypted_data = clear_text.empty? ? clear_text.dup : cipher.update(clear_text)
    encrypted_data << cipher.final

    {
      p: ::Base64::strict_encode64(encrypted_data),
      h: {
        iv: ::Base64::strict_encode64(iv),
        at: ::Base64::strict_encode64(cipher.auth_tag)
      }
    }
  end

  def decrypt(encrypted_message)
    validate_keys!

    encrypted_data = ::Base64.strict_decode64(encrypted_message[:p])
    iv = ::Base64.strict_decode64(encrypted_message[:h][:iv])
    auth_tag = ::Base64.strict_decode64(encrypted_message[:h][:at])

    # Currently the OpenSSL bindings do not raise an error if auth_tag is
    # truncated, which would allow an attacker to easily forge it. See
    # https://github.com/ruby/openssl/issues/63
    raise Exception, 'Encrypted content integrity' if auth_tag.nil? || auth_tag.bytes.length != 16

    cipher = OpenSSL::Cipher.new(CIPHER_TYPE)
    cipher.decrypt
    cipher.key = key
    cipher.iv = iv

    cipher.auth_tag = auth_tag
    cipher.auth_data = ''

    decrypted_data = encrypted_data.empty? ? encrypted_data : cipher.update(encrypted_data)
    decrypted_data << cipher.final

    decrypted_data
  rescue OpenSSL::Cipher::CipherError, TypeError, ArgumentError
    raise Errors, 'Decryption'
  end

  def key
    @key ||= ActiveSupport::KeyGenerator
      .new(Rails.application.credentials.dig(:active_record_encryption, :primary_key))
      .generate_key(Rails.application.credentials.dig(:active_record_encryption, :key_derivation_salt), OpenSSL::Cipher.new(CIPHER_TYPE).key_len)
  end

  def validate_keys!
    raise Errors::Configuration, ':deterministic_key is missing' unless Rails.application.credentials.dig(:active_record_encryption, :deterministic_key).present?
    raise Errors::Configuration, ':key_derivation_salt is missing' unless Rails.application.credentials.dig(:active_record_encryption, :key_derivation_salt).present?
    raise Errors::Configuration, ':primary_key is missing' unless Rails.application.credentials.dig(:active_record_encryption, :primary_key).present?
  end
end
