local _, addon = ...

local EventHandler = {}
addon.EventHandler = EventHandler

local eventFrame = CreateFrame("Frame")
local initialized = false

function EventHandler:Initialize()
	if initialized then
		error("EventHandler already initialized", 2)
	end

	eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
	eventFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
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
	addon.UpdateScheduler:Notify("healthStateChanged", "target")
	addon.UpdateScheduler:Notify("nameStateChanged", "target")
end

function EventHandler:UNIT_HEALTH(event, unit)
	addon.UpdateScheduler:Notify("healthStateChanged", unit)
end

function EventHandler:UNIT_MAXHEALTH(event, unit)
	addon.UpdateScheduler:Notify("healthStateChanged", unit)
end
