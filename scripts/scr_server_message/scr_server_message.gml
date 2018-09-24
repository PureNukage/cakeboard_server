var _message = argument[0]

var j
var buffer = buffer_create(1024,buffer_fixed,1)
buffer_seek(buffer,buffer_seek_start,0)
buffer_write(buffer,buffer_u8,4)
buffer_write(buffer,buffer_string,_message)
for (j=0;j<ds_list_size(socketlist);j++)
{
	var j_socket = ds_list_find_value(socketlist,j)
	network_send_packet(j_socket,buffer,buffer_tell(buffer))	
}
