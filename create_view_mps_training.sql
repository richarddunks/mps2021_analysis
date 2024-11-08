DROP VIEW IF EXISTS mps_training;

CREATE VIEW mps_training AS
	SELECT 
	-- control variables
		MPS_Agency,
		MPS_Stratum,
		MPS_Weight,
		MPS_Supervisor,		
		DEM_04R AS c_retire_elg,
		DEM_10R AS c_gender,
		DEM_ERI AS c_race_eth,
		DEM_15R AS c_age,
		DEM_16R AS c_ed_level,
		MSP_18 AS c_fair_org_pay,
	-- independent variables
		MSP_10 AS i_prov_nec_train,
		MSP_11 AS i_prov_opp_growth,
		ENG_13 AS i_given_opp_skills,
	-- dependent variables
		ENG_02 AS d_meaningful_work,
		ENG_04 AS d_recommend_agency,
		ENG_08 AS d_use_job_skills,
		ENG_03 AS d_unit_high_qual_prod,
		MSP_01 AS d_use_wf_eff,
		MSP_07 AS d_retain_best,
		DEM_05b AS d_take_new_roles,
		DEM_05c AS d_take_high_tech_resp,
		DEM_05d AS d_take_super_resp,
		DEM_05f AS d_move_diff_occ,
		DEM_05h AS d_resign_gov
	FROM mps2021; 