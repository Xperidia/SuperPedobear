--[[---------------------------------------------------------
		Super Pedobear Gamemode for Garry's Mod
				by VictorienXP (2016-2020)
-----------------------------------------------------------]]

AddCSLuaFile()
DEFINE_BASECLASS("player_default")

local PLAYER = {}

PLAYER.DisplayName			= "SPB Player Base Class"

PLAYER.WalkSpeed 			= 200
PLAYER.RunSpeed				= 400
PLAYER.JumpPower			= 220
PLAYER.DropWeaponOnDie		= true

PLAYER.TauntCam = TauntCamera()

function PLAYER:SetupDataTables()

	BaseClass.SetupDataTables(self)

	--TODO: put/transfer stuff here

end

function PLAYER:ShouldDrawLocal()
	if self.TauntCam:ShouldDrawLocalPlayer(self.Player, self.Player:IsPlayingTaunt()) then
		return true
	end
end

function PLAYER:CreateMove(cmd)
	if self.TauntCam:CreateMove(cmd, self.Player, self.Player:IsPlayingTaunt()) then
		return true
	end
end

function PLAYER:CalcView(view)
	if self.TauntCam:CalcView(view, self.Player, self.Player:IsPlayingTaunt()) then
		return true
	end
end

function PLAYER:Loadout()
	self.Player:RemoveAllItems()
end

function PLAYER:StartMove(mv)
	if mv:KeyDown(IN_SPEED) and not mv:GetVelocity():IsZero() then
		self.Player.Sprinting = true
	else
		self.Player.Sprinting = false
	end
end

player_manager.RegisterClass("player_spb", PLAYER, "player_default")
