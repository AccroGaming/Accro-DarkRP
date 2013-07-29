/*---------------------------------------------------------------------------
HUD ConVars
---------------------------------------------------------------------------*/
local ConVars = {}
local HUDWidth
local HUDHeight

local CUR = "$"

CreateClientConVar("weaponhud", 0, true, false)

local function ReloadConVars()
	ConVars = {
		background = {0,0,0,100},
		Healthbackground = {0,0,0,200},
		Healthforeground = {140,0,0,180},
		HealthText = {255,255,255,200},
		Job1 = {0,0,150,200},
		Job2 = {0,0,0,255},
		salary1 = {0,150,0,200},
		salary2 = {0,0,0,255}
	}

	for name, Colour in pairs(ConVars) do
		ConVars[name] = {}
		for num, rgb in SortedPairs(Colour) do
			local CVar = GetConVar(name..num) or CreateClientConVar(name..num, rgb, true, false)
			table.insert(ConVars[name], CVar:GetInt())

			if not cvars.GetConVarCallbacks(name..num, false) then
				cvars.AddChangeCallback(name..num, function() timer.Simple(0,ReloadConVars) end)
			end
		end
		ConVars[name] = Color(unpack(ConVars[name]))
	end


	HUDWidth = (GetConVar("HudW") or  CreateClientConVar("HudW", 240, true, false)):GetInt()
	HUDHeight = (GetConVar("HudH") or CreateClientConVar("HudH", 115, true, false)):GetInt()

	if not cvars.GetConVarCallbacks("HudW", false) and not cvars.GetConVarCallbacks("HudH", false) then
		cvars.AddChangeCallback("HudW", function() timer.Simple(0,ReloadConVars) end)
		cvars.AddChangeCallback("HudH", function() timer.Simple(0,ReloadConVars) end)
	end
end
ReloadConVars()

local function formatNumber(n)
	n = tonumber(n)
	if (!n) then
		return 0
	end
	if n >= 1e14 then return tostring(n) end
    n = tostring(n)
    sep = sep or ","
    local dp = string.find(n, "%.") or #n+1
	for i=dp-4, 1, -3 do
		n = n:sub(1, i) .. sep .. n:sub(i+1)
    end
    return n
end


local Scrw, Scrh, RelativeX, RelativeY
/*---------------------------------------------------------------------------
HUD Seperate Elements
---------------------------------------------------------------------------*/
local function DrawInfo()
	LocalPlayer().DarkRPVars = LocalPlayer().DarkRPVars or {}
	local Salary = 	LANGUAGE.salary .. CUR .. (LocalPlayer().DarkRPVars.salary or 0)

	local JobWallet =
	LANGUAGE.job .. (LocalPlayer().DarkRPVars.job or "") .. "\n"..
	LANGUAGE.wallet .. CUR .. (formatNumber(LocalPlayer().DarkRPVars.money) or 0)

	local wep = LocalPlayer( ):GetActiveWeapon( );

	if IsValid(wep) and GAMEMODE.Config.weaponhud then
        local name = wep:GetPrintName();
		draw.DrawText("Weapon: "..name, "UiBold", RelativeX + 5, RelativeY - HUDHeight - 18, Color(255, 255, 255, 255), 0)
	end
end

local Page = Material("icon16/page_white_text.png")
local function GunLicense()
	if LocalPlayer().DarkRPVars.HasGunlicense then
		surface.SetMaterial(Page)
		surface.SetDrawColor(255, 255, 255, 255)
		surface.DrawTexturedRect(RelativeX + HUDWidth, ScrH() - 34, 32, 32)
	end
end

