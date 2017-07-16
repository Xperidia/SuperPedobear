--[[---------------------------------------------------------------------------
		⚠ This file is a part of the Super Pedobear gamemode ⚠
	⚠ Please do not redistribute any version of it (edited or not)! ⚠
	So please ask me directly or contribute on GitHub if you want something...
-----------------------------------------------------------------------------]]

DEFINE_BASECLASS("gamemode_base")

include("player_class/player_victim.lua")
include("player_class/player_pedobear.lua")

GM.Name 		= "Super Pedobear"
GM.ShortName 	= "SuperPedobear"
GM.Author 		= "VictorienXP@Xperidia"
GM.Website 		= "steamcommunity.com/sharedfiles/filedetails/?id=628449407"
GM.Version 		= 0.27
GM.VersionName	= "The first public release"
GM.TeamBased 	= true

TEAM_VICTIMS	= 1
TEAM_PEDOBEAR	= 2

GM.Sounds = {}
GM.Sounds.YoureThePedo	= Sound("superpedobear/yourethepedo.wav")
GM.Sounds.HeartBeat		= Sound("superpedobear/heartbeat.ogg")

GM.Sounds.Taunts = {}
table.insert(GM.Sounds.Taunts, {"Goat Gentleman", Sound("superpedobear/taunts/s1.ogg"), 0, 16.5})
table.insert(GM.Sounds.Taunts, {"Makka Pakka", Sound("superpedobear/taunts/s2.ogg"), 0, 13})
table.insert(GM.Sounds.Taunts, {"Stampy Intro", Sound("superpedobear/taunts/s3.ogg"), 0, 7})
table.insert(GM.Sounds.Taunts, {"Buttsauce", Sound("superpedobear/taunts/s4.ogg"), 0, 1})
table.insert(GM.Sounds.Taunts, {"Thomas the tank engine", Sound("superpedobear/taunts/s5.ogg"), 0, 7})
table.insert(GM.Sounds.Taunts, {"Get your lollipops", Sound("superpedobear/taunts/p1.ogg"), TEAM_PEDOBEAR, 6})
table.insert(GM.Sounds.Taunts, {"MY PEE PEE", Sound("superpedobear/taunts/s6.ogg"), 0, 20.5})

GM.Sounds.Damage	= GM.Sounds.Damage or {}
GM.Sounds.Death		= GM.Sounds.Death or {}

GM.Materials = {}
GM.Materials.PedoVan = Material("superpedobear/pedovan")
GM.Materials.Pedobear = Material("superpedobear/pedobear")

GM.Vars = GM.Vars or {}
GM.Vars.Round = GM.Vars.Round or {}
GM.Bots = GM.Bots or {}
GM.Musics = GM.Musics or {}
if CLIENT then GM.LocalMusics = GM.LocalMusics or {} end

GM.SeasonalEvents = {
	{"AprilFool", "April Fool", "01/04"},
	{"Halloween", "Halloween", "31/10"},
	{"Christmas", "Christmas", "24/12", "25/12"},
	{"PedobearDay", "Pedobear Anniversary", "10/02"},
	{"LennyFaceDay", "Lenny Face Anniversary", "18/11"}
}

GM.PowerUps = {
	clone = {"Clone", TEAM_VICTIMS, Material("superpedobear/powerup/clone"), Color(255, 200, 50, 255)},
	boost = {"Boost", TEAM_VICTIMS, Material("superpedobear/powerup/boost"), Color(255, 128, 0, 255)},
	--vdisguise = {"Disguise", TEAM_VICTIMS, Material("superpedobear/powerup/vdisguise")},
	--pdisguise = {"Disguise", TEAM_PEDOBEAR, Material("superpedobear/powerup/pdisguise")},
	radar = {"Radar", TEAM_PEDOBEAR, Material("superpedobear/powerup/radar")},
	trap = {"False Power-UP", TEAM_PEDOBEAR, Material("superpedobear/powerup/trap"), Color(255, 64, 64, 255)}
}

GM.PlayerMeta = GM.PlayerMeta or FindMetaTable("Player")
GM.PlayerMeta.RealNick = GM.PlayerMeta.RealNick or GM.PlayerMeta.Nick
function GM.PlayerMeta:Nick()
	if GAMEMODE:IsSeasonalEvent("LennyFaceDay") then return "( ͡° ͜ʖ ͡°)" end
	return self:RealNick()
end

