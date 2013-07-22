include("shared.lua")

function ENT:Draw()
	self:DrawModel()

	local Pos = self:GetPos()
	local Ang = self:GetAngles()

	local owner = self:Getowning_ent()
	owner = (IsValid(owner) and owner:Nick()) or "Unknown"

	surface.SetFont("HUDNumber5")
	local TextWidth = surface.GetTextSize("Druglab!")
	local TextWidth3 = surface.GetTextSize("Done")
	local TextWidth4 = surface.GetTextSize("Need Oil")

	Ang:RotateAroundAxis(Ang:Forward(), 90)
	local TextAng = Ang

	if self.Entity:GetNWBool("Usable") == true then
	TextAng:RotateAroundAxis(TextAng:Right(), CurTime()*-150)
	cam.Start3D2D(Pos + Ang:Right() * -30, TextAng, 0.2)
		draw.WordBox(1, -TextWidth3*0.6 + 5, -42, "Done", "HUDNumber5", Color(0, 140, 0, 100), Color(255,255,255,255))
	cam.End3D2D()
	end
	
	if self.Entity:GetNWBool("Plantable") == true then
	TextAng:RotateAroundAxis(TextAng:Right(), CurTime()*-150)
	cam.Start3D2D(Pos + Ang:Right() * -30, TextAng, 0.2)
		draw.WordBox(1, -TextWidth4*0.6 + 5, -42, "Need Oil", "HUDNumber5", Color(25, 0, 0, 100), Color(255,255,255,255))
	cam.End3D2D()
	end
	
		
	if self.Entity:GetNWBool("Usable") == true then
		self.Entity:SetColor( Color( 255, 255, 255, 255) )
	else
		self.Entity:SetColor( Color( 255, 255, 255, 255) )
	end
end