local _, addon = ...

addon.Frames = addon.Frames or {}
addon.Frames.ManagedContainers = addon.Frames.ManagedContainers or {}
addon.Frames.ManagedContainers.Debuffs = addon.Frames.ManagedContainers.Debuffs or {}

local Debuffs = addon.Frames.ManagedContainers.Debuffs
local AuraButtons = addon.Frames.ManagedContainers.AuraButtons
local PP = addon.PixelPerfect

local settingsCache = {}

local anchorLayouts = {
	TOPLEFT = {
		containerPoint = "BOTTOMLEFT",
		framePoint = "TOPLEFT",
		flowPoint = "BOTTOMLEFT",
		xDirection = AnchorUtil.FlowDirection.Right,
		yDirection = AnchorUtil.FlowDirection.Up,
	},
	TOPRIGHT = {
		containerPoint = "BOTTOMRIGHT",
		framePoint = "TOPRIGHT",
		flowPoint = "BOTTOMRIGHT",
		xDirection = AnchorUtil.FlowDirection.Left,
		yDirection = AnchorUtil.FlowDirection.Up,
	},
	BOTTOMLEFT = {
		containerPoint = "TOPLEFT",
		framePoint = "BOTTOMLEFT",
		flowPoint = "TOPLEFT",
		xDirection = AnchorUtil.FlowDirection.Right,
		yDirection = AnchorUtil.FlowDirection.Down,
	},
	BOTTOMRIGHT = {
		containerPoint = "TOPRIGHT",
		framePoint = "BOTTOMRIGHT",
		flowPoint = "TOPRIGHT",
		xDirection = AnchorUtil.FlowDirection.Left,
		yDirection = AnchorUtil.FlowDirection.Down,
	},
}

local function IsAvailableFrame(frame)
	return frame and (frame.settingsUnit == "player" or frame.settingsUnit == "target")
end

local function UpdateSettingsCache(frame)
	local profile = addon.Database:GetProfile()
	local frameSettings = profile.frames[frame.settingsUnit] or {}
	local settings = frameSettings.debuffs or {}
	local position = settings.position or {}
	local maxIcons = math.max(1, settings.maxIcons or 12)
	local defaultAnchor = frame.settingsUnit == "target" and "TOPRIGHT" or "TOPLEFT"
	local anchor = settings.anchor

	if
		anchor ~= "TOPLEFT"
		and anchor ~= "TOPRIGHT"
		and anchor ~= "BOTTOMLEFT"
		and anchor ~= "BOTTOMRIGHT"
	then
		anchor = defaultAnchor
	end

	settingsCache[frame.settingsUnit] = {
		enabled = settings.enabled == true,
		anchor = anchor,
		maxIcons = maxIcons,
		iconsPerRow = math.max(1, settings.iconsPerRow or 6),
		iconSize = settings.iconSize or 24,
		spacing = settings.spacing or 2,
		showStacks = settings.showStacks ~= false,
		stacksFontSize = settings.stacksFontSize or 10,
		showCooldown = settings.showCooldown == true,
		cooldownFontSize = settings.cooldownFontSize or 10,
		showTooltips = settings.showTooltips == true,
		position = {
			x = position.x or 0,
			y = position.y or 1,
		},
	}
end

local function UpdateContainerLayout(frame, cachedSettings)
	local container = frame.debuffs
	local layout = anchorLayouts[cachedSettings.anchor] or anchorLayouts.TOPLEFT
	local iconSize = PP:ToUIScaled(cachedSettings.iconSize)
	local spacing = PP:ToUIScaled(cachedSettings.spacing)
	local visibleColumns = math.min(cachedSettings.maxIcons, cachedSettings.iconsPerRow)
	local rowWidth = (iconSize * visibleColumns) + (spacing * (visibleColumns - 1)) + 1

	container:ClearAllPoints()
	container:SetPoint(
		layout.containerPoint,
		frame,
		layout.framePoint,
		PP:ToUIScaled(cachedSettings.position.x),
		PP:ToUIScaled(cachedSettings.position.y)
	)
	container:SetFlowLayoutAnchorPoint(layout.flowPoint)
	container:SetFlowLayoutGrowthDirection(layout.xDirection, layout.yDirection)
	container:SetFlowLayoutMaximumLineSize(rowWidth)
