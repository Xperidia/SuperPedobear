--[[---------------------------------------------------------
		Super Pedobear Gamemode for Garry's Mod
				by VictorienXP (2016-2020)
-----------------------------------------------------------]]

AddCSLuaFile()
DEFINE_BASECLASS("player_spb")

local PLAYER = {}

PLAYER.DisplayName			= "Hiding"

PLAYER.CrouchedWalkSpeed 	= 0.8
PLAYER.DuckSpeed			= 0.2
PLAYER.UnDuckSpeed			= 0.2

function PLAYER:Loadout()

	BaseClass.Loadout(self)

	self.Player:Give("spb_hiding")

	if GetConVar("spb_weapons"):GetBool() then
		self.Player:Give("weapon_fists")
		self.Player:Give("weapon_crowbar")
		self.Player:Give("weapon_medkit")
	end

end

function PLAYER:SetModel()

	local cl_playermodel = self.Player:GetInfo("cl_playermodel")

	if cl_playermodel == "none" or not GAMEMODE.Vars.PM_Available[cl_playermodel] or spb_restrict_playermodels:GetBool() then

		local modelname = player_manager.TranslatePlayerModel(self.Player:GetNWString("spb_DefautPM", "chell"))
		util.PrecacheModel(modelname)
		self.Player:SetModel(modelname)

	else

		local modelname = player_manager.TranslatePlayerModel(cl_playermodel)
		util.PrecacheModel(modelname)
		self.Player:SetModel(modelname)

		local skin = self.Player:GetInfoNum("cl_playerskin", 0)
		self.Player:SetSkin(skin)

		local groups = self.Player:GetInfo("cl_playerbodygroups")
		if groups == nil then groups = "" end
		local groups = string.Explode(" ", groups)
		for k = 0, self.Player:GetNumBodyGroups() - 1 do
			self.Player:SetBodygroup(k, tonumber(groups[k + 1]) or 0)
		end

	end

end

function PLAYER:Spawn()
	BaseClass.Spawn(self)
	self.Player:SetPlayerColor(Vector(math.Rand(0, 1), math.Rand(0, 1), math.Rand(0, 1)))
end

player_manager.RegisterClass("player_hiding", PLAYER, "player_spb")
