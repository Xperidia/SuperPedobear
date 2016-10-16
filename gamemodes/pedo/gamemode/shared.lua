DEFINE_BASECLASS( "gamemode_base" )

include( "player_class/player_victim.lua" )
include( "player_class/player_pedobear.lua" )

GM.Name 	= "Pedobear"
GM.ShortName 	= "Pedo"
GM.Author 	= "VictorienXP@Xperidia"
GM.Email 	= "contact@Xperidia.com"
GM.Website 	= "steamcommunity.com/sharedfiles/filedetails/?id=628449407"
GM.Version 	= 0.21
GM.TeamBased = true

TEAM_VICTIMS = 1
TEAM_PEDOBEAR = 2

GM.Sounds = {}
GM.Sounds.YoureThePedo = Sound("pedo/yourethepedo.wav")
GM.Sounds.HeartBeat = Sound("pedo/heartbeat.ogg")

GM.Sounds.Taunts = {}
table.insert( GM.Sounds.Taunts, { "Goat Gentleman", Sound("pedo/taunts/s1.ogg"), 0, 16.5 } )
table.insert( GM.Sounds.Taunts, { "Makka Pakka", Sound("pedo/taunts/s2.ogg"), 0, 13 } )
table.insert( GM.Sounds.Taunts, { "Stampy Intro", Sound("pedo/taunts/s3.ogg"), 0, 7 } )
table.insert( GM.Sounds.Taunts, { "Buttsauce", Sound("pedo/taunts/s4.ogg"), 0, 1 } )
table.insert( GM.Sounds.Taunts, { "Thomas the tank engine", Sound("pedo/taunts/s5.ogg"), 0, 7 } )
table.insert( GM.Sounds.Taunts, { "Get your lollipops", Sound("pedo/taunts/p1.ogg"), TEAM_PEDOBEAR, 6 } )
table.insert( GM.Sounds.Taunts, { "MY PEE PEE", Sound("pedo/taunts/s6.ogg"), 0, 20.5 } )

GM.Sounds.Damage = GM.Sounds.Damage or {}
GM.Sounds.Death = GM.Sounds.Death or {}

GM.Materials = {}
GM.Materials.Death = Material("pedo/pedoscare")
GM.Materials.PepperDeath = Material("pedo/pepperscare")

GM.Vars = GM.Vars or {}
GM.Vars.Round = GM.Vars.Round or {}
GM.Bots = GM.Bots or {}

GM.SeasonalEvents = {
	{"AprilFool", " - April Fool", "01/04"},
	{"Halloween", " - Halloween", "31/10"},
	{"Christmas", " - Christmas", "24/12", "25/12"}
}

function GM:IsSeasonalEvent(str)
	
	local Timestamp = os.time()
	
	for k, v in pairs(GAMEMODE.SeasonalEvents) do
		
		local i = 0
		
		if str == v[1] then
			
			while v[3+i] do
				
				if (os.date("%d/%m", Timestamp) == v[3+i]) then
					return true
				end
				
				i = i + 1
				
			end
		end
		
	end
	
	return false
	
end

function GM:SeasonalEventStr()
	
	local Timestamp = os.time()
	
	for k, v in pairs(GAMEMODE.SeasonalEvents) do
		
		local i = 0
		
		while v[3+i] do
			
			if (os.date("%d/%m", Timestamp) == v[3+i]) then
				return v[2]
			end
			
			i = i + 1
			
		end
		
	end
	
	return ""
	
end

function GM:Initialize()
	
	sound.Add( {
		name = "pedo_yourethepedo",
		channel = CHAN_STATIC,
		volume = 1.0,
		level = 0,
		sound = GAMEMODE.Sounds.YoureThePedo
	} )
	
	pedobear_enabledevmode = CreateConVar( "pedobear_enabledevmode", 0, FCVAR_NONE, "Dev mode and more logs." )
	pedobear_round_time = CreateConVar( "pedobear_round_time", 180, { FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE }, "Time of a round in second." )
	pedobear_round_pretime = CreateConVar( "pedobear_round_pretime", 30, { FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE }, "Time of the round preparation in second." )
	pedobear_afk_time = CreateConVar( "pedobear_afk_time", 30, { FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE }, "Time needed for a player to be consired afk." )
	pedobear_afk_action = CreateConVar( "pedobear_afk_action", 30, { FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE }, "Time needed for a player to be kick out of pedobear when afk." )
	pedobear_save_chances = CreateConVar( "pedobear_save_chances", 1, { FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE }, "Set if we should save the chances to be Pedobear." )
	pedobear_save_score = CreateConVar( "pedobear_save_score", 1, { FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE }, "Set if we should save the scores." )
	
	local damagesnd = file.Find( "sound/pedo/damage/*.ogg", "GAME" )
	
	for k,v in pairs(damagesnd) do
		table.insert( GAMEMODE.Sounds.Damage, Sound("pedo/damage/"..v) )
	end
	
	local deathsnd = file.Find( "sound/pedo/death/*.ogg", "GAME" )
	
	for k,v in pairs(deathsnd) do
		table.insert( GAMEMODE.Sounds.Death, Sound("pedo/death/"..v) )
	end
	
	if CLIENT then
		
		CreateClientConVar( "pedobear_cl_disablexpsc", 0, true, false )
		CreateClientConVar( "pedobear_cl_disabletauntmenuclose", 0, true, false )
		CreateClientConVar( "pedobear_cl_jumpscare", 0, true, true )
		CreateClientConVar( "pedobear_cl_disablehalos", 0, true, false )
		CreateClientConVar( "pedobear_cl_music_enable", 1, true, false )
		CreateClientConVar( "pedobear_cl_music_volume", 0.5, true, false )
		CreateClientConVar( "pedobear_cl_music_allowexternal", 1, true, false )
		CreateClientConVar( "pedobear_cl_music_visualizer", 0, true, false )
		
		cvars.AddChangeCallback( "pedobear_cl_music_volume", function( convar_name, value_old, value_new )
			if IsValid(GAMEMODE.Vars.Music) then
				GAMEMODE.Vars.Music:SetVolume(GetConVar( "pedobear_cl_music_volume" ):GetFloat())
			end
		end)
		cvars.AddChangeCallback( "pedobear_cl_music_enable", function( convar_name, value_old, value_new )
			if IsValid(GAMEMODE.Vars.Music) and !GetConVar( "pedobear_cl_music_enable" ):GetBool() then
				GAMEMODE.Vars.Music:Stop()
				GAMEMODE.Vars.Music = nil
			end
		end)
		
	end
	
