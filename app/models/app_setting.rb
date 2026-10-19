class AppSetting < ApplicationRecord
  has_secure_password :passcode, validations: false

  def self.current
    first_or_create!
  end

  def self.passcode_set?
    ENV["APP_UNLOCK_PIN"].present? || current.passcode_digest.present?
  end

  def self.authenticate(pin)
    return false if pin.blank?

    if ENV["APP_UNLOCK_PIN"].present?
      return true if ENV["APP_UNLOCK_PIN"].to_s.strip == pin.to_s.strip
    end

    setting = current
    if setting.passcode_digest.present?
      !!setting.authenticate_passcode(pin.to_s.strip)
    else
      false
    end
  end

  def self.set_passcode(pin)
    return false if pin.blank?

    current.update(passcode: pin.to_s.strip)
  end
end
