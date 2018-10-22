var read_buffer = argument[0]
var socket = argument[1]
var msgid = buffer_read(read_buffer, buffer_u8)

switch (msgid)
{
	case 0:
	#region Starting Connection
		var _windowsname = buffer_read(read_buffer,buffer_string)
		var _ID
		
		ini_open("data.ini")
		
		//Signing in							//Loop through Windowsnames to compare returned Windowsname
		for(var i=0;i<totalusers;i++)
		{
			var _current_windowsname = ini_read_string("windowsnames",i,0)
			if _current_windowsname = _windowsname{
				_ID = i
				i = totalusers
			}
			else _ID = -1
		}
		if totalusers = 0{	_ID = -1	}
	
		//Gather List of Names
		var _userlist = ds_list_create()
		var _currentstatuslist = ds_list_create()
		var _currenttextboxlist = ds_list_create()
		var _currenttimelist = ds_list_create()
		var _checkmarklist = ds_list_create()
		var _windowsnamelist = ds_list_create()
		var _adminrightslist = ds_list_create()
		var _theme = 0
		
		var o
		for (o=0;o<totalusers;o++)
		{
			ds_list_insert(_userlist,o,ini_read_string("names",o,0))
			ds_list_insert(_currentstatuslist,o,ini_read_real("status",o,0))
			ds_list_insert(_currenttextboxlist,o,ini_read_string("textbox",o,0))
			ds_list_insert(_currenttimelist,o,ini_read_string("time",o,"0/0/0 0:00"))
			ds_list_insert(_checkmarklist,o,ini_read_real("checkmark",o,0))
			ds_list_insert(_windowsnamelist,o,ini_read_string("windowsnames",o,0))
			ds_list_insert(_adminrightslist,o,ini_read_real("adminrights",o,0))
		}
		var _compileduserlist = ds_list_write(_userlist)
		var _compiledcurrentstatuslist = ds_list_write(_currentstatuslist)
		var _compiledtextboxlist = ds_list_write(_currenttextboxlist)
		var _compiledtimelist = ds_list_write(_currenttimelist)
		var _compiledcheckmarklist = ds_list_write(_checkmarklist)
		var _compiledwindowsnamelist = ds_list_write(_windowsnamelist)
		var _compiledadminrightslist = ds_list_write(_adminrightslist)
	
		//Gather Total Statuses
		var _statuslist = ds_list_create()
		
		for (var xstatus=0;xstatus<=5;xstatus++)
		{
			ds_list_insert(_statuslist,xstatus,ini_read_string("statuses",xstatus,0))	
		}
		var _compiledstatuslist = ds_list_write(_statuslist)
		
		//Theme
		if _ID != -1{
			_theme = ds_list_find_value(database_themes,_ID)	
		}
		else _theme = 0
		
		//Admin Rights
		
		ini_close()
	
		//Sending Total Users
		var buffer_server_totalusers = buffer_create(2048,buffer_grow,1)
		buffer_seek(buffer_server_totalusers,buffer_seek_start,0)
		buffer_write(buffer_server_totalusers,buffer_u8,0)
		buffer_write(buffer_server_totalusers,buffer_u32,totalusers)
		buffer_write(buffer_server_totalusers,buffer_s16,_ID)
		buffer_write(buffer_server_totalusers,buffer_string,_compileduserlist)
		buffer_write(buffer_server_totalusers,buffer_string,_compiledstatuslist)
		buffer_write(buffer_server_totalusers,buffer_string,_compiledcurrentstatuslist)
		buffer_write(buffer_server_totalusers,buffer_string,_compiledtextboxlist)
		buffer_write(buffer_server_totalusers,buffer_string,_compiledtimelist)
		buffer_write(buffer_server_totalusers,buffer_string,_compiledcheckmarklist)
		buffer_write(buffer_server_totalusers,buffer_string,_compiledwindowsnamelist)
		buffer_write(buffer_server_totalusers,buffer_string,_compiledadminrightslist)
		buffer_write(buffer_server_totalusers,buffer_u32,_theme)
		buffer_write(buffer_server_totalusers,buffer_u32,ds_list_size(socketlist))
		show_debug_message("Socketlist: " + string(ds_list_size(socketlist)))
		network_send_packet(socket,buffer_server_totalusers,buffer_tell(buffer_server_totalusers))
	
	break;
	#endregion
	case 1:
	#region Change Status
		var xstatusid, xstatus, d
		xstatusid = buffer_read(read_buffer,buffer_u32)
		xstatus = buffer_read(read_buffer,buffer_u32)
		
		ds_list_replace(database_status,xstatusid,xstatus)
	
		if xstatus != 5
		{
			//Check for previous status, if they were on burrito don't update time
			ini_open("data.ini")
			var _oldstatus = ini_read_real("status",xstatusid,0)
			if _oldstatus = 5
			{
				time = ini_read_string("time",xstatusid,"")
			}
			else{ 
				scr_time(xstatusid)
				ini_close()
			}
		}
		else	//Chipotle status, don't change time
		{
			ini_open("data.ini")
			time = ini_read_string("time",xstatusid,"")
			ini_close()
		}
		
		ds_list_replace(database_time,xstatusid,time)
		
		ini_open("data.ini")
		ini_write_real("status",xstatusid,xstatus)
		ini_close()
	
		var buffer_server_changestatus = buffer_create(1024,buffer_fixed,1)
		buffer_seek(buffer_server_changestatus,buffer_seek_start,0)
		buffer_write(buffer_server_changestatus,buffer_u8,1)
		buffer_write(buffer_server_changestatus,buffer_u32,xstatusid)
		buffer_write(buffer_server_changestatus,buffer_u32,xstatus)
		buffer_write(buffer_server_changestatus,buffer_string,time)
		for (d=0;d<ds_list_size(socketlist);d++)
		{
			var thissocket = ds_list_find_value(socketlist, d)
			network_send_packet(thissocket,buffer_server_changestatus,buffer_tell(buffer_server_changestatus))
		}
	
	break;
	#endregion
	case 2:
	#region Active Connection
	
		var buffer = buffer_create(1024,buffer_fixed,1)
		buffer_seek(buffer,buffer_seek_start,0)
		buffer_write(buffer,buffer_u8,2)
		network_send_packet(socket,buffer,buffer_tell(buffer))
		
	break;
	#endregion
	case 3:
	#region Textbox
		var _textboxid, _text, t
		
		_textboxid = buffer_read(read_buffer,buffer_u32)
		_text = buffer_read(read_buffer,buffer_string)
		
		ds_list_replace(database_textbox,_textboxid,_text)
		
		ini_open("data.ini")
		ini_write_string("textbox",_textboxid,_text)
		ini_close()
		
		var textboxbuffer = buffer_create(1024,buffer_fixed,1)
		buffer_seek(textboxbuffer,buffer_seek_start,0)
		buffer_write(textboxbuffer,buffer_u8,3)
		buffer_write(textboxbuffer,buffer_u32,_textboxid)
		buffer_write(textboxbuffer,buffer_string,_text)
		for (t=0;t<ds_list_size(socketlist);t++)
		{
			var t_thissocket = ds_list_find_value(socketlist,t)
			network_send_packet(t_thissocket,textboxbuffer,buffer_tell(textboxbuffer))
		}
		
	break;
	#endregion
	case 4:
	
	break;
	case 5:
	#region Dice Roll
	if dicerollcooldown <= 0
	{
		var compiledlist = buffer_read(read_buffer,buffer_string)
		var list = ds_list_create()
		ds_list_read(list,compiledlist)
		var selectedusercount = ds_list_size(list)
		
		randomize()
		var poorsap = ds_list_find_value(list,irandom(selectedusercount))
		show_debug_message("Poorsap: " + string(poorsap))
		var arrowchanges = irandom_range(12,18)
		show_debug_message("Arrow Changes: " + string(arrowchanges))
		var order, i, currentrep, previousrep
		previousrep = 100
		order = ds_list_create()
		
		for (i=0;i<arrowchanges;i++)
		{
			currentrep = ds_list_find_value(list,irandom(selectedusercount))
			while currentrep = previousrep
			{
				show_debug_message("dupe!")
				currentrep = ds_list_find_value(list,irandom(selectedusercount))
			}
			ds_list_insert(order,i,currentrep)
			show_debug_message("DS_List Current Rep: " + string(ds_list_find_value(order,i)))
			previousrep = currentrep
		}
		ds_list_insert(order,arrowchanges,poorsap)
		show_debug_message("DS_List Poor Sap: " + string(ds_list_find_value(order,arrowchanges)))
		var compiled_order = ds_list_write(order)
	
		var dicerollbuffer = buffer_create(1024,buffer_fixed,1)
		buffer_seek(dicerollbuffer,buffer_seek_start,0)
		buffer_write(dicerollbuffer,buffer_u8,5)
		buffer_write(dicerollbuffer,buffer_string,compiled_order)
		for (i=0;i<ds_list_size(socketlist);i++)
		{
			var d_thissocket = ds_list_find_value(socketlist,i)
			network_send_packet(d_thissocket,dicerollbuffer,buffer_tell(dicerollbuffer))
		}
		dicerollcooldown = 300
	}
	else
	{
		var order = ds_list_create()
		ds_list_insert(order,0,"On Cooldown")
		ds_list_insert(order,1,dicerollcooldown)
		var compiled_order = ds_list_write(order)
		var buffer = buffer_create(1024,buffer_fixed,1)
		buffer_seek(buffer,buffer_seek_start,0)
		buffer_write(buffer,buffer_u8,5)
		buffer_write(buffer,buffer_string,compiled_order)
		network_send_packet(socket,buffer,buffer_tell(buffer))
	}
	
	break;
	#endregion
	case 6:
	#region Checkbox
		var selected = buffer_read(read_buffer,buffer_u32)
		var checkID = buffer_read(read_buffer,buffer_u32)
		
		ds_list_replace(database_checkmark,checkID,selected)
		
		ini_open("data.ini")
		ini_write_real("checkmark",checkID,selected)
		ini_close()
		
		var buffer = buffer_create(1024,buffer_fixed,1)
		buffer_write(buffer,buffer_u8,6)
		buffer_write(buffer,buffer_u32,selected)
		buffer_write(buffer,buffer_u32,checkID)
		for (i=0;i<ds_list_size(socketlist);i++)
		{
			var d_thissocket = ds_list_find_value(socketlist,i)
			network_send_packet(d_thissocket,buffer,buffer_tell(buffer))
		}
		
	break;
	#endregion
	case 7:
	#region Update Active Client Count
		var add_or_subtract = buffer_read(read_buffer,buffer_string)
		var number 
		if add_or_subtract = "add"{
			number = 0
		}
		else number = -1
		
		var active_client_buffer = buffer_create(1024,buffer_fixed,1)
		buffer_seek(active_client_buffer,buffer_seek_start,0)
		buffer_write(active_client_buffer,buffer_u8,7)
		buffer_write(active_client_buffer,buffer_u32,ds_list_size(socketlist)+number)
		show_debug_message("updated socketlist: " + string(ds_list_size(socketlist)+number))
		for (var f=0;f<ds_list_size(socketlist);f++)
		{
			var c_thissocket = ds_list_find_value(socketlist,f)
			network_send_packet(c_thissocket,active_client_buffer,buffer_tell(active_client_buffer))
		}
	
	break;
	#endregion
	case 8:
	#region ManageUsers Update
	
		var _ID = buffer_read(read_buffer,buffer_u32)
		var _section = buffer_read(read_buffer,buffer_string)
		
		show_debug_message("ID: " +string(_ID))
		show_debug_message("who: " +string(ds_list_find_value(database_names,_ID)))
		show_debug_message("section: " +string(_section))
		
		ini_open("data.ini")
		var buffer = buffer_create(1024,buffer_fixed,1)
		buffer_seek(buffer,buffer_seek_start,0)
		buffer_write(buffer,buffer_u8,8)
		buffer_write(buffer,buffer_u32,_ID)
		buffer_write(buffer,buffer_string,_section)
		
		switch(_section)	//Which user data is being changed
		{
			case "names":
				var _text = buffer_read(read_buffer,buffer_string)
				ds_list_replace(database_names,_ID,_text)			
				ini_write_string(_section,_ID,_text)
				buffer_write(buffer,buffer_string,_text)
				show_debug_message("new name: " +string(_text))
			break;
			case "windowsnames":
				var _text = buffer_read(read_buffer,buffer_string)
				ds_list_replace(database_windowsnames,_ID,_text)	
				ini_write_string(_section,_ID,_text)
				buffer_write(buffer,buffer_string,_text)
				show_debug_message("new windows name: " +string(_text))
			break;
			case "adminrights":
				var _admin = buffer_read(read_buffer,buffer_u32)
				ds_list_replace(database_adminrights,_ID,_admin)
				ini_write_real(_section,_ID,_admin)
				buffer_write(buffer,buffer_u32,_admin)
				show_debug_message("new admin: " +string(_admin))
			break;
		}
		
		for (var u=0;u<ds_list_size(socketlist);u++)
		{
			var u_thissocket = ds_list_find_value(socketlist,u)
			network_send_packet(u_thissocket,buffer,buffer_tell(buffer))
		}
		show_debug_message("")
		ini_close()

	break;
	#endregion
	case 9:
	#region ManageUsers Add/Remove User
		
		var _ID, _name, _windowsname, _admin, _name_list, i, _totalusers_new, _position
		
		_ID = buffer_read(read_buffer,buffer_u32)
		_name = buffer_read(read_buffer,buffer_string)
		_windowsname = buffer_read(read_buffer,buffer_string)
		_admin = buffer_read(read_buffer,buffer_u32)
		
		show_debug_message("ID: "+string(_ID))
		show_debug_message("Name: "+string(_name))
		show_debug_message("Windowsname: "+string(_windowsname))
		show_debug_message("Admin: "+string(_admin))
		
		_name_list = ds_list_create()
		
		ini_open("data.ini")
		
		if _ID < totalusers						//Removing a User
		{
			ds_list_copy(_name_list,database_names)						//		Loops through the current list of usernames
			for (i=0;i<totalusers;i++)									//		until it finds the name of the person who
			{															//		was selected to be removed
				var loopname = ds_list_find_value(_name_list,i)			//
				if loopname = _name{									//
					var _position = i									//
					i = totalusers										//
				}
			}
			
			var _totalusers_new = totalusers - 1						//		Setting the new number of totalusers for use later
			
			ds_list_delete(database_names,_position)					//		Deleting all of the records of this account
			ds_list_delete(database_windowsnames,_position)				//		in the temporary database
			ds_list_delete(database_status,_position)					//		
			ds_list_delete(database_textbox,_position)					//		
			ds_list_delete(database_time,_position)						//		
			ds_list_delete(database_checkmark,_position)				//		
			ds_list_delete(database_adminrights,_position)				//	
			ds_list_delete(database_themes,_position)
			
			var array 
			array[8] = 0												//		Making a temporary data structure to house
			array[0] = "database_names"									//		all of the names of the temporary database
			array[1] = "database_windowsnames"							//		variable names
			array[2] = "database_status"								//
			array[3] = "database_textbox"								//
			array[4] = "database_time"									//
			array[5] = "database_checkmark"								//
			array[6] = "database_adminrights"							//
			array[7] = "database_themes"
			
			var loops = 8	//This value should be equal to the number of databases above
			
			for(var c=0;c<loops;c++)				//Loop through as many times as there are databases
			{
				for(var i=0;i<totalusers;i++)		//Loop through as many times as there are users in the system 
				{									//This happens once for each database 
					var list = array[c]
					var section = string_copy(list,10,string_length(list))
					show_debug_message("c: "+string(c))
					show_debug_message("i: "+string(i))
					switch(section)
					{
						case "names":
							if i<_totalusers_new{
								ini_write_string(section,i,ds_list_find_value(database_names,i))
								show_debug_message("writing name: "+string(ds_list_find_value(database_names,i)))
							}
							else ini_key_delete(section,i)
						break;
						case "windowsnames":
							if i<_totalusers_new{
								ini_write_string(section,i,ds_list_find_value(database_windowsnames,i))		
								show_debug_message("writing windowsname: "+string(ds_list_find_value(database_windowsnames,i)))
							}
							else ini_key_delete(section,i)
						break;
						case "textbox":
							if i<_totalusers_new{
								ini_write_string(section,i,ds_list_find_value(database_textbox,i))
								show_debug_message("writing textbox: " +string(ds_list_find_value(database_textbox,i)))
							}
							else ini_key_delete(section,i)
						break;
						case "time": 
							if i<_totalusers_new{
								ini_write_string(section,i,ds_list_find_value(database_time,i))
								show_debug_message("writing time: "+string(ds_list_find_value(database_time,i)))
							}
							else ini_key_delete(section,i)
						break;
						case "status":
							if i<_totalusers_new{
								ini_write_real(section,i,ds_list_find_value(database_status,i))
								show_debug_message("writing status: "+string(ds_list_find_value(database_status,i)))
							}
							else ini_key_delete(section,i)
						break;
						case "checkmark":
							if i<_totalusers_new{
								ini_write_real(section,i,ds_list_find_value(database_checkmark,i))
								show_debug_message("writing checkmark: "+string(ds_list_find_value(database_checkmark,i)))
							}
							else ini_key_delete(section,i)
						break;
						case "adminrights":
							if i<_totalusers_new{
								ini_write_real(section,i,ds_list_find_value(database_adminrights,i))
								show_debug_message("writing adminrights: "+string(ds_list_find_value(database_adminrights,i)))
							}
							else ini_key_delete(section,i)
						break;
						case "themes":
							if i<_totalusers_new{
								ini_write_real(section,i,ds_list_find_value(database_themes,i))
							}
							else ini_key_delete(section,i)
						break;
					}
				}
			}	
			
			
		}
		if _ID = totalusers						//Adding a User
		{
			
			ds_list_copy(_name_list,database_names)
			ds_list_add(_name_list,_name)
			ds_list_sort(_name_list,true)
			var _totalusers_new = totalusers + 1
		
			for (i=0;i<_totalusers_new;i++)
			{
				var loopname = ds_list_find_value(_name_list,i)
				if loopname = _name{	
					_position = i	
					i = _totalusers_new
				}
			}
			
			var array 
			array[7] = 0
			array[0] = "database_names"
			array[1] = "database_windowsnames"
			array[2] = "database_status"
			array[3] = "database_textbox"
			array[4] = "database_time"
			array[5] = "database_checkmark"
			array[6] = "database_adminrights"
			array[7] = "database_themes"
			
			show_debug_message("position: " +string(_position))
			
			ds_list_insert(database_names,_position,_name)
			ds_list_insert(database_windowsnames,_position,_windowsname)
			ds_list_insert(database_adminrights,_position,_admin)
			
			ds_list_insert(database_status,_position,0)
			ds_list_insert(database_textbox,_position,"")
			ds_list_insert(database_time,_position,"0/0/0 0:00")
			ds_list_insert(database_checkmark,_position,0)
			ds_list_insert(database_themes,_position,0)
			
			var loops = 8	//This value should be equal to the number of databases above
			
			for(var c=0;c<loops;c++)
			{
				for(var i=0;i<_totalusers_new;i++)
				{
					var list = array[c]
					var section = string_copy(list,10,string_length(list))
					switch(section)
					{
						case "names":
							ini_write_string(section,i,ds_list_find_value(database_names,i))
						break;
						case "windowsnames":
							ini_write_string(section,i,ds_list_find_value(database_windowsnames,i))						
						break;
						case "textbox":
							ini_write_string(section,i,ds_list_find_value(database_textbox,i))
						break;
						case "time": 
							ini_write_string(section,i,ds_list_find_value(database_time,i))
						break;
						case "status":
							ini_write_real(section,i,ds_list_find_value(database_status,i))
						break;
						case "checkmark":
							ini_write_real(section,i,ds_list_find_value(database_checkmark,i))
						break;
						case "adminrights":
							ini_write_real(section,i,ds_list_find_value(database_adminrights,i))
						break;
						case "themes":
							ini_write_real(section,i,ds_list_find_value(database_themes,i))
						break;
					}
				}
			}	
		}
		
		ini_close()
		
		totalusers = _totalusers_new
		
		var _compiled_names = ds_list_write(database_names)
		var _compiled_windowsnames = ds_list_write(database_windowsnames)
		var _compiled_adminrights = ds_list_write(database_adminrights)
		
		var _compiled_status = ds_list_write(database_status)
		var _compiled_textbox = ds_list_write(database_textbox)
		var _compiled_time = ds_list_write(database_time)
		var _compiled_checkmark = ds_list_write(database_checkmark)

		var buffer_updated_users = buffer_create(2048,buffer_grow,1)
		buffer_seek(buffer_updated_users,buffer_seek_start,0)
		buffer_write(buffer_updated_users,buffer_u8,9)
		buffer_write(buffer_updated_users,buffer_u32,_totalusers_new)
		buffer_write(buffer_updated_users,buffer_string,_compiled_names)
		buffer_write(buffer_updated_users,buffer_string,_compiled_windowsnames)
		buffer_write(buffer_updated_users,buffer_string,_compiled_adminrights)
		buffer_write(buffer_updated_users,buffer_string,_compiled_status)
		buffer_write(buffer_updated_users,buffer_string,_compiled_textbox)
		buffer_write(buffer_updated_users,buffer_string,_compiled_time)
		buffer_write(buffer_updated_users,buffer_string,_compiled_checkmark)
		for (var l=0;l<ds_list_size(socketlist);l++)
		{
			var l_socket = ds_list_find_value(socketlist,l)
			network_send_packet(l_socket,buffer_updated_users,buffer_tell(buffer_updated_users))
		}
		
	break;
	#endregion
	case 10:
	#region Updating Theme
	
		var _theme = buffer_read(read_buffer,buffer_u32)
		var _profile = buffer_read(read_buffer,buffer_s16)
		
		ds_list_replace(database_themes,_profile,_theme)
		
		ini_open("data.ini")
		
		ini_write_real("themes",_profile,_theme)
		
		ini_close()
		
	#endregion
	break;
}