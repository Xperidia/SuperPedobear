--[[---------------------------------------------------------
		Super Pedobear Gamemode for Garry's Mod
				by VictorienXP (2016-2020)
-----------------------------------------------------------]]

local function binds()
	return {
		{GAMEMODE:CheckBind("gm_showhelp"), "Gamemode menu", "Open Help"},
		{GAMEMODE:CheckBind("gm_showteam"), "Change team", "Open Team Menu"},
		{GAMEMODE:CheckBind("gm_showspare1"), "Taunt menu", "Server Customizable Spare 1"},
		{GAMEMODE:CheckBind("gm_showspare2"), "Jukebox/music menu", "Server Customizable Spare 2"},
		{GAMEMODE:CheckBind("+reload"), "Use Power-UP", language.GetPhrase("#Valve_Reload_Weapon")},
		{GAMEMODE:CheckBind("+menu"), "Shop", "Open Spawn Menu"},
		{GAMEMODE:CheckBind("+menu_context"), "Toggle thirdperson", "Open Context Menu"},
		{GAMEMODE:CheckBind("gmod_undo"), "Drop Power-UP", "Undo"},
		{GAMEMODE:CheckBind("phys_swap"), "Enhanced PlayerModel Selector", language.GetPhrase("#Valve_Gravity_Gun")},
		{"1-9", "Quick taunt and quick buy", ""},
		{"0", "Random taunt", ""},
		{GAMEMODE:CheckBind("+forward"), "Move forward", language.GetPhrase("#Valve_Move_Forward")},
		{GAMEMODE:CheckBind("+moveleft"), "Move left", language.GetPhrase("#Valve_Move_Left")},
		{GAMEMODE:CheckBind("+moveright"), "Move right", language.GetPhrase("#Valve_Move_Right")},
		{GAMEMODE:CheckBind("+back"), "Move back", language.GetPhrase("#Valve_Move_Back")},
		{GAMEMODE:CheckBind("+speed"), "Sprint", language.GetPhrase("#Valve_Sprint")},
		{GAMEMODE:CheckBind("+jump"), "Jump", language.GetPhrase("#Valve_Jump")},
		{GAMEMODE:CheckBind("+duck"), "Crouch", language.GetPhrase("#Valve_Duck")},
		{GAMEMODE:CheckBind("+use"), "Use", language.GetPhrase("#Valve_Use_Items")}
	}
end

local function do_a_checkbox(str, cvar, parent)
	local checkbox = vgui.Create("DCheckBoxLabel", parent)
	checkbox:SetText(str)
	checkbox:SetPos(15, 30 + (parent.checkbox_offset or 0))
	checkbox:SetDark(1)
	checkbox:SetConVar(cvar)
	checkbox:SetValue(GetConVar(cvar):GetBool())
	checkbox:SizeToContents()
	parent.checkbox_offset = (parent.checkbox_offset or 0) + 20
end

local function do_a_bunch_of_checkboxes(table, parent)
	for k, v in pairs(table) do
		do_a_checkbox(v, k, parent)
	end
end

local cl_cvars = {
	spb_cl_disabletauntmenuclose = "Don't close the taunt menu after taunting",
	cl_drawhud = "Draw HUD (Caution! This is a Garry's Mod convar)",
	spb_cl_disablehalos = "Disable halos (Improve performance)",
	spb_cl_hide_tips = "Hide all tips",
	--spb_cl_music_enable = "Enable music/jukebox",
	--spb_cl_music_allowexternal = "Allow external musics (from Internet)",
	--spb_cl_music_visualizer = "Enable visualizer (Downgrade performance)",
	spb_cl_quickstuff_enable = "Enable quick taunt and quick buy",
	spb_cl_quickstuff_numpad = "Use numpad as well for quick stuff",
	spb_cl_hud_html_enable = "Enable the HTML HUD (WIP)"
}

local function btnMinimDoClick(btn)
	local self = btn:GetParent()
	if self.minim and self.maxim then
		self:SetPos(0, 0)
		self:SetSize(ScrW(), ScrH())
		self:SetKeyboardInputEnabled(true)
		self:SetSizable(false)
		self:SetDraggable(false)
		self.minim = false
	elseif self.minim then
		self:SetPos(self.lastpos_x, self.lastpos_y)
		self:SetSize(self.lastsize_w, self.lastsize_h)
		self:SetKeyboardInputEnabled(false)
		self:SetSizable(true)
		self.minim = false
	else
		if !self.maxim then
			self.lastpos_x, self.lastpos_y = self:GetPos()
			self.lastsize_w, self.lastsize_h = self:GetSize()
		end
		self:SetPos(0, ScrH() - 24)
		self:SetSize(280, 24)
		self:SetKeyboardInputEnabled(false)
		self:SetSizable(false)
		self.minim = true
	end
end

