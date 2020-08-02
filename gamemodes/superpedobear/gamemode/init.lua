--[[---------------------------------------------------------
		Super Pedobear Gamemode for Garry's Mod
				by VictorienXP (2016-2020)
-----------------------------------------------------------]]

AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_scale.lua")
AddCSLuaFile("cl_fonts.lua")
AddCSLuaFile("cl_scoreboard.lua")
AddCSLuaFile("cl_menu.lua")
AddCSLuaFile("cl_tauntmenu.lua")
AddCSLuaFile("cl_voice.lua")
AddCSLuaFile("cl_deathnotice.lua")
AddCSLuaFile("cl_van.lua")
AddCSLuaFile("cl_hud.lua")
AddCSLuaFile("cl_mapvote.lua")
AddCSLuaFile("semver.lua")

include("shared.lua")

DEFINE_BASECLASS("gamemode_base")

util.AddNetworkString("spb_Vars")
util.AddNetworkString("spb_PlayerStats")
util.AddNetworkString("spb_Notif")
util.AddNetworkString("spb_Taunt")
util.AddNetworkString("spb_Music")
util.AddNetworkString("spb_AFK")
util.AddNetworkString("spb_MusicList")
util.AddNetworkString("spb_TauntList")
util.AddNetworkString("PlayerKilledDummy")
util.AddNetworkString("NPCKilledDummy")
util.AddNetworkString("spb_List")
util.AddNetworkString("spb_MusicQueue")
util.AddNetworkString("spb_MusicAddToQueue")
util.AddNetworkString("spb_MusicQueueVote")
util.AddNetworkString("spb_PM_Lists")
util.AddNetworkString("spb_MapList")

function GM:InitPostEntity()
	self.Vars.ThereIsPowerUPSpawns = #ents.FindByClass("spb_powerup_spawn") > 0
end

