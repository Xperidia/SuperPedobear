--[[---------------------------------------------------------
		Super Pedobear Gamemode for Garry's Mod
				by VictorienXP (2016)
-----------------------------------------------------------]]

local function binds()
	return {
		{GAMEMODE:CheckBind("gm_showhelp"), "Gamemode menu", "Show help"},
		{GAMEMODE:CheckBind("gm_showteam"), "Change team", "Team menu"},
		{GAMEMODE:CheckBind("gm_showspare1"), "Taunt menu", "Spare 1"},
		{GAMEMODE:CheckBind("gm_showspare2"), "Jukebox/music menu", "Spare 2"},
		{GAMEMODE:CheckBind("+reload"), "Use Power-UP", "Reload weapon"},
		{GAMEMODE:CheckBind("+menu"), "Shop", "Show Menu"},
		{GAMEMODE:CheckBind("+menu_context"), "Toggle thirdperson", "Show Context Menu"},
		{GAMEMODE:CheckBind("gmod_undo"), "Drop Power-UP", "Undo"},
		{GAMEMODE:CheckBind("phys_swap"), "Enhanced PlayerModel Selector", "Gravity Gun"},
		{"1-9", "Quick taunt and quick buy", ""},
		{"0", "Random taunt", ""},
		{GAMEMODE:CheckBind("+forward"), "Move forward", "Move forward"},
		{GAMEMODE:CheckBind("+moveleft"), "Move left", "Move left (stafe)"},
		{GAMEMODE:CheckBind("+moveright"), "Move right", "Move right (strafe)"},
		{GAMEMODE:CheckBind("+back"), "Move back", "Move back"},
		{GAMEMODE:CheckBind("+duck"), "Crouch", "Duck"},
		{GAMEMODE:CheckBind("+jump"), "Jump", "Jump"},
		{GAMEMODE:CheckBind("+speed"), "Sprint", "Sprint (Move Quickly)"}
	}
end

