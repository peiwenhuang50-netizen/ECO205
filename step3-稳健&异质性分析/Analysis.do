
do "model1-3.do"
set more off

* D3: ordinary OLS and variance test; compare with the main file robust result.
regress ln_income master professional doctorate agep age2 female disability i.rac1p hispanic i.state
estimates store D3_OLS
hettest, rhs iid
estimates table D3_OLS D3, keep(master professional doctorate) b(%9.4f) se(%9.4f) stats(N r2)


* C3: ordinary OLS and variance test; compare with the main file robust result.
regress ln_income edu_years agep age2 female disability i.rac1p hispanic i.state
estimates store C3_OLS
hettest, rhs iid
estimates table C3_OLS C3, keep(edu_years) b(%9.4f) se(%9.4f) stats(N r2)

