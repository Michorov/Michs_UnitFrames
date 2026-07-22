local _, addon = ...

addon.Frames = addon.Frames or {}
addon.Frames.Widgets = addon.Frames.Widgets or {}
addon.Frames.Widgets.Bars = addon.Frames.Widgets.Bars or {}
addon.Frames.Widgets.Bars.Cast = addon.Frames.Widgets.Bars.Cast or {}

local Cast = addon.Frames.Widgets.Bars.Cast
local PP = addon.PixelPerfect
local LSM = LibStub("LibSharedMedia-3.0")
local settingsCache = {}
local colorCache = {}
local generalSettings

local supportedUnits = {
	player = true,
	pet = true,
	target = true,
	focus = true,
}

local function IsSupportedUnit(unit)
	return unit and (supportedUnits[unit] or unit:match("^boss%d+$") ~= nil)
end

local function UpdateSettingsCache(frame)
	local profile = addon.Database:GetProfile()
	local settings = profile.frames[frame.settingsUnit].cast

	settingsCache[frame.settingsUnit] = {
		enabled = settings.enabled,
		texture = settings.texture,
		font = settings.font,
		fontSize = settings.fontSize,
		position = settings.position,
		height = settings.height,
		icon = {
			position = settings.icon.position,
		},
		spellName = {
			position = settings.spellName.position,
		},
		castTime = {
			position = settings.castTime.position,
		},
	}
	generalSettings = {
		font = profile.general.font,
		texture = profile.general.texture,
	}

	local colors = settings.colors
	colorCache[frame.settingsUnit] = {
		cast = CreateColor(colors.cast.r, colors.cast.g, colors.cast.b, colors.cast.a),
		channel = CreateColor(colors.channel.r, colors.channel.g, colors.channel.b, colors.channel.a),
		nonInterruptible = CreateColor(
			colors.nonInterruptible.r,
			colors.nonInterruptible.g,
			colors.nonInterruptible.b,
			colors.nonInterruptible.a
		),
	}
end

local function HideCastBar(castBar)
	castBar.duration = nil
	castBar.castTimeElapsed = 0
	castBar.spellName:ClearText()
	castBar.castTime:ClearText()
	castBar:Hide()
	castBar.icon:Hide()
end

