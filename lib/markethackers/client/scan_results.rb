module Markethackers
  module Client
    class ScanResults < Base
      URL = "/api/v1/scan_results/%{scan_id}.json"

      attr_accessor :scan_id

      def initialize(scan_id)
        @scan_id = scan_id
      end

      def results
        url  = URL % {scan_id: scan_id}
        resp = get(url)

        resp.body["results"]
      end
    end
  end
end
