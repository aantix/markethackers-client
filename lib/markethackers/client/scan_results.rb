module Markethackers
  module Client
    class ScanResults < Base
      URL = "/api/v1/scan_results/%{scan_result_id}.json"
      STATUS_URL = "/api/v1/scan_results/%{scan_result_id}/status.json"

      attr_accessor :scan_result_id

      def initialize(scan_result_id)
        @scan_result_id = scan_result_id
      end

      def completed?
        resp = get(status_url)

        resp.body["completed_at"].present?
      end

      def wait_until_completed
        while in_progress?
          sleep 1
        end
      end

      def in_progress?
        !completed?
      end

      def results
        resp = get(scan_url)

        resp.body["candidates"]
      end

      private

      def scan_url
        URL % {scan_result_id: scan_result_id}
      end

      def status_url
        STATUS_URL % {scan_result_id: scan_result_id}
      end
    end
  end
end