function Cast:Ensure(frame)
	if not IsSupportedUnit(frame.unit) then
		return
	end

	if not frame.castBar then
		local castBar = CreateFrame("StatusBar", nil, frame)
		castBar:SetFrameLevel(20)
		castBar:SetStatusBarTexture("Interface\\Buttons\\WHITE8x8")
		castBar:SetStatusBarColor(1, 0.7, 0, 1)
		castBar:SetMinMaxValues(0, 1)
		castBar:SetValue(1)
		castBar:SetScript("OnUpdate", function(self, elapsed)
			if self.duration and self.castTime:IsShown() then
				self.castTimeElapsed = (self.castTimeElapsed or 0) + elapsed
				if self.castTimeElapsed >= 0.1 then
					self.castTimeElapsed = self.castTimeElapsed - 0.1
					self.castTime:SetFormattedText("%.1f", self.duration:GetRemainingDuration())
				end
			end
		end)

		castBar.background = castBar:CreateTexture(nil, "BACKGROUND")
		castBar.background:SetAllPoints(castBar)
		castBar.background:SetColorTexture(0.08, 0.08, 0.08, 0.8)

		castBar.spellName = castBar:CreateFontString(nil, "OVERLAY")
		castBar.spellName:SetJustifyH("LEFT")
		castBar.spellName:SetMaxLines(1)
		castBar.spellName:SetWordWrap(false)

		castBar.castTime = castBar:CreateFontString(nil, "OVERLAY")
		castBar.castTime:SetJustifyH("RIGHT")
		castBar.castTime:SetMaxLines(1)

		local border = CreateFrame("Frame", nil, castBar)
		border:SetAllPoints(castBar)
		border:SetFrameLevel(castBar:GetFrameLevel() + 1)

		border.top = border:CreateTexture(nil, "OVERLAY")
		border.bottom = border:CreateTexture(nil, "OVERLAY")
		border.left = border:CreateTexture(nil, "OVERLAY")
		border.right = border:CreateTexture(nil, "OVERLAY")

		border.left:SetPoint("TOPLEFT", border, "TOPLEFT", 0, 0)
		border.left:SetPoint("BOTTOMLEFT", border, "BOTTOMLEFT", 0, 0)
		border.right:SetPoint("TOPRIGHT", border, "TOPRIGHT", 0, 0)
		border.right:SetPoint("BOTTOMRIGHT", border, "BOTTOMRIGHT", 0, 0)
		border.top:SetPoint("TOPLEFT", border.left, "TOPRIGHT", 0, 0)
		border.top:SetPoint("TOPRIGHT", border.right, "TOPLEFT", 0, 0)
		border.bottom:SetPoint("BOTTOMLEFT", border.left, "BOTTOMRIGHT", 0, 0)
		border.bottom:SetPoint("BOTTOMRIGHT", border.right, "BOTTOMLEFT", 0, 0)

		border.top:SetColorTexture(0, 0, 0, 1)
		border.bottom:SetColorTexture(0, 0, 0, 1)
		border.left:SetColorTexture(0, 0, 0, 1)
		border.right:SetColorTexture(0, 0, 0, 1)

		local icon = CreateFrame("Frame", nil, frame)
		icon:SetFrameLevel(castBar:GetFrameLevel())
		icon.texture = icon:CreateTexture(nil, "ARTWORK")
		icon.texture:SetAllPoints(icon)
		icon.texture:SetTexCoord(0.10, 0.90, 0.10, 0.90)

		local iconBorder = CreateFrame("Frame", nil, icon)
		iconBorder:SetAllPoints(icon)
		iconBorder:SetFrameLevel(icon:GetFrameLevel() + 1)
		iconBorder.top = iconBorder:CreateTexture(nil, "OVERLAY")
		iconBorder.bottom = iconBorder:CreateTexture(nil, "OVERLAY")
		iconBorder.left = iconBorder:CreateTexture(nil, "OVERLAY")
		iconBorder.right = iconBorder:CreateTexture(nil, "OVERLAY")

		iconBorder.left:SetPoint("TOPLEFT", iconBorder, "TOPLEFT", 0, 0)
		iconBorder.left:SetPoint("BOTTOMLEFT", iconBorder, "BOTTOMLEFT", 0, 0)
		iconBorder.right:SetPoint("TOPRIGHT", iconBorder, "TOPRIGHT", 0, 0)
		iconBorder.right:SetPoint("BOTTOMRIGHT", iconBorder, "BOTTOMRIGHT", 0, 0)
		iconBorder.top:SetPoint("TOPLEFT", iconBorder.left, "TOPRIGHT", 0, 0)
		iconBorder.top:SetPoint("TOPRIGHT", iconBorder.right, "TOPLEFT", 0, 0)
		iconBorder.bottom:SetPoint("BOTTOMLEFT", iconBorder.left, "BOTTOMRIGHT", 0, 0)
		iconBorder.bottom:SetPoint("BOTTOMRIGHT", iconBorder.right, "BOTTOMLEFT", 0, 0)

		iconBorder.top:SetColorTexture(0, 0, 0, 1)
		iconBorder.bottom:SetColorTexture(0, 0, 0, 1)
		iconBorder.left:SetColorTexture(0, 0, 0, 1)
		iconBorder.right:SetColorTexture(0, 0, 0, 1)

		icon.border = iconBorder
		icon:Hide()

		castBar.border = border
		castBar.icon = icon
		frame.castBar = castBar
	end

	self:UpdateSettings(frame)
end

function Cast:UpdateSettings(frame)
	if not IsSupportedUnit(frame.unit) or not frame.castBar then
		return
	end

	UpdateSettingsCache(frame)
	local cachedSettings = settingsCache[frame.settingsUnit]

	if cachedSettings.enabled == false then
		HideCastBar(frame.castBar)
		return
	end

	local texture = cachedSettings.texture
	if texture == -1 then
		texture = generalSettings.texture
	end

	if not LSM:IsValid("statusbar", texture) then
		texture = "Solid"
	end

	frame.castBar:SetStatusBarTexture(LSM:Fetch("statusbar", texture))
	self:UpdateLayout(frame)
	self:UpdateState(frame)
