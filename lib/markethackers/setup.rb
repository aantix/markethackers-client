require 'yaml'

module Markethackers
  class Setup
    include Markethackers::Settings
    
    attr_accessor :client

    def initialize
      @client = Markethackers::Client::Authenticate.new
    end

    def start
      email      = prompt("Enter Market Hackers account email:")
      password   = prompt("Enter Market Hackers account password:")
      account_id = prompt("Enter Interactive Brokers account id:")
      port       = prompt("Enter Interactive Brokers TWS port:").to_i

      # email      = "jim.jones1@gmail.com"
      # password   = "testme10"
      # account_id = "XXXYYY"
      # port       = 4002

      save(email, password, account_id, port)

      puts "Authentication successful."
      puts "Settings saved to #{SETTINGS_FILE}"
    rescue StandardError => e
      puts "Problem authenticating: #{e.message}"
    end

    def prompt(label)
      puts label
      value = STDIN.gets.chomp
      puts

      value
    end

    def token(email, password)
      client.login(email, password)
    end

    def save(email, password, account_id, port)
      properties = {settings:
                      { auth_token: token(email, password),
                        ib_account_id: account_id,
                        ib_port: port }}

        write_settings(properties)
    rescue Errno::ENOENT
      return nil
    end

    def self.instructions
      puts "Here are the common steps:"
      puts
      puts "1) run: mh setup"
      puts "2) run: mh generate \"My First Scan\""
      puts "3) Modify your daily scan at https://www.markethackers.com/scans"
      puts "4) Edit my_first_scan.erb to load your candidates into Interactive Brokers"
      puts "5) run: mh run my_first_scan.rb"
      puts
      puts "Issues and pull requests welcomed at:"
      puts "  https://github.com/aantix/markethackers-client"
      puts
      puts "- Jim Jones jim@markethackers.com"
    end
  end
end