import delimited "/Users/evelyn/Desktop/eco205/ACS_2024_Final_15000.csv", clear

* Model 1
regress logincome master professional doctorate, vce(robust)

* Model 2
regress logincome master professional doctorate agep age2 female, vce(robust)

* Hispanic dummy
generate byte hispanic = inrange(hisp, 2, 24) if inrange(hisp, 1, 24)

* Model 3
regress logincome master professional doctorate agep age2 female ///
    ib2.dis i.rac1p hispanic i.state, vce(robust)

* Interaction model
regress logincome ib21.schl##c.agep c.agep#c.agep ///
    female ib2.dis i.rac1p hispanic i.state, vce(robust)

* Joint significance of interaction terms
testparm i.schl#c.agep

* Predicted log income by education and age
margins schl, at(agep=(30 40 50 60))

marginsplot

* Marginal differences across education categories
margins, dydx(schl) at(agep=(30 40 50 60))
