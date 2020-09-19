module Markethackers
  module Utils
    class Market
      ZONE  = Time.find_zone("Eastern Time (US & Canada)")

      OPEN  = Time.ZONE.parse("9:30am")
      CLOSE = Time.ZONE.parse("4:00pm")
    end
  end
end

