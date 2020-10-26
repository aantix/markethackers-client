require 'yaml'

module Markethackers
  class Setup
    include Markethackers::Settings
    
    attr_accessor :client

    def initialize
      read_settings
    end
    
    def client
      @client = Markethackers::Client::Authenticate.new
    end
    
    def start
      # email      = prompt("Enter Market Hackers account email:")
      # password   = prompt("Enter Market Hackers account password:")
      # account_id = prompt("Enter Interactive Brokers account id:")
      # port       = prompt("Enter Interactive Brokers TWS port:").to_i

      url = if production? && ENV['MARKETHACKERS_LOCAL_TEST'].nil?
              PRODUCTION_URL
            else
              prompt("Enter URL for #{Markethackers.environment} API calls [#{PRODUCTION_URL}]:") || PRODUCTION_URL
            end

      email      = "jim.jones1@gmail.com"
      password   = "testme10"
      account_id = "XXXYYY"
      port       = 4002

      save(email, password, account_id, port, url)

      puts "Authentication successful."
      puts "Settings saved to #{SETTINGS_FILE}"
    rescue StandardError => e
      puts "Problem authenticating: #{e.message}"
    end

    def prompt(label)
      puts label
      value = STDIN.gets.chomp
      puts

      return nil if value == ''
      value
    end

    def token(email, password)
      client.login(email, password)
    end

    def save(email, password, account_id, port, url)
      props = { auth_token: '',
                    ib_account_id: account_id,
                    ib_port: port,
                    url: url
                  }

      props = {Markethackers.environment => {
          settings: props
      }}

      write_settings(complete_settings.merge(props))

      props[Markethackers.environment][:settings][:auth_token] = token(email, password)

      write_settings(complete_settings.merge(props))

      read_settings
    rescue Errno::ENOENT
      return nil
    end

    def self.instructions
      puts "Here are the common steps:"
      puts
      puts "1) run: mh setup"
      puts "2) run: mh generate breakout \"My First Scan\""
      puts "3) Modify your daily scan at https://www.markethackers.com/scans"
      puts "4) Edit my_first_scan.erb to load your candidates into Interactive Brokers"
      puts "5) run: mh run my_first_scan.rb"
      puts
      puts
      puts "You can have multiple environments. The :production section contains your live Market Hackers credentials."
      puts " By setting the MARKETHACKERS_ENV envrionment you can maintain multiple settings for IB in case"
      puts " you want to try out your scans in paper trading mode."
      puts
      puts
      puts "Questions? Create an issue: https://github.com/aantix/markethackers-client/issues"
    end
  end
end