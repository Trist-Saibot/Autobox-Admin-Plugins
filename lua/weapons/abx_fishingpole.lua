//---------------------------------------
//  Author Info
//---------------------------------------

SWEP.Author        = "Trist Saibot"
SWEP.Category      = "Autobox"
SWEP.Instructions  = ""
SWEP.Spawnable     = true
SWEP.ViewModel     = Model("models/weapons/v_hands.mdl")
SWEP.WorldModel    = ""

//---------------------------------------
//  Properties
//---------------------------------------
SWEP.Primary.ClipSize       = -1
SWEP.Primary.DefaultClip    = -1
SWEP.Primary.Automatic      = false
SWEP.Primary.Ammo           = "none"

SWEP.Secondary.ClipSize	    = -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic    = false
SWEP.Secondary.Ammo         = "none"

SWEP.Casting = false

function SWEP:PrimaryAttack()
	if(!self.Casting)then
		self:SetHoldType("melee")
		timer.Simple(.1,function() self:SetHoldType("pistol") end)
		timer.Simple(.2,function()
			if(IsValid(Bobber))then Bobber:Remove() end
			Bobber = ents.Create("trist_bobber")
			Bobber:SetOwner(self.Owner)
			Bobber:SetPos( self.Owner:GetNWEntity("trist_fishing_pole"):GetAttachment(1).Pos )
			Bobber:SetAngles( self.Owner:EyeAngles()+Angle(0,90,0))
			--self.Bobber:SetParent( self.Owner )
			Bobber:Spawn()
			self.Owner:SetNWEntity("trist_bobber",Bobber)

			local phys = Bobber:GetPhysicsObject()
			if(!IsValid( phys )) then Bobber:Remove() return end
			local vel = self.Owner:GetAimVector()
			vel = vel * 10000
			phys:ApplyForceCenter(vel)

			self.Casting = true
		end)
	else
		if(IsValid(Bobber))then Bobber:Remove() end

		self:SetHoldType("melee")
		timer.Simple(.2,function() self:SetHoldType("pistol") end)
		self.Casting = false
	end

	--[[ Old reference code, ignore this
	if SERVER then
		self:SetNextPrimaryFire( CurTime() + .2 )

		local Forward = self.Owner:EyeAngles():Forward()
		local ent = ents.Create( "trist_letter" )
		if ( IsValid( ent ) ) then
			self.Trist.I = self.Trist.I + 1
			if(self.Trist.I > 6) then
				self.Trist.I = 1
			end
			ent:SetModel("models/sprops/misc/alphanum/alphanum_"..self.Trist.Letters[self.Trist.I]..".mdl")
			ent:SetPos( self.Owner:EyePos() + (self.Owner:GetAimVector() * 16 ) )
			ent:SetAngles( self.Owner:EyeAngles()+Angle(0,90,0))
			ent:Spawn()

			local phys = ent:GetPhysicsObject()
			if(!IsValid( phys )) then ent:Remove() return end
			phys:EnableGravity(false)
			local vel = self.Owner:GetAimVector()
			vel = vel * 20000
			phys:ApplyForceCenter(vel)

			timer.Simple( 2, function() if(IsValid(ent)) then ent:Remove() end end)
		end
	end
	]]--
end

function SWEP:SecondaryAttack()
end
function SWEP:Deploy()
	if SERVER then
		self:GetOwner():SendLua(' hook.Add("CalcView","Trist_FishingRod_ViewSwap",function( ply,pos,angles,fov) local view = {} view.origin = pos-(angles:Forward()*100) view.angles = angles view.fov = fov view.drawviewer = true return view end)')
		--This is really lazy, don't do this lol


		FishingPole = ents.Create("prop_dynamic")
		FishingPole:SetModel("models/abx/Fishing Pole.mdl")
		FishingPole:SetParent(self:GetOwner())
		FishingPole:Fire("setparentattachment", "anim_attachment_RH", 0.01)
		FishingPole:Spawn()
		timer.Simple(.1,function() FishingPole:SetLocalAngles(Angle(0,90,-80)) end)
		--don't ask me why it does this, I have no idea
		self.Owner:SetNWEntity("trist_fishing_pole",FishingPole)


	else

	end
end
function SWEP:Holster()
	if SERVER then
		if(IsValid(FishingPole))then FishingPole:Remove()end
		return true
	else
		hook.Remove("CalcView","Trist_FishingRod_ViewSwap")
	end
end

if CLIENT then
	SWEP.PrintName      = "Fishing Pole"
	SWEP.Slot           = 1
	SWEP.SlotPos        = 1
	SWEP.DrawAmmo       = false
	SWEP.DrawCrosshair	= false
else

	AddCSLuaFile()
	SWEP.Weight         = 5
	SWEP.AutoSwitchTo   = false
	SWEP.AutoSwitchFrom	= false

	function SWEP:Initialize()
		self:SetHoldType("pistol")
	end

	function SWEP:Think()
		if(!IsValid(self.Owner:GetNWEntity("trist_fishing_pole")))then
			FishingPole = ents.Create("prop_dynamic")
			FishingPole:SetModel("models/abx/Fishing Pole.mdl")
			FishingPole:SetParent(self:GetOwner())
			FishingPole:Fire("setparentattachment", "anim_attachment_RH", 0.01)
			FishingPole:Spawn()
			timer.Simple(.1,function() FishingPole:SetLocalAngles(Angle(0,90,-80)) end)
			--don't ask me why it does this, I have no idea
			self.Owner:SetNWEntity("trist_fishing_pole",FishingPole)
		end
	end

	function SWEP:OnRemove()
		if(IsValid(self.Owner:GetNWEntity("trist_fishing_pole")))then self.Owner:GetNWEntity("trist_fishing_pole"):Remove()end
	end

	function SWEP:OwnerChanged()

	end

	function SWEP:OnDrop()
		if(IsValid(self.Owner:GetNWEntity("trist_fishing_pole")))then self.Owner:GetNWEntity("trist_fishing_pole"):Remove()end
	end

end
if CLIENT then
	local rope = Material("cable/rope")
	hook.Add("PostDrawTranslucentRenderables","Draw_Fishing_Lines",function(_isDepth,_isSkybox)
		if _isSkybox then return end
		for _,ply in pairs(player.GetAll()) do
			if (IsValid(ply:GetNWEntity("trist_fishing_pole")) and IsValid(ply:GetNWEntity("trist_bobber"))) then
				render.SetMaterial(rope)
				pos1 = ply:GetNWEntity("trist_fishing_pole"):GetAttachment(1).Pos
				pos2 = ply:GetNWEntity("trist_bobber"):GetPos()

				local segs = 10
				render.StartBeam(segs + 2)
				render.AddBeam(pos1,0.5,0,color_white) --start
				for i = 1,segs do
					local dir = pos2 - pos1 --direction vector between the two points
					local d3 = dir[3] --distance top to bottom
					dir = dir * i / segs --choose distance from start
					dir[3] = dir[3] + i^2 - (segs * i) --adjust it down a little in a curved way
					render.AddBeam(pos1 + dir,0.5,0,color_white) --segment
				end
				render.AddBeam(pos2,0.5,0,color_white) --end
				render.EndBeam()


				--render.DrawBeam(pos1,pos2,.5,0,0,Color(255, 255, 255, 255))
			end
		end
	end)
end