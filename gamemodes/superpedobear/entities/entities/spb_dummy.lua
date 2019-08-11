--[[---------------------------------------------------------
		Super Pedobear Gamemode for Garry's Mod
				by VictorienXP (2016)
-----------------------------------------------------------]]

AddCSLuaFile()

ENT.Base = "base_nextbot"
ENT.PrintName = "Dummy"
ENT.Author = "Xperidia"

function ENT:Initialize()

	local ply = self:GetPlayer()

	self:SetHealth(1)
	self:SetCustomCollisionCheck(true)

	if SERVER then
		self:SetLePos(ply:GetPos())
		self:SetLeAngle(Angle(0, ply:GetAngles()[2], 0))
	end
	self:SetPos(self:GetLePos())
	self:SetAngles(self:GetLeAngle())

	self:SetModel(ply:GetModel())

	self.GetPlayerColor = function() return ply:GetPlayerColor() end
	self.GetName = function() return ply:GetName() end
	self.Nick = function() return ply:Nick() end
	self.Team = function() return ply:Team() end

	self:SetSkin(ply:GetSkin())

	for k, v in pairs(ply:GetBodyGroups()) do
		self:SetBodygroup(v["id"], ply:GetBodygroup(v["id"]))
	end

	self:StartSeq("idle_all_01")

	self:EmitSound("garrysmod/balloon_pop_cute.wav", 75, 100, 1, CHAN_AUTO)

end

function ENT:SetupDataTables()
	self:NetworkVar("Entity", 0, "Player")
	self:NetworkVar("Vector", 0, "LePos")
	self:NetworkVar("Angle", 0, "LeAngle")
end

function ENT:RunBehaviour()
	while true do
		coroutine.wait(180)
		coroutine.yield()
	end
end

local function SameBodyGroups(self, ply)
	for k, v in pairs(self:GetBodyGroups()) do
		if self:GetBodygroup(v.id) != ply:GetBodygroup(v.id) then return false end
	end
	return true
end

function ENT:Think()

	local ply = self:GetPlayer()

	if SERVER then
		if !ply or !IsValid(ply) or ply:Team() != TEAM_HIDING then
			self:BRemove(ply)
			return
		end
	end

	self:SetPos(self:GetLePos())
	self:SetAngles(self:GetLeAngle())

	if ply:GetModel() != self:GetModel() then

		self:SetModel(ply:GetModel())

		self:StartSeq("idle_all_01")

		self:SetSkin(ply:GetSkin())

		for k,v in pairs(ply:GetBodyGroups()) do
			self:SetBodygroup(v["id"], ply:GetBodygroup(v["id"]))
		end

	elseif self:GetSkin() != ply:GetSkin() or !SameBodyGroups(self, ply) then

		self:SetSkin(ply:GetSkin())

		for k, v in pairs(ply:GetBodyGroups()) do
			self:SetBodygroup(v["id"], ply:GetBodygroup(v["id"]))
		end

	end

	for p, ply in pairs(player.GetAll()) do
		if ply:EyePos():Distance(self:EyePos()) <= 60 then
			self:SetEyeTarget(ply:EyePos())
			break
		end
	end

end

function ENT:StartSeq(str)
	local iSeq = self:LookupSequence(str) or 0
	self:SetSequence(iSeq)
	self:ResetSequenceInfo()
	self:SetCycle(0)
	self:SetPlaybackRate(1)
end

function ENT:OnKilled(dmginfo)

	local att = dmginfo:GetAttacker()

	hook.Call("OnDummyKilled", GAMEMODE, self, att, dmginfo:GetInflictor())

	if #GAMEMODE.Sounds.Death > 0 then
		self:EmitSound(GAMEMODE.Sounds.Death[math.random(1, #GAMEMODE.Sounds.Death)], 100, 100, 1, CHAN_AUTO)
	end

	self:BRemove(self:GetPlayer())

end

function ENT:BRemove(ply)
	if !SERVER then return end
	if IsValid(ply) then
		table.RemoveByValue(ply.Clones, self)
	end
	self:Remove()
end
