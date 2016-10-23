include( 'shared.lua' )
include( 'cl_scoreboard.lua' )
include( 'cl_menu.lua' )
include( 'cl_tauntmenu.lua' )
include( 'cl_voice.lua' )
include( 'cl_deathnotice.lua' )

DEFINE_BASECLASS( "gamemode_base" )

surface.CreateFont( "XP_Pedo_TIME", {
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
} )
surface.CreateFont( "XP_Pedo_RND", {
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
} )
surface.CreateFont( "XP_Pedo_TXT", {
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
} )
surface.CreateFont( "XP_Pedo_HT", {
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
} )
surface.CreateFont( "XP_Pedo_HUDname", {
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
} )

net.Receive("XP_Pedo_PlayerStats", function( len )

	GAMEMODE.Vars.victims = net.ReadInt(32)
	GAMEMODE.Vars.downvictims = net.ReadInt(32)
	
end)

net.Receive("XP_Pedo_Vars", function( len )

	GAMEMODE.Vars.Round.Start = tobool(net.ReadBool())
	GAMEMODE.Vars.Round.PreStart = tobool(net.ReadBool())
	GAMEMODE.Vars.Round.PreStartTime = net.ReadFloat()
	GAMEMODE.Vars.Round.Time = net.ReadFloat()
	GAMEMODE.Vars.Round.End = tobool(net.ReadBool())
	GAMEMODE.Vars.Round.Win = net.ReadInt(32)
	GAMEMODE.Vars.Rounds = net.ReadInt(32)
	GAMEMODE.Vars.Round.LastTime = net.ReadFloat()
	
end)

net.Receive("XP_Pedo_Music", function( len )
	
	local src = net.ReadString()
	local pre = net.ReadBool()
	
	GAMEMODE:Music(src, pre)
	
end)

net.Receive("XP_Pedo_AFK", function( len )
	
	GAMEMODE.Vars.AfkTime = net.ReadFloat()
	
	if GAMEMODE.Vars.AfkTime != 0 then system.FlashWindow() chat.PlaySound() end
	
end)

net.Receive("XP_Pedo_MusicList", function( len )
	
	GAMEMODE.Musics.musics = net.ReadTable()
	GAMEMODE.Musics.premusics = net.ReadTable()
	
end)

hook.Add("HUDShouldDraw", "HideHUD", function( name )
	
	local HUDhide = {
		CHudHealth = true, 
		CHudBattery = true,
		CHudDamageIndicator = true,
		CHudWeaponSelection = true,
		CHudZoom = true
	}
	if name=="CHudCrosshair" and LocalPlayer():Team()==TEAM_UNASSIGNED then
		return false
	elseif ( HUDhide[ name ] ) then
		return false
	end
	
end)

function GM:FormatTime(time)
	
	local timet = string.FormattedTime( time )
	
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
	return string.gsub(str, "(%a)([%w_']*)", function( first, rest ) return first:upper()..rest:lower() end)
end

