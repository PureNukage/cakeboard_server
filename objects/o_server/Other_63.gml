var msg_id = ds_map_find_value(async_load,"id")
if message = msg_id 
{
	if ds_map_find_value(async_load,"status")
	{
		if ds_map_find_value(async_load,"result") != ""
		{
			scr_server_message(ds_map_find_value(async_load,"result"))
		}	
	}
}