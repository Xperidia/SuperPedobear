--[[---------------------------------------------------------
		Super Pedobear Gamemode for Garry's Mod
				by VictorienXP (2016-2020)
-----------------------------------------------------------]]

include("shared.lua")
include("cl_scoreboard.lua")
include("cl_menu.lua")
include("cl_tauntmenu.lua")
include("cl_voice.lua")
include("cl_deathnotice.lua")
include("cl_van.lua")
include("cl_hud.lua")
include("cl_mapvote.lua")

DEFINE_BASECLASS("gamemode_base")

surface.CreateFont("spb_TIME", {
	font = "Roboto",
	size = 75,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = true,
	additive = false,
	outline = false,
})
surface.CreateFont("spb_RND", {
	font = "Roboto",
	size = 50,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = true,
	additive = false,
	outline = false,
})
surface.CreateFont("spb_TXT", {
	font = "Roboto",
	size = 40,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = true,
	additive = false,
	outline = false,
})
surface.CreateFont("spb_HT", {
	font = "Roboto",
	size = 24,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = true,
	additive = false,
	outline = false,
})
surface.CreateFont("spb_HUDname", {
	font = "Roboto",
	size = 20,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
})
surface.CreateFont("spb_Normal_Scaled", {
	font = "Roboto",
	size = ScreenScale(8),
	weight = 500
})
surface.CreateFont("spb_High_Scaled", {
	font = "Roboto",
	size = ScreenScale(10),
	weight = 500
})
surface.CreateFont("spb_Big_Scaled", {
	font = "Roboto",
	size = ScreenScale(16),
	weight = 500
})

net.Receive("spb_PlayerStats", function(len)
	GAMEMODE.Vars.victims		= net.ReadUInt(8)
	GAMEMODE.Vars.downvictims	= net.ReadUInt(10)
end)

net.Receive("spb_Vars", function(len)
	GAMEMODE.Vars.Round.Start			= tobool(net.ReadBool())
	GAMEMODE.Vars.Round.PreStart		= tobool(net.ReadBool())
	GAMEMODE.Vars.Round.PreStartTime	= net.ReadFloat()
	GAMEMODE.Vars.Round.Pre2Start		= tobool(net.ReadBool())
	GAMEMODE.Vars.Round.Pre2Time		= net.ReadFloat()
	GAMEMODE.Vars.Round.Time			= net.ReadFloat()
	GAMEMODE.Vars.Round.End				= tobool(net.ReadBool())
	GAMEMODE.Vars.Round.Win				= net.ReadInt(4)
	GAMEMODE.Vars.Round.LastTime		= net.ReadFloat()
	GAMEMODE.Vars.Round.TempEnd			= tobool(net.ReadBool())
	GAMEMODE.Vars.Rounds				= net.ReadUInt(32)
end)

net.Receive("spb_Music", function(len)
	local src = net.ReadString()
	local pre = net.ReadBool()
	local name = net.ReadString()
	GAMEMODE:Music(src, pre, name)
end)

net.Receive("spb_AFK", function(len)
	GAMEMODE.Vars.AfkTime = net.ReadFloat()
	if GAMEMODE.Vars.AfkTime != 0 then system.FlashWindow() chat.PlaySound() end
end)

net.Receive("spb_MusicList", function(len)
	GAMEMODE.Musics.musics = net.ReadTable()
	GAMEMODE.Musics.premusics = net.ReadTable()
end)

net.Receive("spb_TauntList", function(len)
	GAMEMODE.Taunts = net.ReadTable()
end)

net.Receive("spb_PM_Lists", function(len)
	GAMEMODE.Vars.PM_Available = net.ReadTable()
end)

net.Receive("spb_List", function(len)
	GAMEMODE.Vars.Bears = net.ReadTable()
end)

net.Receive("spb_MusicQueue", function(len)
	GAMEMODE.Vars.MusicQueue = net.ReadTable()
end)

net.Receive("spb_MapList", function(len)
	GAMEMODE.MapList = net.ReadTable()
end)

hook.Add("HUDShouldDraw", "HideHUD", function(name)
	local ply = LocalPlayer()
	local HUDhide = {
		CHudHealth = true,
		CHudBattery = true,
		CHudDamageIndicator = true,
		CHudWeaponSelection = (ply.GetWeapons and table.Count(ply:GetWeapons()) < 2) or IsValid(GAMEMODE.VanFrame),
		CHudZoom = true
	}
	if name == "CHudCrosshair" and ply:Team() == TEAM_UNASSIGNED then
		return false
	elseif HUDhide[name] then
		return false
	end
end)

