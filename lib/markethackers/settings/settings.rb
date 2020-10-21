module Markethackers
  module Settings
    SETTINGS_FILE = "#{Dir.home}/.markethackers"

    def url
      @url||=if ENV['MARKETHACKERS_LOCAL'].present?
               "http://localhost:5000/"
             else
               "https://www.markethackers.com/"
             end
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

    def write_settings(new_settings)
      File.write(SETTINGS_FILE, new_settings.to_yaml)
      settings
    end

    def settings
      @settings||=YAML.load(File.read(Markethackers::Client::Base::SETTINGS_FILE))[:settings]
    rescue StandardError
      return {}
    end
  end
end