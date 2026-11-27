* Education and income
* Input: ACS_2024_Final_15000.csv

clear all

* 1. Data
import delimited using "输入数据/ACS_2024_Final_15000.csv", clear varnames(1) case(lower) encoding("utf-8")

* Sample restrictions
keep if inrange(agep,25,64)
keep if inlist(schl,21,22,23,24)
keep if pincp > 0 & !missing(pincp)

* Create variables
gen master = (schl == 22)
gen professional = (schl == 23)
gen doctorate = (schl == 24)
gen female = (sex == 2) if inlist(sex,1,2)
gen age2 = agep^2
gen ln_income = ln(pincp)
gen disability = (dis == 1) if inlist(dis,1,2)
gen hispanic = inrange(hisp,2,24) if inrange(hisp,1,24)

* Estimated education years (mapping; not observed years)
gen byte edu_years = .
replace edu_years = 16 if schl == 21
replace edu_years = 18 if schl == 22
replace edu_years = 19 if schl == 23
replace edu_years = 22 if schl == 24

* Common sample for all six models
keep if !missing(ln_income,master,professional,doctorate,edu_years,agep,age2,female,disability,rac1p,hispanic,state,employed,esr)
keep if inrange(rac1p,1,9)
keep if employed == 1

assert !missing(ln_income,master,professional,doctorate,edu_years,agep,age2,female,disability,rac1p,hispanic,state)
assert employed == 1
assert pincp > 0 & !missing(pincp)
count

* 2. Regressions

* Method 1: Dummy variables
* D1: Education only
reg ln_income master professional doctorate, vce(robust)
est store D1

* D2: Add age and gender
reg ln_income master professional doctorate c.agep female, vce(robust)
est store D2

* D3: Add other controls
reg ln_income master professional doctorate c.agep female disability i.rac1p hispanic i.state , vce(robust)
est store D3

* Joint test of education dummies
est restore D1
test master professional doctorate
est restore D2
test master professional doctorate
est restore D3
test master professional doctorate

* Results: Dummy models
est table D1 D2 D3, b(%9.4f) se(%9.4f) stats(N r2)

* Income differences relative to bachelor's degree (D3)
est restore D3
nlcom (Master_pct: 100*(exp(_b[master])-1)) ///
      (Professional_pct: 100*(exp(_b[professional])-1)) ///
      (Doctorate_pct: 100*(exp(_b[doctorate])-1))

* Method 2: Estimated education years
* C1: Education years only
reg ln_income c.edu_years, vce(robust)
est store C1

* C2: Add age and gender
reg ln_income c.edu_years c.agep female, vce(robust)
est store C2

* C3: Add other controls
reg ln_income c.edu_years c.agep female disability i.rac1p hispanic i.state, vce(robust)
est store C3

* Test education-years coefficient in each model
est restore C1
test edu_years
est restore C2
test edu_years
est restore C3
test edu_years

* Results: Education-years models
est table C1 C2 C3, b(%9.4f) se(%9.4f) stats(N r2)

* Income change for one additional estimated education year (C3)
est restore C3
nlcom (Education_year_pct: 100*(exp(_b[edu_years])-1))

* Results: All six models
est table D1 D2 D3 C1 C2 C3, b(%9.4f) se(%9.4f) stats(N r2)