function GM:PlayerInitialSpawn(ply)

	self:RetrieveXperidiaAccountRank(ply)

	if ply:IsBot() then
		ply:SetTeam(TEAM_HIDING)
		ply:SetNWFloat("spb_BearChance", 0)
	else
		ply:SetTeam(TEAM_UNASSIGNED)
		self:LoadChances(ply)
		self:LoadPlayerInfo(ply)
	end

	if not game.IsDedicated() and ply:IsListenServerHost() then
		ply:SetNWBool("IsListenServerHost", true)
	end

	self:UpVars(ply)
	self:SendMusicIndex(ply)
	self:SendTauntIndex(ply)
	self:SendMusicQueue(ply)
	self:SendPMList(ply)
	self:SendMaps(ply)

	ply:SetNWString("spb_DefautPM", self.Vars.PM_Default[math.Round(util.SharedRandom(ply:UniqueID(), 1, #self.Vars.PM_Default))])

	if not self.LatestRelease.Version then
		self:CheckForNewRelease()
	end

end

function GM:PlayerSpawn(ply, transiton)

	local pteam = ply:Team()

	if pteam == TEAM_SPECTATOR or pteam == TEAM_UNASSIGNED then

		self:PlayerSpawnAsSpectator(ply)
		self:PlayerStats()
		return

	end

	ply:UnSpectate()

	local classes = team.GetClass(pteam)
	player_manager.SetPlayerClass(ply, classes[math.random(1, #classes)])

	player_manager.OnPlayerSpawn(ply, transiton)
	player_manager.RunClass(ply, "Spawn")

	hook.Call("PlayerLoadout", self, ply)

	hook.Call("PlayerSetModel", self, ply)

	ply:SetupHands()

	self:PlayerStats()

end

function GM:PlayerDisconnected(ply)
	self:StoreChances(ply)
	self:StorePlayerInfo(ply)
end

function GM:UpVars(ply)

	net.Start("spb_Vars")
		net.WriteBool(self.Vars.Round.Start or false)
		net.WriteBool(self.Vars.Round.PreStart or false)
		net.WriteFloat(self.Vars.Round.PreStartTime or 0)
		net.WriteBool(self.Vars.Round.Pre2Start or false)
		net.WriteFloat(self.Vars.Round.Pre2Time or 0)
		net.WriteFloat(self.Vars.Round.Time or 0)
		net.WriteBool(self.Vars.Round.End or false)
		net.WriteInt(tonumber(self.Vars.Round.Win) or 0, 4)
		net.WriteFloat(self.Vars.Round.LastTime or 0)
		net.WriteBool(self.Vars.Round.TempEnd or false)
		net.WriteUInt(self.Vars.Rounds or 1, 32)
	if IsValid(ply) then net.Send(ply) else net.Broadcast() end

end

function GM:ListMaps()

	self.MapList = {}
	local AvMaps = file.Find("maps/*.bsp", "GAME")
	local prefixes = string.Explode("|", spb_votemap_prefixes:GetString())

	for _, map in pairs(AvMaps) do
		if map ~= "spb_tutorial.bsp" and map ~= "spb_dev.bsp" then
			for _, prefix in pairs(prefixes) do
				if string.StartWith(map, prefix) then
					self:DebugLog("Found " .. map)
					table.insert(self.MapList, string.StripExtension(map))
					break
				end
			end
		end
	end

	self:Log(#self.MapList .. " map(s) have been found!")

	self:SendMaps()

end

function GM:SendMaps(ply)

	net.Start("spb_MapList")
		net.WriteTable(self.MapList)
	if IsValid(ply) then net.Send(ply) else net.Broadcast() end

end

function GM:SelectMusic(pre)

	self:BuildMusicIndex()

	local mlist = Either(pre, self.Musics.premusics, self.Musics.musics)

	if #mlist > 0 then

		local mid = math.random(1, #mlist)
		local src = mlist[mid][1]

		if not string.match(mlist[mid][1], "://") then
			src = "sound/superpedobear/" .. Either(pre, "premusics", "musics") .. "/" .. src
		end

		self.Vars.CurrentMusic = src
		self.Vars.CurrentMusicName = mlist[mid][2]

	end

	self:Music(self.Vars.CurrentMusic, pre, nil, self.Vars.CurrentMusicName)

end

function GM:Music(src, pre, ply, name)

	net.Start("spb_Music")
		net.WriteString(src or "")
		net.WriteBool(pre or false)
		net.WriteString(name or "")
	if IsValid(ply) then net.Send(ply) else net.Broadcast() end

end

function GM:SendMusicQueue(ply)
	net.Start("spb_MusicQueue")
		net.WriteTable(self.Vars.MusicQueue or {})
	if IsValid(ply) then net.Send(ply) else net.Broadcast() end
end

net.Receive("spb_MusicAddToQueue", function(bits, ply)

	local music = net.ReadString()

	if spb_jukebox_enable_input:GetBool() then
		GAMEMODE:MusicQueueAdd(ply, music)
	end

end)
function GM:MusicQueueAdd(ply, musicsrc)
	if not self.Vars.MusicQueue then self.Vars.MusicQueue = {} end
	self.Vars.MusicQueue[ply] = {}
	self.Vars.MusicQueue[ply].music = musicsrc
	self.Vars.MusicQueue[ply].votes = {ply}
	self:SendMusicQueue()
end

net.Receive("spb_MusicQueueVote", function(bits, ply)
	local qply = net.ReadEntity()
	GAMEMODE:MusicQueueVote(ply, qply)
end)
function GM:MusicQueueVote(ply, qply)
	if not IsValid(qply) then
		return
	end
	if table.HasValue(self.Vars.MusicQueue[qply].votes, ply) then
		table.RemoveByValue(self.Vars.MusicQueue[qply].votes, ply)
	else
		table.insert(self.Vars.MusicQueue[qply].votes, ply)
	end
	self:SendMusicQueue()
end

function GM:MusicQueueSelect()
	if not self.Vars.MusicQueue then return nil end
	local winner
	local who
	for k, v in RandomPairs(self.Vars.MusicQueue) do
		if not winner or #v.votes > #winner.votes then
			who = k
			winner = v
		end
	end
	if who and winner then
		self.Vars.MusicQueue[who] = nil
		self:SendMusicQueue()
		return winner.music
	end
	return nil
end

function GM:PostPlayerDeath(ply)
	self:PlayerStats()
	self:RetrieveXperidiaAccountRank(ply)
end

function GM:PlayerDeathSound()
	return true
end

function GM:PlayerDeathThink(ply)

	if ply:Team() == TEAM_SEEKER
	and self.Vars.Round.Start
	and not self.Vars.Round.End
	and not self.Vars.Round.TempEnd
	and not self.Vars.Round.Pre2Start
	then
		ply:Spawn()
		return
	elseif ply:Team() == TEAM_SEEKER and self.Vars.Round.Pre2Start then
		return
	end

	if ply:Team() == TEAM_HIDING and self.Vars.Round.Start
	and ply.Clones and #ply.Clones > 0 then
		for k, v in pairs(ply.Clones) do
			if IsValid(v) then
				ply:Spawn()
				ply:SetPos(v:GetPos())
				ply:SetAngles(v:GetAngles())
				v:BRemove(ply)
				return
			end
		end
	end

	if ply:Team() == TEAM_HIDING or ply:Team() == TEAM_SEEKER then self:SpecControl(ply) end

	if self.Vars.Round.Start then return end

	if ply.NextSpawnTime and ply.NextSpawnTime > CurTime() then return end

	if ply:IsBot() or ply:KeyPressed(IN_ATTACK) or ply:KeyPressed(IN_ATTACK2) or ply:KeyPressed(IN_JUMP) then
		ply:UnSpectate()
		ply:Spawn()
	end

end

function GM:PlayerStats()

	self.Vars.victims = 0

	for k, v in pairs(team.GetPlayers(TEAM_HIDING)) do
		if IsValid(v) and v:Alive() then
			self.Vars.victims = self.Vars.victims + 1
		elseif IsValid(v) and v.Clones and #v.Clones > 0 then
			for _, c in pairs(v.Clones) do
				if IsValid(c) then
					self.Vars.victims = self.Vars.victims + 1
					break
				end
			end
		end
	end

	net.Start("spb_PlayerStats")
		net.WriteUInt(self.Vars.victims, 8)
		net.WriteUInt(self.Vars.downvictims or 0, 10)
	net.Broadcast()

end

function GM:KeyPress(ply, key)
	if ply:Team() == TEAM_UNASSIGNED and not ply:KeyPressed(IN_SCORE) then
		ply:SetTeam(TEAM_HIDING)
		ply:Spawn()
		if self.Vars.Round.Start then
			ply:KillSilent()
		end
	elseif ply:Team() == TEAM_SPECTATOR or ply:Team() == TEAM_UNASSIGNED then
		self:SpecControl(ply)
	end
end

function GM:SpecControl(ply, manual)

	local players = {}

	for k, v in pairs(player.GetAll()) do
		local vteam = v:Team()
		if v:Alive() and (vteam == TEAM_HIDING or vteam == TEAM_SEEKER) and v ~= ply and vteam ~= TEAM_UNASSIGNED and vteam ~= TEAM_SPECTATOR then
			table.insert(players, v)
		end
	end

	if ply:KeyPressed(IN_ATTACK) or manual then

		if not ply.SpecMODE then ply.SpecMODE = OBS_MODE_CHASE end

		ply:Spectate(ply.SpecMODE)

		if not ply.SpecID then ply.SpecID = 0 end

		ply.SpecID = ply.SpecID + 1

		if ply.SpecID > #players then ply.SpecID = 1 end

		ply:SpectateEntity(players[ply.SpecID])
		ply:SetupHands(players[ply.SpecID])

	elseif ply:KeyPressed(IN_ATTACK2) then

		if not ply.SpecMODE then ply.SpecMODE = OBS_MODE_CHASE end

		ply:Spectate(ply.SpecMODE)

		if not ply.SpecID then ply.SpecID = 2 end

		ply.SpecID = ply.SpecID - 1

		if ply.SpecID <= 0 then ply.SpecID = #players end

		ply:SpectateEntity(players[ply.SpecID])
		ply:SetupHands(players[ply.SpecID])

	elseif ply:KeyPressed(IN_JUMP) then

		if not ply.SpecMODE then ply.SpecMODE = OBS_MODE_CHASE end

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

		if not IsValid(pv) then
			pv = v
		end

	end

	if IsValid(pv) then

		for k, v in pairs(player.GetAll()) do

			if v:Alive() and v:Team() ~= wteam then
				v:DropPowerUP()
				v:KillSilent()
			end

			if v:Team() ~= wteam and v:Team() ~= TEAM_UNASSIGNED and v:Team() ~= TEAM_SPECTATOR then

				v.SpecMODE = OBS_MODE_CHASE

				v:Spectate(v.SpecMODE)

				v:SpectateEntity(pv)
				v:SetupHands(pv)

			end

		end

		timer.Create("spb_ReviewPlayers", 2, 0, function()
			if self.Vars.Round.End or self.Vars.Round.TempEnd then
				for k, v in pairs(player.GetAll()) do
					if not v:Alive() then
						self:SpecControl(v, true)
					end
				end
			else
				timer.Remove("spb_ReviewPlayers")
			end
		end)

	end

end

function GM:Think()

	local daplayers = player.GetAll()

	local time = CurTime()

	for k, v in pairs(daplayers) do

		if v:Team() == TEAM_SEEKER then

			if v:GetModel() ~= "models/player/pbear/pbear.mdl" then --PM Protect
				v:SetModel(Model("models/player/pbear/pbear.mdl"))
			end

		elseif v:Team() == TEAM_HIDING and v:Alive() then

			if v:GetModel() == "models/player/pbear/pbear.mdl" then --PM Protect
				v:SetModel(Model("models/jazzmcfly/magica/homura_mg.mdl"))
			end

			if spb_rainbow_effect:GetBool() then --Rainbow effect~
				local a = math.Clamp(v:Health(), 0, 100) / 100
				local doffset = v:EntIndex()
				local x = time + doffset
				local r = ( 0.5 * (math.sin(x - 2) + 1) ) * a
				local g = ( 0.5 * (math.sin(x + 2) + 1) ) * a
				local b = ( 0.5 * (math.sin(x) + 1) ) * a
				v:SetPlayerColor(Vector(r, g, b))
			end

		end

		if v:IsCloaked() then
			local t = v.spb_CloakTime - CurTime()
			local alpha = 1
			local tt = spb_powerup_cloak_time:GetFloat() or 0
			if t <= 0.5 then
				alpha = math.Clamp(math.Remap(t, 0.5, 0, 0, 1), 0, 1)
			elseif t >= tt - 1 then
				alpha = math.Clamp(math.Remap(t, tt, tt - 1, 1, 0), 0, 1)
			else
				alpha = 0
			end
			v:SetColor(Color(255, 255, 255, 255 * alpha))
		end

	end

	if not self.Vars.CheckTime or self.Vars.CheckTime + 0.1 <= CurTime() then

		for k, v in pairs(daplayers) do

			if v:Team() == TEAM_HIDING then

				if v:Alive() and self.Vars.Round.Start and v.Sprinting and (not v.SprintV or v.SprintV > 0) and not v.SprintLock then
					v.SprintV = (v.SprintV or 100) - 1
				elseif v:Alive() and ((not v.Sprinting and v:IsOnGround()) or v.SprintLock) and v.SprintV and v.SprintV < 100 then
					v.SprintV = v.SprintV + 1
				elseif not v:Alive() and (not v.SprintV or v.SprintV ~= 100) then
					v.SprintV = 100
				end

				if v.SprintV then
					if v.SprintV <= 0 and not v.SprintLock then
						v.SprintLock = true
						v:SetRunSpeed(200)
					elseif v.SprintV >= 85 and v.SprintLock then
						v.SprintLock = false
						v:SetRunSpeed(400)
					end
					v:SetNWInt("spb_SprintV", v.SprintV)
					v:SetNWInt("spb_SprintLock", v.SprintLock)
				end

			elseif (not v.SprintV or v.SprintV ~= 100) then
				v.SprintV = 100
				v:SetNWInt("spb_SprintV", v.SprintV)
			end

		end

		self.Vars.CheckTime = CurTime()

	end

	if not self.Vars.LastCount or self.Vars.LastCount ~= #team.GetPlayers(TEAM_HIDING) then
		self.Vars.LastCount = #team.GetPlayers(TEAM_HIDING)
		self:PlayerStats()
	end

	self:RoundThink()

	self:SlowMo()

	if self:IsSeasonalEvent("AprilFool") then
		physenv.SetGravity(Vector(math.Rand(-4096, 4096), math.Rand(-4096, 4096), math.Rand(-4096, 4096)))
	end

end

function GM:RoundThink()

	if not self.Vars.Round.Start and not self.Vars.Round.PreStart then -- PreRound

		if self.Vars.victims and self.Vars.victims >= 2 and (not MapVote or (MapVote and not MapVote.Allow)) then

			self.Vars.Round.PreStart = true

			if not self.Vars.Rounds or self.Vars.Rounds <= 1 then
				self.Vars.Round.PreStartTime = CurTime() + 40
			else
				self.Vars.Round.PreStartTime = CurTime() + spb_round_pretime:GetFloat()
			end

			self:SelectMusic(true)

			self:UpVars()

			self:DebugLog("The game will start at " .. self.Vars.Round.PreStartTime)

		end

	elseif not self.Vars.Round.Start and self.Vars.Round.PreStart and self.Vars.Round.PreStartTime and self.Vars.Round.PreStartTime < CurTime() then -- Starting Round

		if self.Vars.victims and self.Vars.victims >= 2 then

			hook.Call("spb_RoundStarting")

			self.Vars.Round.Start = true
			self.Vars.Round.PreStart = false
			self.Vars.Round.Pre2Start = true

			self.Vars.Round.PreStartTime = 0
			self.Vars.Round.Pre2Time = CurTime() + spb_round_pre2time:GetFloat()
			self.Vars.Round.Time = self.Vars.Round.Pre2Time + spb_round_time:GetFloat()

			local Seekers = {}
			local WantedSeekers = 1
			local SeekerIndex = 1

			if self.Vars.victims >= 64 then
				WantedSeekers = 4
			elseif self.Vars.victims >= 32 then
				WantedSeekers = 3
			elseif self.Vars.victims >= 24 then
				WantedSeekers = 2
			end

			self:DebugLog(WantedSeekers .. " seeker(s) will be selected")

			while #Seekers ~= WantedSeekers do

				local plys = team.GetPlayers(TEAM_HIDING)

				for k, v in RandomPairs(plys) do

					if not Seekers[SeekerIndex] or (IsValid(Seekers[SeekerIndex]) and (Seekers[SeekerIndex]:GetNWFloat("spb_BearChance", 0) < v:GetNWFloat("spb_BearChance", 0))) then
						Seekers[SeekerIndex] = v
					end

					self:DebugLog(v:GetName() .. " have " .. (v:GetNWFloat("spb_BearChance", 0) * 100) .. "% chance to be a seeker" .. Either(Seekers[SeekerIndex] == v, " and is currently selected", ""))

				end

				self:DebugLog(Seekers[SeekerIndex]:GetName() .. " has been selected to be a seeker " .. SeekerIndex)

				if IsValid(Seekers[SeekerIndex]) then
					Seekers[SeekerIndex]:DropPowerUP()
					Seekers[SeekerIndex]:SetTeam(TEAM_SEEKER)
					Seekers[SeekerIndex]:KillSilent()
					Seekers[SeekerIndex]:SetNWFloat("spb_BearChance", 0)
					Seekers[SeekerIndex]:ScreenFade(SCREENFADE.OUT, color_black, 0.5, spb_round_pre2time:GetFloat())
					SeekerIndex = SeekerIndex + 1
				end

			end

			net.Start("spb_List")
				net.WriteTable(Seekers)
			net.Broadcast()

			timer.Create("spb_TempoStart", spb_round_pre2time:GetFloat(), 1, function()

				self.Vars.Round.Pre2Start = false

				local jukebox = self:MusicQueueSelect()
				if jukebox then
					self.Vars.CurrentMusic = jukebox
					self.Vars.CurrentMusicName = nil
					self:Music(self.Vars.CurrentMusic)
				else
					self:SelectMusic()
				end

				for k, v in pairs(Seekers) do
					v:SendLua([[LocalPlayer():EmitSound("spb_yourethebear") system.FlashWindow()]])
					self:BearAFKCare(v)
					v:ScreenFade(SCREENFADE.IN, Color(0, 0, 0, 255), 0.3, 1)
					if spb_powerup_autofill:GetBool() and not self.Vars.ThereIsPowerUPSpawns then
						v:PickPowerUP()
					end
				end

				self:PlayerStats()
				self:UpVars()

				timer.Remove("spb_TempoStart")

			end)

			if spb_powerup_autofill:GetBool() and not self.Vars.ThereIsPowerUPSpawns then
				for k, v in pairs(team.GetPlayers(TEAM_HIDING)) do
					if v:Alive() then
						v:PickPowerUP()
					end
				end
			end

			hook.Call("spb_RoundStarted")

		else

			self.Vars.Round.PreStart = false

			net.Start("spb_Notif")
				net.WriteString("Not enough players!")
				net.WriteInt(1, 3)
				net.WriteFloat(5)
				net.WriteBit(true)
			net.Broadcast()

		end

		self:UpVars()

	elseif self.Vars.Round.Start and not self.Vars.Round.TempEnd then -- Round end

		if #team.GetPlayers(TEAM_SEEKER) == 0 then

			self.Vars.Round.End = true
			self.Vars.Round.LastTime = self.Vars.Round.Time - CurTime()
			hook.Call("spb_RoundEnd")

		elseif self.Vars.victims and self.Vars.victims <= 0 then

			self.Vars.Round.End = true
			self.Vars.Round.Win = TEAM_SEEKER
			self.Vars.Round.LastTime = self.Vars.Round.Time - CurTime()
			team.AddScore(TEAM_SEEKER, 1)

			self:DoTheVictoryDance(TEAM_SEEKER)
			hook.Call("spb_RoundEnd", nil, TEAM_SEEKER)

		elseif self.Vars.Round.Time < CurTime() then

			self.Vars.Round.End = true
			self.Vars.Round.Win = TEAM_HIDING
			self.Vars.Round.LastTime = 0
			team.AddScore(TEAM_HIDING, 1)

			self:DoTheVictoryDance(TEAM_HIDING)
			hook.Call("spb_RoundEnd", nil, TEAM_HIDING)

		end

		if self.Vars.Round.End then

			self.Vars.Round.TempEnd = true
			self.Vars.Round.Time = 0
			self:UpVars()
			self.Vars.Round.End = false
			self.Vars.Round.Win = 0
			self.Vars.Rounds = (self.Vars.Rounds or 1) + 1

			--self:Music("pause")

			local max_rounds = spb_rounds:GetInt()

			if MapVote and self.Vars.Rounds > max_rounds and max_rounds > 0 then
				MapVote.Start(nil, nil, nil, {"spb_", "ph_"})
			end

			timer.Create("spb_TempoPreEnd", 9.8, 1, function()

				for k, v in pairs(player.GetAll()) do
					if v:Alive() and (v:Team() == TEAM_HIDING or v:Team() == TEAM_SEEKER) then
						v.Clones = nil
						v:DropPowerUP()
						v:KillSilent()
					end
				end

				timer.Remove("spb_TempoPreEnd")

			end)

			timer.Create("spb_TempoEnd", 10, 1, function()

				self.Vars.Round.Start = false
				self.Vars.Round.End = false
				self.Vars.Round.TempEnd = false
				self.Vars.downvictims = 0

				self.Vars.CurrentMusic = nil
				self.Vars.CurrentMusicName = nil

				net.Start("spb_List")
					net.WriteTable({})
				net.Broadcast()

				self:Music("stop")

				game.CleanUpMap()

				for k, v in pairs(team.GetPlayers(TEAM_HIDING)) do
					if not v:Alive() then v:Spawn() end
					if not v:IsBot() and not v.IsAFK then v:SetNWFloat("spb_BearChance", v:GetNWFloat("spb_BearChance", 0) + 0.01) end
					if v.Clones and #v.Clones > 0 then table.Empty(v.Clones) end
				end

				for k, v in pairs(team.GetPlayers(TEAM_SEEKER)) do
					v:SetTeam(TEAM_HIDING)
					v:Spawn()
				end

				self:StoreChances()
				self:StorePlayerInfo(ply)
				self:UpVars()
				self:PlayerStats()

				timer.Remove("spb_TempoEnd")

			end)

		end

	end

end

function GM:SlowMo()

	if not spb_slow_motion:GetBool() then
		if game.GetTimeScale() ~= 1 then
			game.SetTimeScale(1)
		end
		return
	end

	local ply

	for k, v in pairs(team.GetPlayers(TEAM_HIDING)) do
		if v:Alive() and IsValid(ply) then
			return
		elseif v:Alive() then
			if v.Clones and #v.Clones > 0 then
				for k, v in pairs(v.Clones) do
					if IsValid(v) then
						return
					end
				end
			end
			ply = v
		end
	end

	if IsValid(ply) and not ply:IsCloaked() then

		local _, distance = self:GetClosestPlayer(ply, TEAM_SEEKER)
		local scale = 1

		if distance and distance < 200 then
			scale = math.Clamp(math.Remap(distance, 64, 200, 0.2, 1), 0.2, 1)
		end

		game.SetTimeScale(scale)

	elseif game.GetTimeScale() ~= 1 then
		game.SetTimeScale(1)
	end

end

function GM:OnPlayerChangedTeam(ply, oldteam, newteam)

	if newteam == TEAM_SPECTATOR then

		ply:SetPlayerColor(Vector(0, 0, 0))

		local Pos = ply:EyePos()
		ply:Spawn()
		ply:SetPos(Pos)

	elseif newteam == TEAM_HIDING and self.Vars.Round.Start then

		ply:KillSilent()

	end

	ply:DropPowerUP()

	if oldteam == TEAM_SEEKER then
		PrintMessage(HUD_PRINTTALK, Format("%s left the seeker role!", ply:Nick()))
	elseif newteam == TEAM_HIDING then
		PrintMessage(HUD_PRINTTALK, Format("%s joined the game!", ply:Nick()))
	else
		PrintMessage(HUD_PRINTTALK, Format("%s joined '%s'", ply:Nick(), team.GetName(newteam)))
	end

end

function GM:DoPlayerDeath(ply, attacker, dmginfo)

	ply:CreateRagdoll()
	ply:DropPowerUP()

	ply:AddDeaths(1)

	if ply:Team() == TEAM_HIDING and self.Vars.Round.Start then
		if #self.Sounds.Death > 0 then
			ply:EmitSound(self.Sounds.Death[math.random(1, #self.Sounds.Death)], 100, 100, 1, CHAN_AUTO)
		end
		if ply.Clones and #ply.Clones > 0 then
			for k, v in pairs(ply.Clones) do
				if IsValid(v) then
					return
				end
			end
		end
	end

	if attacker:IsValid() and attacker:IsPlayer() and attacker ~= ply and attacker:Team() == TEAM_SEEKER then
		attacker:AddFrags(1)
		attacker:SetNWInt("spb_TotalVictims", attacker:GetNWInt("spb_TotalVictims", 0) + 1)
		attacker:SetNWInt("spb_VictimsCurrency", attacker:GetNWInt("spb_VictimsCurrency", 0) + 1)
		self.Vars.downvictims = (self.Vars.downvictims or 0) + 1
		hook.Call("spb_GotSomeone", nil, ply, attacker)
	end

	self:PlayerStats()

end

function GM:PlayerShouldTakeDamage(ply, attacker)

	if ply:IsCloaked() then
		return false
	end

	if attacker:IsValid() and attacker:IsPlayer() and ply:Team() == attacker:Team() then
		return false
	end

	return true

end

function GM:ShowHelp(ply)
	ply:SendLua("GAMEMODE:Menu()")
end

function GM:ShowSpare1(ply)
	if ply:Team() ~= TEAM_HIDING and ply:Team() ~= TEAM_SEEKER then return end
	ply:SendLua("GAMEMODE:TauntMenuF()")
end

function GM:ShowSpare2(ply)
	ply:SendLua("GAMEMODE:JukeboxMenu()")
end

net.Receive("spb_Taunt", function(bits,ply)
	local tauntid = net.ReadInt(32)
	taunt = GAMEMODE.Taunts[tauntid]
	GAMEMODE:Taunt(ply, taunt, tauntid)
end)
function GM:Taunt(ply, taunt, tauntid)

	if not ply:Alive() or (ply:Team() ~= TEAM_HIDING and ply:Team() ~= TEAM_SEEKER) then return end

	if not ply.TauntCooldown then
		ply.TauntCooldown = 0
	end

	if ply.TauntCooldown <= CurTime() and taunt[3] == ply:Team() or taunt[3] == 0 then

		ply:EmitSound(taunt[2], 75, 100, 1, CHAN_AUTO)

		local cd = taunt[4]

		if cd < 5 then
			cd = 5
		end

		ply.TauntCooldown = CurTime() + cd

		ply:SetNWInt("spb_LastTaunt", tauntid)
		ply:SetNWInt("spb_TauntCooldown", ply.TauntCooldown)
		ply:SetNWInt("spb_TauntCooldownF", cd)

		local shouldgivepoints = self.Vars.Round.Start and not self.Vars.Round.Pre2Start and not self.Vars.Round.End and not self.Vars.Round.TempEnd and ply:Team() ~= TEAM_SEEKER
		hook.Call("spb_Taunt", nil, ply, shouldgivepoints)

	end

end

function GM:PlayerCanHearPlayersVoice(pListener, pTalker)

	if pListener:Team() == TEAM_UNASSIGNED then
		return false, false
	end

	if pListener:Team() == TEAM_SPECTATOR then
		return true, false
	end

	if self.Vars.Round.Start and not pTalker:Alive() and pListener:Alive() then return false end

	return true, false

end

function GM:CreateDummy(ply)
	if ply:Team() ~= TEAM_HIDING or not ply:OnGround() then return false end
	local ent = ents.Create("spb_dummy")
	ent:SetPlayer(ply)
	ent:Spawn()
	if not ply.Clones then
		ply.Clones = {}
	end
	table.insert(ply.Clones, ent)
	return ent
end

function GM:PlayerRequestTeam(ply, teamid)

	if not self.TeamBased then return end

	if not team.Joinable(teamid) then ply:ChatPrint("You can't join that team") return end

	if not self:PlayerCanJoinTeam(ply, teamid) then return end

	self:PlayerJoinTeam(ply, teamid)

end

function GM:PlayerCanSeePlayersChat(text, teamOnly, listener, speaker)

	if IsValid(listener) and (listener:Team() == TEAM_SPECTATOR or (listener.XperidiaRank and listener.XperidiaRank.id >= 250)) then
		return true
	end

	if IsValid(speaker) and speaker.XperidiaRank and speaker.XperidiaRank.id >= 250 then
		return  true
	end

	if teamOnly then
		if not IsValid(speaker) or not IsValid(listener) then return false end
		if listener:Team() ~= speaker:Team() then return false end
	end

	if self.Vars.Round.Start and not self.Vars.Round.End and not teamOnly and speaker:Team() == TEAM_HIDING and not speaker:Alive() and listener:Team() == TEAM_SEEKER then
		return false
	end

	return true

end

function GM:StartCommand(ply, ucmd)
	if not ply:IsBot() then
		self:AFKThink(ply, ucmd)
	end
end

function GM:AFKThink(ply, ucmd)

	local function notmoving(ucmd)
		return ucmd:GetButtons() == 0 and ucmd:GetMouseX() == 0 and ucmd:GetMouseY() == 0
	end

	if ply.afkcheck == nil and notmoving(ucmd) then

		ply.afkcheck = CurTime()

	elseif not notmoving(ucmd) then

		ply.afkcheck = nil

		if ply.IsAFK then

			ply.IsAFK = false

			self:DebugLog(ply:GetName() .. " is no longer afk!")

			net.Start("spb_AFK")
				net.WriteFloat(0)
			net.Send(ply)

			timer.Remove("spb_AFK" .. ply:UserID())

		end

	end

	if not ply.IsAFK and ply.afkcheck ~= nil and ply.afkcheck < CurTime() - spb_afk_time:GetInt() then

		ply.IsAFK = true
		self:DebugLog(ply:GetName() .. " is afk!")

		self:BearAFKCare(ply)

	end

end

function GM:BearAFKCare(ply)

	if ply.IsAFK and ply:Team() == TEAM_SEEKER then

		net.Start("spb_AFK")
			net.WriteFloat(CurTime() + spb_afk_action:GetInt())
		net.Send(ply)

		local userid = ply:UserID()
		timer.Create("spb_AFK" .. userid, spb_afk_action:GetInt(), 1, function()
			if IsValid(ply) and ply.IsAFK and ply:Alive() and ply:Team() == TEAM_SEEKER then
				self:PlayerJoinTeam(ply, TEAM_HIDING)
				hook.Call("spb_BearAFKCared", nil, ply)
			end
			timer.Remove("spb_AFK" .. userid)
		end)

	end

end

function GM:GetFallDamage(ply, flFallSpeed)
	if ply:Team() == TEAM_SEEKER then return 0 end
	if ply:IsCloaked() then return 0 end
	if not self.Vars.Round.Start then return 0 end
	return 10
end

function GM:OnDamagedByExplosion(ply, dmginfo)
end

function GM:EntityTakeDamage(target, dmg)
	if target:IsPlayer() and target:Team() == TEAM_HIDING and target:Health() - dmg:GetDamage() > 0 and not target:IsCloaked() and #self.Sounds.Damage > 0 then
		target:EmitSound(self.Sounds.Damage[math.random(1, #self.Sounds.Damage)], 90, 100, 1, CHAN_AUTO)
	end
end

function GM:SendMusicIndex(ply)

	if not self.Musics.musics or #self.Musics.musics == 0
	or not self.Musics.premusics or #self.Musics.premusics == 0 then
		return
	end

	net.Start("spb_MusicList")

		net.WriteTable(self.Musics.musics or {})
		net.WriteTable(self.Musics.premusics or {})

	if IsValid(ply) then
		net.Send(ply)
	else
		net.Broadcast()
	end

end

function GM:SendTauntIndex(ply)
	net.Start("spb_TauntList")
		net.WriteTable(self.Taunts)
	if IsValid(ply) then net.Send(ply) else net.Broadcast() end
end

function GM:SendPMList(ply)
	net.Start("spb_PM_Lists")
		net.WriteTable(self.Vars.PM_Available)
	if IsValid(ply) then net.Send(ply) else net.Broadcast() end
end

function GM:OnDummyKilled(ent, attacker, inflictor)

	if IsValid(attacker) and attacker:GetClass() == "trigger_hurt" then attacker = ent end

	if IsValid(attacker) and attacker:IsVehicle() and IsValid(attacker:GetDriver()) then
		attacker = attacker:GetDriver()
	end

	if not IsValid(inflictor) and IsValid(attacker) then
		inflictor = attacker
	end

	-- Convert the inflictor to the weapon that they're holding if we can.
	if IsValid(inflictor) and attacker == inflictor and (inflictor:IsPlayer() or inflictor:IsNPC()) then

		inflictor = inflictor:GetActiveWeapon()
		if not IsValid(attacker) then inflictor = attacker end

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

	if not ply:Alive() or ply:Team() == TEAM_SPECTATOR or ply:Team() == TEAM_UNASSIGNED then
		return false
	end

	if (ply:Team() == TEAM_HIDING and IsValid(ent) and string.match(ent:GetClass(), "door")) then

		if not ply.UseDelay then
			ply.UseDelay = 0
		end

		if ply.UseDelay > CurTime() then
			return false
		end

		ply.UseDelay = CurTime() + 0.75

	end

	return BaseClass.PlayerUse(self, ply, ent)

end

function GM:RetrieveXperidiaAccountRank(ply)
	if not IsValid(ply) then return end
	if ply:IsBot() then return end
	if not ply.XperidiaRankLastTime or ply.XperidiaRankLastTime + 300 < SysTime() then
		local steamid = ply:SteamID64()
		self:DebugLog("Retrieving the Xperidia Rank for " .. ply:GetName() .. "...")
		http.Post("https://api.xperidia.com/account/rank/v1", {steamid = steamid},
		function(responseText, contentLength, responseHeaders, statusCode)
			if not IsValid(ply) then return end
			if statusCode == 200 then
				local rank_info = util.JSONToTable(responseText)
				if rank_info and rank_info.id then
					ply.XperidiaRank = rank_info
					ply:SetNWInt("XperidiaRank", rank_info.id)
					ply:SetNWString("XperidiaRankName", rank_info.name)
					if rank_info.color and #rank_info.color == 6 then ply:SetNWString("XperidiaRankColor", tonumber("0x" .. rank_info.color:sub(1,2)) .. " " .. tonumber("0x" .. rank_info.color:sub(3,4)) .. " " .. tonumber("0x" .. rank_info.color:sub(5,6)) .. " 255") end
					ply.XperidiaRankLastTime = SysTime()
					if rank_info.id ~= 0 and rank_info.name then
						self:DebugLog("The Xperidia Rank for " .. ply:GetName() .. " is " .. rank_info.name .. " (" .. rank_info.id .. ")")
					elseif rank_info.id ~= 0 then
						self:DebugLog("The Xperidia Rank for " .. ply:GetName() .. " is " .. rank_info.id)
					else
						self:DebugLog(ply:GetName() .. " doesn't have any Xperidia Rank...")
					end
				end
			else
				self:DebugLog("Error while retriving Xperidia Rank for " .. ply:GetName() .. " (HTTP " .. (statusCode or "?") .. ")")
			end
		end,
		function(errorMessage)
			self:DebugLog("Error while retriving Xperidia Rank for " .. ply:GetName() .. " (" .. errorMessage .. ")")
		end)
	end
end

function GM:StoreChances(ply)

	if not spb_save_chances:GetBool() then self:DebugLog("Chances saving is disabled. Not saving seeker chances.") return end

	local function savechance(pl)

		if pl:IsBot() then return end

		local chance = pl:GetNWFloat("spb_BearChance", nil)

		if chance ~= nil then
			pl:SetPData("spb_PedoChance", math.floor(math.Clamp(chance, 0, 100) * 100))
			self:DebugLog("Saved the " .. (chance * 100) .. "% seeker chance of " .. pl:GetName())
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

	if not spb_save_chances:GetBool() then self:DebugLog("Chances saving is disabled. Not loading seeker chances.") return end

	local function loadchance(pl)

		if pl:IsBot() then return end

		local chance = pl:GetPData("spb_PedoChance", nil)

		if chance ~= nil then
			chance = chance * 0.01
			pl:SetNWFloat("spb_BearChance", chance)
			self:DebugLog("Loaded the " .. (chance * 100) .. "% seeker chance of " .. pl:GetName())
		else
			pl:SetNWFloat("spb_BearChance", 0.01)
			self:DebugLog("No seeker chance found for " .. pl:GetName() .. ", default was set")
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

		local totalvictims = pl:GetNWInt("spb_TotalVictims", nil)
		local victimscurrency = pl:GetNWInt("spb_VictimsCurrency", nil)

		if totalvictims ~= nil then
			pl:SetPData("spb_TotalVictims", totalvictims)
		end

		if victimscurrency ~= nil then
			pl:SetPData("spb_VictimsCurrency", victimscurrency)
		end

		self:DebugLog("Saved the player info of " .. pl:GetName())

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
		pl:SetNWInt("spb_TotalVictims", pl:GetPData("spb_TotalVictims", 0))
		pl:SetNWInt("spb_VictimsCurrency", pl:GetPData("spb_VictimsCurrency", 0))
		self:DebugLog("Loaded the player info of " .. pl:GetName())
	end
	if IsValid(ply) then
		loadinfo(ply)
	elseif ply == nil then
		for _, v in pairs(player.GetAll()) do
			loadinfo(v)
		end
	end
end

function GM:PlayerNoClip(ply, on)
	if not on then return true end
	return IsValid(ply) and (ply:IsListenServerHost() or ply:IsSuperAdmin()) and ply:Alive()
end

function GM:CreatePowerUP(ent, powerupstr, respawn)
	if not spb_powerup_enabled:GetBool() then
		return nil
	end
	local PowerUp = ents.Create("spb_powerup")
	PowerUp:SetPos(ent:GetPos())
	if powerupstr == "dothetrap" then
		PowerUp.Trap = ent
		PowerUp:SetNWBool("Trap", true)
		PowerUp.ForcedPowerUP = "none"
	else
		PowerUp.ForcedPowerUP = powerupstr
		PowerUp.IsRespawn = respawn
		PowerUp.WasDropped = ent
	end
	PowerUp:Spawn()
	return PowerUp
end

concommand.Add("spb_dev_create_powerup", function(ply, cmd, args)
	if spb_enabledevmode:GetBool() and IsValid(ply) and (ply:IsListenServerHost() or ply:IsSuperAdmin()) then
		GAMEMODE:CreatePowerUP(ply, args[1])
	end
end, (GM or GAMEMODE).AutoCompletePowerUP, "Create a power-up", FCVAR_CLIENTCMD_CAN_EXECUTE)

function GM.PlayerMeta:SetPowerUP(powerupstr)
	if not spb_powerup_enabled:GetBool() then
		GAMEMODE:DebugLog("Tried to set a power-up to " .. self:GetName() .. " but power-ups are disabled ")
		return nil
	end
	local before = self.SPB_PowerUP
	if GAMEMODE.PowerUps[powerupstr] and (GAMEMODE.PowerUps[powerupstr][2] == self:Team() or GAMEMODE.PowerUps[powerupstr][2] == 0) then
		self.SPB_PowerUP = powerupstr
		self:SetNWString("spb_PowerUP", powerupstr)
		self.SPB_PowerUP_Delay = CurTime() + 3
		self:SetNWFloat("spb_PowerUPDelay", self.SPB_PowerUP_Delay)
		GAMEMODE:DebugLog(self:GetName() .. " has gained the " .. self.SPB_PowerUP .. " power-up")
		return self.SPB_PowerUP
	elseif powerupstr == "none" then
		self.SPB_PowerUP = powerupstr
		self:SetNWString("spb_PowerUP", powerupstr)
		GAMEMODE:DebugLog(self:GetName() .. " has lost the " .. before .. " power-up")
		return self.SPB_PowerUP
	end
	return nil
end

function GM.PlayerMeta:UsePowerUP()
	if not spb_powerup_enabled:GetBool() then
		return nil
	end
	local result
	if self.SPB_PowerUP and GAMEMODE.PowerUps[self.SPB_PowerUP] and (not self.SPB_PowerUP_Delay or self.SPB_PowerUP_Delay < CurTime()) then
		if self.SPB_PowerUP == "clone" then
			result = GAMEMODE:CreateDummy(self)
		elseif self.SPB_PowerUP == "boost" then
			self.SprintV = 200
			self:EmitSound("player/suit_sprint.wav", 75, 100, 1, CHAN_AUTO)
			result = true
		elseif self.SPB_PowerUP == "radar" then
			self:SetNWFloat("spb_RadarTime", CurTime() + spb_powerup_radar_time:GetFloat())
			result = true
		elseif self.SPB_PowerUP == "trap" then
			result = GAMEMODE:CreatePowerUP(self, "dothetrap")
		elseif self.SPB_PowerUP == "cloak" then
			result = self:PutCloak()
		end
		if result then
			GAMEMODE:DebugLog(self:GetName() .. " has used the " .. self.SPB_PowerUP .. " power-up")
			self.SPB_PowerUP = nil
			self:SetNWString("spb_PowerUP", "none")
		elseif result == nil then
			GAMEMODE:Log(self:GetName() .. " has tried to use the " .. self.SPB_PowerUP .. " power-up but no result was found!")
			self.SPB_PowerUP = nil
			self:SetNWString("spb_PowerUP", "none")
		end
	end
	return result
end

function GM.PlayerMeta:PickPowerUP(powerupstr)
	if not spb_powerup_enabled:GetBool() then
		return nil
	end
	if not self:HasPowerUP() then
		if powerupstr and GAMEMODE.PowerUps[powerupstr] and (GAMEMODE.PowerUps[powerupstr][2] == self:Team() or GAMEMODE.PowerUps[powerupstr][2] == 0) then
			return self:SetPowerUP(powerupstr)
		end
		return self:SetPowerUP(GAMEMODE:SelectRandomPowerUP(self))
	end
	return false
end

function GM.PlayerMeta:DropPowerUP()
	if self:HasPowerUP() then
		GAMEMODE:CreatePowerUP(self, self:GetPowerUP())
		self:SetPowerUP("none")
		return true
	end
	return false
end

function GM.PlayerMeta:PutCloak()
	if self:Alive() then
		local t = spb_powerup_cloak_time:GetFloat()
		local uid = self:UserID()
		self:SetRenderMode(RENDERMODE_TRANSALPHA)
		self.spb_CloakTime = CurTime() + t
		self:SetNWFloat("spb_CloakTime", self.spb_CloakTime)
		timer.Create("spb_uncloak_" .. uid, t, 1, function()
			if IsValid(self) then
				self:SetRenderMode(RENDERMODE_NORMAL)
				self.spb_CloakTime = nil
			end
			timer.Remove("spb_uncloak_" .. uid)
		end)
		return true
	end
	return false
end

concommand.Add("spb_powerup_buy", function(ply, cmd, args)
	if IsValid(ply) and ply:Alive() then
		if not spb_shop_enabled:GetBool() then
			net.Start("spb_Notif")
				net.WriteString("The Power-UP shop has been disabled in this server.")
				net.WriteInt(1, 3)
				net.WriteFloat(5)
				net.WriteBit(true)
			net.Send(ply)
			return
		end
		local pu = args[1]
		local price = GAMEMODE:GetPowerUpPrice(pu, ply)
		local cur = tonumber(ply:GetNWInt("spb_VictimsCurrency", 0))
		local ok
		if cur >= price then
			if ply:HasPowerUP() then
				ply:DropPowerUP()
			end
			ok = ply:PickPowerUP(pu)
			if ok then
				ply:SetNWInt("spb_VictimsCurrency", cur - price)
				GAMEMODE:Log(ply:GetName() .. " has bought a " .. (pu or "random") .. " power-up for " .. price .. " victims (Balance changes: " .. cur .. " => " .. ply:GetNWInt("spb_VictimsCurrency", 0) .. ")")
			end
		end
	end
end, (GM or GAMEMODE).AutoCompletePowerUP, "Buy a power-up", FCVAR_CLIENTCMD_CAN_EXECUTE)

concommand.Add("spb_powerup_drop", function(ply, cmd, args)
	if IsValid(ply) then
		ply:DropPowerUP()
	end
end, nil, "Drop a power-up", FCVAR_CLIENTCMD_CAN_EXECUTE)

local default_playermodel_list =
{
	"Homura Akemi",
	"Kyouko Sakura",
	"Madoka Kaname",
	"Mami Tomoe",
	"Sayaka Miki",
	"Tda Chibi Haku Append (v2)",
	"Tda Chibi Luka Append (v2)",
	"Tda Chibi Miku Append (v2)",
	"Tda Chibi Neru Append (v2)",
	"Tda Chibi Teto Append (v2)",
	"RAM",
	"ROM",
	"WH"
}
function GM:SaveDefaultPlayerModelListExample()

	if not file.Exists("superpedobear/default_playermodel_list_example.json", "DATA") then

		self:Log("Writting default_playermodel_list_example.json and default_playermodel_list_readme.txt...")

		file.Write("superpedobear/default_playermodel_list_example.json", util.TableToJSON(default_playermodel_list, true))

		file.Write("superpedobear/default_playermodel_list_readme.txt", "You can use the \"default_playermodel_list_example.json\" to make your own custom default playermodel list \"default_playermodel_list.json\".")

	end

end

function GM:LoadDefaultPlayerModelList()

	local raw_list = file.Read("superpedobear/default_playermodel_list.json")

	if raw_list then

		local list = util.JSONToTable(raw_list)

		if list then

			self:Log("Custom default_playermodel_list.json loaded succefully!")

			return list, true

		else

			self:ErrorLog("[Super Pedobear] Error while loading default_playermodel_list.json! Make sure it is valid JSON!")

		end
	else

		self:Log("No custom default_playermodel_list.json found.")

	end

	self:Log("Using the builtin default playermodel list.")

	return default_playermodel_list, false

end

function GM:BuildDefaultPlayerModelList()

	self:Log("Building default playermodel list...")

	self:SaveDefaultPlayerModelListExample()

	self.Vars.PM_Available = player_manager.AllValidModels()
	self.Vars.PM_Default = {}

	local list, custom = self:LoadDefaultPlayerModelList()

	for k, v in pairs(list) do
		if self.Vars.PM_Available[v] then
			table.insert(self.Vars.PM_Default, v)
			self:DebugLog("Playermodel found: " .. v)
		elseif custom then
			self:ErrorLog("Playermodel not found: " .. v)
		else
			self:DebugLog("Playermodel not found: " .. v)
		end
	end

	if #self.Vars.PM_Default > 0 then
		self:Log("Default player model list built. (" .. #self.Vars.PM_Default .. " found out of " .. #list .. " selected)")
		self:DebugLog("Final default playermodel list: " .. table.concat(self.Vars.PM_Default, ", "))
	else
		self:Log("Default player model list empty!")
	end

end

function GM:PlayerCanPickupWeapon(ply, entity)

	if entity:GetClass() == "spb_seeker" and ply:Team() == TEAM_SEEKER then
		return true
	elseif ply:Team() == TEAM_SEEKER then
		return false
	end

	return BaseClass.PlayerCanPickupWeapon(self, ply, entity)

end

local forbidden_items = {
	item_battery = true,
	item_suit = true,
}

function GM:PlayerCanPickupItem(ply, entity)

	if ply:Team() == TEAM_SEEKER then
		return false
	elseif forbidden_items[entity:GetClass()] then
		return false
	end

	return BaseClass.PlayerCanPickupItem(self, ply, entity)

end

function GM:SetupPlayerVisibility(pPlayer, pViewEntity)

	if IsValid(pViewEntity) then

		AddOriginToPVS(pViewEntity:GetPos())

	end

	local radartime = pPlayer:GetNWFloat("spb_RadarTime", 0)
	local showvictims = radartime ~= 0 and radartime > CurTime()

	if showvictims then

		for k, v in pairs(player.GetAll()) do

			if v:Team() == TEAM_HIDING and v:Alive() then

				AddOriginToPVS(v:GetPos())

			end

		end

	end

end
