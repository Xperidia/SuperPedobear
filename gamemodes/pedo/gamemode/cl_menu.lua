function GM:Menu()
	
	if !IsValid(pedobearMenuF) and !engine.IsPlayingDemo() then
		
		pedobearMenuF = vgui.Create( "DFrame" )
		pedobearMenuF:SetPos( ScrW()/2-320, ScrH()/2-240 )
		pedobearMenuF:SetSize( 640, 480 )
		pedobearMenuF:SetTitle((GAMEMODE.Name or "?").." Gamemode V"..(GAMEMODE.Version or "?")..GAMEMODE:SeasonalEventStr())
		pedobearMenuF:SetVisible(true)
		pedobearMenuF:SetDraggable(true)
		pedobearMenuF:ShowCloseButton(true)
		pedobearMenuF:SetScreenLock(true)
		pedobearMenuF.Paint = function( self, w, h )
			draw.RoundedBox( 4, 0, 0, w, h, Color( 0, 0, 0, 128 ) )
		end
		pedobearMenuF.Think = function(self)
			
			if xpsc_anim and xpsc_anim:Active() then xpsc_anim:Run() end
			
			local mousex = math.Clamp( gui.MouseX(), 1, ScrW()-1 )
			local mousey = math.Clamp( gui.MouseY(), 1, ScrH()-1 )
		
			if ( self.Dragging ) then
		
				local x = mousex - self.Dragging[1]
				local y = mousey - self.Dragging[2]
		
				-- Lock to screen bounds if screenlock is enabled
				if ( self:GetScreenLock() ) then
		
					x = math.Clamp( x, 0, ScrW() - self:GetWide() )
					y = math.Clamp( y, 0, ScrH() - self:GetTall() )
		
				end
		
				self:SetPos( x, y )
		
			end
				
			if ( self.Hovered && mousey < ( self.y + 24 ) ) then
				self:SetCursor( "sizeall" )
				return
			end
			
			self:SetCursor( "arrow" )

			if ( self.y < 0 ) then
				self:SetPos( self.x, 0 )
			end
			
		end
		pedobearMenuF:MakePopup()
		pedobearMenuF:SetKeyboardInputEnabled(false)
		
		pedobearMenuF.one = vgui.Create( "DPanel" )
		pedobearMenuF.one:SetParent(pedobearMenuF)
		pedobearMenuF.one:SetPos( 10, 30 )
		pedobearMenuF.one:SetSize( 305, 215 )
		
		local xpucp = vgui.Create( "DButton" )
		xpucp:SetParent(pedobearMenuF.one)
		xpucp:SetText( "Xperidia Account" )
		xpucp:SetPos( 20, 190 )
		xpucp:SetSize( 125, 20 )
		xpucp.DoClick = function()
			gui.OpenURL( "https://www.xperidia.com/UCP/" )
			pedobearMenuF:Close()
		end
		
		local xpsteam = vgui.Create( "DButton" )
		xpsteam:SetParent(pedobearMenuF.one)
		xpsteam:SetText( "Xperidia's Steam Group" )
		xpsteam:SetPos( 160, 190 )
		xpsteam:SetSize( 125, 20 )
		xpsteam.DoClick = function()
			gui.OpenURL( "https://xperi.link/XP-SteamGroup" )
			pedobearMenuF:Close()
		end
		
		local beginmenubtn = vgui.Create( "DButton" )
		beginmenubtn:SetParent(pedobearMenuF.one)
		beginmenubtn:SetText( "Beginner screen" )
		beginmenubtn:SetPos( 160, 64 )
		beginmenubtn:SetSize( 125, 20 )
		beginmenubtn:SetDisabled(true)
		beginmenubtn.DoClick = function()
			GAMEMODE:BeginMenu()
			pedobearMenuF:Close()
		end
		
		local onelbl = vgui.Create( "DLabel" )
		onelbl:SetParent(pedobearMenuF.one)
		onelbl:SetText( "Welcome to the Pedobear Gamemode" )
		onelbl:SetPos( 10, 5 )
		onelbl:SetDark( 1 )
		onelbl:SizeToContents()
		
		local desclbl = vgui.Create( "DLabel" )
		desclbl:SetParent(pedobearMenuF.one)
		desclbl:SetText( "Some controls:\n\n"..GAMEMODE:CheckBind("gm_showhelp")..": This window\n"
		..GAMEMODE:CheckBind("gm_showteam")..": Change team\n"
		..GAMEMODE:CheckBind("gm_showspare1")..": Taunt menu\n"
		.."1-9: Quick taunt\n"
		..GAMEMODE:CheckBind("+menu_context")..": Toggle thirdperson" )
		desclbl:SetPos( 20, 30 )
		desclbl:SetDark( 1 )
		desclbl:SizeToContents()
		
		local hflbl = vgui.Create( "DLabel" )
		hflbl:SetParent(pedobearMenuF.one)
		hflbl:SetText( "Have fun!" )
		hflbl:SetPos( 130, 150 )
		hflbl:SetDark( 1 )
		hflbl:SizeToContents()
		
		
		pedobearMenuF.config = vgui.Create( "DPanel" )
		pedobearMenuF.config:SetParent(pedobearMenuF)
		pedobearMenuF.config:SetPos( 325, 30 )
		pedobearMenuF.config:SetSize( 305, 215 )
		
		local configlbl = vgui.Create( "DLabel" )
		configlbl:SetParent(pedobearMenuF.config)
		configlbl:SetText( "Configuration" )
		configlbl:SetPos( 10, 5 )
		configlbl:SetDark( 1 )
		configlbl:SizeToContents()
		
		local disablexpsc = vgui.Create( "DCheckBoxLabel" )
		disablexpsc:SetParent(pedobearMenuF.config)
		disablexpsc:SetText("Disable Xperidia's Showcase")
		disablexpsc:SetPos( 15, 30 )
		disablexpsc:SetDark( 1 )
		disablexpsc:SetConVar( "pedobear_cl_disablexpsc" )
		disablexpsc:SetValue( GetConVar("pedobear_cl_disablexpsc"):GetBool() )
		disablexpsc:SizeToContents()
		
		local disabletc = vgui.Create( "DCheckBoxLabel" )
		disabletc:SetParent(pedobearMenuF.config)
		disabletc:SetText("Don't close the taunt menu after taunting")
		disabletc:SetPos( 15, 50 )
		disabletc:SetDark( 1 )
		disabletc:SetConVar( "pedobear_cl_disabletauntmenuclose" )
		disabletc:SetValue( GetConVar("pedobear_cl_disabletauntmenuclose"):GetBool() )
		disabletc:SizeToContents()
		
		local jumpscare = vgui.Create( "DCheckBoxLabel" )
		jumpscare:SetParent(pedobearMenuF.config)
		jumpscare:SetText("Pedobear jumpscare")
		jumpscare:SetPos( 15, 70 )
		jumpscare:SetDark( 1 )
		jumpscare:SetConVar( "pedobear_cl_jumpscare" )
		jumpscare:SetValue( GetConVar("pedobear_cl_jumpscare"):GetBool() )
		jumpscare:SizeToContents()
		
		local hud = vgui.Create( "DCheckBoxLabel" )
		hud:SetParent(pedobearMenuF.config)
		hud:SetText("Draw HUD (Caution! This is a Garry's Mod convar)")
		hud:SetPos( 15, 90 )
		hud:SetDark( 1 )
		hud:SetConVar( "cl_drawhud" )
		hud:SetValue( GetConVar("cl_drawhud"):GetBool() )
		hud:SizeToContents()
		
		local disablehalo = vgui.Create( "DCheckBoxLabel" )
		disablehalo:SetParent(pedobearMenuF.config)
		disablehalo:SetText("Disable halos (Improve performance)")
		disablehalo:SetPos( 15, 110 )
		disablehalo:SetDark( 1 )
		disablehalo:SetConVar( "pedobear_cl_disablehalos" )
		disablehalo:SetValue( GetConVar("pedobear_cl_disablehalos"):GetBool() )
		disablehalo:SizeToContents()
		
		
		pedobearMenuF.stats = vgui.Create( "DPanel" )
		pedobearMenuF.stats:SetParent(pedobearMenuF)
		pedobearMenuF.stats:SetPos( 10, 255 )
		pedobearMenuF.stats:SetSize( 305, 215 )
		
		local statslbl = vgui.Create( "DLabel" )
		statslbl:SetParent(pedobearMenuF.stats)
		statslbl:SetText( "Chance to be a pedobear" )
		statslbl:SetPos( 10, 5 )
		statslbl:SetDark( 1 )
		statslbl:SizeToContents()
		
		local PedoChance = vgui.Create( "DListView", pedobearMenuF.stats )
		PedoChance:SetPos( 0, 20 )
		PedoChance:SetSize( 305, 195 )
		PedoChance:SetMultiSelect( false )
		PedoChance:AddColumn( "Player" )
		local who = PedoChance:AddColumn( "Chance" )
		who:SetMinWidth(40)
		who:SetMaxWidth(40)
		
		local playerlist = {}
		
		for k, v in pairs(player.GetAll()) do
			
			playerlist[k] = { name = v:GetName(), chance = math.ceil((v:GetNWFloat("XP_Pedo_PedoChance", 0) * 100)) }
			
		end
		
		for k, v in SortedPairsByMemberValue(playerlist, "chance", true) do
			
			PedoChance:AddLine( v.name, v.chance.."%" )
			
		end
		
		
		pedobearMenuF.Music = vgui.Create( "DPanel" )
		pedobearMenuF.Music:SetParent(pedobearMenuF)
		pedobearMenuF.Music:SetPos( 325, 255 )
		pedobearMenuF.Music:SetSize( 305, 215 )
		
		local musicmenulbl = vgui.Create( "DLabel" )
		musicmenulbl:SetParent(pedobearMenuF.Music)
		musicmenulbl:SetText( Either(GAMEMODE:IsSeasonalEvent("AprilFool"), "PedoRadio™", "Music") )
		musicmenulbl:SetPos( 10, 5 )
		musicmenulbl:SetDark( 1 )
		musicmenulbl:SizeToContents()
		
		local enablemusic = vgui.Create( "DCheckBoxLabel" )
		enablemusic:SetParent(pedobearMenuF.Music)
		enablemusic:SetText( Either(GAMEMODE:IsSeasonalEvent("AprilFool"), "Enable the PedoRadio™", "Enable music") )
		enablemusic:SetPos( 15, 30 )
		enablemusic:SetDark( 1 )
		enablemusic:SetConVar( "pedobear_cl_music_enable" )
		enablemusic:SetValue( GetConVar("pedobear_cl_music_enable"):GetBool() )
		enablemusic:SizeToContents()
		
		local allowexternal = vgui.Create( "DCheckBoxLabel" )
		allowexternal:SetParent(pedobearMenuF.Music)
		allowexternal:SetText("Allow external musics (Loaded from url)")
		allowexternal:SetPos( 15, 50 )
		allowexternal:SetDark( 1 )
		allowexternal:SetConVar( "pedobear_cl_music_allowexternal" )
		allowexternal:SetValue( GetConVar("pedobear_cl_music_allowexternal"):GetBool() )
		allowexternal:SizeToContents()
		
		local visualizer = vgui.Create( "DCheckBoxLabel" )
		visualizer:SetParent(pedobearMenuF.Music)
		visualizer:SetText("Enable visualizer (Downgrade performance)")
		visualizer:SetPos( 15, 70 )
		visualizer:SetDark( 1 )
		visualizer:SetConVar( "pedobear_cl_music_visualizer" )
		visualizer:SetValue( GetConVar("pedobear_cl_music_visualizer"):GetBool() )
		visualizer:SizeToContents()
		
		local playmusic = vgui.Create( "DButton" )
		playmusic:SetParent(pedobearMenuF.Music)
		playmusic:SetText( "Auto play" )
		playmusic:SetPos( 15, 190 )
		playmusic:SetSize( 125, 20 )
		playmusic:SetDisabled(!GAMEMODE.Vars.Round.PreStart and !GAMEMODE.Vars.Round.Start)
		playmusic.DoClick = function()
			GAMEMODE:Music("", GAMEMODE.Vars.Round.PreStart)
			pedobearMenuF:Close()
		end
		
		local musicmenu = vgui.Create( "DButton" )
		musicmenu:SetParent(pedobearMenuF.Music)
		musicmenu:SetText( "Mounted music list" )
		musicmenu:SetPos( 160, 190 )
		musicmenu:SetSize( 125, 20 )
		musicmenu:SetDisabled(true)
		musicmenu.DoClick = function()
			
			pedobearMenuF:Close()
		end
		
		local vollbl = vgui.Create( "DLabel" )
		vollbl:SetParent(pedobearMenuF.Music)
		vollbl:SetText( "Volume" )
		vollbl:SetPos( 125, 140 )
		vollbl:SetDark( 1 )
		vollbl:SizeToContents()
		
		local vol = GetConVar( "pedobear_cl_music_volume" )
		local musivol = vgui.Create( "Slider" )
		musivol:SetParent(pedobearMenuF.Music)
		musivol:SetPos( 15, 150 )
		musivol:SetSize( 300, 40 )
		musivol:SetValue( vol:GetFloat() )
		musivol.OnValueChanged = function( panel, value )
			vol:SetFloat(value)
		end
		
		if !GetConVar("pedobear_cl_disablexpsc"):GetBool() then
			
			local xpsc = vgui.Create( "DHTML" )
			xpsc:SetParent(pedobearMenuF)
			xpsc:SetPos( 10, 480 )
			xpsc:SetSize( 620, 128 )
			xpsc:SetAllowLua(true)
			xpsc:OpenURL( "https://xperidia.com/Showcase/?sys=pedobearMenu&zone="..tostring(GAMEMODE.Name).."&lang="..tostring(GetConVarString("gmod_language") or "en") )
			xpsc:SetScrollbars(false)
			
			xpsc_anim = Derma_Anim( "xpsc_anim", pedobearMenuF, function( pnl, anim, delta, data )
				pnl:SetSize( 640, 138*delta+480 )
			end)
			
		end
		
		
	elseif IsValid(pedobearMenuF) then
		
		pedobearMenuF:Close()
		
	end
	
