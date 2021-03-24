
client = Markethackers::Client::Trades.new
broker = Markethackers::Brokers::InteractiveBrokers::Client.new

client.trades.each do |trade|
  symbol                    = trade["stock"]["symbol"]
  stop_loss_percentage      = trade["stop_loss_percentage"].to_f
  profit_protect_percentage = trade["profit_protect_percentage"].to_f
  shares                    = trade["shares"].to_i
  entry_price               = trade["entry_price"].to_f

  puts "Processing : #{symbol}"
  
  broker.buy(stock: symbol,
             num_shares: shares,
             entry_price: entry_price,
             trailing_percent: stop_loss_percentage,
             profit_percent: profit_protect_percentage)
end