local _, addon = ...

addon.Frames = addon.Frames or {}
addon.Frames.Widgets = addon.Frames.Widgets or {}
addon.Frames.Widgets.Bars = addon.Frames.Widgets.Bars or {}
addon.Frames.Widgets.Bars.HealAbsorbs = addon.Frames.Widgets.Bars.HealAbsorbs or {}

local HealAbsorbs = addon.Frames.Widgets.Bars.HealAbsorbs

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

function HealAbsorbs:Ensure(frame, settings)
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

		local healthTexture = frame.healthBar:GetStatusBarTexture()
		healAbsorbBar:SetPoint("TOPLEFT", healthTexture, "TOPLEFT", 0, 0)
		healAbsorbBar:SetPoint("BOTTOMRIGHT", healthTexture, "BOTTOMRIGHT", 0, 0)

		frame.healAbsorbBar = healAbsorbBar
	end

	self:UpdateSettings(frame, settings)
end

function HealAbsorbs:UpdateSettings(frame, settings)
	local bar = frame.healAbsorbBar
	local healAbsorbSettings = (settings and settings.healAbsorbs) or {}
	local color = healAbsorbSettings.color or {}
	bar.enabled = healAbsorbSettings.enabled ~= false
	bar:SetStatusBarColor(
		color.r or 1,
		color.g or 0,
		color.b or 0,
		color.a or 0.5
	)

	self:UpdateState(frame, settings)
end

function HealAbsorbs:UpdateState(frame, settings)
	if not frame.healAbsorbBar.enabled then
		frame.healAbsorbBar:Hide()
		return
	end

	local healAbsorbValue = GetHealAbsorbs(frame)
	if healAbsorbValue == nil then
		frame.healAbsorbBar:Hide()
		return
	end

	frame.healAbsorbBar:SetMinMaxValues(0, UnitHealth(frame.unit))
	frame.healAbsorbBar:SetValue(healAbsorbValue)
	frame.healAbsorbBar:Show()
end
