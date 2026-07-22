local _, addon = ...

local EventHandler = {}
addon.EventHandler = EventHandler

local eventFrame = CreateFrame("Frame")
local unitEventFrames = {}
local initialized = false
local encounterActive = false
local combatActive = false

local supportedUnits = {
	player = true,
	target = true,
	targettarget = true,
	pet = true,
	focus = true,
	focustarget = true,
	boss1 = true,
	boss2 = true,
	boss3 = true,
	boss4 = true,
	boss5 = true,
}

local supportedCastUnits = {
	player = true,
	pet = true,
	target = true,
	focus = true,
	boss1 = true,
	boss2 = true,
	boss3 = true,
	boss4 = true,
	boss5 = true,
}

local unitEvents = {
	"UNIT_NAME_UPDATE",
	"UNIT_POWER_FREQUENT",
	"UNIT_MAXPOWER",
	"UNIT_DISPLAYPOWER",
	"UNIT_HEALTH",
	"UNIT_MAXHEALTH",
	"UNIT_ABSORB_AMOUNT_CHANGED",
	"UNIT_HEAL_ABSORB_AMOUNT_CHANGED",
	"UNIT_FACTION",
}

local castEvents = {
	"UNIT_SPELLCAST_START",
	"UNIT_SPELLCAST_STOP",
	"UNIT_SPELLCAST_FAILED",
	"UNIT_SPELLCAST_INTERRUPTED",
	"UNIT_SPELLCAST_DELAYED",
	"UNIT_SPELLCAST_CHANNEL_START",
	"UNIT_SPELLCAST_CHANNEL_UPDATE",
	"UNIT_SPELLCAST_CHANNEL_STOP",
	"UNIT_SPELLCAST_EMPOWER_START",
	"UNIT_SPELLCAST_EMPOWER_UPDATE",
	"UNIT_SPELLCAST_EMPOWER_STOP",
	"UNIT_SPELLCAST_INTERRUPTIBLE",
	"UNIT_SPELLCAST_NOT_INTERRUPTIBLE",
}

local function DispatchEvent(_, event, ...)
	local handler = EventHandler[event]
	if handler then
		handler(EventHandler, event, ...)
	end
end

local function CreateUnitEventFrame(unit)
	local frame = CreateFrame("Frame")

	for _, event in ipairs(unitEvents) do
		frame:RegisterUnitEvent(event, unit)
	end

	if supportedCastUnits[unit] then
		for _, event in ipairs(castEvents) do
			frame:RegisterUnitEvent(event, unit)
		end
	end

	if unit:match("^boss%d+$") then
		frame:RegisterUnitEvent("UNIT_TARGETABLE_CHANGED", unit)
	end

	frame:SetScript("OnEvent", DispatchEvent)
	unitEventFrames[unit] = frame
end

function EventHandler:Initialize()
	if initialized then
		error("EventHandler already initialized", 2)
	end

	eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
	eventFrame:RegisterEvent("ENCOUNTER_START")
	eventFrame:RegisterEvent("ENCOUNTER_END")
	eventFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
	eventFrame:RegisterEvent("PLAYER_FOCUS_CHANGED")
	eventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
	eventFrame:RegisterEvent("PARTY_LEADER_CHANGED")
	eventFrame:RegisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT")
	eventFrame:RegisterUnitEvent("UNIT_PET", "player")
	eventFrame:RegisterUnitEvent("UNIT_TARGET", "target", "focus")
	eventFrame:RegisterEvent("RAID_TARGET_UPDATE")
	eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
	eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")

	for unit in pairs(supportedUnits) do
		CreateUnitEventFrame(unit)
	end

	eventFrame:SetScript("OnEvent", DispatchEvent)

	initialized = true
end

function EventHandler:PLAYER_ENTERING_WORLD()
	combatActive = UnitAffectingCombat("player") == true
	addon.FrameRegistry:UpdateBlizzardFrameVisibility()
	addon.UpdateScheduler:Notify("unitChanged", "player")
	addon.UpdateScheduler:Notify("unitChanged", "target")
	addon.UpdateScheduler:Notify("unitChanged", "targettarget")
	addon.UpdateScheduler:Notify("unitChanged", "pet")
	addon.UpdateScheduler:Notify("unitChanged", "focus")
	addon.UpdateScheduler:Notify("unitChanged", "focustarget")
	addon.UpdateScheduler:Notify("unitChanged", "boss")
end

function EventHandler:ENCOUNTER_START()
	encounterActive = true
	combatActive = true
	addon.UpdateScheduler:Notify("combatStateChanged", "player")
end

function EventHandler:ENCOUNTER_END()
	encounterActive = false
	combatActive = false
	addon.UpdateScheduler:Notify("combatStateChanged", "player")
end

function EventHandler:PLAYER_REGEN_DISABLED()
	if addon.Options:IsOpen() then
		addon.Options:Close()
	end

	if encounterActive then
		return
	end

	combatActive = true
	addon.UpdateScheduler:Notify("combatStateChanged", "player")
end

function EventHandler:PLAYER_REGEN_ENABLED()
	addon.FrameRegistry:UpdateBlizzardFrameVisibility()

	if addon.Options:ShouldOpenAfterCombat() then
		addon.Options:Open()
	end

	if encounterActive then
		return
	end

	combatActive = false
	addon.UpdateScheduler:Notify("combatStateChanged", "player")
