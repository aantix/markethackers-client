module Markethackers
  module Engine
    class Runnner
      include Settings

      attr_accessor :remote_scan, :local_scan, :script
      attr_accessor :before_callback, :after_callback, :received_callback

      def initialize(remote_scan, local_scan)
        @remote_scan = remote_scan
        raise ArgumentError.new("Must provide the name of the remote scan.\n" \
                                "Go to https://www.markethackers.com/scans") if remote_scan.nil?

        @local_scan  = local_scan
        raise ArgumentError.new("Must provide the the path to the scan.") if local_scan.nil?

        @script      = File.read(local_scan)
      end

      def uri
        "ws://localhost:3000/cable/"
      end

      def before
        @before_callback = proc do
          yield self
        end
      end

      def after
        @after_callback = proc do
          yield self
        end
      end

      def receive(message)
        @received_callback = proc do
          yield message
        end
      end

      def scan
        self.scan_callback = proc do
          yield
        end
      end

      def broker
        @broker||=Markethackers::Brokers::InteractiveBrokers::Client.new(account_id: ib_account_id,
                                                                         port: ib_port)
      end

      def run
        load_script_with_callbacks

        scan_result_id =
            Markethackers::Client::Scan.new(remote_scan).run

        EventMachine.run do
          client = ActionCableClient.new(uri, {channel: "ScanResultChannel",
                                               scan_result_id: scan_result_id})

          client.connected { puts 'Connected.' }

          start

          client.received do | message |
            puts "Received #{message.inspect}"

            case message['status']
              when 'result'
                result(message)
              when 'complete'
                complete
            end
          end
        end
      end

      private

      def start
        before_callback&.call
      end

      def complete
        after_callback&.call
        EventMachine::stop_event_loop
      end

      def result(message)
        received_callback&.call(message['json'])
      end

      def load_script_with_callbacks
        eval(script)
      end
    end
  end
end
