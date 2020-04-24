--[[---------------------------------------------------------
		Super Pedobear Gamemode for Garry's Mod
				by VictorienXP (2020)
-----------------------------------------------------------]]

local fonts = {
	spb_TIME	= {
		75,
		{
			antialias = true,
			shadow = true
		}
	},
	spb_RND	= {
		50,
		{
			antialias = true,
			shadow = true
		}
	},
	spb_TXT	= {
		40,
		{
			antialias = true,
			shadow = true
		}
	},
	spb_HT	= {
		24,
		{
			antialias = true,
			shadow = true
		}
	},
	spb_HUDname	= {
		24,
		{
			antialias = true
		}
	},
	spb_min	= {
		18,
		{
			antialias = true
		}
	},
}

local function scaled_font_name(name)
	return name .. "_" .. ScrH()
end

--[[----------------------------------------------------------------------------
	Name: GM:CreateScaledFont(fname, fsize, foptions)
	Desc: Create a scaled font from the given base name, size and option table.
------------------------------------------------------------------------------]]
function GM:CreateScaledFont(fname, fsize, foptions)

	local aname = scaled_font_name(fname)

	if self.CreatedFonts[aname] then
		self:Log("The " .. aname .. " font is already created.")
		return aname
	end

	local	tfont = {}
			tfont.font		= foptions and foptions.font or "Roboto"
			tfont.size		= self:ScreenScaleMin(fsize)

	for k, v in pairs(foptions) do
		tfont[k] = v
	end

	surface.CreateFont(aname, tfont)

	self.CreatedFonts[aname] = true

	self:Log("Created scaled font " .. aname .. " from " .. fsize)

	return aname

end

--[[----------------------------------------------------------------------------
	Name: GM:GetScaledFont(fname)
	Desc:	Attempt to get a scaled font name from base font name.
			If the scaled font doesn't exist it will create it.
			If the base font is not registered in the fonts table, it will
			return fname.
------------------------------------------------------------------------------]]
function GM:GetScaledFont(fname)

	if self.CreatedFonts[scaled_font_name(fname)] then

		return scaled_font_name(fname)

	elseif !self.CreatedFonts[scaled_font_name(fname)] and fonts[fname] then

		return self:CreateScaledFont(fname, fonts[fname][1], fonts[fname][2])

	end

	return fname

end

--[[----------------------------------------------------------------------------
	Name: GM:CreateScaledFonts()
	Desc:	Will generate scaled fonts from the fonts table.
------------------------------------------------------------------------------]]
function GM:CreateScaledFonts()

	self:Log("Generating scaled fonts...")

	for k, v in pairs(fonts) do

		self:CreateScaledFont(k, v[1], v[2])

	end

	self:Log("Scaled fonts created.")

end
