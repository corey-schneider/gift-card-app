require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module GiftCardApp
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.1

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # Configure ActiveRecord encryption keys (AES-256-GCM) with ENV or credentials fallback
    config.active_record.encryption.primary_key = ENV["ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY"] || Rails.application.credentials.dig(:active_record_encryption, :primary_key) || "Q0RrHqeBK9RXZPaKaK9L0V2IMsiOFRoC"
    config.active_record.encryption.deterministic_key = ENV["ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY"] || Rails.application.credentials.dig(:active_record_encryption, :deterministic_key) || "DatVrFYtum69FsP0CavUWnKy9d7m5aZ7"
    config.active_record.encryption.key_derivation_salt = ENV["ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT"] || Rails.application.credentials.dig(:active_record_encryption, :key_derivation_salt) || "inSvIKeBLs316WUOnfecY7m4phzGab7N"
  end
end
