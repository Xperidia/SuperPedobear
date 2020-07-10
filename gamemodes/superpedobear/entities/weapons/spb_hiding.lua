--[[---------------------------------------------------------
		Super Pedobear Gamemode for Garry's Mod
				by VictorienXP (2016-2020)
-----------------------------------------------------------]]

AddCSLuaFile()

SWEP.PrintName	= "Hiding powers"
SWEP.Author		= "Xperidia"
SWEP.Purpose = "Weld props and use power-ups"
if CLIENT then
	SWEP.Instructions = GAMEMODE:CheckBind("+attack") .. " to weld a prop to another\n" .. GAMEMODE:CheckBind("+attack2") .. " to unweld a prop\n" .. GAMEMODE:CheckBind("+reload") .. " to use power-ups"
	SWEP.WepSelectIcon = surface.GetTextureID("superpedobear/weapons/spb_hiding")
end
SWEP.Spawnable	= false

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= true
SWEP.Secondary.Ammo			= "none"

SWEP.Weight				= 9
SWEP.AutoSwitchTo		= true
SWEP.AutoSwitchFrom		= false

SWEP.Slot				= 0
SWEP.SlotPos			= 0
SWEP.DrawAmmo			= false
SWEP.BounceWeaponIcon	= false

SWEP.ViewModel			= Model("models/weapons/c_arms.mdl")
SWEP.WorldModel			= ""
SWEP.ViewModelFOV		= 54
SWEP.UseHands			= true

function SWEP:Initialize()
	self:SetHoldType("normal")
end

function SWEP:PrimaryAttack()

	if SERVER then

		local owner = self:GetOwner()

		local tr = util.GetPlayerTrace(owner)

		local trace = util.TraceLine(tr)

		if not trace.Hit then return end

		if not trace.HitNonWorld then
			self.laste = nil
			owner:SetNWEntity("spb_Welding", owner)
			owner:SetNWInt("spb_WeldingState", 0)
			return
		end

		if IsValid(trace.Entity) and trace.Entity:IsPlayer() then return end

		if trace.HitPos:Distance(trace.StartPos) > 100 then
			owner:SetNWInt("spb_WeldingState", 2)
			return
		end

		if not util.IsValidPhysicsObject(trace.Entity, trace.PhysicsBone) then return end

		local Phys = trace.Entity:GetPhysicsObjectNum(trace.PhysicsBone)

		if not self.laste or not IsValid(self.laste[1]) then
			self.laste = { trace.Entity, trace.HitPos, Phys, trace.PhysicsBone, trace.HitNormal }
		else

			if trace.Entity:GetPos():Distance(self.laste[1]:GetPos()) > 100 then
				owner:SetNWInt("spb_WeldingState", 3)
				return
			end

			local Ent1, Ent2 = self.laste[1], trace.Entity
			local Bone1, Bone2 = self.laste[4], trace.PhysicsBone

			constraint.Weld(Ent1, Ent2, Bone1, Bone2, 2147483647, false, false)

			self.laste = nil

		end

		if self.laste and IsValid(self.laste[1]) then
			owner:SetNWEntity("spb_Welding", self.laste[1])
			owner:SetNWInt("spb_WeldingState", 1)
		else
			owner:SetNWEntity("spb_Welding", owner)
			owner:SetNWInt("spb_WeldingState", 0)
		end

	end

end

function SWEP:SecondaryAttack()
	if SERVER then
		local owner = self:GetOwner()
		self.laste = nil
		owner:SetNWEntity("spb_Welding", owner)
		owner:SetNWInt("spb_WeldingState", 0)
		local tr = util.GetPlayerTrace(owner)
		local trace = util.TraceLine(tr)
		if not trace.Hit then return end
		if not trace.HitNonWorld then return end
		constraint.RemoveConstraints(trace.Entity, "Weld")
	end
end

function SWEP:Reload()
	if SERVER then
		self:GetOwner():UsePowerUP()
	end
end

function SWEP:OnRemove()
	if SERVER then
		local owner = self:GetOwner()
		self.laste = nil
		owner:SetNWEntity("spb_Welding", owner)
		owner:SetNWInt("spb_WeldingState", 0)
	end
end

function SWEP:ShouldDropOnDie()
	return false
end

function SWEP:OnDrop()
	if SERVER then
		local owner = self:GetOwner()
		self.laste = nil
		owner:SetNWEntity("spb_Welding", owner)
		owner:SetNWInt("spb_WeldingState", 0)
	end
	self:Remove()
end
