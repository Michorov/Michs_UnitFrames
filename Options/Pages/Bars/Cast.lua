local _, addon = ...

local OptionsUILib = LibStub("MichsOptionsUILib-1.0")

addon.Options = addon.Options or {}
addon.Options.Pages = addon.Options.Pages or {}
addon.Options.Pages.Bars = addon.Options.Pages.Bars or {}
addon.Options.Pages.Bars.Cast = addon.Options.Pages.Bars.Cast or {}

local Cast = addon.Options.Pages.Bars.Cast
local PP = addon.OptionsUI.PP
local subpage

local availableUnits = {
	player = true,
	pet = true,
	target = true,
	focus = true,
	boss = true,
}

local elementPositionOptions = {
	{ value = "LEFT", text = "Left" },
	{ value = "RIGHT", text = "Right" },
	{ value = "HIDE", text = "Hide" },
}

local positionOptions = {
	{ value = "TOP", text = "Top" },
	{ value = "BOTTOM", text = "Bottom" },
}

function Cast:Create(page)
	local owner = page:RegisterSubPage("cast", { title = "Cast" })
	subpage = owner.frame
	subpage.unavailableText = subpage:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	subpage.unavailableText:SetPoint("TOPLEFT", subpage, "TOPLEFT", 0, 0)
	subpage.unavailableText:SetJustifyH("LEFT")
	subpage.unavailableText:SetTextColor(OptionsUILib.Theme:GetTextColor("secondary"))
	subpage.unavailableText:SetText("Cast bar is not available for this frame")
	subpage.unavailableText:Hide()

	subpage.enabledCheckbox = owner:CreateControl("Checkbox", "Enabled")
	subpage.enabledCheckbox:SetLayoutWidth(176)
	subpage.enabledCheckbox:SetLayoutPoint("TOPLEFT", subpage, "TOPLEFT", 0, 0)
	subpage.enabledCheckbox:SetOnValueChanged(function(_, enabled)
		local unit = addon.Options:GetSelectedUnit()
		local frameSettings = addon.Database:GetProfile().frames[unit]
		frameSettings.cast = frameSettings.cast or {}
		frameSettings.cast.enabled = enabled
		addon.UpdateScheduler:Notify("castSettingsChanged", unit)
	end)

	subpage.hideBlizzardCastBarCheckbox = owner:CreateControl("Checkbox", "Hide Blizzard Castbar"
	)
	subpage.hideBlizzardCastBarCheckbox:SetLayoutWidth(176)
	subpage.hideBlizzardCastBarCheckbox:SetLayoutPoint(
		"TOPLEFT",
		subpage.enabledCheckbox,
		"BOTTOMLEFT",
		0,
		-8
	)
	subpage.hideBlizzardCastBarCheckbox:SetOnValueChanged(function(_, hidden)
		local unit = addon.Options:GetSelectedUnit()
		if unit ~= "player" then
			return
		end

		local castSettings = addon.Database:GetProfile().frames.player.cast
		castSettings.hideBlizzardCastBar = hidden
		addon.UpdateScheduler:Notify("visibilityChanged", "player")
	end)

	subpage.textureDropdown = owner:CreateControl("Dropdown", "Texture")
	subpage.textureDropdown:SetLayoutWidth(176)
	subpage.textureDropdown:SetOptions(addon.Style.Textures:GetOptions(nil, true))
	subpage.textureDropdown:SetLayoutPoint(
		"TOPLEFT",
		subpage.enabledCheckbox,
		"BOTTOMLEFT",
		0,
		-24
	)
	subpage.textureDropdown:SetOnValueChanged(function(_, value)
		local unit = addon.Options:GetSelectedUnit()
		local frameSettings = addon.Database:GetProfile().frames[unit]
		frameSettings.cast = frameSettings.cast or {}
		frameSettings.cast.texture = value
		addon.UpdateScheduler:Notify("castSettingsChanged", unit)
	end)

	subpage.fontDropdown = owner:CreateControl("Dropdown", "Font")
	subpage.fontDropdown:SetLayoutWidth(176)
	subpage.fontDropdown:SetOptions(addon.Style.Fonts:GetOptions(nil, true))
	subpage.fontDropdown:SetLayoutPoint(
		"TOPLEFT",
		subpage.textureDropdown,
		"TOPRIGHT",
		24,
		0
	)
	subpage.fontDropdown:SetOnValueChanged(function(_, value)
		local unit = addon.Options:GetSelectedUnit()
		local frameSettings = addon.Database:GetProfile().frames[unit]
		frameSettings.cast = frameSettings.cast or {}
		frameSettings.cast.font = value
		addon.UpdateScheduler:Notify("castSettingsChanged", unit)
	end)

	subpage.positionDropdown = owner:CreateControl("Dropdown", "Bar Position")
	subpage.positionDropdown:SetLayoutWidth(176)
	subpage.positionDropdown:SetOptions(positionOptions)
	subpage.positionDropdown:SetLayoutPoint(
		"TOPLEFT",
		subpage.textureDropdown,
		"BOTTOMLEFT",
		0,
		-24
	)
	subpage.positionDropdown:SetOnValueChanged(function(_, value)
		local unit = addon.Options:GetSelectedUnit()
		local frameSettings = addon.Database:GetProfile().frames[unit]
		frameSettings.cast = frameSettings.cast or {}
		frameSettings.cast.position = value
		addon.UpdateScheduler:Notify("castSettingsChanged", unit)
	end)

	subpage.iconDropdown = owner:CreateControl("Dropdown", "Icon Position")
	subpage.iconDropdown:SetLayoutWidth(176)
	subpage.iconDropdown:SetOptions(elementPositionOptions)
	subpage.iconDropdown:SetLayoutPoint(
		"TOPLEFT",
		subpage.positionDropdown,
		"TOPRIGHT",
		24,
		0
	)
	subpage.iconDropdown:SetOnValueChanged(function(_, value)
		local unit = addon.Options:GetSelectedUnit()
		local frameSettings = addon.Database:GetProfile().frames[unit]
		frameSettings.cast = frameSettings.cast or {}
		frameSettings.cast.icon = frameSettings.cast.icon or {}
		frameSettings.cast.icon.position = value
		addon.UpdateScheduler:Notify("castSettingsChanged", unit)
	end)

	subpage.sizeSlider = owner:CreateControl("Slider", "Bar Size")
	subpage.sizeSlider:SetLayoutWidth(176)
	subpage.sizeSlider:SetMinMaxValues(1, 50)
	subpage.sizeSlider:SetStep(1)
	subpage.sizeSlider:SetLayoutPoint(
		"TOPLEFT",
		subpage.iconDropdown,
		"TOPRIGHT",
		24,
		0
	)
	subpage.sizeSlider:SetOnValueChanged(function(_, value)
		local unit = addon.Options:GetSelectedUnit()
		local frameSettings = addon.Database:GetProfile().frames[unit]
		frameSettings.cast = frameSettings.cast or {}
		frameSettings.cast.height = value
		addon.UpdateScheduler:Notify("castSettingsChanged", unit)
	end)

	subpage.spellNameDropdown = owner:CreateControl("Dropdown", "Spell Name")
	subpage.spellNameDropdown:SetLayoutWidth(176)
	subpage.spellNameDropdown:SetOptions(elementPositionOptions)
	subpage.spellNameDropdown:SetLayoutPoint(
		"TOPLEFT",
		subpage.positionDropdown,
		"BOTTOMLEFT",
		0,
		-24
	)
	subpage.spellNameDropdown:SetOnValueChanged(function(_, value)
		local unit = addon.Options:GetSelectedUnit()
		local frameSettings = addon.Database:GetProfile().frames[unit]
		frameSettings.cast = frameSettings.cast or {}
		frameSettings.cast.spellName = frameSettings.cast.spellName or {}
		frameSettings.cast.spellName.position = value
		addon.UpdateScheduler:Notify("castSettingsChanged", unit)
	end)

	subpage.castTimeDropdown = owner:CreateControl("Dropdown", "Cast Time")
	subpage.castTimeDropdown:SetLayoutWidth(176)
	subpage.castTimeDropdown:SetOptions(elementPositionOptions)
	subpage.castTimeDropdown:SetLayoutPoint(
		"TOPLEFT",
		subpage.spellNameDropdown,
		"TOPRIGHT",
		24,
		0
	)
	subpage.castTimeDropdown:SetOnValueChanged(function(_, value)
		local unit = addon.Options:GetSelectedUnit()
		local frameSettings = addon.Database:GetProfile().frames[unit]
		frameSettings.cast = frameSettings.cast or {}
		frameSettings.cast.castTime = frameSettings.cast.castTime or {}
		frameSettings.cast.castTime.position = value
		addon.UpdateScheduler:Notify("castSettingsChanged", unit)
	end)

	subpage.fontSizeSlider = owner:CreateControl("Slider", "Font Size")
	subpage.fontSizeSlider:SetLayoutWidth(176)
	subpage.fontSizeSlider:SetMinMaxValues(6, 32)
	subpage.fontSizeSlider:SetStep(1)
	subpage.fontSizeSlider:SetLayoutPoint(
		"TOPLEFT",
		subpage.castTimeDropdown,
		"TOPRIGHT",
		24,
		0
	)
	subpage.fontSizeSlider:SetOnValueChanged(function(_, value)
		local unit = addon.Options:GetSelectedUnit()
		local frameSettings = addon.Database:GetProfile().frames[unit]
		frameSettings.cast = frameSettings.cast or {}
		frameSettings.cast.fontSize = value
		addon.UpdateScheduler:Notify("castSettingsChanged", unit)
	end)

	function subpage:UpdateLayout()
		OptionsUILib.Theme:ApplyFont(self.unavailableText, PP:ScaleFont(14), "")
	end

	function subpage:UpdateState(profile, unit)
		local available = availableUnits[unit] == true
		self.enabledCheckbox:SetShown(available)
		self.hideBlizzardCastBarCheckbox:SetShown(available and unit == "player")
		self.textureDropdown:SetShown(available)
		self.fontDropdown:SetShown(available)
		self.positionDropdown:SetShown(available)
		self.sizeSlider:SetShown(available)
		self.iconDropdown:SetShown(available)
		self.spellNameDropdown:SetShown(available)
		self.castTimeDropdown:SetShown(available)
		self.fontSizeSlider:SetShown(available)
		self.unavailableText:SetShown(not available)

		if not available then
			return
		end

		local castSettings = profile.frames[unit].cast
		self.enabledCheckbox:SetChecked(not castSettings or castSettings.enabled ~= false)
		if unit == "player" then
			self.hideBlizzardCastBarCheckbox:SetChecked(
				castSettings and castSettings.hideBlizzardCastBar == true
			)
			self.textureDropdown:SetLayoutPoint(
				"TOPLEFT",
				self.hideBlizzardCastBarCheckbox,
				"BOTTOMLEFT",
				0,
				-24
			)
		else
			self.textureDropdown:SetLayoutPoint(
				"TOPLEFT",
				self.enabledCheckbox,
				"BOTTOMLEFT",
				0,
				-24
			)
		end
		local texture = (castSettings and castSettings.texture) or -1
		self.textureDropdown:SetOptions(addon.Style.Textures:GetOptions(texture, true))
		self.textureDropdown:SetValue(texture)
		local font = (castSettings and castSettings.font) or -1
		self.fontDropdown:SetOptions(addon.Style.Fonts:GetOptions(font, true))
		self.fontDropdown:SetValue(font)
		self.positionDropdown:SetValue(
			castSettings and castSettings.position
				or (unit == "focus" and "TOP" or "BOTTOM")
		)
		self.sizeSlider:SetValueSilently(
			(castSettings and castSettings.height)
				or ((unit == "pet" or unit == "focus") and 14 or 20)
		)
		local iconSettings = (castSettings and castSettings.icon) or {}
		self.iconDropdown:SetValue(iconSettings.position or "LEFT")
		local defaultFontSize = (unit == "pet" or unit == "focus") and 8 or 10
		local spellNameSettings = (castSettings and castSettings.spellName) or {}
		self.spellNameDropdown:SetValue(spellNameSettings.position or "LEFT")
		local castTimeSettings = (castSettings and castSettings.castTime) or {}
		self.castTimeDropdown:SetValue(castTimeSettings.position or "RIGHT")
		self.fontSizeSlider:SetValueSilently(
			(castSettings and castSettings.fontSize) or defaultFontSize
		)
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
