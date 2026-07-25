local _, addon = ...

addon.Frames = addon.Frames or {}
addon.Frames.Widgets = addon.Frames.Widgets or {}
addon.Frames.Widgets.Auras = addon.Frames.Widgets.Auras or {}
addon.Frames.Widgets.Auras.Buffs = addon.Frames.Widgets.Auras.Buffs or {}

local Buffs = addon.Frames.Widgets.Auras.Buffs

if addon.IsRestrictedAuraAPI then
	function Buffs:Ensure() end
	function Buffs:UpdateSettings() end
	function Buffs:UpdateState() end
	return
end

local PP = addon.PixelPerfect
local settingsCache = {}
local issecretvalue = issecretvalue

local anchorLayouts = {
	LEFT = {
		containerPoint = "TOPRIGHT",
		framePoint = "TOPLEFT",
		iconPoint = "TOPRIGHT",
		xDirection = -1,
		yDirection = 0,
	},
	RIGHT = {
		containerPoint = "TOPLEFT",
		framePoint = "TOPRIGHT",
		iconPoint = "TOPLEFT",
		xDirection = 1,
		yDirection = 0,
	},
	TOPLEFT = {
		containerPoint = "BOTTOMLEFT",
		framePoint = "TOPLEFT",
		iconPoint = "BOTTOMLEFT",
		xDirection = 1,
		yDirection = 1,
	},
	TOPRIGHT = {
		containerPoint = "BOTTOMRIGHT",
		framePoint = "TOPRIGHT",
		iconPoint = "BOTTOMRIGHT",
		xDirection = -1,
		yDirection = 1,
	},
	BOTTOMLEFT = {
		containerPoint = "TOPLEFT",
		framePoint = "BOTTOMLEFT",
		iconPoint = "TOPLEFT",
		xDirection = 1,
		yDirection = -1,
	},
	BOTTOMRIGHT = {
		containerPoint = "TOPRIGHT",
		framePoint = "BOTTOMRIGHT",
		iconPoint = "TOPRIGHT",
		xDirection = -1,
		yDirection = -1,
	},
}

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
		position = {
			x = position.x or 0,
			y = position.y or 1,
		},
	}
end

local function HideIcons(container)
	if not container then
		return
	end

	for _, icon in ipairs(container.icons) do
		icon:Hide()
	end

	container:Hide()
end

local function ApplyIconCooldown(icon, unit, aura, cachedSettings)
	local auraInstanceID = aura and aura.auraInstanceID

	if
		cachedSettings.showCooldown
		and auraInstanceID
		and C_UnitAuras
		and C_UnitAuras.GetAuraDuration
		and icon.cooldown.SetCooldownFromDurationObject
	then
		local durationObject = C_UnitAuras.GetAuraDuration(unit, auraInstanceID)
		if durationObject then
			icon.cooldown:SetCooldownFromDurationObject(durationObject)

			if C_UnitAuras.DoesAuraHaveExpirationTime and icon.cooldown.SetShownFromBoolean then
				icon.cooldown:SetShownFromBoolean(
					C_UnitAuras.DoesAuraHaveExpirationTime(unit, auraInstanceID),
					true,
					false
				)
			else
				icon.cooldown:Show()
			end

			return
		end
	end

	local duration = aura.duration
	local expirationTime = aura.expirationTime

	if
		not cachedSettings.showCooldown
		or (issecretvalue and (issecretvalue(duration) or issecretvalue(expirationTime)))
		or type(duration) ~= "number"
		or duration <= 0
		or type(expirationTime) ~= "number"
		or expirationTime <= 0
	then
		icon.cooldown:Hide()
		return
	end

	local startTime = expirationTime - duration
	if CooldownFrame_Set then
		CooldownFrame_Set(icon.cooldown, startTime, duration, true)
	else
		icon.cooldown:SetCooldown(startTime, duration)
	end

	icon.cooldown:Show()
end

local function GetStackText(unit, aura)
	local auraInstanceID = aura and aura.auraInstanceID
	if auraInstanceID and C_UnitAuras and C_UnitAuras.GetAuraApplicationDisplayCount then
		return C_UnitAuras.GetAuraApplicationDisplayCount(unit, auraInstanceID, 2, 99)
	end

	local applications = aura and aura.applications
	if issecretvalue and issecretvalue(applications) then
		return nil
	end

	if type(applications) == "number" and applications > 1 then
		return applications
	end
end

local function ApplyIconState(icon, unit, aura, cachedSettings)
	icon.texture:SetTexture(aura.icon)

	if cachedSettings.showStacks then
		icon.count:SetText(GetStackText(unit, aura) or "")
	else
		icon.count:SetText("")
	end

	ApplyIconCooldown(icon, unit, aura, cachedSettings)
	icon:Show()
end

local function CreateIcon(container)
	local icon = CreateFrame("Frame", nil, container)
	icon:SetFrameLevel(container:GetFrameLevel() + 1)

	icon.background = icon:CreateTexture(nil, "BACKGROUND")
	icon.background:SetAllPoints(icon)
	icon.background:SetColorTexture(0, 0, 0, 1)

	icon.texture = icon:CreateTexture(nil, "ARTWORK")
	icon.texture:SetTexCoord(0.08, 0.92, 0.08, 0.92)

	icon.cooldown = CreateFrame("Cooldown", nil, icon, "CooldownFrameTemplate")
	icon.cooldown:SetAllPoints(icon.texture)
	icon.cooldown:SetReverse(true)
	icon.cooldown:SetHideCountdownNumbers(true)

	icon.count = icon:CreateFontString(nil, "OVERLAY", "NumberFontNormal")
	icon.count:SetJustifyH("RIGHT")
	icon.count:SetJustifyV("BOTTOM")

	icon:Hide()
	return icon
