--[[---------------------------------------------------------
		Super Pedobear Gamemode for Garry's Mod
				by VictorienXP (2016)
-----------------------------------------------------------]]

function GM:Van()

	if IsValid(GAMEMODE.VanFrame) and GAMEMODE.VanFrame.DoClose then
		GAMEMODE.VanFrame:DoClose()
		return
	elseif IsValid(GAMEMODE.VanFrame) then
		GAMEMODE.VanFrame:Close()
		return
	end

	if !spb_powerup_enabled:GetBool() then
		GAMEMODE:Notif("Power-UPs are disabled in this server.", NOTIFY_ERROR, 5, true)
		return
	end

	if !spb_shop_enabled:GetBool() then
		GAMEMODE:Notif("The Power-UP shop has been disabled in this server.", NOTIFY_ERROR, 5, true)
		return
	end

	local ply = LocalPlayer()
	local cur = tonumber(ply:GetNWInt("spb_VictimsCurrency", 0))
	local w, h, oh = ScrW(), ScrH() * (736 / 1080), ScrH() * (960 / 1080)
	local scaleW = function(px) return ScrW() * (px / 1920) end
	local scaleH = function(px) return ScrH() * (px / 1080) end
	local use_quick = GetConVar("spb_cl_quickstuff_enable"):GetBool()
	local buttons = {}

	local function buypowerup(pu)
		local price = GAMEMODE:GetPowerUpPrice(pu, ply)
		if ply:Alive() and price <= cur then
			RunConsoleCommand("spb_powerup_buy", pu)
			surface.PlaySound("garrysmod/ui_click.wav")
			GAMEMODE.VanFrame:DoClose()
		else
			surface.PlaySound("common/wpn_denyselect.wav")
		end
	end

	GAMEMODE.VanFrame = vgui.Create("DFrame")
	local self = GAMEMODE.VanFrame
	self:SetPos(0, ScrH() / 2 - h / 2)
	self:SetSize(w, h)
	self:SetTitle("")
	self:SetVisible(true)
	self:SetDraggable(false)
	self:ShowCloseButton(false)
	self:SetBackgroundBlur(true)
	--self:SetScreenLock(true)
	function self:Paint(w, h)
		Derma_DrawBackgroundBlur(self, self.m_fCreateTime)
		surface.SetDrawColor(255, 255, 255, 255)
		surface.SetMaterial(GAMEMODE.Materials.Van)
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
		if use_quick and GAMEMODE.Vars.NInputs[10] != true then
			local i = 1
			for k, v in pairs(GAMEMODE.PowerUps) do
				if v[2] == ply:Team() or v[2] == 0 then
					if GAMEMODE.Vars.NInputs[i] == true and GAMEMODE.Vars.LNInputs[i] != true then
						buypowerup(k)
						break
					end
					i = i + 1
				end
			end
		elseif use_quick and GAMEMODE.Vars.NInputs[10] == true and GAMEMODE.Vars.LNInputs[10] != true then
			buypowerup("random")
		end
	end
	self.DoClose = function()
		if closeanim:Active() then
			if IsValid(self) then self:Close() end
			timer.Remove("CloseVan")
			return
		end
		closeanim:Start(0.3)
		timer.Create("CloseVan", 0.3, 1, function()
			if IsValid(self) then self:Close() end
			timer.Remove("CloseVan")
		end)
	end
	self:MakePopup()
	self:SetKeyboardInputEnabled(false)
	openanim:Start(0.3)

	if !GetConVar("spb_cl_hide_tips"):GetBool() then
		self.backtipclose = vgui.Create("DPanel")
		self.backtipclose:SetParent(self)
		self.backtipclose:SetPos(scaleW(800), scaleH(450))
		self.backtipclose:SetSize(scaleW(530), scaleH(100))
		self.backtipclose:SetBackgroundColor(Color(0, 0, 0, 200))

		self.tipclose = vgui.Create("DLabel")
		self.tipclose:SetParent(self.backtipclose)
		self.tipclose:Dock(FILL)
		self.tipclose:SetContentAlignment(5)
		self.tipclose:SetFont("spb_High_Scaled")
		self.tipclose:SetText("You can press 1-9 to quickly buy a Power-UP.\nDon't forget to press " .. GAMEMODE:CheckBind("+menu") .. " to close the shop.")
	end

	self.backpt = vgui.Create("DPanel")
	self.backpt:SetParent(self)
	self.backpt:SetPos(scaleW(420), scaleH(240))
	self.backpt:SetSize(scaleW(330), scaleH(32))
	self.backpt:SetBackgroundColor(Color(0, 0, 0, 200))

	self.pt = vgui.Create("DLabel")
	self.pt:SetParent(self.backpt)
	self.pt:Dock(FILL)
	self.pt:SetContentAlignment(5)
	self.pt:SetFont("spb_High_Scaled")
	self.pt:SetText("Welcome to my shop")

	self.backvc = vgui.Create("DPanel")
	self.backvc:SetParent(self)
	self.backvc:SetPos(scaleW(1610), scaleH(300))
	self.backvc:SetSize(scaleW(220), scaleH(100))
	self.backvc:SetBackgroundColor(Color(0, 0, 0, 200))

	self.vclbl = vgui.Create("DLabel")
	self.vclbl:SetParent(self)
	self.vclbl:SetPos(scaleW(1610), scaleH(300))
	self.vclbl:SetSize(scaleW(220), scaleH(100))
	self.vclbl:SetContentAlignment(8)
	self.vclbl:SetFont("spb_Normal_Scaled")
	self.vclbl:SetText("Victims in your storage")

	self.vc = vgui.Create("DLabel")
	self.vc:SetParent(self)
	self.vc:SetPos(scaleW(1610), scaleH(300))
	self.vc:SetSize(scaleW(220), scaleH(100))
	self.vc:SetContentAlignment(5)
	self.vc:SetFont("spb_Big_Scaled")
	self.vc:SetText(cur)

	local shametxt
	self.vclbl2 = vgui.Create("DLabel")
	self.vclbl2:SetParent(self)
	self.vclbl2:SetPos(scaleW(1610), scaleH(300))
	self.vclbl2:SetSize(scaleW(220), scaleH(100))
	self.vclbl2:SetContentAlignment(2)
	self.vclbl2:SetFont("spb_Normal_Scaled")
	if cur >= 9000 then
		shametxt = "(╯°□°）╯︵ ┻━┻"
	elseif cur >= 1000 then
		shametxt = "( ͡°( ͡° ͜ʖ( ͡° ͜ʖ ͡°)ʖ ͡°) ͡°)"
	elseif cur >= 500 then
		shametxt = "( ͡° ͜ʖ ͡°)"
	elseif cur >= 100 then
		shametxt = "WOW WOW WOW"
	elseif cur == 69 then
		shametxt = "( ͡° ͜ʖ ͡°)"
	elseif cur >= 50 then
		shametxt = "Damn boi"
	elseif cur == 42 then
		shametxt = "Good answer"
	elseif cur >= 20 then
		shametxt = "Impressive"
	elseif cur >= 10 then
		shametxt = "Now we're talking"
	elseif cur > 0 then
		shametxt = "Can't you get more?"
	else
		shametxt = "Boo, shame on you"
	end
	self.vclbl2:SetText(shametxt)

	self.store = vgui.Create("DPanel")
	self.store:SetParent(self)
	self.store:SetPos(scaleW(800), scaleH(30))
	self.store:SetSize(scaleW(970), scaleH(220))
	self.store:SetBackgroundColor(Color(0, 0, 0, 200))

	self.store.content = vgui.Create("DHorizontalScroller", self.store)
	self.store.content:Dock(FILL)
	self.store.content:SetOverlap(-4)

	self.backtxt = vgui.Create("DPanel")
	self.backtxt:SetParent(self)
	self.backtxt:SetPos(scaleW(1042.5), scaleH(250))
	self.backtxt:SetSize(scaleW(485), scaleH(32))
	self.backtxt:SetBackgroundColor(Color(0, 0, 0, 200))

	self.txt = vgui.Create("DLabel")
	self.txt:SetParent(self.backtxt)
	self.txt:Dock(FILL)
	self.txt:SetContentAlignment(5)
	self.txt:SetFont("spb_High_Scaled")
	if ply:Team() != TEAM_HIDING and ply:Team() != TEAM_SEEKER then
		self.txt:SetText("You can't get Power-UPs while spectating")
	elseif ply:Alive() then
		self.txt:SetText("What do you want?")
	else
		self.txt:SetText("You can't get Power-UPs while dead")
	end

	local i = 1
	for k, v in pairs(GAMEMODE.PowerUps) do
		if v[2] == ply:Team() or v[2] == 0 then

			local price = GAMEMODE:GetPowerUpPrice(k, ply)
			local nprice = GAMEMODE:GetPowerUpPrice(k, ply, true)

			local item = vgui.Create("DPanel", self.store.content)
			item:SetSize(scaleH(220), scaleH(220))
			item:SetPaintBackground(false)

			local itemid = vgui.Create("DLabel", item)
			itemid:Dock(FILL)
			itemid:SetContentAlignment(7)
			itemid:SetFont("spb_High_Scaled")
			itemid:SetText(i)

			local itemname = vgui.Create("DLabel", item)
			itemname:Dock(FILL)
			itemname:SetContentAlignment(2)
			itemname:SetFont("spb_Normal_Scaled")
			if price != nprice then
				itemname:SetText(price .. " victims instead of " .. nprice)
			else
				itemname:SetText(price .. " victims")
			end

			local btn = vgui.Create("DImageButton", item)
			btn:Dock(FILL)
			btn:SetImage(v[3]:GetName())
			if v[4] and IsColor(v[4]) then
				btn:SetColor(v[4])
			else
				btn:SetColor(Color(52, 190, 236, 255))
			end
			btn.DoClick = function()
				buypowerup(k)
			end
			btn.OnCursorEntered = function()
				self.txt:SetText("Buy " .. v[1] .. " for " .. price .. " victims")
			end
			btn.OnCursorExited = function()
				if ply:Team() != TEAM_HIDING and ply:Team() != TEAM_SEEKER then
					self.txt:SetText("You can't get Power-UPs while spectating")
				elseif ply:Alive() then
					self.txt:SetText("What do you want?")
				else
					self.txt:SetText("You can't get Power-UPs while dead")
				end
			end

			self.store.content:AddPanel(item)
			buttons[k] = item
			i = i + 1

		end
	end

	if (ply:Team() != TEAM_HIDING and ply:Team() != TEAM_SEEKER) then
		self.store.txt = vgui.Create("DLabel", self.store)
		self.store.txt:Dock(FILL)
		self.store.txt:SetContentAlignment(5)
		self.store.txt:SetFont("spb_Big_Scaled")
		self.store.txt:SetText("You can't get Power-UPs while spectating")
	end

end
