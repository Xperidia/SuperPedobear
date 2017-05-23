--[[---------------------------------------------------------------------------
							Super Pedobear
		Please don't copy, clone, redistribute or modify the code!
-----------------------------------------------------------------------------]]

function GM:PedoVan()

	if IsValid(GAMEMODE.PedoVanFrame) and GAMEMODE.PedoVanFrame.DoClose then
		GAMEMODE.PedoVanFrame:DoClose()
		return
	elseif IsValid(GAMEMODE.PedoVanFrame) then
		GAMEMODE.PedoVanFrame:Close()
		return
	end

	local w, h, oh = ScrW(), ScrH() * (736 / 1080), ScrH() * (960 / 1080)
	local scaleW = function(px) return ScrW() * (px / 1920) end
	local scaleH = function(px) return ScrH() * (px / 1080) end

	GAMEMODE.PedoVanFrame = vgui.Create("DFrame")
	local self = GAMEMODE.PedoVanFrame
	self:SetPos(0, ScrH() / 2 - h / 2)
	self:SetSize(w, h)
	self:SetTitle("")
	self:SetVisible(true)
	self:SetDraggable(false)
	self:ShowCloseButton(false)
	self:SetBackgroundBlur(true)
	--self.PedoVanFrame:SetScreenLock(true)
	function self:Paint(w, h)
		Derma_DrawBackgroundBlur(self, self.m_fCreateTime)
		surface.SetDrawColor(255, 255, 255, 255)
		surface.SetMaterial(GAMEMODE.Materials.PedoVan)
		surface.DrawTexturedRect(0, 0, w, oh)
	end
	local openanim = Derma_Anim("openanim", self, function(pnl, anim, delta, data)
		pnl:SetPos(w * (1 - delta), ScrH() / 2 - h / 2)
	end)
	local closeanim = Derma_Anim("closeanim", self, function(pnl, anim, delta, data)
		pnl:SetPos(w * -delta, ScrH() / 2 - h / 2)
	end)
	function self:Think(self, w, h)
		if openanim:Active() then openanim:Run() end
		if closeanim:Active() then closeanim:Run() end
	end
	self.DoClose = function()
		if closeanim:Active() then
			if IsValid(self) then self:Close() end
			timer.Remove("ClosePedoVan")
			return
		end
		closeanim:Start(0.50)
		timer.Create("ClosePedoVan", 0.5, 1, function()
			if IsValid(self) then self:Close() end
			timer.Remove("ClosePedoVan")
		end)
	end
	self:MakePopup()
	self:SetKeyboardInputEnabled(false)
	openanim:Start(0.50)

	self.backvc = vgui.Create("DPanel")
	self.backvc:SetParent(self)
	self.backvc:SetPos(scaleW(1610), scaleH(300))
	self.backvc:SetSize(scaleW(220), scaleH(100))

	self.vclbl = vgui.Create("DLabel")
	self.vclbl:SetParent(self)
	self.vclbl:SetText("Victims in your storage")
	self.vclbl:SetPos(scaleW(1610), scaleH(300))
	self.vclbl:SetSize(scaleW(220), scaleH(100))
	self.vclbl:SetDark(1)
	self.vclbl:SetContentAlignment(8)

	self.vc = vgui.Create("DLabel")
	self.vc:SetParent(self)
	self.vc:SetText(LocalPlayer():GetNWInt("XP_Pedo_VictimsCurrency", 0))
	self.vc:SetPos(scaleW(1610), scaleH(300))
	self.vc:SetSize(scaleW(220), scaleH(100))
	self.vc:SetDark(1)
	self.vc:SetContentAlignment(5)
	self.vc:SetFont("DermaLarge")

	self.store = vgui.Create("DPanel")
	self.store:SetParent(self)
	self.store:SetPos(scaleW(800), scaleH(30))
	self.store:SetSize(scaleW(970), scaleH(220))

	self.wip = vgui.Create("DLabel")
	self.wip:SetParent(self)
	self.wip:SetText("WIP")
	self.wip:SetPos(scaleW(800), scaleH(30))
	self.wip:SetSize(scaleW(970), scaleH(220))
	self.wip:SetDark(1)
	self.wip:SetContentAlignment(5)
	self.wip:SetFont("DermaLarge")

end
