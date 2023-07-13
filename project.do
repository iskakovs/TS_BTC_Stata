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