end

function Cast:UpdateLayout(frame)
	local castBar = frame.castBar
	if not castBar then
		return
	end

	local cachedSettings = settingsCache[frame.settingsUnit]
	if cachedSettings.enabled == false then
		return
	end

	local iconPosition = cachedSettings.icon.position
	local spellNamePosition = cachedSettings.spellName.position
	local castTimePosition = cachedSettings.castTime.position
	local showIcon = iconPosition ~= "HIDE"
	iconPosition = iconPosition == "RIGHT" and "RIGHT" or "LEFT"
	spellNamePosition = spellNamePosition == "RIGHT" and "RIGHT" or "LEFT"
	castTimePosition = castTimePosition == "LEFT" and "LEFT" or "RIGHT"

	local font = cachedSettings.font
	if font == -1 then
		font = generalSettings.font
	end

	local fontSize = cachedSettings.fontSize
	local position = cachedSettings.position
	local height = PP:ToUIScaled(cachedSettings.height)
	local borderThickness = PP:ToUIScaled(1)
	local point = position == "TOP" and "BOTTOM" or "TOP"
	local yOffset = PP:ToUIScaled(position == "TOP" and 1 or -1)
	local leftPoint = point .. "LEFT"
	local rightPoint = point .. "RIGHT"
	local relativeLeftPoint = position .. "LEFT"
	local relativeRightPoint = position .. "RIGHT"

	castBar:ClearAllPoints()
	castBar:SetHeight(height)
	castBar.border.left:SetWidth(borderThickness)
	castBar.border.right:SetWidth(borderThickness)
	castBar.border.top:SetHeight(borderThickness)
	castBar.border.bottom:SetHeight(borderThickness)

	castBar.icon:ClearAllPoints()
	castBar.icon:SetSize(height, height)
	castBar.icon.border.left:SetWidth(borderThickness)
	castBar.icon.border.right:SetWidth(borderThickness)
	castBar.icon.border.top:SetHeight(borderThickness)
	castBar.icon.border.bottom:SetHeight(borderThickness)

	castBar.spellName:ClearAllPoints()
	castBar.spellName:SetPoint(
		spellNamePosition,
		castBar,
		spellNamePosition,
		spellNamePosition == "LEFT" and PP:ToUIScaled(2) or PP:ToUIScaled(-2),
		0
	)
	castBar.spellName:SetJustifyH(spellNamePosition)
	castBar.spellName:SetFont(LSM:Fetch("font", font), PP:ScaleFont(fontSize), "OUTLINE")
	castBar.spellName:SetShadowColor(0, 0, 0, 0.9)
	castBar.spellName:SetShadowOffset(1, -1)

	castBar.castTime:ClearAllPoints()
	castBar.castTime:SetPoint(
		castTimePosition,
		castBar,
		castTimePosition,
		castTimePosition == "LEFT" and PP:ToUIScaled(2) or PP:ToUIScaled(-2),
		0
	)
	castBar.castTime:SetJustifyH(castTimePosition)
	castBar.castTime:SetFont(LSM:Fetch("font", font), PP:ScaleFont(fontSize), "OUTLINE")
	castBar.castTime:SetShadowColor(0, 0, 0, 0.9)
	castBar.castTime:SetShadowOffset(1, -1)

	if
		cachedSettings.spellName.position ~= "HIDE"
		and cachedSettings.castTime.position ~= "HIDE"
		and spellNamePosition == castTimePosition
	then
		castBar.spellName:ClearAllPoints()
		if spellNamePosition == "LEFT" then
			castBar.spellName:SetPoint("LEFT", castBar.castTime, "RIGHT", PP:ToUIScaled(4), 0)
			castBar.spellName:SetPoint("RIGHT", castBar, "RIGHT", PP:ToUIScaled(-2), 0)
		else
			castBar.spellName:SetPoint("LEFT", castBar, "LEFT", PP:ToUIScaled(2), 0)
			castBar.spellName:SetPoint("RIGHT", castBar.castTime, "LEFT", PP:ToUIScaled(-4), 0)
		end
	elseif spellNamePosition ~= castTimePosition then
		if spellNamePosition == "LEFT" then
			castBar.spellName:SetPoint("RIGHT", castBar.castTime, "LEFT", PP:ToUIScaled(-4), 0)
		else
			castBar.spellName:SetPoint("LEFT", castBar.castTime, "RIGHT", PP:ToUIScaled(4), 0)
		end
	end

	if not showIcon then
		castBar:SetPoint(leftPoint, frame, relativeLeftPoint, 0, yOffset)
		castBar:SetPoint(rightPoint, frame, relativeRightPoint, 0, yOffset)
	elseif iconPosition == "RIGHT" then
		castBar.icon:SetPoint(rightPoint, frame, relativeRightPoint, 0, yOffset)
		castBar:SetPoint(leftPoint, frame, relativeLeftPoint, 0, yOffset)
		castBar:SetPoint(rightPoint, castBar.icon, leftPoint, borderThickness, 0)
	else
		castBar.icon:SetPoint(leftPoint, frame, relativeLeftPoint, 0, yOffset)
		castBar:SetPoint(leftPoint, castBar.icon, rightPoint, -borderThickness, 0)
		castBar:SetPoint(rightPoint, frame, relativeRightPoint, 0, yOffset)
	end

	castBar.icon:SetShown(castBar:IsShown() and showIcon)
