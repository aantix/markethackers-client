# Grab the scan results from your Market Hacker scan and
#  load the positions into Interactive Brokers.

client  = Markethackers::Client::ScanResults.new(3)
broker  = Markethackers::Brokers::InteractiveBrokers::Client.new("DU2533870", 4002)

broker.clear_pending_buy_orders

client.results.each do |result|
  symbol                = result[:symbol]
  entry_price           = result[:price] * 1.10
  shares                = 100
  volume_entry_level    = result[:volume_30_sma] * 1.5
  trailing_stop_percent = 0.07

  broker.buy_stock_with_trailing_stop_loss(stock: symbol,
                                    entry_price: entry_price,
                                    num_shares: shares,
                                    volume_level: volume_entry_level,
                                    trailing_percent: trailing_stop_percent)
end