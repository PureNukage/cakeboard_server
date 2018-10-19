var _id = argument[0]



//Hours
var i, b, hour, minute
for (i=0;i<=24;i++)
{
	if current_hour <= 12
	{
		if current_hour = 0{
			hour[current_hour] = 12
		}
		else hour[current_hour] = current_hour
	}
	else
	{
	hour[current_hour] = current_hour-12
	}
	
}
for (b=0;b<=59;b++)
{
	if current_minute >= 10
	{
		minute[current_minute] = current_minute
	}
	else
	{
		minute[current_minute] = "0"+string(current_minute)	
	}
}
time = string(current_month) + "/" + string(current_day) + "/" + string(current_year-2000) + " " + string(hour[current_hour]) + ":" + string(minute[current_minute])

ini_open("data.ini")
ini_write_string("time",_id,time)
ini_close()