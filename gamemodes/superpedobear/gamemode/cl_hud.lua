--[[---------------------------------------------------------
		Super Pedobear Gamemode for Garry's Mod
				by VictorienXP (2016-2020)
-----------------------------------------------------------]]

function GM:HUDPaint()

	if !GetConVar("cl_drawhud"):GetBool() then return end

	if GetConVar("spb_cl_hud_html_enable"):GetBool() then
		if !GAMEMODE.HTML_HUD_LOADED then
			GAMEMODE:DrawLegacyHUD()
		end
		GAMEMODE:HTML_HUD()
	else
		GAMEMODE:DrawLegacyHUD()
		if IsValid(GAMEMODE.HUD) then
			GAMEMODE.HUD:Close()
			GAMEMODE.HTML_HUD_LOADED = nil
		end
	end
	hook.Run("HUDDrawTargetID")
	hook.Run("DrawDeathNotice", 0.85, 0.04)

end

concommand.Add("spb_cl_hud_html_reload", function()
	if IsValid(GAMEMODE.HUD) then
		GAMEMODE.HUD:Close()
	end
	GAMEMODE.HTML_HUD_LOADED = nil
end)

function GM:HTML_HUD_UPDATE()

	local vars = {}

	vars.rounds = GAMEMODE.Vars.Rounds
	vars.round = GAMEMODE.Vars.Round

	vars.sply = {}
	vars.ply = {}
	local ply = LocalPlayer()
	local sply = ply:GetObserverTarget() or ply
	if !sply:IsPlayer() then
		sply = ply
	end
	vars.ply.Alive = ply:Alive()
	vars.ply.Team = ply:Team()
	vars.sply.Alive = sply:Alive()
	vars.sply.Team = sply:Team()
	vars.sply.col = sply:GetPlayerColor():ToColor()
	if !vars.sply.Alive then
		vars.sply.col = team.GetColor(vars.sply.Team)
	end
	vars.welding = IsValid(sply:GetNWEntity("spb_Welding"))
	if vars.welding == sply then
		vars.welding = nil
	end
	vars.weldingstate = sply:GetNWInt("spb_WeldingState")
	vars.hide_tips = GetConVar("spb_cl_hide_tips"):GetBool() or End
	vars.hudoffset_w = GetConVar("spb_cl_hud_offset_w") and GetConVar("spb_cl_hud_offset_w"):GetInt() or 0
	vars.hudoffset_h = GetConVar("spb_cl_hud_offset_h") and GetConVar("spb_cl_hud_offset_h"):GetInt() or 0
	vars.hudoffset_w = ScrW() * (vars.hudoffset_w * 0.001)
	vars.hudoffset_h = ScrH() * (vars.hudoffset_h * 0.001)
	vars.ply.wep = ""
	if vars.ply.Alive and IsValid(ply:GetActiveWeapon()) then
		vars.ply.wep = ply:GetActiveWeapon():GetClass()
	end
	vars.sply.swep = ""
	if vars.sply.Alive and IsValid(sply:GetActiveWeapon()) then
		vars.sply.swep = sply:GetActiveWeapon():GetClass()
	end

	GAMEMODE.HUD.HTML:Call("update('" .. util.TableToJSON(vars) .. "')")

end

function GM:HTML_HUD()

	if IsValid(GAMEMODE.HUD) then

		GAMEMODE:HTML_HUD_UPDATE()

	else

		GAMEMODE.HUD = vgui.Create("DFrame")
		GAMEMODE.HUD:ParentToHUD()
		GAMEMODE.HUD:SetPos(0, 0)
		GAMEMODE.HUD:SetSize(ScrW(), ScrH())
		GAMEMODE.HUD:SetTitle("")
		GAMEMODE.HUD:SetVisible(false)
		GAMEMODE.HUD:SetDraggable(false)
		GAMEMODE.HUD:ShowCloseButton(false)
		GAMEMODE.HUD:SetScreenLock(true)
		GAMEMODE.HUD:SetZPos(-32768)
		GAMEMODE.HUD.Paint = function(self, w, h) end
		GAMEMODE.HUD:MakePopup()
		GAMEMODE.HUD:SetKeyboardInputEnabled(false)
		GAMEMODE.HUD:SetMouseInputEnabled(false)

		GAMEMODE.HUD.HTML = vgui.Create("DHTML")
		GAMEMODE.HUD.HTML:SetParent(GAMEMODE.HUD)
		GAMEMODE.HUD.HTML:SetPos(0, 0)
		GAMEMODE.HUD.HTML:SetSize(ScrW(), ScrH())

		GAMEMODE.HUD.HTML:AddFunction("spb", "validate", function(str)

			if str == "HUD" then

				GAMEMODE.HTML_HUD_LOADED = true

				GAMEMODE.HUD:SetVisible(true)

				GAMEMODE:HTML_HUD_UPDATE()

				GAMEMODE:Log("The HTML HUD has loaded properly!")

			end

		end)

		GAMEMODE.HUD.HTML:OpenURL("https://assets.xperidia.com/superpedobear/hud.html")

		GAMEMODE:Log("The HTML HUD is loading!")

	end

