--[[---------------------------------------------------------
		Super Pedobear Gamemode for Garry's Mod
				by VictorienXP (2016)
-----------------------------------------------------------]]

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
	elseif k == "RespawnTime" then
		self.RespawnTime = v
	end
	if string.Left(k, 2) == "On" then
		self:StoreOutput(k, v)
	end
end

function ENT:Think()
	if !SERVER or self.Disabled then return end
	if !self.SpawnedPowerUP then
		self.SpawnedPowerUP = GAMEMODE:CreatePowerUP(self, self.ForcedPowerUP)
	elseif !IsValid(self.SpawnedPowerUP) and !self.Wait then
		self.Wait = CurTime() + (self.RespawnTime or 30)
		self:TriggerOutput("OnPickup")
	elseif self.Wait and self.Wait < CurTime() then
		self.SpawnedPowerUP = GAMEMODE:CreatePowerUP(self, self.ForcedPowerUP, true)
		self.Wait = nil
	end
end

function ENT:AcceptInput(name, activator, caller, data)
	if name == "ForceRespawn" and !IsValid(self.SpawnedPowerUP) then
		self.Wait = 0
	elseif name == "Disable" then
		self.Disabled = true
	elseif name == "Enable" then
		self.Disabled = false
	end
	return true
end
