--[[---------------------------------------------------------------------------
		⚠ This file is a part of the Super Pedobear gamemode ⚠
	⚠ Please do not redistribute any version of it (edited or not)! ⚠
	So please ask me directly or contribute on GitHub if you want something...
-----------------------------------------------------------------------------]]

AddCSLuaFile()

ENT.Base = "base_anim"
ENT.PrintName = "Power-UP"
ENT.Author = "Xperidia"
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

function ENT:Initialize()
	self:SetModel("models/hunter/blocks/cube05x105x05.mdl")
	self:SetSolid(SOLID_VPHYSICS)
	self:DrawShadow(false)
	self:SetPos(self:GetPos() + Vector(0, 0, 35.5))
	self:SetAngles(Angle(0, 0, 90))
	self:SetCollisionGroup(COLLISION_GROUP_WORLD)
	self:SetColor(Color(255, 128, 0, 255))
	self:SetRenderMode(RENDERMODE_TRANSALPHA)
	self:SetMaterial("models/wireframe")
	if SERVER then
		self:SetTrigger(true)
		self:SetUseType(SIMPLE_USE)
	end
end

function ENT:Think()
	--if CLIENT then self:SetAngles(self:GetAngles() + Angle(0, 0.1, 0)) end
end

local sprite = Material("sprites/physg_glow1")
function ENT:Draw()
	if superpedobear_enabledevmode:GetBool() then self:DrawModel() end
	if !IsValid(self.PU) then
		self.PU = ClientsideModel("models/maxofs2d/hover_rings.mdl")
		self.PU.origin = self:GetPos() + Vector(0, 0, -30)
		self.PU:SetPos(self.PU.origin)
		self.PU:SetColor(Color(255, 128, 0, 255))
		self.PU:SetRenderMode(RENDERMODE_TRANSALPHA)
	end
	if IsValid(self.PU) then
		local x = 0.5 * (math.sin(CurTime() * 2) + 1)
		--self.PU:SetAngles(self.PU:GetAngles() + Angle(0.1, 0.1, 0.1))
		--self.PU:SetColor(Color(255, 128, 0, math.Remap(x, 0, 1, 128, 255)))
		if self:GetNWBool("Trap", false) then
			self.PU:SetColor(Color(255, 64, 0, 255))
			self:SetColor(Color(255, 0, 0, 255))
			self.PU:SetPos(self.PU.origin + Vector(0, 0, math.sin(CurTime()) * 2))
			render.SetMaterial(sprite)
			render.DrawSprite(self.PU:GetPos(), 32, 32, Color(255, 64, 0, math.Remap(x, 0, 1, 128, 255)))
		else
			self.PU:SetPos(self.PU.origin + Vector(0, 0, math.sin(CurTime() * 2) * 2))
			render.SetMaterial(sprite)
			render.DrawSprite(self.PU:GetPos(), 32, 32, Color(255, 128, 0, math.Remap(x, 0, 1, 128, 255)))
			self.light = DynamicLight(self:EntIndex())
			if self.light then
				self.light.pos = self.PU:GetPos()
				self.light.r = math.Remap(x, 0, 1, 85, 255)
				self.light.g = math.Remap(x, 0, 1, 128 / 3, 128)
				self.light.b = 0
				self.light.brightness = 1
				self.light.Decay = 1000
				self.light.Size = 256
				self.light.DieTime = CurTime() + 1
			end
		end
	end
end

function ENT:OnRemove()
	if CLIENT then
		if IsValid(self.PU) then
			self.PU:Remove()
		end
	end
end

function ENT:PickUP(ent)
	if IsValid(ent) and ent:IsPlayer() and ent:Alive() then
		if !self.Trap then
			local result = ent:PickPowerUP(self.ForcedPowerUP)
			if result or result == nil then
				self:Remove()
			end
		elseif ent:Team() == TEAM_VICTIMS then
			local d = DamageInfo()
			d:SetDamage(2147483647)
			d:SetDamageType(DMG_DIRECT)
			d:SetAttacker(self.Trap)
			d:SetDamageForce(Vector(0, 0, -100000))
			d:SetDamagePosition(self:GetPos())
			d:SetMaxDamage(2147483647)
			if IsValid(ent) and ent:Health() > 0 then ent:TakeDamageInfo(d) end
			self:Remove()
		end
	end
end

function ENT:StartTouch(ent)
	self:PickUP(ent)
end

function ENT:Use(activator, caller)
	self:PickUP(caller)
end