end

function pedobearSCLoaded()
	if IsValid(pedobearMenuF) then xpsc_anim:Start(0.25) end
end

function GM:BeginMenu()
	
	if !IsValid(pedobearMenuBF) and !engine.IsPlayingDemo() then
		
		pedobearMenuBF = vgui.Create( "DFrame" )
		pedobearMenuBF:SetPos( ScrW()/2-320, ScrH()/2-240 )
		pedobearMenuBF:SetSize( 640, 480 )
		pedobearMenuBF:SetTitle("Welcome to the "..(GAMEMODE.Name or "?").." Gamemode V"..(GAMEMODE.Version or "?")..GAMEMODE:SeasonalEventStr())
		pedobearMenuBF:SetVisible(true)
		pedobearMenuBF:SetDraggable(true)
		pedobearMenuBF:ShowCloseButton(true)
		pedobearMenuBF:SetScreenLock(true)
		pedobearMenuBF.Paint = function( self, w, h )
			draw.RoundedBox( 4, 0, 0, w, h, Color( 0, 0, 0, 128 ) )
		end
		pedobearMenuBF.Think = function(self)
			
			local mousex = math.Clamp( gui.MouseX(), 1, ScrW()-1 )
			local mousey = math.Clamp( gui.MouseY(), 1, ScrH()-1 )
		
			if ( self.Dragging ) then
		
				local x = mousex - self.Dragging[1]
				local y = mousey - self.Dragging[2]
		
				-- Lock to screen bounds if screenlock is enabled
				if ( self:GetScreenLock() ) then
		
					x = math.Clamp( x, 0, ScrW() - self:GetWide() )
					y = math.Clamp( y, 0, ScrH() - self:GetTall() )
		
				end
		
				self:SetPos( x, y )
		
			end
				
			if ( self.Hovered && mousey < ( self.y + 24 ) ) then
				self:SetCursor( "sizeall" )
				return
			end
			
			self:SetCursor( "arrow" )

			if ( self.y < 0 ) then
				self:SetPos( self.x, 0 )
			end
			
		end
		pedobearMenuBF:MakePopup()
		pedobearMenuBF:SetKeyboardInputEnabled(false)
		
		pedobearMenuBF.one = vgui.Create( "DPanel" )
		pedobearMenuBF.one:SetParent(pedobearMenuBF)
		pedobearMenuBF.one:SetPos( 10, 30 )
		pedobearMenuBF.one:SetSize( 305, 215 )
		
		local xpucp = vgui.Create( "DButton" )
		xpucp:SetParent(pedobearMenuBF.one)
		xpucp:SetText( "Xperidia Account" )
		xpucp:SetPos( 20, 190 )
		xpucp:SetSize( 125, 20 )
		xpucp.DoClick = function()
			gui.OpenURL( "https://www.xperidia.com/UCP/" )
			pedobearMenuBF:Close()
		end
		
		local xpsteam = vgui.Create( "DButton" )
		xpsteam:SetParent(pedobearMenuBF.one)
		xpsteam:SetText( "Xperidia's Steam Group" )
		xpsteam:SetPos( 160, 190 )
		xpsteam:SetSize( 125, 20 )
		xpsteam.DoClick = function()
			gui.OpenURL( "https://xperi.link/XP-SteamGroup" )
			pedobearMenuBF:Close()
		end
		
		local onelbl = vgui.Create( "DLabel" )
		onelbl:SetParent(pedobearMenuBF.one)
		onelbl:SetText( "Welcome to the Pedobear Gamemode" )
		onelbl:SetPos( 10, 5 )
		onelbl:SetDark( 1 )
		onelbl:SizeToContents()
		
		local desclbl = vgui.Create( "DLabel" )
		desclbl:SetParent(pedobearMenuBF.one)
		desclbl:SetText( "Some controls:\n\n"..GAMEMODE:CheckBind("gm_showhelp")..": This window\n"
		..GAMEMODE:CheckBind("gm_showteam")..": Change team\n"
		..GAMEMODE:CheckBind("gm_showspare1")..": Taunt menu\n"
		.."1-9: Quick taunt\n"
		..GAMEMODE:CheckBind("+menu_context")..": Toggle thirdperson" )
		desclbl:SetPos( 20, 30 )
		desclbl:SetDark( 1 )
		desclbl:SizeToContents()
		
		local hflbl = vgui.Create( "DLabel" )
		hflbl:SetParent(pedobearMenuBF.one)
		hflbl:SetText( "Have fun!" )
		hflbl:SetPos( 130, 150 )
		hflbl:SetDark( 1 )
		hflbl:SizeToContents()
		
	end
	
end