require 'yaml'

module Markethackers
  class Setup
    include Markethackers::Settings
    extend Markethackers::Settings

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
                url: url,
                scripts: {
                  minute: ["./scripts/process_orders.rb"]
                }
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
      read_settings
      puts "loading environment #{Markethackers.environment}"
      puts
      puts "Usage: "
      puts
      puts "  mh register"
      puts "    Opens a browser window to register as a Market Hackers user."
      puts 
      puts "  mh setup"
      puts "    Interactively prompts you for your Market Hackers username/password, "
      puts "    your Interactive Brokers account id and port."
      puts "    Stores auth details in ~/.markethackers "
      puts
      puts "  mh generate <template_nam> \"<title of scan>\""
      puts "  mh generate breakout \"My First Scan\""
      puts "    Generates a basic scan on the Market Hackers website."
      puts "    Generates an accompanying local scan that allows for the"
      puts "    retrieval of those server scan side results. You can then"
      puts "    use those results to place local orders through your local"
      puts "    Interactive Brokers instance."
      puts
      puts " mh run every <interval> <path>"
      puts "   mh run every minute my_first_scan"
      puts "   mh run every hour my_first_scan"
      puts "    Adds a local scan script to be run locally"
      puts
      puts " mh run remove <match>"
      puts "   mh run remove my_first_scan"
      puts "    Removes all scan scripts for running that match."
      puts
      puts " mh run all"
      puts "    Runs all predefined scans at their specified intervals."
      puts "    Any trades placed via the Market Hackers chart view, will"
      puts "    be processed as well."
      puts "    Results printed to STDOUT."
      puts
      puts
      puts " You can have multiple environments."
      puts "    Default is production."
      puts
      puts " The :production section contains your live Market Hackers credentials."
      puts " By setting the MARKETHACKERS_ENV environment you can maintain"
      puts " multiple settings for Interactive Brokers in the event"
      puts " you want to try out your scans in paper trading mode."
      puts
      puts " e.g. export MARKETHACKERS_ENV=test"
      puts " e.g. export MARKETHACKERS_ENV=production"
      puts
      puts
      puts "Questions? Create an issue: https://github.com/aantix/markethackers-client/issues"
    end
  end
end