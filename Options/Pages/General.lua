local _, addon = ...

addon.Options = addon.Options or {}
addon.Options.Pages = addon.Options.Pages or {}
addon.Options.Pages.General = addon.Options.Pages.General or {}

local General = addon.Options.Pages.General
local PP = addon.PixelPerfect
local page

function General:Ensure(parent)
	if page then
		return page
	end

	page = CreateFrame("Frame", nil, parent)
	page.header = CreateFrame("Frame", nil, page)
	page.header:SetPoint("TOPLEFT", page, "TOPLEFT", 0, 0)
	page.header:SetPoint("TOPRIGHT", page, "TOPRIGHT", 0, 0)

	page.body = CreateFrame("Frame", nil, page)
	page.body:SetPoint("BOTTOMLEFT", page, "BOTTOMLEFT", 0, 0)
	page.body:SetPoint("BOTTOMRIGHT", page, "BOTTOMRIGHT", 0, 0)

	page.header.title = page.header:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	page.header.title:SetPoint("LEFT", page.header, "LEFT", 0, 0)
	page.header.title:SetJustifyH("LEFT")
	page.header.title:SetTextColor(0.88, 0.89, 0.92, 1)
	page.header.title:SetText("General")

	page.body.mouseoverHighlightCheckbox = addon.Options.Controls.Checkbox:Create(
		page.body,
		"Mouseover Highlight"
	)
	page.body.mouseoverHighlightCheckbox:SetLayoutWidth(178)
	page.body.mouseoverHighlightCheckbox:SetLayoutPoint("TOPLEFT", page.body, "TOPLEFT", 0, 0)
	page.body.mouseoverHighlightCheckbox:SetOnValueChanged(function(_, enabled)
		addon.Database:GetProfile().general.mouseoverHighlight = enabled
		addon.UpdateScheduler:Notify("mouseoverHighlightSettingsChanged")
	end)

	page.body.fontDropdown = addon.Options.Controls.Dropdown:Create(page.body, "Global Font")
	page.body.fontDropdown:SetLayoutWidth(178)
	page.body.fontDropdown:SetOptions(addon.Style.Fonts:GetOptions())
	page.body.fontDropdown:SetLayoutPoint(
		"TOPLEFT",
		page.body.mouseoverHighlightCheckbox,
		"BOTTOMLEFT",
		0,
		-24
	)
	page.body.fontDropdown:SetOnValueChanged(function(_, value)
		addon.Database:GetProfile().general.font = value
		addon.UpdateScheduler:Notify("nameTextSettingsChanged")
		addon.UpdateScheduler:Notify("healthTextSettingsChanged")
		addon.UpdateScheduler:Notify("powerTextSettingsChanged")
	end)

	page.body.textureDropdown = addon.Options.Controls.Dropdown:Create(page.body, "Global Texture")
	page.body.textureDropdown:SetLayoutWidth(178)
	page.body.textureDropdown:SetOptions(addon.Style.Textures:GetOptions())
	page.body.textureDropdown:SetLayoutPoint("TOPLEFT", page.body.fontDropdown, "TOPRIGHT", 24, 0)
	page.body.textureDropdown:SetOnValueChanged(function(_, value)
		addon.Database:GetProfile().general.texture = value
		addon.UpdateScheduler:Notify("healthSettingsChanged")
		addon.UpdateScheduler:Notify("backgroundSettingsChanged")
		addon.UpdateScheduler:Notify("powerSettingsChanged")
	end)

	function page:UpdateLayout()
		self.header:SetHeight(PP:ToUIScaled(32))
		self.header.title:SetFont("Fonts\\ARIALN.TTF", PP:ScaleFont(20), "")
		self.body:SetPoint("TOPLEFT", self.header, "BOTTOMLEFT", 0, PP:ToUIScaled(-16))
		self.body:SetPoint("TOPRIGHT", self.header, "BOTTOMRIGHT", 0, PP:ToUIScaled(-16))
	end

	function page:UpdateState(profile)
		self.body.fontDropdown:SetOptions(addon.Style.Fonts:GetOptions(profile.general.font))
		self.body.fontDropdown:SetValue(profile.general.font)
		self.body.textureDropdown:SetOptions(addon.Style.Textures:GetOptions(profile.general.texture))
		self.body.textureDropdown:SetValue(profile.general.texture)
		self.body.mouseoverHighlightCheckbox:SetChecked(profile.general.mouseoverHighlight)
	end

	return page
end