end

local function BreathEffect(number)
	return (math.sin(CurTime() * 6) + 1) / 2 * number
end

local function winstr(WinTeam)
	if WinTeam == TEAM_HIDING then
		return "The victims wins"
	elseif WinTeam == TEAM_SEEKER then
		return "The bears captured everyone"
	end
	return "Draw game"
end

local function WeldInfo(str, warn)
	surface.SetFont("spb_HT")
	local w, h = surface.GetTextSize(str)
	surface.SetDrawColor(Either(warn, Color(0, 0, 0, 225), Color(0, 0, 0, BreathEffect(225))))
	surface.DrawRect(ScrW() / 2 - w / 2 - 4, ScrH() / 2 + 100 - h, w + 8, h)
	draw.DrawText(str, "spb_HT", ScrW() / 2, ScrH() / 2 + 100 - h, Either(warn, Color(255, 0, 0, 255), Color(255, 255, 255, BreathEffect(255))), TEXT_ALIGN_CENTER)
	surface.SetDrawColor(Either(warn, Color(255, 0, 0, BreathEffect(255)), Color(0, 0, 0, BreathEffect(255))))
	surface.DrawOutlinedRect(ScrW() / 2 - w / 2 - 4, ScrH() / 2 + 100 - h, w + 8, h)
end

local function remap_volume(mu) return
	math.Remap(mu, 0, 1, 0, 255)
end

local function volume_to_color(mu) return
	Color(remap_volume(mu), 255 - remap_volume(mu), 0, 200)
end

function GM:DrawLegacyHUD()

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

	draw.DrawText("Super Pedobear v" .. (GAMEMODE.Version and tostring(GAMEMODE.Version) or "?") .. " (" .. (GAMEMODE.VersionDate or "?") .. ")", "DermaDefault", ScrW() / 2, hudoffset_h, Color(255, 255, 255, 32), TEXT_ALIGN_CENTER)


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
		draw.DrawText(txt, "spb_RND", ScrW() / 2, ScrH() / 2 - h / 2, Color(255, BreathEffect(255), BreathEffect(255), 255), TEXT_ALIGN_CENTER)
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
			surface.SetDrawColor(Color(0, 0, 0, BreathEffect(200)))
			surface.DrawRect(ScrW() / 2 - w / 2 - 4, ScrH() / 2 - h, w + 8, h)
			draw.DrawText(qtips, "spb_TXT", ScrW() / 2, ScrH() / 2 - h, Color(255, 255, 255, BreathEffect(255)), TEXT_ALIGN_CENTER)
			surface.SetDrawColor(Color(0, 0, 0, BreathEffect(255)))
			surface.DrawOutlinedRect(ScrW() / 2 - w / 2 - 4, ScrH() / 2 - h, w + 8, h)
		end


		--[[ THE PERFORMING WELD MESSAGE ]]--

		if splyAlive and splyTeam == TEAM_HIDING then

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
		if sply:IsGamemodeAuthor() then
			rankname = "Gamemode author"
		end
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
				surface.DrawTexturedRect(ox + BreathEffect(25) / 2, oy + BreathEffect(25) / 2, ow - BreathEffect(25), oh - BreathEffect(25))
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

		local title = GAMEMODE:LimitString(rtitle, 246, "spb_HUDname")
		draw.DrawText(title, "spb_HUDname", ScrW() - 127 - hudoffset_w, ScrH() - 99 + visspace - hudoffset_h, Color(0, 0, 0, 255), TEXT_ALIGN_CENTER)
		draw.DrawText(title, "spb_HUDname", ScrW() - 128 - hudoffset_w, ScrH() - 100 + visspace - hudoffset_h, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)

		draw.RoundedBox(0, ScrW() - 256 - hudoffset_w, ScrH() - 80 + visspace - hudoffset_h, 256, 16, Color(0, 0, 0, 200)) --Timetrack
		draw.RoundedBox(0, ScrW() - 256 - hudoffset_w, ScrH() - 77 + visspace - hudoffset_h, math.Remap(time, 0, totaltime, 0, 256), 10, Color(255, 255, 255, 200))

		draw.RoundedBox(0, ScrW() - 256 - hudoffset_w, ScrH() - 64 + visspace - hudoffset_h, 256, 16, Color( 0, 0, 0, 200)) --Wub
		draw.RoundedBox(0, ScrW() - 256 - hudoffset_w, ScrH() - 56 + visspace - hudoffset_h, math.Remap(left, 0, 1, 0, 256), 8, volume_to_color(left))
		draw.RoundedBox(0, ScrW() - 256 - hudoffset_w, ScrH() - 64 + visspace - hudoffset_h, math.Remap(right, 0, 1, 0, 256), 8, volume_to_color(right))

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
				surface.SetDrawColor(volume_to_color(b))
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
