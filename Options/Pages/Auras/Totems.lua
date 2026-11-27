local _, addon = ...

local OptionsUILib = LibStub("MichsOptionsUILib-1.0")

addon.Options = addon.Options or {}
addon.Options.Pages = addon.Options.Pages or {}
addon.Options.Pages.Auras = addon.Options.Pages.Auras or {}
addon.Options.Pages.Auras.Totems = addon.Options.Pages.Auras.Totems or {}

local Totems = addon.Options.Pages.Auras.Totems
local PP = addon.OptionsUI.PP
local subpage

local visibilityOptions = {
	{ value = true, text = "Show" },
	{ value = false, text = "Hide" },
}

local growthDirectionOptions = {
	{ value = "UP_LEFT", text = "Up and Left" },
	{ value = "UP_RIGHT", text = "Up and Right" },
	{ value = "DOWN_LEFT", text = "Down and Left" },
	{ value = "DOWN_RIGHT", text = "Down and Right" },
}

function Totems:Create(page)
	local owner = page:RegisterSubPage("totems", { title = "Totems" })
	subpage = owner.frame
	subpage.unavailableText = subpage:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	subpage.unavailableText:SetPoint("TOPLEFT", subpage, "TOPLEFT", 0, 0)
	subpage.unavailableText:SetJustifyH("LEFT")
	subpage.unavailableText:SetTextColor(OptionsUILib.Theme:GetTextColor("secondary"))
	subpage.unavailableText:SetText("Totems are not available for this frame")
	subpage.unavailableText:Hide()

	subpage.enabledCheckbox = owner:CreateControl("Checkbox", "Enabled")
	subpage.enabledCheckbox:SetLayoutWidth(126)
	subpage.enabledCheckbox:SetLayoutPoint("TOPLEFT", subpage, "TOPLEFT", 0, 0)
	subpage.enabledCheckbox:SetOnValueChanged(function(_, enabled)
		addon.Database:GetProfile().frames.player.totems.enabled = enabled
		addon.UpdateScheduler:Notify("totemsSettingsChanged", "player")
	end)

	subpage.iconsRow = owner:CreateRow(4)
	subpage.iconsRow:SetLayoutPoint("TOPLEFT", subpage.enabledCheckbox, "BOTTOMLEFT", 0, -16)
	local maxSlots = math.max(1, GetNumTotemSlots())

	subpage.maxIconsSlider = subpage.iconsRow:CreateControl("Slider", "Max Icons")
	subpage.maxIconsSlider:SetMinMaxValues(1, maxSlots)
	subpage.maxIconsSlider:SetStep(1)
	subpage.maxIconsSlider:SetOnValueChanged(function(_, value)
		addon.Database:GetProfile().frames.player.totems.maxIcons = value
		addon.UpdateScheduler:Notify("totemsSettingsChanged", "player")
	end)

	subpage.iconsPerRowSlider = subpage.iconsRow:CreateControl("Slider", "Icons Per Row")
	subpage.iconsPerRowSlider:SetMinMaxValues(1, maxSlots)
	subpage.iconsPerRowSlider:SetStep(1)
	subpage.iconsPerRowSlider:SetOnValueChanged(function(_, value)
		addon.Database:GetProfile().frames.player.totems.iconsPerRow = value
		addon.UpdateScheduler:Notify("totemsSettingsChanged", "player")
	end)

	subpage.iconSizeSlider = subpage.iconsRow:CreateControl("Slider", "Icon Size")
	subpage.iconSizeSlider:SetMinMaxValues(12, 48)
	subpage.iconSizeSlider:SetStep(1)
	subpage.iconSizeSlider:SetOnValueChanged(function(_, value)
		addon.Database:GetProfile().frames.player.totems.iconSize = value
		addon.UpdateScheduler:Notify("totemsSettingsChanged", "player")
	end)

	subpage.spacingSlider = subpage.iconsRow:CreateControl("Slider", "Spacing")
	subpage.spacingSlider:SetMinMaxValues(0, 12)
	subpage.spacingSlider:SetStep(1)
	subpage.spacingSlider:SetOnValueChanged(function(_, value)
		addon.Database:GetProfile().frames.player.totems.spacing = value
		addon.UpdateScheduler:Notify("totemsSettingsChanged", "player")
	end)

	subpage.positionRow = owner:CreateRow(4)
	subpage.positionRow:SetLayoutPoint("TOPLEFT", subpage.iconsRow.frame, "BOTTOMLEFT", 0, -16)

	subpage.growthDirectionDropdown = subpage.positionRow:CreateControl("Dropdown", "Growth Direction")
	subpage.growthDirectionDropdown:SetOptions(growthDirectionOptions)
	subpage.growthDirectionDropdown:SetOnValueChanged(function(_, value)
		addon.Database:GetProfile().frames.player.totems.growthDirection = value
		addon.UpdateScheduler:Notify("totemsSettingsChanged", "player")
	end)

	subpage.offsetXSlider = subpage.positionRow:CreateControl("Slider", "Offset X")
	subpage.offsetXSlider:SetMinMaxValues(-2000, 2000)
	subpage.offsetXSlider:SetStep(1)
	subpage.offsetXSlider:SetOnValueChanged(function(_, value)
		addon.Database:GetProfile().frames.player.totems.position.x = value
		addon.UpdateScheduler:Notify("totemsSettingsChanged", "player")
	end)

	subpage.offsetYSlider = subpage.positionRow:CreateControl("Slider", "Offset Y")
	subpage.offsetYSlider:SetMinMaxValues(-2000, 2000)
	subpage.offsetYSlider:SetStep(1)
	subpage.offsetYSlider:SetOnValueChanged(function(_, value)
		addon.Database:GetProfile().frames.player.totems.position.y = value
		addon.UpdateScheduler:Notify("totemsSettingsChanged", "player")
	end)

	subpage.cooldownRow = owner:CreateRow(4)
	subpage.cooldownRow:SetLayoutPoint("TOPLEFT", subpage.positionRow.frame, "BOTTOMLEFT", 0, -16)

	subpage.showCooldownDropdown = subpage.cooldownRow:CreateControl("Dropdown", "Show Cooldown")
	subpage.showCooldownDropdown:SetOptions(visibilityOptions)
	subpage.showCooldownDropdown:SetOnValueChanged(function(_, value)
		addon.Database:GetProfile().frames.player.totems.showCooldown = value == true
		addon.UpdateScheduler:Notify("totemsSettingsChanged", "player")
	end)

	subpage.cooldownFontSizeSlider = subpage.cooldownRow:CreateControl("Slider", "Cooldown Font Size")
	subpage.cooldownFontSizeSlider:SetMinMaxValues(6, 20)
	subpage.cooldownFontSizeSlider:SetStep(1)
	subpage.cooldownFontSizeSlider:SetOnValueChanged(function(_, value)
		addon.Database:GetProfile().frames.player.totems.cooldownFontSize = value
		addon.UpdateScheduler:Notify("totemsSettingsChanged", "player")
	end)

	function subpage:UpdateLayout()
		OptionsUILib.Theme:ApplyFont(self.unavailableText, PP:ToUI(14), "")
	end

	function subpage:UpdateState(profile, unit)
		local available = unit == "player"
		self.enabledCheckbox:SetShown(available)
		self.iconsRow.frame:SetShown(available)
		self.positionRow.frame:SetShown(available)
		self.cooldownRow.frame:SetShown(available)
		self.unavailableText:SetShown(not available)

		if not available then
			return
		end

		local settings = profile.frames.player.totems
		self.enabledCheckbox:SetChecked(settings.enabled)
		self.maxIconsSlider:SetValueSilently(settings.maxIcons)
		self.iconsPerRowSlider:SetValueSilently(settings.iconsPerRow)
		self.iconSizeSlider:SetValueSilently(settings.iconSize)
		self.spacingSlider:SetValueSilently(settings.spacing)
		self.growthDirectionDropdown:SetValue(settings.growthDirection)
		self.offsetXSlider:SetValueSilently(settings.position.x)
		self.offsetYSlider:SetValueSilently(settings.position.y)
		self.showCooldownDropdown:SetValue(settings.showCooldown)
		self.cooldownFontSizeSlider:SetValueSilently(settings.cooldownFontSize)
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
