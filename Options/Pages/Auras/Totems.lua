local _, addon = ...

local OptionsUILib = LibStub("MichsOptionsUILib-1.0")

addon.Options = addon.Options or {}
addon.Options.Pages = addon.Options.Pages or {}
addon.Options.Pages.Auras = addon.Options.Pages.Auras or {}
addon.Options.Pages.Auras.Totems = addon.Options.Pages.Auras.Totems or {}

local Totems = addon.Options.Pages.Auras.Totems
local PP = addon.OptionsUI.PP
local subpage

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
	subpage.iconsRow:SetLayoutPoint("TOPLEFT", subpage.enabledCheckbox, "BOTTOMLEFT", 0, -4)
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

	function subpage:UpdateLayout()
		OptionsUILib.Theme:ApplyFont(self.unavailableText, PP:ToUI(14), "")
	end

	function subpage:UpdateState(profile, unit)
		local available = unit == "player"
		self.enabledCheckbox:SetShown(available)
		self.iconsRow.frame:SetShown(available)
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
