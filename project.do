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

* Let's make a simple OLS regression for our differenced and logged variables
regress d.lgold d.lbtc d.lm1
asdoc regress d.lgold d.lbtc

* Durbin-Watson d-statistic
estat dwatson
** d-statistic is .3957583, and R^2 is .2488. So d-statistic > R^2 => time series are stationary and we have a case of I(1)-I(1). There is no spurious regression

** Lag selection
* For gold and BTC price
asdoc varsoc lgold lbtc
* First lag seems to be perfect

* Let's make a simple OLS again
asdoc regress lgold lbtc, robust

*Predicting error terms
predict error, resid

*Applying ADF test to error terms
dfuller error
* our p value is <0.05, so our error terms are stationary and we have cointegration

*So we need VAR(1) model with one lag and two variables
var lgold lbtc, lags(1)

* Trying to set up the model with one exogeneous variable Money supply
asdoc var lgold lbtc, lags (1) dfk exog(lm1)

*Performing Lagrange-multiplier test
varlmar
* We canot reject the null hypothesis - so there is no autocorrelation at lag 1

*Checking for normality of the error terms
asdoc varnorm
* our error terms are normally distributed

*Plotting error terms to see it
line error t, legend(size(medsmall))

*Check if our error terms behave like a WN
wntestq error
* no - we don't have WN process

// Performing the Granger causality test
asdoc vargranger
* H0: X does not Granger Cause Y, 
* H1: X Granger Cause Y
* we get p values > 0.05 that means that X does not Granger cause Y (i.e. our variables does not effect each other at 5% significance level)  

*Checking for VAR model stability
varstable
varstable, graph
*IRFs
irf create irf2, set(irf_gb2)
irf graph oirf, impulse(lgold) response(lbtc)

irf create irf3, set(irf_bg)
irf graph oirf, impulse(lbtc) response(lgold)

** We can also try to check for IRF, that is we can check the effect of one unit shock in X on Y. But since we don't have relationship between these varaibles, I'm not sure we need to do it.
// (for IRF we need to apply Cholesky decomposition approach)