function GM:LimitString(str, size, font)
	surface.SetFont(font)
	if surface.GetTextSize(str) <= size then
		return str
	end
	while surface.GetTextSize(str .. "...") >= size do
		str = string.Left(str, #str - 1)
	end
	return str .. "..."
end

net.Receive("spb_Notif", function(len)

	local str = net.ReadString() or ""
	local ne = net.ReadInt(3) or 0
	local dur = net.ReadFloat() or 5
	local sound = net.ReadBit() or false

	GAMEMODE:Notif(str, ne, dur, sound)

end)
function GM:Notif(str, ne, dur, sound)
	notification.AddLegacy(str, ne, dur, sound)
	if !tobool(sound) then return end
	if ne == NOTIFY_HINT then
		surface.PlaySound("ambient/water/drip" .. math.random(1, 4) .. ".wav")
	elseif ne == NOTIFY_ERROR then
		surface.PlaySound("buttons/button10.wav")
	else
		chat.PlaySound()
	end
end

function GM:PreDrawHalos()

	if GetConVar("spb_cl_disablehalos"):GetBool() then return end

	local ply = LocalPlayer()
	local tab = {}
	local tab2 = {}
	local tab3 = {}
	local sply = ply:GetObserverTarget() or ply
	if !sply:IsPlayer() then
		sply = ply
	end
	local welding = sply:GetNWEntity("spb_Welding")
	if welding == sply then
		welding = nil
	end

	if ply:Team() == TEAM_HIDING then

		if !ply:Alive() then

			for k,v in pairs(player.GetAll()) do
				if v:Team() == TEAM_HIDING and v:Alive() then
					table.insert(tab, v)
				end
			end
			halo.Add(tab, team.GetColor(TEAM_HIDING), 1, 1, 1, true, true)

			for k,v in pairs(ents.FindByClass("spb_dummy")) do
				table.insert(tab3, v)
			end
			halo.Add(tab3, Color(0, 0, 255), 1, 1, 1, true, true)

		else

			for k,v in pairs(ents.FindByClass("spb_dummy")) do
				if v:GetPlayer() == ply then
					table.insert(tab3, v)
				end
			end
			halo.Add(tab3, Color(0, 0, 255), 1, 1, 1, true, true)

		end

		for k,v in pairs(player.GetAll()) do
			if v:Team() == TEAM_SEEKER and v:Alive() then
				table.insert(tab2, v)
			end
		end
		local radartime = ply:GetNWFloat("spb_RadarTime", 0)
		local showseekers = radartime != 0 and radartime > CurTime()
		halo.Add(tab2, team.GetColor(TEAM_SEEKER), 1, 1, 1, true, !ply:Alive() or showseekers)

		if IsValid(welding) then
			halo.Add({welding}, Color(255, 255, 255), 1, 1, 1, true, false)
		end

	elseif ply:Team() == TEAM_SEEKER then

		local radartime = ply:GetNWFloat("spb_RadarTime", 0)
		local showvictims = radartime != 0 and radartime > CurTime()
		for k,v in pairs(player.GetAll()) do
			if v:Team() == TEAM_SEEKER and v:Alive() then
				table.insert(tab, v)
			elseif showvictims and v:Team() == TEAM_HIDING and v:Alive() then
				table.insert(tab2, v)
			end
		end
		halo.Add(tab, team.GetColor(TEAM_SEEKER), 1, 1, 1, true, true)
		halo.Add(tab2, team.GetColor(TEAM_HIDING), 1, 1, 1, true, true)

	elseif ply:Team() == TEAM_SPECTATOR then

		for k,v in pairs(player.GetAll()) do
			if v:Team() == TEAM_HIDING and v:Alive() then
				table.insert(tab, v)
			end
		end

		for k,v in pairs(player.GetAll()) do
			if v:Team() == TEAM_SEEKER and v:Alive() then
				table.insert(tab2, v)
			end
		end

		halo.Add(tab, team.GetColor(TEAM_HIDING), 1, 1, 1, true, true)
		halo.Add(tab2, team.GetColor(TEAM_SEEKER), 2, 2, 2, true, true)

	end

end

function GM:ShowTeam()

	if !IsValid(self.TeamSelectFrame) then

		self.TeamSelectFrame = vgui.Create("DFrame")
		self.TeamSelectFrame:SetTitle("Pick Team")

		local AllTeams = team.GetAllTeams()
		local x = 4
		local y = 156
		for ID, TeamInfo in pairs (AllTeams) do

			if (ID != TEAM_CONNECTING and ID != TEAM_UNASSIGNED) and team.Joinable(ID) then

				local Team = vgui.Create("DButton", self.TeamSelectFrame)
				function Team.DoClick() self:HideTeam() RunConsoleCommand("changeteam", ID) end
				Team:SetPos(x, 24)
				Team:SetSize(256, 128)
				Team:SetText(TeamInfo.Name)
				Team:SetTextColor(TeamInfo.Color)
				Team:SetFont("DermaLarge")
				Team:SetExpensiveShadow(1, Color(0,0,0,255))

				if IsValid(LocalPlayer()) and LocalPlayer():Team() == ID then
					Team:SetDisabled(true)
					Team:SetTextColor(Color(40, 40, 40))
					Team.Paint = function(self, w, h)
						draw.RoundedBox(4, 4, 4, w - 8, h - 8, Color(0, 0, 0, 150))
					end
				else
					Team:SetTextColor(TeamInfo.Color)
					Team.Paint = function(self, w, h)
						draw.RoundedBox(4, 4, 4, w - 8, h - 8, Color(255, 255, 255, 150))
					end
				end

				x = x + 256

			end

		end

		if GAMEMODE.AllowAutoTeam then

			local Team = vgui.Create("DButton", self.TeamSelectFrame)
			function Team.DoClick() self:HideTeam() RunConsoleCommand("autoteam") end
			Team:SetPos(4 + x / 3, 280)
			Team:SetSize(x / 3 - 4, 32)
			Team:SetText("Auto")
			Team:SetTextColor(GAMEMODE.Colors_default)
			Team:SetFont("DermaLarge")
			Team.Paint = function(self, w, h)
				draw.RoundedBox(4, 4, 4, w - 8, h - 8, Color(255, 255, 255, 150))
			end

			y = y + 32

		end

		self.TeamSelectFrame:SetSize(x + 4, y)
		self.TeamSelectFrame:SetDraggable(true)
		self.TeamSelectFrame:SetScreenLock(true)
		self.TeamSelectFrame:SetPaintShadow(true)
		self.TeamSelectFrame:Center()
		self.TeamSelectFrame:MakePopup()
		self.TeamSelectFrame:SetKeyboardInputEnabled(false)
		self.TeamSelectFrame.Paint = function(self, w, h)
			draw.RoundedBox(4, 0, 0, w, h, Color(0, 0, 0, 128))
		end

	else
		self.TeamSelectFrame:Close()
	end

end

function GM:Think()

	local ply = LocalPlayer()
	local use_quick = GetConVar("spb_cl_quickstuff_enable"):GetBool()
	local use_numpad = GetConVar("spb_cl_quickstuff_numpad"):GetBool()
	local got_weapons = (ply.GetWeapons and table.Count(ply:GetWeapons()) > 1) and !IsValid(GAMEMODE.VanFrame)

	if use_quick then
		if GAMEMODE.Vars.NInputs then
			GAMEMODE.Vars.LNInputs = {
										GAMEMODE.Vars.NInputs[1] or false,
										GAMEMODE.Vars.NInputs[2] or false,
										GAMEMODE.Vars.NInputs[3] or false,
										GAMEMODE.Vars.NInputs[4] or false,
										GAMEMODE.Vars.NInputs[5] or false,
										GAMEMODE.Vars.NInputs[6] or false,
										GAMEMODE.Vars.NInputs[7] or false,
										GAMEMODE.Vars.NInputs[8] or false,
										GAMEMODE.Vars.NInputs[9] or false,
										GAMEMODE.Vars.NInputs[10] or false
									}
		end
		GAMEMODE.Vars.NInputs = {
									(!got_weapons and input.IsKeyDown(KEY_1)) or (use_numpad and input.IsKeyDown(KEY_PAD_1)),
									(!got_weapons and input.IsKeyDown(KEY_2)) or (use_numpad and input.IsKeyDown(KEY_PAD_2)),
									(!got_weapons and input.IsKeyDown(KEY_3)) or (use_numpad and input.IsKeyDown(KEY_PAD_3)),
									(!got_weapons and input.IsKeyDown(KEY_4)) or (use_numpad and input.IsKeyDown(KEY_PAD_4)),
									(!got_weapons and input.IsKeyDown(KEY_5)) or (use_numpad and input.IsKeyDown(KEY_PAD_5)),
									(!got_weapons and input.IsKeyDown(KEY_6)) or (use_numpad and input.IsKeyDown(KEY_PAD_6)),
									(!got_weapons and input.IsKeyDown(KEY_7)) or (use_numpad and input.IsKeyDown(KEY_PAD_7)),
									(!got_weapons and input.IsKeyDown(KEY_8)) or (use_numpad and input.IsKeyDown(KEY_PAD_8)),
									(!got_weapons and input.IsKeyDown(KEY_9)) or (use_numpad and input.IsKeyDown(KEY_PAD_9)),
									(!got_weapons and input.IsKeyDown(KEY_0)) or (use_numpad and input.IsKeyDown(KEY_PAD_0))
							}

		if ply:Alive() and (ply:Team() == TEAM_HIDING or ply:Team() == TEAM_SEEKER) and !GAMEMODE.ChatOpen and !gui.IsGameUIVisible() and !IsValid(GAMEMODE.VanFrame) then

			local sel = 0

			if GAMEMODE.Vars.NInputs[10] != true then
				for k, v in pairs(GAMEMODE.Vars.NInputs) do
					if v == true and GAMEMODE.Vars.LNInputs[k] != true then
						sel = k
						break
					end
				end
			elseif GAMEMODE.Vars.NInputs[10] == true and GAMEMODE.Vars.LNInputs[10] != true then
				local selt = {}
				for k, v in pairs(GAMEMODE.Taunts) do
					if v[3] == ply:Team() or v[3] == 0 then
						table.insert(selt, v)
					end
				end
				sel = math.random(1, #selt)
			end

			GAMEMODE:StartTaunt(sel)

		end
	end

	if ply:Team() == TEAM_HIDING and ply:Alive() and GAMEMODE.Vars.Round.Start and !GAMEMODE.Vars.Round.End and !GAMEMODE.Vars.Round.TempEnd then
		GAMEMODE:HeartBeat(ply)
	end

end

function GM:PlayerBindPress(ply, bind, down)

	if down and bind == "gmod_undo" then
		RunConsoleCommand("spb_powerup_drop")
	elseif down and bind == "phys_swap" and !ply:HasWeapon("weapon_physcannon") then
		RunConsoleCommand("playermodel_selector")
	end

	return false

end

function GM:HeartBeat(ply)

	local _, distance = GAMEMODE:GetClosestPlayer(ply, TEAM_SEEKER)
	local nextheartbeat = 1
	local volume = 1

	if distance and distance < 1000 then

		nextheartbeat = math.Remap(distance, 0, 1000, 0.30, 2)
		volume = math.Remap(distance, 1000, 0, 0.30, 1)

		if !ply.LastHeartBeat or ply.LastHeartBeat + nextheartbeat < CurTime() then
			ply:EmitSound(GAMEMODE.Sounds.HeartBeat, 0, 100, volume, CHAN_AUTO)
			ply.LastHeartBeat = CurTime()
		end

	end

end

function GM:StartTaunt(sel)

	local ply = LocalPlayer()

	if sel and sel != 0 and GAMEMODE.Taunts[sel] and (!ply.TauntCooldown or ply.TauntCooldown-CurTime() + 0.5 < 0) then

		if GAMEMODE.Taunts[sel][3] != 0 and GAMEMODE.Taunts[sel][3] != ply:Team() then return end

		net.Start("spb_Taunt")
			net.WriteInt(sel, 32)
		net.SendToServer()

		local cd = GAMEMODE.Taunts[sel][4]

		if cd < 5 then
			cd = 5
		end

		ply.TauntCooldown = CurTime() + cd
		ply.TauntCooldownF = cd
		ply.LastTaunt = sel

	end

end

function GM:Music(src, pre, name, retry)

	if !retry then retry = 0 end

	GAMEMODE:BuildMusicIndex()

	GAMEMODE.Vars.CurrentMusic = src

	if IsValid(GAMEMODE.Vars.Music) and src == "play" then
		GAMEMODE.Vars.Music:Play()
	elseif IsValid(GAMEMODE.Vars.Music) and src == "pause" then
		GAMEMODE.Vars.Music:Pause()
	elseif IsValid(GAMEMODE.Vars.Music) then
		GAMEMODE.Vars.Music:Stop()
		GAMEMODE.Vars.CurrentMusicName = nil
		GAMEMODE.Vars.Music = nil
	end

	if src != "stop" and src != "pause" and src != "play" and GetConVar("spb_cl_music_enable"):GetBool() then

		local exist = file.Exists(src, "GAME")
		local isurl = false
		local orisrc = nil

		if src != "" and !exist and GetConVar("spb_cl_music_allowexternal"):GetBool() and string.match(src, "://") then

			isurl = true

		elseif src == "" or !exist then

			local tbl = file.Find("sound/superpedobear/" .. Either(pre, "premusics", "musics") .. "/*", "GAME")

			if #tbl > 0 then
				orisrc = src
				src = "sound/superpedobear/" .. Either(pre, "premusics", "musics") .. "/" .. tbl[math.random(1,#tbl)]
			end

		end

		local function domusicstuff(mus, errorID, errorName)

			if IsValid(mus) then
				mus:SetVolume(GetConVar("spb_cl_music_volume"):GetFloat())
				mus:EnableLooping(true)
				GAMEMODE.Vars.Music = mus
				if mus.GetTagsOGG and mus:GetTagsOGG() then
					local title = GAMEMODE:FindOGGTag(mus:GetTagsOGG(), "TITLE")
					if title then
						GAMEMODE.Vars.CurrentMusicName = title
					end
				elseif mus.GetTagsID3 and mus:GetTagsID3() and mus:GetTagsID3().title then
					GAMEMODE.Vars.CurrentMusicName = string.Trim(mus:GetTagsID3().title)
				end
			end

			if errorID or errorName then
				GAMEMODE:Log("Error while starting music \"" .. src .. "\": " .. errorName .. " (" .. errorID .. ")")
				if retry < 5 then
					GAMEMODE:Log("Retrying with fallback...")
					GAMEMODE:Music("", pre, nil, retry + 1)
				else
					GAMEMODE:Log("Too many retries! Aborting fallback...")
				end
			elseif orisrc != nil then
				GAMEMODE:Log("Playing music \"" .. src .. "\"" .. Either(pre, " (pre round music)", "") .. " instead of " .. Either(orisrc != "", "\"" .. orisrc .. "\"", "nothing"))
				GAMEMODE.Vars.CurrentMusicName = ""
			else
				GAMEMODE:Log("Playing music \"" .. src .. "\"" .. Either(pre, " (pre round music)", ""))
			end

		end

		if !isurl and src != "" then
			sound.PlayFile(src, "noblock", domusicstuff)
		elseif isurl then
			GAMEMODE:Log("Downloading external music... \"" .. src .. "\"")
			sound.PlayURL(src, "noblock", domusicstuff)
		end

		GAMEMODE.Vars.CurrentMusicName = name

	end

end

function GM:StartChat(teamsay)
	GAMEMODE.ChatOpen = true
	return false
end

function GM:FinishChat()
	GAMEMODE.ChatOpen = false
end

function GM:GetTeamColor(ent)
	local team = TEAM_UNASSIGNED
	if ent.Team then team = ent:Team() end
	if ent:GetClass() == "spb_dummy" then team = TEAM_HIDING end
	return GAMEMODE:GetTeamNumColor(team)
end

function GM:InitPostEntity()
	if !GAMEMODE:LoadStats() then
		GAMEMODE:SplashScreen()
	end
end

function GM:LoadStats()

	local stats = file.Read("superpedobear/stats.json")

	if stats then
		local t = util.JSONToTable(stats)
		return t or (t.Version and t.Version >= (GAMEMODE.Version or 0))
	else
		return nil
	end

end

function GM:SaveStats()

	local stats = {}

	stats.Version = GAMEMODE.Version or 0

	file.Write("superpedobear/stats.json", util.TableToJSON(stats))

	file.Delete("superpedobear/info.txt")

end

function GM:ContextMenuOpen()
	return true
end

function GM:OnContextMenuOpen()
	LocalPlayer().ThirdPerson = !LocalPlayer().ThirdPerson
end

function GM:OnSpawnMenuOpen()
	GAMEMODE:Van()
end

hook.Add("CalcView", "spb_thirdperson", function(ply, pos, angles, fov)

	if ply:Alive() and ply.ThirdPerson and !ply:IsPlayingTaunt() and ply:Team() != TEAM_SPECTATOR then

		local view = {}

		local traceData = {}
		traceData.start = ply:EyePos()
		traceData.endpos = traceData.start + angles:Forward() * -100
		traceData.endpos = traceData.endpos + angles:Right()
		traceData.endpos = traceData.endpos + angles:Up()
		traceData.collisiongroup = COLLISION_GROUP_DEBRIS
		traceData.filter = ply

		local trace = util.TraceLine(traceData)

		pos = trace.HitPos

		if trace.Fraction < 1.0 then
			pos = pos + trace.HitNormal * 5
		end

		view.origin = pos
		view.angles = angles
		view.fov = fov
		view.drawviewer = true

		return view

	end

end)

function GM:CheckBind(cmd)
	if input.LookupBinding(cmd, true) then
		return string.upper(input.LookupBinding(cmd, true))
	end
	return "N/A"
end

function GM:OnPlayerChat(player, strText, bTeamOnly, bPlayerIsDead)

	local tab = {}

	if bPlayerIsDead then
		table.insert(tab, Color(255, 30, 40))
		table.insert(tab, "*DEAD* ")
	end

	if bTeamOnly then
		table.insert(tab, Color(30, 160, 40))
		table.insert(tab, "(TEAM) ")
	end

	if IsValid(player) then
		local rankid = player:GetNWInt("XperidiaRank", 0)
		local rankname = player:GetNWString("XperidiaRankName", "<Unknown rank name>")
		local rankcolor = player:GetNWString("XperidiaRankColor", "255 255 255 255")
		if player:IsGamemodeAuthor() then
			table.insert(tab, string.ToColor(rankcolor))
			table.insert(tab, "{Gamemode author} ")
		elseif rankid > 0 then
			table.insert(tab, string.ToColor(rankcolor))
			table.insert(tab, "{Xperidia " .. rankname .. "} ")
		end
		if player:GetUserGroup() != "user" then
			table.insert(tab, Color(255, 255, 255))
			table.insert(tab, "[" .. string.upper(string.sub(player:GetUserGroup(), 1, 1)) .. string.sub(player:GetUserGroup(), 2) .. "] ")
		end
		table.insert(tab, player)
	else
		table.insert(tab, "Console")
	end

	table.insert(tab, Color(255, 255, 255))
	table.insert(tab, ": " .. strText)

	chat.AddText(unpack(tab))

	return true

end

function GM:RenderScreenspaceEffects()

	local ply = LocalPlayer()

	local ravemode = false
	if GAMEMODE.Vars.Bears and #GAMEMODE.Vars.Bears > 0 then
		for k, v in pairs(GAMEMODE.Vars.Bears) do
			if IsValid(v) and v:Alive() and v:SteamID64() == "76561198108011282" then
				ravemode = true
			end
		end
	end

	if ravemode then
		local x = CurTime() * 5
		local tab = {
			["$pp_colour_addr"] = 0,
			["$pp_colour_addg"] = 0,
			["$pp_colour_addb"] = 0,
			["$pp_colour_brightness"] = 0,
			["$pp_colour_contrast"] = 1,
			["$pp_colour_colour"] = 1,
			["$pp_colour_mulr"] = (0.5 * math.sin(x - 1)) * 10,
			["$pp_colour_mulg"] = (0.5 * math.sin(x)) * 10,
			["$pp_colour_mulb"] = (0.5 * math.sin(x + 1)) * 10
		}
		DrawColorModify(tab)
	end

	if ply:Team() == TEAM_HIDING and ply:Alive() then

		local _, distance = GAMEMODE:GetClosestPlayer(ply, TEAM_SEEKER)

		if distance and distance < 400 then
			DrawToyTown(1, ScrH() * math.Clamp(math.Remap(distance, 300, 32, 0, 0.8), 0, 0.8))
			DrawMotionBlur(0.4, math.Clamp(math.Remap(distance, 200, 32, 0, 0.8), 0, 0.8), 0.01)
			local x = CurTime() * 5
			local tab = {
				["$pp_colour_addr"] = 0,
				["$pp_colour_addg"] = 0,
				["$pp_colour_addb"] = 0,
				["$pp_colour_brightness"] = 0,
				["$pp_colour_contrast"] = math.Clamp(math.Remap(distance, 32, 200, 0.1, 1), 0.1, 1),
				["$pp_colour_colour"] = 1,
				["$pp_colour_mulr"] = 0,
				["$pp_colour_mulg"] = 0,
				["$pp_colour_mulb"] = 0
			}
			DrawColorModify(tab)
		end

	end

end