function GM:Menu()

	if !IsValid(spb_MenuF) and !engine.IsPlayingDemo() then

		spb_MenuF = vgui.Create("DFrame")
		spb_MenuF:SetPos(ScrW() / 2 - 320, ScrH() / 2 - 240)
		spb_MenuF:SetSize(640, 480)
		spb_MenuF:SetTitle(GAMEMODE.Name .. " main menu")
		spb_MenuF:SetVisible(true)
		spb_MenuF:SetDraggable(true)
		spb_MenuF:ShowCloseButton(true)
		spb_MenuF:SetScreenLock(true)
		spb_MenuF.Paint = function(self, w, h)
			draw.RoundedBox(4, 0, 0, w, h, Color(0, 0, 0, 128))
		end
		spb_MenuF.Think = function(self)
			if xpsc_anim and xpsc_anim:Active() then xpsc_anim:Run() end
			local mousex = math.Clamp(gui.MouseX(), 1, ScrW() - 1)
			local mousey = math.Clamp(gui.MouseY(), 1, ScrH() - 1)
			if self.Dragging then
				local x = mousex - self.Dragging[1]
				local y = mousey - self.Dragging[2]
				if self:GetScreenLock() then
					x = math.Clamp(x, 0, ScrW() - self:GetWide())
					y = math.Clamp(y, 0, ScrH() - self:GetTall())
				end
				self:SetPos(x, y)
			end
			if self.Hovered and mousey < (self.y + 24) then
				self:SetCursor("sizeall")
				return
			end
			self:SetCursor("arrow")
			if self.y < 0 then
				self:SetPos(self.x, 0)
			end
		end
		spb_MenuF:MakePopup()
		spb_MenuF:SetKeyboardInputEnabled(false)

		spb_MenuF.one = vgui.Create("DPanel")
		spb_MenuF.one:SetParent(spb_MenuF)
		spb_MenuF.one:SetPos(10, 30)
		spb_MenuF.one:SetSize(305, 215)

		spb_MenuF.one.text = vgui.Create("RichText", spb_MenuF.one)
		spb_MenuF.one.text:Dock(FILL)
		spb_MenuF.one.text:InsertColorChange(0, 0, 0, 255)
		function spb_MenuF.one.text:PerformLayout()
			self:SetFontInternal("DermaDefault")
		end
		spb_MenuF.one.text:AppendText("\t    You're playing Super Pedobear V" .. (GAMEMODE.Version or "?") .. " (" .. (GAMEMODE.VersionDate or "?") .. ")\n")
		if GAMEMODE:SeasonalEventStr() != "" then
			spb_MenuF.one.text:AppendText("\t\t\t    " .. GAMEMODE:SeasonalEventStr() .. "\n\n")
		else
			spb_MenuF.one.text:AppendText("\n")
		end
		spb_MenuF.one.text:AppendText("Gamemode made by VictorienXP, with arts from Pho3 and Wubsy...\n\n")

		spb_MenuF.one.text:InsertClickableTextStart("SplashScreen")
		spb_MenuF.one.text:AppendText("Click here to open the Splash Screen")
		spb_MenuF.one.text:InsertClickableTextEnd()
		spb_MenuF.one.text:AppendText("\n")
		spb_MenuF.one.text:InsertClickableTextStart("MapVote")
		spb_MenuF.one.text:AppendText("Click here for the map vote (not yet implemeted)")
		spb_MenuF.one.text:InsertClickableTextEnd()
		spb_MenuF.one.text:AppendText("\n")
		spb_MenuF.one.text:InsertClickableTextStart("Debug")
		spb_MenuF.one.text:AppendText("Click here to open the debug window")
		spb_MenuF.one.text:InsertClickableTextEnd()
		spb_MenuF.one.text:AppendText("\n")
		spb_MenuF.one.text:InsertClickableTextStart("Workshop")
		spb_MenuF.one.text:AppendText("Click here to open the Workshop page")
		spb_MenuF.one.text:InsertClickableTextEnd()
		spb_MenuF.one.text:AppendText("\n")
		spb_MenuF.one.text:InsertClickableTextStart("Workshop_changelog")
		spb_MenuF.one.text:AppendText("Click here to open the Workshop Change Notes")
		spb_MenuF.one.text:InsertClickableTextEnd()
		spb_MenuF.one.text:AppendText("\n")
		spb_MenuF.one.text:InsertClickableTextStart("GitHub")
		spb_MenuF.one.text:AppendText("Click here to open the GitHub repo")
		spb_MenuF.one.text:InsertClickableTextEnd()
		spb_MenuF.one.text:AppendText("\n")
		spb_MenuF.one.text:InsertClickableTextStart("GitHub_releases")
		spb_MenuF.one.text:AppendText("Click here to open the GitHub releases")
		spb_MenuF.one.text:InsertClickableTextEnd()
		spb_MenuF.one.text:AppendText("\n")
		spb_MenuF.one.text:InsertClickableTextStart("Discord")
		spb_MenuF.one.text:AppendText("Click here to join the Xperidia's Discord server")
		spb_MenuF.one.text:InsertClickableTextEnd()
		spb_MenuF.one.text:AppendText("\n\n")

		function spb_MenuF.one.text:ActionSignal(signalName, signalValue)
			if signalName == "TextClicked" then
				if signalValue == "SplashScreen" then
					GAMEMODE:SplashScreen()
					spb_MenuF:Close()
				elseif signalValue == "MapVote" then
					GAMEMODE:MapVote()
					spb_MenuF:Close()
				elseif signalValue == "Debug" then
					GAMEMODE:DebugWindow()
					spb_MenuF:Close()
				elseif signalValue == "Workshop" then
					gui.OpenURL("https://" .. GAMEMODE.Website)
					spb_MenuF:Close()
				elseif signalValue == "Workshop_changelog" then
					gui.OpenURL("https://steamcommunity.com/sharedfiles/filedetails/changelog/628449407")
					spb_MenuF:Close()
				elseif signalValue == "GitHub" then
					gui.OpenURL("https://github.com/Xperidia/SuperPedobear")
					spb_MenuF:Close()
				elseif signalValue == "GitHub_releases" then
					gui.OpenURL("https://github.com/Xperidia/SuperPedobear/releases")
					spb_MenuF:Close()
				elseif signalValue == "Discord" then
					gui.OpenURL("https://discordapp.com/invite/jtUtYDa")
					spb_MenuF:Close()
				end
			end
		end


		spb_MenuF.config = vgui.Create("DPanel")
		spb_MenuF.config:SetParent(spb_MenuF)
		spb_MenuF.config:SetPos(325, 30)
		spb_MenuF.config:SetSize(305, 215)

		local configlbl = vgui.Create("DLabel")
		configlbl:SetParent(spb_MenuF.config)
		configlbl:SetText("Personal configuration")
		configlbl:SetPos(10, 5)
		configlbl:SetDark(1)
		configlbl:SizeToContents()

		local disabletc = vgui.Create("DCheckBoxLabel")
		disabletc:SetParent(spb_MenuF.config)
		disabletc:SetText("Don't close the taunt menu after taunting")
		disabletc:SetPos(15, 30)
		disabletc:SetDark(1)
		disabletc:SetConVar("spb_cl_disabletauntmenuclose")
		disabletc:SetValue(GetConVar("spb_cl_disabletauntmenuclose"):GetBool())
		disabletc:SizeToContents()

		local hud = vgui.Create("DCheckBoxLabel")
		hud:SetParent(spb_MenuF.config)
		hud:SetText("Draw HUD (Caution! This is a Garry's Mod convar)")
		hud:SetPos(15, 50)
		hud:SetDark(1)
		hud:SetConVar("cl_drawhud")
		hud:SetValue(GetConVar("cl_drawhud"):GetBool())
		hud:SizeToContents()

		local disablehalo = vgui.Create("DCheckBoxLabel")
		disablehalo:SetParent(spb_MenuF.config)
		disablehalo:SetText("Disable halos (Improve performance)")
		disablehalo:SetPos(15, 70)
		disablehalo:SetDark(1)
		disablehalo:SetConVar("spb_cl_disablehalos")
		disablehalo:SetValue(GetConVar("spb_cl_disablehalos"):GetBool())
		disablehalo:SizeToContents()

		local disablehalo = vgui.Create("DCheckBoxLabel")
		disablehalo:SetParent(spb_MenuF.config)
		disablehalo:SetText("Hide all tips")
		disablehalo:SetPos(15, 90)
		disablehalo:SetDark(1)
		disablehalo:SetConVar("spb_cl_hide_tips")
		disablehalo:SetValue(GetConVar("spb_cl_hide_tips"):GetBool())
		disablehalo:SizeToContents()

		local quickstuff = vgui.Create("DCheckBoxLabel")
		quickstuff:SetParent(spb_MenuF.config)
		quickstuff:SetText("Enable quick taunt and quick buy")
		quickstuff:SetPos(15, 110)
		quickstuff:SetDark(1)
		quickstuff:SetConVar("spb_cl_quickstuff_enable")
		quickstuff:SetValue(GetConVar("spb_cl_quickstuff_enable"):GetBool())
		quickstuff:SizeToContents()

		local quickstuffnumpad = vgui.Create("DCheckBoxLabel")
		quickstuffnumpad:SetParent(spb_MenuF.config)
		quickstuffnumpad:SetText("Use numpad as well for quick stuff")
		quickstuffnumpad:SetPos(15, 130)
		quickstuffnumpad:SetDark(1)
		quickstuffnumpad:SetConVar("spb_cl_quickstuff_numpad")
		quickstuffnumpad:SetValue(GetConVar("spb_cl_quickstuff_numpad"):GetBool())
		quickstuffnumpad:SizeToContents()

		local hudoffset_w = vgui.Create("DNumSlider", spb_MenuF.config)
		hudoffset_w:SetPos(15, 160)
		hudoffset_w:SetSize(300, 16)
		hudoffset_w:SetText("Horizontal HUD Offset")
		hudoffset_w:SetMin(0)
		hudoffset_w:SetMax(100)
		hudoffset_w:SetDecimals(0)
		hudoffset_w:SetDark(1)
		hudoffset_w:SetConVar("spb_cl_hud_offset_w")

		local hudoffset_h = vgui.Create("DNumSlider", spb_MenuF.config)
		hudoffset_h:SetPos(15, 190)
		hudoffset_h:SetSize(300, 16)
		hudoffset_h:SetText("Vertical HUD Offset")
		hudoffset_h:SetMin(0)
		hudoffset_h:SetMax(100)
		hudoffset_h:SetDecimals(0)
		hudoffset_h:SetDark(1)
		hudoffset_h:SetConVar("spb_cl_hud_offset_h")


		spb_MenuF.Controls = vgui.Create("DPanel")
		spb_MenuF.Controls:SetParent(spb_MenuF)
		spb_MenuF.Controls:SetPos(10, 255)
		spb_MenuF.Controls:SetSize(305, 215)

		spb_MenuF.Controls.lbl = vgui.Create("DLabel")
		spb_MenuF.Controls.lbl:SetParent(spb_MenuF.Controls)
		spb_MenuF.Controls.lbl:SetText("Controls")
		spb_MenuF.Controls.lbl:SetPos(10, 5)
		spb_MenuF.Controls.lbl:SetSize(289, 10)
		spb_MenuF.Controls.lbl:SetDark(1)

		spb_MenuF.Controls.List = vgui.Create("DListView", spb_MenuF.Controls)
		spb_MenuF.Controls.List:SetPos(0, 20)
		spb_MenuF.Controls.List:SetSize(305, 195)
		spb_MenuF.Controls.List:SetMultiSelect(false)
		local key = spb_MenuF.Controls.List:AddColumn("KEY")
		key:SetMinWidth(40)
		key:SetMinWidth(60)
		local action = spb_MenuF.Controls.List:AddColumn("Action")
		action:SetMinWidth(100)
		local bindname = spb_MenuF.Controls.List:AddColumn("Options bind name")
		bindname:SetMinWidth(100)

		for k, v in pairs(binds()) do
			spb_MenuF.Controls.List:AddLine(v[1], v[2], v[3])
		end


		spb_MenuF.AdminCFG = vgui.Create("DPanel")
		spb_MenuF.AdminCFG:SetParent(spb_MenuF)
		spb_MenuF.AdminCFG:SetPos(325, 255)
		spb_MenuF.AdminCFG:SetSize(305, 215)

		local adminmenulbl = vgui.Create("DLabel", spb_MenuF.AdminCFG)
		adminmenulbl:SetText("Admin configuration")
		adminmenulbl:SetPos(10, 5)
		adminmenulbl:SetDark(1)
		adminmenulbl:SizeToContents()

		local eh = 0
		local function docheckbox(str, cvar)
			local checkbox = vgui.Create("DCheckBoxLabel")
			checkbox:SetParent(spb_MenuF.AdminCFG)
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
		docheckbox("Give some weapons on spawn (You shouldn't use this)", "spb_weapons")
		docheckbox("Enable jukebox input", "spb_jukebox_enable_input")


	elseif IsValid(spb_MenuF) then
		spb_MenuF:Close()
	end

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
		spb_SplashScreenF.Paint = function(self, w, h)
		end
		spb_SplashScreenF:MakePopup()
		--spb_SplashScreenF:SetKeyboardInputEnabled(false)
		--spb_SplashScreenF:SetMouseInputEnabled(false)

		spb_SplashScreenF.SplashScreen = vgui.Create("DHTML")
		spb_SplashScreenF.SplashScreen:SetParent(spb_SplashScreenF)
		spb_SplashScreenF.SplashScreen:SetPos(0, 0)
		spb_SplashScreenF.SplashScreen:SetSize(ScrW(), ScrH())
		spb_SplashScreenF.SplashScreen:SetAllowLua(true)
		spb_SplashScreenF.SplashScreen:OpenURL("https://www.xperidia.com/SuperPedobear/?steamid=" .. LocalPlayer():SteamID64())
		--spb_SplashScreenF.SplashScreen:SetScrollbars(false)

		local btxt = ""
		for k, v in pairs(binds()) do
			btxt = btxt .. "<tr><td class='leftside'>" .. v[1] .. "</td><td>" .. v[2] .. "</td><td>" .. v[3] .. "</td></tr>"
		end
		spb_SplashScreenF.SplashScreen:Call('$("#controls").append("<h2><u>Controls</u></h2><table>' .. "<thead><th class='leftside'>KEY</th><th>Action</th><th>Options bind name</th></tr>" .. btxt .. '</table>");')

		local closebtn = vgui.Create("DButton", spb_SplashScreenF)
		closebtn:SetText("X")
		closebtn:SetPos(ScrW() - 20, 0)
		closebtn:SetSize(20, 20)
		closebtn.DoClick = function()
			spb_SplashScreenF:Close()
		end
		closebtn:SetZPos(32767)

	elseif IsValid(spb_SplashScreenF) then
		spb_SplashScreenF:Close()
	end

