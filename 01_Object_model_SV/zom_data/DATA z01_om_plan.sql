--// SPDX-License-Identifier: Unlicense
INSERT INTO public.z01_om_plan (group_num,sub_group_num,sub_group_name,func_name,is_enable,group_name) VALUES
	 (1,1,'WBK','zfr_wbk_items',1,'OM'),
     (1,2,'WBK','z01_wbk_items_relations',1,'OM'),
	 (1,3,'WBK','zfr_wbk_hrh_table',1,'OM'),
	 (1,4,'WBK','zfr_wbk_hrh_list',1,'OM'),
	 (1,5,'WBK','zfr_wbk_all',1,'OM'),
	 (1,6,'DSB','zfr_clc_dir_list',1,'OM'),
	 (1,7,'DSB','zfr_clc_rep_hst',0,'OM'),
	 (1,8,'DSB','zfr_dsb_public_link',1,'OM'),
	 (1,9,'DSB','zfr_dsb_list',1,'OM'),
	 (1,10,'DSB','zfr_dsb_all',1,'OM'),
	 (1,11,'WID','zfr_wid_list',1,'OM');
INSERT INTO public.z01_om_plan (group_num,sub_group_num,sub_group_name,func_name,is_enable,group_name) VALUES
	 (1,12,'WID','zfr_wid_conf',0,'OM'),
	 (1,13,'WID','zfr_wid_all',1,'OM'),
	 (1,14,'LNK','zfr_lnk_dsb2wid',1,'OM'),
	 (1,15,'LNK','zfr_lnk_wid2ds',1,'OM'),
	 (1,16,'CON','zfr_con_list',1,'OM'),
	 (1,17,'CON','zfr_con_hist',0,'OM'),
	 (1,18,'DS','zfr_ds_ec2tableid',1,'OM'),
	 (1,19,'DS','zfr_ds_name_alias',1,'OM'),
	 (1,20,'DS','zfr_ds_list',1,'OM'),
	 (1,21,'DS','zfr_ds_server_list',1,'OM');
INSERT INTO public.z01_om_plan (group_num,sub_group_num,sub_group_name,func_name,is_enable,group_name) VALUES
	 (1,22,'DS','zfr_ds_conf',1,'OM'),
	 (1,23,'DS','zfr_ds_fields_list',1,'OM'),
	 (1,24,'DS','zfr_ds_msr_list',1,'OM'),
	 (1,25,'DS','zfr_ds_hrh_table',1,'OM'),
	 (1,26,'DS','zfr_ds_hrh_table_type',1,'OM'),
	 (1,27,'DS','zfr_ds_hrh_list',1,'OM'),
	 (1,28,'DS','zfr_ds_table2parent',1,'OM'),
	 (1,29,'DS','zfr_ds_table2origin',1,'OM'),
	 (1,30,'DS','zfr_ds_table_lineage_for_each',1,'OM'),
	 (1,31,'DS','zfr_ds_table_lineage',1,'OM');
INSERT INTO public.z01_om_plan (group_num,sub_group_num,sub_group_name,func_name,is_enable,group_name) VALUES
	 (1,32,'DS','zfr_ds_upd_state',1,'OM'),
	 (1,33,'DS','zfr_ds_upd_stats',1,'OM'),
	 (1,34,'DS','zfr_ds_upd_struct',1,'OM'),
	 (1,35,'DS','zfr_ds_all',1,'OM'),
	 (1,36,'DS','zfr_ds_cache_table',1,'OM'),
	 (1,37,'PKG','zfr_pkg_list',1,'OM'),
	 (1,38,'UPD','zfr_upd_task_list',1,'OM'),
	 (1,39,'UPD','zfr_upd_sch_table',1,'OM'),
	 (1,40,'UPD','zfr_upd_sch_ds_cron_parse',1,'OM'),
	 (1,41,'UPD','zfr_upd_sch_table_pvt',1,'OM');
INSERT INTO public.z01_om_plan (group_num,sub_group_num,sub_group_name,func_name,is_enable,group_name) VALUES
	 (1,42,'UPD','zfr_upd_sch_table_unpvt',1,'OM'),
	 (1,43,'USR','zfr_usr_status',1,'OM'),
	 (1,44,'RL','zfr_rl_dep_pos_list',1,'OM'),
	 (1,45,'RL','zfr_rl_user2dep_pos',1,'OM'),
	 (1,46,'RL','zfr_rl_user2roles',1,'OM'),
	 (1,47,'PRM','zfr_prm_list_con',1,'OM'),
	 (1,48,'PRM','zfr_prm_list_dsb',1,'OM'),
	 (1,49,'PRS','zfr_prs_list',1,'OM'),
	 (1,50,'WID','zfr_wid_conf',1,'OM'),
	 (1,51,'WID','zfr_wid_all',1,'OM');
INSERT INTO public.z01_om_plan (group_num,sub_group_num,sub_group_name,func_name,is_enable,group_name) VALUES
	 (1,52,'LOG','zfr_log_fre_fr_stat',1,'OM'),
	 (1,53,'LOG','zfr_log_fre_view_stat',1,'OM'),
	 (1,54,'RO','zfr_ent_link_stats',1,'OM');
