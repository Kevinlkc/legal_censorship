************** Last edit Aug 7 by Kaicheng Luo **************
clear all
cd "/Users/kevin/Dropbox/legal_censorship"
import delimited using "Data/rongzi_firm_panel.csv", encoding("utf-8") clear

gen treated = cond(treat == "True", 1, 0)
gen p = cond(post == "True", 1, 0)
keep if quarter >= "2019"
keep if quarter <= "2023Q3"
egen q = group(quarter)

egen ind_temp = group(industry)
destring district_code, replace force
gen code_temp = floor(district_code / 100)
bysort ent_name: egen ind = max(ind_temp)
bysort ent_name: egen code = max(code_temp)

cap drop rel_year
gen rel_year = q-9 // q=9 when quarter == "2021Q1"
replace rel_year = . if treated == 0 // Non-treated units are considered the "control" group

replace amount = 0 if amount == .
replace amount = amount / 1e6

eventdd amount, timevar(rel_year) absorb(ent_name q) baseline(0) accum leads(4) lags(5) hdfe noline graph_op( ///
 xline(0.5) graphregion(color(white)) xtitle("Quarters relative to censorship") ytitle("Private placement (million)"))
graph export "Figure/eventstudy_amount_invest.png", replace