end

local function UpdateAuraGroupSettings(frame, cachedSettings)
	local container = frame.debuffs
	local spacing = PP:ToUIScaled(cachedSettings.spacing)
	local maxFrameCount = cachedSettings.enabled and cachedSettings.maxIcons or 0

	container:SetAuraGroupMaxFrameCount("debuffs", maxFrameCount)
	container:SetAuraGroupLayout("debuffs", {
		elementSpacing = spacing,
		lineSpacing = spacing,
	})
	container:UpdateAllAuras()
end

local function UpdateButtonsSettings(frame, cachedSettings)
	for button in pairs(frame.debuffs.auraButtons or {}) do
		AuraButtons:ApplyIconSettings(button, cachedSettings)
		AuraButtons:ApplyBorderSettings(button)
		AuraButtons:ApplyCooldownSettings(button, cachedSettings)
		AuraButtons:ApplyCountSettings(button, cachedSettings)
		AuraButtons:ApplyTooltipSettings(button, cachedSettings)
	end
end

function Debuffs:Ensure(frame)
	if not IsAvailableFrame(frame) then
		return
	end

	if not settingsCache[frame.settingsUnit] then
		UpdateSettingsCache(frame)
	end

	if frame.debuffs then
		return
	end

	local container = CreateFrame("AuraContainer", nil, frame, "CustomAuraContainerTemplate")
	container:SetFrameLevel(42)
	frame.debuffs = container

	UpdateContainerLayout(frame, settingsCache[frame.settingsUnit])

	container:AddAuraGroup("debuffs", "HARMFUL", {
		maxFrameCount = 0,
		candidateFilters = {},
		sortMethod = AuraContainerSortMethod.UnitFrameDebuff,
		sortDirection = AuraContainerSortDirection.Normal,
		initializeFrame = function(button)
			AuraButtons:Initialize(button, container)
			local cachedSettings = settingsCache[frame.settingsUnit]
			AuraButtons:ApplyIconSettings(button, cachedSettings)
			AuraButtons:ApplyBorderSettings(button)
			AuraButtons:ApplyCooldownSettings(button, cachedSettings)
			AuraButtons:ApplyCountSettings(button, cachedSettings)
			AuraButtons:ApplyTooltipSettings(button, cachedSettings)
		end,
	})

	self:SetUnit(frame)
	self:UpdateSettings(frame)
end

function Debuffs:UpdateSettings(frame)
	if not IsAvailableFrame(frame) then
		return
	end

	UpdateSettingsCache(frame)

	local cachedSettings = settingsCache[frame.settingsUnit]
	if not frame.debuffs then
		return
	end

	UpdateButtonsSettings(frame, cachedSettings)
	UpdateContainerLayout(frame, cachedSettings)
	UpdateAuraGroupSettings(frame, cachedSettings)
	self:UpdateState(frame)
end

function Debuffs:UpdateState(frame)
	if not IsAvailableFrame(frame) or not frame.debuffs then
		return
	end

	if not settingsCache[frame.settingsUnit] then
		UpdateSettingsCache(frame)
	end

	local cachedSettings = settingsCache[frame.settingsUnit]
	local shouldShow = cachedSettings.enabled and frame.unit and UnitExists(frame.unit)

	if frame.debuffs.isShown ~= shouldShow then
		frame.debuffs.isShown = shouldShow
		frame.debuffs:SetShown(shouldShow)
	end
end

function Debuffs:SetUnit(frame)
	if not IsAvailableFrame(frame) or not frame.debuffs then
		return
	end

	frame.debuffs:SetUnit((frame.unit and UnitExists(frame.unit)) and frame.unit or "none")
	frame.debuffs:UpdateAllAuras()
	self:UpdateState(frame)
end
