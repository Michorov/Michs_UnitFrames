local _, addon = ...

addon.Options = addon.Options or {}
addon.Options.Pages = addon.Options.Pages or {}
addon.Options.Pages.Layout = addon.Options.Pages.Layout or {}

local Layout = addon.Options.Pages.Layout
local PP = addon.PixelPerfect
local page

function Layout:Ensure(parent)
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
	page.header.title:SetText("Layout")

	page.enabledCheckbox = addon.Options.Controls.Checkbox:Create(page.body, "Enabled")
	page.enabledCheckbox:SetLayoutPoint("TOPLEFT", page.body, "TOPLEFT", 0, 0)
	page.enabledCheckbox:SetOnValueChanged(function(_, enabled)
		local unit = addon.Options.Sections.Content:GetSelectedUnit()
		addon.Database:GetProfile().frames[unit].enabled = enabled
		addon.UpdateScheduler:Notify("visibilityChanged", unit)
	end)

	page.hideBlizzardFrameCheckbox = addon.Options.Controls.Checkbox:Create(page.body, "Hide Blizzard Frame")
	page.hideBlizzardFrameCheckbox:SetLayoutPoint("TOPLEFT", page.enabledCheckbox, "BOTTOMLEFT", 0, -8)
	page.hideBlizzardFrameCheckbox:SetOnValueChanged(function(_, hidden)
		local unit = addon.Options.Sections.Content:GetSelectedUnit()
		addon.Database:GetProfile().frames[unit].hideBlizzardFrame = hidden
		addon.UpdateScheduler:Notify("visibilityChanged", unit)
	end)

	page.horizontalPositionSlider = addon.Options.Controls.Slider:Create(page.body, "Horizontal Position")
	page.horizontalPositionSlider:SetLayoutWidth(178)
	page.horizontalPositionSlider:SetMinMaxValues(-2000, 2000)
	page.horizontalPositionSlider:SetStep(1)
	page.horizontalPositionSlider:SetLayoutPoint("TOPLEFT", page.hideBlizzardFrameCheckbox, "BOTTOMLEFT", 0, -24)
	page.horizontalPositionSlider:SetOnValueChanged(function(_, value)
		local unit = addon.Options.Sections.Content:GetSelectedUnit()
		addon.Database:GetProfile().frames[unit].position.x = value
		addon.UpdateScheduler:Notify("layoutChanged", unit)
	end)

	page.verticalPositionSlider = addon.Options.Controls.Slider:Create(page.body, "Vertical Position")
	page.verticalPositionSlider:SetLayoutWidth(178)
	page.verticalPositionSlider:SetMinMaxValues(-2000, 2000)
	page.verticalPositionSlider:SetStep(1)
	page.verticalPositionSlider:SetLayoutPoint("TOPLEFT", page.horizontalPositionSlider, "TOPRIGHT", 24, 0)
	page.verticalPositionSlider:SetOnValueChanged(function(_, value)
		local unit = addon.Options.Sections.Content:GetSelectedUnit()
		addon.Database:GetProfile().frames[unit].position.y = value
		addon.UpdateScheduler:Notify("layoutChanged", unit)
	end)

	page.spacingSlider = addon.Options.Controls.Slider:Create(page.body, "Spacing")
	page.spacingSlider:SetLayoutWidth(178)
	page.spacingSlider:SetMinMaxValues(-10, 100)
	page.spacingSlider:SetStep(1)
	page.spacingSlider:SetLayoutPoint("TOPLEFT", page.verticalPositionSlider, "TOPRIGHT", 24, 0)
	page.spacingSlider:SetOnValueChanged(function(_, value)
		addon.Database:GetProfile().frames.boss.spacing = value
		addon.UpdateScheduler:Notify("layoutChanged", "boss")
	end)

	page.frameWidthSlider = addon.Options.Controls.Slider:Create(page.body, "Frame Width")
	page.frameWidthSlider:SetLayoutWidth(178)
	page.frameWidthSlider:SetMinMaxValues(10, 500)
	page.frameWidthSlider:SetStep(1)
	page.frameWidthSlider:SetLayoutPoint("TOPLEFT", page.horizontalPositionSlider, "BOTTOMLEFT", 0, -24)
	page.frameWidthSlider:SetOnValueChanged(function(_, value)
		local unit = addon.Options.Sections.Content:GetSelectedUnit()
		addon.Database:GetProfile().frames[unit].size.width = value
		addon.UpdateScheduler:Notify("layoutChanged", unit)
	end)

	page.frameHeightSlider = addon.Options.Controls.Slider:Create(page.body, "Frame Height")
	page.frameHeightSlider:SetLayoutWidth(178)
	page.frameHeightSlider:SetMinMaxValues(10, 500)
	page.frameHeightSlider:SetStep(1)
	page.frameHeightSlider:SetLayoutPoint("TOPLEFT", page.frameWidthSlider, "TOPRIGHT", 24, 0)
	page.frameHeightSlider:SetOnValueChanged(function(_, value)
		local unit = addon.Options.Sections.Content:GetSelectedUnit()
		addon.Database:GetProfile().frames[unit].size.height = value
		addon.UpdateScheduler:Notify("layoutChanged", unit)
	end)

	function page:UpdateLayout()
		self.header:SetHeight(PP:ToUIScaled(32))
		self.header.title:SetFont("Fonts\\ARIALN.TTF", PP:ScaleFont(20), "")
		self.body:SetPoint("TOPLEFT", self.header, "BOTTOMLEFT", 0, PP:ToUIScaled(-16))
		self.body:SetPoint("TOPRIGHT", self.header, "BOTTOMRIGHT", 0, PP:ToUIScaled(-16))
	end

	function page:UpdateState(profile, unit)
		local settings = profile.frames[unit]
		self.enabledCheckbox:SetChecked(settings.enabled)
		self.hideBlizzardFrameCheckbox:SetText(unit == "boss" and "Hide Blizzard Frames" or "Hide Blizzard Frame")
		self.hideBlizzardFrameCheckbox:SetChecked(settings.hideBlizzardFrame)
		self.horizontalPositionSlider:SetValueSilently(settings.position.x)
		self.verticalPositionSlider:SetValueSilently(settings.position.y)
		self.spacingSlider:SetShown(unit == "boss")

		if unit == "boss" then
			self.spacingSlider:SetValueSilently(settings.spacing)
		end

		self.frameWidthSlider:SetValueSilently(settings.size.width)
		self.frameHeightSlider:SetValueSilently(settings.size.height)
	end

	page:UpdateState(addon.Database:GetProfile(), addon.Options.Sections.Content:GetSelectedUnit())

	return page
end
