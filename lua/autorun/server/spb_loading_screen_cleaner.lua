--[[----------------------------------------------------------------------------
				Put back the default Garry's Mod loading screen...
------------------------------------------------------------------------------]]

local spb_ls_url = "https://assets.xperidia.com/garrysmod/loading.html#auto-spb"

hook.Add("Initialize", "spb_loading_screen_cleaner", function()

	local url = GetConVar("sv_loadingurl"):GetString()

	if not GAMEMODE.IsSPBDerived and url == spb_ls_url then

		RunConsoleCommand("sv_loadingurl", "")

	end

end)
