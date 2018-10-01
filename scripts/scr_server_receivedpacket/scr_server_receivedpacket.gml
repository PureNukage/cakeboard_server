var read_buffer = argument[0]
var socket = argument[1]
var msgid = buffer_read(read_buffer, buffer_u8)

switch (msgid)
{
	case 0:
	#region Starting Connection
		var _totalusers = buffer_read(read_buffer,buffer_u32)
		var _xtotalusers = 8
	
		//Gather List of Names
		var _userlist = ds_list_create()
		var _currentstatuslist = ds_list_create()
		var _currenttextboxlist = ds_list_create()
		var _currenttimelist = ds_list_create()
		var _checkmarklist = ds_list_create()
		var _windowsnamelist = ds_list_create()
		var _adminrightslist = ds_list_create()
		
		ini_open("data.ini")
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
		var xstatus
		for (xstatus=0;xstatus<=5;xstatus++)
		{
			ds_list_insert(_statuslist,xstatus,ini_read_string("statuses",xstatus,0))	
		}
		var _compiledstatuslist = ds_list_write(_statuslist)
	
		////Gather Current Statuses
		//currentstatuslist = ds_list_create()
		//var xcurrentstatus
		//for (xcurrentstatus=0;xcurrentstatus<totalusers;xcurrentstatus++)
		//{
		//	ds_list_insert(currentstatuslist,xcurrentstatus,ini_read_real("status",xcurrentstatus,0))
		//}	
		//compiledcurrentstatuslist = ds_list_write(currentstatuslist)
		
		////Gather Textboxes
		//currenttextboxlist = ds_list_create()
		//var xcurrenttextbox
		//for (xcurrenttextbox = 0;xcurrenttextbox<totalusers;xcurrenttextbox++)
		//{
		//	ds_list_insert(currenttextboxlist,xcurrenttextbox,ini_read_string("textbox",xcurrenttextbox,0))	
		//}
		//compiledtextboxlist = ds_list_write(currenttextboxlist)
		
		////Time
		//currenttimelist = ds_list_create()
		//var xcurrenttime
		//for (xcurrenttime=0;xcurrenttime<totalusers;xcurrenttime++)
		//{
		//	ds_list_insert(currenttimelist,xcurrenttime,ini_read_string("time",xcurrenttime,"0/0/0 0:00"))	
		//}
		//compiledtimelist = ds_list_write(currenttimelist)
		
		////Checkmarks
		//checkmarklist = ds_list_create()
		//var xcurrentcheckmark
		//for(xcurrentcheckmark=0;xcurrentcheckmark<totalusers;xcurrentcheckmark++)
		//{
		//	ds_list_insert(checkmarklist,xcurrentcheckmark,ini_read_real("checkmark",xcurrentcheckmark,0))
		//}
		//compiledcheckmarklist = ds_list_write(checkmarklist)
		
		////Windows Names
		//var _windowsnameslist = ds_list_create()
		
		////Admin Rights
		
		ini_close()
	
		//Sending Total Users
		var buffer_server_totalusers = buffer_create(2048,buffer_grow,1)
		buffer_seek(buffer_server_totalusers,buffer_seek_start,0)
		buffer_write(buffer_server_totalusers,buffer_u8,0)
		buffer_write(buffer_server_totalusers,buffer_u32,_xtotalusers)
		buffer_write(buffer_server_totalusers,buffer_string,_compileduserlist)
		buffer_write(buffer_server_totalusers,buffer_string,_compiledstatuslist)
		buffer_write(buffer_server_totalusers,buffer_string,_compiledcurrentstatuslist)
		buffer_write(buffer_server_totalusers,buffer_string,_compiledtextboxlist)
		buffer_write(buffer_server_totalusers,buffer_string,_compiledtimelist)
		buffer_write(buffer_server_totalusers,buffer_string,_compiledcheckmarklist)
		buffer_write(buffer_server_totalusers,buffer_string,_compiledwindowsnamelist)
		buffer_write(buffer_server_totalusers,buffer_string,_compiledadminrightslist)
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
	
		if xstatus != 5
		{
			//Check for previous status, if they were on burrito don't update time
			ini_open("data.ini")
			var _oldstatus = ini_read_real("status",xstatusid,0)
			if _oldstatus = 5
			{
				time = ini_read_string("time",xstatusid,"")
			}
			else scr_time(xstatusid)
			ini_close()
		}
		else	//Chipotle status, don't change time
		{
			ini_open("data.ini")
			time = ini_read_string("time",xstatusid,"")
			ini_close()
		}
		
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

	break;
	#endregion
	case 3:
	#region Textbox
		var _textboxid, _text, t
		
		_textboxid = buffer_read(read_buffer,buffer_u32)
		_text = buffer_read(read_buffer,buffer_string)
		
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
		var _compiled_list_firstname_ID, _compiled_list_firstname_value, _compiled_list_windowsname_ID,
		_compiled_list_windowsname_value, _compiled_list_admin_ID, _compiled_list_admin_value,
		_list_firstname_ID, _list_firstname_value, _list_windowsname_ID, _list_windowsname_value,
		_list_admin_ID, _list_admin_value, u, _ID, _value
		
		_compiled_list_firstname_ID = buffer_read(read_buffer,buffer_string)
		_compiled_list_firstname_value = buffer_read(read_buffer,buffer_string)
		_compiled_list_windowsname_ID = buffer_read(read_buffer,buffer_string)
		_compiled_list_windowsname_value = buffer_read(read_buffer,buffer_string)
		_compiled_list_admin_ID = buffer_read(read_buffer,buffer_string)
		_compiled_list_admin_value = buffer_read(read_buffer,buffer_string)	
		
		_list_firstname_ID = ds_list_create()
		_list_firstname_value = ds_list_create()
		_list_windowsname_ID = ds_list_create()
		_list_windowsname_value = ds_list_create()
		_list_admin_ID = ds_list_create()
		_list_admin_value = ds_list_create()
		
		ds_list_read(_list_firstname_ID,_compiled_list_firstname_ID)
		ds_list_read(_list_firstname_value,_compiled_list_firstname_value)
		ds_list_read(_list_windowsname_ID,_compiled_list_windowsname_ID)
		ds_list_read(_list_windowsname_value,_compiled_list_windowsname_value)
		ds_list_read(_list_admin_ID,_compiled_list_admin_ID)
		ds_list_read(_list_admin_value,_compiled_list_admin_value)
		
		for(var poop=0;poop<ds_list_size(_list_admin_value);poop++)
		{
			show_debug_message("Admin Value: " + string(ds_list_find_value(_list_admin_value,poop)))	
		}		
		ini_open("data.ini")
		if !ds_list_empty(_list_firstname_ID){
			for (u=0;u<ds_list_size(_list_firstname_ID);u++)
			{
				_ID = ds_list_find_value(_list_firstname_ID,u)
				_value = ds_list_find_value(_list_firstname_value,u)
				
				ini_write_string("names",_ID,_value)
			}
		}
		if !ds_list_empty(_list_windowsname_ID){
			for (u=0;u<ds_list_size(_list_windowsname_ID);u++)
			{
				_ID = ds_list_find_value(_list_windowsname_ID,u)
				_value = ds_list_find_value(_list_windowsname_value,u)
				
				ini_write_string("windowsnames",_ID,_value)
			}
		}
		if !ds_list_empty(_list_admin_ID){
			for (u=0;u<ds_list_size(_list_admin_ID);u++)
			{
				_ID = ds_list_find_value(_list_admin_ID,u)
				_value = ds_list_find_value(_list_admin_value,u)
				
				ini_write_real("adminrights",_ID,_value)
			}
		}
		
		ini_close()
		
		var buffer_server_manageusers = buffer_create(2048,buffer_grow,1)
		
		buffer_seek(buffer_server_manageusers,buffer_seek_start,0)
		buffer_write(buffer_server_manageusers,buffer_u8,8)
		buffer_write(buffer_server_manageusers,buffer_string,_compiled_list_firstname_ID)
		buffer_write(buffer_server_manageusers,buffer_string,_compiled_list_firstname_value)
		buffer_write(buffer_server_manageusers,buffer_string,_compiled_list_windowsname_ID)
		buffer_write(buffer_server_manageusers,buffer_string,_compiled_list_windowsname_value)
		buffer_write(buffer_server_manageusers,buffer_string,_compiled_list_admin_ID)
		buffer_write(buffer_server_manageusers,buffer_string,_compiled_list_admin_value)
		for (var u=0;u<ds_list_size(socketlist);u++)
		{
			var u_thissocket = ds_list_find_value(socketlist,u)
			network_send_packet(u_thissocket,buffer_server_manageusers,buffer_tell(buffer_server_manageusers))
		}
		
		
		
	break;
	#endregion
	case 9:
	#region ManageUsers Add/Remove User
		
		var _ID, _name, _windowsname, _admin, _name_list, i, _totalusers_new, _position
		
		_ID = buffer_read(read_buffer,buffer_u32)
		_name = buffer_read(read_buffer,buffer_string)
		_windowsname = buffer_read(read_buffer,buffer_string)
		_admin = buffer_read(read_buffer,buffer_u32)
		
		_name_list = ds_list_create()
		
		ini_open("data.ini")
		
		if _ID < totalusers						//Removing a User
		{
			
		}
		if _ID = totalusers						//Adding a User
		{
			
			ds_list_copy(_name_list,database_names)
			ds_list_add(_name_list,_name)
			ds_list_sort(_name_list,false)
			_totalusers_new = totalusers++
		
			for (i=0;i<_totalusers_new;i++)
			{
				var loopname = ds_list_find_value(_name_list,i)
				if loopname = _name{	
					_position = i	
					i = _totalusers_new
				}
			}
			
			
				
			
			ds_list_insert(database_names,_position,_name)
			ds_list_insert(database_windowsnames,_position,_windowsname)
			ds_list_insert(database_adminrights,_position,_admin)
			
			ds_list_insert(database_status,_position,0)
			ds_list_insert(database_textbox,_position,"")
			ds_list_insert(database_time,_position,"0/0/0 0:00")
			ds_list_insert(database_checkmark,_position,0)
			
			for(var c=0;c<totalusers;c++)
			{
				for(var i=0;i<totalusers;i++)
				{
					
				}
			}
			
			
			
		}
		
		ini_close()
		
	break;
	#endregion
}