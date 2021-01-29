use "/Users/mac/Dropbox/ugur-cem/final.dta", clear

set more off
set matsize 11000
sort period commoditycode partnercode
merge period commoditycode partnercode using "/Users/mac/Dropbox/ugur-cem/partnercode.dta"

gsort partnercode commoditycode -_merge
quietly by partnercode commoditycode: replace _merge=_merge[_n-1] if _n > 1
keep if _merge==3

drop _merge*
sort partnercode commoditycode period
merge 1:1 partnercode commoditycode period using "/Users/mac/Desktop/ugur-cem/COMTRADE data/world.dta"
keep if x!=.
drop _merge

drop global_x partner_x

replace partner_m=0 if partner_m==.

gen asinhx=asinh(x)
gen asinh_pm=asinh(partner_m)


drop reportercode



**aggregating embargoed products*
gen embargo=0
replace embargo=1 if commoditycode==80510 | commoditycode==80520 | commoditycode==80910 | commoditycode==80930 | commoditycode==80940 // Oct 2016

replace embargo=2 if commoditycode==60312 | commoditycode==70310 | commoditycode==70410 | commoditycode==250100 // Mar 2017

replace embargo=3 if commoditycode==20714 | commoditycode==20727 | commoditycode==70700 | commoditycode==80810 | commoditycode==80830 | commoditycode==80610 | commoditycode==81010 // Jun 2017

replace embargo=4 if commoditycode==70200 // Nov 2017




*gen logx=ln(x)
*sort embargo period partnercode  
*twoway line logx period if partnercode==643 & embargo==1


set more off
gen work = string(period, "%12.0f")

gen month=real(substr(work, -2, 2))
drop work
*gen partnerxmonth=partnercode*month
** treated dates as a whole *
gen treatment_Oct2016=0
replace treatment_Oct2016=1 if period>201600 & period<201610 & partnercode==643


gen treatment_Mar2017=0
replace treatment_Mar2017=1 if period>201609 & period<201703 & partnercode==643

gen treatment_Jun2017=0
replace treatment_Jun2017=1 if period>201702 & period<201706 & partnercode==643


gen treatment_Nov2017=0
replace treatment_Nov2017=1 if period>201705 & period<201711 & partnercode==643




gen pre_treatment=0
replace pre_treatment=1 if period==201508 & partnercode==643 | period==201509 & partnercode==643 | period==201510 & partnercode==643 | period==201511 & partnercode==643 | period==201512 & partnercode==643




gen post_treatment_Nov2017=0
replace post_treatment_Nov2017=1 if period==201711 & partnercode==643 | period==201712 & partnercode==643 | period==201801 & partnercode==643 | period==201802 & partnercode==643 | period==201803 & partnercode==643



/*
*creating a dummy which takes 1 if period is between Sukhoi Su-24 shootdown (December (end of November) 2015) and import ban by Russian Government (Jan 2016)*
gen pre_sanction=0
replace pre_sanction=1 if partnercode==643 & period==201512
*/

*egen month_group=group(month)
*egen product=group(commoditycode)