local function Agenda()
	local DrawAgenda, AgendaManager = DarkRPAgendas[LocalPlayer():Team()], LocalPlayer():Team()
	if not DrawAgenda then
		for k,v in pairs(DarkRPAgendas) do
			if table.HasValue(v.Listeners or {}, LocalPlayer():Team()) then
				DrawAgenda, AgendaManager = DarkRPAgendas[k], k
				break
			end
		end
	end
	if DrawAgenda then
		draw.RoundedBox(0, 10, 10, 460, 110, Color(0, 0, 0, 155))
		draw.RoundedBox(0, 12, 12, 456, 106, Color(51, 58, 51,100))
		draw.RoundedBox(0, 12, 12, 456, 20, Color(0, 0, 70, 100))

		draw.DrawText(DrawAgenda.Title, "DarkRPHUD1", 30, 12, Color(255,0,0,255),0)

		local AgendaText = ""
		for k,v in pairs(team.GetPlayers(AgendaManager)) do
			if not v.DarkRPVars then continue end
			AgendaText = AgendaText .. (v.DarkRPVars.agenda or "") .. "\n"
		end
		draw.DrawText(string.gsub(string.gsub(AgendaText, "//", "\n"), "\\n", "\n"), "DarkRPHUD1", 30, 35, Color(255,255,255,255),0)
	end
end

local VoiceChatTexture = surface.GetTextureID("voice/icntlk_pl")
local function DrawVoiceChat()
	if LocalPlayer().DRPIsTalking then
		local chbxX, chboxY = chat.GetChatBoxPos()

		local Rotating = math.sin(CurTime()*3)
		local backwards = 0
		if Rotating < 0 then
			Rotating = 1-(1+Rotating)
			backwards = 180
		end
		surface.SetTexture(VoiceChatTexture)
		surface.SetDrawColor(ConVars.Healthforeground)
		surface.DrawTexturedRectRotated(ScrW() - 100, chboxY, Rotating*96, 96, backwards)
	end
end

local function LockDown()
	local chbxX, chboxY = chat.GetChatBoxPos()
	if util.tobool(GetConVarNumber("DarkRP_LockDown")) then
		local cin = (math.sin(CurTime()) + 1) / 2
		local chatBoxSize = math.floor(ScrH() / 4)
		draw.DrawText(LANGUAGE.lockdown_started, "ScoreboardSubtitle", chbxX, chboxY + chatBoxSize, Color(cin * 255, 0, 255 - (cin * 255), 255), TEXT_ALIGN_LEFT)
	end
end

local Arrested = function() end

usermessage.Hook("GotArrested", function(msg)
	local StartArrested = CurTime()
	local ArrestedUntil = msg:ReadFloat()

	Arrested = function()
		if CurTime() - StartArrested <= ArrestedUntil and LocalPlayer().DarkRPVars.Arrested then
		draw.DrawText(string.format(LANGUAGE.youre_arrested, math.ceil(ArrestedUntil - (CurTime() - StartArrested))), "DarkRPHUD1", ScrW()/2, ScrH() - ScrH()/12, Color(255,255,255,255), 1)
		elseif not LocalPlayer().DarkRPVars.Arrested then
			Arrested = function() end
		end
	end
end)

local AdminTell = function() end

usermessage.Hook("AdminTell", function(msg)
	local Message = msg:ReadString()

	AdminTell = function()
		draw.RoundedBox(4, 10, 10, ScrW() - 20, 100, Color(0, 0, 0, 200))
		draw.DrawText(LANGUAGE.listen_up, "GModToolName", ScrW() / 2 + 10, 10, Color(255, 255, 255, 255), 1)
		draw.DrawText(Message, "ChatFont", ScrW() / 2 + 10, 80, Color(200, 30, 30, 255), 1)
	end

	timer.Simple(10, function()
		AdminTell = function() end
	end)
end)

/*---------------------------------------------------------------------------
Drawing the HUD elements such as Health etc.
---------------------------------------------------------------------------*/
name = Material("icon16/world.png")
job = Material("icon16/user_suit.png")
salarr = Material("icon16/money_add.png")
banii = Material("icon16/money_dollar.png")
played = Material("icon16/time.png")
news = Material("icon16/new.png")

local function MyHUD()
		local newtime = string.ToMinutesSeconds(CurTime())
		local ply = LocalPlayer()
		local hp,ar = ply:Health(),ply:Armor()
		local slujba = LocalPlayer().DarkRPVars.job or "ERROR"
		local salar = LocalPlayer().DarkRPVars.salary or "ERROR"
		local bani = LocalPlayer().DarkRPVars.money or "ERROR"
		local hr = LocalPlayer().DarkRPVars.Energy
	LocalPlayer().DarkRPVars = LocalPlayer().DarkRPVars or {}
	LocalPlayer().DarkRPVars.Energy = LocalPlayer().DarkRPVars.Energy or 0
	
