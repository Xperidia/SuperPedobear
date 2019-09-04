--[[---------------------------------------------------------
		Super Pedobear Gamemode for Garry's Mod
				by VictorienXP (2016)
-----------------------------------------------------------]]

DEFINE_BASECLASS("gamemode_base")

include("player_class/player_hiding.lua")
include("player_class/player_seeker.lua")

GM.Name 		= "Super Pedobear"
GM.Author 		= "VictorienXP@Xperidia"
GM.Website 		= "steamcommunity.com/sharedfiles/filedetails/?id=628449407"
GM.Version 		= 0.32
GM.VersionDate 	= 190904
GM.TeamBased 	= true

TEAM_HIDING	= 1
TEAM_SEEKER	= 2

GM.Sounds = {}
GM.Sounds.YoureTheBear	= Sound("superpedobear/yourethebear.wav")
GM.Sounds.HeartBeat		= Sound("superpedobear/heartbeat.ogg")
GM.Sounds.Damage		= GM.Sounds.Damage or {}
GM.Sounds.Death			= GM.Sounds.Death or {}

GM.Materials = {}
GM.Materials.Van	= Material("superpedobear/van")
GM.Materials.Bear	= Material("superpedobear/bear")

GM.Vars = GM.Vars or {}
GM.Vars.Round = GM.Vars.Round or {}
GM.Bots = GM.Bots or {}
GM.Musics = GM.Musics or {}
GM.Taunts = GM.Taunts or {}
if CLIENT then GM.LocalMusics = GM.LocalMusics or {} end

GM.SeasonalEvents = {
	{"AprilFool", "April Fool", "01/04"},
	{"Halloween", "Halloween", "31/10"},
	{"Christmas", "Christmas", "24/12", "25/12"},
	{"PedobearDay", "Pedobear Anniversary", "10/02"},
	{"LennyFaceDay", "Lenny Face Anniversary", "18/11"}
}

GM.PowerUps = {
	--name		= {"Name", <TEAM: -1(disabled), 0(all teams), TEAM_HIDING or TEAM_SEEKER>, Material("superpedobear/powerup/materialname"), <Optional Color()>, <Optional price addition>},
	clone		= {"Clone",				TEAM_HIDING,	Material("superpedobear/powerup/clone"),	Color(255, 200, 50, 255),	2},
	boost		= {"Boost",				TEAM_HIDING,	Material("superpedobear/powerup/boost"),	Color(255, 128, 0, 255)},
	vdisguise	= {"Disguise",			-1,				Material("superpedobear/powerup/vdisguise")},
	cloak		= {"Invisibility",		TEAM_HIDING,	Material("superpedobear/powerup/cloak"),	Color(84, 110, 122, 255),	2},
	radar		= {"Radar",				TEAM_SEEKER,	Material("superpedobear/powerup/radar"),	nil,						4},
	trap		= {"False Power-UP",	TEAM_SEEKER,	Material("superpedobear/powerup/trap"),		Color(255, 64, 64, 255)}
}

GM.PlayerMeta = GM.PlayerMeta or FindMetaTable("Player")
GM.PlayerMeta.RealNick = GM.PlayerMeta.RealNick or GM.PlayerMeta.Nick
function GM.PlayerMeta:Nick()
	if GAMEMODE:IsSeasonalEvent("LennyFaceDay") then return "( ͡° ͜ʖ ͡°)" end
	return self:RealNick()
end


function GM:IsSeasonalEvent(str)
	local Timestamp = os.time()
	for _, v in pairs(GAMEMODE.SeasonalEvents) do
		local i = 0
		if str == v[1] then
			while v[3 + i] do
				if (os.date("%d/%m", Timestamp) == v[3 + i]) then
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
	for _, v in pairs(GAMEMODE.SeasonalEvents) do
		local i = 0
		while v[3 + i] do
			if (os.date("%d/%m", Timestamp) == v[3 + i]) then
				return " - " .. v[2]
			end
			i = i + 1
		end
	end
	return ""
end

