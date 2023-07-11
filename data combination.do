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

