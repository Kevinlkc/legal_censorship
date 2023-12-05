************** Last edit Aug 7 by Kaicheng Luo **************
clear all
cd "/Users/kevin/Dropbox/legal_censorship"
import delimited using "Data/procurement_firm_panel.csv", clear

egen ind_temp = group(industry)
destring district_code, replace force
gen code_temp = floor(district_code / 100)
bysort ent_name: egen ind = max(ind_temp)
bysort ent_name: egen code = max(code_temp)

gen treated = cond(treat == "True", 1, 0)
gen p = cond(post == "True", 1, 0)
egen q = group(quarter)

keep if quarter <= "2023Q2"
replace sales_amount = sales_amount / 100
replace sales_amount = sales_amount / 1e4 if sales_amount > 1e5
gen lsales = log(1+sales_amount)

reghdfe sales_amount treated p c.treated#c.p, vce(r)
reghdfe num treated p c.treated#c.p, vce(r)
reghdfe govt treated p c.treated#c.p, vce(r)

cap drop rel_year
gen rel_year = q-13 // q=13 when quarter == "2021Q1"
replace rel_year = . if treated == 0 // Non-treated units are considered the "control" group

eventdd sales_amount, timevar(rel_year) absorb(quarter ent_name) baseline(0) inrange leads(4) lags(5) hdfe cluster(ind) noline graph_op(  ///
 xline(0.5) graphregion(color(white)) xtitle("Quarters relative to censorship") ytitle("Government procurement (Million yuan)"))
graph export "Figure/eventstudy_salesamout.png", replace

winsor2 govt, replace cuts(0 99)
eventdd govt, timevar(rel_year) absorb(quarter ent_name) baseline(0) inrange leads(4) lags(5) hdfe cluster(ent_name) noline graph_op( ///
 xline(0.5) graphregion(color(white)) xtitle("Quarters relative to censorship") ytitle("Government procurement #"))
graph export "Figure/eventstudy_numgovt.png", replace

winsor2 num, replace cuts(0 99)
eventdd num, timevar(rel_year) absorb(quarter ent_name) baseline(0) inrange leads(4) lags(5) hdfe cluster(ind) noline graph_op( ///
 xline(0.5) graphregion(color(white)) xtitle("Quarters relative to censorship") ytitle("Government procurement #"))
graph export "Figure/eventstudy_numtotal.png", replace
