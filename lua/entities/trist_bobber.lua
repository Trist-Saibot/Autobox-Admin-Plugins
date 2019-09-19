AddCSLuaFile()

ENT.Base              = "base_gmodentity"
ENT.Category          = "Autobox"
ENT.Type              = "anim"
ENT.PrintName         = "TRIST_BOBBER"
ENT.Author			  = "Trist Saibot"
ENT.Contact			  = ""
ENT.Purpose			  = ""
ENT.Instructions	  = ""
ENT.Spawnable         = false
ENT.Editable          = false
ENT.DisableDuplicator = true
ENT.AdminOnly         = true

function ENT:Initialize()
	self:SetModel("models/abx/Bobber.mdl")

	if ( CLIENT ) then return end

	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)



	local phys = self:GetPhysicsObject()
	if(!IsValid( phys )) then self:Remove() return end
	phys:SetMass(10)
end
hook.Add("PhysgunPickup","trist_notouch_bobber",function(ply,ent)
	if(ent:GetClass()=="TRIST_BOBBER") then return false end
end)
if SERVER then
	ENT.WaterPos = nil
	function ENT:PhysicsUpdate()
		if(self:WaterLevel()>0) then
			local phys = self:GetPhysicsObject()
			if(!IsValid( phys )) then self:Remove() return end
			phys:EnableMotion(false)
			self:SetAngles(Angle(0,0,0))
		end
	end
end
