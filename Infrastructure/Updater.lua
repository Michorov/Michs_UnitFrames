local _, addon = ...

local Updater = {}
addon.Updater = Updater

local initialized = false

local function UpdateUnitState(frame, settings)
	addon.Frames.Widgets.Bars.Health:UpdateState(frame, settings)
	addon.Frames.Widgets.Background:UpdateState(frame, settings)
	addon.Frames.Widgets.Bars.Absorbs:UpdateState(frame, settings)
	addon.Frames.Widgets.Bars.HealAbsorbs:UpdateState(frame, settings)
	addon.Frames.Widgets.Texts.Name:UpdateState(frame, settings)
	addon.Frames.Widgets.Texts.Health:UpdateState(frame, settings)
end

local function BuildSettingsUpdater(updateReasons, settings)
	return function(frame)
		local frameSettings = settings
		if not frameSettings then
			local settingsUnit = frame.unit:match("^boss%d+$") and "boss" or frame.unit
			frameSettings = addon.Database:GetProfile().frames[settingsUnit]
		end

		if updateReasons.mouseoverHighlightSettingsChanged then
			addon.Frames.Widgets.MouseoverHighlight:UpdateSettings(
				frame,
				addon.Database:GetProfile().general
			)
		end

		if updateReasons.backgroundSettingsChanged then
			addon.Frames.Widgets.Background:UpdateSettings(frame, frameSettings)
		end

		if updateReasons.healthSettingsChanged then
			addon.Frames.Widgets.Bars.Health:UpdateSettings(frame, frameSettings)
		end

		if updateReasons.absorbsSettingsChanged then
			addon.Frames.Widgets.Bars.Absorbs:UpdateSettings(frame, frameSettings)
		end

		if updateReasons.healAbsorbsSettingsChanged then
			addon.Frames.Widgets.Bars.HealAbsorbs:UpdateSettings(frame, frameSettings)
		end

		if updateReasons.healthTextSettingsChanged then
			addon.Frames.Widgets.Texts.Health:UpdateSettings(frame, frameSettings)
		end

		if updateReasons.nameTextSettingsChanged then
			addon.Frames.Widgets.Texts.Name:UpdateSettings(frame, frameSettings)
		end
	end
end

local function BuildStateUpdater(updateReasons, settings)
	return function(frame)
		if updateReasons.unitChanged then
			UpdateUnitState(frame, settings)
			return
		end

		if updateReasons.healthStateChanged or updateReasons.unitColorStateChanged then
			addon.Frames.Widgets.Bars.Health:UpdateState(frame, settings)
		end

		if updateReasons.healthStateChanged then
			addon.Frames.Widgets.Texts.Health:UpdateState(frame, settings)
		end

		if updateReasons.absorbsStateChanged then
			addon.Frames.Widgets.Bars.Absorbs:UpdateState(frame, settings)
		end

		if updateReasons.healAbsorbsStateChanged then
			addon.Frames.Widgets.Bars.HealAbsorbs:UpdateState(frame, settings)
		end

		if updateReasons.unitColorStateChanged then
			addon.Frames.Widgets.Background:UpdateState(frame, settings)
			addon.Frames.Widgets.Texts.Name:UpdateState(frame, settings)
			addon.Frames.Widgets.Texts.Health:UpdateState(frame, settings)
		end

		if updateReasons.nameStateChanged then
			addon.Frames.Widgets.Texts.Name:UpdateState(frame, settings)
		end
	end
end

local function Flush(updateReasons)
	if not addon.FrameRegistry:IsInitialized() then
		return
	end

	local globalReasons = updateReasons.global or {}
	local hasUnits = next(updateReasons.units or {}) ~= nil
	local hasGlobal = next(globalReasons) ~= nil
	if not hasUnits and not hasGlobal then
		return
	end

	for unit, unitReasons in pairs(updateReasons.units or {}) do
		if unitReasons.visibilityChanged then
			addon.FrameRegistry:UpdateVisibility(unit)
		end

		if unitReasons.layoutChanged then
			addon.FrameRegistry:UpdateLayout(unit)
		end

		local settingsUnit = unit:match("^boss%d+$") and "boss" or unit
		local settings = addon.Database:GetProfile().frames[settingsUnit]
		local stateUpdater = BuildStateUpdater(unitReasons, settings)
		local settingsUpdater = BuildSettingsUpdater(unitReasons, settings)

		addon.FrameRegistry:UpdateUnit(unit, stateUpdater, settingsUpdater)
	end

	if hasGlobal then
		local stateUpdater = BuildStateUpdater(globalReasons)
		local settingsUpdater = BuildSettingsUpdater(globalReasons)

		addon.FrameRegistry:UpdateAllUnits(stateUpdater, settingsUpdater)
	end
end

function Updater:CreateFlushCallback()
	if initialized then
		error("Flush Callback was already created", 2)
	end

	initialized = true

	return Flush
end
