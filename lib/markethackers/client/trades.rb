module Markethackers
  module Client
    class Trades < Base
      URL = "/api/v1/trades.json"
      UPDATE_URL = "/api/v1/trades/%{trade_id}.json"

      def results
        resp = get(URL)
        resp.body
      end

      def processed(trade_id)
        resp = post(trade_url(trade_id), trade: {processed: true})
        resp.body["id"]
      end

      private
      
      def trade_url(trade_id)
        UPDATE_URL % {trade_id: trade_id}
      end
    end
  end
end
