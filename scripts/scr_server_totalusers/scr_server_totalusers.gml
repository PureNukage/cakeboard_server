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

ini_close()