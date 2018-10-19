var type_event = ds_map_find_value(async_load,"type")
switch (type_event) 
{
    case network_type_connect:
        // Add client to socket variable
        var socket = ds_map_find_value(async_load,"socket")
        var buffer = ds_map_find_value(async_load,"buffer")
        ds_list_add(socketlist,socket)
    break;
    case network_type_disconnect:
        // Remove client
		show_message("disconnected")
        var socket = ds_map_find_value(async_load,"socket")
        var findsocket = ds_list_find_index(socketlist,socket)
		if findsocket >= 0
		{
			ds_list_delete(socketlist,findsocket)
		}
    break;
    case network_type_data:
        // Handle the data
        var buffer = ds_map_find_value(async_load,"buffer")
        var socket = ds_map_find_value(async_load,"id")
        buffer_seek(buffer,buffer_seek_start,0)
        scr_server_receivedpacket(buffer,socket)
    break;
}

