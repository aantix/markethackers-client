module Markethackers
  module Brokers
    module InteractiveBrokers
      class Client
        attr_accessor :ib, :account_id, :futures, :account_value

        def initialize(account_id:, port: 7497)
          @account_id    = account_id
          @account_value = nil

          @ib = IB::Connection.new( port: port ) do | gw |
            # gw.subscribe(:AccountValue) { |msg| @account_value = msg.inspect }
            # gw.subscribe(:OpenOrder) { |msg| puts "Placed: #{msg.order}" }
            # gw.subscribe(:ExecutionData) { |msg| puts "Filled: #{msg.execution}" }
            # gw.subscribe(:Alert, :OpenOrder, :OrderStatus) { |msg| puts msg.to_human }
            # gw.subscribe(:Alert, :PositionData){ |msg| puts msg.to_human }
            gw.subscribe(:AccountSummary){ |msg| @account_value = msg.account_value }
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
                                              entry_price:, num_shares:,
                                              volume_level:, trailing_percent:)
          ib.send_message :RequestAccountData, account_code: account_id
          ib.wait_for :AccountDownloadEnd

          # contract = IB::Stock.new symbol: stock
          symbol    = IB::Symbols::Stocks[stock.to_sym]

          buy_order = Limit.order price: entry_price, size: num_shares, action: :buy,
                                  account_code: account_id, tif: :good_till_cancelled,
                                  conditions: [ IB::VolumeCondition.fabricate( ">=" , volume_level),
                                                IB::TimeCondition.fabricate( "<=" , Date.today + 6 ) ]
          
          ib.wait_for :NextValidId


          stop_order = IB::TrailingStop.order action: :sell,
                                              tif: :good_till_cancelled,
                                              size: num_shares,
                                              trailing_percent: trailing_percent,
                                              parent_id: limit_order.local_id,
                                              account: account_id

          ib.place_order buy_order, symbol
          stop_order.parent_id = buy_order.local_id
          ib.place_order stop_order, symbol

          ib.send_message :RequestAllOpenOrders
        end
      end
    end
  end
end
