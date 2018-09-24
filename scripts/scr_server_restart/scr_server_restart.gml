restartbuffer = buffer_create(1024,buffer_fixed,1)

var restartmessage, j
restartmessage = ""
restartmessage = get_string(restartmessage,"Server has restarted! Please re-open Cakeboard")

buffer_seek(restartbuffer,buffer_seek_start,0)
buffer_write(restartbuffer,buffer_u8,4)
buffer_write(restartbuffer,buffer_string,restartmessage)
for (j=0;j<ds_list_size(socketlist);j++)
{
	var j_socket = ds_list_find_value(socketlist,j)
	network_send_packet(j_socket,restartbuffer,buffer_tell(restartbuffer))	
}