end

function Cast:UpdateState(frame)
	if not IsSupportedUnit(frame.unit) then
		return
	end

	local castBar = frame.castBar
	if not castBar then
		return
	end

	local cachedSettings = settingsCache[frame.settingsUnit]

	if cachedSettings.enabled == false or not frame.unit or not UnitExists(frame.unit) then
		HideCastBar(castBar)
		return
	end

	local direction = Enum.StatusBarTimerDirection.ElapsedTime
	local name, _, iconTexture, _, _, _, _, notInterruptible = UnitCastingInfo(frame.unit)
	local duration
	local isChannel

	if name then
		duration = UnitCastingDuration(frame.unit)
	else
		local isEmpowered
		name, _, iconTexture, _, _, _, notInterruptible, _, isEmpowered = UnitChannelInfo(frame.unit)
		isChannel = true

		if isEmpowered then
			duration = UnitEmpoweredChannelDuration(frame.unit)
		else
			duration = UnitChannelDuration(frame.unit)
			direction = Enum.StatusBarTimerDirection.RemainingTime
		end
	end

	if not name or not duration then
		HideCastBar(castBar)
		return
	end

	local colors = colorCache[frame.settingsUnit]
	local color = isChannel and colors.channel or colors.cast
	castBar:SetStatusBarColor(
		C_CurveUtil.EvaluateColorFromBoolean(
			notInterruptible,
			colors.nonInterruptible,
			color
		):GetRGBA()
	)

	local spellNameEnabled = cachedSettings.spellName.position ~= "HIDE"
	local castTimeEnabled = cachedSettings.castTime.position ~= "HIDE"

	castBar:SetTimerDuration(duration, Enum.StatusBarInterpolation.Immediate, direction)
	castBar.duration = duration
	castBar.castTimeElapsed = 0
	if spellNameEnabled then
		castBar.spellName:SetText(name)
	else
		castBar.spellName:ClearText()
	end
	if castTimeEnabled then
		castBar.castTime:SetFormattedText("%.1f", duration:GetRemainingDuration())
	else
		castBar.castTime:ClearText()
	end
	castBar.icon.texture:SetTexture(iconTexture or 136243)
	castBar:Show()
	castBar.icon:SetShown(cachedSettings.icon.position ~= "HIDE")
	castBar.spellName:SetShown(spellNameEnabled)
	castBar.castTime:SetShown(castTimeEnabled)
end
