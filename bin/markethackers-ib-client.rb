#!/usr/bin/env bash

require 'drb'
require 'ib_ruby_proxy'
require 'byebug'

client = IbRubyProxy::Client::Client.from_drb

class CallbacksObserver < IbRubyProxy::Client::IbCallbacksObserver
  def account_summary(*args)
    _request_id, _account_id, request_type, cash_value, currency = args
    puts "#{request_type}: #{cash_value} #{currency}"
  end

  def account_summary_end(*args)
    request_id = args
  end

  def connection_closed(*args)
    puts "Connection closed to ibproxy"
    puts args
  end
end

puts "Starting ibproxy - looking for TraderWorkstation"

client.add_ib_callbacks_observer CallbacksObserver.new

# client.req_account_summary(1, "All", "$LEDGER")
client.req_account_summary(1, "All", "TotalCashValue")

begin
  while true
    sleep 1
  end
rescue SystemExit, Interrupt
end
