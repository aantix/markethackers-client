require 'active_support/time'

module Markethackers
  module Brokers
    module InteractiveBrokers
      class Client
        include Markethackers::Settings

        attr_accessor :ib, :account_id, :port, :futures, :total_cash

        # https://interactivebrokers.github.io/tws-api/classIBApi_1_1EClient.html#a3e0d55d36cd416639b97ee6e47a86fe9
        def initialize
          read_settings
          
          @account_id    = ib_account_id
          @port          = ib_port
          @account_value = nil

          @ib = IB::Connection.new(port: port ) do | gw |
            gw.subscribe(:OrderStatus) { |msg| puts "Order status: #{msg.to_human}" }
            gw.subscribe(:OpenOrderEnd) { |msg| puts "Placed: #{msg.to_human}" }
            gw.subscribe(:ExecutionData) { |msg| puts "Filled: #{msg.to_human}" }
            gw.subscribe(:Alert, :OpenOrder, :OrderStatus, :ManagedAccounts) { |msg| puts msg.to_human }
            gw.subscribe(:AccountSummary){ |msg| @account_value = msg.account_value }

            gw.subscribe(:ContractData ) do |msg|
              puts msg.contract.to_human + "\n"
            end
          end
        end

        def account_summary
          req_id = ib.send_message :RequestAccountSummary,
                                   tags: "TotalCashValue",
                                   account_code: account_id

          ib.wait_for :AccountSummaryEnd!
          ib.send_message :CancelAccountSummary, id: req_id

          @account_value.value.to_f
        end

        # https://github.com/ib-ruby/ib-ruby/blob/master/example/account_summary
        def account_balance
          req_id = ib.send_message :RequestAccountSummary,
                                   tags: "TotalCashValue",
                                   account_code: account_id

          ib.wait_for :AccountSummaryEnd!
          ib.send_message :CancelAccountSummary, id: req_id
          
          @account_value.value.to_f
        end

        def account_value
          req_id = ib.send_message :RequestAccountSummary,
                                   tags: "TotalCashValue",
                                   account_code: account_id

          ib.wait_for :AccountSummaryEnd!
          ib.send_message :CancelAccountSummary, id: req_id

          @account_value.value.to_f
        end

        def current_positions
          ib.send_message :RequestPositions
        end

        def entry_orders
        end

        def exit_orders
        end

        def clear_pending_buy_orders
        end

        def buy(stock:,
                num_shares:,
                entry_price:,
                trailing_percent:,
                profit_percent:)

          # https://github.com/ib-ruby/ib-extensions/blob/master/examples/place_bracket_order
          ib.send_message :RequestAccountData, account_code: account_id
          ib.wait_for :AccountDownloadEnd

          symbol = IB::Stock.new symbol: stock
          
          buy_order = IB::Limit.order :total_quantity => num_shares,
                                      :price => entry_price,
                                      :action => :buy,
                                      :algo_strategy => '',
                                      :transmit => false,
                                      account: account_id
          ib.wait_for :NextValidId

          stop_order = IB::TrailingStop.order :total_quantity => num_shares,
                                              :trailing_percent => trailing_percent,
                                              :trail_stop_price => entry_price,
                                              :action => :sell,
                                              :parent_id => buy_order.local_id,
                                              account: account_id

          profit_target = profit_target(entry_price, profit_percent)

          profit_order = IB::Limit.order  :total_quantity => num_shares,
                                          :price => profit_target,
                                          :action => :sell,
                                          :parent_id => buy_order.local_id,
                                          account: account_id

          ib.place_order buy_order, symbol

          stop_order.parent_id   = buy_order.local_id
          profit_order.parent_id = buy_order.local_id
          
          ib.place_order stop_order, symbol
          ib.place_order profit_order, symbol

          ib.send_message :RequestAllOpenOrders
        end

        private

        def profit_target(entry_price, profit_percent)
          target = entry_price * (1 + (profit_percent / 100))
          (target * 20).round / 20.0
        end
      end
    end
  end
end