if (ply:Alive()) then
	draw.RoundedBox(14,5,ScrH() - 162,335,155,Color(0,0,0,200))
	
		surface.SetMaterial(name)
	surface.SetDrawColor(255,255,255,255)
	surface.DrawTexturedRect(10,ScrH() - 150,16,16)
	draw.SimpleText("Name: "..ply:Nick(),"TargetID",30,ScrH() - 150)
	
		surface.SetMaterial(job)
	surface.SetDrawColor(255,255,255,255)
	surface.DrawTexturedRect(10,ScrH() - 130,16,16)
	draw.SimpleText("Job: "..slujba,"TargetID",30,ScrH() - 130)
	
		surface.SetMaterial(salarr)
	surface.SetDrawColor(255,255,255,255)
	surface.DrawTexturedRect(10,ScrH() - 110,16,16)
	draw.SimpleText("Salary: $"..salar,"TargetID",30,ScrH() - 110)
	
			surface.SetMaterial(banii)
	surface.SetDrawColor(255,255,255,255)
	surface.DrawTexturedRect(10,ScrH() - 90,16,16)
	draw.SimpleText("Wallet: $"..bani,"TargetID",30,ScrH() - 90)
	
			surface.SetMaterial(banii)
	surface.SetDrawColor(255,255,255,255)
	draw.SimpleText("Steam ID: ","Chatfont",10,ScrH() - 54)
	
			surface.SetMaterial(banii)
	surface.SetDrawColor(255,255,255,255)
	draw.SimpleText(""..ply:SteamID(),"Chatfont",80,ScrH() - 54, Color(162,162,162,255))
	
			surface.SetMaterial(banii)
	surface.SetDrawColor(255,255,255,255)
	draw.SimpleText("Ping: "..ply:Ping(),"Chatfont",10,ScrH() - 70)
	
	draw.RoundedBox(0,10,ScrH() - 35,150,20,Color(0,0,0,200))
	draw.RoundedBox(0,12,ScrH() - 33,math.Clamp(hp,0,100)*1.46,16,Color(127,0,0,200))
	draw.SimpleText("Health: "..hp,"TargetID",46,ScrH() - 33)
	
	if (ar > 0) then
	draw.RoundedBox(0,180,ScrH() - 35,150,20,Color(0,0,0,200))
	draw.RoundedBox(0,182,ScrH() - 33,math.Clamp(ar,0,100)*1.46,16,Color(0,148,255,200))
	draw.SimpleText("Armor: "..ar,"TargetID",210,ScrH() - 33)
	end
	
	
return
false
end
end

local function DrawHUD()
	Scrw, Scrh = ScrW(), ScrH()
	RelativeX, RelativeY = 0, Scrh
	
	MyHUD()
	DrawInfo()
	GunLicense()
	Agenda()
	DrawVoiceChat()
	LockDown()
	Arrested()
	AdminTell()
end

