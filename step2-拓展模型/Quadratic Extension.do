do  "Education&Income.do"

reg ln_income c.edu_years##c.edu_years agep age2 female disability i.rac1p hispanic i.state, vce(robust)
