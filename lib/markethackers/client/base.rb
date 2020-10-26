require 'faraday'
require 'faraday_middleware'

module Markethackers
  module Client
    class Error < StandardError; end
    class Base
      include Markethackers::Settings

      def initialize
        read_settings
      end

      def connection
        @connection||=Faraday.new(url) do |c|
          c.use FaradayMiddleware::ParseJson,       content_type: 'application/json'
          c.use Faraday::Response::Logger,          Logger.new('logs/faraday.log')
          c.use FaradayMiddleware::FollowRedirects, limit: 3
          c.use Faraday::Response::RaiseError       # raise exceptions on 40x, 50x responses
          c.adapter Faraday::Adapter::NetHttp

          if auth_token?
            c.authorization :Bearer, auth_token
          end
        end
      end

      def get(url, params = {})
        connection.get(url, params, headers)
      end

      def post(url, params = {})
        connection.post(url, params.to_json, headers)
      end

      protected

      def headers
        {'Accept'       => 'application/json',
         'Content-Type' => "application/json"}
      end
    end
  end
end
