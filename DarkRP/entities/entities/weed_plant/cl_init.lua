include("shared.lua")

function ENT:Draw()
	self:DrawModel()
	local Pos = self:GetPos()
	local Ang = self:GetAngles()

	--local owner = self:Getowning_ent()
	--owner = (IsValid(owner) and owner:Nick()) or "Unknown"

	surface.SetFont("HUDNumber5")
	local TextWidth = surface.GetTextSize("Drug Plant")
	--local TextWidth2 = surface.GetTextSize(owner)
	local TextWidth3 = surface.GetTextSize("Done")

	Ang:RotateAroundAxis(Ang:Forward(), 90)
	local TextAng = Ang
	cam.Start3D2D(Pos + Ang:Right() * -30, TextAng, 0.2)
		draw.WordBox(1, -TextWidth*0.5 + 5, -100, "Drug Plant", "HUDNumber5", Color(140, 140, 140, 100), Color(255,255,255,255))
		--draw.WordBox(1, -TextWidth2*0.5 + 5, -14, owner, "HUDNumber5", Color(140, 0, 0, 100), Color(255,255,255,255))
	cam.End3D2D()
	
	if self.Entity:GetNWBool("Usable") == true then
	TextAng:RotateAroundAxis(TextAng:Right(), CurTime()*-150)
	cam.Start3D2D(Pos + Ang:Right() * -30, TextAng, 0.2)
		draw.WordBox(1, -TextWidth3*0.6 + 5, -135, "Done", "HUDNumber5", Color(0, 140, 0, 100), Color(255,255,255,255))
		--draw.WordBox(1, -TextWidth3*0.5 + 5, -14, owner, "HUDNumber5", Color(140, 0, 0, 100), Color(255,255,255,255))
	cam.End3D2D()
	end
	
	
	if self.Entity:GetNWBool("Usable") == true then
		self.Entity:SetColor( Color( 255, 255, 255, 255) )
	else
		self.Entity:SetColor( Color( 255, 255, 255, 255) )
	end
end