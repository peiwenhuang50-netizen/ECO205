cd "/Users/evelyn/Desktop/eco205小组作业"
do "Education&Income.do"

* D5: Education dummy × Age interaction
reg ln_income ib21.schl##c.agep c.age2 female disability i.rac1p hispanic i.state, vce(robust)
est store D5

* C5: Education years × Age
reg ln_income c.edu_years##c.agep c.age2 female disability i.rac1p hispanic i.state, vce(robust)
est store C5

* D6: Education dummies × Gender
reg ln_income ib21.schl##i.female agep age2 disability i.rac1p hispanic i.state, vce(robust)
est store D6

* C6: Education years × Gender
reg ln_income c.edu_years##i.female c.age2 female disability i.rac1p hispanic i.state, vce(robust)
est store C6

