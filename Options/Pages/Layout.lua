local _, addon = ...

addon.Options = addon.Options or {}
addon.Options.Pages = addon.Options.Pages or {}
addon.Options.Pages.Layout = addon.Options.Pages.Layout or {}

local Layout = addon.Options.Pages.Layout
local page

function Layout:Create(panel)
	local owner = panel:RegisterPage("layout", {
		title = "Layout",
		showHeader = true,
		showModeSwitch = true,
		modeSwitchType = "dropdown",
		showHeaderButton = true,
		headerButtonText = "Unlock",
		headerButtonCallback = function()
			addon.FrameRegistry:SetUnlocked(not addon.FrameRegistry:IsUnlocked())
			addon.Options:RefreshProfile()
		end,
	})
	local content = owner:RegisterSubPage("layout", { title = "Layout" })
	page = content.frame
	page.unlockButton = owner.headerButton

	page.enabledCheckbox = content:CreateControl("Checkbox", "Enabled")
	page.enabledCheckbox:SetLayoutPoint("TOPLEFT", page, "TOPLEFT", 0, 0)
	page.enabledCheckbox:SetOnValueChanged(function(_, enabled)
		local unit = addon.Options:GetSelectedUnit()
		addon.Database:GetProfile().frames[unit].enabled = enabled
		addon.UpdateScheduler:Notify("visibilityChanged", unit)
	end)

	page.hideBlizzardFrameCheckbox = content:CreateControl("Checkbox", "Hide Blizzard Frame")
	page.hideBlizzardFrameCheckbox:SetLayoutPoint("TOPLEFT", page.enabledCheckbox, "BOTTOMLEFT", 0, -8)
	page.hideBlizzardFrameCheckbox:SetOnValueChanged(function(_, hidden)
		local unit = addon.Options:GetSelectedUnit()
		addon.Database:GetProfile().frames[unit].hideBlizzardFrame = hidden
		addon.UpdateScheduler:Notify("visibilityChanged", unit)
	end)

	page.horizontalPositionSlider = content:CreateControl("Slider", "Horizontal Position")
	page.horizontalPositionSlider:SetLayoutWidth(176)
	page.horizontalPositionSlider:SetMinMaxValues(-2000, 2000)
	page.horizontalPositionSlider:SetStep(1)
	page.horizontalPositionSlider:SetLayoutPoint("TOPLEFT", page.hideBlizzardFrameCheckbox, "BOTTOMLEFT", 0, -24)
	page.horizontalPositionSlider:SetOnValueChanged(function(_, value)
		local unit = addon.Options:GetSelectedUnit()
		addon.Database:GetProfile().frames[unit].position.x = value
		addon.UpdateScheduler:Notify("layoutChanged", unit)
	end)

	page.verticalPositionSlider = content:CreateControl("Slider", "Vertical Position")
	page.verticalPositionSlider:SetLayoutWidth(176)
	page.verticalPositionSlider:SetMinMaxValues(-2000, 2000)
	page.verticalPositionSlider:SetStep(1)
	page.verticalPositionSlider:SetLayoutPoint("TOPLEFT", page.horizontalPositionSlider, "TOPRIGHT", 24, 0)
	page.verticalPositionSlider:SetOnValueChanged(function(_, value)
		local unit = addon.Options:GetSelectedUnit()
		addon.Database:GetProfile().frames[unit].position.y = value
		addon.UpdateScheduler:Notify("layoutChanged", unit)
	end)

	page.spacingSlider = content:CreateControl("Slider", "Spacing")
	page.spacingSlider:SetLayoutWidth(176)
	page.spacingSlider:SetMinMaxValues(-10, 100)
	page.spacingSlider:SetStep(1)
	page.spacingSlider:SetLayoutPoint("TOPLEFT", page.verticalPositionSlider, "TOPRIGHT", 24, 0)
	page.spacingSlider:SetOnValueChanged(function(_, value)
		addon.Database:GetProfile().frames.boss.spacing = value
		addon.UpdateScheduler:Notify("layoutChanged", "boss")
	end)

	page.frameWidthSlider = content:CreateControl("Slider", "Frame Width")
	page.frameWidthSlider:SetLayoutWidth(176)
	page.frameWidthSlider:SetMinMaxValues(10, 500)
	page.frameWidthSlider:SetStep(1)
	page.frameWidthSlider:SetLayoutPoint("TOPLEFT", page.horizontalPositionSlider, "BOTTOMLEFT", 0, -24)
	page.frameWidthSlider:SetOnValueChanged(function(_, value)
		local unit = addon.Options:GetSelectedUnit()
		addon.Database:GetProfile().frames[unit].size.width = value
		addon.UpdateScheduler:Notify("layoutChanged", unit)
	end)

	page.frameHeightSlider = content:CreateControl("Slider", "Frame Height")
	page.frameHeightSlider:SetLayoutWidth(176)
	page.frameHeightSlider:SetMinMaxValues(10, 500)
	page.frameHeightSlider:SetStep(1)
	page.frameHeightSlider:SetLayoutPoint("TOPLEFT", page.frameWidthSlider, "TOPRIGHT", 24, 0)
	page.frameHeightSlider:SetOnValueChanged(function(_, value)
		local unit = addon.Options:GetSelectedUnit()
		addon.Database:GetProfile().frames[unit].size.height = value
		addon.UpdateScheduler:Notify("layoutChanged", unit)
	end)


	function page:UpdateState(profile, unit)
		local settings = profile.frames[unit]
		self.unlockButton:SetText(addon.FrameRegistry:IsUnlocked() and "Lock" or "Unlock")
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


	content:SetStateUpdater(function(profile, unit)
		page:UpdateState(profile, unit)
	end)

	return owner
end