end

function GM:ShutDown()
end

if SERVER then

	function GM:StoreChances(ply)
		
		if !pedobear_save_chances:GetBool() then GAMEMODE:Log("Chances saving is disabled. Not saving pedobear chances.") return end
		
		local function savechance(pl)
			
			if pl:IsBot() then return end
			
			local chance = pl:GetNWFloat("XP_Pedo_PedoChance", nil)
			
			if chance != nil then
				
				pl:SetPData('XP_Pedo_PedoChance', math.floor(math.Clamp(chance,0,100)*100))
				
				GAMEMODE:Log("Saved the "..(chance*100).."% pedobear chance of "..pl:GetName())
				
			end
			
		end
		
		if IsValid(ply) then
			
			savechance(ply)
			
		elseif ply == nil then
			
			for k, v in pairs(player.GetAll()) do
				
				savechance(v)
				
			end
			
		end
		
	end

	function GM:LoadChances(ply)
		
		if !pedobear_save_chances:GetBool() then GAMEMODE:Log("Chances saving is disabled. Not loading pedobear chances.", nil, true) return end
		
		local function loadchance(pl)
			
			if pl:IsBot() then return end
			
			local chance = pl:GetPData("XP_Pedo_PedoChance", nil)
			
			if chance != nil then
				
				chance = chance * 0.01
				
				pl:SetNWFloat("XP_Pedo_PedoChance", chance)
				
				GAMEMODE:Log("Loaded the "..(chance*100).."% pedobear chance of "..pl:GetName())
				
			else
				
				pl:SetNWFloat("XP_Pedo_PedoChance", 0.01)
				
				GAMEMODE:Log("No pedobear chance found for "..pl:GetName()..", default was set")
				
			end
			
		end
		
		if IsValid(ply) then
			
			loadchance(ply)
			
		elseif ply == nil then
			
			for k, v in pairs(player.GetAll()) do
				
				loadchance(v)
				
			end
			
		end
		
	end

end

function GM:CreateTeams()
	
	team.SetUp( TEAM_VICTIMS, "Victims", Color(247, 127, 190) )
	team.SetSpawnPoint( TEAM_VICTIMS, "info_player_terrorist" )
	team.SetClass(TEAM_VICTIMS, { "player_victim" } )

	team.SetUp( TEAM_PEDOBEAR, "Pedobear", Color( 139, 85, 46 ), false )
	team.SetSpawnPoint( TEAM_PEDOBEAR, "info_player_counterterrorist" )
	team.SetClass(TEAM_PEDOBEAR, { "player_pedobear" } )
	
	team.SetUp( TEAM_SPECTATOR, "Spectator", DefaultColor, false )

	team.SetSpawnPoint( TEAM_SPECTATOR, "worldspawn" )
	team.SetSpawnPoint( TEAM_UNASSIGNED, "worldspawn" )
	
end

function GM:ShouldCollide( Ent1, Ent2 )
	
	if Ent1:GetClass()=="pedo_dummy" or Ent2:GetClass()=="pedo_dummy" then
		return false
	end
	
	return true
	
end


function GM:Log(str,tn,hardcore)
	
	local name = (GAMEMODE.ShortName or "Pedo")
	if tn then name = "Pedo" end
	
	if hardcore and !pedobear_enabledevmode:GetBool() then return end
	
	if game.IsDedicated() or GAMEMODE.Vars.DS then
		local tmstmp = os.time()
		local time = os.date( "L %m/%d/%Y - %H:%M:%S" , tmstmp )
		Msg( time..": ["..name.."] "..(str or "This was a log message, but something went wrong").."\n" )
	else
		Msg( "["..name.."] "..(str or "This was a log message, but something went wrong").."\n" )
	end
	
end
