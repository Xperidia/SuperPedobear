--[[---------------------------------------------------------------------------
		⚠ This file is a part of the Super Pedobear gamemode ⚠
	⚠ Please do not redistribute any version of it (edited or not)! ⚠
	So please ask me directly or contribute on GitHub if you want something...
-----------------------------------------------------------------------------]]

AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_scoreboard.lua")
AddCSLuaFile("cl_menu.lua")
AddCSLuaFile("cl_tauntmenu.lua")
AddCSLuaFile("cl_voice.lua")
AddCSLuaFile("cl_deathnotice.lua")
AddCSLuaFile("cl_pedovan.lua")

include("shared.lua")

DEFINE_BASECLASS("gamemode_base")

resource.AddWorkshop("111603898")
resource.AddWorkshop("481073360")
resource.AddWorkshop("628449407")
resource.AddWorkshop("232539187") --Marco

util.AddNetworkString("SuperPedobear_Vars")
util.AddNetworkString("SuperPedobear_PlayerStats")
util.AddNetworkString("SuperPedobear_Notif")
util.AddNetworkString("SuperPedobear_Taunt")
util.AddNetworkString("SuperPedobear_Music")
util.AddNetworkString("SuperPedobear_AFK")
util.AddNetworkString("SuperPedobear_MusicList")
util.AddNetworkString("PlayerKilledDummy")
util.AddNetworkString("NPCKilledDummy")
util.AddNetworkString("SuperPedobear_List")
util.AddNetworkString("SuperPedobear_MusicQueue")
util.AddNetworkString("SuperPedobear_MusicAddToQueue")
util.AddNetworkString("SuperPedobear_MusicQueueVote")

local LegitUse

function GM:PlayerInitialSpawn(ply)

	GAMEMODE:RetrieveXperidiaAccountRank(ply)

	if ply:IsBot() then
		ply:SetTeam(TEAM_VICTIMS)
		ply:SetNWFloat("SuperPedobear_PedoChance", 0)
	else
		ply:SetTeam(TEAM_UNASSIGNED)
		GAMEMODE:LoadChances(ply)
		GAMEMODE:LoadPlayerInfo(ply)
	end

	if !game.IsDedicated() then
		if ply:IsListenServerHost() then
			ply:SetNWBool("IsListenServerHost", true)
		end
	end

	GAMEMODE:PedoVars(ply)
	GAMEMODE:SendMusicIndex(ply)
	GAMEMODE:SendMusicQueue(ply)

end

