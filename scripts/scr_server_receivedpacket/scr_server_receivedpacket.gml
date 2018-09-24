var read_buffer = argument[0]
var socket = argument[1]
var msgid = buffer_read(read_buffer, buffer_u8)

switch (msgid)
{
	case 0:
	//Starting Connection
		var _totalusers = buffer_read(read_buffer, buffer_u32)
		var _xtotalusers = 8
	
		//Gather List of Names
		userlist = ds_list_create()
		ini_open("data.ini")
		var xnames
		for (xnames=0;xnames<totalusers;xnames++)
		{
			ds_list_insert(userlist,xnames,ini_read_string("names",xnames,0))
		}
		compileduserlist = ds_list_write(userlist)
	
		//Gather Total Statuses
		statuslist = ds_list_create()
		var xstatus
		for (xstatus=0;xstatus<=5;xstatus++)
		{
			ds_list_insert(statuslist,xstatus,ini_read_string("statuses",xstatus,0))	
		}
		compiledstatuslist = ds_list_write(statuslist)
	
		//Gather Current Statuses
		currentstatuslist = ds_list_create()
		var xcurrentstatus
		for (xcurrentstatus=0;xcurrentstatus<totalusers;xcurrentstatus++)
		{
			ds_list_insert(currentstatuslist,xcurrentstatus,ini_read_real("status",xcurrentstatus,0))
		}	
		compiledcurrentstatuslist = ds_list_write(currentstatuslist)
		
		//Gather Textboxes
		currenttextboxlist = ds_list_create()
		var xcurrenttextbox
		for (xcurrenttextbox = 0;xcurrenttextbox<totalusers;xcurrenttextbox++)
		{
			ds_list_insert(currenttextboxlist,xcurrenttextbox,ini_read_string("textbox",xcurrenttextbox,0))	
		}
		compiledtextboxlist = ds_list_write(currenttextboxlist)
		
		//Time
		currenttimelist = ds_list_create()
		var xcurrenttime
		for (xcurrenttime=0;xcurrenttime<totalusers;xcurrenttime++)
		{
			ds_list_insert(currenttimelist,xcurrenttime,ini_read_string("time",xcurrenttime,"0/0/0 0:00"))	
			//show_message(ds_list_find_value(currenttimelist,xcurrenttime))
		}
		compiledtimelist = ds_list_write(currenttimelist)
		
		//Checkmarks
		checkmarklist = ds_list_create()
		var xcurrentcheckmark
		for(xcurrentcheckmark=0;xcurrentcheckmark<totalusers;xcurrentcheckmark++)
		{
			ds_list_insert(checkmarklist,xcurrentcheckmark,ini_read_real("checkmark",xcurrentcheckmark,0))
		}
		compiledcheckmarklist = ds_list_write(checkmarklist)
		
		ini_close()
	
		//Sending Total Users
		var buffer_server_totalusers = buffer_create(2048,buffer_fixed,1)
		buffer_seek(buffer_server_totalusers,buffer_seek_start,0)
		buffer_write(buffer_server_totalusers,buffer_u8,0)
		buffer_write(buffer_server_totalusers,buffer_u32,_xtotalusers)
		buffer_write(buffer_server_totalusers,buffer_string,compileduserlist)
		buffer_write(buffer_server_totalusers,buffer_string,compiledstatuslist)
		buffer_write(buffer_server_totalusers,buffer_string,compiledcurrentstatuslist)
		buffer_write(buffer_server_totalusers,buffer_string,compiledtextboxlist)
		buffer_write(buffer_server_totalusers,buffer_string,compiledtimelist)
		buffer_write(buffer_server_totalusers,buffer_string,compiledcheckmarklist)
		network_send_packet(socket,buffer_server_totalusers,buffer_tell(buffer_server_totalusers))
	
	break;
	case 1:
	//Change Status
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
	case 2:
	//Refresh
		var _Rtotalusers, r
		_Rtotalusers = 7
		rcurrentstatuslist = ds_list_create()
		ini_open("data.ini")
		for (r=0;r<=_Rtotalusers;r++)
		{
			ds_list_insert(rcurrentstatuslist,r,ini_read_real("status",r,0))
		}
		ini_close()
		compiledrcurrentstatuslist = ds_list_write(rcurrentstatuslist)
		
		var refresh_buffer = buffer_create(1024,buffer_fixed,1)
		
		buffer_seek(refresh_buffer,buffer_seek_start,0)
		buffer_write(refresh_buffer,buffer_u8,2)
		buffer_write(refresh_buffer,buffer_string,compiledrcurrentstatuslist)
		network_send_packet(socket,refresh_buffer,buffer_tell(refresh_buffer))	
	break;
	case 3:
	//Textbox
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
	case 4:
	
	break;
	case 5:
	//Dice Roll
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
	case 6:
	//Checkbox
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
}