function GM:Initialize()

	sound.Add({
		name = "spb_yourethebear",
		channel = CHAN_STATIC,
		volume = 1.0,
		level = 0,
		sound = GAMEMODE.Sounds.YoureTheBear
	})

	spb_enabledevmode = CreateConVar("spb_enabledevmode", 0, FCVAR_NONE, "Dev mode and more logs.")
	spb_round_time = CreateConVar("spb_round_time", 180, {FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE}, "Time of a round in second.")
	spb_round_pretime = CreateConVar("spb_round_pretime", 15, {FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE}, "Time of the player waiting time in second.")
	spb_round_pre2time = CreateConVar("spb_round_pre2time", 15, {FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE}, "Time before seeker spawn.")
	spb_rounds = CreateConVar("spb_rounds", 8, {FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE}, "Number of rounds before map voting. Any value bellow 1 will disable map voting.")
	spb_afk_time = CreateConVar("spb_afk_time", 30, {FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE}, "Time needed for a player to be consired afk.")
	spb_afk_action = CreateConVar("spb_afk_action", 30, {FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE}, "Time needed for a player to be kick out of the seeker role when afk.")
	spb_save_chances = CreateConVar("spb_save_chances", 1, {FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE}, "Set if we should save the chances to be a seeker.")
	spb_slow_motion = CreateConVar("spb_slow_motion", 1, {FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE}, "Slow motion effect.")
	spb_rainbow_effect = CreateConVar("spb_rainbow_effect", 1, {FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE}, "Rainbow colors for the victims.")
	spb_powerup_enabled = CreateConVar("spb_powerup_enabled", 1, {FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE}, "Enable power-ups.")
	spb_powerup_autofill = CreateConVar("spb_powerup_autofill", 1, {FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE}, "Fill players with random power-ups on round start when the maps doesn't have any power-up spawner.")
	spb_powerup_radar_time = CreateConVar("spb_powerup_radar_time", 2, {FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE}, "Radar time.")
	spb_powerup_cloak_time = CreateConVar("spb_powerup_cloak_time", 4, {FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE}, "Cloak time.")
	spb_shop_enabled = CreateConVar("spb_shop_enabled", 1, {FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE}, "Enable the power-up shop.")
	spb_shop_base_price = CreateConVar("spb_shop_base_price", 4, {FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE}, "Power-ups base price. Negative values will be converted to positive and will ignore power-ups price addition. 0 will set everything to free.")
	spb_weapons = CreateConVar("spb_weapons", 0, {FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE}, "Give some weapons at spawn.")
	spb_votemap_prefixes = CreateConVar("spb_votemap_prefixes", "spb_|ph_|md_|mu_|ttt_", {FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE}, "Map prefixes to use for votemap. Prefixes are separated with pipes.")
	spb_jukebox_enable_input = CreateConVar("spb_jukebox_enable_input", 1, {FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE}, "Enable player input on the jukebox queue.")

	local damagesnd = file.Find("sound/superpedobear/damage/*.ogg", "GAME")

	for _, v in pairs(damagesnd) do
		table.insert(GAMEMODE.Sounds.Damage, Sound("superpedobear/damage/" .. v))
	end

	local deathsnd = file.Find("sound/superpedobear/death/*.ogg", "GAME")

	for _, v in pairs(deathsnd) do
		table.insert(GAMEMODE.Sounds.Death, Sound("superpedobear/death/" .. v))
	end

	if !file.IsDir("superpedobear", "DATA") then
		file.CreateDir("superpedobear")
	end

	if game.GetMap() == "spb_tutorial" then
		GAMEMODE.Vars.Tutorial = true
	end

	if CLIENT then

		local screen_ratio = ScrW() / ScrH()

		CreateClientConVar("spb_cl_disabletauntmenuclose", 0, true, false, "Don't close the taunt menu after taunting")
		CreateClientConVar("spb_cl_disablehalos", 0, true, false, "Disable halos (Improve performance)")
		CreateClientConVar("spb_cl_music_enable", 1, true, false, "Enable music")
		CreateClientConVar("spb_cl_music_volume", 0.5, true, false, "Music volume")
		CreateClientConVar("spb_cl_music_allowexternal", 1, true, false, "Allow external musics (Loaded from url)")
		CreateClientConVar("spb_cl_music_visualizer", 1, true, false, "Enable visualizer (Downgrade performance)")
		CreateClientConVar("spb_cl_hud_offset_w", 25, true, false, "Horizontal HUD Offset")
		CreateClientConVar("spb_cl_hud_offset_h", 25, true, false, "Vertical HUD Offset")
		CreateClientConVar("spb_cl_hide_tips", 0, true, false, "Hide all tips")
		CreateClientConVar("spb_cl_quickstuff_enable", 1, true, false, "Enable quick taunt and quick buy")
		CreateClientConVar("spb_cl_quickstuff_numpad", 1, true, false, "Use numpad aswell for quick stuff")

		cvars.AddChangeCallback("spb_cl_music_volume", function(convar_name, value_old, value_new)
			if IsValid(GAMEMODE.Vars.Music) then
				GAMEMODE.Vars.Music:SetVolume(GetConVar("spb_cl_music_volume"):GetFloat())
			end
		end)
		cvars.AddChangeCallback("spb_cl_music_enable", function(convar_name, value_old, value_new)
			value_new = GetConVar("spb_cl_music_enable"):GetBool()
			if IsValid(GAMEMODE.Vars.Music) and !value_new then
				GAMEMODE.Vars.Music:Stop()
				GAMEMODE.Vars.Music = nil
			elseif value_new and (GAMEMODE.Vars.Round.Start or GAMEMODE.Vars.Round.PreStart) then
				GAMEMODE:Music(GAMEMODE.Vars.CurrentMusic or "", GAMEMODE.Vars.Round.PreStart)
			end
		end)

	end

	if SERVER then

		GAMEMODE.Vars.PM_Available = player_manager.AllValidModels()
		GAMEMODE.Vars.PM_Default = {}
		if GAMEMODE.Vars.PM_Available["Homura Akemi"] then
			table.Merge(GAMEMODE.Vars.PM_Default, {"Homura Akemi", "Kyouko Sakura", "Madoka Kaname", "Mami Tomoe", "Sayaka Miki"})
		end
		if GAMEMODE.Vars.PM_Available["Tda Chibi Haku Append (v2)"] then
			table.insert(GAMEMODE.Vars.PM_Default, "Tda Chibi Haku Append (v2)")
		end
		if GAMEMODE.Vars.PM_Available["Tda Chibi Luka Append (v2)"] then
			table.insert(GAMEMODE.Vars.PM_Default, "Tda Chibi Luka Append (v2)")
		end
		if GAMEMODE.Vars.PM_Available["Tda Chibi Miku Append (v2)"] then
			table.insert(GAMEMODE.Vars.PM_Default, "Tda Chibi Miku Append (v2)")
		end
		if GAMEMODE.Vars.PM_Available["Tda Chibi Neru Append (v2)"] then
			table.insert(GAMEMODE.Vars.PM_Default, "Tda Chibi Neru Append (v2)")
		end
		if GAMEMODE.Vars.PM_Available["Tda Chibi Teto Append (v2)"] then
			table.insert(GAMEMODE.Vars.PM_Default, "Tda Chibi Teto Append (v2)")
		end
		if GAMEMODE.Vars.PM_Available["RAM"] then
			table.insert(GAMEMODE.Vars.PM_Default, "RAM")
		end
		if GAMEMODE.Vars.PM_Available["Rom"] then
			table.insert(GAMEMODE.Vars.PM_Default, "Rom")
		end
		if GAMEMODE.Vars.PM_Available["WH"] then
			table.insert(GAMEMODE.Vars.PM_Default, "WH")
		end

		if GetConVar("sv_loadingurl"):GetString() == "" then --Use the Xperidia's loading screen if no other loading screen is defined... Because it shows more information than the current default of Garry's Mod...
			RunConsoleCommand("sv_loadingurl", "https://xperidia.com/GMOD/loading/?auto")
		end
		RunConsoleCommand("sv_playermodel_selector_force", "0") --This is needed so bears won't get overriden
	end

	GAMEMODE:BuildMusicIndex()
	GAMEMODE:BuildTauntIndex()

