do  "Education&Income.do"

* D4: Quadratic age model (Education Dummies)
reg ln_income master professional doctorate agep c.age2 female disability i.rac1p hispanic i.state, vce(robust)
est store D4

* C4: Quadratic age model (Education Years)
reg ln_income edu_years agep c.age2 female disability i.rac1p hispanic i.state, vce(robust)
est store C4

