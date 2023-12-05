* ************************************
* ************************************
* ********** Preamble ****************
* ************************************

clear all
cls
cd "/Users/kevin/Dropbox/legal_censorship/"

* spec 1: construct career incentive panel
* spec 2: analysis

local spec 2

import excel using "Data/treat_county.xlsx", firstrow clear
destring year, replace force
gen prefecture = floor(county / 100) * 100
collapse (sum) plaintiff defendant court, by(prefecture year)

preserve
import excel using "Data/career_incentive_panel.xlsx", firstrow clear
duplicates drop prefecture year, force
tempfile incentive
save `incentive'
restore

if `spec' == 1{
preserve
	import excel using "/Users/kevin/Dropbox/Policy Experimentation/Revision/Data/mayor_birth_connection.xlsx", firstrow clear
	duplicates drop name on_yr, force
	tempfile connection
	save `connection'
restore

preserve
	use "/Users/kevin/Dropbox/Policy Experimentation/Data/Admin data/City Data Final.dta", clear
	replace city = substr(city, 1, strlen(city) - 3)
	rename city prefname
	rename year on_yr
	tempfile demo
	save `demo'
restore

preserve
	import excel using "/Users/kevin/Dropbox/Policy Experimentation/R&R/incentives/Pref_Secretary&Mayor_2021nov.xlsx", firstrow clear
	replace prefname = substr(prefname, 1, strlen(prefname) - 3)
// 	drop if incumbent==1
	gen realpromotion = cond(promotion>2,1,0)
	replace realpromotion = . if incumbent == 1
	keep if pos==1
	destring on_yr birth_yr on_mh birth_mh center_yr, replace force
	gen startage=on_yr-birth_yr if on_mh>=birth_mh & birth_mh!=. & on_mh != .
	replace startage=on_yr-birth_yr-1 if on_mh<birth_mh & birth_mh!=. & on_mh != .
	*** for those missing birth_mh ***
	replace startage=on_yr-birth_yr if birth_mh==.
	gen startagesq=startage^2
	egen p_begin = group(plevel_begin)
	
	gen fubu=0 if plevel_begin=="正厅"
	replace fubu=1 if plevel_begin=="副部"
	gen strage_fubu = startage * fubu

	*** part 3: define promotion
	gen promote = 1 if promotion > 2 // 3: 提拔-二线, 4: 提拔-晋升
	replace promote = 0 if promotion < 3
	
	*** clean up educational vars ***
	gen edu = 3 if edu_name == "博士" | edu_name == "博士后" | edu_name == "博士研究生" | edu_name == "在职博士" | edu_name == "在职研究生" | edu_name == "在职硕士研究生" | edu_name == "中央党校研究生" | edu_name == "区委党校研究生" | edu_name == "省委党校研究生" | edu_name == "研究生" | edu_name == "硕士研究生"
	replace edu = 2 if edu_name == "本科"
	replace edu = 1 if edu == .

	*** previous central experience ***
	replace center = "." if center=="N/A"
	gen center_exp = real(center)
	gen prev_center = 1 if center_exp == 1
	replace prev_center = 0 if prev_center == .
	replace prev_center = 0 if center_yr >= on_yr
	
	*** previous prov experience ***
	gen prev_prov = cond(otherprovbefore == "1", 1, 0)
	gen college = cond(edu_name == "博士" | edu_name == "博士后" | edu_name == "博士研究生" | edu_name == "本科" | edu_name == "硕士研究生" | edu_name == "研究生", 1, 0)
	gen party_college = cond(edu_name == "中央党校研究生" | edu_name == "区委党校研究生" | edu_name == "省委党校研究生" , 1, 0)
	
	*** current tenure
	destring off_yr on_yr, replace force
	gen tenure = off_yr - on_yr
	
	*** connection: same_birthprov_sj
	duplicates drop name on_yr, force
	merge 1:1 name on_yr using `connection'
	replace same_birthprov_sj = 0 if same_birthprov_sj == .
	
	*** demographics
	merge m:1 prefname on_yr using `demo', keep(1 3) nogen
	gen gdppc = gdp / population
	
// 	egen edu = group(edu_name)
	
	probit promote fubu startage strage_fubu
	predict prt_hat
	
	probit promote c.startage##i.p_begin gdppc, r
	predict prt_hat2

	probit promote c.startage##i.p_begin same_birthprov_sj gdppc, r
	predict prt_hat3
	
	keep prefname name prt_hat prt_hat2 prt_hat3 on_yr
	sort prefname on_yr

	by prefname: gen prt_hat2_post = prt_hat2[_n+1]
	by prefname: gen prt_hat3_post = prt_hat3[_n+1]
	
	duplicates drop prefname name, force
	save "Data/incentive_robust.dta", replace
	
	tempfile career_incentive
	save `career_incentive'
restore
}
if `spec' == 2{
merge 1:1 prefecture year using `incentive', keep(1 3) nogen
replace prefname = substr(prefname, 1, strlen(prefname) - 3)
rename name_party name
merge m:1 prefname name using "Data/incentive_robust.dta", keep(1 3) nogen

* Censored cases happens more often during time periods when politicians have more career incentive
reghdfe defendant_counts prt_hat, a(prefecture) vce(r)
reghdfe defendant_counts prt_hat, a(year) vce(r)
reghdfe defendant_counts prt_hat, a(prefecture year) vce(r)
reghdfe defendant_counts prt_hat, a(prefecture year) vce(r)
reghdfe defendant_counts prt_hat3, a(prefecture year) vce(r)
}
