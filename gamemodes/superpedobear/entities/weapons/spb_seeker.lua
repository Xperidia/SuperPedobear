--[[---------------------------------------------------------
		Super Pedobear Gamemode for Garry's Mod
				by VictorienXP (2016-2020)
-----------------------------------------------------------]]

AddCSLuaFile()

SWEP.PrintName	= "Seeker powers"
SWEP.Author		= "Xperidia"
SWEP.Purpose = "Catch players, break props and use power-ups"
if CLIENT then
	SWEP.Instructions = GAMEMODE:CheckBind("+attack") .. " to break props\n" .. GAMEMODE:CheckBind("+reload") .. " to use power-ups"
	SWEP.WepSelectIcon = surface.GetTextureID("superpedobear/weapons/spb_seeker")
end
SWEP.Spawnable	= false

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.Weight				= 10
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
	self:SetHoldType("duel")
end

function SWEP:PrimaryAttack()
	if not self.lasttime or self.lasttime + 1 < CurTime() then
		local owner = self:GetOwner()
		local tr = util.GetPlayerTrace(owner)
		local trace = util.TraceLine(tr)
		if not trace.Hit then return end
		if not trace.HitNonWorld then return end
		if IsValid(trace.Entity) and trace.Entity:IsPlayer() then return end
		if SERVER then
			constraint.RemoveConstraints(trace.Entity, "Weld")
			self:GangBang(trace.Entity, owner)
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

function SWEP:Reload()
	if SERVER then
		self:GetOwner():UsePowerUP()
	end
end

function SWEP:GangBang(ent, attacker)
	local d = DamageInfo()
	d:SetDamage(2147483647)
	d:SetDamageType(DMG_DIRECT)
	d:SetAttacker(attacker)
	d:SetDamageForce(Vector(0, 0, -100000))
	d:SetDamagePosition(attacker:GetPos())
	d:SetMaxDamage(2147483647)
	if IsValid(ent) and ent:Health() > 0 then
		ent:TakeDamageInfo(d)
	end
end

function SWEP:Think()
	if SERVER and GAMEMODE.Vars.Round.Start then
		local attacker = self:GetOwner()
		for k, v in pairs(ents.FindInSphere(attacker:GetPos() + Vector(0, 0, 32), 32.2)) do
			if IsValid(v) and ((v:IsPlayer() and v:Alive() and v:Team() == TEAM_HIDING and attacker:IsLineOfSightClear(v)) or v:GetClass() == "spb_dummy") then
				if not IsValid(attacker) then attacker = self end
				self:GangBang(v, attacker)
			end
		end
	end
end
