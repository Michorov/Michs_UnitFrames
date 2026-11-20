local _, addon = ...

addon.Options = addon.Options or {}
addon.Options.Pages = addon.Options.Pages or {}
addon.Options.Pages.General = addon.Options.Pages.General or {}

local General = addon.Options.Pages.General
local page

function General:Create(panel)
	local owner = panel:RegisterPage("general", {
		title = "General",
		showHeader = true,
	})
	local content = owner:RegisterSubPage("general", { title = "General" })
	page = content.frame

	page.mouseoverHighlightCheckbox = content:CreateControl("Checkbox", "Mouseover Highlight")
	page.mouseoverHighlightCheckbox:SetLayoutWidth(176)
	page.mouseoverHighlightCheckbox:SetLayoutPoint("TOPLEFT", page, "TOPLEFT", 0, 0)
	page.mouseoverHighlightCheckbox:SetOnValueChanged(function(_, enabled)
		addon.Database:GetProfile().general.mouseoverHighlight = enabled
		addon.UpdateScheduler:Notify("mouseoverHighlightSettingsChanged")
	end)

	page.minimapIconCheckbox = content:CreateControl("Checkbox", "Minimap Icon")
	page.minimapIconCheckbox:SetLayoutWidth(176)
	page.minimapIconCheckbox:SetLayoutPoint("TOPLEFT", page.mouseoverHighlightCheckbox, "TOPRIGHT", 24, 0)
	page.minimapIconCheckbox:SetOnValueChanged(function(_, enabled)
		addon.Database:GetProfile().general.minimap.hide = not enabled
		addon.Options.Minimap:Refresh()
	end)

	page.fontDropdown = content:CreateControl("Dropdown", "Global Font")
	page.fontDropdown:SetLayoutWidth(176)
	page.fontDropdown:SetOptions(addon.Style.Fonts:GetOptions())
	page.fontDropdown:SetLayoutPoint(
		"TOPLEFT",
		page.mouseoverHighlightCheckbox,
		"BOTTOMLEFT",
		0,
		-24
	)
	page.fontDropdown:SetOnValueChanged(function(_, value)
		addon.Database:GetProfile().general.font = value
		addon.UpdateScheduler:Notify("nameTextSettingsChanged")
		addon.UpdateScheduler:Notify("levelTextSettingsChanged")
		addon.UpdateScheduler:Notify("healthTextSettingsChanged")
		addon.UpdateScheduler:Notify("powerTextSettingsChanged")
		addon.UpdateScheduler:Notify("castSettingsChanged")
	end)

	page.textureDropdown = content:CreateControl("Dropdown", "Global Texture")
	page.textureDropdown:SetLayoutWidth(176)
	page.textureDropdown:SetOptions(addon.Style.Textures:GetOptions())
	page.textureDropdown:SetLayoutPoint("TOPLEFT", page.fontDropdown, "TOPRIGHT", 24, 0)
	page.textureDropdown:SetOnValueChanged(function(_, value)
		addon.Database:GetProfile().general.texture = value
		addon.UpdateScheduler:Notify("healthSettingsChanged")
		addon.UpdateScheduler:Notify("backgroundSettingsChanged")
		addon.UpdateScheduler:Notify("powerSettingsChanged")
		addon.UpdateScheduler:Notify("castSettingsChanged")
	end)


	function page:UpdateState(profile)
		self.fontDropdown:SetOptions(addon.Style.Fonts:GetOptions(profile.general.font))
		self.fontDropdown:SetValue(profile.general.font)
		self.textureDropdown:SetOptions(addon.Style.Textures:GetOptions(profile.general.texture))
		self.textureDropdown:SetValue(profile.general.texture)
		self.mouseoverHighlightCheckbox:SetChecked(profile.general.mouseoverHighlight)
		self.minimapIconCheckbox:SetChecked(not profile.general.minimap.hide)
	end

	content:SetStateUpdater(function(profile, unit)
		page:UpdateState(profile, unit)
	end)

	return owner
end
