require 'openssl'
require 'base64'
require 'json'

class AesEncryptionService
  ALGORITHM = 'AES-256-CBC'

  def self.key
    Base64.decode64(Rails.application.credentials.dig(:aes, :key).to_s)
  end

  def self.iv
    Base64.decode64(Rails.application.credentials.dig(:aes, :iv).to_s)
  end

  def self.encrypt(data)
    return nil unless key.present? && iv.present?

    cipher = OpenSSL::Cipher.new(ALGORITHM)
    cipher.encrypt
    cipher.key = key
    cipher.iv = iv

    encrypted = cipher.update(data.to_json) + cipher.final
    Base64.strict_encode64(encrypted)
  rescue StandardError => e
    Rails.logger.error("Encryption error: #{e.message}")
    nil
  end

  def self.decrypt(encrypted_data)
    return nil unless key.present? && iv.present?

    decipher = OpenSSL::Cipher.new(ALGORITHM)
    decipher.decrypt
    decipher.key = key
    decipher.iv = iv

    decoded = Base64.decode64(encrypted_data)
    decrypted = decipher.update(decoded) + decipher.final
    JSON.parse(decrypted)
  rescue StandardError => e
    Rails.logger.error("Decryption error: #{e.message}")
    nil
  end
end
