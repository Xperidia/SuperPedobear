--[[---------------------------------------------------------------------------
		⚠ This file is a part of the Super Pedobear gamemode ⚠
	⚠ Please do not redistribute any version of it (edited or not)! ⚠
	So please ask me directly or contribute on GitHub if you want something...
-----------------------------------------------------------------------------]]

AddCSLuaFile()

ENT.Base = "base_entity"
ENT.Type = "point"
ENT.PrintName = "Spawn point for Power-UPs"
ENT.Author = "Xperidia"
ENT.RenderGroup = RENDERGROUP_OTHER

function ENT:Initialize()
	self:SetSolid(SOLID_NONE)
	self:SetCollisionGroup(COLLISION_GROUP_NONE)
	self:SetRenderMode(RENDERMODE_NONE)
end

function ENT:KeyValue(k, v)
	if k == "PowerUP" then
		self.ForcedPowerUP = v
	end
end

if SERVER then
	function ENT:Think()
		if !self.SpawnedPowerUP then
			self.SpawnedPowerUP = GAMEMODE:CreatePowerUP(self, self.ForcedPowerUP)
		elseif !IsValid(self.SpawnedPowerUP) and !self.Wait then
			self.Wait = CurTime() + 30
		elseif self.Wait and self.Wait < CurTime() then
			self.SpawnedPowerUP = GAMEMODE:CreatePowerUP(self, self.ForcedPowerUP, true)
			self.Wait = nil
		end
	end
end
