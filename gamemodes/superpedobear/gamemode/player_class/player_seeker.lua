--[[---------------------------------------------------------
		Super Pedobear Gamemode for Garry's Mod
				by VictorienXP (2016-2020)
-----------------------------------------------------------]]

AddCSLuaFile()
DEFINE_BASECLASS("player_spb")

local PLAYER = {}

PLAYER.DisplayName			= "Seeker"

PLAYER.MaxHealth			= 255
PLAYER.StartHealth			= 255
PLAYER.StartArmor			= 255
PLAYER.UseVMHands			= false

function PLAYER:Loadout()

	BaseClass.Loadout(self)

	self.Player:Give("spb_seeker")

end

function PLAYER:SetModel()
	self.Player:SetModel(GAMEMODE.Models.Bear)
end

function PLAYER:Spawn()
	BaseClass.Spawn(self)
	self.Player:SetPlayerColor(Vector(0.545098, 0.333333, 0.180392))
end

player_manager.RegisterClass("player_seeker", PLAYER, "player_spb")
