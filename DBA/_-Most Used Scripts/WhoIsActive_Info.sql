EXEC sp_whoisactive
     @sort_order='session_id',
     @get_full_inner_text = 1,
     @get_plans = 1,
     @get_outer_command = 1