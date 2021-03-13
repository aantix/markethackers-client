require 'active_support/time'

module Markethackers
  module Brokers
    module InteractiveBrokers
      class Client
        include Markethackers::Settings

        attr_accessor :ib, :account_id, :port, :futures, :account_value

        def initialize
          read_settings
          
          @account_id    = ib_account_id
          @port          = ib_port
          @account_value = nil

          @ib = IB::Connection.new(port: port ) do | gw |
            gw.subscribe(:AccountValue) { |msg| @account_value = msg.account_value }
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

        # https://github.com/ib-ruby/ib-ruby/blob/master/example/account_summary
        def account_balance
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

        def buy_stock_with_trailing_stop_loss(stock:,
                                              entry_price:,
                                              num_shares:,
                                              stop_price:,
                                              trailing_percent:)
          ib.send_message :RequestAccountData, account_code: account_id
          ib.wait_for :AccountDownloadEnd

          symbol    = IB::Stock.new symbol: stock
          buy_order = IB::Order.new  limit_price: entry_price,
                                     order_type: 'LMT',
                                     total_quantity: num_shares,
                                     action: :buy
          ib.place_order buy_order, symbol


          sell_order_profit = IB::Order.new  limit_price: stop_price,
                                     order_type: 'STP LMT',
                                     total_quantity: num_shares,
                                     action: :sell,
                                     parent_id: buy_order.local_id
          ib.place_order sell_order_profit, symbol

          # https://github.com/ib-ruby/ib-api/blob/31884e8065aeb085ba63eb1550e845f4e5f4070e/lib/models/ib/order.rb#L21
          # Protect the loss
          sell_order_loss = IB::Order.new  trailing_percent: trailing_percent,
                                             order_type: 'TRAIL',
                                             total_quantity: num_shares,
                                             action: :sell,
                                             parent_id: buy_order.local_id
          ib.place_order sell_order_loss, symbol

          # stop_order = IB::TrailingStop.order action: :sell,
          #                                     tif: :good_till_cancelled,
          #                                     size: num_shares,
          #                                     trailing_percent: trailing_percent,
          #                                     parent_id: buy_order.local_id,
          #                                     trail_stop_price: buy_order.price,
          #                                     account: account_id
          #
          # puts "7777"
          # ib.place_order stop_order, symbol
          # puts "88888"
          # ib.wait_for :NextValidId
          # puts "9999"
          # ib.wait_for :ContractDataEnd, 10 #sec
          # puts "101010101010"

          # ib.send_message :RequestAllOpenOrders
        end
      end
    end
  end
end