function GM:PlayerSpawn(ply)

	if ply:Team() == TEAM_UNASSIGNED or ply:Team() == TEAM_SPECTATOR then

		GAMEMODE:PlayerSpawnAsSpectator(ply)
		ply:SetPos(ply:GetPos() + Vector(0, 0, 32))

	elseif ply:Team() == TEAM_VICTIMS or ply:Team() == TEAM_PEDOBEAR then

		local pteam = ply:Team()
		local spawnpoints = team.GetSpawnPoints(pteam)
		local spawnpoint = spawnpoints[math.random(1, #spawnpoints)]
		if IsValid(spawnpoint) then
			ply:SetPos(spawnpoint:GetPos())
		end
		local classes = team.GetClass(pteam)
		player_manager.SetPlayerClass(ply, classes[math.random( 1, #classes )])

	end

	BaseClass.PlayerSpawn(self, ply)

	GAMEMODE:PlayerStats()

end

function GM:PlayerDisconnected(ply)
	GAMEMODE:StoreChances(ply)
	GAMEMODE:StorePlayerInfo(ply)
end

function GM:PedoVars(ply)

	net.Start("SuperPedobear_Vars")
		net.WriteBool(GAMEMODE.Vars.Round.Start or false)
		net.WriteBool(GAMEMODE.Vars.Round.PreStart or false)
		net.WriteFloat(GAMEMODE.Vars.Round.PreStartTime or 0)
		net.WriteFloat(GAMEMODE.Vars.Round.Time or 0)
		net.WriteBool(GAMEMODE.Vars.Round.End or false)
		net.WriteInt(tonumber(GAMEMODE.Vars.Round.Win) or 0, 32)
		net.WriteInt(GAMEMODE.Vars.Rounds or 1, 32)
		net.WriteFloat(GAMEMODE.Vars.Round.LastTime or 0)
	if IsValid(ply) then net.Send(ply) else net.Broadcast() end

end

local function Registration()
	http.Post("https://xperidia.com/monitor.php", { kind = "SuperPedobear", version = tostring(GAMEMODE.Version), key = file.Read("superpedobear/key.txt"), ip = game.GetIPAddress(), servername = GetHostName() },
		function(responseText, contentLength, responseHeaders, statusCode)
			local resp = util.JSONToTable(responseText)
			if statusCode == 200 and resp and resp.response and resp.response.success then
				GAMEMODE:Log(resp.response.message)
				LegitUse = resp.response.success
			elseif resp and resp.response then
				GAMEMODE:Log(resp.response.message)
				LegitUse = false
			else
				GAMEMODE:Log("Error " .. statusCode .. " while trying registering...")
			end
		end,
		function(errorMessage)
			GAMEMODE:Log(errorMessage)
		end)
end

function GM:SelectMusic(pre)

	GAMEMODE:BuildMusicIndex()

	local mlist = Either(pre, GAMEMODE.Musics.premusics, GAMEMODE.Musics.musics)

	if #mlist > 0 then

		local mid = math.random(1, #mlist)
		local src = mlist[mid][1]

		if !string.match(mlist[mid][1], "://") then
			src = "sound/superpedobear/" .. Either(pre, "premusics", "musics") .. "/" .. src
		end

		GAMEMODE.Vars.CurrentMusic = src
		GAMEMODE.Vars.CurrentMusicName = mlist[mid][2]

	end

	GAMEMODE:PedoMusic(GAMEMODE.Vars.CurrentMusic, pre, nil, GAMEMODE.Vars.CurrentMusicName)

end

function GM:PedoMusic(src, pre, ply, name)

	net.Start("SuperPedobear_Music")
		net.WriteString(src or "")
		net.WriteBool(pre or false)
		net.WriteString(name or "")
	if IsValid(ply) then net.Send(ply) else net.Broadcast() end

end

function GM:SendMusicQueue(ply)
	net.Start("SuperPedobear_MusicQueue")
		net.WriteTable(GAMEMODE.Vars.MusicQueue or {})
	if IsValid(ply) then net.Send(ply) else net.Broadcast() end
end

net.Receive("SuperPedobear_MusicAddToQueue", function(bits, ply)
	local music = net.ReadString()
	GAMEMODE:MusicQueueAdd(ply, music)
end)
function GM:MusicQueueAdd(ply, musicsrc)
	if !GAMEMODE.Vars.MusicQueue then GAMEMODE.Vars.MusicQueue = {} end
	GAMEMODE.Vars.MusicQueue[ply] = {}
	GAMEMODE.Vars.MusicQueue[ply].music = musicsrc
	GAMEMODE.Vars.MusicQueue[ply].votes = {ply}
	GAMEMODE:SendMusicQueue()
end

net.Receive("SuperPedobear_MusicQueueVote", function(bits, ply)
	local qply = net.ReadEntity()
	GAMEMODE:MusicQueueVote(ply, qply)
end)
function GM:MusicQueueVote(ply, qply)
	if !IsValid(qply) then
		return
	end
	if table.HasValue(GAMEMODE.Vars.MusicQueue[qply].votes, ply) then
		table.RemoveByValue(GAMEMODE.Vars.MusicQueue[qply].votes, ply)
	else
		table.insert(GAMEMODE.Vars.MusicQueue[qply].votes, ply)
	end
	GAMEMODE:SendMusicQueue()
end

function GM:MusicQueueSelect()
	if !GAMEMODE.Vars.MusicQueue then return nil end
	local winner
	local who
	for k, v in RandomPairs(GAMEMODE.Vars.MusicQueue) do
		if !winner or #v.votes > #winner.votes then
			who = k
			winner = v
		end
	end
	if who and winner then
		GAMEMODE.Vars.MusicQueue[who] = nil
		GAMEMODE:SendMusicQueue()
		return winner.music
	end
	return nil
end

function GM:PostPlayerDeath(ply)
	GAMEMODE:PlayerStats()
	GAMEMODE:RetrieveXperidiaAccountRank(ply)
end

function GM:PlayerDeathSound()
	return true
end

function GM:PlayerDeathThink(ply)

	if ply:Team() == TEAM_PEDOBEAR and GAMEMODE.Vars.Round.Start and !GAMEMODE.Vars.Round.End and !GAMEMODE.Vars.Round.TempEnd then
		ply:Spawn()
		return
	end

	if ply:Team() == TEAM_VICTIMS or ply:Team() == TEAM_PEDOBEAR then GAMEMODE:SpecControl(ply) end

	if GAMEMODE.Vars.Round.Start then return end

	if ply.NextSpawnTime and ply.NextSpawnTime > CurTime() then return end

	if ply:IsBot() or ply:KeyPressed(IN_ATTACK) or ply:KeyPressed(IN_ATTACK2) or ply:KeyPressed(IN_JUMP) then
		ply:UnSpectate()
		ply:Spawn()
	end

end

function GM:PlayerStats()

	GAMEMODE.Vars.victims = 0

	for k, v in pairs(team.GetPlayers(TEAM_VICTIMS)) do
		if IsValid(v) and v:Alive() then
			GAMEMODE.Vars.victims = GAMEMODE.Vars.victims + 1
		end
	end

	net.Start("SuperPedobear_PlayerStats")
		net.WriteInt(GAMEMODE.Vars.victims, 32)
		net.WriteInt(GAMEMODE.Vars.downvictims or 0, 32)
	net.Broadcast()

end

function GM:KeyPress(ply, key)
	if ply:Team() == TEAM_UNASSIGNED and !ply:KeyPressed(IN_SCORE) then
		ply:SetTeam(TEAM_VICTIMS)
		ply:Spawn()
		if GAMEMODE.Vars.Round.Start then
			ply:KillSilent()
		end
	elseif ply:Team() == TEAM_SPECTATOR or ply:Team() == TEAM_UNASSIGNED then
		GAMEMODE:SpecControl(ply)
	end
end

function GM:SpecControl(ply, manual)

	local players = {}

	for k, v in pairs(player.GetAll()) do
		local vteam = v:Team()
		if v:Alive() and (vteam == TEAM_VICTIMS or vteam == TEAM_PEDOBEAR) and v != ply and vteam != TEAM_UNASSIGNED and vteam != TEAM_SPECTATOR then
			table.insert(players, v)
		end
	end

	if ply:KeyPressed(IN_ATTACK) or manual then

		if !ply.SpecMODE then ply.SpecMODE = OBS_MODE_CHASE end

		ply:Spectate(ply.SpecMODE)

		if !ply.SpecID then ply.SpecID = 0 end

		ply.SpecID = ply.SpecID + 1

		if ply.SpecID > #players then ply.SpecID = 1 end

		ply:SpectateEntity(players[ply.SpecID])
		ply:SetupHands(players[ply.SpecID])

	elseif ply:KeyPressed(IN_ATTACK2) then

		if !ply.SpecMODE then ply.SpecMODE = OBS_MODE_CHASE end

		ply:Spectate(ply.SpecMODE)

		if !ply.SpecID then ply.SpecID = 2 end

		ply.SpecID = ply.SpecID - 1

		if ply.SpecID <= 0 then ply.SpecID = #players end

		ply:SpectateEntity(players[ply.SpecID])
		ply:SetupHands(players[ply.SpecID])

	elseif ply:KeyPressed(IN_JUMP) then

		if !ply.SpecMODE then ply.SpecMODE = OBS_MODE_CHASE end

		if ply.SpecMODE == OBS_MODE_IN_EYE then
			ply.SpecMODE = OBS_MODE_CHASE
		elseif ply.SpecMODE == OBS_MODE_CHASE then
			ply.SpecMODE = OBS_MODE_ROAMING
		elseif ply.SpecMODE == OBS_MODE_ROAMING then
			ply.SpecMODE = OBS_MODE_IN_EYE
		end

		ply:Spectate(ply.SpecMODE)

	end

end

function GM:DoTheVictoryDance(wteam)

	local pv

	for k, v in RandomPairs(team.GetPlayers(wteam)) do

		v:ConCommand("act dance")
		v:SendLua([[RunConsoleCommand("act", "dance")]])

		if !IsValid(pv) then
			pv = v
		end

	end

	if IsValid(pv) then

		for k, v in pairs(player.GetAll()) do

			if v:Alive() and v:Team() != wteam then v:KillSilent() end

			if v:Team() != wteam and v:Team() != TEAM_UNASSIGNED and v:Team() != TEAM_SPECTATOR then

				v.SpecMODE = OBS_MODE_CHASE

				v:Spectate(v.SpecMODE)

				v:SpectateEntity( pv )
				v:SetupHands( pv )

			end

		end

		timer.Create("SuperPedobear_ReviewPlayers", 2, 0, function()

			if GAMEMODE.Vars.Round.End or GAMEMODE.Vars.Round.TempEnd then

				for k, v in pairs(player.GetAll()) do

					if !v:Alive() then
						GAMEMODE:SpecControl(v, true)
					end

				end

			else

				timer.Remove("SuperPedobear_ReviewPlayers")

			end

		end)

	end

end

function GM:Think()

	for k, v in pairs(player.GetAll()) do
		if v:Team() == TEAM_PEDOBEAR then
			if GAMEMODE.PlayerEasterEgg[v:SteamID64()] and GAMEMODE.PlayerEasterEgg[v:SteamID64()][1] and v:GetModel() != GAMEMODE.PlayerEasterEgg[v:SteamID64()][1] then
				v:SetModel( GAMEMODE.PlayerEasterEgg[v:SteamID64()][1] )
			elseif (!GAMEMODE.PlayerEasterEgg[v:SteamID64()] or (GAMEMODE.PlayerEasterEgg[v:SteamID64()] and !GAMEMODE.PlayerEasterEgg[v:SteamID64()][1])) and v:GetModel() != "models/player/pbear/pbear.mdl" then
				v:SetModel(Model("models/player/pbear/pbear.mdl"))
			end
		elseif v:Team() == TEAM_VICTIMS and v:Alive() then
				if v:GetModel() == "models/player/pbear/pbear.mdl" then
					v:SetModel(Model("models/jazzmcfly/magica/homura_mg.mdl"))
				end
		end
	end

	for k, v in pairs(team.GetPlayers(TEAM_VICTIMS)) do

		if v:Alive() then
			local a = math.Clamp(v:Health(), 0, 100) / 100
			local doffset = v:EntIndex()
			v:SetPlayerColor( Vector(   (0.5 * (math.sin((CurTime() * a + doffset) - 1) + 1)) * a,
										(0.5 * (math.sin(CurTime() * a + doffset) + 1)) * a,
										(0.5 * (math.sin((CurTime() * a + doffset) + 1) + 1)) * a ) )
		end

	end

	if !GAMEMODE.Vars.CheckTime or GAMEMODE.Vars.CheckTime + 0.1 <= CurTime() then

		for k, v in pairs(player.GetAll()) do

			if v:Team() == TEAM_VICTIMS then

				if v:Alive() and GAMEMODE.Vars.Round.Start and v.Sprinting and (!v.SprintV or v.SprintV > 0) and !v.SprintLock then
					v.SprintV = (v.SprintV or 100) - 1
				elseif v:Alive() and ((!v.Sprinting and v:IsOnGround()) or v.SprintLock) and v.SprintV and v.SprintV < 100 then
					v.SprintV = v.SprintV + 1
				elseif !v:Alive() and (!v.SprintV or v.SprintV != 100) then
					v.SprintV = 100
				end

				if v.SprintV then

					if v.SprintV <= 0 and !v.SprintLock then
						v.SprintLock = true
						v:SetRunSpeed(200)
					elseif v.SprintV >= 85 and v.SprintLock then
						v.SprintLock = false
						v:SetRunSpeed(400)
					end

					v:SetNWInt("SprintV", v.SprintV)
					v:SetNWInt("SprintLock", v.SprintLock)

				end

			elseif (!v.SprintV or v.SprintV != 100) then

				v.SprintV = 100
				v:SetNWInt("SprintV", v.SprintV)

			end

		end

		GAMEMODE.Vars.CheckTime = CurTime()

	end

	if !GAMEMODE.Vars.LastCount or GAMEMODE.Vars.LastCount != #team.GetPlayers(TEAM_VICTIMS) then
		GAMEMODE.Vars.LastCount = #team.GetPlayers(TEAM_VICTIMS)
		GAMEMODE:PlayerStats()
	end

	GAMEMODE:RoundThink()

	if GAMEMODE:IsSeasonalEvent("AprilFool") then
		physenv.SetGravity(Vector(math.Rand(-4096, 4096), math.Rand(-4096, 4096), math.Rand(-4096, 4096)))
	end

end

function GM:RoundThink()

	if !GAMEMODE.Vars.Round.Start and !GAMEMODE.Vars.Round.PreStart then -- PreRound

		if GAMEMODE.Vars.victims and GAMEMODE.Vars.victims >= 2 and (!MapVote or (MapVote and !MapVote.Allow)) then

			GAMEMODE.Vars.Round.PreStart = true

			GAMEMODE.Vars.Round.PreStartTime = CurTime() + superpedobear_round_pretime:GetFloat()

			GAMEMODE:SelectMusic(true)

			GAMEMODE:PedoVars()

			GAMEMODE:Log("The game will start at " .. GAMEMODE.Vars.Round.PreStartTime, nil, true)

			if !LegitUse and !game.IsDedicated() then
				LegitUse = true
			elseif !LegitUse then
				Registration()
			end

		end

	elseif !GAMEMODE.Vars.Round.Start and GAMEMODE.Vars.Round.PreStart and GAMEMODE.Vars.Round.PreStartTime and GAMEMODE.Vars.Round.PreStartTime < CurTime() then -- Starting Round

		if GAMEMODE.Vars.victims and GAMEMODE.Vars.victims >= 2 and LegitUse then

			GAMEMODE.Vars.Round.Start = true
			GAMEMODE.Vars.Round.PreStart = false

			GAMEMODE.Vars.Round.PreStartTime = 0
			GAMEMODE.Vars.Round.Time = CurTime() + superpedobear_round_time:GetFloat()

			local Pedos = {}
			local WantedPedos = 1
			local PedoIndex = 1
			local tw = "the"

			if GAMEMODE.Vars.victims >= 64 then
				WantedPedos = 4
			elseif GAMEMODE.Vars.victims >= 32 then
				WantedPedos = 3
			elseif GAMEMODE.Vars.victims >= 24 then
				WantedPedos = 2
			end

			GAMEMODE:Log(WantedPedos .. " pedobear(s) will be selected", nil, true)

			while #Pedos != WantedPedos do

				local plys = team.GetPlayers(TEAM_VICTIMS)

				for k, v in RandomPairs(plys) do

					if !Pedos[PedoIndex] or (IsValid(Pedos[PedoIndex]) and (Pedos[PedoIndex]:GetNWFloat("SuperPedobear_PedoChance", 0) < v:GetNWFloat("SuperPedobear_PedoChance", 0))) then
						Pedos[PedoIndex] = v
					end

					GAMEMODE:Log(v:GetName() .. " have " .. (v:GetNWFloat("SuperPedobear_PedoChance", 0) * 100) .. "% chance to be a Pedobear" .. Either(Pedos[PedoIndex] == v, " and is currently selected", ""), nil, true)

				end

				GAMEMODE:Log(Pedos[PedoIndex]:GetName() .. " has been selected to be Pedobear " .. PedoIndex, nil, true)

				if IsValid(Pedos[PedoIndex]) then
					Pedos[PedoIndex]:SetTeam(TEAM_PEDOBEAR)
					Pedos[PedoIndex]:KillSilent()
					Pedos[PedoIndex]:SetNWFloat("SuperPedobear_PedoChance", 0)
					PedoIndex = PedoIndex + 1
				end

			end

			if #Pedos > 1 then
				tw = "a"
			end

			for k, v in pairs(Pedos) do

				--PrintMessage( HUD_PRINTTALK, v:Nick().." is "..tw.." pedobear!" )
				v:SendLua([[LocalPlayer():EmitSound("superpedobear_yourethepedo") system.FlashWindow()]])
				GAMEMODE:PedoAFKCare(v)

			end

			net.Start("SuperPedobear_List")
				net.WriteTable(Pedos)
			net.Broadcast()

			timer.Create("SuperPedobear_TempoStart", 0.2, 1, function()

				local custommusic = false

				for k, v in pairs(team.GetPlayers(TEAM_PEDOBEAR)) do

					if GAMEMODE.PlayerEasterEgg[v:SteamID64()] and GAMEMODE.PlayerEasterEgg[v:SteamID64()][3] then

						GAMEMODE.Vars.CurrentMusic = GAMEMODE.PlayerEasterEgg[v:SteamID64()][3]
						GAMEMODE.Vars.CurrentMusicName = v:Nick()
						custommusic = true

					end

				end

				if custommusic then
					GAMEMODE:PedoMusic(GAMEMODE.Vars.CurrentMusic, false, nil, GAMEMODE.Vars.CurrentMusicName)
				else
					local jukebox = GAMEMODE:MusicQueueSelect()
					if jukebox then
						GAMEMODE.Vars.CurrentMusic = jukebox
						GAMEMODE.Vars.CurrentMusicName = nil
						GAMEMODE:PedoMusic(GAMEMODE.Vars.CurrentMusic)
					else
						GAMEMODE:SelectMusic()
					end
				end

				GAMEMODE:PlayerStats()

				timer.Remove("SuperPedobear_TempoStart")

			end)

		elseif !LegitUse then

			GAMEMODE.Vars.Round.PreStart = false

			net.Start("SuperPedobear_Notif")
				net.WriteString("The gamemode is not registered!")
				net.WriteInt(1, 3)
				net.WriteFloat(5)
				net.WriteBit(true)
			net.Broadcast()

		else

			GAMEMODE.Vars.Round.PreStart = false

			net.Start("SuperPedobear_Notif")
				net.WriteString("Not enough players!")
				net.WriteInt(1, 3)
				net.WriteFloat(5)
				net.WriteBit(true)
			net.Broadcast()

		end

		GAMEMODE:PedoVars()

	elseif GAMEMODE.Vars.Round.Start and !GAMEMODE.Vars.Round.TempEnd then -- Round end

		if #team.GetPlayers(TEAM_PEDOBEAR) == 0 then

			GAMEMODE.Vars.Round.End = true
			GAMEMODE.Vars.Round.LastTime = GAMEMODE.Vars.Round.Time - CurTime()

		elseif GAMEMODE.Vars.victims and GAMEMODE.Vars.victims <= 0 then

			GAMEMODE.Vars.Round.End = true
			GAMEMODE.Vars.Round.Win = TEAM_PEDOBEAR
			GAMEMODE.Vars.Round.LastTime = GAMEMODE.Vars.Round.Time - CurTime()
			team.AddScore(TEAM_PEDOBEAR, 1)

			GAMEMODE:DoTheVictoryDance(TEAM_PEDOBEAR)

		elseif GAMEMODE.Vars.Round.Time < CurTime() then

			GAMEMODE.Vars.Round.End = true
			GAMEMODE.Vars.Round.Win = TEAM_VICTIMS
			GAMEMODE.Vars.Round.LastTime = 0
			team.AddScore( TEAM_VICTIMS, 1 )

			GAMEMODE:DoTheVictoryDance(TEAM_VICTIMS)

		end

		if GAMEMODE.Vars.Round.End then

			GAMEMODE.Vars.Round.TempEnd = true
			GAMEMODE.Vars.Round.Time = 0
			GAMEMODE:PedoVars()
			GAMEMODE.Vars.Round.End = false
			GAMEMODE.Vars.Round.Win = 0
			GAMEMODE.Vars.Rounds = (GAMEMODE.Vars.Rounds or 0) + 1

			--GAMEMODE:PedoMusic("pause")

			if MapVote and GAMEMODE.Vars.Rounds >= 8 then
				MapVote.Start(nil, nil, nil, {"spb_", "ph_"})
			end

			timer.Create( "SuperPedobear_TempoPreEnd", 9.8, 1, function()

				for k, v in pairs(team.GetPlayers(TEAM_PEDOBEAR)) do
					v:KillSilent()
				end

				for k, v in pairs(team.GetPlayers(TEAM_VICTIMS)) do
					if v:Alive() then v:KillSilent() end
				end

				timer.Remove("SuperPedobear_TempoPreEnd")

			end)

			timer.Create("SuperPedobear_TempoEnd", 10, 1, function()

				GAMEMODE.Vars.Round.Start = false
				GAMEMODE.Vars.Round.End = false
				GAMEMODE.Vars.Round.TempEnd = false
				GAMEMODE.Vars.downvictims = 0

				GAMEMODE.Vars.CurrentMusic = nil
				GAMEMODE.Vars.CurrentMusicName = nil

				net.Start("SuperPedobear_List")
					net.WriteTable({})
				net.Broadcast()

				GAMEMODE:PedoMusic("stop")

				game.CleanUpMap()

				for k, v in pairs(team.GetPlayers(TEAM_VICTIMS)) do
					if !v:Alive() then v:Spawn() end
					if !v:IsBot() and !v.IsAFK then v:SetNWFloat("SuperPedobear_PedoChance", v:GetNWFloat("SuperPedobear_PedoChance", 0) + 0.01) end
				end

				for k, v in pairs(team.GetPlayers(TEAM_PEDOBEAR)) do
					v:SetTeam(TEAM_VICTIMS)
					v:Spawn()
				end

				GAMEMODE:StoreChances()
				GAMEMODE:StorePlayerInfo(ply)
				GAMEMODE:PedoVars()
				GAMEMODE:PlayerStats()

				timer.Remove("SuperPedobear_TempoEnd")

			end)

		end

	end

end

function GM:OnPlayerChangedTeam( ply, oldteam, newteam )

	if newteam == TEAM_SPECTATOR then

		ply:SetPlayerColor(Vector(0, 0, 0))

		local Pos = ply:EyePos()
		ply:Spawn()
		ply:SetPos(Pos)

	elseif newteam == TEAM_VICTIMS and GAMEMODE.Vars.Round.Start then

		ply:KillSilent()

	end

	if oldteam == TEAM_PEDOBEAR then

		PrintMessage(HUD_PRINTTALK, Format("%s left the Pedobear role!", ply:Nick()))

	elseif newteam == TEAM_VICTIMS then

		PrintMessage(HUD_PRINTTALK, Format("%s joined the game!", ply:Nick()))

	else

		PrintMessage(HUD_PRINTTALK, Format("%s joined '%s'", ply:Nick(), team.GetName(newteam)))

	end

end

function GM:DoPlayerDeath(ply, attacker, dmginfo)

	ply:CreateRagdoll()

	ply:AddDeaths(1)

	if ply:Team() == TEAM_VICTIMS and GAMEMODE.Vars.Round.Start then

		if #GAMEMODE.Sounds.Death > 0 then
			ply:EmitSound(GAMEMODE.Sounds.Death[math.random(1, #GAMEMODE.Sounds.Death)], 100, 100, 1, CHAN_AUTO)
		end

	end

	if attacker:IsValid() and attacker:IsPlayer() then

		if attacker != ply and attacker:Team() == TEAM_PEDOBEAR then
			attacker:AddFrags(1)
			attacker:SetNWInt("SuperPedobear_TotalVictims", attacker:GetNWInt("SuperPedobear_TotalVictims", 0) + 1)
			attacker:SetNWInt("SuperPedobear_VictimsCurrency", attacker:GetNWInt("SuperPedobear_VictimsCurrency", 0) + 1)
			if GAMEMODE:IsSeasonalEvent("Halloween") or ply:GetInfoNum("superpedobear_cl_jumpscare", 0) == 1 then
				if GAMEMODE.PlayerEasterEgg[attacker:SteamID64()] and GAMEMODE.PlayerEasterEgg[attacker:SteamID64()][2] then
					ply:SendLua("GAMEMODE:CallJumpscare('" .. GAMEMODE.PlayerEasterEgg[attacker:SteamID64()][2] .. "')")
				else
					ply:SendLua("GAMEMODE:CallJumpscare()")
				end
			end
			GAMEMODE.Vars.downvictims = (GAMEMODE.Vars.downvictims or 0) + 1
		end

	end

	GAMEMODE.Vars.victims = 0

	for k, v in pairs(team.GetPlayers(TEAM_VICTIMS)) do
		if IsValid(v) and v:Alive() then
			GAMEMODE.Vars.victims = GAMEMODE.Vars.victims + 1
		end
	end

	GAMEMODE:PlayerStats()

end

function GM:PlayerShouldTakeDamage(ply, attacker)

	if game.SinglePlayer() then return true end

	if attacker:IsValid() and attacker:IsPlayer() and ply:Team() == attacker:Team() then
		return false
	end

	return true

end

function GM:ShowHelp(ply)
	ply:SendLua("GAMEMODE:Menu()")
end

function GM:ShowSpare1(ply)
	if ply:Team() != TEAM_VICTIMS and ply:Team() != TEAM_PEDOBEAR then return end
	ply:SendLua("GAMEMODE:TauntMenuF()")
end

function GM:ShowSpare2(ply) --TODO Jukebox
	ply:SendLua("GAMEMODE:JukeboxMenu()")
end

net.Receive("SuperPedobear_Taunt", function(bits,ply)
	local tauntid = net.ReadInt(32)
	taunt = GAMEMODE.Sounds.Taunts[tauntid]
	GAMEMODE:Taunt(ply, taunt, tauntid)
end)
function GM:Taunt(ply, taunt, tauntid)

	if !ply:Alive() or (ply:Team() != TEAM_VICTIMS and ply:Team() != TEAM_PEDOBEAR) then return end

	if !ply.TauntCooldown then
		ply.TauntCooldown = 0
	end

	if ply.TauntCooldown <= CurTime() then

		if taunt[3] == ply:Team() or taunt[3] == 0 then

			ply:EmitSound(taunt[2], 75, 100, 1, CHAN_AUTO)

			local cd = taunt[4]

			if cd < 5 then
				cd = 5
			end

			ply.TauntCooldown = CurTime() + cd

			ply:SetNWInt("LastTaunt", tauntid)
			ply:SetNWInt("TauntCooldown", ply.TauntCooldown)
			ply:SetNWInt("TauntCooldownF", cd)

			if PS and GAMEMODE.Vars.Round.Start and !GAMEMODE.Vars.Round.End and !GAMEMODE.Vars.Round.TempEnd and ply:Team() != TEAM_PEDOBEAR then
				local points = 10
				ply:PS_GivePoints(points)
				ply:PS_Notify("You've been given " .. points .. " " .. PS.Config.PointsName .. " for taunting!")
			end

		end

	end

end

function GM:PlayerCanHearPlayersVoice(pListener, pTalker)

	if pListener:Team() == TEAM_UNASSIGNED then
		return false, false
	end

	if pListener:Team() == TEAM_SPECTATOR then
		return true, false
	end

	if GAMEMODE.Vars.Round.Start and !pTalker:Alive() and pListener:Alive() then return false end

	return true, false

end

function GM:CreateDummy(ply)
	local cd = 1
	if ply:Team() != TEAM_VICTIMS or !ply:OnGround() then return end
	if !IsValid(ply.Dummy) or (!ply.tnextpowerup or ply.tnextpowerup < CurTime()) then
		if IsValid(ply.Dummy) then
			ply.Dummy:Remove()
		end
		local ent = ents.Create("superpedobear_dummy")
		ent:SetPlayer(ply)
		ent:Spawn()
		ply.Dummy = ent
		ply.tnextpowerup = CurTime() + cd
		ply:SetNWInt("tnextpowerup", ply.tnextpowerup)
		ply:SetNWInt("ttnextpowerup", cd)
	end
end

function GM:PlayerRequestTeam(ply, teamid)

	if !GAMEMODE.TeamBased then return end

	if !team.Joinable(teamid) then ply:ChatPrint("You can't join that team") return end

	if !GAMEMODE:PlayerCanJoinTeam(ply, teamid) then return end

	GAMEMODE:PlayerJoinTeam(ply, teamid)

end

function GM:PlayerCanSeePlayersChat(text, teamOnly, listener, speaker)

	if IsValid(listener) and (listener:Team() == TEAM_SPECTATOR or (listener.XperidiaRank and listener.XperidiaRank.id >= 250)) then
		return true
	end

	if IsValid(speaker) and speaker.XperidiaRank and speaker.XperidiaRank.id >= 250 then
		return  true
	end

	if teamOnly then
		if !IsValid(speaker) or !IsValid(listener) then return false end
		if listener:Team() != speaker:Team() then return false end
	end

	if GAMEMODE.Vars.Round.Start and !GAMEMODE.Vars.Round.End and !teamOnly then
		if speaker:Team() == TEAM_VICTIMS and !speaker:Alive() and listener:Team() == TEAM_PEDOBEAR then
			return false
		end
	end

	return true

end

function GM:StartCommand(ply, ucmd)

	if !ply:IsBot() then
		GAMEMODE:AFKThink(ply, ucmd)
	end

end

function GM:AFKThink(ply, ucmd)

	local function notmoving(ucmd)
		return ucmd:GetButtons() == 0 and ucmd:GetMouseX() == 0 and ucmd:GetMouseY() == 0
	end

	if ply.afkcheck == nil and notmoving(ucmd) then

		ply.afkcheck = CurTime()

	elseif !notmoving(ucmd) then

		ply.afkcheck = nil

		if ply.IsAFK then

			ply.IsAFK = false

			GAMEMODE:Log(ply:GetName() .. " is no longer afk!", nil, true)

			net.Start("SuperPedobear_AFK")
				net.WriteFloat(0)
			net.Send(ply)

			timer.Remove("SuperPedobear_AFK" .. ply:UserID())

		end

	end

	if !ply.IsAFK and ply.afkcheck != nil and ply.afkcheck < CurTime() - superpedobear_afk_time:GetInt() then

		ply.IsAFK = true
		GAMEMODE:Log(ply:GetName() .. " is afk!", nil, true)

		GAMEMODE:PedoAFKCare(ply)

	end

end

function GM:PedoAFKCare(ply)

	if ply.IsAFK and ply:Team() == TEAM_PEDOBEAR then

		net.Start("SuperPedobear_AFK")
			net.WriteFloat(CurTime() + superpedobear_afk_action:GetInt())
		net.Send(ply)

		local userid = ply:UserID()
		timer.Create("SuperPedobear_AFK" .. userid, superpedobear_afk_action:GetInt(), 1, function()
			if IsValid(ply) and ply.IsAFK and ply:Alive() and ply:Team() == TEAM_PEDOBEAR then GAMEMODE:PlayerJoinTeam( ply, TEAM_VICTIMS ) end
			timer.Remove("SuperPedobear_AFK" .. userid)
		end)

	end

end

function GM:GetFallDamage(ply, flFallSpeed)

	if ply:Team() == TEAM_PEDOBEAR then return 0 end

	if !GAMEMODE.Vars.Round.Start then return 0 end

	return 10

end

function GM:OnDamagedByExplosion(ply, dmginfo)
end

function GM:EntityTakeDamage(target, dmg)

	if target:IsPlayer() and target:Team() == TEAM_VICTIMS and target:Health() - dmg:GetDamage() > 0 then

		if #GAMEMODE.Sounds.Damage > 0 then
			target:EmitSound(GAMEMODE.Sounds.Damage[math.random(1, #GAMEMODE.Sounds.Damage)], 90, 100, 1, CHAN_AUTO)
		end

	end

end

function GM:SendMusicIndex(ply)

	net.Start("SuperPedobear_MusicList")
		net.WriteTable(GAMEMODE.Musics.musics)
		net.WriteTable(GAMEMODE.Musics.premusics)
	if IsValid(ply) then net.Send(ply) else net.Broadcast() end

end

function GM:OnDummyKilled(ent, attacker, inflictor)

	if IsValid(attacker) and attacker:GetClass() == "trigger_hurt" then attacker = ent end

	if IsValid(attacker) and attacker:IsVehicle() and IsValid(attacker:GetDriver()) then
		attacker = attacker:GetDriver()
	end

	if !IsValid(inflictor) and IsValid(attacker) then
		inflictor = attacker
	end

	-- Convert the inflictor to the weapon that they're holding if we can.
	if IsValid(inflictor) and attacker == inflictor and (inflictor:IsPlayer() or inflictor:IsNPC()) then

		inflictor = inflictor:GetActiveWeapon()
		if !IsValid(attacker) then inflictor = attacker end

	end

	local InflictorClass = "worldspawn"
	local AttackerClass = "worldspawn"

	if IsValid(inflictor) then InflictorClass = inflictor:GetClass() end
	if IsValid(attacker) then

		AttackerClass = attacker:GetClass()

		if attacker:IsPlayer() then

			net.Start("PlayerKilledDummy")

				net.WriteEntity(ent)
				net.WriteString(InflictorClass)
				net.WriteEntity(attacker)

			net.Broadcast()

			return
		end

	end

	net.Start("NPCKilledDummy")

		net.WriteEntity(ent)
		net.WriteString(InflictorClass)
		net.WriteString(AttackerClass)

	net.Broadcast()

end

function GM:PlayerUse(ply, ent)

	if !ply:Alive() or ply:Team() == TEAM_SPECTATOR or ply:Team() == TEAM_UNASSIGNED then
		return false
	end

	if (ply:Team() == TEAM_VICTIMS and IsValid(ent) and string.match(ent:GetClass(), "door")) then

		if !ply.PedoUseDelay then
			ply.PedoUseDelay = 0
		end

		if ply.PedoUseDelay > CurTime() then
			return false
		end

		ply.PedoUseDelay = CurTime() + 0.75
		--ply:SetNWFloat("PedoUseDelay", ply.PedoUseDelay)

	end

	return true

end

function GM:RetrieveXperidiaAccountRank(ply)
	if !IsValid(ply) then return end
	if ply:IsBot() then return end
	if !ply.XperidiaRankLastTime or ply.XperidiaRankLastTime + 3600 < SysTime() then
		local steamid = ply:SteamID64()
		GAMEMODE:Log("Retrieving the Xperidia Rank for " .. ply:GetName() .. "...", nil, true)
		http.Post("https://xperidia.com/UCP/rank_v2.php", {steamid = steamid},
		function(responseText, contentLength, responseHeaders, statusCode)
			if !IsValid(ply) then return end
			if statusCode == 200 then
				local rank_info = util.JSONToTable(responseText)
				if rank_info and rank_info.id then
					ply.XperidiaRank = rank_info
					ply:SetNWInt("XperidiaRank", rank_info.id)
					ply:SetNWString("XperidiaRankName", rank_info.name)
					ply:SetNWString("XperidiaRankColor", tonumber("0x" .. rank_info.color:sub(1,2)) .. " " .. tonumber("0x" .. rank_info.color:sub(3,4)) .. " " .. tonumber("0x" .. rank_info.color:sub(5,6)) .. " 255")
					ply.XperidiaRankLastTime = SysTime()
					if rank_info.id != 0 and rank_info.name then
						GAMEMODE:Log("The Xperidia Rank for " .. ply:GetName() .. " is " .. rank_info.name .. " (" .. rank_info.id .. ")")
					elseif rank_info.id != 0 then
						GAMEMODE:Log("The Xperidia Rank for " .. ply:GetName() .. " is " .. rank_info.id)
					else
						GAMEMODE:Log(ply:GetName() .. " doesn't have any Xperidia Rank...", nil, true)
					end
				end
			else
				GAMEMODE:Log("Error while retriving Xperidia Rank for " .. ply:GetName() .. " (HTTP " .. (statusCode or "?") .. ")")
			end
		end,
		function(errorMessage)
			GAMEMODE:Log(errorMessage)
		end)
	end
end

function GM:StoreChances(ply)

	if !superpedobear_save_chances:GetBool() then GAMEMODE:Log("Chances saving is disabled. Not saving pedobear chances.") return end

	local function savechance(pl)

		if pl:IsBot() then return end

		local chance = pl:GetNWFloat("SuperPedobear_PedoChance", nil)

		if chance != nil then

			pl:SetPData("SuperPedobear_PedoChance", math.floor(math.Clamp(chance, 0, 100) * 100))

			GAMEMODE:Log("Saved the " .. (chance * 100) .. "% pedobear chance of " .. pl:GetName())

		end

	end

	if IsValid(ply) then

		savechance(ply)

	elseif ply == nil then

		for _, v in pairs(player.GetAll()) do

			savechance(v)

		end

	end

end

function GM:LoadChances(ply)

	if !superpedobear_save_chances:GetBool() then GAMEMODE:Log("Chances saving is disabled. Not loading pedobear chances.", nil, true) return end

	local function loadchance(pl)

		if pl:IsBot() then return end

		local chance = pl:GetPData("SuperPedobear_PedoChance", nil)

		if chance != nil then

			chance = chance * 0.01

			pl:SetNWFloat("SuperPedobear_PedoChance", chance)

			GAMEMODE:Log("Loaded the " .. (chance * 100) .. "% pedobear chance of " .. pl:GetName())

		else

			pl:SetNWFloat("SuperPedobear_PedoChance", 0.01)

			GAMEMODE:Log("No pedobear chance found for " .. pl:GetName() .. ", default was set")

		end

	end

	if IsValid(ply) then

		loadchance(ply)

	elseif ply == nil then

		for _, v in pairs(player.GetAll()) do

			loadchance(v)

		end

	end

end

function GM:StorePlayerInfo(ply)

	local function saveinfo(pl)

		if pl:IsBot() then return end

		local totalvictims = pl:GetNWInt("SuperPedobear_TotalVictims", nil)
		local victimscurrency = pl:GetNWInt("SuperPedobear_VictimsCurrency", nil)

		if totalvictims != nil then
			pl:SetPData("SuperPedobear_TotalVictims", totalvictims)
		end
		if victimscurrency != nil then
			pl:SetPData("SuperPedobear_VictimsCurrency", victimscurrency)
		end

		GAMEMODE:Log("Saved the player info of " .. pl:GetName())

	end

	if IsValid(ply) then

		saveinfo(ply)

	elseif ply == nil then

		for _, v in pairs(player.GetAll()) do

			saveinfo(v)

		end

	end

end

function GM:LoadPlayerInfo(ply)

	local function loadinfo(pl)

		if pl:IsBot() then return end

		pl:SetNWInt("SuperPedobear_TotalVictims", pl:GetPData("SuperPedobear_TotalVictims", 0))
		pl:SetNWInt("SuperPedobear_VictimsCurrency", pl:GetPData("SuperPedobear_VictimsCurrency", 0))

		GAMEMODE:Log("Loaded the player info of " .. pl:GetName())

	end

	if IsValid(ply) then

		loadinfo(ply)

	elseif ply == nil then

		for _, v in pairs(player.GetAll()) do

			loadinfo(v)

		end

	end

end
