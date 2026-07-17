local _, addon = ...

local EventHandler = {}
addon.EventHandler = EventHandler

local eventFrame = CreateFrame("Frame")
local initialized = false

local function NotifyUnitState(unit)
	addon.UpdateScheduler:Notify("healthStateChanged", unit)
	addon.UpdateScheduler:Notify("nameStateChanged", unit)
end

function EventHandler:Initialize()
	if initialized then
		error("EventHandler already initialized", 2)
	end

	eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
	eventFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
	eventFrame:RegisterEvent("UNIT_PET")
	eventFrame:RegisterEvent("UNIT_TARGET")
	eventFrame:RegisterEvent("UNIT_HEALTH")
	eventFrame:RegisterEvent("UNIT_MAXHEALTH")

	eventFrame:SetScript("OnEvent", function(self, event, ...)
		if EventHandler[event] then
			EventHandler[event](EventHandler, event, ...)
		end
	end)

	initialized = true
end

function EventHandler:PLAYER_ENTERING_WORLD() end

function EventHandler:PLAYER_TARGET_CHANGED()
	NotifyUnitState("target")
	NotifyUnitState("targettarget")
end

function EventHandler:UNIT_PET(event, unit)
	if unit == "player" then
		NotifyUnitState("pet")
	end
end

function EventHandler:UNIT_TARGET(event, unit)
	if unit == "target" then
		NotifyUnitState("targettarget")
	end
end

function EventHandler:UNIT_HEALTH(event, unit)
	addon.UpdateScheduler:Notify("healthStateChanged", unit)
end

function EventHandler:UNIT_MAXHEALTH(event, unit)
	addon.UpdateScheduler:Notify("healthStateChanged", unit)
end