end

local function ApplyIconSettings(icon, cachedSettings)
	local iconSize = PP:ToUIScaled(cachedSettings.iconSize)
	local textureInset = PP:ToUIScaled(1)

	icon:SetSize(iconSize, iconSize)
	icon.texture:ClearAllPoints()
	icon.texture:SetPoint("TOPLEFT", icon, "TOPLEFT", textureInset, -textureInset)
	icon.texture:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", -textureInset, textureInset)
	icon.cooldown:ClearAllPoints()
	icon.cooldown:SetAllPoints(icon.texture)
	icon.cooldown:SetHideCountdownNumbers(not cachedSettings.showCooldown)
	if cachedSettings.showCooldown and icon.cooldown.SetCountdownFont then
		local fontSize = PP:ScaleFont(cachedSettings.cooldownFontSize)
		local fontName = "MUF_CooldownFont_" .. tostring(fontSize)
		local cooldownFont = _G[fontName]
		if not cooldownFont then
			cooldownFont = CreateFont(fontName)
		end

		cooldownFont:SetFont("Fonts\\ARIALN.TTF", fontSize, "OUTLINE")
		icon.cooldown:SetCountdownFont(fontName)
	end

	icon.count:SetFont("Fonts\\ARIALN.TTF", PP:ScaleFont(cachedSettings.stacksFontSize), "OUTLINE")
	icon.count:SetTextColor(1, 1, 1, 1)
	icon.count:ClearAllPoints()
	icon.count:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", -textureInset, textureInset)
	icon.count:SetShown(cachedSettings.showStacks)
end

local function UpdateIconLayout(container, cachedSettings)
	local iconSize = PP:ToUIScaled(cachedSettings.iconSize)
	local spacing = PP:ToUIScaled(cachedSettings.spacing)
	local step = iconSize + spacing
	local layout = anchorLayouts[cachedSettings.anchor] or anchorLayouts.TOPRIGHT

	for index = 1, cachedSettings.maxIcons do
		local icon = container.icons[index]
		if not icon then
			icon = CreateIcon(container)
			container.icons[index] = icon
		end

		ApplyIconSettings(icon, cachedSettings)

		local gridIndex = index - 1
		local column = gridIndex % cachedSettings.iconsPerRow
		local row = math.floor(gridIndex / cachedSettings.iconsPerRow)

		icon:ClearAllPoints()
		icon:SetPoint(
			layout.iconPoint,
			container,
			layout.iconPoint,
			column * step * layout.xDirection,
			row * step * layout.yDirection
		)
	end

	for index = cachedSettings.maxIcons + 1, #container.icons do
		container.icons[index]:Hide()
	end
end

local function UpdateContainerLayout(frame, cachedSettings)
	local container = frame.buffs
	local visibleColumns = math.min(cachedSettings.maxIcons, cachedSettings.iconsPerRow)
	local rows = math.max(1, math.ceil(cachedSettings.maxIcons / cachedSettings.iconsPerRow))
	local iconSize = PP:ToUIScaled(cachedSettings.iconSize)
	local spacing = PP:ToUIScaled(cachedSettings.spacing)
	local width = (visibleColumns * iconSize) + ((visibleColumns - 1) * spacing)
	local height = (rows * iconSize) + ((rows - 1) * spacing)
	local layout = anchorLayouts[cachedSettings.anchor] or anchorLayouts.TOPRIGHT

	container:ClearAllPoints()
	container:SetPoint(
		layout.containerPoint,
		frame,
		layout.framePoint,
		PP:ToUIScaled(cachedSettings.position.x),
		PP:ToUIScaled(cachedSettings.position.y)
	)
	container:SetSize(width, height)
end

function Buffs:Ensure(frame)
	if not frame.buffs then
		local container = CreateFrame("Frame", nil, frame)
		container:SetFrameLevel(42)
		container.icons = {}

		frame.buffs = container
	end

	self:UpdateSettings(frame)
end

function Buffs:UpdateSettings(frame)
	UpdateSettingsCache(frame)

	local cachedSettings = settingsCache[frame.settingsUnit]
	if not frame.buffs then
		return
	end

	if not cachedSettings.enabled then
		HideIcons(frame.buffs)
		return
	end

	UpdateContainerLayout(frame, cachedSettings)
	UpdateIconLayout(frame.buffs, cachedSettings)
	self:UpdateState(frame)
end

function Buffs:UpdateState(frame)
	if not settingsCache[frame.settingsUnit] then
		UpdateSettingsCache(frame)
	end

	local cachedSettings = settingsCache[frame.settingsUnit]
	local container = frame.buffs
	if not container then
		return
	end

	if not cachedSettings.enabled or not frame.unit or not UnitExists(frame.unit) then
		HideIcons(container)
		return
	end

	local shown = 0
	local auras = addon.AuraHandler:GetUnitAuras(frame.unit, "helpful")

	for _, aura in ipairs(auras) do
		if shown >= cachedSettings.maxIcons then
			break
		end

		if aura.icon then
			shown = shown + 1
			local icon = container.icons[shown]
			if not icon then
				icon = CreateIcon(container)
				container.icons[shown] = icon
				ApplyIconSettings(icon, cachedSettings)
			end

			ApplyIconState(icon, frame.unit, aura, cachedSettings)
		end
	end

	for index = shown + 1, cachedSettings.maxIcons do
		local icon = container.icons[index]
		if icon then
			icon:Hide()
		end
	end

	container:SetShown(shown > 0)
end