/*---------------------------------------------------------------------------
Entity HUDPaint things
---------------------------------------------------------------------------*/
local function DrawPlayerInfo(ply)
	local pos = ply:EyePos()

	pos.z = pos.z + 10 -- The position we want is a bit above the position of the eyes
	pos = pos:ToScreen()
	pos.y = pos.y - 50 -- Move the text up a few pixels to compensate for the height of the text

	if GAMEMODE.Config.showname and not ply.DarkRPVars.wanted then
		draw.DrawText(ply:Nick(), "DarkRPHUD2", pos.x + 1, pos.y + 1, Color(0, 0, 0, 255), 1)
		draw.DrawText(ply:Nick(), "DarkRPHUD2", pos.x, pos.y, team.GetColor(ply:Team()), 1)
		draw.DrawText(LANGUAGE.health ..ply:Health(), "DarkRPHUD2", pos.x + 1, pos.y + 21, Color(0, 0, 0, 255), 1)
		draw.DrawText(LANGUAGE.health..ply:Health(), "DarkRPHUD2", pos.x, pos.y + 20, Color(255,255,255,200), 1)
	end

	if GAMEMODE.Config.showjob then
		local teamname = team.GetName(ply:Team())
		draw.DrawText(ply.DarkRPVars.job or teamname, "DarkRPHUD2", pos.x + 1, pos.y + 41, Color(0, 0, 0, 255), 1)
		draw.DrawText(ply.DarkRPVars.job or teamname, "DarkRPHUD2", pos.x, pos.y + 40, Color(255, 255, 255, 200), 1)
	end

	if ply.DarkRPVars.HasGunlicense then
		surface.SetMaterial(Page)
		surface.SetDrawColor(255,255,255,255)
		surface.DrawTexturedRect(pos.x-16, pos.y + 60, 32, 32)
	end
end

local function DrawWantedInfo(ply)
	if not ply:Alive() then return end

	local pos = ply:EyePos()
	if not pos:RPIsInSight({LocalPlayer(), ply}) then return end

	pos.z = pos.z + 14
	pos = pos:ToScreen()

	if GAMEMODE.Config.showname then
		draw.DrawText(ply:Nick(), "DarkRPHUD2", pos.x + 1, pos.y + 1, Color(0, 0, 0, 255), 1)
		draw.DrawText(ply:Nick(), "DarkRPHUD2", pos.x, pos.y, team.GetColor(ply:Team()), 1)
	end

	draw.DrawText(LANGUAGE.wanted.."\nReason: "..tostring(ply.DarkRPVars["wantedReason"]), "DarkRPHUD2", pos.x, pos.y - 40, Color(255, 255, 255, 200), 1)
	draw.DrawText(LANGUAGE.wanted.."\nReason: "..tostring(ply.DarkRPVars["wantedReason"]), "DarkRPHUD2", pos.x + 1, pos.y - 41, Color(255, 0, 0, 255), 1)
end

-------- Door Hud Start --------




