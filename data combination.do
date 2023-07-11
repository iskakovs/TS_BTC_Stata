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

*Change the date format, to make the data we got from FRED in the same date format
gen new_date = date(date, "MDY")
format new_date %td
format %tdDD/NN/CCYY new_date

*Sort by new date format
gsort +new_date

*Drop the old date column
drop date

*...and rename the new date column to simply "date"
rename new_date date

*Change the order of columns
order date gold

*Change the format of price from US format with (.) as a decimal to the format with (,) as a decimal 
destring gold, replace ignore(",")

*Save as a new file "gold" and replace if we have the same file 
save "C:\Users\Admin\Desktop\gold.dta", replace

//Import data the data for money supply M1 aggregate in CSV file
import delimited "C:\Users\Admin\Desktop\WM1NS.csv", clear

*Change the date format (here we follow the same procedure as before)
gen new_date = date(date, "YMD")
drop date
format new_date %td
format %tdDD/NN/CCYY new_date

*Sort by date
gsort +new_date

*Rename the name of the column for money supply aggregate M1 and the date
rename wm1ns m1
rename new_date date

*Change the order of columns
order date m1

*Save (and if needed replace) the file
save "C:\Users\Admin\Desktop\m1.dta", replace

//Import data the data for Bitcoin price in CSV file
import delimited "C:\Users\Admin\Desktop\CBBTCUSD.csv", clear

*Change the date format (as before)
gen new_date = date(date, "YMD")
drop date
format new_date %td
format %tdDD/NN/CCYY new_date

*Sort by date
gsort +new_date

*Rename the column for Bitcoin price and date
rename cbbtcusd btc
rename new_date date

*Change the order of columns
order date btc

*Save (and if needed replace) the file
save "C:\Users\Admin\Desktop\btc.dta", replace

// Let's merge (or actually append) the files for Bitcoin price and Gold price by dates
joinby date using "C:\Users\Admin\Desktop\gold.dta"

*Save the new file btc-gold
save "C:\Users\Admin\Desktop\btc-gold.dta", replace

// Now let's take the last file we got (btc-gold) and merge it in the same way with the file where we have money supply
use "C:\Users\Admin\Desktop\btc-gold.dta", clear
joinby date using "C:\Users\Admin\Desktop\m1.dta"

*Save the new file as "data" - we got the final dataset we will work with
save "C:\Users\Admin\Desktop\data.dta", replace

*If we need to describe it
describe btc gold m1
inspect btc gold m1
summarize btc gold m1
