-- queries for each of the bivariate analysis

-- Intent to turnover measures
SELECT
  mps_weight,
	(i_prov_nec_train::DECIMAL + i_prov_opp_growth::DECIMAL + i_given_opp_skills::DECIMAL)/3 as i_average, 
	(d_meaningful_work::DECIMAL + d_move_diff_occ::DECIMAL)/2 as d_average
FROM mps_training 
WHERE c_retire_elg = '0' 
	-- independent variables
	AND (i_prov_nec_train != 'D' AND i_prov_nec_train IS NOT NULL)
	AND (i_prov_opp_growth != 'D' AND i_prov_opp_growth IS NOT NULL) 
	AND (i_given_opp_skills != 'D' AND i_given_opp_skills IS NOT NULL)
	-- ITT dependent variables
	AND (d_resign_gov != 'D' AND d_resign_gov IS NOT NULL)
  	AND (d_move_diff_occ != 'D' AND d_move_diff_occ IS NOT NULL);

-- Personal Job Satisfaction
SELECT
  mps_weight,
	(i_prov_nec_train::DECIMAL + i_prov_opp_growth::DECIMAL + i_given_opp_skills::DECIMAL)/3 as i_average,
	(d_meaningful_work::DECIMAL + d_recommend_agency::DECIMAL + d_use_job_skills::DECIMAL)/3 as d_average
FROM mps_training 
WHERE c_retire_elg = '0' 
	-- independent variables
	AND (i_prov_nec_train != 'D' AND i_prov_nec_train IS NOT NULL)
	AND (i_prov_opp_growth != 'D' AND i_prov_opp_growth IS NOT NULL) 
	AND (i_given_opp_skills != 'D' AND i_given_opp_skills IS NOT NULL)
	-- PJS dependent variables
	AND (d_meaningful_work != 'D' AND d_meaningful_work IS NOT NULL)
	AND (d_recommend_agency != 'D' AND d_recommend_agency IS NOT NULL)
	AND (d_use_job_skills != 'D' AND d_use_job_skills IS NOT NULL);

-- Professional Growth Opportunities
SELECT
  mps_weight,
	(i_prov_nec_train::DECIMAL + i_prov_opp_growth::DECIMAL + i_given_opp_skills::DECIMAL)/3 as i_average,
	(d_take_new_roles::DECIMAL + d_take_high_tech_resp::DECIMAL + d_take_super_resp::DECIMAL)/3 as d_average
FROM mps_training 
WHERE c_retire_elg = '0' 
	-- independent variables
	AND (i_prov_nec_train != 'D' AND i_prov_nec_train IS NOT NULL)
	AND (i_prov_opp_growth != 'D' AND i_prov_opp_growth IS NOT NULL) 
	AND (i_given_opp_skills != 'D' AND i_given_opp_skills IS NOT NULL)
	-- dependent variables
	AND (d_take_new_roles != 'D' AND d_take_new_roles IS NOT NULL)
	AND (d_take_high_tech_resp != 'D' AND d_take_high_tech_resp IS NOT NULL)
	AND (d_take_super_resp != 'D' AND d_take_super_resp IS NOT NULL);

-- Agency Satisfaction
SELECT
  mps_weight,
	(i_prov_nec_train::DECIMAL + i_prov_opp_growth::DECIMAL + i_given_opp_skills::DECIMAL)/3 as i_average,
	(d_unit_high_qual_prod::DECIMAL + d_use_wf_eff::DECIMAL + d_retain_best::DECIMAL)/3 as d_average 
FROM mps_training
WHERE c_retire_elg = '0' 
	-- independent variables
	AND (i_prov_nec_train != 'D' AND i_prov_nec_train IS NOT NULL)
	AND (i_prov_opp_growth != 'D' AND i_prov_opp_growth IS NOT NULL) 
	AND (i_given_opp_skills != 'D' AND i_given_opp_skills IS NOT NULL)
	-- dependent variables
	AND (d_unit_high_qual_prod != 'D' AND d_unit_high_qual_prod IS NOT NULL)
	AND (d_use_wf_eff != 'D' AND d_use_wf_eff IS NOT NULL)
	AND (d_retain_best != 'D' AND d_retain_best IS NOT NULL);

