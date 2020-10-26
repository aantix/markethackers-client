require 'ib-ruby'
require "markethackers/settings/settings"
require "markethackers/generate/scans"
require "markethackers/setup"
require "markethackers/client/base"
require "markethackers/client/authenticate"
require "markethackers/client/scan"
require "markethackers/client/scan_results"
require "markethackers/client/version"
require "markethackers/brokers/interactive_brokers/client"


module Markethackers
  mattr_accessor :environment
  
  @@environment = (ENV['MARKETHACKERS_ENV'] || Markethackers::Settings::PRODUCTION_ENVIRONMENT).parameterize(separator: '_').to_sym
end