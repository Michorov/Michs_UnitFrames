local _, addon = ...

local OptionsUILib = LibStub("MichsOptionsUILib-1.0")

addon.Options = addon.Options or {}
addon.Options.Pages = addon.Options.Pages or {}
addon.Options.Pages.Indicators = addon.Options.Pages.Indicators or {}
addon.Options.Pages.Indicators.GroupStatus = addon.Options.Pages.Indicators.GroupStatus or {}

local GroupStatus = addon.Options.Pages.Indicators.GroupStatus
local PP = addon.OptionsUI.PP
local subpage

local anchorOptions = {
	{ value = "TOPLEFT", text = "Top Left" },
	{ value = "TOP", text = "Top" },
	{ value = "TOPRIGHT", text = "Top Right" },
	{ value = "RIGHT", text = "Right" },
	{ value = "BOTTOMRIGHT", text = "Bottom Right" },
	{ value = "BOTTOM", text = "Bottom" },
	{ value = "BOTTOMLEFT", text = "Bottom Left" },
	{ value = "LEFT", text = "Left" },
	{ value = "CENTER", text = "Center" },
}

function GroupStatus:Create(page)
	local owner = page:RegisterSubPage("groupStatus", { title = "Leader & Assistant" })
	subpage = owner.frame
	subpage.unavailableText = subpage:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	subpage.unavailableText:SetPoint("TOPLEFT", subpage, "TOPLEFT", 0, 0)
	subpage.unavailableText:SetJustifyH("LEFT")
	subpage.unavailableText:SetTextColor(OptionsUILib.Theme:GetTextColor("secondary"))
	subpage.unavailableText:SetText("Leader & Assistant indicator is not available for this frame")
	subpage.unavailableText:Hide()

	subpage.enabledCheckbox = owner:CreateControl("Checkbox", "Enabled")
	subpage.enabledCheckbox:SetLayoutWidth(176)
	subpage.enabledCheckbox:SetLayoutPoint("TOPLEFT", subpage, "TOPLEFT", 0, 0)
	subpage.enabledCheckbox:SetOnValueChanged(function(_, enabled)
		addon.Database:GetProfile().frames.player.groupStatus.enabled = enabled
		addon.UpdateScheduler:Notify("groupStatusSettingsChanged", "player")
	end)

	subpage.showLeaderCheckbox = owner:CreateControl("Checkbox", "Leader")
	subpage.showLeaderCheckbox:SetLayoutWidth(176)
	subpage.showLeaderCheckbox:SetLayoutPoint(
		"TOPLEFT",
		subpage.enabledCheckbox,
		"BOTTOMLEFT",
		0,
		-24
	)
	subpage.showLeaderCheckbox:SetOnValueChanged(function(_, enabled)
		addon.Database:GetProfile().frames.player.groupStatus.showLeader = enabled
		addon.UpdateScheduler:Notify("groupStatusSettingsChanged", "player")
	end)

	subpage.showAssistantCheckbox = owner:CreateControl("Checkbox", "Assistant")
	subpage.showAssistantCheckbox:SetLayoutWidth(176)
	subpage.showAssistantCheckbox:SetLayoutPoint(
		"TOPLEFT",
		subpage.showLeaderCheckbox,
		"TOPRIGHT",
		24,
		0
	)
	subpage.showAssistantCheckbox:SetOnValueChanged(function(_, enabled)
		addon.Database:GetProfile().frames.player.groupStatus.showAssistant = enabled
		addon.UpdateScheduler:Notify("groupStatusSettingsChanged", "player")
	end)

	subpage.anchorDropdown = owner:CreateControl("Dropdown", "Position")
	subpage.anchorDropdown:SetLayoutWidth(176)
	subpage.anchorDropdown:SetOptions(anchorOptions)
	subpage.anchorDropdown:SetLayoutPoint(
		"TOPLEFT",
		subpage.showLeaderCheckbox,
		"BOTTOMLEFT",
		0,
		-24
	)
	subpage.anchorDropdown:SetOnValueChanged(function(_, value)
		addon.Database:GetProfile().frames.player.groupStatus.anchor = value
		addon.UpdateScheduler:Notify("groupStatusSettingsChanged", "player")
	end)

	subpage.offsetXSlider = owner:CreateControl("Slider", "Offset X")
	subpage.offsetXSlider:SetLayoutWidth(176)
	subpage.offsetXSlider:SetMinMaxValues(-100, 100)
	subpage.offsetXSlider:SetStep(1)
	subpage.offsetXSlider:SetLayoutPoint("TOPLEFT", subpage.anchorDropdown, "TOPRIGHT", 24, 0)
	subpage.offsetXSlider:SetOnValueChanged(function(_, value)
		addon.Database:GetProfile().frames.player.groupStatus.position.x = value
		addon.UpdateScheduler:Notify("groupStatusSettingsChanged", "player")
	end)

	subpage.offsetYSlider = owner:CreateControl("Slider", "Offset Y")
	subpage.offsetYSlider:SetLayoutWidth(176)
	subpage.offsetYSlider:SetMinMaxValues(-100, 100)
	subpage.offsetYSlider:SetStep(1)
	subpage.offsetYSlider:SetLayoutPoint("TOPLEFT", subpage.offsetXSlider, "TOPRIGHT", 24, 0)
	subpage.offsetYSlider:SetOnValueChanged(function(_, value)
		addon.Database:GetProfile().frames.player.groupStatus.position.y = value
		addon.UpdateScheduler:Notify("groupStatusSettingsChanged", "player")
	end)

	subpage.sizeSlider = owner:CreateControl("Slider", "Size")
	subpage.sizeSlider:SetLayoutWidth(176)
	subpage.sizeSlider:SetMinMaxValues(8, 64)
	subpage.sizeSlider:SetStep(1)
	subpage.sizeSlider:SetLayoutPoint("TOPLEFT", subpage.anchorDropdown, "BOTTOMLEFT", 0, -24)
	subpage.sizeSlider:SetOnValueChanged(function(_, value)
		addon.Database:GetProfile().frames.player.groupStatus.size = value
		addon.UpdateScheduler:Notify("groupStatusSettingsChanged", "player")
	end)

	function subpage:UpdateLayout()
		OptionsUILib.Theme:ApplyFont(self.unavailableText, PP:ScaleFont(14), "")
	end

	function subpage:UpdateState(profile, unit)
		local available = unit == "player"
		self.enabledCheckbox:SetShown(available)
		self.showLeaderCheckbox:SetShown(available)
		self.showAssistantCheckbox:SetShown(available)
		self.anchorDropdown:SetShown(available)
		self.offsetXSlider:SetShown(available)
		self.offsetYSlider:SetShown(available)
		self.sizeSlider:SetShown(available)
		self.unavailableText:SetShown(not available)

		if not available then
			return
		end

		local settings = profile.frames.player.groupStatus
		self.enabledCheckbox:SetChecked(settings.enabled)
		self.showLeaderCheckbox:SetChecked(settings.showLeader)
		self.showAssistantCheckbox:SetChecked(settings.showAssistant)
		self.anchorDropdown:SetValue(settings.anchor)
		self.offsetXSlider:SetValueSilently(settings.position.x)
		self.offsetYSlider:SetValueSilently(settings.position.y)
		self.sizeSlider:SetValueSilently(settings.size)
	end

	subpage:UpdateLayout()

	owner:SetStateUpdater(function(profile, unit)
		subpage:UpdateState(profile, unit)
	end)

	local UpdateLayout = owner.UpdateLayout
	function owner:UpdateLayout()
		UpdateLayout(self)
		subpage:UpdateLayout()
	end

	return owner
end
