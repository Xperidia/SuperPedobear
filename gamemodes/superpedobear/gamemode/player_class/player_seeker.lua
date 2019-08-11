--[[---------------------------------------------------------
		Super Pedobear Gamemode for Garry's Mod
				by VictorienXP (2016)
-----------------------------------------------------------]]

AddCSLuaFile()
DEFINE_BASECLASS("player_default")

local PLAYER = {}

PLAYER.DisplayName			= "Seeker"

PLAYER.WalkSpeed 			= 200
PLAYER.RunSpeed				= 400
PLAYER.CrouchedWalkSpeed 	= 0.3
PLAYER.DuckSpeed			= 0.3
PLAYER.UnDuckSpeed			= 0.3
PLAYER.JumpPower			= 200
PLAYER.CanUseFlashlight     = true
PLAYER.MaxHealth			= 255
PLAYER.StartHealth			= 255
PLAYER.StartArmor			= 255
PLAYER.DropWeaponOnDie		= false
PLAYER.TeammateNoCollide 	= true
PLAYER.AvoidPlayers			= false
PLAYER.UseVMHands			= true

PLAYER.TauntCam = TauntCamera()

function PLAYER:SetupDataTables()
	BaseClass.SetupDataTables(self)
end

function PLAYER:ShouldDrawLocal()
	if self.TauntCam:ShouldDrawLocalPlayer(self.Player, self.Player:IsPlayingTaunt()) then return true end
end

function PLAYER:CreateMove(cmd)
	if self.TauntCam:CreateMove(cmd, self.Player, self.Player:IsPlayingTaunt()) then return true end
end

function PLAYER:CalcView(view)
	if self.TauntCam:CalcView(view, self.Player, self.Player:IsPlayingTaunt()) then return true end
end

function PLAYER:Loadout()
	self.Player:RemoveAllItems()
	self.Player:Give("spb_seeker")
	if GetConVar("spb_weapons"):GetBool() then
		self.Player:Give("weapon_crowbar")
		self.Player:Give("weapon_fists")
		self.Player:Give("weapon_physcannon")
	end
end

function PLAYER:SetModel()
	self.Player:SetModel(Model("models/player/pbear/pbear.mdl"))
end

function PLAYER:Spawn()
	BaseClass.Spawn(self)
	self.Player:SetPlayerColor(Vector(0.545098, 0.333333, 0.180392))
end

function PLAYER:StartMove(mv)
	if mv:KeyDown(IN_SPEED) and !mv:GetVelocity():IsZero() then
		self.Player.Sprinting = true
	else
		self.Player.Sprinting = false
	end
end

player_manager.RegisterClass("player_seeker", PLAYER, "player_default")
