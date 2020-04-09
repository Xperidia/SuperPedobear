--[[---------------------------------------------------------
		Super Pedobear Gamemode for Garry's Mod
				by VictorienXP (2016)
-----------------------------------------------------------]]

AddCSLuaFile()
DEFINE_BASECLASS("player_default")

local PLAYER = {}

PLAYER.DisplayName			= "Hiding"

PLAYER.WalkSpeed 			= 200		-- How fast to move when not running
PLAYER.RunSpeed				= 400		-- How fast to move when running
PLAYER.CrouchedWalkSpeed 	= 0.3		-- Multiply move speed by this when crouching
PLAYER.DuckSpeed			= 0.3		-- How fast to go from not ducking, to ducking
PLAYER.UnDuckSpeed			= 0.3		-- How fast to go from ducking, to not ducking
PLAYER.JumpPower			= 200		-- How powerful our jump should be
PLAYER.CanUseFlashlight     = true		-- Can we use the flashlight
PLAYER.MaxHealth			= 100		-- Max health we can have
PLAYER.StartHealth			= 100		-- How much health we start with
PLAYER.StartArmor			= 0			-- How much armour we start with
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
	self.Player:Give("spb_hiding")
	if GetConVar("spb_weapons"):GetBool() then
		self.Player:Give("weapon_fists")
		self.Player:Give("weapon_stunstick")
		self.Player:Give("weapon_medkit")
	end
end

function PLAYER:Spawn()
	BaseClass.Spawn(self)
	self.Player:SetPlayerColor(Vector(math.Rand(0, 1), math.Rand(0, 1), math.Rand(0, 1)))
end

function PLAYER:SetModel()

	local cl_playermodel = self.Player:GetInfo("cl_playermodel")

	if cl_playermodel == "none" or !GAMEMODE.Vars.PM_Available[cl_playermodel] or spb_restrict_playermodels:GetBool() then

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

function PLAYER:GetHandsModel()

	local cl_playermodel = self.Player:GetInfo("cl_playermodel")
	if cl_playermodel != "none" and GAMEMODE.Vars.PM_Available[cl_playermodel] and !spb_restrict_playermodels:GetBool() then
		return player_manager.TranslatePlayerHands(cl_playermodel)
	else
		return player_manager.TranslatePlayerHands(self.Player:GetNWString("spb_DefautPM", "chell"))
	end

end

function PLAYER:StartMove(mv)
	if mv:KeyDown(IN_SPEED) and !mv:GetVelocity():IsZero() then
		self.Player.Sprinting = true
	else
		self.Player.Sprinting = false
	end
end

player_manager.RegisterClass("player_hiding", PLAYER, "player_default")
