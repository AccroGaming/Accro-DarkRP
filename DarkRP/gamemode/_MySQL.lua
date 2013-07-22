RP_MySQLConfig = {} 


RP_MySQLConfig.EnableMySQL = false -- Set to true if you want to use an external MySQL database, false if you want to use the built in SQLite database (garrysmod/sv.db) of Garry's mod.
RP_MySQLConfig.Host = "127.0.0.1" -- This is the IP address of the MySQL host. Make sure the IP address is correct and in quotation marks (" ")
RP_MySQLConfig.Username = "user" -- This is the username to log in on the MySQL server.
								-- contact the owner of the server about the username and password. Make sure it's in quotation marks! (" ")
RP_MySQLConfig.Password = "password" -- This is the Password to log in on the MySQL server,
									-- Everyone who has access to FTP on the server can read this password.
									-- Make sure you know who to trust. Make sure it's in quotation marks (" ")
RP_MySQLConfig.Database_name = "DarkRP" -- This is the name of the Database on the MySQL server. Contact the MySQL server host to find out what this is
RP_MySQLConfig.Database_port = 3306 -- This is the port of the MySQL server. Again, contact the MySQL server host if you don't know this.


--[[
MANUAL!
HOW TO USE MySQL FOR DARKRP!
Download andyvincent's/Drakehawke's gm_MySQL OO module and read the guide here:
http://www.facepunch.com/showthread.php?t=1220537
]]
