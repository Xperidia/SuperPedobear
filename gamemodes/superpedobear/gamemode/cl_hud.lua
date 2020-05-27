--[[---------------------------------------------------------
		Super Pedobear Gamemode for Garry's Mod
				by VictorienXP (2016-2020)
-----------------------------------------------------------]]

function GM:HUDPaint()

	if !GetConVar("cl_drawhud"):GetBool() then return end

	if GetConVar("spb_cl_hud_html_enable"):GetBool() then
		if !self.HTML_HUD_LOADED then
			self:DrawLegacyHUD()
		end
		self:HTML_HUD()
	else
		self:DrawLegacyHUD()
		if IsValid(self.HUD) then
			self.HUD:Close()
			self.HTML_HUD_LOADED = nil
		end
	end
	hook.Run("HUDDrawTargetID")
	hook.Run("DrawDeathNotice", 0.85, 0.04)

end

concommand.Add("spb_cl_hud_html_reload", function()
	if IsValid(self.HUD) then
		self.HUD:Close()
	end
	self.HTML_HUD_LOADED = nil
end)

function GM:HTML_HUD_UPDATE()

	self.HUD.HTML:Call("update('" .. util.TableToJSON(self:HUD_Values()) .. "')")

end

function GM:HTML_HUD()

	if IsValid(self.HUD) then

		self:HTML_HUD_UPDATE()

	else

		self.HUD = vgui.Create("DFrame")
		self.HUD:ParentToHUD()
		self.HUD:SetPos(0, 0)
		self.HUD:SetSize(ScrW(), ScrH())
		self.HUD:SetTitle("")
		self.HUD:SetVisible(false)
		self.HUD:SetDraggable(false)
		self.HUD:ShowCloseButton(false)
		self.HUD:SetScreenLock(true)
		self.HUD:SetZPos(-32768)
		self.HUD.Paint = function(self, w, h) end
		self.HUD:MakePopup()
		self.HUD:SetKeyboardInputEnabled(false)
		self.HUD:SetMouseInputEnabled(false)

		self.HUD.HTML = vgui.Create("DHTML", self.HUD)
		self.HUD.HTML:SetPos(0, 0)
		self.HUD.HTML:SetSize(ScrW(), ScrH())

		self.HUD.HTML:AddFunction("spb", "validate", function(str)

			if str == "HUD" then

				self.HTML_HUD_LOADED = true

				self.HUD:SetVisible(true)

				self:HTML_HUD_UPDATE()

				self:Log("The HTML HUD has loaded properly!")

			end

		end)

		self.HUD.HTML:OpenURL("https://assets.xperidia.com/superpedobear/hud.html")

		self:Log("The HTML HUD is loading!")

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

local function remap_volume(mu) return
	math.Remap(mu, 0, 1, 0, 255)
end

local function volume_to_color(mu) return
	Color(remap_volume(mu), 255 - remap_volume(mu), 0, 200)
end

function GM:HUD_Values()

	local v = {}

	--Round table
	v.R					= self.Vars.Round

	--Misc
	v.victims			= self.Vars.victims
	v.seekers			= self.Vars.Bears
	v.downvictims		= self.Vars.downvictims
	v.rounds			= self.Vars.Rounds
	v.spacer			= self:ScreenScaleMin(8)

	--cvars
	v.hide_tips			= GetConVar("spb_cl_hide_tips"):GetBool() or v.R.End
	v.hudoffset_w		= GetConVar("spb_cl_hud_offset_w") and GetConVar("spb_cl_hud_offset_w"):GetInt() or 0
	v.hudoffset_h		= GetConVar("spb_cl_hud_offset_h") and GetConVar("spb_cl_hud_offset_h"):GetInt() or 0
	v.hudoffset_w		= ScrW() * (v.hudoffset_w * 0.001)
	v.hudoffset_h		= ScrH() * (v.hudoffset_h * 0.001)

	--Player values
	v.P = {}
	v.P.ply				= LocalPlayer()
	v.P.sply			= v.P.ply:GetObserverTarget() or v.P.ply
	if !v.P.sply:IsPlayer() then
		v.P.sply		= v.P.ply
	end
	v.P.plyAlive		= v.P.ply:Alive()
	v.P.plyTeam			= v.P.ply:Team()
	v.P.splyAlive		= v.P.sply:Alive()
	v.P.splyTeam		= v.P.sply:Team()
	v.P.color			= v.P.sply:GetPlayerColor():ToColor()
	if !v.P.splyAlive then
		v.P.color		= team.GetColor(v.P.splyTeam)
	end
	v.P.welding			= v.P.sply:GetNWEntity("spb_Welding")
	if v.P.welding == v.P.sply then
		v.P.welding		= nil
	end
	v.P.weldingstate	= v.P.sply:GetNWInt("spb_WeldingState")
	v.P.wep				= ""
	if v.P.plyAlive and IsValid(v.P.ply:GetActiveWeapon()) then
		v.P.wep			= v.P.ply:GetActiveWeapon():GetClass()
	end
	v.P.swep			= ""
	if v.P.splyAlive and IsValid(v.P.sply:GetActiveWeapon()) then
		v.P.swep		= v.P.sply:GetActiveWeapon():GetClass()
	end

	return v

