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
		{"1-9", "Quick taunt", ""},
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
local function changelog()
	return {
		"The shop is now open!",
		"Xperidia's Premium Members gets Power-UPs half the normal price!",
		"You can now drop Power-UPs with " .. GAMEMODE:CheckBind("gmod_undo") .. " (Check out controls)",
		"You can now open the Enhanced PlayerModel Selector with " .. GAMEMODE:CheckBind("phys_swap") .. " (Check out controls)",
		"Quick taunt now works with the numpad too (Can be toggled)",
		"You can now do a random taunt with 0",
		"The welding state has been fixed",
		"The Gamemode menu and the Splash Screen have been updated",
		"The HUD offset thingy has been updated",
		"Added cvar spb_shop_base_price",
		"Added cvar spb_cl_quickstuff_enable",
		"Added cvar spb_cl_quickstuff_numpad",
		"Added cvar spb_cl_hud_offset_w",
		"Added cvar spb_cl_hud_offset_h",
		"Updated cvar spb_rounds",
		"Removed cvar spb_cl_hud_offset",
		"A huge bunch of changes and behind the scenes stuff"
	}
end

function GM:Menu()

	if !IsValid(spb_MenuF) and !engine.IsPlayingDemo() then

		spb_MenuF = vgui.Create("DFrame")
		spb_MenuF:SetPos(ScrW() / 2 - 320, ScrH() / 2 - 240)
		spb_MenuF:SetSize(640, 480)
		spb_MenuF:SetTitle((GAMEMODE.Name or "?") .. " V" .. (GAMEMODE.Version or "?") .. GAMEMODE:SeasonalEventStr() .. " | By " .. (GAMEMODE.Author or "?"))
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

		local onelbl = vgui.Create("DLabel")
		onelbl:SetParent(spb_MenuF.one)
		onelbl:SetText("You're playing " .. (GAMEMODE.Name or "?") .. " V" .. (GAMEMODE.Version or "?"))
		onelbl:SetPos(10, 5)
		onelbl:SetDark(1)
		onelbl:SizeToContents()

		local desclbl = vgui.Create("DLabel")
		desclbl:SetParent(spb_MenuF.one)
		desclbl:SetPos(20, 30)
		desclbl:SetDark(1)
		desclbl:SetText("Gamemode made by VictorienXP with love\nWith arts from Pho3 and Wubsy\n\n\nIf you need help or anything,\nplease go to Xperidia's Discord server discord.gg/jtUtYDa\n\n\nSupport Xperidia for more stuff and updates!\nGet a Premium Rank in Xperidia.com/Premium")
		desclbl:SizeToContents()

		local xpucp = vgui.Create( "DButton" )
		xpucp:SetParent(spb_MenuF.one)
		xpucp:SetText("Xperidia Account")
		xpucp:SetPos(20, 190)
		xpucp:SetSize(125, 20)
		xpucp.DoClick = function()
			gui.OpenURL("https://account.xperidia.com/")
			spb_MenuF:Close()
		end

		local support = vgui.Create("DButton")
		support:SetParent(spb_MenuF.one)
		support:SetText("Xperidia's Discord server")
		support:SetPos(160, 190)
		support:SetSize(125, 20)
		support.DoClick = function()
			gui.OpenURL("https://discordapp.com/invite/jtUtYDa")
			spb_MenuF:Close()
		end

		local SplashScreen = vgui.Create("DButton")
		SplashScreen:SetParent(spb_MenuF.one)
		SplashScreen:SetText("Splash Screen")
		SplashScreen:SetPos(20, 165)
		SplashScreen:SetSize(125, 20)
		SplashScreen.DoClick = function()
			GAMEMODE:SplashScreen()
			spb_MenuF:Close()
		end

		local Workshop = vgui.Create("DButton")
		Workshop:SetParent(spb_MenuF.one)
		Workshop:SetText("Workshop page")
		Workshop:SetPos(160, 165)
		Workshop:SetSize(125, 20)
		Workshop.DoClick = function()
			gui.OpenURL("http://" .. GAMEMODE.Website)
			spb_MenuF:Close()
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

		local ctxt = ""
		for k, v in pairs(changelog()) do
			ctxt = ctxt .. "<tr><td>> " .. v .. "</td></tr>"
		end
		spb_SplashScreenF.SplashScreen:Call('$("#changelog").append("<h2><u>Changelog V' .. (GAMEMODE.Version or '?') .. '</u></h2><table>' .. ctxt .. '</table>");')

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
		spb_Jukebox:SetTitle(GAMEMODE.Name .. " Jukebox")
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
		spb_Jukebox.ServerQueue.add2queue = vgui.Create("DTextEntry", spb_Jukebox.ServerQueue)
		spb_Jukebox.ServerQueue.add2queue:SetPos(0, h - 60)
		spb_Jukebox.ServerQueue.add2queue:SetSize(mw, 20)
		spb_Jukebox.ServerQueue.add2queue:SetText(placeholder)
		spb_Jukebox.ServerQueue.add2queue.OnMousePressed = function(self, keycode)
			if keycode == MOUSE_FIRST and !self:IsEditing() then
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