***********************
*                     *
*      CROZET         *
*                     *
***********************
*PPML*
**non-embargoed*
set more off
ppmlhdfe x pre_treatment treatment_Oct2016 treatment_Mar2017 treatment_Jun2017  treatment_Nov2017 post_treatment_Nov2017 partner_m if embargo==0, absorb(period#commoditycode commoditycode#partnercode#month) sep(fe) vce(cluster partnercode#period) keepsing
set more off
outreg2 using "/Users/mac/Dropbox/ugur-cem/results/emb_nonemb_all_ppml.xls", replace ctitle("Non-embargoed" "PPML") se bdec(3) tdec(3) 10pct addstat("Psuedo R2", e(r2_p)) keep(pre_treatment treatment_Oct2016 treatment_Mar2017 treatment_Jun2017  treatment_Nov2017 post_treatment_Nov2017) addtext(Periodxproduct Dummies, yes, PartnerxproductxMonth Dummies, yes) addnote("Robust standard errors clustured by partnerxtime")



** all products**
set more off
ppmlhdfe x pre_treatment treatment_Oct2016 treatment_Mar2017 treatment_Jun2017  treatment_Nov2017 post_treatment_Nov2017 partner_m, absorb(period#commoditycode commoditycode#partnercode#month) sep(fe) vce(cluster partnercode#period) keepsing
outreg2 using "/Users/mac/Dropbox/ugur-cem/results/emb_nonemb_all_ppml.xls", append ctitle("All products" "PPML") se bdec(3) tdec(3) 10pct addstat("Psuedo R2", e(r2_p)) keep(pre_treatment treatment_Oct2016 treatment_Mar2017 treatment_Jun2017  treatment_Nov2017 post_treatment_Nov2017) addtext(Periodxproduct Dummies, yes, PartnerxproductxMonth Dummies, yes) addnote("Robust standard errors clustured by partnerxtime")



** embargoed**
keep if embargo!=0
set more off
ppmlhdfe x pre_treatment treatment_Oct2016 treatment_Mar2017 treatment_Jun2017  treatment_Nov2017 post_treatment_Nov2017 partner_m, absorb(period#commoditycode commoditycode#partnercode#month) sep(fe) vce(cluster partnercode#period) keepsing
outreg2 using "/Users/mac/Dropbox/ugur-cem/results/emb_nonemb_all_ppml.xls", append ctitle("Embargoed" "PPML") se bdec(3) tdec(3) 10pct addstat("Psuedo R2", e(r2_p)) keep(pre_treatment treatment_Oct2016 treatment_Mar2017 treatment_Jun2017  treatment_Nov2017 post_treatment_Nov2017) addtext(Periodxproduct Dummies, yes, PartnerxproductxMonth Dummies, yes) addnote("Robust standard errors clustured by partnerxtime")



*OLS*
**non-embargoed*
set more off
reghdfe asinhx pre_treatment treatment_Oct2016 treatment_Mar2017 treatment_Jun2017  treatment_Nov2017 post_treatment_Nov2017 asinh_pm if embargo==0, absorb(period#commoditycode commoditycode#partnercode#month) vce(cluster partnercode#period)
outreg2 using "/Users/mac/Dropbox/ugur-cem/results/asinh_emb_nonemb_all.xls", replace ctitle("Non-embargoed") se bdec(3) tdec(3) 10pct addstat("F-stat", e(F)) keep(pre_treatment treatment_Oct2016 treatment_Mar2017 treatment_Jun2017  treatment_Nov2017 post_treatment_Nov2017) addtext(Periodxproduct Dummies, yes, PartnerxproductxMonth Dummies, yes) addnote("Robust standard errors clustured by partnerxtime")



** all products**
reghdfe asinhx pre_treatment treatment_Oct2016 treatment_Mar2017 treatment_Jun2017  treatment_Nov2017 post_treatment_Nov2017 asinh_pm, absorb(period#commoditycode commoditycode#partnercode#month) vce(cluster partnercode#period)
outreg2 using "/Users/mac/Dropbox/ugur-cem/results/asinh_emb_nonemb_all.xls", append ctitle("All products") se bdec(3) tdec(3) 10pct addstat("F-stat", e(F)) keep(pre_treatment treatment_Oct2016 treatment_Mar2017 treatment_Jun2017  treatment_Nov2017 post_treatment_Nov2017) addtext(Periodxproduct Dummies, yes, PartnerxproductxMonth Dummies, yes) addnote("Robust standard errors clustured by partnerxtime")



** embargoed**
keep if embargo!=0
set more off
reghdfe asinhx pre_treatment treatment_Oct2016 treatment_Mar2017 treatment_Jun2017  treatment_Nov2017 post_treatment_Nov2017 asinh_pm, absorb(period#commoditycode commoditycode#partnercode#month) vce(cluster partnercode#period)
outreg2 using "/Users/mac/Dropbox/ugur-cem/results/asinh_emb_nonemb_all.xls", append ctitle("Embargoed") se bdec(3) tdec(3) 10pct addstat("F-stat", e(F)) keep(pre_treatment treatment_Oct2016 treatment_Mar2017 treatment_Jun2017  treatment_Nov2017 post_treatment_Nov2017) addtext(Periodxproduct Dummies, yes, PartnerxproductxMonth Dummies, yes) addnote("Robust standard errors clustured by partnerxtime")


 