end

function GM:ShutDown()
	if SERVER and GetConVar("sv_loadingurl"):GetString() == "https://xperidia.com/GMOD/loading/?auto" then --Put back the default Garry's Mod loading screen...
		RunConsoleCommand("sv_loadingurl", "")
	end
end

function GM:BuildMusicIndex()

	if !file.IsDir("superpedobear/musics", "DATA") then
		file.CreateDir("superpedobear/musics")
	end
	if !file.IsDir("superpedobear/premusics", "DATA") then
		file.CreateDir("superpedobear/premusics")
	end

	local function ReadMusicInfo(pre)

		local mlist = {}

		local lua = file.Find("pedo_musiclist/" .. Either(pre, "premusics", "musics") .. "/*.lua", "LUA")

		for _, v in pairs(lua) do
			local ft = include("pedo_musiclist/" .. Either(pre, "premusics", "musics") .. '/' .. v)
			table.Add(mlist, ft)
		end

		local infos = file.Find("superpedobear/" .. Either(pre, "premusics", "musics") .. "/*.txt", "DATA")

		for _, v in pairs(infos) do
			local fileml = file.Read("superpedobear/" .. Either(pre, "premusics", "musics") .. "/" .. v)
			local tmlist = util.JSONToTable(fileml)
			table.Add(mlist, tmlist)
		end

		return mlist

	end

	local musiclist = ReadMusicInfo()
	local premusiclist = ReadMusicInfo(true)

	if SERVER then
		GAMEMODE.Musics.musics = musiclist
		GAMEMODE.Musics.premusics = premusiclist
		if !game.IsDedicated() then GAMEMODE:SendMusicIndex() end
	else
		GAMEMODE.LocalMusics.musics = musiclist
		GAMEMODE.LocalMusics.premusics = premusiclist
	end

end

