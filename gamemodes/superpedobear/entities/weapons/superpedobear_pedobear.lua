--[[---------------------------------------------------------------------------
		⚠ This file is a part of the Super Pedobear source code ⚠
		⚠ Please do not clone, redistribute or modify the code! ⚠
	We do not obscurate the code or anything mostly to help bug reporting.
	Please do not try to cheat, if you want something ask me directly...
We're just indies making stuff so please support us instead of putting us down.
So unless you're modifying it to improve it via a Pull request please do not.
-----------------------------------------------------------------------------]]

AddCSLuaFile()

SWEP.PrintName = "Pedobear"
SWEP.Author = "Xperidia"
SWEP.Spawnable = false

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo		= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo		= "none"

SWEP.Weight			= 10
SWEP.AutoSwitchTo		= true
SWEP.AutoSwitchFrom		= false

SWEP.Slot			= 0
SWEP.SlotPos			= 0
SWEP.DrawAmmo			= false
SWEP.BounceWeaponIcon = false

SWEP.ViewModel			= "models/weapons/c_arms.mdl"
SWEP.WorldModel			= ""

function SWEP:Initialize()
	self:SetHoldType("duel")
end

function SWEP:PrimaryAttack()
	if !self.lasttime or self.lasttime + 1 < CurTime() then
		local tr = util.GetPlayerTrace(self.Owner)
		local trace = util.TraceLine(tr)
		if !trace.Hit then return end
		if !trace.HitNonWorld then return end
		if IsValid(trace.Entity) and trace.Entity:IsPlayer() then return end
		if SERVER then
			constraint.RemoveConstraints(trace.Entity, "Weld")
			self:GangBang(trace.Entity, self.Owner)
		end
		self.lasttime = CurTime()
	end
end

function SWEP:SecondaryAttack()
end

function SWEP:OnRemove()
end

function SWEP:ShouldDropOnDie()
	return false
end

function SWEP:OnDrop()
	self:Remove()
end

function SWEP:GangBang(ent, attacker)
	local d = DamageInfo()
	d:SetDamage(2147483647)
	d:SetDamageType(DMG_DIRECT)
	d:SetAttacker(attacker)
	d:SetDamageForce(attacker:EyeAngles():Forward() * 10 ^ 8)
	d:SetDamagePosition(attacker:GetPos())
	d:SetMaxDamage(2147483647)
	if IsValid(ent) and ent:Health() > 0 then ent:TakeDamageInfo(d) end
end

function SWEP:Think()
	if SERVER and GAMEMODE.Vars.Round.Start then
		local attacker = self.Owner
		for k, v in pairs (ents.FindInSphere(self.Owner:GetPos(), 26)) do
			if IsValid(v) and ((v:IsPlayer() and v:Alive() and v:Team() == TEAM_VICTIMS and v != self.Owner) or v:GetClass() == "superpedobear_dummy") and v:Health() > 0 then
				if !IsValid(attacker) then attacker = self end
				self:GangBang(v, attacker)
			end
		end
		for k, v in pairs (ents.FindInSphere(self.Owner:GetPos() + (self.Owner:GetViewOffset() or Vector(0,0,32)), 26)) do
			if IsValid(v) and ((v:IsPlayer() and v:Alive() and v:Team() == TEAM_VICTIMS and v != self.Owner) or v:GetClass() == "superpedobear_dummy") and v:Health() > 0 then
				if !IsValid(attacker) then attacker = self end
				self:GangBang(v, attacker)
			end
		end
	end
end
