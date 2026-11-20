local _, addon = ...

addon.Options = addon.Options or {}
addon.Options.Pages = addon.Options.Pages or {}
addon.Options.Pages.Bars = addon.Options.Pages.Bars or {}
addon.Options.Pages.Bars.Background = addon.Options.Pages.Bars.Background or {}

local Background = addon.Options.Pages.Bars.Background
local subpage

local colorModeOptions = {
	{ value = "static", text = "Static" },
	{ value = "classOrReaction", text = "Class/Reaction" },
}

function Background:Create(page)
	local owner = page:RegisterSubPage("background", { title = "Background" })
	subpage = owner.frame

	subpage.colorModeDropdown = owner:CreateControl("Dropdown", "Color Mode")
	subpage.colorModeDropdown:SetLayoutWidth(176)
	subpage.colorModeDropdown:SetOptions(colorModeOptions)
	subpage.colorModeDropdown:SetLayoutPoint("TOPLEFT", subpage, "TOPLEFT", 0, 0)
	subpage.colorModeDropdown:SetOnValueChanged(function(_, value)
		local unit = addon.Options:GetSelectedUnit()
		addon.Database:GetProfile().frames[unit].background.colorByClassOrReaction = value == "classOrReaction"
		addon.UpdateScheduler:Notify("backgroundSettingsChanged", unit)
	end)

	subpage.colorPicker = owner:CreateControl("ColorPicker", "Static Color")
	subpage.colorPicker:SetLayoutWidth(176)
	subpage.colorPicker:SetLayoutPoint("BOTTOMLEFT", subpage.colorModeDropdown, "BOTTOMRIGHT", 24, 0)
	subpage.colorPicker:SetOnValueChanged(function(_, r, g, b, a)
		local unit = addon.Options:GetSelectedUnit()
		addon.Database:GetProfile().frames[unit].background.color = { r = r, g = g, b = b, a = a }
		addon.UpdateScheduler:Notify("backgroundSettingsChanged", unit)
	end)

	subpage.textureDropdown = owner:CreateControl("Dropdown", "Texture")
	subpage.textureDropdown:SetLayoutWidth(176)
	subpage.textureDropdown:SetOptions(addon.Style.Textures:GetOptions(nil, true))
	subpage.textureDropdown:SetLayoutPoint("TOPLEFT", subpage.colorModeDropdown, "BOTTOMLEFT", 0, -24)
	subpage.textureDropdown:SetOnValueChanged(function(_, value)
		local unit = addon.Options:GetSelectedUnit()
		addon.Database:GetProfile().frames[unit].background.texture = value
		addon.UpdateScheduler:Notify("backgroundSettingsChanged", unit)
	end)

	function subpage:UpdateState(profile, unit)
		local settings = profile.frames[unit].background

		self.colorModeDropdown:SetValue(settings.colorByClassOrReaction and "classOrReaction" or "static")
		self.colorPicker:SetColor(settings.color)
		self.textureDropdown:SetOptions(addon.Style.Textures:GetOptions(settings.texture, true))
		self.textureDropdown:SetValue(settings.texture)
	end

	owner:SetStateUpdater(function(profile, unit)
		subpage:UpdateState(profile, unit)
	end)

	return owner
end
