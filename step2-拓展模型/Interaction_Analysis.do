cd "/Users/evelyn/Desktop/eco205小组作业"
do "Education&Income.do"

* D4: Education dummy × Age interaction
reg ln_income ib21.schl##c.agep c.age2 female disability i.rac1p hispanic i.state, vce(robust)
est store D4

* C4: Education years × Age
reg ln_income c.edu_years##c.agep c.age2 female disability i.rac1p hispanic i.state, vce(robust)
est store C4

* D4: Predicted log income by education and age
est restore D4
margins schl, at(agep=(30(5)60))
marginsplot, name(D4_Graph)

* C4: Marginal association of education years at different ages
est restore C4
margins, dydx(edu_years) at(agep=(30(5)60))
marginsplot, name(C4_Graph)
