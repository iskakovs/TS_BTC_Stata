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
*	          - Bitcoin Price
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

* Let's make a graph of the variables with trendlines for gold
** For Log gold
scatter lgold date || lfit lgold date, saving(plot_lgold)
** For gold
scatter gold date || lfit gold date, saving(plot_gold)
** Combine the graphs
graph combine "plot_lgold" "plot_gold"

** Combine the graphs of the raw variables
graph combine "plot_btc" "plot_gold"

** Combine the graphs of the logged variables
graph combine "plot_lbtc" "plot_lgold"

*Let's make some visualizations of our variables
tsline lbtc lgold
scatter lbtc lgold || lfit lbtc lgold
** The graph shows the negative correlation between the price of the gold and Bitcoin. However, we need to check our results using the tests. 

*For the begining, let's make a simple OLS regression
asdoc reg lgold lbtc 

*Let's plot the ACF and PACF functions
** For BTC price
ac lbtc
pac lbtc

** For Gold price
ac lgold
pac lgold

* We again run the regression and to check for structural breaks
regress lgold lbtc

* Now let's check for structural breaks
estat sbsingle, breakvars(lbtc) //generate(wald)
outreg2 using myfile2.doc, replace

tsline wald, title("Wald test statistics")

* Plot the scatter plot to check for relationship
graph twoway (lfitci lgold lbtc) (scatter lgold lbtc)
* seems like we have negative relationship between varaibles, so it looks like people shift from gold to BTC and assets behave like absolute substitutes 

regress lgold lbtc

* ADF test for stationarity
asdoc dfuller lbtc
asdoc dfuller lgold

*We are not reqiured, but let's check the stationarity of the money supply series too
dfuller lm1
*We have non stationary data series. So we apply first differencing

* We can alternatively run DF-GLS test
asdoc dfgls lbtc
asdoc dfgls lgold

* Taking first difference of each TS
asdoc dfuller d.lgold
asdoc dfuller d.lbtc
*We see that each TS becomes stationary - p value = 0.0000.

* We can alternatively run DF-GLS test
asdoc dfgls d.lbtc
asdoc dfgls d.lgold

* Plotting the graph of each variable
line d.lgold d.lbtc t, legend(size(medsmall))



