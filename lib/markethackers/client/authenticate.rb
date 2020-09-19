require "markethackers/client/version"
require 'json'

module Markethackers
  module Client
    class Error < StandardError; end
    class Authenticate < Base
      URL = "/api/v1/auth.json"

      def login(email, password)
        resp = post(URL, email: email, password: password)

        body = resp&.body || {}
        body["token"]
      end
    end
  end
end