end

function GM:HideSplashScreenUntilNextUpdate()
	local tab = {}
	tab.LastVersion = GAMEMODE.Version
	file.Write("superpedobear/info.txt", util.TableToJSON(tab))
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


		spb_Jukebox.MusicL = vgui.Create("DPanel")
		spb_Jukebox.MusicL:SetParent(spb_Jukebox)
		spb_Jukebox.MusicL:SetPos(10, 30)
		spb_Jukebox.MusicL:SetSize(mw, h - 40)

		spb_Jukebox.MusicL.lbl = vgui.Create("DLabel")
		spb_Jukebox.MusicL.lbl:SetParent(spb_Jukebox.MusicL)
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

		local switchbtn = vgui.Create("DButton")
		switchbtn:SetParent(spb_Jukebox.MusicL)
		switchbtn:SetText("Switch to " .. Either(pre, "Round", "Pre round"))
		switchbtn:SetPos(mw - 105, 0)
		switchbtn:SetSize(105, 20)
		switchbtn.DoClick = function()
			pre = !pre
			switchbtn:SetText("Switch to " .. Either(pre, "Round", "Pre round"))
			CreateMusicList(pre)
		end


		local queue = {}
		spb_Jukebox.ServerQueue = vgui.Create("DPanel")
		spb_Jukebox.ServerQueue:SetParent(spb_Jukebox)
		spb_Jukebox.ServerQueue:SetPos(w / 3 + 10, 30)
		spb_Jukebox.ServerQueue:SetSize(mw, h - 40)
		spb_Jukebox.ServerQueue.Think = function(self)
			if GAMEMODE.Vars.MusicQueue and queue != GAMEMODE.Vars.MusicQueue then
				queue = GAMEMODE.Vars.MusicQueue
				spb_Jukebox.ServerQueue.List.CreateQueueList()
			end
		end

		spb_Jukebox.ServerQueue.lbl = vgui.Create("DLabel")
		spb_Jukebox.ServerQueue.lbl:SetParent(spb_Jukebox.ServerQueue)
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

		local placeholder = "Enter a music path or URL (Mostly .mp3)"
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


		spb_Jukebox.MusicCFG = vgui.Create("DPanel")
		spb_Jukebox.MusicCFG:SetParent(spb_Jukebox)
		spb_Jukebox.MusicCFG:SetPos(w / 3 * 2 + 10, 30)
		spb_Jukebox.MusicCFG:SetSize(mw, h - 40)

		local mcfgw, mcfgh = spb_Jukebox.MusicCFG:GetSize()

		local musicmenulbl = vgui.Create("DLabel")
		musicmenulbl:SetParent(spb_Jukebox.MusicCFG)
		musicmenulbl:SetText("Music configuration")
		musicmenulbl:SetPos(8, 5)
		musicmenulbl:SetDark(1)
		musicmenulbl:SizeToContents()

		local enablemusic = vgui.Create("DCheckBoxLabel")
		enablemusic:SetParent(spb_Jukebox.MusicCFG)
		enablemusic:SetText("Enable music")
		enablemusic:SetPos(10, 30)
		enablemusic:SetDark(1)
		enablemusic:SetConVar("spb_cl_music_enable")
		enablemusic:SetValue(GetConVar("spb_cl_music_enable"):GetBool())
		enablemusic:SizeToContents()

		local allowexternal = vgui.Create("DCheckBoxLabel")
		allowexternal:SetParent(spb_Jukebox.MusicCFG)
		allowexternal:SetText("Allow external musics (Loaded from url)")
		allowexternal:SetPos(10, 50)
		allowexternal:SetDark(1)
		allowexternal:SetConVar("spb_cl_music_allowexternal")
		allowexternal:SetValue(GetConVar("spb_cl_music_allowexternal"):GetBool())
		allowexternal:SizeToContents()

		local visualizer = vgui.Create("DCheckBoxLabel")
		visualizer:SetParent(spb_Jukebox.MusicCFG)
		visualizer:SetText("Enable visualizer (Downgrade performance)")
		visualizer:SetPos(10, 70)
		visualizer:SetDark(1)
		visualizer:SetConVar("spb_cl_music_visualizer")
		visualizer:SetValue(GetConVar("spb_cl_music_visualizer"):GetBool())
		visualizer:SizeToContents()

		local vollbl = vgui.Create("DLabel")
		vollbl:SetParent(spb_Jukebox.MusicCFG)
		vollbl:SetText("Volume")
		vollbl:SetPos(mw / 2 - 40, mcfgh - 50)
		vollbl:SetDark(1)
		vollbl:SizeToContents()

		local vol = GetConVar("spb_cl_music_volume")
		local musivol = vgui.Create("Slider")
		musivol:SetParent(spb_Jukebox.MusicCFG)
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