-- all together
SELECT
	mps_weight,
	MPS_Agency,
	-- dummy variable for supervisor or executive
	CASE WHEN MPS_Supervisor = 'S' OR MPS_Supervisor = 'X' THEN 1
		ELSE 0 END AS mps_supervisor_dummy,
		CASE WHEN c_gender = '1' THEN 1
		WHEN c_gender = '2' THEN 0
		ELSE NULL END AS is_female,
	c_race_eth::int AS is_minority,
	-- dummy variable for age 39 or less
	CASE 
		WHEN c_age = '4' THEN 0
		WHEN c_age = '1' THEN 1 
		ELSE NULL END AS c_age_dummy,
	CASE WHEN c_ed_level = '5' THEN 1
		WHEN c_ed_level = '3' THEN 0
		WHEN c_ed_level = '1' THEN 0
		ELSE NULL END AS has_masters_plus,
	c_fair_org_pay::int,
	(i_prov_nec_train::DECIMAL + i_prov_opp_growth::DECIMAL + i_given_opp_skills::DECIMAL)/3 as i_average, 
	(d_meaningful_work::DECIMAL + d_move_diff_occ::DECIMAL)/2 as d_itt_avg,
	(d_meaningful_work::DECIMAL + d_recommend_agency::DECIMAL + d_use_job_skills::DECIMAL)/3 as d_pjs_avg,
	(d_take_new_roles::DECIMAL + d_take_high_tech_resp::DECIMAL + d_take_super_resp::DECIMAL)/3 as d_pgo_avg,
	(d_unit_high_qual_prod::DECIMAL + d_use_wf_eff::DECIMAL + d_retain_best::DECIMAL)/3 as d_as_average 
FROM mps_training 
WHERE c_retire_elg = '0' 
	-- control variables
	AND mps_supervisor IS NOT NULL
	AND c_gender IS NOT NULL
	AND c_race_eth IS NOT NULL
	AND c_age IS NOT NULL
	AND c_ed_level IS NOT NULL
	AND (c_fair_org_pay	 != 'D' AND c_fair_org_pay IS NOT NULL)
	-- independent variables
	AND (i_prov_nec_train != 'D' AND i_prov_nec_train IS NOT NULL)
	AND (i_prov_opp_growth != 'D' AND i_prov_opp_growth IS NOT NULL) 
	AND (i_given_opp_skills != 'D' AND i_given_opp_skills IS NOT NULL)
	-- ITT dependent variables
	AND (d_resign_gov != 'D' AND d_resign_gov IS NOT NULL)
  	AND (d_move_diff_occ != 'D' AND d_move_diff_occ IS NOT NULL)
	-- PJS dependent variables
	AND (d_meaningful_work != 'D' AND d_meaningful_work IS NOT NULL)
	AND (d_recommend_agency != 'D' AND d_recommend_agency IS NOT NULL)
	AND (d_use_job_skills != 'D' AND d_use_job_skills IS NOT NULL)
	-- PGO dependent variables
	AND (d_take_new_roles != 'D' AND d_take_new_roles IS NOT NULL)
	AND (d_take_high_tech_resp != 'D' AND d_take_high_tech_resp IS NOT NULL)
	AND (d_take_super_resp != 'D' AND d_take_super_resp IS NOT NULL)
	-- AS dependent variables
	AND (d_unit_high_qual_prod != 'D' AND d_unit_high_qual_prod IS NOT NULL)
	AND (d_use_wf_eff != 'D' AND d_use_wf_eff IS NOT NULL)
	AND (d_retain_best != 'D' AND d_retain_best IS NOT NULL);