end

function GM:HUD_ClockLogic(v)

	local time_val = 0
	local time_color = Color(255, 255, 255, 255)

	if v.R.Pre2Time and v.R.Pre2Time - CurTime() >= 0 then
		time_val = v.R.Pre2Time - CurTime()
		if v.P.plyTeam == TEAM_HIDING then
			time_color = Color(255, 0, 0, 255)
		elseif v.P.plyTeam == TEAM_SEEKER then
			time_color = Color(0, 255, 0, 255)
		else
			time_color = Color(255, 255, 0, 255)
		end
	elseif v.R.PreStartTime and v.R.PreStartTime - CurTime() >= 0 then
		time_val = v.R.PreStartTime - CurTime()
		if time_val < 10 then
			time_color = Color(255, 255, 0, 255)
		end
	elseif v.R.Time and v.R.Time - CurTime() >= 0 then
		time_val = v.R.Time - CurTime()
		if time_val < 60 and v.P.plyTeam == TEAM_HIDING then
			time_color = Color(0, 255, 0, 255)
		elseif time_val < 60 and v.P.plyTeam == TEAM_SEEKER then
			time_color = Color(255, 0, 0, 255)
		elseif time_val < 60 then
			time_color = Color(255, 255, 0, 255)
		end
	elseif v.R.End or v.R.TempEnd then
		time_val = v.R.LastTime
	elseif !v.R.Start and !v.R.Pre2Time then
		if rounds <= 1 then
			time_val = 40
		else
			time_val = spb_round_pretime:GetFloat()
		end
	end

	return self:FormatTime(time_val), time_color

end

function GM:DrawLegacyClockHUD(v)

	local w, h = self:ScreenScale(200, 72)
	local time_str, time_color = self:HUD_ClockLogic(v)

	surface.SetDrawColor(Color(0, 0, 0, 200))
	surface.DrawRect(ScrW() / 2 - w / 2, v.hudoffset_h, w, h)
	draw.DrawText(time_str, self:GetScaledFont("spb_TIME"), ScrW() / 2, v.hudoffset_h, time_color, TEXT_ALIGN_CENTER)
	surface.SetDrawColor(Color(0, 0, 0, 255))
	surface.DrawOutlinedRect(ScrW() / 2 - w / 2, v.hudoffset_h, w, h)

	return h

end

function GM:DrawLegacyRoundStrHUD(v, str, offset)

	local y = v.hudoffset_h + offset
	surface.SetFont(self:GetScaledFont("spb_RND"))
	local w, h = surface.GetTextSize(str)

	surface.SetDrawColor(Color(0, 0, 0, 200))
	surface.DrawRect(ScrW() / 2 - w / 2 - v.spacer, y, w + v.spacer * 2, h)

	draw.DrawText(str, self:GetScaledFont("spb_RND"), ScrW() / 2, y, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)

	surface.SetDrawColor(Color(0, 0, 0, 255))
	surface.DrawOutlinedRect(ScrW() / 2 - w / 2 - v.spacer, y, w + v.spacer * 2, h)

	return offset + h

end

function GM:DrawLegacyWeldInfo(V, str, warn)
	surface.SetFont(self:GetScaledFont("spb_HT"))
	local w, h = surface.GetTextSize(str)
	surface.SetDrawColor(Either(warn, Color(0, 0, 0, 225), Color(0, 0, 0, BreathEffect(225))))
	surface.DrawRect(ScrW() / 2 - w / 2 - V.spacer / 2, ScrH() / 2 + 100 - h, w + V.spacer, h)
	draw.DrawText(str, self:GetScaledFont("spb_HT"), ScrW() / 2, ScrH() / 2 + 100 - h, Either(warn, Color(255, 0, 0, 255), Color(255, 255, 255, BreathEffect(255))), TEXT_ALIGN_CENTER)
	surface.SetDrawColor(Either(warn, Color(255, 0, 0, BreathEffect(255)), Color(0, 0, 0, BreathEffect(255))))
	surface.DrawOutlinedRect(ScrW() / 2 - w / 2 - V.spacer / 2, ScrH() / 2 + 100 - h, w + V.spacer, h)
end