function GM:BuildTauntIndex()

	if SERVER then

		if !file.IsDir("superpedobear/taunts", "DATA") then
			file.CreateDir("superpedobear/taunts")
		end

		local function ReadTauntInfo()

			local mlist = {}

			local lua = file.Find("superpedobear/taunts/*.lua", "LUA")

			for _, v in pairs(lua) do
				local ft = include("superpedobear/taunts/" .. v)
				table.Add(mlist, ft)
			end

			local infos = file.Find("superpedobear/taunts/*.txt", "DATA")

			for _, v in pairs(infos) do
				local fileml = file.Read("superpedobear/taunts/" .. v)
				local tmlist = util.JSONToTable(fileml)
				table.Add(mlist, tmlist)
			end

			return mlist

		end

		local tauntlist = ReadTauntInfo()

		GAMEMODE.Taunts = tauntlist
		if !game.IsDedicated() then GAMEMODE:SendTauntIndex() end

	end

end

function GM:CreateTeams()

	team.SetUp(TEAM_HIDING, "Hiding", Color(247, 127, 190))
	team.SetSpawnPoint(TEAM_HIDING, {"info_player_start", "info_player_terrorist"})
	team.SetClass(TEAM_HIDING, {"player_hiding"})

	team.SetUp(TEAM_SEEKER, "Seekers", Color(139, 85, 46), false)
	team.SetSpawnPoint(TEAM_SEEKER, {"info_player_seekers", "info_player_counterterrorist"})
	team.SetClass(TEAM_SEEKER, {"player_seeker"})

	team.SetSpawnPoint(TEAM_SPECTATOR, "worldspawn")
	team.SetSpawnPoint(TEAM_UNASSIGNED, "worldspawn")

end

function GM:ShouldCollide(Ent1, Ent2)
	if Ent1:GetClass() == "spb_dummy" or Ent2:GetClass() == "spb_dummy" then
		return false
	end
	return true
end

function GM:Log(str, tn, hardcore)
	if hardcore and !spb_enabledevmode:GetBool() then return end
	Msg("[Super Pedobear] " .. (str or "This was a log message, but something went wrong") .. "\n")
end

function GM:GetHost()
	if GAMEMODE.Vars.Host and IsValid(GAMEMODE.Vars.Host) then
		return GAMEMODE.Vars.Host
	end
	for k, v in pairs(player.GetAll()) do
		local host = v:GetNWBool("IsListenServerHost", false)
		if host then
			GAMEMODE.Vars.Host = v
			return v
		end
	end
	return nil
end

function GM.PlayerMeta:GetPowerUP()
	if CLIENT then return self:GetNWString("spb_PowerUP", "none") end
	return self.SPB_PowerUP
end

function GM.PlayerMeta:HasPowerUP()
	if CLIENT then
		if self:GetNWString("spb_PowerUP", "none") != "none" then
			return true
		else
			return false
		end
	end
	if self.SPB_PowerUP and self.SPB_PowerUP != "none" then
		return true
	else
		return false
	end
end

function GM.PlayerMeta:IsCloaked()
	local var = self.spb_CloakTime or self:GetNWFloat("spb_CloakTime", nil)
	if !var then
		return nil
	end
	return var >= CurTime()
end

function GM:SelectRandomPowerUP(ply)
	for k, v in RandomPairs(GAMEMODE.PowerUps) do
		if !IsValid(ply) or v[2] == ply:Team() or v[2] == 0 then
			return k
		end
	end
	return nil
end

function GM:GetClosestPlayer(ply, pteam)
	local seeker
	local distance
	local t
	local list = team.GetPlayers(pteam)
	for k, v in pairs(list) do
		if v:Alive() and v:IsLineOfSightClear(ply) then
			t = v:GetPos():Distance(ply:GetPos())
			if (!distance or distance < t) then
				distance = t
				seeker = v
			end
		end
	end
	return seeker, distance
end

function GM:PlayerFootstep(ply, pos, foot, sound, volume, filter)
	if ply:IsCloaked() then
		return true
	end
end

function GM:GetPowerUpPrice(id, ply, ignorereduc)
	local price = spb_shop_base_price:GetInt()
	local ignoreadd = false
	if price == 0 then
		return 0
	elseif price < 0 then
		price = price * -1
		ignoreadd = true
	end
	if !ignoreadd and GAMEMODE.PowerUps[id] and GAMEMODE.PowerUps[id][5] then
		price = price + GAMEMODE.PowerUps[id][5]
	end
	if !ignorereduc and ply:GetNWInt("XperidiaRank", 0) > 0 then
		price = price / 2
	end
	return math.Round(price)
end

function GM.PlayerMeta:IsGamemodeAuthor() --Credits
	return self:SteamID() == "STEAM_0:1:18280147"
end
