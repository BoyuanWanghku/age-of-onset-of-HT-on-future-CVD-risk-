
//weighting

forval i = 0/5 {
di "age_`i'"
use "overall_data temp_v1.dta", clear 

keep if age_c == `i'

logit onset_dm age sex smoking_bl af_before pvd_before amputation_before dementia_before lung_before CTD_before peptic_ulcer_before liver_before cvd_before hemiplegia_before leukemia_before malignant_lymphoma_before cancer_before ht_before ht_drug_b4 lipid_drug_b4 
predict pscore, pr

mmws onset_dm, pscore(pscore) binary nstrata(50) plevel
drop if _support == 0
count if _mmws==.
drop if _mmws==.

save "overall_data_weight`i'_v1.dta", replace
di _N

}


//unweight
forval i = 0/5 {
di "age_`i'"
use "overall_data temp_v1.dta", clear 

keep if age_c == `i'

save "overall_data_unweight`i'_v1.dta", replace
di _N

}


//t2&f1
log using "log/t2.log", replace
//incident rate
forval i = 0/5 {
di "Group_`i'"

quietly use "overall_data_weight`i'_v1.dta", clear 

	foreach outcome in death renal_decline first_esrd first_ckd{
		stset `outcome'_fu_period2, id(patient_pssn) failure(`outcome')
		stptime, per(1000) by(onset_dm)
}
	
}

log close


//figure1
log using "log/figure1.log", replace
//weight
//HR
forval i = 0/5 {
di "Group_`i'"

quietly use "overall_data_weight`i'_v1.dta", clear 

foreach outcome in first_ckd first_ckd death renal_decline first_esrd  first_ckd{

quietly stset `outcome'_fu_period2 [iw=_mmws], id(patient_pssn) failure(`outcome')
quietly stcox i.onset_dm age i.sex i.smoking_bl i.af_before i.pvd_before i.amputation_before i.dementia_before i.lung_before i.CTD_before i.peptic_ulcer_before i.liver_before i.cvd_before i.hemiplegia_before i.leukemia_before i.malignant_lymphoma_before i.cancer_before i.ht_before i.ht_drug_b4 i.lipid_drug_b4
	quietly matrix temp = r(table)
	//matrix list temp
		scalar HRij = temp[1,2]
		scalar Pij = temp[4,2]
		scalar CILij = temp[5,2]
		scalar CIUij = temp[6,2]
		scalar SEij = temp[2,2]
di `i' _col(20) HRij _col(35) CILij _col(50) CIUij _col(65) Pij  _col(80) SEij

}

}


log close