hook.Add("PostDrawOpaqueRenderables", "PaintHook", function()
	local tr = LocalPlayer():GetEyeTrace()
	local Pos = tr.Entity:GetPos()
	local GetAngles = tr.Entity:GetAngles()
	local DoorClass = tr.Entity:GetClass()
	local text1 = "Owned by:"
	local text2 = tr.Entity:GetNWInt("OwnerOfDoor")
	local text3 = "Health ".. tr.Entity:GetNWInt("OwnerOfDoorHealth") .."%"
	local text3info = tr.Entity:GetNWInt("OwnerOfDoorHealth")
	local text4 = "Door is broken. Contact Locksmith"
	
	surface.SetFont("DarkRPHUD2")
	local TextWidth2 = surface.GetTextSize(tr.Entity:GetNWInt("OwnerOfDoor"))
	local TextWidth3 = surface.GetTextSize("Health ".. tr.Entity:GetNWInt("OwnerOfDoorHealth") .."%")
	local TextWidth4 = surface.GetTextSize("Door is broken. Contact Locksmith")
	
	local text = tr.Entity:GetNWInt("OwnerOfDoor")
	
	if DoorClass == "prop_door_rotating" then
		GetAngles:RotateAroundAxis(GetAngles:Up(), 270)
		local TextAng = GetAngles
		TextAng:RotateAroundAxis(TextAng:Forward() * 1, 90)
		cam.Start3D2D(Pos + GetAngles:Up() * 1.25, TextAng, 0.1)
			draw.RoundedBox(4, -400, -200, 345, 145, Color(0, 0, 0, 200))	
			draw.RoundedBox(4, -390, -115, 325, 50, Color(0, 0, 0, 125))
			draw.WordBox(2, -275, -180, text1, "DarkRPHUD2", Color(0, 0, 0, 0), Color(255,255,255,255))
			draw.WordBox(2, (-232) -TextWidth2*0.5, -150, text2, "DarkRPHUD2", Color(0, 0, 0, 0), Color(255,255,255,255))
			if(tr.Entity:GetNWInt("OwnerOfDoorHealth") > 0)then
				draw.RoundedBox(4, -385, -110, 315 * text3info / 100, 40, Color(0, 127, 31, 200))
				draw.WordBox(2, (-232) -TextWidth3*0.5, -102, text3, "DarkRPHUD2", Color(0, 0, 0, 0), Color(255,255,255,255))
			else
				draw.RoundedBox(4, -385, -110, 315, 40, Color(217, 0, 0, 200))
				draw.WordBox(2, (-232) -TextWidth4*0.5, -102, text4, "DarkRPHUD2", Color(0, 0, 0, 0), Color(255,255,255,255))
			end
		cam.End3D2D()
		
		GetAngles:RotateAroundAxis(GetAngles:Right(), 180)
		local TextAng = GetAngles
		TextAng:RotateAroundAxis(TextAng:Forward() * 1, 0)
		cam.Start3D2D(Pos + GetAngles:Up() * 1.25, TextAng, 0.1)
			draw.RoundedBox(4, 55, -200, 345, 145, Color(0, 0, 0, 200))	
			draw.RoundedBox(4, 65, -115, 325, 50, Color(0, 0, 0, 125))
			draw.WordBox(2, (227) -TextWidth2*0.5, -150, text2, "DarkRPHUD2", Color(0, 0, 0, 0), Color(255,255,255,255))
			draw.WordBox(2, 185, -180, text1, "DarkRPHUD2", Color(0, 0, 0, 0), Color(255,255,255,255))
			
			if(tr.Entity:GetNWInt("OwnerOfDoorHealth") > 0)then
				draw.RoundedBox(4, 70, -110, 315 * text3info / 100, 40, Color(0, 127, 31, 200))
				draw.WordBox(2, (227) -TextWidth3*0.5, -102, text3, "DarkRPHUD2", Color(0, 0, 0, 0), Color(255,255,255,255))
			else
				draw.RoundedBox(4, 70, -110, 315, 40, Color(217, 0, 0, 200))
				draw.WordBox(2, (227) -TextWidth4*0.5, -102, text4, "DarkRPHUD2", Color(0, 0, 0, 0), Color(255,255,255,255))
			end
		cam.End3D2D()
	end
	
		 ---1st Line---
local Pos1 = Vector(-2690,-790,135)
local Pos5 = Vector(-110, 414, 105)
local Pos9 = Vector(325, 4218, 55)
local Pos13 = Vector(2645, -2443, 95)
local Pos17 = Vector(180, -623, 85)
local Text5 = "Welcome to Accro-Gaming"


    ---2nd Line---
local Pos2 = Vector(-2715,-790,120)
local Pos6 = Vector(-87, 414, 90)
local Pos10 = Vector(300, 4218, 40)
local Pos14 = Vector(2670, -2443, 80)
local Pos18 = Vector(155, -623, 70)
local Text6 = "Sign up on our forum for more benefits"

    ---3th Line---
local Pos3 = Vector(-2685,-790,105)
local Pos7 = Vector(-117, 414, 75)
local Pos11 = Vector(330, 4218, 25)
local Pos15 = Vector(2640, -2443, 65)
local Pos19 = Vector(185, -623, 55)
local Text7 = "www.accro-gaming.com"

     ---4th line---
local Pos4 = Vector(-2660,-790,90)
local Pos8 = Vector(-145, 414, 60)
local Pos12 = Vector(355, 4218, 10)
local Pos16 = Vector(2615, -2443, 50)
local Pos20 = Vector(210, -623, 40)
local Text8 = "- The staff"

    --- Fonts---
local Font = "DarkRPHUD2"
local Font1 = "DarkRPHUD2"


     
	 ---Angles---
local Ang = Angle(0,0,90)
local Ang2 = Angle(0,180,90)


    ---Box---
local TextWidth = surface.GetTextSize(""..Text5)

	---Line 1---
	cam.Start3D2D(Pos1, Ang, 0.5)
	draw.WordBox(2, -TextWidth*0.5, -30, Text5, Font, Color(0, 100, 200, 100), Color(255,255,255,255))
	cam.End3D2D()
	
	cam.Start3D2D(Pos5, Ang2, 0.5)
	draw.WordBox(2, -TextWidth*0.5, -30, Text5, Font, Color(0, 100, 200, 100), Color(255,255,255,255))
	cam.End3D2D()
	
	cam.Start3D2D(Pos9, Ang, 0.5)
	draw.WordBox(2, -TextWidth*0.5, -30, Text5, Font, Color(0, 100, 200, 100), Color(255,255,255,255))
	cam.End3D2D()
	
	cam.Start3D2D(Pos13, Ang2, 0.5)
	draw.WordBox(2, -TextWidth*0.5, -30, Text5, Font, Color(0, 100, 200, 100), Color(255,255,255,255))
	cam.End3D2D()
	
	cam.Start3D2D(Pos17, Ang, 0.5)
	draw.WordBox(2, -TextWidth*0.5, -30, Text5, Font, Color(0, 100, 200, 100), Color(255,255,255,255))
	cam.End3D2D()
	
	---Line 2---
	cam.Start3D2D(Pos2, Ang, 0.5)	
	draw.WordBox(2, -TextWidth*0.5, -30, Text6, Font1, Color(0, 100, 200, 100), Color(255,255,255,255))
	cam.End3D2D()
	
	cam.Start3D2D(Pos6, Ang2, 0.5)	
	draw.WordBox(2, -TextWidth*0.5, -30, Text6, Font1, Color(0, 100, 200, 100), Color(255,255,255,255))
	cam.End3D2D()
	
	cam.Start3D2D(Pos10, Ang, 0.5)
	draw.WordBox(2, -TextWidth*0.5, -30, Text6, Font1, Color(0, 100, 200, 100), Color(255,255,255,255))
	cam.End3D2D()
	
	cam.Start3D2D(Pos14, Ang2, 0.5)	
	draw.WordBox(2, -TextWidth*0.5, -30, Text6, Font1, Color(0, 100, 200, 100), Color(255,255,255,255))
	cam.End3D2D()
	
	cam.Start3D2D(Pos18, Ang, 0.5)	
	draw.WordBox(2, -TextWidth*0.5, -30, Text6, Font1, Color(0, 100, 200, 100), Color(255,255,255,255))
	cam.End3D2D()
	
	---Line 3---
	cam.Start3D2D(Pos3, Ang, 0.5)	
	draw.WordBox(2, -TextWidth*0.5, -30, Text7, Font1, Color(0, 100, 200, 100), Color(255,255,255,255))
	cam.End3D2D()
	
	cam.Start3D2D(Pos7, Ang2, 0.5)	
	draw.WordBox(2, -TextWidth*0.5, -30, Text7, Font1, Color(0, 100, 200, 100), Color(255,255,255,255))
	cam.End3D2D()
	
	cam.Start3D2D(Pos11, Ang, 0.5)	
	draw.WordBox(2, -TextWidth*0.5, -30, Text7, Font1, Color(0, 100, 200, 100), Color(255,255,255,255))
	cam.End3D2D()
	
	cam.Start3D2D(Pos15, Ang2, 0.5)	
	draw.WordBox(2, -TextWidth*0.5, -30, Text7, Font1, Color(0, 100, 200, 100), Color(255,255,255,255))
	cam.End3D2D()
	
	cam.Start3D2D(Pos19, Ang, 0.5)	
	draw.WordBox(2, -TextWidth*0.5, -30, Text7, Font1, Color(0, 100, 200, 100), Color(255,255,255,255))
	cam.End3D2D()
	
	---Line 4---
	cam.Start3D2D(Pos4, Ang, 0.5)	
	draw.WordBox(2, -TextWidth*0.5, -30, Text8, Font1, Color(0, 100, 200, 100), Color(255,255,255,255))
	cam.End3D2D()
	
	cam.Start3D2D(Pos8, Ang2, 0.5)	
	draw.WordBox(2, -TextWidth*0.5, -30, Text8, Font1, Color(0, 100, 200, 100), Color(255,255,255,255))
	cam.End3D2D()
	
	cam.Start3D2D(Pos12, Ang, 0.5)	
	draw.WordBox(2, -TextWidth*0.5, -30, Text8, Font1, Color(0, 100, 200, 100), Color(255,255,255,255))
	cam.End3D2D()
	
	cam.Start3D2D(Pos16, Ang2, 0.5)	
	draw.WordBox(2, -TextWidth*0.5, -30, Text8, Font1, Color(0, 100, 200, 100), Color(255,255,255,255))
	cam.End3D2D()
	
	cam.Start3D2D(Pos20, Ang, 0.5)	
	draw.WordBox(2, -TextWidth*0.5, -30, Text8, Font1, Color(0, 100, 200, 100), Color(255,255,255,255))
	cam.End3D2D()
	
	
end)