local function btnMaximDoClick(btn)
	local self = btn:GetParent()
	if self.maxim and !self.minim then
		self:SetPos(self.lastpos_x, self.lastpos_y)
		self:SetSize(self.lastsize_w, self.lastsize_h)
		self:SetKeyboardInputEnabled(false)
		self:SetSizable(true)
		self:SetDraggable(true)
		self.maxim = false
	else
		if !self.minim then
			self.lastpos_x, self.lastpos_y = self:GetPos()
			self.lastsize_w, self.lastsize_h = self:GetSize()
		end
		self:SetPos(0, 0)
		self:SetSize(ScrW(), ScrH())
		self:SetKeyboardInputEnabled(true)
		self:SetSizable(false)
		self:SetDraggable(false)
		self.maxim = true
		self.minim = false
	end
end

concommand.Add("spb_menu", function() GAMEMODE:Menu() end, nil, "Open the gamemode's menu")

function GM:Menu()

	if engine.IsPlayingDemo() then
		return
	end

	if IsValid(GAMEMODE.MainMenuFrame) then
		GAMEMODE.MainMenuFrame:ToggleVisible()
		return
	end

	GAMEMODE.MainMenuFrame = vgui.Create("DFrame")
	local menu = GAMEMODE.MainMenuFrame
	local s_x, s_y = 640, 480
	menu:SetSize(s_x, s_y)
	menu:SetPos(ScrW() / 2 - (s_x / 2), ScrH() / 2 - (s_y / 2))
	menu:SetTitle(GAMEMODE.Name .. " main menu")
	menu:SetVisible(true)
	menu:SetDraggable(true)
	menu:ShowCloseButton(true)
	menu:SetScreenLock(true)
	menu:SetSizable(true)
	--menu.btnMaxim:SetDisabled(false)
	--menu.btnMaxim.DoClick = function(btn) btnMaximDoClick(btn) end
	menu.btnMinim:SetDisabled(false)
	menu.btnMinim.DoClick = function(btn) menu:ToggleVisible() end
	menu.Paint = function(self, w, h)
		draw.RoundedBox(4, 0, 0, w, h, Color(0, 0, 0, 128))
	end
	menu:MakePopup()
	menu:SetKeyboardInputEnabled(false)

	menu.one = vgui.Create("DPanel", menu)
	menu.one:SetPos(10, 30)
	menu.one:SetSize(305, 215)

	menu.one.text = vgui.Create("RichText", menu.one)
	menu.one.text:Dock(FILL)
	menu.one.text:InsertColorChange(0, 0, 0, 255)
	function menu.one.text:PerformLayout()
		self:SetFontInternal("DermaDefault")
	end

	menu.one.text:AppendText("\t    You're playing Super Pedobear v" .. (self.Version and tostring(self.Version) or "?") .. " (" .. (self.VersionDate or "?") .. ")\n")

	if self:SeasonalEventStr() != "" then
		menu.one.text:AppendText("\t\t\t    " .. self:SeasonalEventStr() .. "\n\n")
	else
		menu.one.text:AppendText("\n")
	end

	menu.one.text:AppendText("Gamemode made by VictorienXP, with arts from Pho3 and Wubsy...\n\n")

	if self.LatestRelease.Version then

		if self.LatestRelease.Newer then
			menu.one.text:InsertColorChange(192, 0, 0, 255)
			menu.one.text:AppendText("There is a new release available! ")
			menu.one.text:InsertColorChange(192, 0, 192, 255)
		elseif self:VersionEqual(self.Version, self.LatestRelease.Version) then
			menu.one.text:InsertColorChange(0, 192, 0, 255)
			menu.one.text:AppendText("You're on the latest release! ")
			menu.one.text:InsertColorChange(192, 0, 192, 255)
		elseif self:VersionCompare(self.LatestRelease.Version, self.Version) then
			menu.one.text:InsertColorChange(0, 0, 0, 255)
			menu.one.text:AppendText("You're on a unreleased/dev build!\nLatest release is ")
			menu.one.text:InsertColorChange(192, 0, 192, 255)
		end
		menu.one.text:InsertClickableTextStart("LatestRelease")
		menu.one.text:AppendText(self.LatestRelease.Name or ("v" .. (self.LatestRelease.Version and tostring(self.LatestRelease.Version) or "?")))
		menu.one.text:InsertClickableTextEnd()
		menu.one.text:InsertColorChange(0, 0, 0, 255)
		menu.one.text:AppendText("\n")
		if self.LatestRelease.Newer and !self.LatestRelease.prerelease and game.IsDedicated() then
			menu.one.text:AppendText("Ask the server owner to update the gamemode!\n")
		elseif self.LatestRelease.Newer and !self.LatestRelease.prerelease and self.MountedfromWorkshop and LocalPlayer():GetNWBool("IsListenServerHost", false) then
			menu.one.text:AppendText("Let Steam download the update and restart the game!\n")
		elseif self.LatestRelease.Newer and !self.LatestRelease.prerelease then
			menu.one.text:AppendText("Don't forget to update!\n")
		end
		menu.one.text:AppendText("\n")

	else

		menu.one.text:AppendText("Couldn't fetch the ")
		menu.one.text:InsertClickableTextStart("LatestRelease")
			menu.one.text:AppendText("latest release")
		menu.one.text:InsertClickableTextEnd()
		menu.one.text:AppendText(".\t")
		menu.one.text:InsertClickableTextStart("FetchLatestRelease")
			menu.one.text:AppendText("Retry")
		menu.one.text:InsertClickableTextEnd()
		menu.one.text:AppendText("\n\n")

	end

	menu.one.text:InsertClickableTextStart("SplashScreen")
	menu.one.text:AppendText("Click here to open the Splash Screen")
	menu.one.text:InsertClickableTextEnd()
	menu.one.text:AppendText("\n")
	menu.one.text:InsertClickableTextStart("MapVote")
	menu.one.text:AppendText("Click here for the map vote (WIP)")
	menu.one.text:InsertClickableTextEnd()
	menu.one.text:AppendText("\n")
	menu.one.text:InsertClickableTextStart("Debug")
	menu.one.text:AppendText("Click here to open the debug window")
	menu.one.text:InsertClickableTextEnd()
	menu.one.text:AppendText("\n")
	menu.one.text:InsertClickableTextStart("Workshop")
	menu.one.text:AppendText("Click here to open the Workshop page")
	menu.one.text:InsertClickableTextEnd()
	menu.one.text:AppendText("\n")
	menu.one.text:InsertClickableTextStart("Workshop_changelog")
	menu.one.text:AppendText("Click here to open the Workshop change notes")
	menu.one.text:InsertClickableTextEnd()
	menu.one.text:AppendText("\n")
	menu.one.text:InsertClickableTextStart("GitHub")
	menu.one.text:AppendText("Click here to open the GitHub repository")
	menu.one.text:InsertClickableTextEnd()
	menu.one.text:AppendText("\n")
	menu.one.text:InsertClickableTextStart("GitHub_releases")
	menu.one.text:AppendText("Click here to open the GitHub releases")
	menu.one.text:InsertClickableTextEnd()
	menu.one.text:AppendText("\n")

	function menu.one.text:ActionSignal(signalName, signalValue)
		if signalName == "TextClicked" then
			if signalValue == "SplashScreen" then
				GAMEMODE:SplashScreen()
				menu:Close()
			elseif signalValue == "MapVote" then
				GAMEMODE:MapVote()
				menu:Close()
			elseif signalValue == "Debug" then
				GAMEMODE:DebugWindow()
				menu:Close()
			elseif signalValue == "Workshop" then
				gui.OpenURL("https://steamcommunity.com/sharedfiles/filedetails/?id=628449407")
				menu:Close()
			elseif signalValue == "Workshop_changelog" then
				gui.OpenURL("https://steamcommunity.com/sharedfiles/filedetails/changelog/628449407")
				menu:Close()
			elseif signalValue == "GitHub" then
				gui.OpenURL("https://github.com/Xperidia/SuperPedobear")
				menu:Close()
			elseif signalValue == "GitHub_releases" then
				gui.OpenURL("https://github.com/Xperidia/SuperPedobear/releases")
				menu:Close()
			elseif signalValue == "LatestRelease" then
				gui.OpenURL(GAMEMODE.LatestRelease.URL or "https://github.com/Xperidia/SuperPedobear/releases/latest")
				menu:Close()
			elseif signalValue == "FetchLatestRelease" then
				GAMEMODE:CheckForNewRelease()
				menu:Close()
			end
		end
	end


	menu.config = vgui.Create("DScrollPanel", menu)
	menu.config:SetPos(325, 30)
	menu.config:SetSize(305, 215)
	menu.config:SetPaintBackground(true)

	local configlbl = vgui.Create("DLabel", menu.config)
	configlbl:SetText("Personal configuration")
	configlbl:SetPos(10, 5)
	configlbl:SetDark(1)
	configlbl:SizeToContents()

	do_a_bunch_of_checkboxes(cl_cvars, menu.config)

	menu.config.checkbox_offset = (menu.config.checkbox_offset or 0) + 10
	local hudoffset_w = vgui.Create("DNumSlider", menu.config)
	hudoffset_w:SetPos(15, 24 + menu.config.checkbox_offset)
	hudoffset_w:SetSize(300, 16)
	hudoffset_w:SetText("Horizontal HUD Offset")
	hudoffset_w:SetMin(0)
	hudoffset_w:SetMax(100)
	hudoffset_w:SetDecimals(0)
	hudoffset_w:SetDark(1)
	hudoffset_w:SetConVar("spb_cl_hud_offset_w")
	menu.config.checkbox_offset = menu.config.checkbox_offset + 24

	local hudoffset_h = vgui.Create("DNumSlider", menu.config)
	hudoffset_h:SetPos(15, 24 + menu.config.checkbox_offset)
	hudoffset_h:SetSize(300, 16)
	hudoffset_h:SetText("Vertical HUD Offset")
	hudoffset_h:SetMin(0)
	hudoffset_h:SetMax(100)
	hudoffset_h:SetDecimals(0)
	hudoffset_h:SetDark(1)
	hudoffset_h:SetConVar("spb_cl_hud_offset_h")


	menu.Controls = vgui.Create("DPanel", menu)
	menu.Controls:SetPos(10, 255)
	menu.Controls:SetSize(305, 215)

	menu.Controls.lbl = vgui.Create("DLabel", menu.Controls)
	menu.Controls.lbl:SetText("Controls")
	menu.Controls.lbl:SetPos(10, 5)
	menu.Controls.lbl:SetSize(289, 10)
	menu.Controls.lbl:SetDark(1)

	menu.Controls.List = vgui.Create("DListView", menu.Controls)
	menu.Controls.List:SetPos(0, 20)
	menu.Controls.List:SetSize(305, 195)
	menu.Controls.List:SetMultiSelect(false)
	local key = menu.Controls.List:AddColumn("KEY")
	key:SetMinWidth(40)
	key:SetMinWidth(60)
	local action = menu.Controls.List:AddColumn("Action")
	action:SetMinWidth(100)
	local bindname = menu.Controls.List:AddColumn("Options bind name")
	bindname:SetMinWidth(100)

	for k, v in pairs(binds()) do
		menu.Controls.List:AddLine(v[1], v[2], v[3])
	end


	menu.AdminCFG = vgui.Create("DScrollPanel", menu)
	menu.AdminCFG:SetPos(325, 255)
	menu.AdminCFG:SetSize(305, 215)
	menu.AdminCFG:SetPaintBackground(true)

	local adminmenulbl = vgui.Create("DLabel", menu.AdminCFG)
	adminmenulbl:SetText("Admin configuration")
	adminmenulbl:SetPos(10, 5)
	adminmenulbl:SetDark(1)
	adminmenulbl:SizeToContents()

	local eh = 0
	local function docheckbox(str, cvar)
		local checkbox = vgui.Create("DCheckBoxLabel", menu.AdminCFG)
		checkbox:SetText(str)
		checkbox:SetPos(15, 30 + eh)
		checkbox:SetDark(1)
		checkbox:SetConVar(cvar)
		checkbox:SetValue(GetConVar(cvar):GetBool())
		checkbox:SetEnabled(LocalPlayer():GetNWBool("IsListenServerHost", false))
		checkbox:SizeToContents()
		eh = eh + 20
	end

	docheckbox("Dev mode (You really shoudn't use this)", "spb_enabledevmode")
	docheckbox("Save chances", "spb_save_chances")
	docheckbox("Slow motion effect", "spb_slow_motion")
	docheckbox("Rainbow color effect", "spb_rainbow_effect")
	docheckbox("Enable Power-UPs", "spb_powerup_enabled")
	docheckbox("Give Power-UPs on maps without Power-UP spawner", "spb_powerup_autofill")
	docheckbox("Enable the van (shop)", "spb_shop_enabled")
	docheckbox("Give some weapons on spawn (not recommended)", "spb_weapons")
	docheckbox("Enable jukebox input", "spb_jukebox_enable_input")
	docheckbox("Restrict playermodels to the default list", "spb_restrict_playermodels")

