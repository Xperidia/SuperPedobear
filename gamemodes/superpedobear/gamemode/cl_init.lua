include("shared.lua")
include("cl_scoreboard.lua")
include("cl_menu.lua")
include("cl_tauntmenu.lua")
include("cl_voice.lua")
include("cl_deathnotice.lua")
include("cl_van.lua")

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

net.Receive("spb_PlayerStats", function( len )
	GAMEMODE.Vars.victims = net.ReadInt(32)
	GAMEMODE.Vars.downvictims = net.ReadInt(32)
end)

net.Receive("spb_Vars", function( len )
	GAMEMODE.Vars.Round.Start = tobool(net.ReadBool())
	GAMEMODE.Vars.Round.PreStart = tobool(net.ReadBool())
	GAMEMODE.Vars.Round.PreStartTime = net.ReadFloat()
	GAMEMODE.Vars.Round.Pre2Start = tobool(net.ReadBool())
	GAMEMODE.Vars.Round.Pre2Time = net.ReadFloat()
	GAMEMODE.Vars.Round.Time = net.ReadFloat()
	GAMEMODE.Vars.Round.End = tobool(net.ReadBool())
	GAMEMODE.Vars.Round.Win = net.ReadInt(32)
	GAMEMODE.Vars.Rounds = net.ReadInt(32)
	GAMEMODE.Vars.Round.LastTime = net.ReadFloat()
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

function GM:FormatTime(time)
	local timet = string.FormattedTime(time)
	if timet.h >= 999 then
		return "∞"
	elseif timet.h >= 1 then
		return string.format("%02i:%02i", timet.h, timet.m)
	elseif timet.m >= 1 then
		return string.format("%02i:%02i", timet.m, timet.s)
	else
		return string.format("%02i.%02i", timet.s, math.Clamp(timet.ms, 0, 99))
	end
end

function GM:FormatTimeTri(time)
	local timet = string.FormattedTime( time )
	if timet.h > 0 then
		return string.format("%02i:%02i:%02i", timet.h, timet.m, timet.s)
	end
	return string.format("%02i:%02i", timet.m, timet.s)
end

function GM:PrettyMusicName(snd)
	local str = string.StripExtension(snd)
	str = string.Replace(str, "_", " ")
	str = string.Replace(str, "%20", " ")
	return string.gsub(str, "(%a)([%w_']*)", function(first, rest) return first:upper() .. rest:lower() end)
end

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

function GM:HUDPaint()

	if !GetConVar("cl_drawhud"):GetBool() then return end

	hook.Run("HUDDrawTargetID")
	hook.Run("DrawDeathNotice", 0.85, 0.04)

	--[[ THE INDEX ZONE ]]--

	local PreStartTime = GAMEMODE.Vars.Round.PreStartTime
	local PreStart = GAMEMODE.Vars.Round.PreStart
	local Pre2Time = GAMEMODE.Vars.Round.Pre2Time
	local Pre2Start = GAMEMODE.Vars.Round.Pre2Start
	local Time = GAMEMODE.Vars.Round.Time
	local End = GAMEMODE.Vars.Round.End
	local LastTime = GAMEMODE.Vars.Round.LastTime
	local Start = GAMEMODE.Vars.Round.Start
	local TempEnd = GAMEMODE.Vars.Round.TempEnd

	local function yay(a) return (math.sin(CurTime() * 6) + 1) / 2 * a end
	local ply = LocalPlayer()
	local sply = ply:GetObserverTarget() or ply
	if !sply:IsPlayer() then
		sply = ply
	end
	local plyAlive = ply:Alive()
	local plyTeam = ply:Team()
	local splyAlive = sply:Alive()
	local splyTeam = sply:Team()
	local col = sply:GetPlayerColor():ToColor()
	if !splyAlive then col = team.GetColor(splyTeam) end
	local wi = true
	if !splyAlive or (splyTeam != TEAM_SEEKER and splyTeam != TEAM_HIDING) then
		wi = false
	end
	local welding = sply:GetNWEntity("spb_Welding")
	if welding == sply then
		welding = nil
	end
	local weldingstate = sply:GetNWInt("spb_WeldingState")
	local hide_tips = GetConVar("spb_cl_hide_tips"):GetBool() or End
	local hudoffset_w = GetConVar("spb_cl_hud_offset_w") and GetConVar("spb_cl_hud_offset_w"):GetInt() or 0
	local hudoffset_h = GetConVar("spb_cl_hud_offset_h") and GetConVar("spb_cl_hud_offset_h"):GetInt() or 0
	hudoffset_w = ScrW() * (hudoffset_w * 0.001)
	hudoffset_h = ScrH() * (hudoffset_h * 0.001)
	local wep = ""
	if plyAlive and IsValid(ply:GetActiveWeapon()) then
		wep = ply:GetActiveWeapon():GetClass()
	end
	local swep = ""
	if splyAlive and IsValid(sply:GetActiveWeapon()) then
		swep = sply:GetActiveWeapon():GetClass()
	end


	--[[ THE CLOCK AND ROUND COUNT ]]--

	local TheTime = 0
	local rnd = GAMEMODE.Vars.Rounds or 0
	local time_color = Color(255, 255, 255, 255)

	if Pre2Time and Pre2Time - CurTime() >= 0 then
		TheTime = Pre2Time - CurTime()
		if plyTeam == TEAM_HIDING then
			time_color = Color(255, 0, 0, 255)
		elseif plyTeam == TEAM_SEEKER then
			time_color = Color(0, 255, 0, 255)
		else
			time_color = Color(255, 255, 0, 255)
		end
	elseif PreStartTime and PreStartTime - CurTime() >= 0 then
		TheTime = PreStartTime - CurTime()
		if TheTime < 10 then
			time_color = Color(255, 255, 0, 255)
		end
	elseif Time and Time - CurTime() >= 0 then
		TheTime = Time - CurTime()
		if TheTime < 60 and plyTeam == TEAM_HIDING then
			time_color = Color(0, 255, 0, 255)
		elseif TheTime < 60 and plyTeam == TEAM_SEEKER then
			time_color = Color(255, 0, 0, 255)
		elseif TheTime < 60 then
			time_color = Color(255, 255, 0, 255)
		end
	elseif End or TempEnd then
		TheTime = LastTime
	elseif !Start and !PreStart then
		if GAMEMODE.Vars.Tutorial then
			TheTime = 2147483647
		elseif rnd <= 1 then
			TheTime = 40
		else
			TheTime = spb_round_pretime:GetFloat()
		end
	end

	local max_rounds = spb_rounds:GetInt()
	if rnd > 99 or GAMEMODE.Vars.Tutorial then
		rnd = "∞"
	elseif MapVote and max_rounds < 10 and max_rounds > 0 then
		rnd = rnd .. "/" .. max_rounds
	end

	surface.SetDrawColor(Color(0, 0, 0, 200))
	surface.DrawRect(ScrW() / 2 - 100, hudoffset_h, 200, 110)
	draw.DrawText(GAMEMODE:FormatTime(TheTime), "spb_TIME", ScrW() / 2, hudoffset_h, time_color, TEXT_ALIGN_CENTER)
	draw.DrawText("Round " .. rnd, "spb_RND", ScrW() / 2, 60 + hudoffset_h, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)
	surface.SetDrawColor(Color(0, 0, 0, 255))
	surface.DrawOutlinedRect(ScrW() / 2 - 100, hudoffset_h, 200, 110)

	draw.DrawText(GAMEMODE.Name .. " V" .. GAMEMODE.Version .. " - " ..  os.date("%d/%m/%Y", os.time()), "DermaDefault", ScrW() / 2, hudoffset_h, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)


	--[[ THE ROUND STATUS ]]--

	local rndtxth = 0
	local function addrndtxt(str)
		surface.SetFont("spb_RND")
		local w, h = surface.GetTextSize(str)
		surface.SetDrawColor(Color(0, 0, 0, 200))
		surface.DrawRect(ScrW() / 2 - w / 2 - 8, 110 + hudoffset_h + rndtxth, w + 16, h)
		draw.DrawText(str, "spb_RND", ScrW() / 2, 110 + hudoffset_h + rndtxth, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)
		surface.SetDrawColor(Color(0, 0, 0, 255))
		surface.DrawOutlinedRect(ScrW() / 2 - w / 2 - 8, 110 + hudoffset_h + rndtxth, w + 16, h)
		rndtxth = rndtxth + h
	end

	if game.SinglePlayer() then
		addrndtxt("You can't play in \"Single Player\" mode!")
		addrndtxt("Start a new game and select at least \"2 Players\"")
	elseif GAMEMODE.Vars.Tutorial then
		addrndtxt("Welcome to the tutorial")
	elseif PreStart then
		addrndtxt("Waiting for players")
	elseif Pre2Start then
		if plyTeam == TEAM_HIDING then
			addrndtxt("You don't got much time to hide")
		elseif plyTeam == TEAM_SEEKER then
			addrndtxt("You have been selected to be a seeker")
			addrndtxt("Spawning soon")
		else
			addrndtxt("The game will start soon")
		end
	elseif Start and GAMEMODE.Vars.Bears and #GAMEMODE.Vars.Bears > 0 then

		addrndtxt((GAMEMODE.Vars.victims or 0) .. "|" .. (GAMEMODE.Vars.downvictims or 0))

	elseif !Start and GAMEMODE.Vars.victims < 2 then
		addrndtxt("Waiting for players")
	end
	if End then
		local function winstr(WinTeam)
			if WinTeam == TEAM_HIDING then
				return "The victims wins"
			elseif WinTeam == TEAM_SEEKER then
				return "The bears captured everyone"
			end
			return "Draw game"
		end
		addrndtxt(winstr(GAMEMODE.Vars.Round.Win))
	end


	--[[ THE BEAR SHOWCASE ]]--

	if Start and !PreStart then

		local txt = ""
		local w, h = 0, 0

		if GAMEMODE.Vars.Bears and #GAMEMODE.Vars.Bears > 0 then
			for k, v in pairs(GAMEMODE.Vars.Bears) do
				if IsValid(v) and v:Alive() and txt == "" then
					txt = Format(Either(#GAMEMODE.Vars.Bears > 1, "%s is a seeker", "%s is the seeker"), v:Nick())
				elseif IsValid(v) and v:Alive() and txt != "" then
					txt = txt .. Format("\n%s is a seeker", v:Nick())
				end
			end
		end

		if txt != "" then
			surface.SetFont("spb_HT")
			w, h = surface.GetTextSize(txt)
			draw.RoundedBox(0, hudoffset_w, hudoffset_h, w + 16, h + 16, Color(0, 0, 0, 200))
			draw.DrawText(txt, "spb_HT", hudoffset_w + 8 + w / 2, hudoffset_h + 8, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)
			surface.SetDrawColor(Color(0, 0, 0, 255))
			surface.DrawOutlinedRect(hudoffset_w, hudoffset_h, w + 16, h + 16)
		end

	end


	--[[ THE AFK MESSAGE ]]--

	if GAMEMODE.Vars.AfkTime and GAMEMODE.Vars.AfkTime - CurTime() >= 0 then
		local txt = "Hey you're kind of afk!\nIf you're still afk in " .. GAMEMODE:FormatTime(GAMEMODE.Vars.AfkTime - CurTime()) .. "\nYou will be kicked out\n of the seeker"
		surface.SetFont("spb_RND")
		local w, h = surface.GetTextSize(txt)
		surface.SetDrawColor(Color(0, 0, 0, 200))
		surface.DrawRect(ScrW() / 2 - w / 2 - 4, ScrH() / 2 - h / 2, w + 8, h)
		draw.DrawText(txt, "spb_RND", ScrW() / 2, ScrH() / 2 - h / 2, Color(255, yay(255), yay(255), 255), TEXT_ALIGN_CENTER)
		surface.SetDrawColor(Color(255, 0, 0, 255))
		surface.DrawOutlinedRect(ScrW() / 2 - w / 2 - 4, ScrH() / 2 - h / 2, w + 8, h)
	end

	if !hide_tips then --[[ ALL GENERIC TIPS ]]--

		--[[ THE TIPS MESSAGES ]]--

		local w, h = 0, 0
		local tips = ""

		if (plyTeam == TEAM_HIDING and Start and !plyAlive) or plyTeam == TEAM_SPECTATOR then
			tips = GAMEMODE:CheckBind("+attack") .. " next player\n" .. GAMEMODE:CheckBind("+attack2") .. " previous player\n" .. GAMEMODE:CheckBind("+jump") .. " spectate mode (1st person/Chase/Free)"
		elseif plyAlive and plyTeam == TEAM_HIDING and wep == "spb_hiding" then
			tips = GAMEMODE:CheckBind("+attack") .. " to weld a prop to another\n" .. GAMEMODE:CheckBind("+attack2") .. " to unweld a prop"
		elseif plyAlive and plyTeam == TEAM_SEEKER and wep == "spb_seeker" then
			tips = GAMEMODE:CheckBind("+attack") .. " to break props"
		end

		if tips != "" then
			surface.SetFont("spb_HT")
			w, h = surface.GetTextSize(tips)
			surface.SetDrawColor(Color(0, 0, 0, 200))
			surface.DrawRect(ScrW() / 2 - w / 2 - 4, ScrH() - h - hudoffset_h, w + 8, h)
			draw.DrawText(tips, "spb_HT", ScrW() / 2, ScrH() - h - hudoffset_h, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)
			surface.SetDrawColor(Color(0, 0, 0, 255))
			surface.DrawOutlinedRect(ScrW() / 2 - w / 2 - 4, ScrH() - h - hudoffset_h, w + 8, h)
		end


		--[[ THE QUICK TIPS ]]--

		local qtips
		local w, h = 0, 0

		if plyTeam == TEAM_UNASSIGNED then
			qtips = "Press any key to join!"
		elseif plyTeam == TEAM_HIDING and !Start and !plyAlive then
			qtips = "Press any key to respawn!"
		end
		if qtips then
			surface.SetFont("spb_TXT")
			w, h = surface.GetTextSize(qtips)
			surface.SetDrawColor(Color(0, 0, 0, yay(200)))
			surface.DrawRect(ScrW() / 2 - w / 2 - 4, ScrH() / 2 - h, w + 8, h)
			draw.DrawText(qtips, "spb_TXT", ScrW() / 2, ScrH() / 2 - h, Color(255, 255, 255, yay(255)), TEXT_ALIGN_CENTER)
			surface.SetDrawColor(Color(0, 0, 0, yay(255)))
			surface.DrawOutlinedRect(ScrW() / 2 - w / 2 - 4, ScrH() / 2 - h, w + 8, h)
		end


		--[[ THE PERFORMING WELD MESSAGE ]]--

		if splyAlive and splyTeam == TEAM_HIDING then

			local function WeldInfo(str, warn)
				surface.SetFont("spb_HT")
				local w, h = surface.GetTextSize(str)
				surface.SetDrawColor(Either(warn, Color(0, 0, 0, 225), Color(0, 0, 0, yay(225))))
				surface.DrawRect(ScrW() / 2 - w / 2 - 4, ScrH() / 2 + 100 - h, w + 8, h)
				draw.DrawText(str, "spb_HT", ScrW() / 2, ScrH() / 2 + 100 - h, Either(warn, Color(255, 0, 0, 255), Color(255, 255, 255, yay(255))), TEXT_ALIGN_CENTER)
				surface.SetDrawColor(Either(warn, Color(255, 0, 0, yay(255)), Color(0, 0, 0, yay(255))))
				surface.DrawOutlinedRect(ScrW() / 2 - w / 2 - 4, ScrH() / 2 + 100 - h, w + 8, h)
			end

			if weldingstate == 2 then
				WeldInfo("This prop is too far!", true)
			elseif weldingstate == 3 then
				WeldInfo("The props are too far each other!", true)
			elseif IsValid(welding) then
				WeldInfo("Click another prop")
			end

		end

	end


	--[[ THE PLAYER STATUS AND FACE ]]--

	if splyTeam == TEAM_SEEKER or splyTeam == TEAM_HIDING then

		local col = sply:GetPlayerColor():ToColor()
		if !splyAlive then col = team.GetColor(splyTeam) end
		local life = Either(splyAlive, 1, 0)
		local stamina = 200
		local taunt = 200
		local radar = 200
		local cloak = 200
		local sprintlock = false
		local fcolor = Color(col.r, col.g, col.b, 150 * life)
		local ib = 0

		if splyAlive and splyTeam == TEAM_HIDING then
			stamina = math.Remap(sply:GetNWInt("spb_SprintV", 100), 0, 100, 0, 200)
			sprintlock = sply:GetNWInt("spb_SprintLock", false)
		end

		if ply != sply and splyAlive then

			local LastTaunt = sply:GetNWInt("spb_LastTaunt", 0)
			local TauntCooldown = sply:GetNWInt("spb_TauntCooldown", 0) - CurTime()
			local TauntCooldownF = sply:GetNWInt("spb_TauntCooldownF", 5)

			if LastTaunt > 0 and TauntCooldown > 0 then
				taunt = math.Remap(TauntCooldown, 0, TauntCooldownF, 200, 0)
			end

		elseif plyAlive and ply.LastTaunt and ply.TauntCooldown-CurTime() > 0 then
			taunt = math.Remap(ply.TauntCooldown - CurTime(), 0, ply.TauntCooldownF, 200, 0)
		end


		local cloaktime = sply:GetNWFloat("spb_CloakTime", 0)
		if cloaktime != 0 and cloaktime > CurTime() then
			cloak = math.Remap(cloaktime - CurTime(), 0, spb_powerup_cloak_time:GetFloat(), 0, 200)
		end
		local radartime = sply:GetNWFloat("spb_RadarTime", 0)
		if radartime != 0 and radartime > CurTime() then
			radar = math.Remap(radartime - CurTime(), 0, spb_powerup_radar_time:GetFloat(), 0, 200)
		end

		draw.RoundedBox(0, hudoffset_w, ScrH() - 200 - hudoffset_h, 200, 200, Color(0, 0, 0, 200))

		draw.RoundedBox(0, hudoffset_w, ScrH() - 200 - hudoffset_h, 200, 200, fcolor)

		local function MakeBar(name, value, nope)
			surface.SetDrawColor(Color(0, 0, 0, 200))
			surface.DrawRect(200 + hudoffset_w, ScrH() - 200 + 50 * ib - hudoffset_h, 200, 50)
			surface.SetDrawColor(fcolor)
			surface.DrawRect(200 + hudoffset_w, ScrH() - 200 + 50 * ib - hudoffset_h, value, 50)
			draw.DrawText(name, "spb_TXT", 300 + hudoffset_w, ScrH() - 195 + 50 * ib - hudoffset_h, Either(nope, Color(255, 0, 0, 255), Color(255, 255, 255, 255)), TEXT_ALIGN_CENTER)
			surface.SetDrawColor(Color(0, 0, 0, 255))
			surface.DrawOutlinedRect(200 + hudoffset_w, ScrH() - 200 + 50 * ib - hudoffset_h, 200, 50)
			ib = ib + 1
		end

		if splyAlive then
			if (Start or stamina != 200) and splyTeam == TEAM_HIDING then
				MakeBar("STAMINA", stamina, sprintlock)
			end
			if taunt != 200 then
				MakeBar("TAUNT", taunt)
			end
			if radar != 200 then
				MakeBar("RADAR", radar)
			end
			if cloak != 200 then
				MakeBar("CLOAK", cloak)
			end
		end

	end

	if (sply:GetModel() == "models/player/pbear/pbear.mdl" or sply:GetModel() == "models/player/kuristaja/pbear/pbear.mdl") then
		surface.SetDrawColor(255, 255, 255, 255)
		surface.SetMaterial(GAMEMODE.Materials.Bear)
		surface.DrawTexturedRect(hudoffset_w, ScrH() - 200 - hudoffset_h, 200, 200)
		surface.SetDrawColor(Color(0, 0, 0, 255))
		surface.DrawOutlinedRect(hudoffset_w, ScrH() - 200 - hudoffset_h, 200, 200)
	elseif plyTeam != TEAM_UNASSIGNED and splyTeam != TEAM_SPECTATOR then
		self:DrawHealthFace(sply, hudoffset_w, ScrH() - 200 - hudoffset_h)
		surface.SetDrawColor(Color(0, 0, 0, 255))
		surface.DrawOutlinedRect(hudoffset_w, ScrH() - 200 - hudoffset_h, 200, 200)
	end

	if plyTeam != TEAM_UNASSIGNED and splyTeam != TEAM_SPECTATOR then
		local splynick = GAMEMODE:LimitString(sply:Nick(), 200, "spb_HUDname")
		local rankname = GAMEMODE:LimitString(sply:GetNWString("XperidiaRankName", nil) or "", 200, "spb_HUDname")
		local rankcolor = string.ToColor(sply:GetNWString("XperidiaRankColor", "255 255 255 255"))
		draw.DrawText(splynick, "spb_HUDname", 100 + 1 + hudoffset_w, ScrH() - 200 + 1 - hudoffset_h, Color(0, 0, 0, 255), TEXT_ALIGN_CENTER)
		draw.DrawText(splynick, "spb_HUDname", 100 + hudoffset_w, ScrH() - 200 - hudoffset_h, col, TEXT_ALIGN_CENTER)
		draw.DrawText(rankname, "spb_HUDname", 100 + 1 + hudoffset_w, ScrH() - 20 + 1 - hudoffset_h, Color(0, 0, 0, 255), TEXT_ALIGN_CENTER)
		draw.DrawText(rankname, "spb_HUDname", 100 + hudoffset_w, ScrH() - 20 - hudoffset_h, rankcolor, TEXT_ALIGN_CENTER)
	end


	--[[ THE POWER-UP ]]--

	if sply:HasPowerUP() then

		local powerup = GAMEMODE.PowerUps[sply:GetPowerUP()]
		local anim_time = sply:GetNWFloat("spb_PowerUPDelay", nil)
		local anim_progress = anim_time and anim_time > CurTime()
		local ox, oy = 25 + hudoffset_w, ScrH() - 400 - hudoffset_h
		local ow, oh = 150, 150
		surface.SetFont("spb_HUDname")

		surface.SetDrawColor(Color(0, 0, 0, 200))
		surface.DrawRect(ox, oy, ow, oh)

		if sply:HasPowerUP() and anim_progress and sply.AnimSetup and table.Count(sply.AnimSetup) > 0 then
			for k, v in pairs(sply.AnimSetup) do
				if v.Color and IsColor(v.Color) then
					surface.SetDrawColor(v.Color)
				else
					surface.SetDrawColor(Color(52, 190, 236, 255))
				end
				surface.SetMaterial(v.Mat)
				if v.Offset < 0 then
					local tstart = math.Remap(math.Clamp(v.Offset, -oh, 0), -oh, 0, 1, 0)
					local toff = math.Remap(math.Clamp(v.Offset, -oh, 0), -oh, 0, 0, 1)
					surface.DrawTexturedRectUV(ox, oy, ow, oh * toff, 0, tstart, 1, 1)
				elseif v.Offset >= 0 then
					local tend = math.Remap(math.Clamp(v.Offset, 0, oh), 0, oh, 1, 0)
					surface.DrawTexturedRectUV(ox, oy + v.Offset, ow, oh * tend, 0, 0, 1, tend)
				end
				if anim_time - 1 > CurTime() or (anim_time - 1 <= CurTime() and sply.AnimSetup[sply:GetPowerUP()].Offset != 0) then
					if sply.AnimSetup[k].Offset > oh * (table.Count(sply.AnimSetup) - 1) then
						sply.AnimSetup[k].Offset = -oh
					else
						sply.AnimSetup[k].Offset = sply.AnimSetup[k].Offset + 10
					end
				end
			end
		elseif sply:HasPowerUP() and anim_progress then
			local offset = 0
			if !sply.AnimSetup then sply.AnimSetup = {} else table.Empty(sply.AnimSetup) end
			--sply.AnimStart = CurTime()
			for k, v in RandomPairs(GAMEMODE.PowerUps) do
				sply.AnimSetup[k] = {}
				sply.AnimSetup[k].Mat = v[3]
				sply.AnimSetup[k].Color = v[4]
				sply.AnimSetup[k].Offset = offset
				offset = offset + oh
			end
		elseif sply:HasPowerUP() then
			if powerup[4] and IsColor(powerup[4]) then
				surface.SetDrawColor(powerup[4])
			else
				surface.SetDrawColor(Color(52, 190, 236, 255))
			end
			surface.SetMaterial(powerup[3])
			if (swep == "spb_hiding" or swep == "spb_seeker") and !End then
				surface.DrawTexturedRect(ox + yay(25) / 2, oy + yay(25) / 2, ow - yay(25), oh - yay(25))
			else
				surface.DrawTexturedRect(ox, oy, ow, oh)
			end
			if sply.AnimSetup and table.Count(sply.AnimSetup) > 0 then table.Empty(sply.AnimSetup) end
		elseif sply.AnimSetup and table.Count(sply.AnimSetup) > 0 then
			table.Empty(sply.AnimSetup)
		end

		surface.SetDrawColor(Color(0, 0, 0, 255))
		surface.DrawOutlinedRect(ox, oy, ow, oh)

		if !hide_tips then
			local usetip
			if ply:HasPowerUP() and !anim_progress and (wep == "spb_hiding" or wep == "spb_seeker") then
				usetip = "Press " .. GAMEMODE:CheckBind("+reload") .. " to use"
			end
			if usetip then
				local tw, th = surface.GetTextSize(usetip)
				surface.SetDrawColor(Color(0, 0, 0, 200))
				surface.DrawRect(ox + ow / 2 - tw / 2 - 4, oy + oh, tw + 8, th)
				draw.DrawText(usetip, "spb_HUDname", ox + ow / 2, oy + oh, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)
				surface.SetDrawColor(Color(0, 0, 0, 255))
				surface.DrawOutlinedRect(ox + ow / 2 - tw / 2 - 4, oy + oh, tw + 8, th)
			end
		end

	end


	--[[ THE MUSICS STUFF ]]--

	if IsValid(GAMEMODE.Vars.Music) then

		local time = GAMEMODE.Vars.Music:GetTime()
		local totaltime = GAMEMODE.Vars.Music:GetLength()
		local left, right = GAMEMODE.Vars.Music:GetLevel()
		local function meh(mu) return math.Remap(mu, 0, 1, 0, 255) end
		local function volcolor(mu) return Color( meh(mu), 255-meh(mu), 0, 200 ) end
		local visuok = GetConVar("spb_cl_music_visualizer"):GetBool() and GAMEMODE.Vars.Music:GetState() == GMOD_CHANNEL_PLAYING
		local visspace = 48
		if visuok then
			visspace = 0
		end

		draw.RoundedBox(0, ScrW() - 256 - hudoffset_w, ScrH() - 100 + visspace - hudoffset_h, 256, 100 - visspace, Color(0, 0, 0, 200))

		local ctitle = GAMEMODE.Vars.CurrentMusicName
		local rtitle
		if ctitle and ctitle != "" then
			rtitle = ctitle
		else
			rtitle = GAMEMODE:PrettyMusicName(string.GetFileFromFilename(GAMEMODE.Vars.Music:GetFileName()))
		end

		local title = "♪ " .. GAMEMODE:LimitString(rtitle, 216, "spb_HUDname") .. " ♪"
		draw.DrawText(title, "spb_HUDname", ScrW() - 127 - hudoffset_w, ScrH() - 99 + visspace - hudoffset_h, Color(0, 0, 0, 255), TEXT_ALIGN_CENTER)
		draw.DrawText(title, "spb_HUDname", ScrW() - 128 - hudoffset_w, ScrH() - 100 + visspace - hudoffset_h, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)

		draw.RoundedBox(0, ScrW() - 256 - hudoffset_w, ScrH() - 80 + visspace - hudoffset_h, 256, 16, Color(0, 0, 0, 200)) --Timetrack
		draw.RoundedBox(0, ScrW() - 256 - hudoffset_w, ScrH() - 77 + visspace - hudoffset_h, math.Remap(time, 0, totaltime, 0, 256), 10, Color(255, 255, 255, 200))

		draw.RoundedBox(0, ScrW() - 256 - hudoffset_w, ScrH() - 64 + visspace - hudoffset_h, 256, 16, Color( 0, 0, 0, 200)) --Wub
		draw.RoundedBox(0, ScrW() - 256 - hudoffset_w, ScrH() - 56 + visspace - hudoffset_h, math.Remap(left, 0, 1, 0, 256), 8, volcolor(left))
		draw.RoundedBox(0, ScrW() - 256 - hudoffset_w, ScrH() - 64 + visspace - hudoffset_h, math.Remap(right, 0, 1, 0, 256), 8, volcolor(right))

		surface.SetDrawColor(0, 0, 0, 255)
		surface.DrawLine(ScrW() - 256 - hudoffset_w, ScrH() - 64 + visspace - hudoffset_h, ScrW() - hudoffset_w, ScrH() - 64 + visspace - hudoffset_h)
		surface.DrawLine(ScrW() - 256 - hudoffset_w, ScrH() - 48 + visspace - hudoffset_h, ScrW() - hudoffset_w, ScrH() - 48 + visspace - hudoffset_h)

		local timetxt = GAMEMODE:FormatTimeTri(time) .. "/" .. GAMEMODE:FormatTimeTri(totaltime) --Time
		surface.SetFont("spb_HUDname")
		local tw, _ = surface.GetTextSize(timetxt)
		draw.RoundedBox(0, ScrW() - 128 - tw / 2 - 4 - hudoffset_w, ScrH() - 80 + visspace - hudoffset_h, tw + 8, 16, Color(0, 0, 0, 220))
		draw.DrawText(timetxt, "spb_HUDname", ScrW() - 127 - hudoffset_w, ScrH() - 81 + visspace - hudoffset_h, Color(0, 0, 0, 255), TEXT_ALIGN_CENTER)
		draw.DrawText(timetxt, "spb_HUDname", ScrW() - 128 - hudoffset_w, ScrH() - 82 + visspace - hudoffset_h, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)

		surface.SetDrawColor(Color(0, 0, 0, 255))
		surface.DrawOutlinedRect(ScrW() - 256 - hudoffset_w, ScrH() - 100 + visspace - hudoffset_h, 256, 100 - visspace)

		if visuok then

			local eqd = {}

			GAMEMODE.Vars.Music:FFT(eqd, 0)

			surface.SetDrawColor(Color(0, 0, 0, 200))
			surface.DrawRect(ScrW() - 256 - hudoffset_w, ScrH() - 48 - hudoffset_h, 256, 48)

			for k, v in pairs(eqd) do
				local on = math.Clamp(math.Remap(v, 0, 1 / k, 0, 48), 0, 48)
				local b = math.Clamp(math.Remap(v, 0, 1 / k, 0, 1), 0, 1)
				surface.SetDrawColor(volcolor(b))
				surface.DrawRect(ScrW() - 256 + (k - 1) * 2 - hudoffset_w, ScrH() - on - hudoffset_h, 2, on)
			end

			surface.SetDrawColor(Color(0, 0, 0, 255))
			surface.DrawOutlinedRect(ScrW() - 256 - hudoffset_w, ScrH() - 48 - hudoffset_h, 256, 48)

		end

		if !hide_tips then
			local usetip = "Press " .. GAMEMODE:CheckBind("gm_showspare2") .. " for options"
			if usetip then
				local tw, th = surface.GetTextSize(usetip)
				surface.SetDrawColor(Color(0, 0, 0, 200))
				surface.DrawRect(ScrW() - 128 - hudoffset_w - tw / 2 - 4, ScrH() - 100 + visspace - hudoffset_h - 20, tw + 8, th)
				draw.DrawText(usetip, "spb_HUDname", ScrW() - 128 - hudoffset_w, ScrH() - 100 + visspace - hudoffset_h - 20, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)
				surface.SetDrawColor(Color(0, 0, 0, 255))
				surface.DrawOutlinedRect(ScrW() - 128 - hudoffset_w - tw / 2 - 4, ScrH() - 100 + visspace - hudoffset_h - 20, tw + 8, th)
			end
		end

	end

end

function GM:CreateHealthFace(ply)
	self.HealthFace = ClientsideModel(ply:GetModel(), RENDER_GROUP_OPAQUE_ENTITY)
	self.HealthFace:SetNoDraw(true)
	local iSeq = self.HealthFace:LookupSequence("idle_passive")
	if (iSeq <= 0) then iSeq = self.HealthFace:LookupSequence("walk_all") end
	if (iSeq <= 0) then iSeq = self.HealthFace:LookupSequence("WalkUnarmed_all") end
	if (iSeq <= 0) then iSeq = self.HealthFace:LookupSequence("walk_all_moderate") end
	if (iSeq > 0) then
		self.HealthFace:SetSequence(iSeq)
		self.HealthFace:ResetSequenceInfo()
		self.HealthFace:SetCycle(0)
		self.HealthFace:SetPlaybackRate(1)
		self.LastSeq = iSeq
	end
	self.HealthFace.GetPlayerColor = function() return ply:GetPlayerColor() end

	local f = function (self) return self.PlayerColor or Vector(1, 0, 0) end
	self.HealthFace.GetPlayerColorOverride = f

	self.HealthFace:SetSkin(ply:GetSkin())

	for k,v in pairs(ply:GetBodyGroups()) do
		self.HealthFace:SetBodygroup(v["id"], ply:GetBodygroup(v["id"]))
	end

end

local function SameBodyGroups(self, ply)
	for k, v in pairs(self:GetBodyGroups()) do
		if self:GetBodygroup(v.id) != ply:GetBodygroup(v.id) then return false end
	end
	return true
end

function GM:DrawHealthFace(ply, x, y)

	local w, h = 200, 200

	if !IsValid(self.HealthFace) then
		self:CreateHealthFace(ply)
	end

	if IsValid(self.HealthFace) then

		if self.HealthFace:GetModel() != ply:GetModel() or self.HealthFace:GetSkin() != ply:GetSkin() or !SameBodyGroups(self.HealthFace, ply) then
			self:CreateHealthFace(ply)
		end

		local seq = ply:GetSequence()
		--[[local seqname = ply:GetSequenceName(seq)
		if seqname == "walk_all" or seqname == "run_all_01" or seqname == "swimming_all" then
			seq = ply:LookupSequence("menu_walk")
			seqname = ply:GetSequenceName(seq)
		end]]

		if !ply:Alive() and self.LastSeq != 0 then
			local iSeq = 0
			self.HealthFace:SetSequence(iSeq)
			self.HealthFace:ResetSequenceInfo()
			self.HealthFace:SetCycle(0)
			self.HealthFace:SetPlaybackRate(1)
			self.LastSeq = iSeq
		elseif ply:Alive() and self.LastSeq != seq then
			local iSeq = seq or 0
			self.HealthFace:SetSequence(iSeq)
			self.HealthFace:ResetSequenceInfo()
			self.HealthFace:SetCycle(0)
			self.HealthFace:SetPlaybackRate(1)
			self.LastSeq = iSeq
		end
		--print(ply:GetSequenceList()[ply:GetSequence()])
		--PrintTable(ply:GetSequenceList())

		if self.HealthFace.PlayerColor != ply:GetPlayerColor() then
			self.HealthFace.PlayerColor = ply:GetPlayerColor()
		end

		local bone = self.HealthFace:LookupBone("ValveBiped.Bip01_Head1")
		local pos = Vector(0, 0, 70)
		local bang = Angle()
		if bone then
			pos, bang = self.HealthFace:GetBonePosition(bone)
		end

		cam.Start3D(pos + Vector(19, 0, 2), Vector(-1, 0, 0):Angle(), 70, x, y, w, h, 5, 4096)
		cam.IgnoreZ(true)

		render.OverrideDepthEnable(false)
		render.SuppressEngineLighting(true)
		render.SetLightingOrigin(pos)
		local life = math.Clamp(math.Remap(ply:Health(), 0, ply:GetMaxHealth(), 0, 1), 0, 1) or 0
		render.ResetModelLighting(life, life, life)
		render.SetColorModulation(1, 1, 1)
		render.SetBlend(1)

		self.HealthFace:DrawModel()

		render.SuppressEngineLighting(false)
		cam.IgnoreZ(false)
		cam.End3D()

	end

	render.SetStencilEnable(false)

	render.SetStencilWriteMask(0)
	render.SetStencilReferenceValue(0)
	render.SetStencilTestMask(0)
	render.SetStencilEnable(false)
	render.OverrideDepthEnable(false)
	render.SetBlend(1)

	cam.IgnoreZ(false)
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

function GM:HUDDrawTargetID()

	local tr = util.GetPlayerTrace(LocalPlayer())
	local trace = util.TraceLine(tr)
	if !trace.Hit then return end
	if !trace.HitNonWorld then return end
	local ply = LocalPlayer()
	if ply:GetObserverMode() == OBS_MODE_CHASE then return end

	local text = ""
	local font = "DermaLarge"


	if (trace.Entity:IsPlayer() and !trace.Entity:IsCloaked()) or trace.Entity:GetClass() == "spb_dummy" then
		text = trace.Entity:Nick()
	end

	surface.SetFont(font)
	local w, h = surface.GetTextSize(text)

	local MouseX, MouseY = ScrW() / 2, ScrH() * 0.5

	local x = MouseX
	local y = MouseY

	x = x - w / 2
	y = y + 30

	draw.SimpleText(text, font, x + 1, y + 1, Color(0, 0, 0, 255))
	draw.SimpleText(text, font, x + 2, y + 2, Color(0, 0, 0, 126))
	if trace.Entity:IsPlayer() or trace.Entity:GetClass() == "spb_dummy" then
		local col = trace.Entity:GetPlayerColor():ToColor()
		draw.SimpleText(text, font, x, y, col)
	elseif trace.Entity:IsPlayer() then
		draw.SimpleText(text, font, x, y, self:GetTeamColor(trace.Entity))
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
	GAMEMODE:Stats()
end

function GM:Stats()

	local function welcomehandle()
		GAMEMODE:SplashScreen()
	end

	local info = file.Read("superpedobear/info.txt")

	if info then
		local tab = util.JSONToTable(info)
		if !tab or (tab.LastVersion and tab.LastVersion < GAMEMODE.Version) then
			GAMEMODE:SplashScreen()
		end
	else
		GAMEMODE:SplashScreen()
	end

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
		if rankid > 0 then
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
