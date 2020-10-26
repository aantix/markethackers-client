# Markethackers.com Scan and Trade Client for InteractiveBrokers 

Use this client to connect to Market Hackers, run your scan, retrieve your candidates,
and place your limit orders with Interactive Brokers

The scans are run on the Market Hackers servers.  

This client runs locally on your laptop along with IB's Trader Workstation.

Market Hackers never interacts with your brokerage account.

## Installation

Be sure to have Ruby installed on your system.

For Macs, run :

`brew install ruby`

then

`gem install markethackers-client`

## Setup

From the command-line, setup the Market Hackers client with `mh setup`.

This will prompt you for your Market Hacker email/password for login,
your Interactive Brokers account ID, and the Interactive Brokers API port.

You can have multiple environments by setting the 'MARKETHACKERS_ENV' envrionment variable.
If it's unset, it defaults to 'production'.

Typically, it's useful to have a second environment (e.g. test) with a different IB port setting for paper trading
vs live trading.

A sample `~/.markethackers` yml config file after running `mh setup`:

```
---
:production:
  :settings:
    :auth_token: TSDSDSoSFDFDDFYzFyFPna
    :ib_account_id: XXXYYY
    :ib_port: 4002
    :url: http://localhost:5000
:test:
  :settings:
    :auth_token: TSDSDSoSFDFDDFYzFyFPna
    :ib_account_id: XXXYYY
    :ib_port: 4002
    :url: http://localhost:5000
```
To retrieve your Interactive Brokers port value, start the TWS Trader's Workstation application. 

From the settings, click API, you should see your port number.

Also, make sure to enable "API->Active X socket connections". 

Hit apply then save.

## Creating a Scan

`mh generate <title>`

E.g. `mh generate "A Breakout Scan"`

Your browser will open up tab with your newly create Market Hacker scan titled 'A Breakout Scan'
Locally in your current directory, `a_breakout_scan.rb` file will be generated along with the boilerplate code
for loading your Market Hacker scan results, and loading your positions within Interactive Brokers. 

Go to the Market Hackers website, and create a new scan.

https://www.markethackers.com/scans/new

## Creating Limit Orders Based on Scan Results

Open up the "a_breakout_scan" file.

There you will see the 

`mh scan a_breakout_scan` 