-------- Door Hud End --------

/*---------------------------------------------------------------------------
The Entity display: draw HUD information about entities
---------------------------------------------------------------------------*/
local function DrawEntityDisplay()
	local shootPos = LocalPlayer():GetShootPos()
	local aimVec = LocalPlayer():GetAimVector()

	for k, ply in pairs(player.GetAll()) do
		if not ply:Alive() then continue end
		local hisPos = ply:GetShootPos()

		ply.DarkRPVars = ply.DarkRPVars or {}
		if ply.DarkRPVars.wanted then DrawWantedInfo(ply) end

		if GAMEMODE.Config.globalshow and ply ~= LocalPlayer() then
			DrawPlayerInfo(ply)
		-- Draw when you're (almost) looking at him
		elseif not GAMEMODE.Config.globalshow and hisPos:Distance(shootPos) < 400 then
			local pos = hisPos - shootPos
			local unitPos = pos:GetNormalized()
			if unitPos:Dot(aimVec) > 0.95 then
				local trace = util.QuickTrace(shootPos, pos, LocalPlayer())
				if trace.Hit and trace.Entity ~= ply then return end
				DrawPlayerInfo(ply)
			end
		end
	end

	local tr = LocalPlayer():GetEyeTrace()

	if tr.Entity:IsOwnable() and tr.Entity:GetPos():Distance(LocalPlayer():GetPos()) < 200 then
		tr.Entity:DrawOwnableInfo()
	end