end

function EventHandler:IsCombatActive()
	return combatActive
end

function EventHandler:RAID_TARGET_UPDATE()
	addon.UpdateScheduler:Notify("raidMarkerStateChanged")
end

function EventHandler:GROUP_ROSTER_UPDATE()
	addon.UpdateScheduler:Notify("groupStatusStateChanged", "player")
end

function EventHandler:PARTY_LEADER_CHANGED()
	addon.UpdateScheduler:Notify("groupStatusStateChanged", "player")
end

function EventHandler:PLAYER_TARGET_CHANGED()
	addon.UpdateScheduler:Notify("unitChanged", "target")
	addon.UpdateScheduler:Notify("unitChanged", "targettarget")
end

function EventHandler:PLAYER_FOCUS_CHANGED()
	addon.UpdateScheduler:Notify("unitChanged", "focus")
	addon.UpdateScheduler:Notify("unitChanged", "focustarget")
end

function EventHandler:INSTANCE_ENCOUNTER_ENGAGE_UNIT()
	addon.FrameRegistry:UpdateBlizzardFrameVisibility()
	addon.UpdateScheduler:Notify("unitChanged", "boss")
end

function EventHandler:UNIT_PET(event, unit)
	if unit == "player" then
		addon.UpdateScheduler:Notify("unitChanged", "pet")
	end
end

function EventHandler:UNIT_TARGET(event, unit)
	if unit == "target" then
		addon.UpdateScheduler:Notify("unitChanged", "targettarget")
	elseif unit == "focus" then
		addon.UpdateScheduler:Notify("unitChanged", "focustarget")
	end
end

function EventHandler:UNIT_TARGETABLE_CHANGED(event, unit)
	addon.UpdateScheduler:Notify("unitChanged", unit)
end

function EventHandler:UNIT_NAME_UPDATE(event, unit)
	addon.UpdateScheduler:Notify("nameStateChanged", unit)
end

function EventHandler:UNIT_POWER_FREQUENT(event, unit)
	addon.UpdateScheduler:Notify("powerValueChanged", unit)
end

function EventHandler:UNIT_MAXPOWER(event, unit)
	addon.UpdateScheduler:Notify("powerMaximumChanged", unit)
end

function EventHandler:UNIT_DISPLAYPOWER(event, unit)
	addon.UpdateScheduler:Notify("powerTypeChanged", unit)
end

function EventHandler:UNIT_SPELLCAST_START(event, unit)
	addon.UpdateScheduler:Notify("castStateChanged", unit)
end

EventHandler.UNIT_SPELLCAST_STOP = EventHandler.UNIT_SPELLCAST_START
EventHandler.UNIT_SPELLCAST_FAILED = EventHandler.UNIT_SPELLCAST_START
EventHandler.UNIT_SPELLCAST_INTERRUPTED = EventHandler.UNIT_SPELLCAST_START
EventHandler.UNIT_SPELLCAST_DELAYED = EventHandler.UNIT_SPELLCAST_START
EventHandler.UNIT_SPELLCAST_CHANNEL_START = EventHandler.UNIT_SPELLCAST_START
EventHandler.UNIT_SPELLCAST_CHANNEL_UPDATE = EventHandler.UNIT_SPELLCAST_START
EventHandler.UNIT_SPELLCAST_CHANNEL_STOP = EventHandler.UNIT_SPELLCAST_START
EventHandler.UNIT_SPELLCAST_EMPOWER_START = EventHandler.UNIT_SPELLCAST_START
EventHandler.UNIT_SPELLCAST_EMPOWER_UPDATE = EventHandler.UNIT_SPELLCAST_START
EventHandler.UNIT_SPELLCAST_EMPOWER_STOP = EventHandler.UNIT_SPELLCAST_START
EventHandler.UNIT_SPELLCAST_INTERRUPTIBLE = EventHandler.UNIT_SPELLCAST_START
EventHandler.UNIT_SPELLCAST_NOT_INTERRUPTIBLE = EventHandler.UNIT_SPELLCAST_START

function EventHandler:UNIT_HEALTH(event, unit)
	addon.UpdateScheduler:Notify("healthStateChanged", unit)
	addon.UpdateScheduler:Notify("absorbsStateChanged", unit)
	addon.UpdateScheduler:Notify("healAbsorbsStateChanged", unit)
end

function EventHandler:UNIT_MAXHEALTH(event, unit)
	addon.UpdateScheduler:Notify("healthStateChanged", unit)
	addon.UpdateScheduler:Notify("absorbsStateChanged", unit)
	addon.UpdateScheduler:Notify("healAbsorbsStateChanged", unit)
end

function EventHandler:UNIT_ABSORB_AMOUNT_CHANGED(event, unit)
	addon.UpdateScheduler:Notify("absorbsStateChanged", unit)
end

function EventHandler:UNIT_HEAL_ABSORB_AMOUNT_CHANGED(event, unit)
	addon.UpdateScheduler:Notify("healAbsorbsStateChanged", unit)
end

function EventHandler:UNIT_FACTION(event, unit)
	addon.UpdateScheduler:Notify("unitColorStateChanged", unit)
end
