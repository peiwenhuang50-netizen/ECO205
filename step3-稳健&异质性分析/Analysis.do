* B group: first select this folder as the Stata working directory.
* Call the agreed main file once; it stores robust results D1-D3 and C1-C3.
* Reuse those results below; do not estimate robust regressions again.
do "model1-3.do"
set more off
capture log close
log using "B_group_results.log", text replace

* D1: ordinary OLS and variance test; compare with the main file robust result.
regress ln_income master professional doctorate
estimates store D1_OLS
hettest, rhs iid
estimates table D1_OLS D1, keep(master professional doctorate) b(%9.4f) se(%9.4f) stats(N r2)

* D2: ordinary OLS and variance test; compare with the main file robust result.
regress ln_income master professional doctorate agep age2 female
estimates store D2_OLS
hettest, rhs iid
estimates table D2_OLS D2, keep(master professional doctorate) b(%9.4f) se(%9.4f) stats(N r2)

* D3: ordinary OLS and variance test; compare with the main file robust result.
regress ln_income master professional doctorate agep age2 female disability i.rac1p hispanic i.state
estimates store D3_OLS
hettest, rhs iid
estimates table D3_OLS D3, keep(master professional doctorate) b(%9.4f) se(%9.4f) stats(N r2)

* C1: ordinary OLS and variance test; compare with the main file robust result.
regress ln_income edu_years
estimates store C1_OLS
hettest, rhs iid
estimates table C1_OLS C1, keep(edu_years) b(%9.4f) se(%9.4f) stats(N r2)

* C2: ordinary OLS and variance test; compare with the main file robust result.
regress ln_income edu_years agep age2 female
estimates store C2_OLS
hettest, rhs iid
estimates table C2_OLS C2, keep(edu_years) b(%9.4f) se(%9.4f) stats(N r2)

* C3: ordinary OLS and variance test; compare with the main file robust result.
regress ln_income edu_years agep age2 female disability i.rac1p hispanic i.state
estimates store C3_OLS
hettest, rhs iid
estimates table C3_OLS C3, keep(edu_years) b(%9.4f) se(%9.4f) stats(N r2)

log close
