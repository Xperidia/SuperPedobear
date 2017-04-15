AddCSLuaFile()
DEFINE_BASECLASS( "player_default" )

local PLAYER = {}

PLAYER.DisplayName			= "Victim"

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

	BaseClass.SetupDataTables( self )

end

function PLAYER:ShouldDrawLocal()

	if ( self.TauntCam:ShouldDrawLocalPlayer( self.Player, self.Player:IsPlayingTaunt() ) ) then return true end

end

function PLAYER:CreateMove( cmd )

	if ( self.TauntCam:CreateMove( cmd, self.Player, self.Player:IsPlayingTaunt() ) ) then return true end

end

function PLAYER:CalcView( view )

	if ( self.TauntCam:CalcView( view, self.Player, self.Player:IsPlayingTaunt() ) ) then return true end
end

function PLAYER:Loadout()

	self.Player:RemoveAllItems()
	self.Player:Give( "pedo_victim" )

end

function PLAYER:Spawn()

	BaseClass.Spawn( self )

	self.Player:SetPlayerColor( Vector( math.Rand(0,1), math.Rand(0,1), math.Rand(0,1) ) )

	self.Player:SetModelScale( 1, 0 )

end

function PLAYER:SetModel()

	BaseClass.SetModel( self )

	local cl_playermodel = self.Player:GetInfo("cl_playermodel")
	local avmodels = player_manager.AllValidModels()

	if cl_playermodel == "none" or !avmodels[cl_playermodel] then
		local models = {"models/jazzmcfly/magica/homura_mg.mdl", "models/jazzmcfly/magica/kyouko_mg.mdl", "models/jazzmcfly/magica/madoka_mg.mdl", "models/jazzmcfly/magica/mami_mg.mdl", "models/jazzmcfly/magica/sayaka_mg.mdl"}
		self.Player:SetModel(models[math.random(1, #models)])
	else
		local modelname = player_manager.TranslatePlayerModel(cl_playermodel)
		self.Player:SetModel(modelname)

		local skin = self.Player:GetInfoNum("cl_playerskin", 0)
		self.Player:SetSkin( skin )

		local groups = self.Player:GetInfo("cl_playerbodygroups")
		if groups == nil then groups = "" end
		local groups = string.Explode(" ", groups)
		for k = 0, self.Player:GetNumBodyGroups() - 1 do
			self.Player:SetBodygroup( k, tonumber( groups[ k + 1 ] ) or 0 )
		end
	end

end

function PLAYER:StartMove( mv )

	if mv:KeyDown( IN_SPEED ) and !mv:GetVelocity():IsZero() then
		self.Player.Sprinting = true
	else
		self.Player.Sprinting = false
	end

end

player_manager.RegisterClass( "player_victim", PLAYER, "player_default" )
