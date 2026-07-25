local _, addon = ...

local _, _, _, interfaceVersion = GetBuildInfo()
addon.IsRestrictedAuraAPI = (tonumber(interfaceVersion) or 0) >= 120100

addon.AuraHandler = addon.AuraHandler or {}
local AuraHandler = addon.AuraHandler

local AURA_FILTERS = {
	helpful = "HELPFUL",
	harmful = "HARMFUL",
}

AuraHandler.unitAuras = {
	helpful = {},
	harmful = {},
}

local GetUnitAuras = C_UnitAuras and C_UnitAuras.GetUnitAuras

function AuraHandler:UpdateAurasForUnit(unit)
	if addon.IsRestrictedAuraAPI then
		return
	end

	if type(unit) ~= "string" or unit == "" or not UnitExists(unit) or not GetUnitAuras then
		return
	end

	for collectionKey, filter in pairs(AURA_FILTERS) do
		local success, auras = pcall(GetUnitAuras, unit, filter)
		self.unitAuras[collectionKey][unit] = success and auras or {}
	end
end

function AuraHandler:GetUnitAuras(unit, collectionKey)
	if addon.IsRestrictedAuraAPI then
		return {}
	end

	local collection = self.unitAuras[collectionKey]
	if not collection then
		return {}
	end

	if type(unit) ~= "string" or unit == "" or not UnitExists(unit) then
		return {}
	end

	if not collection[unit] then
		self:UpdateAurasForUnit(unit)
	end

	return collection[unit] or {}
end
