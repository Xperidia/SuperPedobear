--[[---------------------------------------------------------------------------
		⚠ This file is a part of the Super Pedobear gamemode ⚠
	⚠ Please do not redistribute any version of it (edited or not)! ⚠
	So please ask me directly or contribute on GitHub if you want something...
-----------------------------------------------------------------------------]]

AddCSLuaFile()

ENT.Base = "base_nextbot"
ENT.PrintName = "Dummy"
ENT.Author = "Xperidia"

function ENT:Initialize()

	local ply = self:GetPlayer()

	self:SetHealth(1)
	self:SetCustomCollisionCheck(true)

	self.OPos = ply:GetPos()
	self.OAngles = Angle(0, ply:GetAngles()[2], 0)
	self:SetPos(self.OPos)
	self:SetAngles(self.OAngles)

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

end

function ENT:SetupDataTables()
	self:NetworkVar("Entity", 0, "Player")
end

function ENT:RunBehaviour()
	while true do
		coroutine.wait(60)
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

	if !ply or !IsValid(ply) or !ply:Alive() or ply:Team() != TEAM_VICTIMS then
		self:Remove()
		return
	end

	if self:GetPos() != self.OPos then
		self:SetPos(self.OPos)
	end

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

	local ply = self:GetPlayer()

	ply:PrintMessage(HUD_PRINTTALK, "Your clone is dead!")

	--self:BecomeRagdoll(dmginfo)

	self:Remove()

end