function GM:MapVote()

	GAMEMODE:Notif("Not yet implemented.", NOTIFY_ERROR, 5, true)

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
	debugwindow.btnMaxim.DoClick = function(btn)
		if debugwindow.maxim and !debugwindow.minim then
			debugwindow:SetPos(debugwindow.lastpos_x, debugwindow.lastpos_y)
			debugwindow:SetSize(debugwindow.lastsize_w, debugwindow.lastsize_h)
			debugwindow:SetKeyboardInputEnabled(false)
			debugwindow:SetSizable(true)
			debugwindow:SetDraggable(true)
			debugwindow.maxim = false
		else
			if !debugwindow.minim then
				debugwindow.lastpos_x, debugwindow.lastpos_y = debugwindow:GetPos()
				debugwindow.lastsize_w, debugwindow.lastsize_h = debugwindow:GetSize()
			end
			debugwindow:SetPos(0, 0)
			debugwindow:SetSize(ScrW(), ScrH())
			debugwindow:SetKeyboardInputEnabled(true)
			debugwindow:SetSizable(false)
			debugwindow:SetDraggable(false)
			debugwindow.maxim = true
			debugwindow.minim = false
		end
	end
	debugwindow.btnMinim:SetDisabled(false)
	debugwindow.btnMinim.DoClick = function(btn)
		if debugwindow.minim and debugwindow.maxim then
			debugwindow:SetPos(0, 0)
			debugwindow:SetSize(ScrW(), ScrH())
			debugwindow:SetKeyboardInputEnabled(true)
			debugwindow:SetSizable(false)
			debugwindow:SetDraggable(false)
			debugwindow.minim = false
		elseif debugwindow.minim then
			debugwindow:SetPos(debugwindow.lastpos_x, debugwindow.lastpos_y)
			debugwindow:SetSize(debugwindow.lastsize_w, debugwindow.lastsize_h)
			debugwindow:SetKeyboardInputEnabled(false)
			debugwindow:SetSizable(true)
			debugwindow.minim = false
		else
			if !debugwindow.maxim then
				debugwindow.lastpos_x, debugwindow.lastpos_y = debugwindow:GetPos()
				debugwindow.lastsize_w, debugwindow.lastsize_h = debugwindow:GetSize()
			end
			debugwindow:SetPos(0, ScrH() - 24)
			debugwindow:SetSize(280, 24)
			debugwindow:SetKeyboardInputEnabled(false)
			debugwindow:SetSizable(false)
			debugwindow.minim = true
		end
	end
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
		autoappend("Gamemode version", GAMEMODE.Version)
		autoappend("Gamemode version date", GAMEMODE.VersionDate)
		linebreak()

		debugwindow.panel.text:AppendText("Mounted Source games:\n")
		for k, v in pairs(engine.GetGames()) do
			if v.mounted then
				debugwindow.panel.text:InsertColorChange(29, 193, 228, 255)
				debugwindow.panel.text:AppendText("▶ ")
				debugwindow.panel.text:InsertColorChange(0, 0, 0, 255)
				debugwindow.panel.text:AppendText(Either(v.title, v.title, "unkown name"))
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
				debugwindow.panel.text:AppendText(Either(v.title, v.title, "unkown name"))
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
					debugwindow.panel.text:AppendText(Either(v.title, v.title, "unkown name"))
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
