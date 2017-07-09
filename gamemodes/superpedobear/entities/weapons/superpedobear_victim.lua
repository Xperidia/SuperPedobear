--[[---------------------------------------------------------------------------
		⚠ This file is a part of the Super Pedobear gamemode ⚠
	⚠ Please do not redistribute any version of it (edited or not)! ⚠
	So please ask me directly or contribute on GitHub if you want something...
-----------------------------------------------------------------------------]]

AddCSLuaFile()

SWEP.PrintName = "Victim"
SWEP.Author = "Xperidia"
SWEP.Spawnable = false

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo		= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= true
SWEP.Secondary.Ammo		= "none"

SWEP.Weight			= 9
SWEP.AutoSwitchTo		= true
SWEP.AutoSwitchFrom		= false

SWEP.Slot			= 0
SWEP.SlotPos			= 0
SWEP.DrawAmmo			= false
SWEP.BounceWeaponIcon = false

SWEP.ViewModel			= "models/weapons/c_arms.mdl"
SWEP.WorldModel			= ""

function SWEP:Initialize()
	self:SetHoldType("normal")
end

function SWEP:PrimaryAttack()

	if SERVER then

		local tr = util.GetPlayerTrace(self.Owner)

		local trace = util.TraceLine(tr)

		if (!trace.Hit) then return end

		if (!trace.HitNonWorld) then
			self.laste = nil
			self.Owner:SetNWEntity("PedoWelding", self.Owner)
			self.Owner:SetNWInt("PedoWeldingState", 0)
			return
		end

		if IsValid(trace.Entity) and trace.Entity:IsPlayer() then return end

		if trace.HitPos:Distance(trace.StartPos) > 100 then
			self.Owner:SetNWInt("PedoWeldingState", 2)
			return
		end

		if !util.IsValidPhysicsObject( trace.Entity, trace.PhysicsBone ) then return end

		local Phys = trace.Entity:GetPhysicsObjectNum( trace.PhysicsBone )

		if !self.laste then
			self.laste = { trace.Entity, trace.HitPos, Phys, trace.PhysicsBone, trace.HitNormal }
		else

			if trace.Entity:GetPos():Distance(self.laste[1]:GetPos()) > 100 then
				self.Owner:SetNWInt("PedoWeldingState", 3)
				return
			end

			local Ent1, Ent2 = self.laste[1], trace.Entity
			local Bone1, Bone2 = self.laste[4], trace.PhysicsBone

			constraint.Weld(Ent1, Ent2, Bone1, Bone2, 2147483647, false, false)

			self.laste = nil

		end

		if self.laste and IsValid(self.laste[1]) then
			self.Owner:SetNWEntity("PedoWelding", self.laste[1])
			self.Owner:SetNWInt("PedoWeldingState", 1)
		else
			self.Owner:SetNWEntity("PedoWelding", self.Owner)
			self.Owner:SetNWInt("PedoWeldingState", 0)
		end

	end

end

function SWEP:SecondaryAttack()
	if SERVER then
		self.laste = nil
		self.Owner:SetNWEntity("PedoWelding", self.Owner)
		self.Owner:SetNWInt("PedoWeldingState", 0)
		local tr = util.GetPlayerTrace(self.Owner)
		local trace = util.TraceLine(tr)
		if (!trace.Hit) then return end
		if (!trace.HitNonWorld) then return end
		constraint.RemoveConstraints(trace.Entity, "Weld")
	end
end

function SWEP:Reload()
	if SERVER then
		self.Owner:UsePowerUP()
	end
end

function SWEP:OnRemove()
	if SERVER then
		self.laste = nil
		self.Owner:SetNWEntity("PedoWelding", self.Owner)
		self.Owner:SetNWInt("PedoWeldingState", 0)
	end
end

function SWEP:ShouldDropOnDie()
	return false
end

function SWEP:OnDrop()
	if SERVER then
		self.laste = nil
		self.Owner:SetNWEntity("PedoWelding", self.Owner)
		self.Owner:SetNWInt("PedoWeldingState", 0)
	end
	self:Remove()
end
