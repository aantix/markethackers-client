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

Be sure to have the IB Gateway application running on your computer. 

From the settings, enable "API->Active X socket connections". Hit apply then save.

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
