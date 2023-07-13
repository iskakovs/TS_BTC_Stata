* Date: 
* Paper: 
*
* This code is written for the analysis of the relationship (cointegration, and causality) between gold price and Bitcoin price
*
* Database used: 
* Preliminary: "CBBTCUSD.csv", "WM1NS.csv", "Gold Futures Historical Data.csv",   
* Datasets after preprocessing: "btc.dta", "gold.dta", "m1.dta", "btc-gold.dta"
* Final data to use: "data.dta"
*
* output: data.dta
*
* Key varaibles: - Gold Price
*				 - Bitcoin Price
*

clear
clear matrix
set mem 500m

#delimit;

codebook

// Import the data
use "C:\Users\Admin\Desktop\data.dta", clear

bro

* Install the package for Latex conversion
ssc install estout, replace
ssc install outreg2
ssc install asdoc

* Let's generate the new variable "n" as a time period number
generate t = _n

* Set dataset as a timeseries 
tsset t, weekly

*Set dataset as a time series of weekly values
*tsset date, weekly

*Let's take to log of each variable to normalize it, we will also need the log for further % change interpretation
generate lbtc = log(btc)
generate lm1 = log(m1)
generate lgold = log(gold)

*Let's set labels for variables
label var btc "Bitcoin price (USD)"
label var gold "Gold price (USD)"
label var m1 "Aggregate M1 (bln.USD)"
label var lbtc "Log BTC Price"
label var lgold "Log Gold Price"
label var lm1 "Log Aggregate M1"

* Let's make a graph of the variables
** For BTC
twoway (tsline lbtc)
** For gold
twoway (tsline lgold)

* Let's make a graph of the variables with trendlines for BTC
** For Log BTC
scatter lbtc date || lfit lbtc date, saving(plot_lbtc)
** For BTC
scatter btc date || lfit btc date, saving(plot_btc)
** Combine the graphs
graph combine "plot_lbtc" "plot_btc"
