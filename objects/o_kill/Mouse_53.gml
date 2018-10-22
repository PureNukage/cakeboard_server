if mouseover{
	with o_server{
		var buffer = buffer_create(1024,buffer_fixed,1)
		buffer_seek(buffer,buffer_seek_start,0)
		buffer_write(buffer,buffer_u8,66)
		for(var i=0;i<ds_list_size(socketlist);i++)
		{
			var k_socket = ds_list_find_value(socketlist,i)
			network_send_packet(k_socket,buffer,buffer_tell(buffer))
		}
	}
}	