end

function GM:SplashScreen()

	if !IsValid(spb_SplashScreenF) and !engine.IsPlayingDemo() then

		spb_SplashScreenF = vgui.Create("DFrame")
		spb_SplashScreenF:ParentToHUD()
		spb_SplashScreenF:SetPos(0, 0)
		spb_SplashScreenF:SetSize(ScrW(), ScrH())
		spb_SplashScreenF:SetTitle("")
		spb_SplashScreenF:SetVisible(true)
		spb_SplashScreenF:SetDraggable(false)
		spb_SplashScreenF:ShowCloseButton(false)
		spb_SplashScreenF:SetScreenLock(true)
		spb_SplashScreenF.Paint = function(self, w, h) end
		spb_SplashScreenF:MakePopup()

		local closebtn = vgui.Create("DButton", spb_SplashScreenF)
		closebtn:SetText("You're currently on the gamemode's splash screen window that shows controls for new players.\nIf it doesn't load, please click here to force close and skip it for now.")
		closebtn:SetPos(0, 0)
		closebtn:SetSize(ScrW(), 32)
		closebtn:SetColor(Color(255, 255, 255))
		closebtn.DoClick = function()
			surface.PlaySound("garrysmod/ui_return.wav")
			spb_SplashScreenF:Close()
		end
		closebtn.Paint = function(self, w, h)
			if self.nanim then
				draw.RoundedBox(4, 0, 0, w, h, Color(0, 0, 0, math.Clamp(CurTime() - self.nanim, 0, 255)))
			else
				draw.RoundedBox(4, 0, 0, w, h, Color(0, 0, 0, 200))
			end
		end
		closebtn:SetZPos(32767)

		spb_SplashScreenF.SplashScreen = vgui.Create("DHTML", spb_SplashScreenF)
		spb_SplashScreenF.SplashScreen:SetPos(0, 0)
		spb_SplashScreenF.SplashScreen:SetSize(ScrW(), ScrH())
		spb_SplashScreenF.SplashScreen:OpenURL("https://assets.xperidia.com/superpedobear/splash_screen.html")

		spb_SplashScreenF.SplashScreen:AddFunction("splashscreen", "loaded", function()

			GAMEMODE:SaveStats()

			surface.PlaySound("ambient/water/drip" .. math.random(1, 4) .. ".wav")

			if IsValid(closebtn) then
				closebtn:SetSize(ScrW(), 16)
				closebtn:SetText("Click here if you're somehow stuck in the splash screen.")
				closebtn:SetColor(Color(255, 255, 255, 0))
				closebtn.nanim = CurTime()
				closebtn.Think = function(self)
					self:SetColor(Color(255, 255, 255, math.Clamp(CurTime() - self.nanim, 0, 255)))
				end
			end

			GAMEMODE:Log("The splash screen has loaded properly!")

		end)

		spb_SplashScreenF.SplashScreen:AddFunction("splashscreen", "close", function()
			surface.PlaySound("garrysmod/ui_click.wav")
			spb_SplashScreenF:Close()
		end)

		spb_SplashScreenF.SplashScreen:AddFunction("splashscreen", "openurl", function(url)
			surface.PlaySound("garrysmod/ui_click.wav")
			gui.OpenURL(url)
		end)

		local btxt = ""
		for k, v in pairs(binds()) do
			btxt = btxt .. "<tr><td class='leftside'>" .. v[1] .. "</td><td>" .. v[2] .. "</td><td>" .. v[3] .. "</td></tr>"
		end
		spb_SplashScreenF.SplashScreen:Call('$("#controls").append("<h2><u>Controls</u></h2><table>' .. "<thead><th class='leftside'>KEY</th><th>Action</th><th>Options bind name</th></tr>" .. btxt .. '</table>");')

	elseif IsValid(spb_SplashScreenF) then
		spb_SplashScreenF:Close()
	end

