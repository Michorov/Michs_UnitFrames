local addonName, addon = ...

local function InitializeAddon()
	addon.Database:Initialize()

	local flushCallback = addon.Updater:CreateFlushCallback()
	addon.UpdateScheduler:SetFlushCallback(flushCallback)

	addon.Options:Initialize()
	addon.FrameRegistry:Initialize()
	addon.EventHandler:Initialize()

	local LSM = LibStub("LibSharedMedia-3.0")
	LSM.RegisterCallback(addon, "LibSharedMedia_Registered", function(_, mediaType, mediaName)
		if mediaType == "font" then
			addon.Style.Fonts:Invalidate(mediaName)
		elseif mediaType ~= "statusbar" then
			return
		end

		for unit, settings in pairs(addon.Database:GetProfile().frames) do
			if mediaType == "font" then
				if settings.nameText.font == mediaName then
					addon.UpdateScheduler:Notify("nameTextSettingsChanged", unit)
				end

				if settings.healthText.font == mediaName then
					addon.UpdateScheduler:Notify("healthTextSettingsChanged", unit)
				end
			else
				if settings.health.texture == mediaName then
					addon.UpdateScheduler:Notify("healthSettingsChanged", unit)
				end

				if settings.background.texture == mediaName then
					addon.UpdateScheduler:Notify("backgroundSettingsChanged", unit)
				end
			end
		end
	end)
end

local core = CreateFrame("Frame")
core:RegisterEvent("ADDON_LOADED")
core:SetScript("OnEvent", function(_, event, loadedAddonName)
	if event ~= "ADDON_LOADED" then
		return
	end

	if loadedAddonName ~= addonName then
		return
	end

	core:UnregisterEvent("ADDON_LOADED")
	InitializeAddon()
end)
