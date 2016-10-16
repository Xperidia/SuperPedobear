function GM:TauntMenuF()
	
	if !IsValid(GAMEMODE.TauntMenu) and !engine.IsPlayingDemo() then
		
		local sx, sy = 320, ScrH()*0.5
		local ply = LocalPlayer()
		
		GAMEMODE.TauntMenu = vgui.Create( "DFrame" )
		GAMEMODE.TauntMenu:SetPos( ScrW()/2-sx/2, ScrH()/2-sy/2 )
		GAMEMODE.TauntMenu:SetSize( sx, sy )
		GAMEMODE.TauntMenu:SetTitle("Taunt menu")
		GAMEMODE.TauntMenu:SetVisible(true)
		GAMEMODE.TauntMenu:SetDraggable(true)
		GAMEMODE.TauntMenu:ShowCloseButton(true)
		GAMEMODE.TauntMenu:SetScreenLock(true)
		GAMEMODE.TauntMenu.Paint = function( self, w, h )
			draw.RoundedBox( 4, 0, 0, w, h, Color( 0, 0, 0, 128 ) )
		end
		GAMEMODE.TauntMenu.Think = function(self)
			
			if !ply:Alive() or ( ply:Team()!=TEAM_VICTIMS and ply:Team()!=TEAM_PEDOBEAR ) then
				GAMEMODE.TauntMenu:SetTitle("Taunt menu (You can't taunt now!)")
				GAMEMODE.TauntMenu.play:SetEnabled(false)
				GAMEMODE.TauntMenu.random:SetEnabled(false)
			elseif ply.TauntCooldown and ply.TauntCooldown-CurTime()+0.1>0 then
				local cd = math.ceil(ply.TauntCooldown-CurTime()+0.1)
				GAMEMODE.TauntMenu:SetTitle("Taunt menu (Cooldown: "..cd.."s)")
				GAMEMODE.TauntMenu.play:SetEnabled(false)
				GAMEMODE.TauntMenu.random:SetEnabled(false)
			else
				GAMEMODE.TauntMenu:SetTitle("Taunt menu")
				GAMEMODE.TauntMenu.play:SetEnabled(true)
				GAMEMODE.TauntMenu.random:SetEnabled(true)
			end
			
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
		GAMEMODE.TauntMenu:MakePopup()
		GAMEMODE.TauntMenu:SetKeyboardInputEnabled(false)
		
		local AppList = vgui.Create( "DListView", GAMEMODE.TauntMenu )
		AppList:SetPos( 0, 20 )
		AppList:SetSize( sx, sy-80 )
		AppList:SetMultiSelect( false )
		local id = AppList:AddColumn( "ID" )
		id:SetMinWidth(20)
		id:SetMaxWidth(20)
		local tauntc = AppList:AddColumn( "Taunt" )
		local who = AppList:AddColumn( "Who" )
		who:SetMinWidth(64)
		who:SetMaxWidth(64)
		
		function AppList:DoDoubleClick( lineID, line )
			
			GAMEMODE:StartTaunt(lineID)
			
			if !GetConVar("pedobear_cl_disabletauntmenuclose"):GetBool() then GAMEMODE.TauntMenu:Close() end
			
		end
		
		local whostr = "Unknown"
		
		for k,v in pairs(GAMEMODE.Sounds.Taunts) do
			
			local whostr = "Unknown"
			
			if v[3]==0 then
				whostr = "Everyone"
			elseif v[3]==TEAM_VICTIMS then
				whostr = "Victims"
			elseif v[3]==TEAM_PEDOBEAR then
				whostr = "Pedobear"
			end
			
			AppList:AddLine( k, v[1], whostr )
			
		end
		
		GAMEMODE.TauntMenu.play = vgui.Create( "DButton", GAMEMODE.TauntMenu )
		GAMEMODE.TauntMenu.play:SetText( "PLAY" )
		GAMEMODE.TauntMenu.play:SetPos( 0, sy-60 )
		GAMEMODE.TauntMenu.play:SetSize( sx, 30 )
		GAMEMODE.TauntMenu.play.DoClick = function()
			local taunt = AppList:GetSelectedLine()
			GAMEMODE:StartTaunt(taunt)
			if !GetConVar("pedobear_cl_disabletauntmenuclose"):GetBool() then GAMEMODE.TauntMenu:Close() end
		end
		
		GAMEMODE.TauntMenu.random = vgui.Create( "DButton", GAMEMODE.TauntMenu )
		GAMEMODE.TauntMenu.random:SetText( "RANDOM" )
		GAMEMODE.TauntMenu.random:SetPos( 0, sy-30 )
		GAMEMODE.TauntMenu.random:SetSize( sx, 30 )
		GAMEMODE.TauntMenu.random.DoClick = function()
			
			local sel = {}
			
			for k,v in pairs(GAMEMODE.Sounds.Taunts) do
				
				if v[3]==ply:Team() or v[3]==0 then
					
					table.insert( sel, v )
					
				end
				
			end
			
			local selid = math.random( 1, #sel )
			
			GAMEMODE:StartTaunt(selid)
			
			if !GetConVar("pedobear_cl_disabletauntmenuclose"):GetBool() then GAMEMODE.TauntMenu:Close() end
			
		end
		
	elseif IsValid(GAMEMODE.TauntMenu) then
		
		GAMEMODE.TauntMenu:Close()
		
	end
	
end