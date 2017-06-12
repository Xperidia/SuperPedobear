--[[---------------------------------------------------------------------------
		⚠ This file is a part of the Super Pedobear source code ⚠
		⚠ Please do not clone, redistribute or modify the code! ⚠
	We do not obscurate the code or anything mostly to help bug reporting.
	Please do not try to cheat, if you want something ask me directly...
We're just indies making stuff so please support us instead of putting us down.
So unless you're modifying it to improve it via a Pull request please do not.
-----------------------------------------------------------------------------]]

function GM:Menu()

	if !IsValid(pedobearMenuF) and !engine.IsPlayingDemo() then

		if IsValid(pedobearMenuBF) then
			pedobearMenuBF:Close()
		end

		pedobearMenuF = vgui.Create("DFrame")
		pedobearMenuF:SetPos(ScrW() / 2 - 320, ScrH() / 2 - 240)
		pedobearMenuF:SetSize(640, 480)
		pedobearMenuF:SetTitle((GAMEMODE.Name or "?") .. " V" .. (GAMEMODE.Version or "?") .. GAMEMODE:SeasonalEventStr() .. " | By " .. (GAMEMODE.Author or "?"))
		pedobearMenuF:SetVisible(true)
		pedobearMenuF:SetDraggable(true)
		pedobearMenuF:ShowCloseButton(true)
		pedobearMenuF:SetScreenLock(true)
		pedobearMenuF.Paint = function(self, w, h)
			draw.RoundedBox(4, 0, 0, w, h, Color(0, 0, 0, 128))
		end
		pedobearMenuF.Think = function(self)
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
		pedobearMenuF:MakePopup()
		pedobearMenuF:SetKeyboardInputEnabled(false)

		pedobearMenuF.one = vgui.Create("DPanel")
		pedobearMenuF.one:SetParent(pedobearMenuF)
		pedobearMenuF.one:SetPos(10, 30)
		pedobearMenuF.one:SetSize(305, 215)

		local onelbl = vgui.Create("DLabel")
		onelbl:SetParent(pedobearMenuF.one)
		onelbl:SetText( "You're playing " .. (GAMEMODE.Name or "?") )
		onelbl:SetPos(10, 5)
		onelbl:SetDark(1)
		onelbl:SizeToContents()

		local desclbl = vgui.Create("DLabel")
		desclbl:SetParent(pedobearMenuF.one)
		desclbl:SetText("Some controls:\n\n" .. GAMEMODE:CheckBind("gm_showhelp") .. ": This window\n"
		.. GAMEMODE:CheckBind("gm_showteam") .. ": Change team\n"
		.. GAMEMODE:CheckBind("gm_showspare1") .. ": Taunt menu\n"
		.. GAMEMODE:CheckBind("gm_showspare2") .. ": Jukebox menu\n"
		.. GAMEMODE:CheckBind("+menu") .. ": PedoVan (Shop)\n"
		.. GAMEMODE:CheckBind("+menu_context") .. ": Toggle thirdperson\n"
		.. "1-9: Quick taunt")
		desclbl:SetPos(20, 30)
		desclbl:SetDark(1)
		desclbl:SizeToContents()

		local xpucp = vgui.Create( "DButton" )
		xpucp:SetParent(pedobearMenuF.one)
		xpucp:SetText("Xperidia Account")
		xpucp:SetPos(20, 190)
		xpucp:SetSize(125, 20)
		xpucp.DoClick = function()
			gui.OpenURL("https://www.xperidia.com/UCP/")
			pedobearMenuF:Close()
		end

		local xpsteam = vgui.Create("DButton")
		xpsteam:SetParent(pedobearMenuF.one)
		xpsteam:SetText("Xperidia's Steam Group")
		xpsteam:SetPos(160, 190)
		xpsteam:SetSize(125, 20)
		xpsteam.DoClick = function()
			gui.OpenURL("https://xperi.link/XP-SteamGroup")
			pedobearMenuF:Close()
		end

		local playermodelselection = vgui.Create("DButton")
		playermodelselection:SetParent(pedobearMenuF.one)
		playermodelselection:SetText("Outfitter")
		playermodelselection:SetPos(145, 40)
		playermodelselection:SetSize(160, 20)
		playermodelselection:SetEnabled(concommand.GetTable()["outfitter_open"])
		playermodelselection.DoClick = function()
			RunConsoleCommand("outfitter_open")
			pedobearMenuF:Close()
		end

		local playermodelselection = vgui.Create("DButton")
		playermodelselection:SetParent(pedobearMenuF.one)
		playermodelselection:SetText("Enhanced PlayerModel Selector")
		playermodelselection:SetPos(145, 60)
		playermodelselection:SetSize(160, 20)
		playermodelselection:SetEnabled(concommand.GetTable()["playermodel_selector"] and (GetConVar("sv_playermodel_selector_gamemodes"):GetBool() or LocalPlayer():IsAdmin()))
		playermodelselection.DoClick = function()
			RunConsoleCommand("playermodel_selector")
			pedobearMenuF:Close()
		end

		local support = vgui.Create("DButton")
		support:SetParent(pedobearMenuF.one)
		support:SetText("Support")
		support:SetPos(160, 165)
		support:SetSize(125, 20)
		support.DoClick = function()
			gui.OpenURL("https://xperi.link/XP-DSupport")
			pedobearMenuF:Close()
		end

		local SplashScreen = vgui.Create("DButton")
		SplashScreen:SetParent(pedobearMenuF.one)
		SplashScreen:SetText("Splash Screen")
		SplashScreen:SetPos(20, 165)
		SplashScreen:SetSize(125, 20)
		SplashScreen.DoClick = function()
			GAMEMODE:SplashScreen()
			pedobearMenuF:Close()
		end


		pedobearMenuF.config = vgui.Create("DPanel")
		pedobearMenuF.config:SetParent(pedobearMenuF)
		pedobearMenuF.config:SetPos(325, 30)
		pedobearMenuF.config:SetSize(305, 215)

		local configlbl = vgui.Create("DLabel")
		configlbl:SetParent(pedobearMenuF.config)
		configlbl:SetText("Configuration")
		configlbl:SetPos(10, 5)
		configlbl:SetDark(1)
		configlbl:SizeToContents()

		local disablexpsc = vgui.Create("DCheckBoxLabel")
		disablexpsc:SetParent(pedobearMenuF.config)
		disablexpsc:SetText("Disable Xperidia's Showcase")
		disablexpsc:SetPos(15, 30)
		disablexpsc:SetDark(1)
		disablexpsc:SetConVar("superpedobear_cl_disablexpsc")
		disablexpsc:SetValue( GetConVar("superpedobear_cl_disablexpsc"):GetBool() )
		disablexpsc:SizeToContents()

		local disabletc = vgui.Create("DCheckBoxLabel")
		disabletc:SetParent(pedobearMenuF.config)
		disabletc:SetText("Don't close the taunt menu after taunting")
		disabletc:SetPos(15, 50)
		disabletc:SetDark(1)
		disabletc:SetConVar("superpedobear_cl_disabletauntmenuclose")
		disabletc:SetValue(GetConVar("superpedobear_cl_disabletauntmenuclose"):GetBool())
		disabletc:SizeToContents()

		local jumpscare = vgui.Create("DCheckBoxLabel")
		jumpscare:SetParent(pedobearMenuF.config)
		jumpscare:SetText("Pedobear jumpscare")
		jumpscare:SetPos(15, 70)
		jumpscare:SetDark(1)
		jumpscare:SetConVar("superpedobear_cl_jumpscare")
		jumpscare:SetValue(GetConVar("superpedobear_cl_jumpscare"):GetBool())
		jumpscare:SetDisabled(GAMEMODE:IsSeasonalEvent("Halloween"))
		jumpscare:SizeToContents()

		local hud = vgui.Create("DCheckBoxLabel")
		hud:SetParent(pedobearMenuF.config)
		hud:SetText("Draw HUD (Caution! This is a Garry's Mod convar)")
		hud:SetPos(15, 90)
		hud:SetDark(1)
		hud:SetConVar("cl_drawhud")
		hud:SetValue(GetConVar("cl_drawhud"):GetBool())
		hud:SizeToContents()

		local disablehalo = vgui.Create("DCheckBoxLabel")
		disablehalo:SetParent(pedobearMenuF.config)
		disablehalo:SetText("Disable halos (Improve performance)")
		disablehalo:SetPos(15, 110)
		disablehalo:SetDark(1)
		disablehalo:SetConVar("superpedobear_cl_disablehalos")
		disablehalo:SetValue(GetConVar("superpedobear_cl_disablehalos"):GetBool())
		disablehalo:SizeToContents()

		local hudoffset = vgui.Create("DNumSlider", pedobearMenuF.config)
		hudoffset:SetPos(15, 190)
		hudoffset:SetSize(300, 16)
		hudoffset:SetText("HUD Offset")
		hudoffset:SetMin(0)
		hudoffset:SetMax(64)
		hudoffset:SetDecimals(0)
		hudoffset:SetDark(1)
		hudoffset:SetConVar("superpedobear_cl_hud_offset")


		pedobearMenuF.MusicL = vgui.Create("DPanel")
		pedobearMenuF.MusicL:SetParent(pedobearMenuF)
		pedobearMenuF.MusicL:SetPos(10, 255)
		pedobearMenuF.MusicL:SetSize(305, 215)

		local pre = GAMEMODE.Vars.Round.PreStart

		pedobearMenuF.MusicL.lbl = vgui.Create("DLabel")
		pedobearMenuF.MusicL.lbl:SetParent(pedobearMenuF.MusicL)
		pedobearMenuF.MusicL.lbl:SetText("Music list")
		pedobearMenuF.MusicL.lbl:SetPos(10, 5)
		pedobearMenuF.MusicL.lbl:SetSize(289, 10)
		pedobearMenuF.MusicL.lbl:SetDark(1)

		pedobearMenuF.MusicL.List = vgui.Create("DListView", pedobearMenuF.MusicL)
		pedobearMenuF.MusicL.List:SetPos(0, 20)
		pedobearMenuF.MusicL.List:SetSize(305, 195)
		pedobearMenuF.MusicL.List:SetMultiSelect(false)
		local name = pedobearMenuF.MusicL.List:AddColumn("Music")
		name:SetMinWidth(150)
		local mp = pedobearMenuF.MusicL.List:AddColumn("Pack")
		mp:SetMinWidth(30)
		local loc = pedobearMenuF.MusicL.List:AddColumn("Local")
		loc:SetMinWidth(30)
		loc:SetMaxWidth(30)
		local serv = pedobearMenuF.MusicL.List:AddColumn("Serv")
		serv:SetMinWidth(30)
		serv:SetMaxWidth(30)

		local function CreateMusicList(pre)

			pedobearMenuF.MusicL.List:Clear()
			pedobearMenuF.MusicL.lbl:SetText("Music list" .. Either(pre, " (Pre Round Musics)", ""))

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
				pedobearMenuF.MusicL.List:AddLine(v[1] or GAMEMODE:PrettyMusicName(k), v[2], Either(string.match(k, "://"), "URL", Either(v[3], "✓", "❌")), Either(v[4], "✓", "❌"))
			end

		end
		CreateMusicList(pre)

		local switchbtn = vgui.Create("DButton")
		switchbtn:SetParent(pedobearMenuF.MusicL)
		switchbtn:SetText("Switch to " .. Either(pre, "Round", "Pre round"))
		switchbtn:SetPos(200, 0)
		switchbtn:SetSize(105, 20)
		switchbtn.DoClick = function()
			pre = !pre
			switchbtn:SetText("Switch to " .. Either(pre, "Round", "Pre round"))
			CreateMusicList(pre)
		end


		pedobearMenuF.MusicCFG = vgui.Create("DPanel")
		pedobearMenuF.MusicCFG:SetParent(pedobearMenuF)
		pedobearMenuF.MusicCFG:SetPos(325, 255)
		pedobearMenuF.MusicCFG:SetSize(305, 215)

		local musicmenulbl = vgui.Create("DLabel")
		musicmenulbl:SetParent(pedobearMenuF.MusicCFG)
		musicmenulbl:SetText( Either(GAMEMODE:IsSeasonalEvent("AprilFool"), "PedoRadio™", "Music") .. " configuration")
		musicmenulbl:SetPos(10, 5)
		musicmenulbl:SetDark(1)
		musicmenulbl:SizeToContents()

		local enablemusic = vgui.Create("DCheckBoxLabel")
		enablemusic:SetParent(pedobearMenuF.MusicCFG)
		enablemusic:SetText(Either(GAMEMODE:IsSeasonalEvent("AprilFool"), "Enable the PedoRadio™", "Enable music"))
		enablemusic:SetPos(15, 30)
		enablemusic:SetDark(1)
		enablemusic:SetConVar("superpedobear_cl_music_enable")
		enablemusic:SetValue(GetConVar("superpedobear_cl_music_enable"):GetBool())
		enablemusic:SizeToContents()

		local allowexternal = vgui.Create("DCheckBoxLabel")
		allowexternal:SetParent(pedobearMenuF.MusicCFG)
		allowexternal:SetText("Allow external musics (Loaded from url)")
		allowexternal:SetPos(15, 50)
		allowexternal:SetDark(1)
		allowexternal:SetConVar("superpedobear_cl_music_allowexternal")
		allowexternal:SetValue(GetConVar("superpedobear_cl_music_allowexternal"):GetBool())
		allowexternal:SizeToContents()

		local visualizer = vgui.Create("DCheckBoxLabel")
		visualizer:SetParent(pedobearMenuF.MusicCFG)
		visualizer:SetText("Enable visualizer (Downgrade performance)")
		visualizer:SetPos(15, 70)
		visualizer:SetDark(1)
		visualizer:SetConVar("superpedobear_cl_music_visualizer")
		visualizer:SetValue(GetConVar("superpedobear_cl_music_visualizer"):GetBool())
		visualizer:SizeToContents()

		local playmusic = vgui.Create("DButton")
		playmusic:SetParent(pedobearMenuF.MusicCFG)
		playmusic:SetText("Auto play local file")
		playmusic:SetPos(90, 190)
		playmusic:SetSize(125, 20)
		playmusic:SetDisabled(!GAMEMODE.Vars.Round.PreStart and !GAMEMODE.Vars.Round.Start)
		playmusic.DoClick = function()
			GAMEMODE:Music("", GAMEMODE.Vars.Round.PreStart)
		end

		local vollbl = vgui.Create("DLabel")
		vollbl:SetParent(pedobearMenuF.MusicCFG)
		vollbl:SetText("Volume")
		vollbl:SetPos(125, 140)
		vollbl:SetDark(1)
		vollbl:SizeToContents()

		local vol = GetConVar("superpedobear_cl_music_volume")
		local musivol = vgui.Create("Slider")
		musivol:SetParent(pedobearMenuF.MusicCFG)
		musivol:SetPos(15, 150)
		musivol:SetSize(300, 40)
		musivol:SetValue(vol:GetFloat())
		musivol.OnValueChanged = function(panel, value)
			vol:SetFloat(value)
		end

		if !GetConVar("superpedobear_cl_disablexpsc"):GetBool() then

			local xpsc = vgui.Create("DHTML")
			xpsc:SetParent(pedobearMenuF)
			xpsc:SetPos(10, 480)
			xpsc:SetSize(620, 128)
			xpsc:SetAllowLua(true)
			xpsc:OpenURL("https://xperidia.com/Showcase/?sys=pedobearMenu&zone=" .. tostring(GAMEMODE.Name) .. "&lang=" .. tostring(GetConVarString("gmod_language") or "en"))
			xpsc:SetScrollbars(false)

			xpsc_anim = Derma_Anim("xpsc_anim", pedobearMenuF, function(pnl, anim, delta, data)
				pnl:SetSize(640, 138 * delta + 480)
			end)

		end


	elseif IsValid(pedobearMenuF) then
		pedobearMenuF:Close()
	end