function GM:HUDPaint()
	
	if ( GetConVarNumber( "cl_drawhud" ) == 0 ) then return end
	
	hook.Run( "HUDDrawTargetID" )
	hook.Run( "DrawDeathNotice", 0.85, 0.04 )
	
	local function yay(a) return (math.sin(CurTime()*6)+1)/2*a end
	local ply = LocalPlayer()
	local sply = ply:GetObserverTarget() or ply
	if !sply:IsPlayer() then
		sply = ply
	end
	local col = sply:GetPlayerColor():ToColor()
	if !sply:Alive() then col = team.GetColor( sply:Team() ) end
	
	local wi = true
	local str = "Victims Left: "..(GAMEMODE.Vars.victims or 0)
	local str2 = 'Victims "Captured": '..(GAMEMODE.Vars.downvictims or 0)
	if !string.match( GetHostName(), "Ollie's Mod" ) then str2 = "Victims Raped: "..(GAMEMODE.Vars.downvictims or 0) end
	local timestr = "00:00"
	local rnd = "Round "..(GAMEMODE.Vars.Rounds or 0)
	if GAMEMODE.Vars.Rounds and GAMEMODE.Vars.Rounds > 999 then
		rnd = "Round ∞"
	end
	local str4 = ""
	
	if !sply:Alive() or ( sply:Team()!=TEAM_PEDOBEAR and sply:Team()!=TEAM_VICTIMS ) then
		wi = false
	end
	
	if GAMEMODE.Vars.Round.Start then
		
		draw.RoundedBoxEx( 16, 0, ScrH()/2-10, 330, 100, Color( 0, 0, 0, 200 ), false, true, false, true )
		draw.DrawText( str.."\n"..str2, "XP_Pedo_TXT", 320, ScrH()/2, Color( 255, 255, 255, 255 ), TEXT_ALIGN_RIGHT )
		
	end
	
	
	if GAMEMODE.Vars.Round.PreStartTime and GAMEMODE.Vars.Round.PreStartTime - CurTime() >= 0 then
		timestr = GAMEMODE:FormatTime(GAMEMODE.Vars.Round.PreStartTime - CurTime())
	elseif GAMEMODE.Vars.Round.Time and GAMEMODE.Vars.Round.Time - CurTime() >= 0 then
		timestr = GAMEMODE:FormatTime(GAMEMODE.Vars.Round.Time - CurTime())
	elseif GAMEMODE.Vars.Round.End or GAMEMODE.Vars.Round.TempEnd then
		timestr = GAMEMODE:FormatTime(GAMEMODE.Vars.Round.LastTime)
	elseif !GAMEMODE.Vars.Round.Start and !GAMEMODE.Vars.Round.PreStart then
		timestr = GAMEMODE:FormatTime(pedobear_round_pretime:GetFloat())
	end
	
	draw.DrawText( timestr, "XP_Pedo_TIME", ScrW()/2, 0, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
	
	draw.DrawText( rnd, "XP_Pedo_RND", ScrW()/2, 60, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
	
	if !GAMEMODE.Vars.Round.Start and !GAMEMODE.Vars.Round.PreStart and GAMEMODE.Vars.victims<2 then
		
		draw.RoundedBox( 16, ScrW()/2-200, 110, 400, 55, Color( 0, 0, 0, 200 ) )
		draw.DrawText( "Waiting for players", "XP_Pedo_RND", ScrW()/2, 110, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
		
	elseif GAMEMODE.Vars.Round.PreStart then
		
		draw.RoundedBox( 16, ScrW()/2-125, 110, 250, 55, Color( 0, 0, 0, 200 ) )
		draw.DrawText( "Preparing...", "XP_Pedo_RND", ScrW()/2, 110, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
		
	end
	
	if GAMEMODE.Vars.AfkTime and GAMEMODE.Vars.AfkTime - CurTime() >= 0 then
		draw.RoundedBox( 16, ScrW()/2-300, 165, 600, 210, Color( 0, 0, 0, 200 ) )
		draw.DrawText( "Hey you're kind of afk!\nIf you're still afk in "..GAMEMODE:FormatTime(GAMEMODE.Vars.AfkTime - CurTime()).."\nYou will be kicked out\n of the role of Pedobear", "XP_Pedo_RND", ScrW()/2, 165, Color( 255, yay(255), yay(255), 255 ), TEXT_ALIGN_CENTER )
	end
	
	if ply:Alive() and !GAMEMODE.Vars.Round.Start and ply:Team()==TEAM_VICTIMS then
		
		draw.RoundedBox( 8, ScrW()/2-270, ScrH()-90, 540, 75, Color( 0, 0, 0, 200 ) )
		if GAMEMODE:IsSeasonalEvent("AprilFool") then draw.DrawText("PedoTips™", "DermaDefault", ScrW()/2-270, ScrH()-90, Color(255, 255, 255, 64), TEXT_ALIGN_LEFT) end
		draw.DrawText( GAMEMODE:CheckBind("+attack").." to weld a prop to another\n"..GAMEMODE:CheckBind("+attack2").." to unweld a prop\n"..GAMEMODE:CheckBind("+reload").." to create a clone (Only one clone at the same time)", "XP_Pedo_HT", ScrW()/2, ScrH()-90, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
		
	elseif ply:Alive() and ply:Team()==TEAM_PEDOBEAR then
		
		draw.RoundedBox( 8, ScrW()/2-180, ScrH()-90, 360, 75, Color( 0, 0, 0, 200 ) )
		if GAMEMODE:IsSeasonalEvent("AprilFool") then draw.DrawText("PedoTips™", "DermaDefault", ScrW()/2-180, ScrH()-90, Color(255, 255, 255, 64), TEXT_ALIGN_LEFT) end
		draw.DrawText( "You're a Pedobear!\n"..GAMEMODE:CheckBind("+attack").." to break props\nNow start chasing some little girls! ( ͡° ͜ʖ ͡°)", "XP_Pedo_HT", ScrW()/2, ScrH()-90, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
		
	end
	
	if GAMEMODE.Vars.welding and ply:Alive() and ply:Team()==TEAM_VICTIMS then
		
		draw.RoundedBox( 8, ScrW()/2-150, ScrH()/2+100, 300, 26, Color( 0, 0, 0, yay(200) ) )
		draw.DrawText( "Click another prop or world", "XP_Pedo_HT", ScrW()/2, ScrH()/2+100, Color( 255, 255, 255, yay(255) ), TEXT_ALIGN_CENTER )
		
	end
	
	if ply:Team()==TEAM_UNASSIGNED then
		
		draw.RoundedBox( 8, ScrW()/2-160, ScrH()/2-20, 320, 40, Color( 0, 0, 0, yay(200) ) )
		draw.DrawText( "Press any key to join!", "XP_Pedo_TXT", ScrW()/2, ScrH()/2-20, Color( 255, 255, 255, yay(255) ), TEXT_ALIGN_CENTER )
		
	elseif ply:Team()==TEAM_VICTIMS and !GAMEMODE.Vars.Round.Start and !ply:Alive() then
		
		draw.RoundedBox( 8, ScrW()/2-200, ScrH()/2-20, 400, 40, Color( 0, 0, 0, yay(200) ) )
		draw.DrawText( "Press any key to respawn!", "XP_Pedo_TXT", ScrW()/2, ScrH()/2-20, Color( 255, 255, 255, yay(255) ), TEXT_ALIGN_CENTER )
		
	end
	
	
	if wi and (sply:GetModel()=="models/player/pbear/pbear.mdl" or sply:GetModel()=="models/player/kuristaja/pbear/pbear.mdl") then
		surface.SetDrawColor(255, 255, 255, 255 )
		surface.SetMaterial( Material("pedo/pedobear") )
		surface.DrawTexturedRectUV(0, ScrH()-200, 200, 200, 0, 0, 1, 1)
	elseif ply:Team()!=TEAM_UNASSIGNED and sply:Team()!=TEAM_SPECTATOR then
		self:DrawHealthFace(sply)
	end
	
	if GAMEMODE.Vars.Round.End then str4 = "Draw game!" end
	if GAMEMODE.Vars.Round.End and GAMEMODE.Vars.Round.Win==TEAM_VICTIMS then str4 = "The victims wins!" end
	if GAMEMODE.Vars.Round.End and GAMEMODE.Vars.Round.Win==TEAM_PEDOBEAR then str4 = "Pedobear captured everyone!" end
	draw.DrawText( str4, "XP_Pedo_TXT", ScrW()/2, ScrH()/2-80, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
	
	if ply:Team()!=TEAM_UNASSIGNED and sply:Team()!=TEAM_SPECTATOR then
		draw.DrawText( sply:Nick(), "XP_Pedo_HUDname", 100+1, ScrH()-200+1, Color( 0, 0, 0, 255 ), TEXT_ALIGN_CENTER )
		draw.DrawText( sply:Nick(), "XP_Pedo_HUDname", 100, ScrH()-200, col, TEXT_ALIGN_CENTER )
	end
	
	if IsValid(GAMEMODE.Vars.Music) then
		
		local time = GAMEMODE.Vars.Music:GetTime()
		local totaltime = GAMEMODE.Vars.Music:GetLength()
		local left, right = GAMEMODE.Vars.Music:GetLevel()
		local muh = math.max(left, right)
		local function meh(mu) return math.Remap(mu, 0, 1, 0, 255) end
		local function volcolor(mu) return Color( meh(mu), 255-meh(mu), 0, 200 ) end
		local visuok = GetConVar("pedobear_cl_music_visualizer"):GetBool() and GAMEMODE.Vars.Music:GetState()==GMOD_CHANNEL_PLAYING
		local visspace = 48
		if visuok then
			visspace = 0
		end
		
		if GAMEMODE:IsSeasonalEvent("AprilFool") then draw.DrawText("PedoRadio™", "DermaDefault", ScrW(), ScrH()-100+visspace, Color(255, 255, 255, 64), TEXT_ALIGN_RIGHT) end
		
		draw.RoundedBoxEx( 16, ScrW()-256, ScrH()-100+visspace, 256, 100-visspace, Color( 0, 0, 0, 200 ), true, false, false, false )
		
		local title = "♪ "..GAMEMODE:PrettyMusicName(string.GetFileFromFilename(GAMEMODE.Vars.Music:GetFileName())).." ♪"
		draw.DrawText( title, "XP_Pedo_HUDname", ScrW()-127, ScrH()-99+visspace, Color( 0, 0, 0, 255 ), TEXT_ALIGN_CENTER )
		draw.DrawText( title, "XP_Pedo_HUDname", ScrW()-128, ScrH()-100+visspace, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER )
		
		draw.RoundedBox( 0, ScrW()-256, ScrH()-80+visspace, 256, 16, Color( 0, 0, 0, 200 ) ) --Timetrack
		draw.RoundedBox( 3, ScrW()-256, ScrH()-77+visspace, math.Remap( time, 0, totaltime, 0, 256 ), 10, Color(255, 255, 255, 200) )
		
		draw.RoundedBox( 0, ScrW()-256, ScrH()-64+visspace, 256, 16, Color( 0, 0, 0, 200 ) ) --Wub
		draw.RoundedBox( 0, ScrW()-256, ScrH()-56+visspace, math.Remap(left, 0, 1, 0, 256), 8, volcolor(left) )
		draw.RoundedBox( 0, ScrW()-256, ScrH()-64+visspace, math.Remap(right, 0, 1, 0, 256), 8, volcolor(right) )
		
		surface.SetDrawColor( 0, 0, 0, 255 )
		surface.DrawLine( ScrW()-256, ScrH()-64+visspace, ScrW(), ScrH()-64+visspace )
		surface.DrawLine( ScrW()-256, ScrH()-48+visspace, ScrW(), ScrH()-48+visspace )
		
		draw.RoundedBox( 4, ScrW()-196, ScrH()-80+visspace, 136, 16, Color( 0, 0, 0, 220 ) ) --Time
		local timetxt = GAMEMODE:FormatTimeTri(time).."/"..GAMEMODE:FormatTimeTri(totaltime)
		draw.DrawText( timetxt, "XP_Pedo_HUDname", ScrW()-127, ScrH()-81+visspace, Color( 0, 0, 0, 255 ), TEXT_ALIGN_CENTER )
		draw.DrawText( timetxt, "XP_Pedo_HUDname", ScrW()-128, ScrH()-82+visspace, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER )
		
		if visuok then
			
			local eqd = {}
			
			GAMEMODE.Vars.Music:FFT(eqd, 0)
			
			draw.RoundedBox( 0, ScrW()-256, ScrH()-48, 256, 48, Color( 0, 0, 0, 200 ) )
			
			for k, v in pairs(eqd) do
				local on = math.Clamp(math.Remap(v, 0, 1 / k, 0, 48), 0, 48)
				local b = math.Clamp(math.Remap(v, 0, 1 / k, 0, 1), 0, 1)
				draw.RoundedBoxEx( 0, ScrW()-256+(k-1)*2, ScrH()-on, 2, on, volcolor(b), false, true, false, true )
			end
			
		end
		
	end
	
end

function GM:HUDPaintBackground()
	
	if ( GetConVarNumber( "cl_drawhud" ) == 0 ) then return end
	
	local ply = LocalPlayer()
	local sply = ply:GetObserverTarget() or ply
	if !sply:IsPlayer() then
		sply = ply
	end
	
	draw.RoundedBoxEx( 16, ScrW()/2-100, 0, 200, 110, Color( 0, 0, 0, 200 ), false, false, GAMEMODE.Vars.Round.Start, GAMEMODE.Vars.Round.Start )
	
	if ( sply:Team()==TEAM_PEDOBEAR or sply:Team()==TEAM_VICTIMS ) then
		
		local col = sply:GetPlayerColor():ToColor()
		if !sply:Alive() then col = team.GetColor( sply:Team() ) end
		local life = Either(sply:Alive(), 1, 0)
		local stamina = 200
		local propheal = 200
		local taunt = 200
		local sprintlock = ply.SprintLock
		
		if ply != sply and sply:Alive() and sply:Team() == TEAM_VICTIMS then
			stamina = math.Remap(sply:GetNWInt( "SprintV", 100 ), 0, 100, 1, 200)
			sprintlock = sply:GetNWInt( "SprintLock", false )
		elseif ply:Alive() and ply.SprintV and ply.SprintV < 100 and ply:Team() == TEAM_VICTIMS then
			stamina = math.Remap(ply.SprintV, 0, 100, 1, 200)
		end
		
		if ply != sply and sply:Alive() then
			
			local LastTaunt = sply:GetNWInt( "LastTaunt", 0 )
			local TauntCooldown = sply:GetNWInt( "TauntCooldown", 0 ) - CurTime()
			local TauntCooldownF = sply:GetNWInt( "TauntCooldownF", 5 )
			
			if LastTaunt > 0 and TauntCooldown > 0 then
				
				taunt = math.Remap(TauntCooldown, 0, TauntCooldownF, 200, 1)
				
			end
			
		elseif ply:Alive() and ply.LastTaunt and ply.TauntCooldown-CurTime() > 0 then
			
			taunt = math.Remap(ply.TauntCooldown-CurTime(), 0, ply.TauntCooldownF, 200, 1)
			
		end
		
		if sply:Alive() then
			
			local PropHealCD = sply:GetNWInt( "PropHealCD", 0 ) - CurTime()
			
			if PropHealCD > 0 then
				propheal = math.Remap(PropHealCD, 0, 30, 200, 1)
			end
			
		end
		
		draw.RoundedBoxEx( 8, 0, ScrH()-200, 200, 200, Color( 0, 0, 0, 200 ), false, true, false, false )
		
		draw.RoundedBoxEx( 8, 0, ScrH()-200, 200, 200, Color( col.r*life, col.g*life, col.b*life, 150*life ), false, true, false, false )
		
		if stamina!=200 then
			draw.RoundedBoxEx( 2, 200, ScrH()-175, 200, 50, Color( 0, 0, 0, 200 ), false, true, false, true )
			draw.RoundedBoxEx( 2, 200, ScrH()-175, stamina, 50, Color( col.r, col.g, col.b, 150*life ), false, true, false, true )
			draw.DrawText( "Stamina", "XP_Pedo_TXT", 300, ScrH()-170, Either(ply.SprintLock, Color( 255, 0, 0, 255 ), Color( 255, 255, 255, 255 )), TEXT_ALIGN_CENTER )
		end
		
		if propheal!=200 and ply:Team()==TEAM_VICTIMS then
			draw.RoundedBoxEx( 2, 200, ScrH()-125, 200, 50, Color( 0, 0, 0, 200 ), false, true, false, true )
			draw.RoundedBoxEx( 2, 200, ScrH()-125, propheal, 50, Color( col.r, col.g, col.b, 150*life ), false, true, false, true )
			draw.DrawText( "Prop healing", "XP_Pedo_TXT", 300, ScrH()-120, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
		end
		
		if taunt!=200 then
			draw.RoundedBoxEx( 2, 200, ScrH()-75, 200, 50, Color( 0, 0, 0, 200 ), false, true, false, true )
			draw.RoundedBoxEx( 2, 200, ScrH()-75, taunt, 50, Color( col.r, col.g, col.b, 150*life ), false, true, false, true )
			draw.DrawText( "Taunt", "XP_Pedo_TXT", 300, ScrH()-70, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
		end
		
	end
	
	draw.DrawText(GAMEMODE.Name.." Gamemode V"..GAMEMODE.Version, "DermaDefault", ScrW()/2, 0, Color(255, 255, 255, 64), TEXT_ALIGN_CENTER)
	if GAMEMODE:IsSeasonalEvent("AprilFool") then draw.DrawText("PedoFrame™", "DermaDefault", 1, ScrH()-200, Color(255, 255, 255, 64), TEXT_ALIGN_LEFT) end
	
end

function GM:CreateHealthFace(ply)
	self.HealthFace = ClientsideModel(ply:GetModel(), RENDER_GROUP_OPAQUE_ENTITY)
	self.HealthFace:SetNoDraw( true )
	local iSeq = self.HealthFace:LookupSequence( "idle_passive" )
	if ( iSeq <= 0 ) then iSeq = self.HealthFace:LookupSequence( "walk_all" ) end
	if ( iSeq <= 0 ) then iSeq = self.HealthFace:LookupSequence( "WalkUnarmed_all" ) end
	if ( iSeq <= 0 ) then iSeq = self.HealthFace:LookupSequence( "walk_all_moderate" ) end
	if ( iSeq > 0 ) then
		self.HealthFace:SetSequence( iSeq )
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
		self.HealthFace:SetBodygroup( v["id"], ply:GetBodygroup( v["id"] ) )
	end
	
end

local function SameBodyGroups(self, ply)
	for k, v in pairs(self:GetBodyGroups()) do
		if self:GetBodygroup( v.id ) != ply:GetBodygroup( v.id ) then return false end
	end
	return true
end

function GM:DrawHealthFace(ply)
	
	local x = 0
	local w,h = 200, 200
	h = w
	local y = ScrH() - h

	local ps = 0.0

	if !IsValid(self.HealthFace) then
		self:CreateHealthFace(ply)
	end

	if IsValid(self.HealthFace) then
		
		if self.HealthFace:GetModel() != ply:GetModel() or self.HealthFace:GetSkin() != ply:GetSkin() or !SameBodyGroups(self.HealthFace, ply) then
			self:CreateHealthFace(ply)
		end
		
		local seq = ply:GetSequence()
		local seqname = ply:GetSequenceName( seq )
		-- if seqname == "walk_all" or seqname == "run_all_01" or seqname == "swimming_all" then
			-- seq = ply:LookupSequence( "menu_walk" )
			-- seqname = ply:GetSequenceName( seq )
		-- end
		
		if !ply:Alive() and self.LastSeq!=0 then
			local iSeq = 0
			self.HealthFace:SetSequence( iSeq )
			self.HealthFace:ResetSequenceInfo()
			self.HealthFace:SetCycle(0)
			self.HealthFace:SetPlaybackRate(1)
			self.LastSeq = iSeq
		elseif ply:Alive() and self.LastSeq != seq then
			local iSeq = seq or 0
			self.HealthFace:SetSequence( iSeq )
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

		cam.Start3D( pos + Vector(19, 0, 2), Vector(-1,0,0):Angle(), 70, x, y, w, h, 5, 4096 )
		cam.IgnoreZ( true )
		
		render.OverrideDepthEnable( false )
		render.SuppressEngineLighting( true )
		render.SetLightingOrigin(pos)
		local life = math.Remap(ply:Health(),0,ply:GetMaxHealth(),0,1) or 0
		render.ResetModelLighting(life, life, life)
		render.SetColorModulation(1, 1, 1)
		render.SetBlend(1)
		
		self.HealthFace:DrawModel()
		
		render.SuppressEngineLighting( false )
		cam.IgnoreZ( false )
		cam.End3D()

	end

	render.SetStencilEnable( false )
 
	render.SetStencilWriteMask( 0 )
	render.SetStencilReferenceValue( 0 )
	render.SetStencilTestMask( 0 )
	render.SetStencilEnable( false )
	render.OverrideDepthEnable( false )
	render.SetBlend( 1 )
	
	cam.IgnoreZ( false )
end

net.Receive( "XP_Pedo_Notif", function( len )
	
	local str = net.ReadString() or ""
	local ne = net.ReadInt(3) or 0
	local dur = net.ReadFloat() or 5
	local sound = net.ReadBit() or false
	
	GAMEMODE:Notif(str,ne,dur,sound)
	
end)
function GM:Notif(str,ne,dur,sound)
	notification.AddLegacy(str,ne,dur,sound)
	if !tobool(sound) then return end
	if ne==NOTIFY_HINT then
		surface.PlaySound( "ambient/water/drip"..math.random(1, 4)..".wav" )
	elseif ne==NOTIFY_ERROR then
		surface.PlaySound( "buttons/button10.wav" )
	else
		chat.PlaySound()
	end
end

function GM:HUDDrawTargetID()

	local tr = util.GetPlayerTrace( LocalPlayer() )
	local trace = util.TraceLine( tr )
	if ( !trace.Hit ) then return end
	if ( !trace.HitNonWorld ) then return end
	local ply = LocalPlayer()
	if ply:GetObserverMode() == OBS_MODE_CHASE then return end
	
	local text = ""
	local font = "DermaLarge"
	
	if ( trace.Entity:IsPlayer() and trace.Entity:Team() == TEAM_VICTIMS ) or trace.Entity:GetClass() == "pedo_dummy" then
		text = trace.Entity:Nick()
	elseif trace.Entity:IsPlayer() and ply:Team() == TEAM_PEDOBEAR then
		text = trace.Entity:Nick()
	end
	
	surface.SetFont( font )
	local w, h = surface.GetTextSize( text )
	
	local MouseX, MouseY = ScrW() / 2, ScrH() * 0.7
	
	local x = MouseX
	local y = MouseY
	
	x = x - w / 2
	y = y + 30
	
	draw.SimpleText( text, font, x + 1, y + 1, Color( 0, 0, 0, 255 ) )
	draw.SimpleText( text, font, x + 2, y + 2, Color( 0, 0, 0, 126 ) )
	if ( trace.Entity:IsPlayer() and trace.Entity:Team() == TEAM_VICTIMS ) or trace.Entity:GetClass() == "pedo_dummy" then
		local col = trace.Entity:GetPlayerColor():ToColor()
		draw.SimpleText( text, font, x, y, col )
	elseif trace.Entity:IsPlayer() then
		draw.SimpleText( text, font, x, y, self:GetTeamColor( trace.Entity ) )
	end
	
	if trace.Entity:IsPlayer() and trace.Entity:Team()==TEAM_VICTIMS and trace.Entity:Health()>0 then
		
		y = y + h + 5
		
		local text = trace.Entity:Health() .. "%"
		local font = "DermaLarge"
		
		surface.SetFont( font )
		local w, h = surface.GetTextSize( text )
		local x = MouseX - w / 2
		
		draw.SimpleText( text, font, x + 1, y + 1, Color( 0, 0, 0, 255 ) )
		draw.SimpleText( text, font, x + 2, y + 2, Color( 0, 0, 0, 126 ) )
		draw.SimpleText( text, font, x, y, self:GetTeamColor( trace.Entity ) )
		
	end

end

hook.Add( "PreDrawHalos", "fnafgmHalos", function()
	
	if GetConVar("pedobear_cl_disablehalos"):GetBool() then return end
	
	local ply = LocalPlayer()
	local tab = {}
	local tab2 = {}
	local tab3 = {}
	
	if ply:Team() == TEAM_VICTIMS then
		
		if !ply:Alive() then
			
			for k,v in pairs(player.GetAll()) do
				if v:Team()==TEAM_VICTIMS and v:Alive() then
					table.insert(tab, v)
				end
			end
			halo.Add( tab, team.GetColor(TEAM_VICTIMS), 1, 1, 1, true, true )
			
			for k,v in pairs(ents.FindByClass( "pedo_dummy" )) do
				table.insert(tab3, v)
			end
			halo.Add( tab3, Color(0,0,255), 1, 1, 1, true, true )
			
		else
			
			for k,v in pairs(ents.FindByClass( "pedo_dummy" )) do
				if v:GetPlayer()==ply then
					table.insert(tab3, v)
				end
			end
			halo.Add( tab3, Color(0,0,255), 1, 1, 1, true, true )
			
		end
		
		for k,v in pairs(player.GetAll()) do
			if v:Team()==TEAM_PEDOBEAR and v:Alive() then
				table.insert(tab2, v)
			end
		end
		halo.Add( tab2, team.GetColor(TEAM_PEDOBEAR), 1, 1, 1, true, !ply:Alive() )
		
		if GAMEMODE.Vars.welding then
			
			halo.Add( { GAMEMODE.Vars.welding[1] }, Color(255,255,255), 1, 1, 1, true, false )
			
		end
		
	elseif ply:Team() == TEAM_PEDOBEAR then
		
		for k,v in pairs(player.GetAll()) do
			if v:Team() == TEAM_PEDOBEAR and v:Alive() then
				table.insert(tab, v)
			end
		end
		halo.Add( tab, team.GetColor(TEAM_PEDOBEAR), 1, 1, 1, true, true )
		
	elseif ply:Team()==TEAM_SPECTATOR then
		
		for k,v in pairs(player.GetAll()) do
			if v:Team()==TEAM_VICTIMS and v:Alive() then
				table.insert(tab, v)
			end
		end
		
		for k,v in pairs(player.GetAll()) do
			if v:Team()==TEAM_PEDOBEAR and v:Alive() then
				table.insert(tab2, v)
			end
		end
		
		halo.Add( tab, team.GetColor(TEAM_VICTIMS), 1, 1, 1, true, true )
		halo.Add( tab2, team.GetColor(TEAM_PEDOBEAR), 2, 2, 2, true, true )
	
	end
	
end )

function GM:ShowTeam()

	if !IsValid( self.TeamSelectFrame ) then
		
		self.TeamSelectFrame = vgui.Create( "DFrame" )
		self.TeamSelectFrame:SetTitle( "Pick Team" )
		
		local AllTeams = team.GetAllTeams()
		local x = 4
		local y = 156
		for ID, TeamInfo in pairs ( AllTeams ) do
		
			if ( ID != TEAM_CONNECTING && ID != TEAM_UNASSIGNED ) and team.Joinable(ID) then
		
				local Team = vgui.Create( "DButton", self.TeamSelectFrame )
				function Team.DoClick() self:HideTeam() RunConsoleCommand( "changeteam", ID ) end
				Team:SetPos( x, 24 )
				Team:SetSize( 256, 128 )
				Team:SetText( TeamInfo.Name )
				Team:SetTextColor( TeamInfo.Color )
				Team:SetFont("DermaLarge")
				Team:SetExpensiveShadow( 1, Color(0,0,0,255) )
				
				if ( IsValid( LocalPlayer() ) && LocalPlayer():Team() == ID ) then
					Team:SetDisabled( true )
					Team:SetTextColor( Color(40, 40, 40) )
					Team.Paint = function( self, w, h )
						draw.RoundedBox( 4, 4, 4, w-8, h-8, Color( 0, 0, 0, 150 ) )
					end
				else
					Team:SetTextColor( TeamInfo.Color )
					Team.Paint = function( self, w, h )
						draw.RoundedBox( 4, 4, 4, w-8, h-8, Color( 255, 255, 255, 150 ) )
					end
				end
				
				x = x + 256
			
			end
			
		end
	
		if ( GAMEMODE.AllowAutoTeam ) then
		
			local Team = vgui.Create( "DButton", self.TeamSelectFrame )
			function Team.DoClick() self:HideTeam() RunConsoleCommand( "autoteam" ) end
			Team:SetPos( 4+x/3, 280 )
			Team:SetSize( x/3-4, 32 )
			Team:SetText( "Auto" )
			Team:SetTextColor( GAMEMODE.Colors_default )
			Team:SetFont("DermaLarge")
			Team.Paint = function( self, w, h )
				draw.RoundedBox( 4, 4, 4, w-8, h-8, Color( 255, 255, 255, 150 ) )
			end
			
			y = y + 32
		
		end
		
		self.TeamSelectFrame:SetSize( x+4, y )
		self.TeamSelectFrame:SetDraggable( true )
		self.TeamSelectFrame:SetScreenLock(true)
		self.TeamSelectFrame:SetPaintShadow(true)
		self.TeamSelectFrame:Center()
		self.TeamSelectFrame:MakePopup()
		self.TeamSelectFrame:SetKeyboardInputEnabled( false )
		self.TeamSelectFrame.Paint = function( self, w, h )
			draw.RoundedBox( 4, 0, 0, w, h, Color( 0, 0, 0, 128 ) )
		end
		
	else
		self.TeamSelectFrame:Close()
	end
	
end

function GM:Think()
	
	local ply = LocalPlayer()
	
	if ply:Team()==TEAM_VICTIMS and ( !GAMEMODE.Vars.CheckTime or GAMEMODE.Vars.CheckTime+0.1<=CurTime() ) then
		
		if ply:Alive() and ply.Sprinting and ( !ply.SprintV or ply.SprintV>0 ) and !ply.SprintLock then
			ply.SprintV = (ply.SprintV or 100) - 1
		elseif ply:Alive() and (!ply.Sprinting or ply.SprintLock) and ply.SprintV and ply.SprintV<100 then
			ply.SprintV = ply.SprintV + 1
		end
		
		if ply.SprintV then
			
			if ply.SprintV<=0 and !ply.SprintLock then
				ply.SprintLock = true
				ply:SetRunSpeed( 200 )
			elseif ply.SprintV>=85 and ply.SprintLock then
				ply.SprintLock = false
				ply:SetRunSpeed( 400 )
			end
			
		end
		
		GAMEMODE.Vars.CheckTime = CurTime()
		
	elseif ( ply:Team()!=TEAM_VICTIMS or !ply:Alive() ) and ( !ply.SprintV or ply.SprintV!=100 ) then
		ply.SprintV = 100
	end
	
	if ply:Alive() and (ply:Team()==TEAM_VICTIMS or ply:Team()==TEAM_PEDOBEAR) and !GAMEMODE.ChatOpen and !gui.IsGameUIVisible() then
		
		local inputs = { input.IsKeyDown(KEY_1), input.IsKeyDown(KEY_2), input.IsKeyDown(KEY_3), input.IsKeyDown(KEY_4), input.IsKeyDown(KEY_5), input.IsKeyDown(KEY_6), input.IsKeyDown(KEY_7), input.IsKeyDown(KEY_8), input.IsKeyDown(KEY_9) }
		local sel = 0
		
		for k,v in pairs(inputs) do
			
			if v==true then
				
				sel = k
				break
				
			end
			
		end
		
		GAMEMODE:StartTaunt(sel)
		
	end
	
	if ply:Team()==TEAM_VICTIMS and ply:Alive() and GAMEMODE.Vars.Round.Start and !GAMEMODE.Vars.Round.End and !GAMEMODE.Vars.Round.TempEnd then
		
		GAMEMODE:HeartBeat(ply)
		
	end
	
end

function GM:HeartBeat(ply)
	
	local distance
	local t
	local nextheartbeat = 1
	local volume = 1
	
	for k, v in pairs(team.GetPlayers(TEAM_PEDOBEAR)) do
		
		t = v:GetPos():Distance( ply:GetPos() )
		
		if !distance or distance < t then
			distance = t
		end
		
	end
	
	if distance and distance < 1000 then
		
		nextheartbeat = math.Remap( distance, 0, 1000, 0.30, 2 )
		volume = math.Remap( distance, 1000, 0, 0.30, 1 )
		
		if !ply.LastHeartBeat or ply.LastHeartBeat + nextheartbeat < CurTime() then
			ply:EmitSound(GAMEMODE.Sounds.HeartBeat, 0, 100, volume, CHAN_AUTO)
			ply.LastHeartBeat = CurTime()
		end
		
	end
	
end

function GM:StartTaunt(sel)
	
	local ply = LocalPlayer()
	
	if sel and sel!= 0 and GAMEMODE.Sounds.Taunts[sel] and ( !ply.TauntCooldown or ply.TauntCooldown-CurTime()+0.5<0 ) then
		
		if GAMEMODE.Sounds.Taunts[sel][3]!=0 and GAMEMODE.Sounds.Taunts[sel][3]!=ply:Team() then return end
		
		net.Start( "XP_Pedo_Taunt" )
			net.WriteInt(sel,32)
		net.SendToServer()
		
		local cd = GAMEMODE.Sounds.Taunts[sel][4]
		
		if cd<5 then
			cd = 5
		end
		
		ply.TauntCooldown = CurTime() + cd
		ply.TauntCooldownF = cd
		ply.LastTaunt = sel
		
	end
	
end

function GM:Music(src, pre)
	
	GAMEMODE.Vars.CurrentMusic = src
	
	if IsValid(GAMEMODE.Vars.Music) and src == "play" then
		GAMEMODE.Vars.Music:Play()
	elseif IsValid(GAMEMODE.Vars.Music) and src == "pause" then
		GAMEMODE.Vars.Music:Pause()
	elseif IsValid(GAMEMODE.Vars.Music) then
		GAMEMODE.Vars.Music:Stop()
		GAMEMODE.Vars.Music = nil
	end
	
	if src != "stop" and src != "pause" and src != "play" and GetConVar("pedobear_cl_music_enable"):GetBool() then
		
		local exist = file.Exists(src, "GAME")
		local isurl = false
		local orisrc = nil
		
		if src != "" and !exist and GetConVar("pedobear_cl_music_allowexternal"):GetBool() then
		
			isurl = true
			
		elseif src == "" or !exist then
			
			local tbl = file.Find( "sound/pedo/"..Either( pre, "premusics", "musics" ).."/*", "GAME" )
			
			if #tbl > 0 then
				orisrc = src
				src = "sound/pedo/"..Either( pre, "premusics", "musics" ).."/"..tbl[math.random(1,#tbl)]
			end
			
		end
		
		local function domusicstuff( mus, errorID, errorName )
			
			if IsValid( mus ) then
				mus:SetVolume(GetConVar( "pedobear_cl_music_volume" ):GetFloat())
				mus:EnableLooping(true)
				GAMEMODE.Vars.Music = mus
			end
			
			if errorID or errorName then
				GAMEMODE:Log("Error while starting music \""..src.."\": "..errorName.." ("..errorID..")")
				GAMEMODE:Log("Retrying with fallback...")
				GAMEMODE:Music("", pre)
			elseif orisrc != nil then
				GAMEMODE:Log("Playing music \""..src.."\""..Either( pre, " (pre round music)", "" ).." instead of "..Either(orisrc != "", "\""..orisrc.."\"", "nothing"))
			else
				GAMEMODE:Log("Playing music \""..src.."\""..Either( pre, " (pre round music)", "" ))
			end
			
		end
		
		if !isurl and src != "" then
			
			sound.PlayFile( src, "noblock", domusicstuff)
			
		elseif isurl then
			
			GAMEMODE:Log("Downloading external music... \""..src.."\"")
			sound.PlayURL( src, "noblock", domusicstuff)
			
		end
		
	end
	
end

function GM:StartChat( teamsay )
	
	GAMEMODE.ChatOpen = true
	
	return false

end

function GM:FinishChat()
	
	GAMEMODE.ChatOpen = false
	
end

function GM:GetTeamColor( ent )

	local team = TEAM_UNASSIGNED
	if ( ent.Team ) then team = ent:Team() end
	if ent:GetClass()=="pedo_dummy" then team = TEAM_VICTIMS end
	return GAMEMODE:GetTeamNumColor( team )

end

function GM:Stats()
	
	local steamid = LocalPlayer():SteamID64()
	
	if !file.IsDir( (GAMEMODE.ShortName or "pedo").."/stats", "DATA" ) then
		file.CreateDir( (GAMEMODE.ShortName or "pedo").."/stats" )
	end
	
	local needstat = !file.Exists( (GAMEMODE.ShortName or "pedo").."/stats/" .. steamid .. ".txt", "DATA" )
	
	if needstat then
		
		http.Post( "https://www.xperidia.com/UCP/stats.php", { steamid = steamid, zone = (GAMEMODE.ShortName or "pedo") },
		function( responseText, contentLength, responseHeaders, statusCode )
			
			if statusCode == 200 then
				file.Write( (GAMEMODE.ShortName or "pedo").."/stats/" .. steamid .. ".txt", "" )
				GAMEMODE:Log(responseText)
			else
				GAMEMODE:Log("Error while registering the gamemode (ERROR "..statusCode..")")
			end
			
		end, 
		function( errorMessage )
			
			GAMEMODE:Log(errorMessage)
			
		end )
		
	end
	
	local function welcomehandle()
		
		GAMEMODE:BeginMenu()
		
		local tab = {}
		
		tab.LastVersion = GAMEMODE.Version
		
		file.Write( "pedo/info.txt", util.TableToJSON( tab ) )
		
	end
	
	local info = file.Read( "pedo/info.txt" )
	
	if info then
	
		local tab = util.JSONToTable(info)
		if !tab or (tab.LastVersion and tab.LastVersion < GAMEMODE.Version) then
			
			welcomehandle()
			
		end
		
	else
		
		welcomehandle()
		
	end
	
end

function GM:ContextMenuOpen()
	return true
end

function GM:OnContextMenuOpen()
	LocalPlayer().ThirdPerson = !LocalPlayer().ThirdPerson
end

hook.Add("CalcView", "XP_Pedo_thirdperson", function(ply, pos, angles, fov)
	
	if ply:Alive() and ply.ThirdPerson and !ply:IsPlayingTaunt() then
		
		local view = {}
		
		local traceData = {}
		traceData.start = ply:EyePos()
		traceData.endpos = traceData.start + angles:Forward() * -100
		traceData.endpos = traceData.endpos + angles:Right()
		traceData.endpos = traceData.endpos + angles:Up()
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
	if input.LookupBinding( cmd, true ) then
		return string.upper(input.LookupBinding( cmd, true ))
	end	
	return "N/A"
end

function GM:OnPlayerChat( player, strText, bTeamOnly, bPlayerIsDead )
	
	local tab = {}
	
	if bPlayerIsDead then
		table.insert( tab, Color( 255, 30, 40 ) )
		table.insert( tab, "*DEAD* " )
	end
	
	if bTeamOnly then
		table.insert( tab, Color( 30, 160, 40 ) )
		table.insert( tab, "(TEAM) " )
	end
 
	if IsValid( player ) then
		if player:GetNWInt( "XperidiaRank", 0 )==3 then
			table.insert( tab, Color( 85, 255, 255 ) )
			table.insert( tab, "{Xperidia Admin} " )
		elseif player:GetNWInt( "XperidiaRank", 0 )==2 then
			table.insert( tab, Color( 170, 0, 170 ) )
			table.insert( tab, "{Xperidia Creator} " )
		elseif player:GetNWInt( "XperidiaRank", 0 )==1 then
			table.insert( tab, Color( 255, 170, 0 ) )
			table.insert( tab, "{Xperidia Premium} " )
		end
		if player:GetUserGroup()!="user" then
			table.insert( tab, Color( 255, 255, 255 ) )
			table.insert( tab, "["..string.upper( string.sub(player:GetUserGroup(), 1, 1) )..string.sub(player:GetUserGroup(), 2).."] " )
		end
		table.insert( tab, player )
	else
		table.insert( tab, "Console" )
	end
	
	table.insert( tab, Color( 255, 255, 255 ) )
	table.insert( tab, ": "..strText )
	
	chat.AddText( unpack(tab) )
	
	return true
	
end
