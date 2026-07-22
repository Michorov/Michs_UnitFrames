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
		if mediaType ~= "font" and mediaType ~= "statusbar" then
			return
		end

		local profile = addon.Database:GetProfile()
		local globalFontRegistered = mediaType == "font" and profile.general.font == mediaName
		local globalTextureRegistered = mediaType == "statusbar" and profile.general.texture == mediaName

		for unit, settings in pairs(profile.frames) do
			if mediaType == "font" then
				local castSettings = settings.cast
				if castSettings then
					local castFont = castSettings.font
					if castFont == mediaName or ((castFont == nil or castFont == -1) and globalFontRegistered) then
						addon.UpdateScheduler:Notify("castSettingsChanged", unit)
					end
				end

				if settings.nameText.font == mediaName or (settings.nameText.font == -1 and globalFontRegistered) then
					addon.UpdateScheduler:Notify("nameTextSettingsChanged", unit)
				end

				if
					settings.healthText.font == mediaName
					or (settings.healthText.font == -1 and globalFontRegistered)
				then
					addon.UpdateScheduler:Notify("healthTextSettingsChanged", unit)
				end

				if settings.powerText.font == mediaName or (settings.powerText.font == -1 and globalFontRegistered) then
					addon.UpdateScheduler:Notify("powerTextSettingsChanged", unit)
				end
			else
				if
					settings.health.texture == mediaName
					or (settings.health.texture == -1 and globalTextureRegistered)
				then
					addon.UpdateScheduler:Notify("healthSettingsChanged", unit)
				end

				if
					settings.background.texture == mediaName
					or (settings.background.texture == -1 and globalTextureRegistered)
				then
					addon.UpdateScheduler:Notify("backgroundSettingsChanged", unit)
				end

				if
					settings.power.texture == mediaName
					or (settings.power.texture == -1 and globalTextureRegistered)
				then
					addon.UpdateScheduler:Notify("powerSettingsChanged", unit)
				end

				local castTexture = settings.cast and settings.cast.texture
				if
					castTexture == mediaName
					or ((castTexture == nil or castTexture == -1) and globalTextureRegistered)
				then
					addon.UpdateScheduler:Notify("castSettingsChanged", unit)
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
