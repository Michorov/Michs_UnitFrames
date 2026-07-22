local _, addon = ...

local Updater = {}
addon.Updater = Updater

local initialized = false

local function UpdateUnitState(frame)
	addon.Frames.Widgets.Bars.Health:UpdateState(frame)
	addon.Frames.Widgets.Bars.Power:UpdateState(frame)
	addon.Frames.Widgets.Bars.Cast:UpdateState(frame)
	addon.Frames.Widgets.Background:UpdateState(frame)
	addon.Frames.Widgets.Bars.Absorbs:UpdateState(frame)
	addon.Frames.Widgets.Bars.HealAbsorbs:UpdateState(frame)
	addon.Frames.Widgets.Texts.Name:UpdateState(frame)
	addon.Frames.Widgets.Texts.Health:UpdateState(frame)
	addon.Frames.Widgets.Texts.Power:UpdateState(frame)
	addon.Frames.Widgets.Indicators.Combat:UpdateState(frame)
	addon.Frames.Widgets.Indicators.RaidMarker:UpdateState(frame)
	addon.Frames.Widgets.Indicators.GroupStatus:UpdateState(frame)
end

local function UpdateUnitSettings(frame)
	addon.Frames.Widgets.MouseoverHighlight:UpdateSettings(frame)
	addon.Frames.Widgets.Background:UpdateSettings(frame)
	addon.Frames.Widgets.Bars.Health:UpdateSettings(frame)
	addon.Frames.Widgets.Bars.Power:UpdateSettings(frame)
	addon.Frames.Widgets.Bars.Cast:UpdateSettings(frame)
	addon.Frames.Widgets.Bars.Absorbs:UpdateSettings(frame)
	addon.Frames.Widgets.Bars.HealAbsorbs:UpdateSettings(frame)
	addon.Frames.Widgets.Texts.Health:UpdateSettings(frame)
	addon.Frames.Widgets.Texts.Name:UpdateSettings(frame)
	addon.Frames.Widgets.Texts.Power:UpdateSettings(frame)
	addon.Frames.Widgets.Indicators.Combat:UpdateSettings(frame)
	addon.Frames.Widgets.Indicators.RaidMarker:UpdateSettings(frame)
	addon.Frames.Widgets.Indicators.GroupStatus:UpdateSettings(frame)
end

local function BuildSettingsUpdater(updateReasons)
	return function(frame)
		if updateReasons.mouseoverHighlightSettingsChanged then
			addon.Frames.Widgets.MouseoverHighlight:UpdateSettings(frame)
		end

		if updateReasons.backgroundSettingsChanged then
			addon.Frames.Widgets.Background:UpdateSettings(frame)
		end

		if updateReasons.healthSettingsChanged then
			addon.Frames.Widgets.Bars.Health:UpdateSettings(frame)
		end

		if updateReasons.powerSettingsChanged then
			addon.Frames.Widgets.Bars.Power:UpdateSettings(frame)
		end

		if updateReasons.castSettingsChanged then
			addon.Frames.Widgets.Bars.Cast:UpdateSettings(frame)
		end

		if updateReasons.absorbsSettingsChanged then
			addon.Frames.Widgets.Bars.Absorbs:UpdateSettings(frame)
		end

		if updateReasons.healAbsorbsSettingsChanged then
			addon.Frames.Widgets.Bars.HealAbsorbs:UpdateSettings(frame)
		end

		if updateReasons.healthTextSettingsChanged then
			addon.Frames.Widgets.Texts.Health:UpdateSettings(frame)
		end

		if updateReasons.nameTextSettingsChanged then
			addon.Frames.Widgets.Texts.Name:UpdateSettings(frame)
		end

		if updateReasons.powerTextSettingsChanged then
			addon.Frames.Widgets.Texts.Power:UpdateSettings(frame)
		end

		if updateReasons.combatIndicatorSettingsChanged then
			addon.Frames.Widgets.Indicators.Combat:UpdateSettings(frame)
		end

		if updateReasons.raidMarkerSettingsChanged then
			addon.Frames.Widgets.Indicators.RaidMarker:UpdateSettings(frame)
		end

		if updateReasons.groupStatusSettingsChanged then
			addon.Frames.Widgets.Indicators.GroupStatus:UpdateSettings(frame)
		end
	end
end

local function BuildStateUpdater(updateReasons)
	return function(frame)
		if updateReasons.unitChanged then
			UpdateUnitState(frame)
			return
		end

		if updateReasons.healthStateChanged or updateReasons.unitColorStateChanged then
			addon.Frames.Widgets.Bars.Health:UpdateState(frame)
		end

		if updateReasons.healthStateChanged then
			addon.Frames.Widgets.Texts.Health:UpdateState(frame)
		end

		if updateReasons.absorbsStateChanged then
			addon.Frames.Widgets.Bars.Absorbs:UpdateState(frame)
		end

		if updateReasons.healAbsorbsStateChanged then
			addon.Frames.Widgets.Bars.HealAbsorbs:UpdateState(frame)
		end

		if updateReasons.unitColorStateChanged then
			addon.Frames.Widgets.Background:UpdateState(frame)
			addon.Frames.Widgets.Texts.Name:UpdateState(frame)
			addon.Frames.Widgets.Texts.Health:UpdateState(frame)
		end

		if updateReasons.nameStateChanged then
			addon.Frames.Widgets.Texts.Name:UpdateState(frame)
		end

		if updateReasons.powerStateChanged then
			addon.Frames.Widgets.Bars.Power:UpdateState(frame)
			addon.Frames.Widgets.Texts.Power:UpdateState(frame)
		end

		if updateReasons.castStateChanged then
			addon.Frames.Widgets.Bars.Cast:UpdateState(frame)
		end

		if updateReasons.combatStateChanged then
			addon.Frames.Widgets.Indicators.Combat:UpdateState(frame)
		end

		if updateReasons.raidMarkerStateChanged then
			addon.Frames.Widgets.Indicators.RaidMarker:UpdateState(frame)
		end

		if updateReasons.groupStatusStateChanged then
			addon.Frames.Widgets.Indicators.GroupStatus:UpdateState(frame)
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

		local stateUpdater = BuildStateUpdater(unitReasons)
		local settingsUpdater = BuildSettingsUpdater(unitReasons)

		addon.FrameRegistry:UpdateUnit(unit, stateUpdater, settingsUpdater)
	end

	if hasGlobal then
		if globalReasons.profileChanged then
			addon.FrameRegistry:UpdateAllVisibility()
			addon.FrameRegistry:UpdateAllLayouts()
			addon.FrameRegistry:UpdateAllUnits(UpdateUnitState, UpdateUnitSettings)
		else
			local stateUpdater = BuildStateUpdater(globalReasons)
			local settingsUpdater = BuildSettingsUpdater(globalReasons)

			addon.FrameRegistry:UpdateAllUnits(stateUpdater, settingsUpdater)
		end
	end
end

function Updater:CreateFlushCallback()
	if initialized then
		error("Flush Callback was already created", 2)
	end

	initialized = true

	return Flush
end
