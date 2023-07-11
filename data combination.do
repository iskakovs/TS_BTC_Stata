********************************************
***********DATA MANIPULATION****************
********************************************

//Import data the data for gold in CSV file
import delimited "C:\Users\Admin\Desktop\Gold Futures Historical Data.csv", clear

*We need to sort the data, since now it is in the backward format, we need the earlier dates to be first 
gsort -v1

*Drop the varaible we don't need (highest price, lowest price, etc.). All we need is the last (closing) price 
drop v3 v4 v5 v6 v7

*Rename the columns 
rename v1 date
rename v2 gold

*Let's delete the first row
*Let's generate the new variable which is the index number for the price
gen n = _n

*...and delete the first index number, so that it will delete the row too 
drop if n == 1

*we don't need index number
drop n