end

function pedobearSCLoaded()
	if IsValid(pedobearMenuF) then xpsc_anim:Start(0.25) end
	if IsValid(pedobearMenuBF) then xpsc_anim2:Start(0.25) end
end

function GM:SplashScreen()

	if !IsValid(pedobearSplashScreenF) and !engine.IsPlayingDemo() then

		pedobearSplashScreenF = vgui.Create("DFrame")
		pedobearSplashScreenF:ParentToHUD()
		pedobearSplashScreenF:SetPos(0, 0)
		pedobearSplashScreenF:SetSize(ScrW(), ScrH())
		pedobearSplashScreenF:SetTitle("")
		pedobearSplashScreenF:SetVisible(true)
		pedobearSplashScreenF:SetDraggable(false)
		pedobearSplashScreenF:ShowCloseButton(false)
		pedobearSplashScreenF:SetScreenLock(true)
		pedobearSplashScreenF.Paint = function(self, w, h)
		end
		pedobearSplashScreenF:MakePopup()
		--pedobearSplashScreenF:SetKeyboardInputEnabled(false)
		--pedobearSplashScreenF:SetMouseInputEnabled(false)

		pedobearSplashScreenF.SplashScreen = vgui.Create("DHTML")
		pedobearSplashScreenF.SplashScreen:SetParent(pedobearSplashScreenF)
		pedobearSplashScreenF.SplashScreen:SetPos(0, 0)
		pedobearSplashScreenF.SplashScreen:SetSize(ScrW(), ScrH())
		pedobearSplashScreenF.SplashScreen:SetAllowLua(true)
		pedobearSplashScreenF.SplashScreen:OpenURL("https://www.xperidia.com/SuperPedobear/?steamid=" .. LocalPlayer():SteamID64())
		--pedobearSplashScreenF.SplashScreen:SetScrollbars(false)
		pedobearSplashScreenF.SplashScreen:Call('$("#controls").append("<h2><u>Controls</u></h2><table>'
		.. "<tr><td class='leftside'>" .. GAMEMODE:CheckBind("+forward") .. "</td><td> Move forward</td></tr>"
		.. "<tr><td class='leftside'>" .. GAMEMODE:CheckBind("+moveleft") .. "</td><td> Move left (stafe)</td></tr>"
		.. "<tr><td class='leftside'>" .. GAMEMODE:CheckBind("+moveright") .. "</td><td> Move right (strafe)</td></tr>"
		.. "<tr><td class='leftside'>" .. GAMEMODE:CheckBind("+back") .. "</td><td> Move back</td></tr>"
		.. "<tr><td class='leftside'>" .. GAMEMODE:CheckBind("+duck") .. "</td><td> Duck</td></tr>"
		.. "<tr><td class='leftside'>" .. GAMEMODE:CheckBind("+jump") .. "</td><td> Jump</td></tr>"
		.. "<tr><td class='leftside'>" .. GAMEMODE:CheckBind("+speed") .. "</td><td> Sprint (Move Quickly)</td></tr>"
		.. "<tr><td class='leftside'>" .. GAMEMODE:CheckBind("gm_showhelp") .. "</td><td> Gamemode menu ('Show help')</td></tr>"
		.. "<tr><td class='leftside'>" .. GAMEMODE:CheckBind("gm_showteam") .. "</td><td> Change team ('Team menu')</td></tr>"
		.. "<tr><td class='leftside'>" .. GAMEMODE:CheckBind("gm_showspare1") .. "</td><td> Taunt menu ('Spare 1')</td></tr>"
		.. "<tr><td class='leftside'>" .. GAMEMODE:CheckBind("gm_showspare2") .. "</td><td> Jukebox menu ('Spare 2')</td></tr>"
		.. "<tr><td class='leftside'>" .. GAMEMODE:CheckBind("+menu") .. "</td><td> PedoVan ('Show Menu')</td></tr>"
		.. "<tr><td class='leftside'>" .. GAMEMODE:CheckBind("+menu_context") .. "</td><td> Toggle thirdperson ('Show Context Menu')</td></tr>"
		.. "<tr><td class='leftside'>1-9</td><td> Quick taunt</td></tr>"
		.. '</table>");')
		pedobearSplashScreenF.SplashScreen:Call('$("#changelog").append("<h2><u>Changelog V' .. (GAMEMODE.Version or '?') .. '</u></h2><table>'
		.. "<tr><td>> Welcome to this new Splash Screen</td></tr>"
		.. "<tr><td>> Removed pedochance visibility</td></tr>"
		.. "<tr><td>> New version of the Xperidia Rank system</td></tr>"
		.. "<tr><td>> Rework of chat message visibility</td></tr>"
		.. "<tr><td>> Removed music start when connecting</td></tr>"
		.. "<tr><td>> Fixed clones positions</td></tr>"
		.. "<tr><td>> Jukebox menu</td></tr>"
		.. "<tr><td>> Preparing release</td></tr>"
		.. '</table>");')

		local closebtn = vgui.Create("DButton", pedobearSplashScreenF)
		closebtn:SetText("X")
		closebtn:SetPos(ScrW() - 20, 0)
		closebtn:SetSize(20, 20)
		closebtn.DoClick = function()
			pedobearSplashScreenF:Close()
		end
		closebtn:SetZPos(32767)

	elseif IsValid(pedobearSplashScreenF) then
		pedobearSplashScreenF:Close()
	end

