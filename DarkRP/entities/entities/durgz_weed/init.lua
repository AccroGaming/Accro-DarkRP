AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.MODEL = "models/katharsmodels/contraband/zak_wiet/zak_wiet.mdl"


ENT.LASTINGEFFECT = 120;


function ENT:High(activator,caller)
	local smoke = EffectData();
	smoke:SetOrigin(activator:EyePos());
	util.Effect("durgz_weed_smoke", smoke);

	activator:SetDSP(6);

	if( math.random(0,10) == 0 )then
		activator:Ignite(5,0)
		self:Say(activator, "FFFFFFUUUUUUUUUUUUUUUUUU")
	else
		local health = activator:Health()
		if( health * 3/2 < 500 )then
			activator:SetHealth( math.floor(health + 5) )
		else
			activator:SetHealth( health + 5 )
		end
		activator:SetGravity(0.2);
		
		local sayings = {
			"does any1 hav goldfish!?1 i want goldfish plz thx",
			"My eyes aren't red. What are you talking about?",
			"duuuuuuuuuuudeeeeeeee",
			"hi how do i type in chat i cant figure it out"
		}
		self:Say( activator, sayings[math.random(1,#sayings)] )
		
	end
end

function ENT:AfterHigh(activator, caller)
end


function ENT:SpawnFunction( ply, tr ) 
   
 	if ( !tr.Hit ) then return end 
 	 
 	local SpawnPos = tr.HitPos + tr.HitNormal * 16 
 	 
 	local ent = ents.Create("durgz_weed") 
 		ent:SetPos( SpawnPos ) 
 	ent:Spawn() 
 	ent:Activate() 
 	 
 	return ent 
 	 
 end 


local function ResetGrav()

	for id,pl in pairs( player.GetAll() )do

		if( pl:GetNetworkedFloat("durgz_weed_high_end") - 0.5 < CurTime() && pl:GetNetworkedFloat("durgz_weed_high_end") > CurTime() )then
			pl:SetGravity(1)
		end
		
	end
	
end
hook.Add("Think", "durgz_weed_resetgrav", ResetGrav)


