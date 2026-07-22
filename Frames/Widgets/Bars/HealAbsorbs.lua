local _, addon = ...

addon.Frames = addon.Frames or {}
addon.Frames.Widgets = addon.Frames.Widgets or {}
addon.Frames.Widgets.Bars = addon.Frames.Widgets.Bars or {}
addon.Frames.Widgets.Bars.HealAbsorbs = addon.Frames.Widgets.Bars.HealAbsorbs or {}

local HealAbsorbs = addon.Frames.Widgets.Bars.HealAbsorbs
local settingsCache = {}

local function UpdateSettingsCache(frame)
	local settings = addon.Database:GetProfile().frames[frame.settingsUnit]
	settingsCache[frame.settingsUnit] = settings.healAbsorbs or {}
end

local function GetHealAbsorbs(frame)
	local unit = frame.unit
	if not unit or not UnitExists(unit) or UnitCanAttack("player", unit) then
		return nil
	end

	local healAbsorbValue

	if CreateUnitHealPredictionCalculator and UnitGetDetailedHealPrediction then
		frame.healAbsorbCalculator = frame.healAbsorbCalculator or CreateUnitHealPredictionCalculator()
		local calculator = frame.healAbsorbCalculator

		if calculator.SetHealAbsorbClampMode then
			pcall(calculator.SetHealAbsorbClampMode, calculator, 0)
		end

		UnitGetDetailedHealPrediction(unit, nil, calculator)

		if calculator.GetHealAbsorbs then
			local succeeded, value = pcall(calculator.GetHealAbsorbs, calculator)
			if succeeded then
				healAbsorbValue = value
			end
		end
	end

	if healAbsorbValue == nil and UnitGetTotalHealAbsorbs then
		healAbsorbValue = UnitGetTotalHealAbsorbs(unit)
	end

	return healAbsorbValue
end

function HealAbsorbs:Ensure(frame)
	if not frame.healAbsorbBar then
		local healAbsorbBar = CreateFrame("StatusBar", nil, frame)
		healAbsorbBar:SetFrameLevel(14)
		healAbsorbBar:SetOrientation("HORIZONTAL")
		healAbsorbBar:SetReverseFill(false)
		healAbsorbBar:Hide()

		local texture = healAbsorbBar:CreateTexture(nil, "ARTWORK")
		texture:SetTexture("Interface\\AddOns\\Michs_UnitFrames\\Media\\Textures\\Absorb", "REPEAT", "REPEAT")
		texture:SetHorizTile(true)
		texture:SetVertTile(true)
		healAbsorbBar:SetStatusBarTexture(texture)

		local healthTexture = frame.healthBar and frame.healthBar:GetStatusBarTexture()
		if healthTexture then
			healAbsorbBar:SetPoint("TOPLEFT", healthTexture, "TOPLEFT", 0, 0)
			healAbsorbBar:SetPoint("BOTTOMRIGHT", healthTexture, "BOTTOMRIGHT", 0, 0)
		end

		frame.healAbsorbBar = healAbsorbBar
	end

	self:UpdateSettings(frame)
end

function HealAbsorbs:UpdateSettings(frame)
	UpdateSettingsCache(frame)
	local cachedSettings = settingsCache[frame.settingsUnit]

	if cachedSettings.enabled == false then
		frame.healAbsorbBar:Hide()
		return
	end

	local bar = frame.healAbsorbBar
	local color = cachedSettings.color or {}

	bar:SetStatusBarColor(color.r or 1, color.g or 0, color.b or 0, color.a or 0.5)

	self:UpdateState(frame)
end

function HealAbsorbs:UpdateState(frame)
	local cachedSettings = settingsCache[frame.settingsUnit]

	if cachedSettings.enabled == false then
		frame.healAbsorbBar:Hide()
		return
	end

	local healAbsorbValue = GetHealAbsorbs(frame)
	if healAbsorbValue == nil then
		frame.healAbsorbBar:Hide()
		return
	end

	local currentHealth = UnitHealth(frame.unit)
	if currentHealth == nil then
		frame.healAbsorbBar:Hide()
		return
	end

	frame.healAbsorbBar:SetMinMaxValues(0, currentHealth)
	frame.healAbsorbBar:SetValue(healAbsorbValue)
	frame.healAbsorbBar:Show()
end