end

function GM:JukeboxMenu()

	if !IsValid(spb_Jukebox) and !engine.IsPlayingDemo() then

		spb_Jukebox = vgui.Create("DFrame")
		spb_Jukebox:SetSize(ScrW() * 0.90, ScrH() * 0.40)
		local w, h = spb_Jukebox:GetSize()
		spb_Jukebox:SetPos(ScrW() / 2 - w / 2, ScrH() / 2 - h / 2)
		spb_Jukebox:SetTitle("Super Pedobear Jukebox")
		spb_Jukebox:SetVisible(true)
		spb_Jukebox:SetDraggable(true)
		spb_Jukebox:ShowCloseButton(true)
		spb_Jukebox:SetScreenLock(true)
		--spb_Jukebox:SetSizable(true)
		spb_Jukebox.Paint = function(self, w, h)
			draw.RoundedBox(4, 0, 0, w, h, Color(0, 0, 0, 128))
		end
		spb_Jukebox:MakePopup()
		spb_Jukebox:SetKeyboardInputEnabled(false)
		local mw = w / 3 - 20


		spb_Jukebox.MusicL = vgui.Create("DPanel", spb_Jukebox)
		spb_Jukebox.MusicL:SetPos(10, 30)
		spb_Jukebox.MusicL:SetSize(mw, h - 40)

		spb_Jukebox.MusicL.lbl = vgui.Create("DLabel", spb_Jukebox.MusicL)
		spb_Jukebox.MusicL.lbl:SetText("Music list")
		spb_Jukebox.MusicL.lbl:SetPos(5, 3)
		spb_Jukebox.MusicL.lbl:SetSize(mw, 15)
		spb_Jukebox.MusicL.lbl:SetDark(1)

		spb_Jukebox.MusicL.List = vgui.Create("DListView", spb_Jukebox.MusicL)
		spb_Jukebox.MusicL.List:SetPos(0, 20)
		spb_Jukebox.MusicL.List:SetSize(mw, h - 60)
		spb_Jukebox.MusicL.List:SetMultiSelect(false)
		local name = spb_Jukebox.MusicL.List:AddColumn("Music")
		name:SetMinWidth(150)
		local mp = spb_Jukebox.MusicL.List:AddColumn("Pack")
		mp:SetMinWidth(30)
		local loc = spb_Jukebox.MusicL.List:AddColumn("Local")
		loc:SetMinWidth(30)
		loc:SetMaxWidth(30)
		local serv = spb_Jukebox.MusicL.List:AddColumn("Serv")
		serv:SetMinWidth(30)
		serv:SetMaxWidth(30)

		local pre = GAMEMODE.Vars.Round.PreStart
		local function CreateMusicList(pre)

			spb_Jukebox.MusicL.List:Clear()
			spb_Jukebox.MusicL.lbl:SetText("Music list" .. Either(pre, " (Pre Round Musics)", ""))

			local localmusics = Either(pre, GAMEMODE.LocalMusics.premusics, GAMEMODE.LocalMusics.musics)

			local musiclist = {}

			for k, v in pairs(localmusics) do
				musiclist[v[1]] = { v[2], v[3], file.Exists("sound/superpedobear/" .. Either(pre, "premusics", "musics") .. "/" .. v[1], "GAME"), nil }
			end

			if Either(pre, GAMEMODE.Musics.premusics, GAMEMODE.Musics.musics) then
				for k, v in pairs(Either(pre, GAMEMODE.Musics.premusics, GAMEMODE.Musics.musics)) do
					if musiclist[v[1]] then
						musiclist[v[1]] = { v[2], v[3], musiclist[v[1]][3], true }
					else
						musiclist[v[1]] = { v[2], v[3], file.Exists("sound/superpedobear/" .. Either(pre, "premusics", "musics") .. "/" .. v[1], "GAME"), true }
					end
				end
			end

			for k, v in SortedPairs(musiclist) do
				local line = spb_Jukebox.MusicL.List:AddLine(v[1] or GAMEMODE:PrettyMusicName(k), v[2], Either(string.match(k, "://"), "URL", Either(v[3], "✓", "❌")), Either(v[4], "✓", "❌"))
				line.music = "sound/superpedobear/" .. Either(pre, "premusics", "musics") .. "/" .. k
			end

			function spb_Jukebox.MusicL.List:DoDoubleClick(lineID, line)
				GAMEMODE:Music(line.music, pre)
			end

		end
		CreateMusicList(pre)

		local switchbtn = vgui.Create("DButton", spb_Jukebox.MusicL)
		switchbtn:SetText("Switch to " .. Either(pre, "Round", "Pre round"))
		switchbtn:SetPos(mw - 105, 0)
		switchbtn:SetSize(105, 20)
		switchbtn.DoClick = function()
			pre = !pre
			switchbtn:SetText("Switch to " .. Either(pre, "Round", "Pre round"))
			CreateMusicList(pre)
		end


		local queue = {}
		spb_Jukebox.ServerQueue = vgui.Create("DPanel", spb_Jukebox)
		spb_Jukebox.ServerQueue:SetPos(w / 3 + 10, 30)
		spb_Jukebox.ServerQueue:SetSize(mw, h - 40)
		spb_Jukebox.ServerQueue.Think = function(self)
			if GAMEMODE.Vars.MusicQueue and queue != GAMEMODE.Vars.MusicQueue then
				queue = GAMEMODE.Vars.MusicQueue
				spb_Jukebox.ServerQueue.List.CreateQueueList()
			end
		end

		spb_Jukebox.ServerQueue.lbl = vgui.Create("DLabel", spb_Jukebox.ServerQueue)
		spb_Jukebox.ServerQueue.lbl:SetText("Jukebox (server queue)")
		spb_Jukebox.ServerQueue.lbl:SetPos(5, 3)
		spb_Jukebox.ServerQueue.lbl:SetSize(289, 15)
		spb_Jukebox.ServerQueue.lbl:SetDark(1)

		spb_Jukebox.ServerQueue.List = vgui.Create("DListView", spb_Jukebox.ServerQueue)
		spb_Jukebox.ServerQueue.List:SetPos(0, 20)
		spb_Jukebox.ServerQueue.List:SetSize(mw, h - 80)
		spb_Jukebox.ServerQueue.List:SetMultiSelect(false)
		local name = spb_Jukebox.ServerQueue.List:AddColumn("Music")
		name:SetMinWidth(150)
		local who = spb_Jukebox.ServerQueue.List:AddColumn("Suggested by")
		who:SetMinWidth(100)
		local votes = spb_Jukebox.ServerQueue.List:AddColumn("Votes")
		votes:SetMinWidth(40)
		votes:SetMaxWidth(40)

		function spb_Jukebox.ServerQueue.List.CreateQueueList()
			spb_Jukebox.ServerQueue.List:Clear()
			for k, v in pairs(queue) do
				local line = spb_Jukebox.ServerQueue.List:AddLine(v.music, k:Nick(), #v.votes)
				line.owner = k
			end
			function spb_Jukebox.ServerQueue.List:DoDoubleClick(lineID, line)
				net.Start("spb_MusicQueueVote")
					net.WriteEntity(line.owner)
				net.SendToServer()
			end
		end

		local placeholder = "Enter a music path or URL (MP3, MP2, MP1, OGG, WAV, AIFF)"
		local jukebox_input_enabled = spb_jukebox_enable_input:GetBool()
		spb_Jukebox.ServerQueue.add2queue = vgui.Create("DTextEntry", spb_Jukebox.ServerQueue)
		spb_Jukebox.ServerQueue.add2queue:SetPos(0, h - 60)
		spb_Jukebox.ServerQueue.add2queue:SetSize(mw, 20)
		spb_Jukebox.ServerQueue.add2queue:SetText(placeholder)
		spb_Jukebox.ServerQueue.add2queue.OnMousePressed = function(self, keycode)
			if jukebox_input_enabled and keycode == MOUSE_FIRST and !self:IsEditing() then
				spb_Jukebox:SetKeyboardInputEnabled(true)
				if self:GetValue() == placeholder then
					self:SetText("")
				end
			end
		end
		spb_Jukebox.ServerQueue.add2queue.OnEnter = function(self)
			net.Start("spb_MusicAddToQueue")
				net.WriteString(self:GetValue())
			net.SendToServer()
			self:SetText(placeholder)
		end
		spb_Jukebox.ServerQueue.add2queue.OnLoseFocus = function(self)
			spb_Jukebox:SetKeyboardInputEnabled(false)
		end

		if !jukebox_input_enabled then
			spb_Jukebox.ServerQueue.add2queue:SetText("Music input has been disabled by the server.")
			spb_Jukebox.ServerQueue.add2queue:SetDisabled(true)
		end


		spb_Jukebox.MusicCFG = vgui.Create("DPanel", spb_Jukebox)
		spb_Jukebox.MusicCFG:SetPos(w / 3 * 2 + 10, 30)
		spb_Jukebox.MusicCFG:SetSize(mw, h - 40)

		local mcfgw, mcfgh = spb_Jukebox.MusicCFG:GetSize()

		local musicmenulbl = vgui.Create("DLabel", spb_Jukebox.MusicCFG)
		musicmenulbl:SetText("Music configuration")
		musicmenulbl:SetPos(8, 5)
		musicmenulbl:SetDark(1)
		musicmenulbl:SizeToContents()

		local enablemusic = vgui.Create("DCheckBoxLabel", spb_Jukebox.MusicCFG)
		enablemusic:SetText("Enable music")
		enablemusic:SetPos(10, 30)
		enablemusic:SetDark(1)
		enablemusic:SetConVar("spb_cl_music_enable")
		enablemusic:SetValue(GetConVar("spb_cl_music_enable"):GetBool())
		enablemusic:SizeToContents()

		local allowexternal = vgui.Create("DCheckBoxLabel", spb_Jukebox.MusicCFG)
		allowexternal:SetText("Allow external musics (Loaded from url)")
		allowexternal:SetPos(10, 50)
		allowexternal:SetDark(1)
		allowexternal:SetConVar("spb_cl_music_allowexternal")
		allowexternal:SetValue(GetConVar("spb_cl_music_allowexternal"):GetBool())
		allowexternal:SizeToContents()

		local visualizer = vgui.Create("DCheckBoxLabel", spb_Jukebox.MusicCFG)
		visualizer:SetText("Enable visualizer (Downgrade performance)")
		visualizer:SetPos(10, 70)
		visualizer:SetDark(1)
		visualizer:SetConVar("spb_cl_music_visualizer")
		visualizer:SetValue(GetConVar("spb_cl_music_visualizer"):GetBool())
		visualizer:SizeToContents()

		local vollbl = vgui.Create("DLabel", spb_Jukebox.MusicCFG)
		vollbl:SetText("Volume")
		vollbl:SetPos(mw / 2 - 40, mcfgh - 50)
		vollbl:SetDark(1)
		vollbl:SizeToContents()

		local vol = GetConVar("spb_cl_music_volume")
		local musivol = vgui.Create("Slider", spb_Jukebox.MusicCFG)
		musivol:SetPos(0, mcfgh - 40)
		musivol:SetSize(mw, 40)
		musivol:SetValue(vol:GetFloat())
		musivol.OnValueChanged = function(panel, value)
			vol:SetFloat(value)
		end

	elseif IsValid(spb_Jukebox) then
		spb_Jukebox:Close()
	end

end

function GM:DebugWindow()

	local debugwindow = vgui.Create("DFrame")
	local w, h = ScrW() * .2, ScrH() * .2
	debugwindow:SetPos(ScrW() / 2 - w / 2, ScrH() / 2 - h / 2)
	debugwindow:SetSize(w, h)
	debugwindow:SetMinWidth(280)
	debugwindow:SetMinHeight(24)
	debugwindow:SetTitle("Super Pedobear Debug Window")
	debugwindow:SetVisible(true)
	debugwindow:SetDraggable(true)
	debugwindow:ShowCloseButton(true)
	debugwindow:SetScreenLock(true)
	debugwindow:SetSizable(true)
	debugwindow.btnMaxim:SetDisabled(false)
	debugwindow.btnMaxim.DoClick = function(btn) btnMaximDoClick(btn) end
	debugwindow.btnMinim:SetDisabled(false)
	debugwindow.btnMinim.DoClick = function(btn) btnMinimDoClick(btn) end
	debugwindow.Paint = function(self, w, h)
		draw.RoundedBox(4, 0, 0, w, h, Color(0, 0, 0, 128))
	end
	debugwindow:MakePopup()
	debugwindow:SetKeyboardInputEnabled(false)

	debugwindow.panel = vgui.Create("DPanel", debugwindow)
	debugwindow.panel:Dock(FILL)
	debugwindow.panel.text = vgui.Create("RichText", debugwindow.panel)
	debugwindow.panel.text:Dock(FILL)
	function debugwindow.panel.text:PerformLayout()
		self:SetFontInternal("DermaDefault")
	end

	local function writedebuginfo()

		local ostime = os.time()
		local osclock = os.clock()
		local systime = SysTime()

		debugwindow.panel.text:SetText("")
		debugwindow.panel.text:InsertColorChange(0, 0, 0, 255)

		local function linebreak() debugwindow.panel.text:AppendText("\n") end
		local function autoappend(txt, var)
			if txt then
				debugwindow.panel.text:InsertColorChange(0, 0, 0, 255)
				debugwindow.panel.text:AppendText(txt)
				debugwindow.panel.text:AppendText(": ")
			end
			debugwindow.panel.text:InsertColorChange(128, 0, 128, 255)
			if isbool(var) and var then
				debugwindow.panel.text:AppendText("Yes")
			elseif isbool(var) and !var then
				debugwindow.panel.text:AppendText("No")
			else
				debugwindow.panel.text:AppendText(var or nil)
			end
			debugwindow.panel.text:InsertColorChange(0, 0, 0, 255)
			debugwindow.panel.text:AppendText("\n")
		end

		autoappend("System time", ostime)
		autoappend("System time (formatted)", os.date("%H:%M:%S - %d/%m/%Y" , ostime))
		autoappend("Country code", system.GetCountry())
		autoappend("Game clock time", osclock)
		autoappend("Game time", systime)
		autoappend("Game started since", os.date("%H:%M:%S - %d/%m/%Y" , ostime - systime))
		linebreak()

		autoappend("Windows", system.IsWindows())
		autoappend("OSX", system.IsOSX())
		autoappend("Linux", system.IsLinux())
		linebreak()

		autoappend("Garry's Mod version", VERSIONSTR)
		autoappend("Garry's Mod branch", BRANCH)
		autoappend("Lua version", _VERSION)
		autoappend("LuaJIT version", jit.version)
		autoappend("LuaJIT enabled", jit.status())
		autoappend("gmod_language", GetConVar("gmod_language"):GetString())
		linebreak()

		autoappend("Server ticks", engine.TickCount())
		autoappend("Gametick interval", engine.TickInterval())
		autoappend("Servertick", 1 / engine.TickInterval())
		autoappend("Map", game.GetMap())
		autoappend("Dedicated", game.IsDedicated())
		autoappend("IP", game.GetIPAddress())
		autoappend("sv_allowcslua", GetConVar("sv_allowcslua"):GetBool())
		linebreak()

		autoappend("Gamemode id (GAMEMODE_NAME)", GAMEMODE_NAME)
		autoappend("Gamemode id (engine.ActiveGamemode())", engine.ActiveGamemode())
		autoappend("Gamemode name", GAMEMODE.Name)
		autoappend("Gamemode version", tostring(GAMEMODE.Version))
		autoappend("Gamemode version date", GAMEMODE.VersionDate)
		linebreak()

		debugwindow.panel.text:AppendText("Mounted Source games:\n")
		for k, v in pairs(engine.GetGames()) do
			if v.mounted then
				debugwindow.panel.text:InsertColorChange(29, 193, 228, 255)
				debugwindow.panel.text:AppendText("▶ ")
				debugwindow.panel.text:InsertColorChange(0, 0, 0, 255)
				debugwindow.panel.text:AppendText(Either(v.title, v.title, "unknown name"))
				debugwindow.panel.text:AppendText(" ")
				debugwindow.panel.text:InsertColorChange(128, 0, 128, 255)
				debugwindow.panel.text:AppendText(Either(v.depot, v.depot, "unknown depot"))
				debugwindow.panel.text:AppendText(" ")
				debugwindow.panel.text:InsertColorChange(128, 128, 128, 255)
				debugwindow.panel.text:AppendText(Either(v.folder, v.folder, ""))
				debugwindow.panel.text:AppendText("\n")
				debugwindow.panel.text:InsertColorChange(0, 0, 0, 255)
			end
		end
		linebreak()

		if game.GetIPAddress() == "loopback" then

			debugwindow.panel.text:AppendText("Gamemodes:\n")
			for k, v in pairs(engine.GetGamemodes()) do
				debugwindow.panel.text:InsertColorChange(29, 193, 228, 255)
				debugwindow.panel.text:AppendText("▶ ")
				debugwindow.panel.text:InsertColorChange(0, 0, 0, 255)
				debugwindow.panel.text:AppendText(Either(v.title, v.title, "unknown name"))
				debugwindow.panel.text:AppendText(" ")
				debugwindow.panel.text:InsertColorChange(128, 0, 128, 255)
				debugwindow.panel.text:AppendText(Either(v.workshopid, v.workshopid, "unknown workshop id"))
				debugwindow.panel.text:AppendText(" ")
				debugwindow.panel.text:InsertColorChange(128, 128, 128, 255)
				debugwindow.panel.text:AppendText(Either(v.name, v.name, "unknown name"))
				debugwindow.panel.text:AppendText("\n")
				debugwindow.panel.text:InsertColorChange(0, 0, 0, 255)
			end
			linebreak()

			debugwindow.panel.text:AppendText("Mounted addons:\n")
			for k, v in pairs(engine.GetAddons()) do
				if v.mounted then
					debugwindow.panel.text:InsertColorChange(29, 193, 228, 255)
					debugwindow.panel.text:AppendText("▶ ")
					debugwindow.panel.text:InsertColorChange(0, 0, 0, 255)
					debugwindow.panel.text:AppendText(Either(v.title, v.title, "unknown name"))
					debugwindow.panel.text:AppendText(" ")
					debugwindow.panel.text:InsertColorChange(128, 0, 128, 255)
					debugwindow.panel.text:AppendText(Either(v.wsid, v.wsid, "unknown id"))
					debugwindow.panel.text:AppendText(" ")
					debugwindow.panel.text:InsertColorChange(128, 128, 128, 255)
					debugwindow.panel.text:AppendText(Either(v.file, "\"" .. v.file .. "\"", "unknown path"))
					debugwindow.panel.text:AppendText("\n")
					debugwindow.panel.text:InsertColorChange(0, 0, 0, 255)
				end
			end
			linebreak()

		end

	end

	writedebuginfo()

end
