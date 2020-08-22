# Markethackers.com Scan and Trade Client for InteractiveBrokers 

Use this client to connect to Market Hackers, run your scan, retrieve your candidates
and place your limit orders with Interactive Brokers

The scans are run on the Market Hackers servers.  This client runs locally on your laptop
along with IB's Trader Workstation.

## Installation

Be sure to have Ruby installed on your system.

For Macs, run :

`brew install ruby`

then

`gem install markethackers-ib-client`

## Usage

Be sure to have Trader Workstation application running on your computer. 

From the settings, enable "API->Active X socket connections". Hit apply then save.

From the command-line, start the Market Hackers client with `markethackers-ib-client`.
