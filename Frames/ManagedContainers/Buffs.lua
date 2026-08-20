local _, addon = ...

addon.Frames = addon.Frames or {}
addon.Frames.ManagedContainers = addon.Frames.ManagedContainers or {}
addon.Frames.ManagedContainers.Buffs = addon.Frames.ManagedContainers.Buffs or {}

local Buffs = addon.Frames.ManagedContainers.Buffs
local AuraButtons = addon.Frames.ManagedContainers.AuraButtons
local PP = addon.PixelPerfect

local settingsCache = {}

local anchorLayouts = {
	LEFT = {
		containerPoint = "TOPRIGHT",
		framePoint = "TOPLEFT",
		flowPoint = "TOPRIGHT",
		xDirection = AnchorUtil.FlowDirection.Left,
		yDirection = AnchorUtil.FlowDirection.Down,
	},
	RIGHT = {
		containerPoint = "TOPLEFT",
		framePoint = "TOPRIGHT",
		flowPoint = "TOPLEFT",
		xDirection = AnchorUtil.FlowDirection.Right,
		yDirection = AnchorUtil.FlowDirection.Down,
	},
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
	return frame and (frame.settingsUnit == "player" or frame.settingsUnit == "target" or frame.settingsUnit == "boss")
end

local function UpdateSettingsCache(frame)
	local profile = addon.Database:GetProfile()
	local frameSettings = profile.frames[frame.settingsUnit] or {}
	local settings = frameSettings.buffs or {}
	local position = settings.position or {}
	local maxIcons = math.max(1, settings.maxIcons or 12)
	local defaultAnchor = frame.settingsUnit == "boss" and "LEFT" or "TOPRIGHT"
	local anchor = settings.anchor

	if frame.settingsUnit == "boss" then
		if anchor ~= "LEFT" and anchor ~= "RIGHT" then
			anchor = defaultAnchor
		end
	elseif
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
		iconsPerRow = frame.settingsUnit == "boss" and maxIcons or math.max(1, settings.iconsPerRow or 6),
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
	local container = frame.buffs
	local layout = anchorLayouts[cachedSettings.anchor] or anchorLayouts.TOPRIGHT
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
	local container = frame.buffs
	local spacing = PP:ToUIScaled(cachedSettings.spacing)
	local maxFrameCount = cachedSettings.enabled and cachedSettings.maxIcons or 0

	container:SetAuraGroupMaxFrameCount("buffs", maxFrameCount)
	container:SetAuraGroupLayout("buffs", {
		elementSpacing = spacing,
		lineSpacing = spacing,
	})
	container:UpdateAllAuras()
end

local function UpdateButtonsSettings(frame, cachedSettings)
	for button in pairs(frame.buffs.auraButtons or {}) do
		AuraButtons:ApplyIconSettings(button, cachedSettings)
		AuraButtons:ApplyBorderSettings(button)
		AuraButtons:ApplyCooldownSettings(button, cachedSettings)
		AuraButtons:ApplyCountSettings(button, cachedSettings)
		AuraButtons:ApplyTooltipSettings(button, cachedSettings)
	end
end

function Buffs:Ensure(frame)
	if not IsAvailableFrame(frame) then
		return
	end

	if not settingsCache[frame.settingsUnit] then
		UpdateSettingsCache(frame)
	end

	if frame.buffs then
		return
	end

	local container = CreateFrame("AuraContainer", nil, frame, "CustomAuraContainerTemplate")
	container:SetFrameLevel(42)
	frame.buffs = container

	UpdateContainerLayout(frame, settingsCache[frame.settingsUnit])

	container:AddAuraGroup("buffs", "HELPFUL", {
		maxFrameCount = 0,
		candidateFilters = {},
		sortMethod = AuraContainerSortMethod.Default,
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

function Buffs:UpdateSettings(frame)
	if not IsAvailableFrame(frame) then
		return
	end

	UpdateSettingsCache(frame)

	local cachedSettings = settingsCache[frame.settingsUnit]
	if not frame.buffs then
		return
	end

	UpdateButtonsSettings(frame, cachedSettings)
	UpdateContainerLayout(frame, cachedSettings)
	UpdateAuraGroupSettings(frame, cachedSettings)
	self:UpdateState(frame)
end

function Buffs:UpdateState(frame)
	if not IsAvailableFrame(frame) or not frame.buffs then
		return
	end

	if not settingsCache[frame.settingsUnit] then
		UpdateSettingsCache(frame)
	end

	local cachedSettings = settingsCache[frame.settingsUnit]
	local shouldShow = cachedSettings.enabled and frame.unit and UnitExists(frame.unit)

	if frame.buffs.isShown ~= shouldShow then
		frame.buffs.isShown = shouldShow
		frame.buffs:SetShown(shouldShow)
	end
end

function Buffs:SetUnit(frame)
	if not IsAvailableFrame(frame) or not frame.buffs then
		return
	end

	frame.buffs:SetUnit((frame.unit and UnitExists(frame.unit)) and frame.unit or "none")
	frame.buffs:UpdateAllAuras()
	self:UpdateState(frame)
end
