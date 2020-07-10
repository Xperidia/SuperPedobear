--[[---------------------------------------------------------
		Super Pedobear Gamemode for Garry's Mod
				by VictorienXP (2020)
-----------------------------------------------------------]]

function GM:MapVote()

	if IsValid(self.MapSelectF) then return end

	self.MapSelectF = vgui.Create("DFrame")
	self.MapSelectF:SetTitle("Map vote (WIP)")

	self.MapSelectF.pan = vgui.Create("DScrollPanel", self.MapSelectF)
	self.MapSelectF.pan:Dock(FILL)

	local Maps = self.MapList or {}
	local size = self:ScreenScaleMin(192)
	local x = 0
	local y = size
	local font = self:GetScaledFont("spb_min")

	surface.SetFont(font)

	for _, map in SortedPairsByValue(Maps) do

		if x + size > ScrW() - 32 then
			y = y + size + 12
			x = 12 + size
		else
			x = x + size + 12
		end

		local _, text_h = surface.GetTextSize(map)

		local MapPreview = vgui.Create("DButton", self.MapSelectF.pan)
		MapPreview:SetPos(x - size, y - size)
		MapPreview:SetSize(size, size)
		MapPreview:SetText(map)
		MapPreview:SetContentAlignment(2)
		MapPreview:SetFont(font)
		MapPreview:SetTextColor(Color(255, 255, 255, 0))

		local png
		local thumb_path_1 = "maps/thumb/" .. map .. ".png"
		local thumb_path_2 = "maps/" .. map .. ".png"

		if file.Exists(thumb_path_1, "GAME") then
			png = Material(thumb_path_1, "noclamp smooth")
		elseif file.Exists(thumb_path_2, "GAME") then
			png = Material(thumb_path_2, "noclamp smooth")
		end

		if png then
			MapPreview.OnCursorEntered = function()
				MapPreview:SetTextColor(Color(255, 255, 255, 255))
				MapPreview.CursorOn = true
			end
			MapPreview.OnCursorExited = function()
				MapPreview:SetTextColor(Color(255, 255, 255, 0))
				MapPreview.CursorOn = false
			end
		else
			png = Material("maps/thumb/noicon.png", "noclamp smooth")
			MapPreview:SetTextColor(Color(255, 255, 255))
			MapPreview:SetContentAlignment(5)
		end

		MapPreview.Paint = function(self, w, h)
			surface.SetMaterial(png)
			surface.SetDrawColor(255, 255, 255, 255)
			surface.DrawTexturedRect(0, 0, size, size)
			if self.CursorOn then
				surface.SetDrawColor(0, 0, 0, 200)
				surface.DrawRect(0, size - text_h, size, text_h)
			end
		end
		function MapPreview.DoClick()
		end

	end

	self.MapSelectF:SetPos(0, 0)
	self.MapSelectF:SetSize(ScrW(), ScrH())
	self.MapSelectF:SetDraggable(false)
	self.MapSelectF:SetScreenLock(true)
	self.MapSelectF:SetPaintShadow(true)
	self.MapSelectF:Center()
	self.MapSelectF:MakePopup()
	self.MapSelectF:SetKeyboardInputEnabled(false)
	self.MapSelectF.Paint = function(self, w, h)
		Derma_DrawBackgroundBlur(self)
	end

end
