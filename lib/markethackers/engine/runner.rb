require 'active_support/core_ext/date_time'

module Markethackers
  module Engine
    class Runner
      include Settings

      attr_reader :last_ran
      attr_reader :running
      attr_reader :ractors

      def initialize
        @last_ran = {}
        @running  = {}

        read_settings
      end
      
      def all
        while true do
          @ractors  = []

          scripts.each do |interval, script|
            next if too_soon?(interval, script)
            next if running?(script)

            ractors << Ractor.new do
              start_script(script)

              puts "Running #{script} (#{DateTime.now})"
              load script

              end_script(script)
            end
          end

          sleep 1
        end
      end

      private

      def start_script(script)
        last_ran[script] = DateTime.now
        running[script]  = true
      end

      def end_script(script)
        running[script] = false
      end

      def too_soon?(interval, script)
        !!last_ran[script].try!(:before, 1.send(interval).ago)
      end

      def running?(script)
        running[script] == true
      end
    end
  end
end
