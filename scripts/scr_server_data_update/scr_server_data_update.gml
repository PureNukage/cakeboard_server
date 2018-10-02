var array

array[totalusers] = 0

if !ini_open("data.ini"){	ini_open("data.ini")	}		//Open data.ini if not already opened

array[0] = "database_names"
array[1] = "database_windowsnames"
array[2] = "database_status"
array[3] = "database_textbox"
array[4] = "database_time"
array[5] = "database_checkmark"
array[6] = "database_adminrights"

var loops = 7		//Set this equal to the ds_lists above
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
		show_debug_message("c: " + string(c))
		show_debug_message("key: " + string(key))
		show_debug_message("database: " + string(database))
		switch(key)
		{
			case "names":
				ds_list_insert(database_names,b,value_string)
			break;
			case "windowsnames":
				ds_list_insert(database_windowsnames,b,value_string)
			break;
			case "textbox":
				ds_list_insert(database_textbox,b,value_string)
			break;
			case "time": 
				ds_list_insert(database_time,b,value_string)
			break;
			case "status":
				ds_list_insert(database_status,b,value_real)
			break;
			case "checkmark":
				ds_list_insert(database_checkmark,b,value_real)
			break;
			case "adminrights":
				ds_list_insert(database_adminrights,b,value_real)
			break;
		}
		show_debug_message("")	
	}
}
