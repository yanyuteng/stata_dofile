** What Factors Affect Housing Area
cd "~/desktop/usualdata"
use "cgss2015_14.dta", clear

** dependence var lnhouse
*** tab a11
recode a11 (0=.), gen(house)
gen lnhouse = ln(house)
*** hist lnhouse

** independence var age age^2 buyear
gen age = 2015-a301
*** hist age
*** gen age2 = age*age notsig
*** gen age1960 = 0 notsig
*** replace age1960 = 1 if a301>1960
*** label define age1960l 1"brith_aft1960" 0"brith_bef1960"
*** label value age1960 age1960l

recode e1 (-3 -2=.), gen(buyear)

gen buy1998 = 0 
replace buy1998 = 1 if buyear>1998
label define buy1998l 1"buy_aft1998" 0"buy_bef1998"
label value buy1998 buy1998l

gen buyearlen = 2015 - buyear + 1

*** gen buyear2 = buyear*buyear notsig

** independence var famincome
*** tab a62
gen famincome = a62
recode famincome (-3/0=.)
gen lnfamincome = ln(famincome)
gen faincome = famincome/10000

** independence var edu
*** tab a7a
recode a7a (-8 14=.)(1=1)(2=3)(3=6)(4=9)(5=11)(6=12)(7=11)(8=11)(9=14)(10 11=15)(12=16)(13=19), gen(edu)

gen eduxbuy1998 = edu*buy1998

** independence var party
*** tab a10
gen party = a10
recode party (-8=.)(1 2 =0)(3 4 =1)
label define partyl 1"party" 0"crowd"
label value party partyl

** independence var danwei
*** tab a59k notsig
recode a59k (-8 6=.)(1 2 =1)(3/5 =0), gen(danwei)
label define danweil 1"government" 0"personal"
label value danwei danweil

*** tab a59j notsig
recode a59j (-8 7=.)(1 3 6=1)(2 4 5 =0), gen(danwei2)
label define danweil2 1"government" 0"personal"
label value danwei2 danweil2

** 1control var sex
*** tab a2
recode a2 (1=1)(2=0), gen(sex)

** 2control var urban
recode a18 (1 6 7=0)(2/5=1)(8=1), gen(urban)

** control var ethnic notsig
*** tab a4
*** tab a4 , nol
recode a4 (-8=.)(1=1)(2/8=0), gen(ethnic)
label define ethnicl 1"han" 0"others"
label value ethnic ethnicl

** 3control var householdnum
*** tab a63
*** tab a63 , nol
gen householdnum = a63
recode householdnum (-3/-1=.)(50=.) 

** 4control var marriage
*** tab a69 , nol
recode a69 (1 2=0)(3/7=1), gen(marriage)
label define marriagel 1"marriage" 0"single"
label value marriage marriagel

** 5control var property
gen property=0 
replace property=1 if a121==1 | a122==1
replace property=2 if a123==1 | a126==1 | a124==1 | a125==1 | a127==1
replace property=. if a129==1
label define propertyl 0"rent" 1"own" 2"borrow"
label value property propertyl

gen property1 = 1
replace property1=0 if property==0 | property==2
gen property2 = 1
replace property2=0 if property==0 | property==1


** analysis

foreach v in lnhouse edu age buy1998 faincome danwei2 party sex householdnum marriage property {
  drop if `v' == .
}

** model1 human captial
*** quietly xi: reg lnhouse faincome edu age sex householdnum marriage i.property urban
quietly reg lnhouse faincome edu age sex householdnum marriage property1 property2 urban
sheafcoef, latent(human_capital: faincome edu) post
outreg2 using example1.docx, replace
** model2 political captial
quietly reg lnhouse faincome edu danwei2 party age sex householdnum marriage property1 property2 urban
sheafcoef, latent(human_capital: faincome edu; political_capital: danwei2 party) post
outreg2 using example1.docx
** model3 buy1998 influence
quietly reg lnhouse faincome edu danwei2 party buy1998 age sex householdnum marriage property1 property2 urban
sheafcoef, latent(human_capital: faincome edu; political_capital: danwei2 party) post
outreg2 using example1.docx
** model4 buy1998*human captial
quietly reg lnhouse faincome edu buy1998 eduxbuy1998 danwei2 party age sex householdnum marriage property1 property2 urban
sheafcoef, latent(human_capital: faincome edu; political_capital: danwei2 party) post
outreg2 using example1.docx


** test
estat hettest, iid
estat hettest, rhs iid

estat vif

** heise
quietly reg lnhouse faincome edu buy1998 eduxbuy1998 danwei2 party age sex householdnum marriage property1 property2 urban
sheafcoef, latent(human_capital: faincome edu; political_capital: danwei2 party) post