end

function GM:HideSplashScreenUntilNextUpdate()
	local tab = {}
	tab.LastVersion = GAMEMODE.Version
	file.Write("superpedobear/info.txt", util.TableToJSON(tab))
end

function GM:JukeboxMenu()

	if !IsValid(SuperPedobearJukebox) and !engine.IsPlayingDemo() then

		SuperPedobearJukebox = vgui.Create("DFrame")
		SuperPedobearJukebox:SetSize(ScrW() * 0.90, ScrH() * 0.75)
		local w, h = SuperPedobearJukebox:GetSize()
		SuperPedobearJukebox:SetPos(ScrW() / 2 - w / 2, ScrH() / 2 - h / 2)
		SuperPedobearJukebox:SetTitle("Super Pedobear Jukebox")
		SuperPedobearJukebox:SetVisible(true)
		SuperPedobearJukebox:SetDraggable(true)
		SuperPedobearJukebox:ShowCloseButton(true)
		SuperPedobearJukebox:SetScreenLock(true)
		SuperPedobearJukebox.Paint = function(self, w, h)
			draw.RoundedBox(4, 0, 0, w, h, Color(0, 0, 0, 128))
		end
		SuperPedobearJukebox:MakePopup()
		SuperPedobearJukebox:SetKeyboardInputEnabled(false)
		local mw = w / 3 - 20


		SuperPedobearJukebox.MusicL = vgui.Create("DPanel")
		SuperPedobearJukebox.MusicL:SetParent(SuperPedobearJukebox)
		SuperPedobearJukebox.MusicL:SetPos(10, 30)
		SuperPedobearJukebox.MusicL:SetSize(mw, h - 40)

		SuperPedobearJukebox.MusicL.lbl = vgui.Create("DLabel")
		SuperPedobearJukebox.MusicL.lbl:SetParent(SuperPedobearJukebox.MusicL)
		SuperPedobearJukebox.MusicL.lbl:SetText("Music list")
		SuperPedobearJukebox.MusicL.lbl:SetPos(5, 3)
		SuperPedobearJukebox.MusicL.lbl:SetSize(mw, 15)
		SuperPedobearJukebox.MusicL.lbl:SetDark(1)

		SuperPedobearJukebox.MusicL.List = vgui.Create("DListView", SuperPedobearJukebox.MusicL)
		SuperPedobearJukebox.MusicL.List:SetPos(0, 20)
		SuperPedobearJukebox.MusicL.List:SetSize(mw, h - 60)
		SuperPedobearJukebox.MusicL.List:SetMultiSelect(false)
		local name = SuperPedobearJukebox.MusicL.List:AddColumn("Music")
		name:SetMinWidth(150)
		local mp = SuperPedobearJukebox.MusicL.List:AddColumn("Pack")
		mp:SetMinWidth(30)
		local loc = SuperPedobearJukebox.MusicL.List:AddColumn("Local")
		loc:SetMinWidth(30)
		loc:SetMaxWidth(30)
		local serv = SuperPedobearJukebox.MusicL.List:AddColumn("Serv")
		serv:SetMinWidth(30)
		serv:SetMaxWidth(30)

		local pre = GAMEMODE.Vars.Round.PreStart
		local function CreateMusicList(pre)

			SuperPedobearJukebox.MusicL.List:Clear()
			SuperPedobearJukebox.MusicL.lbl:SetText("Music list" .. Either(pre, " (Pre Round Musics)", ""))

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
				local line = SuperPedobearJukebox.MusicL.List:AddLine(v[1] or GAMEMODE:PrettyMusicName(k), v[2], Either(string.match(k, "://"), "URL", Either(v[3], "✓", "❌")), Either(v[4], "✓", "❌"))
				line.music = "sound/superpedobear/" .. Either(pre, "premusics", "musics") .. "/" .. k
			end

			function SuperPedobearJukebox.MusicL.List:DoDoubleClick(lineID, line)
				GAMEMODE:Music(line.music, pre)
			end

		end
		CreateMusicList(pre)

		local switchbtn = vgui.Create("DButton")
		switchbtn:SetParent(SuperPedobearJukebox.MusicL)
		switchbtn:SetText("Switch to " .. Either(pre, "Round", "Pre round"))
		switchbtn:SetPos(mw - 105, 0)
		switchbtn:SetSize(105, 20)
		switchbtn.DoClick = function()
			pre = !pre
			switchbtn:SetText("Switch to " .. Either(pre, "Round", "Pre round"))
			CreateMusicList(pre)
		end


		local queue = {}
		SuperPedobearJukebox.ServerQueue = vgui.Create("DPanel")
		SuperPedobearJukebox.ServerQueue:SetParent(SuperPedobearJukebox)
		SuperPedobearJukebox.ServerQueue:SetPos(w / 3 + 10, 30)
		SuperPedobearJukebox.ServerQueue:SetSize(mw, h - 40)
		SuperPedobearJukebox.ServerQueue.Think = function(self)
			if GAMEMODE.Vars.MusicQueue and queue != GAMEMODE.Vars.MusicQueue then
				queue = GAMEMODE.Vars.MusicQueue
				SuperPedobearJukebox.ServerQueue.List.CreateQueueList()
			end
		end

		SuperPedobearJukebox.ServerQueue.lbl = vgui.Create("DLabel")
		SuperPedobearJukebox.ServerQueue.lbl:SetParent(SuperPedobearJukebox.ServerQueue)
		SuperPedobearJukebox.ServerQueue.lbl:SetText("Jukebox (server queue)")
		SuperPedobearJukebox.ServerQueue.lbl:SetPos(5, 3)
		SuperPedobearJukebox.ServerQueue.lbl:SetSize(289, 15)
		SuperPedobearJukebox.ServerQueue.lbl:SetDark(1)

		SuperPedobearJukebox.ServerQueue.List = vgui.Create("DListView", SuperPedobearJukebox.ServerQueue)
		SuperPedobearJukebox.ServerQueue.List:SetPos(0, 20)
		SuperPedobearJukebox.ServerQueue.List:SetSize(mw, h - 80)
		SuperPedobearJukebox.ServerQueue.List:SetMultiSelect(false)
		local name = SuperPedobearJukebox.ServerQueue.List:AddColumn("Music")
		name:SetMinWidth(150)
		local who = SuperPedobearJukebox.ServerQueue.List:AddColumn("Suggested by")
		who:SetMinWidth(100)
		local votes = SuperPedobearJukebox.ServerQueue.List:AddColumn("Votes")
		votes:SetMinWidth(40)
		votes:SetMaxWidth(40)

		function SuperPedobearJukebox.ServerQueue.List.CreateQueueList()
			SuperPedobearJukebox.ServerQueue.List:Clear()
			for k, v in pairs(queue) do
				local line = SuperPedobearJukebox.ServerQueue.List:AddLine(v.music, k:Nick(), #v.votes)
				line.owner = k
			end
			function SuperPedobearJukebox.ServerQueue.List:DoDoubleClick(lineID, line)
				net.Start("XP_Pedo_MusicQueueVote")
					net.WriteEntity(line.owner)
				net.SendToServer()
			end
		end

		local placeholder = "Enter a music path or URL (Mostly .mp3)"
		SuperPedobearJukebox.ServerQueue.add2queue = vgui.Create("DTextEntry", SuperPedobearJukebox.ServerQueue)
		SuperPedobearJukebox.ServerQueue.add2queue:SetPos(0, h - 60)
		SuperPedobearJukebox.ServerQueue.add2queue:SetSize(mw, 20)
		SuperPedobearJukebox.ServerQueue.add2queue:SetText(placeholder)
		SuperPedobearJukebox.ServerQueue.add2queue.OnMousePressed = function(self, keycode)
			if keycode == MOUSE_FIRST and !self:IsEditing() then
				SuperPedobearJukebox:SetKeyboardInputEnabled(true)
				if self:GetValue() == placeholder then
					self:SetText("")
				end
			end
		end
		SuperPedobearJukebox.ServerQueue.add2queue.OnEnter = function(self)
			net.Start("XP_Pedo_MusicAddToQueue")
				net.WriteString(self:GetValue())
			net.SendToServer()
			self:SetText(placeholder)
		end
		SuperPedobearJukebox.ServerQueue.add2queue.OnLoseFocus = function(self)
			SuperPedobearJukebox:SetKeyboardInputEnabled(false)
		end


		SuperPedobearJukebox.MusicCFG = vgui.Create("DPanel")
		SuperPedobearJukebox.MusicCFG:SetParent(SuperPedobearJukebox)
		SuperPedobearJukebox.MusicCFG:SetPos(w / 3 * 2 + 10, h / 2 + 30)
		SuperPedobearJukebox.MusicCFG:SetSize(mw, h / 2 - 40)

		local mcfgw, mcfgh = SuperPedobearJukebox.MusicCFG:GetSize()

		local musicmenulbl = vgui.Create("DLabel")
		musicmenulbl:SetParent(SuperPedobearJukebox.MusicCFG)
		musicmenulbl:SetText("Music configuration")
		musicmenulbl:SetPos(8, 5)
		musicmenulbl:SetDark(1)
		musicmenulbl:SizeToContents()

		local enablemusic = vgui.Create("DCheckBoxLabel")
		enablemusic:SetParent(SuperPedobearJukebox.MusicCFG)
		enablemusic:SetText("Enable music")
		enablemusic:SetPos(10, 30)
		enablemusic:SetDark(1)
		enablemusic:SetConVar("superpedobear_cl_music_enable")
		enablemusic:SetValue(GetConVar("superpedobear_cl_music_enable"):GetBool())
		enablemusic:SizeToContents()

		local allowexternal = vgui.Create("DCheckBoxLabel")
		allowexternal:SetParent(SuperPedobearJukebox.MusicCFG)
		allowexternal:SetText("Allow external musics (Loaded from url)")
		allowexternal:SetPos(10, 50)
		allowexternal:SetDark(1)
		allowexternal:SetConVar("superpedobear_cl_music_allowexternal")
		allowexternal:SetValue(GetConVar("superpedobear_cl_music_allowexternal"):GetBool())
		allowexternal:SizeToContents()

		local visualizer = vgui.Create("DCheckBoxLabel")
		visualizer:SetParent(SuperPedobearJukebox.MusicCFG)
		visualizer:SetText("Enable visualizer (Downgrade performance)")
		visualizer:SetPos(10, 70)
		visualizer:SetDark(1)
		visualizer:SetConVar("superpedobear_cl_music_visualizer")
		visualizer:SetValue(GetConVar("superpedobear_cl_music_visualizer"):GetBool())
		visualizer:SizeToContents()

		local vollbl = vgui.Create("DLabel")
		vollbl:SetParent(SuperPedobearJukebox.MusicCFG)
		vollbl:SetText("Volume")
		vollbl:SetPos(mw / 2 - 40, mcfgh - 50)
		vollbl:SetDark(1)
		vollbl:SizeToContents()

		local vol = GetConVar("superpedobear_cl_music_volume")
		local musivol = vgui.Create("Slider")
		musivol:SetParent(SuperPedobearJukebox.MusicCFG)
		musivol:SetPos(0, mcfgh - 40)
		musivol:SetSize(mw, 40)
		musivol:SetValue(vol:GetFloat())
		musivol.OnValueChanged = function(panel, value)
			vol:SetFloat(value)
		end

	elseif IsValid(SuperPedobearJukebox) then
		SuperPedobearJukebox:Close()
	end

end
