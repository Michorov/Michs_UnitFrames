local _, addon = ...

addon.Options = addon.Options or {}
addon.Options.Pages = addon.Options.Pages or {}
addon.Options.Pages.Bars = addon.Options.Pages.Bars or {}
addon.Options.Pages.Bars.Health = addon.Options.Pages.Bars.Health or {}

local Health = addon.Options.Pages.Bars.Health
local LSM = LibStub("LibSharedMedia-3.0")
local subpage

local colorModeOptions = {
	{ value = "static", text = "Static" },
	{ value = "classOrReaction", text = "Class/Reaction" },
}

local excludedTextureNames = {
	play_icon = true,
	stop_icon = true,
	user_icon = true,
	users_icon = true,
}

local function GetTextureOptions()
	local options = {}

	for _, textureName in ipairs(LSM:List("statusbar")) do
		if not excludedTextureNames[textureName] and LSM:IsValid("statusbar", textureName) then
			options[#options + 1] = {
				value = textureName,
				text = textureName,
				texture = LSM:Fetch("statusbar", textureName),
			}
		end
	end

	return options
end

function Health:Ensure(parent)
	if subpage then
		return subpage
	end

	subpage = CreateFrame("Frame", nil, parent)

	subpage.colorModeDropdown = addon.Options.Controls.Dropdown:Create(subpage, "Color Mode")
	subpage.colorModeDropdown:SetLayoutWidth(178)
	subpage.colorModeDropdown:SetOptions(colorModeOptions)
	subpage.colorModeDropdown:SetLayoutPoint("TOPLEFT", subpage, "TOPLEFT", 0, 0)
	subpage.colorModeDropdown:SetOnValueChanged(function(_, value)
		local unit = addon.Options.Sections.Content:GetSelectedUnit()
		addon.Database:GetProfile().frames[unit].health.colorByClassOrReaction = value == "classOrReaction"
		addon.UpdateScheduler:Notify("healthSettingsChanged", unit)
	end)

	subpage.colorPicker = addon.Options.Controls.ColorPicker:Create(subpage, "Static Color")
	subpage.colorPicker:SetLayoutWidth(178)
	subpage.colorPicker:SetLayoutPoint("BOTTOMLEFT", subpage.colorModeDropdown, "BOTTOMRIGHT", 24, 0)
	subpage.colorPicker:SetOnValueChanged(function(_, r, g, b, a)
		local unit = addon.Options.Sections.Content:GetSelectedUnit()
		addon.Database:GetProfile().frames[unit].health.color = { r = r, g = g, b = b, a = a }
		addon.UpdateScheduler:Notify("healthSettingsChanged", unit)
	end)

	subpage.textureDropdown = addon.Options.Controls.Dropdown:Create(subpage, "Texture")
	subpage.textureDropdown:SetLayoutWidth(178)
	subpage.textureDropdown:SetOptions(GetTextureOptions())
	subpage.textureDropdown:SetLayoutPoint("TOPLEFT", subpage.colorModeDropdown, "BOTTOMLEFT", 0, -24)
	subpage.textureDropdown:SetOnValueChanged(function(_, value)
		local unit = addon.Options.Sections.Content:GetSelectedUnit()
		addon.Database:GetProfile().frames[unit].health.texture = value
		addon.UpdateScheduler:Notify("healthSettingsChanged", unit)
	end)

	function subpage:UpdateState(profile, unit)
		local settings = profile.frames[unit].health
		local textureOptions = GetTextureOptions()
		local textureListed = false

		for _, option in ipairs(textureOptions) do
			if option.value == settings.texture then
				textureListed = true
				break
			end
		end

		if not textureListed then
			textureOptions[#textureOptions + 1] = {
				value = settings.texture,
				text = settings.texture .. (LSM:IsValid("statusbar", settings.texture) and "" or " (Unavailable)"),
			}
		end

		self.colorModeDropdown:SetValue(settings.colorByClassOrReaction and "classOrReaction" or "static")
		self.colorPicker:SetColor(settings.color)
		self.textureDropdown:SetOptions(textureOptions)
		self.textureDropdown:SetValue(settings.texture)
	end

	return subpage
end
