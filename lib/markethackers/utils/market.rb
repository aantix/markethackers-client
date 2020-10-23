module Markethackers
  module Utils
    class Market
      ZONE  = Time.find_zone("Eastern Time (US & Canada)")

      OPEN  = ZONE.parse("9:30am")
      CLOSE = ZONE.parse("4:00pm")

      def self.open?
        now = ZONE.now

        now >= OPEN && now <= CLOSE
      end

      def self.closed?
        !open?
      end
    end
  end
end