end

/*---------------------------------------------------------------------------
Zombie display
---------------------------------------------------------------------------*/
local function DrawZombieInfo()
	if not LocalPlayer().DarkRPVars.zombieToggle then return end
	for x=1, LocalPlayer().DarkRPVars.numPoints, 1 do
		local zPoint = LocalPlayer().DarkRPVars["zPoints".. x]
		if zPoint then
			zPoint = zPoint:ToScreen()
			draw.DrawText("Zombie Spawn (" .. x .. ")", "DarkRPHUD2", zPoint.x, zPoint.y - 20, Color(255, 255, 255, 200), 1)
			draw.DrawText("Zombie Spawn (" .. x .. ")", "DarkRPHUD2", zPoint.x + 1, zPoint.y - 21, Color(255, 0, 0, 255), 1)
		end
	end
end

/*---------------------------------------------------------------------------
Actual HUDPaint hook
---------------------------------------------------------------------------*/
function GM:HUDPaint()
	DrawHUD()
	DrawZombieInfo()
	DrawEntityDisplay()

	self.BaseClass:HUDPaint()
end
/*---------------------------------------------------------------------------
Draw dat cuztom shita! -Shriio!?!,-
setpos 154.426468 -709.757568 18.397545;setang 19.712179 30.900398 0.000000
---------------------------------------------------------------------------*/

function DrawWorldHud()
	cam.Start3D2D( Vector(-2890, -1450, -140), Angle(0, 0, 0), 1 )
		draw.WordBox(0, 0, 0, "test", "HUDNumber5", Color(0, 0, 0, 0), Color(255,255,255,255))
		draw.RoundedBox(50222, -50222, -50222, 50222, 50222, Color(140, 0, 0, 100)) -- Draw Background Bar - health
	cam.End3D2D()
end
concommand.Add("drawworldhud", DrawWorldHud)
