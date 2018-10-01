var i

ini_open("data.ini")

for (i=0;i<500;i++)
{
	if !ini_key_exists("names",i)
	{	
		totalusers = i
		i = 500
	}
}

var array 

array[8] = 0

database_names = ds_list_create()				array[0] = "database_names"
database_windowsnames = ds_list_create()		array[1] = "database_windowsnames"
database_status = ds_list_create()				array[2] = "database_status"
database_statuses = ds_list_create()			array[3] = "database_statuses"
database_textbox = ds_list_create()				array[4] = "database_textbox"
database_time = ds_list_create()				array[5] = "database_time"
database_checkmark = ds_list_create()			array[6] = "database_checkmark"
database_adminrights = ds_list_create()			array[7] = "database_adminrights"

var loops = 8	//Set this equal to the ds_lists above
var c = 0

show_debug_message("totalusers: " + string(totalusers))
for(var c=0;c<loops;c++)
{
for(var b=0;b<totalusers;b++)
{
	var list = array[c]
	var key = string_copy(list,10,string_length(list))
	var database = "database_"+string(key)
	var value_string = ini_read_string(key,b,0)
	var value_real = ini_read_real(key,b,0)
	show_debug_message("key: " + string(key))
	show_debug_message("database: " + string(database))
	show_debug_message("value: " + string(value_string))
	if key = "names" or "windowsnames" or "textbox" or "time"	//String
	{
		ds_list_add(real(database),value_string)
		show_debug_message(string(ds_list_find_value(real(database),b)))
	}
	if key = "status" or "checkmark" or "adminrights" 		//Real
	{
		ds_list_add(real(database),value_real)
		show_debug_message(string(ds_list_find_value(real(database),b)))
	}
	show_debug_message("")
	
}
}


ini_close()