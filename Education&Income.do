* Education and income
* Input: ACS_2024_Final_15000.csv
* Output: education_income_cleaned.dta, regression_results.dta

clear all
set more off

* 1. Data
import delimited using "ACS_2024_Final_15000.csv", clear varnames(1) case(lower) encoding("utf-8")
count
local n0 = r(N)

* Sample restrictions
keep if inrange(agep,25,64)
count
local n1 = r(N)

keep if inlist(schl,21,22,23,24)
count
local n2 = r(N)

keep if pincp > 0 & !missing(pincp)
count
local n3 = r(N)

* Create variables
foreach v in master professional doctorate female age2 logincome ln_income disability hispanic sample_common edu_years {
    cap drop `v'
}

gen byte master = schl == 22
gen byte professional = schl == 23
gen byte doctorate = schl == 24
gen byte female = (sex == 2) if inlist(sex,1,2)
gen int age2 = agep^2
gen double ln_income = ln(pincp)
gen double logincome = ln_income
gen byte disability = (dis == 1) if inlist(dis,1,2)
gen byte hispanic = inrange(hisp,2,24) if inrange(hisp,1,24)

* Estimated education years (mapping; not observed years)
gen byte edu_years = .
replace edu_years = 16 if schl == 21
replace edu_years = 18 if schl == 22
replace edu_years = 19 if schl == 23
replace edu_years = 22 if schl == 24
label var edu_years "Estimated years of education"

* Common sample for all six models
keep if !missing(ln_income,master,professional,doctorate,edu_years,agep,age2,female,disability,rac1p,hispanic,state,employed,esr)
keep if inrange(rac1p,1,9)
count
local n4 = r(N)

keep if employed == 1
count
local n5 = r(N)

gen byte sample_common = 1
assert !missing(ln_income,master,professional,doctorate,edu_years,agep,age2,female,disability,rac1p,hispanic,state)
assert employed == 1
assert pincp > 0 & !missing(pincp)

dis "Original sample: " `n0'
dis "After age restriction: " `n1'
dis "After education restriction: " `n2'
dis "After positive income restriction: " `n3'
dis "After complete-case restriction: " `n4'
dis "Final employed sample: " `n5'

tab schl
tab esr
sum pincp ln_income agep

save "education_income_cleaned.dta", replace

* 2. Regressions
use "education_income_cleaned.dta", clear

describe
tab schl, missing
sum pincp wagp agep

* Method 1: Dummy variables
* D1: Education only
reg ln_income master professional doctorate if sample_common, vce(robust)
est store D1

* D2: Add age and gender
reg ln_income master professional doctorate c.agep c.agep#c.agep female if sample_common, vce(robust)
est store D2

* D3: Add other controls
reg ln_income master professional doctorate c.agep c.agep#c.agep female disability i.rac1p hispanic i.state if sample_common, vce(robust)
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
reg ln_income c.edu_years if sample_common, vce(robust)
est store C1

* C2: Add age and gender
reg ln_income c.edu_years c.agep c.agep#c.agep female if sample_common, vce(robust)
est store C2

* C3: Add other controls
reg ln_income c.edu_years c.agep c.agep#c.agep female disability i.rac1p hispanic i.state if sample_common, vce(robust)
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

* Results: All six models
est table D1 D2 D3 C1 C2 C3, b(%9.4f) se(%9.4f) stats(N r2)

* Income change for one additional estimated education year (C3)
est restore C3
nlcom (Education_year_pct: 100*(exp(_b[edu_years])-1))

* Save coefficients and model statistics
tempname results
postfile `results' str12 model str80 variable ///
    double coefficient robust_se t_stat p_value observations r_squared ///
    using "regression_results.dta", replace

foreach m in D1 D2 D3 C1 C2 C3 {
    est restore `m'
    matrix b = e(b)
    local vars : colnames b
    local N = e(N)
    local R2 = e(r2)
    local df = e(df_r)

    foreach v of local vars {
        local coef = _b[`v']
        local se = _se[`v']
        if (`se' > 0 & `se' < .) {
            local t = `coef' / `se'
            local p = 2*ttail(`df', abs(`t'))
            post `results' ("`m'") ("`v'") (`coef') (`se') (`t') (`p') (`N') (`R2')
        }
    }
}
postclose `results'

use "regression_results.dta", clear
