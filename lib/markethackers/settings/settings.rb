module Markethackers
  module Settings
    extend ActiveSupport::Concern

    included do |base|
      attr_accessor :settings
    end

    SETTINGS_FILE          = "#{Dir.home}/.markethackers"
    PRODUCTION_URL         = "https://www.markethackers.com"
    PRODUCTION_ENVIRONMENT = "production"

    def url
      settings[:url]
    end

    def ib_account_id
      settings[:ib_account_id]
    end

    def ib_port
      settings[:ib_port]
    end

    def auth_token
      settings[:auth_token]
    end

    def auth_token?
      auth_token.present?
    end

    def ib_port?
      port.present?
    end

    def ib_account_id?
      ib_account_id.present?
    end

    def production?
      Markethackers.environment == PRODUCTION_ENVIRONMENT.parameterize(separator: '_').to_sym
    end

    def write_settings(new_settings)
      File.write(SETTINGS_FILE, new_settings.to_yaml)
    end

    def read_settings
      @settings = complete_settings.dig(Markethackers.environment, :settings)
    rescue StandardError => e
      puts e.full_message
      puts e.backtrace.join("\n")
      return {}
    end

    def complete_settings
      YAML.load(File.read(Markethackers::Client::Base::SETTINGS_FILE)) rescue {}
    end
  end
end