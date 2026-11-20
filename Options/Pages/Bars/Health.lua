local _, addon = ...

addon.Options = addon.Options or {}
addon.Options.Pages = addon.Options.Pages or {}
addon.Options.Pages.Bars = addon.Options.Pages.Bars or {}
addon.Options.Pages.Bars.Health = addon.Options.Pages.Bars.Health or {}

local Health = addon.Options.Pages.Bars.Health
local subpage

local colorModeOptions = {
	{ value = "static", text = "Static" },
	{ value = "classOrReaction", text = "Class/Reaction" },
}

function Health:Create(page)
	local owner = page:RegisterSubPage("health", { title = "Health" })
	subpage = owner.frame

	subpage.colorModeDropdown = owner:CreateControl("Dropdown", "Color Mode")
	subpage.colorModeDropdown:SetLayoutWidth(176)
	subpage.colorModeDropdown:SetOptions(colorModeOptions)
	subpage.colorModeDropdown:SetLayoutPoint("TOPLEFT", subpage, "TOPLEFT", 0, 0)
	subpage.colorModeDropdown:SetOnValueChanged(function(_, value)
		local unit = addon.Options:GetSelectedUnit()
		addon.Database:GetProfile().frames[unit].health.colorByClassOrReaction = value == "classOrReaction"
		addon.UpdateScheduler:Notify("healthSettingsChanged", unit)
	end)

	subpage.colorPicker = owner:CreateControl("ColorPicker", "Static Color")
	subpage.colorPicker:SetLayoutWidth(176)
	subpage.colorPicker:SetLayoutPoint("BOTTOMLEFT", subpage.colorModeDropdown, "BOTTOMRIGHT", 24, 0)
	subpage.colorPicker:SetOnValueChanged(function(_, r, g, b, a)
		local unit = addon.Options:GetSelectedUnit()
		addon.Database:GetProfile().frames[unit].health.color = { r = r, g = g, b = b, a = a }
		addon.UpdateScheduler:Notify("healthSettingsChanged", unit)
	end)

	subpage.tappedColorPicker = owner:CreateControl("ColorPicker", "Claimed Mob Color")
	subpage.tappedColorPicker:SetLayoutWidth(176)
	subpage.tappedColorPicker:SetLayoutPoint("BOTTOMLEFT", subpage.colorPicker, "BOTTOMRIGHT", 24, 0)
	subpage.tappedColorPicker:SetOnValueChanged(function(_, r, g, b, a)
		local unit = addon.Options:GetSelectedUnit()
		addon.Database:GetProfile().frames[unit].health.tappedColor = { r = r, g = g, b = b, a = a }
		addon.UpdateScheduler:Notify("healthSettingsChanged", unit)
	end)

	subpage.textureDropdown = owner:CreateControl("Dropdown", "Texture")
	subpage.textureDropdown:SetLayoutWidth(176)
	subpage.textureDropdown:SetOptions(addon.Style.Textures:GetOptions(nil, true))
	subpage.textureDropdown:SetLayoutPoint("TOPLEFT", subpage.colorModeDropdown, "BOTTOMLEFT", 0, -24)
	subpage.textureDropdown:SetOnValueChanged(function(_, value)
		local unit = addon.Options:GetSelectedUnit()
		addon.Database:GetProfile().frames[unit].health.texture = value
		addon.UpdateScheduler:Notify("healthSettingsChanged", unit)
	end)

	function subpage:UpdateState(profile, unit)
		local settings = profile.frames[unit].health

		self.colorModeDropdown:SetValue(settings.colorByClassOrReaction and "classOrReaction" or "static")
		self.colorPicker:SetColor(settings.color)
		self.tappedColorPicker:SetShown(unit ~= "player" and unit ~= "pet")
		self.tappedColorPicker:SetColor(settings.tappedColor)
		self.textureDropdown:SetOptions(addon.Style.Textures:GetOptions(settings.texture, true))
		self.textureDropdown:SetValue(settings.texture)
	end

	owner:SetStateUpdater(function(profile, unit)
		subpage:UpdateState(profile, unit)
	end)

	return owner
end