function GM:DrawLegacyHUD()

	draw.DrawText("SPB\nv" .. (self.Version and tostring(self.Version) or "?") .. "\n" .. (self.VersionDate or ""), self:GetScaledFont("spb_min"), ScrW() - 4, 0, Color(255, 255, 255, 255), TEXT_ALIGN_RIGHT)

	--[[ THE INDEX ZONE ]]--

	local V = self:HUD_Values()


	--[[ THE CLOCK AND ROUND STATUS ]]--

	local rndtxth = self:DrawLegacyClockHUD(V)

	local rounds = "Round " .. (V.rounds or 0)
	local max_rounds = spb_rounds:GetInt()
	if MapVote and max_rounds < 1000 and max_rounds > 0 then
		rounds = rounds .. "/" .. max_rounds
	end
	rndtxth = self:DrawLegacyRoundStrHUD(V, rounds, rndtxth)

	if game.SinglePlayer() then
		rndtxth = self:DrawLegacyRoundStrHUD(V, "You can't play in \"Single Player\" mode!", rndtxth)
		rndtxth = self:DrawLegacyRoundStrHUD(V, "Start a new game and select at least \"2 Players\"", rndtxth)
	elseif V.R.PreStart or (!V.R.Start and V.victims < 2) then
		rndtxth = self:DrawLegacyRoundStrHUD(V, "Waiting for players", rndtxth)
	elseif V.R.Pre2Start then
		if V.P.plyTeam == TEAM_HIDING then
			rndtxth = self:DrawLegacyRoundStrHUD(V, "You don't got much time to hide", rndtxth)
		elseif V.P.plyTeam == TEAM_SEEKER then
			rndtxth = self:DrawLegacyRoundStrHUD(V, "You have been selected to be a seeker", rndtxth)
			rndtxth = self:DrawLegacyRoundStrHUD(V, "Spawning soon", rndtxth)
		else
			rndtxth = self:DrawLegacyRoundStrHUD(V, "The game will start soon", rndtxth)
		end
	elseif V.R.Start and V.seekers and #V.seekers > 0 then
		rndtxth = self:DrawLegacyRoundStrHUD(V, (V.victims or 0) .. "|" .. (V.downvictims or 0), rndtxth)
	end
	if V.R.End then
		rndtxth = self:DrawLegacyRoundStrHUD(V, winstr(V.R.Win), rndtxth)
	end


	--[[ THE BEAR SHOWCASE ]]--

	if V.R.Start and !V.R.PreStart then

		local txt = ""
		local w, h = 0, 0

		if V.seekers and #V.seekers > 0 then
			for k, v in pairs(V.seekers) do
				if IsValid(v) and v:Alive() and txt == "" then
					txt = Format(Either(#V.seekers > 1, "%s is a seeker", "%s is the seeker"), v:Nick())
				elseif IsValid(v) and v:Alive() and txt != "" then
					txt = txt .. Format("\n%s is a seeker", v:Nick())
				end
			end
		end

		if txt != "" then
			surface.SetFont(self:GetScaledFont("spb_HT"))
			w, h = surface.GetTextSize(txt)
			draw.RoundedBox(0, V.hudoffset_w, V.hudoffset_h, w + V.spacer * 2, h + V.spacer * 2, Color(0, 0, 0, 200))
			draw.DrawText(txt, self:GetScaledFont("spb_HT"), V.hudoffset_w + V.spacer + w / 2, V.hudoffset_h + V.spacer, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)
			surface.SetDrawColor(Color(0, 0, 0, 255))
			surface.DrawOutlinedRect(V.hudoffset_w, V.hudoffset_h, w + V.spacer * 2, h + V.spacer * 2)
		end

	end


	--[[ THE AFK MESSAGE ]]--

	if self.Vars.AfkTime and self.Vars.AfkTime - CurTime() >= 0 then
		local txt = "Hey you're kind of afk!\nIf you're still afk in " .. self:FormatTime(self.Vars.AfkTime - CurTime()) .. "\nYou will be kicked out of the seeker role!"
		surface.SetFont(self:GetScaledFont("spb_RND"))
		local w, h = surface.GetTextSize(txt)
		surface.SetDrawColor(Color(0, 0, 0, 200))
		surface.DrawRect(ScrW() / 2 - w / 2 - V.spacer / 2, ScrH() / 2 - h / 2, w + V.spacer, h)
		draw.DrawText(txt, self:GetScaledFont("spb_RND"), ScrW() / 2, ScrH() / 2 - h / 2, Color(255, BreathEffect(255), BreathEffect(255), 255), TEXT_ALIGN_CENTER)
		surface.SetDrawColor(Color(255, 0, 0, 255))
		surface.DrawOutlinedRect(ScrW() / 2 - w / 2 - V.spacer / 2, ScrH() / 2 - h / 2, w + V.spacer, h)
	end

	if !V.hide_tips then --[[ ALL GENERIC TIPS ]]--

		--[[ THE TIPS MESSAGES ]]--

		local w, h = 0, 0
		local tips = ""

		if (V.P.plyTeam == TEAM_HIDING and V.R.Start and !V.P.plyAlive) or V.P.plyTeam == TEAM_SPECTATOR then
			tips = self:CheckBind("+attack") .. " next player\n" .. self:CheckBind("+attack2") .. " previous player\n" .. self:CheckBind("+jump") .. " spectate mode (1st person/Chase/Free)"
		elseif V.P.plyAlive and V.P.plyTeam == TEAM_HIDING and V.P.wep == "spb_hiding" then
			tips = self:CheckBind("+attack") .. " to weld a prop to another\n" .. self:CheckBind("+attack2") .. " to unweld a prop"
		elseif V.P.plyAlive and V.P.plyTeam == TEAM_SEEKER and V.P.wep == "spb_seeker" then
			tips = self:CheckBind("+attack") .. " to break props"
		end

		if tips != "" then
			surface.SetFont(self:GetScaledFont("spb_HT"))
			w, h = surface.GetTextSize(tips)
			surface.SetDrawColor(Color(0, 0, 0, 200))
			surface.DrawRect(ScrW() / 2 - w / 2 - V.spacer / 2, ScrH() - h - V.hudoffset_h, w + V.spacer * 2, h)
			draw.DrawText(tips, self:GetScaledFont("spb_HT"), ScrW() / 2, ScrH() - h - V.hudoffset_h, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)
			--surface.SetDrawColor(Color(0, 0, 0, 255))
			--surface.DrawOutlinedRect(ScrW() / 2 - w / 2 - V.spacer / 2, ScrH() - h - V.hudoffset_h, w + V.spacer, h)
		end


		--[[ THE QUICK TIPS ]]--

		local qtips
		local w, h = 0, 0

		if V.P.plyTeam == TEAM_UNASSIGNED then
			qtips = "Press any key to join!"
		elseif V.P.plyTeam == TEAM_HIDING and !V.R.Start and !V.P.plyAlive then
			qtips = "Press any key to respawn!"
		end
		if qtips then
			surface.SetFont(self:GetScaledFont("spb_TXT"))
			w, h = surface.GetTextSize(qtips)
			surface.SetDrawColor(Color(0, 0, 0, BreathEffect(200)))
			surface.DrawRect(ScrW() / 2 - w / 2 - V.spacer / 2, ScrH() / 2 - h, w + V.spacer, h)
			draw.DrawText(qtips, self:GetScaledFont("spb_TXT"), ScrW() / 2, ScrH() / 2 - h, Color(255, 255, 255, BreathEffect(255)), TEXT_ALIGN_CENTER)
			surface.SetDrawColor(Color(0, 0, 0, BreathEffect(255)))
			surface.DrawOutlinedRect(ScrW() / 2 - w / 2 - V.spacer / 2, ScrH() / 2 - h, w + V.spacer, h)
		end


		--[[ THE PERFORMING WELD MESSAGE ]]--

		if V.P.splyAlive and V.P.splyTeam == TEAM_HIDING then

			if V.P.weldingstate == 2 then
				self:DrawLegacyWeldInfo(V, "This prop is too far!", true)
			elseif V.P.weldingstate == 3 then
				self:DrawLegacyWeldInfo(V, "The props are too far each other!", true)
			elseif IsValid(V.P.welding) then
				self:DrawLegacyWeldInfo(V, "Click another prop")
			end

		end

	end


	--[[ THE PLAYER STATUS AND FACE ]]--

	local base_value = self:ScreenScaleMin(200)
	local base_value_quad = base_value / 4

	if V.P.splyTeam == TEAM_SEEKER or V.P.splyTeam == TEAM_HIDING then

		local life = Either(V.P.splyAlive, 1, 0)
		local stamina = base_value
		local taunt = base_value
		local radar = base_value
		local cloak = base_value
		local sprintlock = false
		local fcolor = Color(V.P.color.r, V.P.color.g, V.P.color.b, 150 * life)
		local ib = 0

		if V.P.splyAlive and V.P.splyTeam == TEAM_HIDING then
			stamina = math.Remap(V.P.sply:GetNWInt("spb_SprintV", 100), 0, 100, 0, base_value)
			sprintlock = V.P.sply:GetNWInt("spb_SprintLock", false)
		end

		if V.P.ply != V.P.sply and V.P.splyAlive then

			local LastTaunt = V.P.sply:GetNWInt("spb_LastTaunt", 0)
			local TauntCooldown = V.P.sply:GetNWInt("spb_TauntCooldown", 0) - CurTime()
			local TauntCooldownF = V.P.sply:GetNWInt("spb_TauntCooldownF", 5)

			if LastTaunt > 0 and TauntCooldown > 0 then
				taunt = math.Remap(TauntCooldown, 0, TauntCooldownF, base_value, 0)
			end

		elseif V.P.plyAlive and V.P.ply.LastTaunt and V.P.ply.TauntCooldown-CurTime() > 0 then
			taunt = math.Remap(V.P.ply.TauntCooldown - CurTime(), 0, V.P.ply.TauntCooldownF, base_value, 0)
		end


		local cloaktime = V.P.sply:GetNWFloat("spb_CloakTime", 0)
		if cloaktime != 0 and cloaktime > CurTime() then
			cloak = math.Remap(cloaktime - CurTime(), 0, spb_powerup_cloak_time:GetFloat(), 0, base_value)
		end
		local radartime = V.P.sply:GetNWFloat("spb_RadarTime", 0)
		if radartime != 0 and radartime > CurTime() then
			radar = math.Remap(radartime - CurTime(), 0, spb_powerup_radar_time:GetFloat(), 0, base_value)
		end

		draw.RoundedBox(0, V.hudoffset_w, ScrH() - base_value - V.hudoffset_h, base_value, base_value, Color(0, 0, 0, 200))

		draw.RoundedBox(0, V.hudoffset_w, ScrH() - base_value - V.hudoffset_h, base_value, base_value, fcolor)

		local function MakeBar(name, value, nope)
			surface.SetDrawColor(Color(0, 0, 0, 200))
			surface.DrawRect(base_value + V.hudoffset_w, ScrH() - base_value + base_value_quad * ib - V.hudoffset_h, base_value, base_value_quad)
			surface.SetDrawColor(fcolor)
			surface.DrawRect(base_value + V.hudoffset_w, ScrH() - base_value + base_value_quad * ib - V.hudoffset_h, value, base_value_quad)
			draw.DrawText(name, self:GetScaledFont("spb_TXT"), base_value * 1.5 + V.hudoffset_w, ScrH() - base_value * .975 + base_value_quad * ib - V.hudoffset_h, Either(nope, Color(255, 0, 0, 255), Color(255, 255, 255, 255)), TEXT_ALIGN_CENTER)
			surface.SetDrawColor(Color(0, 0, 0, 255))
			surface.DrawOutlinedRect(base_value + V.hudoffset_w, ScrH() - base_value + base_value_quad * ib - V.hudoffset_h, base_value, base_value_quad)
			ib = ib + 1
		end

		if V.P.splyAlive then
			if (V.R.Start or stamina != base_value) and V.P.splyTeam == TEAM_HIDING then
				MakeBar("STAMINA", stamina, sprintlock)
			end
			if taunt != base_value then
				MakeBar("TAUNT", taunt)
			end
			if radar != base_value then
				MakeBar("RADAR", radar)
			end
			if cloak != base_value then
				MakeBar("CLOAK", cloak)
			end
		end

	end

	if (V.P.sply:GetModel() == "models/player/pbear/pbear.mdl" or V.P.sply:GetModel() == "models/player/kuristaja/pbear/pbear.mdl") then
		surface.SetDrawColor(255, 255, 255, 255)
		surface.SetMaterial(self.Materials.Bear)
		surface.DrawTexturedRect(V.hudoffset_w, ScrH() - base_value - V.hudoffset_h, base_value, base_value)
		surface.SetDrawColor(Color(0, 0, 0, 255))
		surface.DrawOutlinedRect(V.hudoffset_w, ScrH() - base_value - V.hudoffset_h, base_value, base_value)
	elseif V.P.plyTeam != TEAM_UNASSIGNED and V.P.splyTeam != TEAM_SPECTATOR then
		self:DrawHealthFace(V.P.sply, V.hudoffset_w, ScrH() - base_value - V.hudoffset_h, base_value, base_value)
		surface.SetDrawColor(Color(0, 0, 0, 255))
		surface.DrawOutlinedRect(V.hudoffset_w, ScrH() - base_value - V.hudoffset_h, base_value, base_value)
	end

	if V.P.plyTeam != TEAM_UNASSIGNED and V.P.splyTeam != TEAM_SPECTATOR then
		local splynick = self:LimitString(V.P.sply:Nick(), base_value, self:GetScaledFont("spb_HUDname"))
		local rankname = self:LimitString(V.P.sply:GetNWString("XperidiaRankName", nil) or "", base_value, self:GetScaledFont("spb_HUDname"))
		local rankcolor = string.ToColor(V.P.sply:GetNWString("XperidiaRankColor", "255 255 255 255"))
		if V.P.sply:IsGamemodeAuthor() then
			rankname = "Gamemode author"
		end
		draw.DrawText(splynick, self:GetScaledFont("spb_HUDname"), base_value / 2 + 1 + V.hudoffset_w, ScrH() - base_value + 1 - V.hudoffset_h, Color(0, 0, 0, 255), TEXT_ALIGN_CENTER)
		draw.DrawText(splynick, self:GetScaledFont("spb_HUDname"), base_value / 2 + V.hudoffset_w, ScrH() - base_value - V.hudoffset_h, V.P.color, TEXT_ALIGN_CENTER)
		draw.DrawText(rankname, self:GetScaledFont("spb_HUDname"), base_value / 2 + 1 + V.hudoffset_w, ScrH() - base_value * .12 + 1 - V.hudoffset_h, Color(0, 0, 0, 255), TEXT_ALIGN_CENTER)
		draw.DrawText(rankname, self:GetScaledFont("spb_HUDname"), base_value / 2 + V.hudoffset_w, ScrH() - base_value * .12 - V.hudoffset_h, rankcolor, TEXT_ALIGN_CENTER)
	end


	--[[ THE POWER-UP ]]--

	if V.P.sply:HasPowerUP() then

		local powerup = self.PowerUps[V.P.sply:GetPowerUP()]
		local anim_time = V.P.sply:GetNWFloat("spb_PowerUPDelay", nil)
		local anim_progress = anim_time and anim_time > CurTime()
		local ox, oy = self:ScreenScaleMin(25) + V.hudoffset_w, ScrH() - self:ScreenScaleMin(400) - V.hudoffset_h
		local ow, oh = self:ScreenScaleMin(150), self:ScreenScaleMin(150)
		surface.SetFont(self:GetScaledFont("spb_HUDname"))

		surface.SetDrawColor(Color(0, 0, 0, 200))
		surface.DrawRect(ox, oy, ow, oh)

		if V.P.sply:HasPowerUP() and anim_progress and V.P.sply.AnimSetup and table.Count(V.P.sply.AnimSetup) > 0 then
			for k, v in pairs(V.P.sply.AnimSetup) do
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
				if anim_time - 1 > CurTime() or (anim_time - 1 <= CurTime() and V.P.sply.AnimSetup[V.P.sply:GetPowerUP()].Offset != 0) then
					if V.P.sply.AnimSetup[k].Offset > oh * (table.Count(V.P.sply.AnimSetup) - 1) then
						V.P.sply.AnimSetup[k].Offset = -oh
					else
						V.P.sply.AnimSetup[k].Offset = V.P.sply.AnimSetup[k].Offset + 10
					end
				end
			end
		elseif V.P.sply:HasPowerUP() and anim_progress then
			local offset = 0
			if !V.P.sply.AnimSetup then V.P.sply.AnimSetup = {} else table.Empty(V.P.sply.AnimSetup) end
			--V.P.sply.AnimStart = CurTime()
			for k, v in RandomPairs(self.PowerUps) do
				V.P.sply.AnimSetup[k] = {}
				V.P.sply.AnimSetup[k].Mat = v[3]
				V.P.sply.AnimSetup[k].Color = v[4]
				V.P.sply.AnimSetup[k].Offset = offset
				offset = offset + oh
			end
		elseif V.P.sply:HasPowerUP() then
			if powerup[4] and IsColor(powerup[4]) then
				surface.SetDrawColor(powerup[4])
			else
				surface.SetDrawColor(Color(52, 190, 236, 255))
			end
			surface.SetMaterial(powerup[3])
			if (V.P.swep == "spb_hiding" or V.P.swep == "spb_seeker") and !V.R.End then
				surface.DrawTexturedRect(ox + BreathEffect(self:ScreenScaleMin(25)) / 2, oy + BreathEffect(self:ScreenScaleMin(25)) / 2, ow - BreathEffect(self:ScreenScaleMin(25)), oh - BreathEffect(self:ScreenScaleMin(25)))
			else
				surface.DrawTexturedRect(ox, oy, ow, oh)
			end
			if V.P.sply.AnimSetup and table.Count(V.P.sply.AnimSetup) > 0 then table.Empty(V.P.sply.AnimSetup) end
		elseif V.P.sply.AnimSetup and table.Count(V.P.sply.AnimSetup) > 0 then
			table.Empty(V.P.sply.AnimSetup)
		end

		surface.SetDrawColor(Color(0, 0, 0, 255))
		surface.DrawOutlinedRect(ox, oy, ow, oh)

		if !V.hide_tips then
			local usetip
			if V.P.ply:HasPowerUP() and !anim_progress and (V.P.wep == "spb_hiding" or V.P.wep == "spb_seeker") then
				usetip = "Press " .. self:CheckBind("+reload") .. " to use"
			end
			if usetip then
				local tw, th = surface.GetTextSize(usetip)
				surface.SetDrawColor(Color(0, 0, 0, 200))
				surface.DrawRect(ox + ow / 2 - tw / 2 - V.spacer / 2, oy + oh, tw + V.spacer * 2, th)
				draw.DrawText(usetip, self:GetScaledFont("spb_HUDname"), ox + ow / 2, oy + oh, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)
				--surface.SetDrawColor(Color(0, 0, 0, 255))
				--surface.DrawOutlinedRect(ox + ow / 2 - tw / 2 - V.spacer / 2, oy + oh, tw + V.spacer, th)
			end
		end

	end


	--[[ THE MUSICS STUFF ]]--

	if IsValid(self.Vars.Music) then

		local m_s_x, m_s_y = self:ScreenScale(256, 100)
		local time = self.Vars.Music:GetTime()
		local totaltime = self.Vars.Music:GetLength()
		local left, right = self.Vars.Music:GetLevel()
		local visuok = GetConVar("spb_cl_music_visualizer"):GetBool() and self.Vars.Music:GetState() == GMOD_CHANNEL_PLAYING
		local visspace = self:ScreenScaleMin(48)
		if visuok then
			visspace = 0
		end

		draw.RoundedBox(0, ScrW() - m_s_x - V.hudoffset_w, ScrH() - m_s_y + visspace - V.hudoffset_h, m_s_x, m_s_y - visspace, Color(0, 0, 0, 200))

		local ctitle = self.Vars.CurrentMusicName
		local rtitle
		if ctitle and ctitle != "" then
			rtitle = ctitle
		else
			rtitle = self:PrettyMusicName(string.GetFileFromFilename(self.Vars.Music:GetFileName()))
		end

		local title = self:LimitString(rtitle, self:ScreenScaleMin(246), self:GetScaledFont("spb_HUDname"))
		draw.DrawText(title, self:GetScaledFont("spb_HUDname"), ScrW() - m_s_x / 2 + 1 - V.hudoffset_w, ScrH() - m_s_y + 1 + visspace - V.hudoffset_h - self:ScreenScaleMin(2), Color(0, 0, 0, 255), TEXT_ALIGN_CENTER)
		draw.DrawText(title, self:GetScaledFont("spb_HUDname"), ScrW() - m_s_x / 2 - V.hudoffset_w, ScrH() - m_s_y + visspace - V.hudoffset_h - self:ScreenScaleMin(2), Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)

		draw.RoundedBox(0, ScrW() - m_s_x - V.hudoffset_w, ScrH() - self:ScreenScaleMin(80) + visspace - V.hudoffset_h, m_s_x, self:ScreenScaleMin(16), Color(0, 0, 0, 200)) --Timetrack
		draw.RoundedBox(0, ScrW() - m_s_x - V.hudoffset_w, ScrH() - self:ScreenScaleMin(77) + visspace - V.hudoffset_h, math.Remap(time, 0, totaltime, 0, m_s_x), self:ScreenScaleMin(10), Color(255, 255, 255, 200))

		draw.RoundedBox(0, ScrW() - m_s_x - V.hudoffset_w, ScrH() - self:ScreenScaleMin(64) + visspace - V.hudoffset_h, m_s_x, self:ScreenScaleMin(16), Color( 0, 0, 0, 200)) --Wub
		draw.RoundedBox(0, ScrW() - m_s_x - V.hudoffset_w, ScrH() - self:ScreenScaleMin(56) + visspace - V.hudoffset_h, math.Remap(left, 0, 1, 0, m_s_x), V.spacer, volume_to_color(left))
		draw.RoundedBox(0, ScrW() - m_s_x - V.hudoffset_w, ScrH() - self:ScreenScaleMin(64) + visspace - V.hudoffset_h, math.Remap(right, 0, 1, 0, m_s_x), V.spacer, volume_to_color(right))

		surface.SetDrawColor(0, 0, 0, 255)
		surface.DrawLine(ScrW() - m_s_x - V.hudoffset_w, ScrH() - self:ScreenScaleMin(64) + visspace - V.hudoffset_h, ScrW() - V.hudoffset_w, ScrH() - self:ScreenScaleMin(64) + visspace - V.hudoffset_h)
		surface.DrawLine(ScrW() - m_s_x - V.hudoffset_w, ScrH() - self:ScreenScaleMin(48) + visspace - V.hudoffset_h, ScrW() - V.hudoffset_w, ScrH() - self:ScreenScaleMin(48) + visspace - V.hudoffset_h)

		local timetxt = self:FormatTimeTri(time) .. "/" .. self:FormatTimeTri(totaltime) --Time
		surface.SetFont(self:GetScaledFont("spb_HUDname"))
		local tw, _ = surface.GetTextSize(timetxt)
		draw.RoundedBox(0, ScrW() - self:ScreenScaleMin(128) - tw / 2 - V.hudoffset_w - self:ScreenScaleMin(4), ScrH() - self:ScreenScaleMin(80) + visspace - V.hudoffset_h, tw + self:ScreenScaleMin(8), V.spacer * 2, Color(0, 0, 0, 220))
		draw.DrawText(timetxt, self:GetScaledFont("spb_HUDname"), ScrW() - self:ScreenScaleMin(128) + 1 - V.hudoffset_w, ScrH() - self:ScreenScaleMin(82) + 1 + visspace - V.hudoffset_h - self:ScreenScaleMin(2), Color(0, 0, 0, 255), TEXT_ALIGN_CENTER)
		draw.DrawText(timetxt, self:GetScaledFont("spb_HUDname"), ScrW() - self:ScreenScaleMin(128) - V.hudoffset_w, ScrH() - self:ScreenScaleMin(82) + visspace - V.hudoffset_h - self:ScreenScaleMin(2), Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)

		surface.SetDrawColor(Color(0, 0, 0, 255))
		surface.DrawOutlinedRect(ScrW() - m_s_x - V.hudoffset_w, ScrH() - m_s_y + visspace - V.hudoffset_h, m_s_x, m_s_y - visspace)

		if visuok then

			local eqd = {}
			local width = self:ScreenScaleMin(2)

			self.Vars.Music:FFT(eqd, 0)

			surface.SetDrawColor(Color(0, 0, 0, 200))
			surface.DrawRect(ScrW() - m_s_x - V.hudoffset_w, ScrH() - self:ScreenScaleMin(48) - V.hudoffset_h, m_s_x, self:ScreenScaleMin(48))

			for k, v in pairs(eqd) do
				local on = math.Clamp(math.Remap(v, 0, 1 / k, 0, self:ScreenScaleMin(48)), 0, self:ScreenScaleMin(48))
				local b = math.Clamp(math.Remap(v, 0, 1 / k, 0, 1), 0, 1)
				surface.SetDrawColor(volume_to_color(b))
				surface.DrawRect(ScrW() - m_s_x + (k - 1) * width - V.hudoffset_w, ScrH() - on - V.hudoffset_h, width, on)
			end

			surface.SetDrawColor(Color(0, 0, 0, 255))
			surface.DrawOutlinedRect(ScrW() - m_s_x - V.hudoffset_w, ScrH() - self:ScreenScaleMin(48) - V.hudoffset_h, m_s_x, self:ScreenScaleMin(48))

		end

		if !V.hide_tips then
			local usetip = "Press " .. self:CheckBind("gm_showspare2") .. " for options"
			if usetip then
				local tw, th = surface.GetTextSize(usetip)
				surface.SetDrawColor(Color(0, 0, 0, 200))
				surface.DrawRect(ScrW() - self:ScreenScaleMin(128) - V.hudoffset_w - tw / 2 - V.spacer / 2, ScrH() - self:ScreenScaleMin(100) + visspace - V.hudoffset_h - self:ScreenScaleMin(20) - V.spacer / 2, tw + V.spacer, th)
				draw.DrawText(usetip, self:GetScaledFont("spb_HUDname"), ScrW() - self:ScreenScaleMin(128) - V.hudoffset_w, ScrH() - self:ScreenScaleMin(100) + visspace - V.hudoffset_h - self:ScreenScaleMin(20) - V.spacer / 2, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)
				--surface.SetDrawColor(Color(0, 0, 0, 255))
				--surface.DrawOutlinedRect(ScrW() - self:ScreenScaleMin(128) - V.hudoffset_w - tw / 2 - V.spacer / 2, ScrH() - self:ScreenScaleMin(100) + visspace - V.hudoffset_h - self:ScreenScaleMin(20) - V.spacer / 2, tw + V.spacer, th)
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

function GM:DrawHealthFace(ply, x, y, w, h)

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

	local x, y = ScrW() / 2, ScrH() * 0.5

	x = x - w / 2
	y = y + h

	draw.SimpleText(text, font, x + 1, y + 1, Color(0, 0, 0, 255))
	draw.SimpleText(text, font, x + 2, y + 2, Color(0, 0, 0, 126))
	if trace.Entity:IsPlayer() or trace.Entity:GetClass() == "spb_dummy" then
		local col = trace.Entity:GetPlayerColor():ToColor()
		draw.SimpleText(text, font, x, y, col)
	elseif trace.Entity:IsPlayer() then
		draw.SimpleText(text, font, x, y, self:GetTeamColor(trace.Entity))
	end

end