GM.PlayerEasterEgg = {}
--GM.PlayerEasterEgg["SteamID64"] = {<playermodel>, <jumpscare texture>, <custom music>, <custom announce>}
GM.PlayerEasterEgg["76561198108011282"] = {Model("models/player/nachocheese.mdl"), "superpedobear/pepperscare", "https://xperidia.com/PedoMusics/76561198108011282.mp3", "IT'S CHEEZY TIME WITH %s"} --Marco


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
		name = "superpedobear_yourethepedo",
		channel = CHAN_STATIC,
		volume = 1.0,
		level = 0,
		sound = GAMEMODE.Sounds.YoureThePedo
	})

	superpedobear_enabledevmode = CreateConVar("superpedobear_enabledevmode", 0, FCVAR_NONE, "Dev mode and more logs.")
	superpedobear_round_time = CreateConVar("superpedobear_round_time", 180, {FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE}, "Time of a round in second.")
	superpedobear_round_pretime = CreateConVar("superpedobear_round_pretime", 15, {FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE}, "Time of the player waiting time in second.")
	superpedobear_round_pre2time = CreateConVar("superpedobear_round_pre2time", 15, {FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE}, "Time before pedobear spawn.")
	superpedobear_afk_time = CreateConVar("superpedobear_afk_time", 30, {FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE}, "Time needed for a player to be consired afk.")
	superpedobear_afk_action = CreateConVar("superpedobear_afk_action", 30, {FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE}, "Time needed for a player to be kick out of pedobear when afk.")
	superpedobear_save_chances = CreateConVar("superpedobear_save_chances", 1, {FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE}, "Set if we should save the chances to be Pedobear.")

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

	if CLIENT then

		CreateClientConVar("superpedobear_cl_disablexpsc", 0, true, false)
		CreateClientConVar("superpedobear_cl_disabletauntmenuclose", 0, true, false)
		CreateClientConVar("superpedobear_cl_jumpscare", 0, true, true )
		CreateClientConVar("superpedobear_cl_disablehalos", 0, true, false)
		CreateClientConVar("superpedobear_cl_music_enable", 1, true, false)
		CreateClientConVar("superpedobear_cl_music_volume", 0.5, true, false)
		CreateClientConVar("superpedobear_cl_music_allowexternal", 1, true, false)
		CreateClientConVar("superpedobear_cl_music_visualizer", 1, true, false)
		CreateClientConVar("superpedobear_cl_hud_offset", 0, true, false)
		CreateClientConVar("superpedobear_cl_hide_tips", 0, true, false)

		cvars.AddChangeCallback("superpedobear_cl_music_volume", function(convar_name, value_old, value_new)
			if IsValid(GAMEMODE.Vars.Music) then
				GAMEMODE.Vars.Music:SetVolume(GetConVar("superpedobear_cl_music_volume"):GetFloat())
			end
		end)
		cvars.AddChangeCallback("superpedobear_cl_music_enable", function(convar_name, value_old, value_new)
			value_new = GetConVar("superpedobear_cl_music_enable"):GetBool()
			if IsValid(GAMEMODE.Vars.Music) and !value_new then
				GAMEMODE.Vars.Music:Stop()
				GAMEMODE.Vars.Music = nil
			elseif value_new and (GAMEMODE.Vars.Round.Start or GAMEMODE.Vars.Round.PreStart) then
				GAMEMODE:Music(GAMEMODE.Vars.CurrentMusic or "", GAMEMODE.Vars.Round.PreStart)
			end
		end)

	end

	GAMEMODE:BuildMusicIndex()

end

function GM:ShutDown()
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

function GM:CreateTeams()

	team.SetUp(TEAM_VICTIMS, "Victims", Color(247, 127, 190))
	team.SetSpawnPoint(TEAM_VICTIMS, {"info_player_start", "info_player_terrorist"})
	team.SetClass(TEAM_VICTIMS, {"player_victim"})

	team.SetUp(TEAM_PEDOBEAR, "Pedobear", Color(139, 85, 46), false)
	team.SetSpawnPoint(TEAM_PEDOBEAR, {"superpedobear_pedobearstart", "info_player_counterterrorist"})
	team.SetClass(TEAM_PEDOBEAR, {"player_pedobear"})

	team.SetSpawnPoint(TEAM_SPECTATOR, "worldspawn")
	team.SetSpawnPoint(TEAM_UNASSIGNED, "worldspawn")

end

function GM:ShouldCollide(Ent1, Ent2)
	if Ent1:GetClass() == "superpedobear_dummy" or Ent2:GetClass() == "superpedobear_dummy" then
		return false
	end
	return true
end

function GM:Log(str, tn, hardcore)
	if hardcore and !superpedobear_enabledevmode:GetBool() then return end
	Msg("[SuperPedobear] " .. (str or "This was a log message, but something went wrong") .. "\n")
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
	if CLIENT then return self:GetNWString("SuperPedobear_PowerUP", "none") end
	return self.SPB_PowerUP
end

function GM.PlayerMeta:HasPowerUP()
	if CLIENT then
		if self:GetNWString("SuperPedobear_PowerUP", "none") != "none" then
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

function GM:SelectRandomPowerUP(ply)
	for k, v in RandomPairs(GAMEMODE.PowerUps) do
		if !IsValid(ply) or v[2] == ply:Team() then
			return k
		end
	end
	return nil
end
