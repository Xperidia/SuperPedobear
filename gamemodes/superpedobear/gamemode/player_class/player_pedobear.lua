--[[---------------------------------------------------------------------------
		⚠ This file is a part of the Super Pedobear source code ⚠
		⚠ Please do not clone, redistribute or modify the code! ⚠
	We do not obscurate the code or anything mostly to help bug reporting.
	Please do not try to cheat, if you want something ask me directly...
We're just indies making stuff so please support us instead of putting us down.
So unless you're modifying it to improve it via a Pull request please do not.
-----------------------------------------------------------------------------]]

AddCSLuaFile()
DEFINE_BASECLASS("player_default")

local PLAYER = {}

PLAYER.DisplayName			= "Pedobear"

PLAYER.WalkSpeed 			= 200		-- How fast to move when not running
PLAYER.RunSpeed				= 400		-- How fast to move when running
PLAYER.CrouchedWalkSpeed 	= 0.3		-- Multiply move speed by this when crouching
PLAYER.DuckSpeed			= 0.3		-- How fast to go from not ducking, to ducking
PLAYER.UnDuckSpeed			= 0.3		-- How fast to go from ducking, to not ducking
PLAYER.JumpPower			= 200		-- How powerful our jump should be
PLAYER.CanUseFlashlight     = true		-- Can we use the flashlight
PLAYER.MaxHealth			= 100		-- Max health we can have
PLAYER.StartHealth			= 5000		-- How much health we start with
PLAYER.StartArmor			= 255			-- How much armour we start with
PLAYER.DropWeaponOnDie		= false		-- Do we drop our weapon when we die
PLAYER.TeammateNoCollide 	= true		-- Do we collide with teammates or run straight through them
PLAYER.AvoidPlayers			= false		-- Automatically swerves around other players
PLAYER.UseVMHands			= true		-- Uses viewmodel hands

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
	self.Player:Give("superpedobear_pedobear")
end

function PLAYER:SetModel()
	self.Player:SetModel(Model("models/player/pbear/pbear.mdl"))
end

function PLAYER:Spawn()
	BaseClass.Spawn(self)
	self.Player:SetPlayerColor(Vector(0.545098, 0.333333, 0.180392))
	self.Player:SetModelScale(1, 0)
end

function PLAYER:StartMove(mv)
	if mv:KeyDown(IN_SPEED) and !mv:GetVelocity():IsZero() then
		self.Player.Sprinting = true
	else
		self.Player.Sprinting = false
	end
end

player_manager.RegisterClass("player_pedobear", PLAYER, "player_default")
