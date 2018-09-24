var type,port,maxclients
type = network_socket_tcp
port = 64198 //64198
maxclients = 8

server = network_create_server(type,port,maxclients)

var size,type1,alignment
size = 1024
type1 = buffer_wrap
alignment = 1
buffer = buffer_create(size,type1,alignment)

socketlist = ds_list_create()
