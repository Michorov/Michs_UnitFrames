local _, addon = ...

addon.Frames = addon.Frames or {}

local Frames = addon.Frames
local PP = addon.PixelPerfect

local dummyLabels = {
	player = "Player",
	target = "Target",
	pet = "Pet",
	targettarget = "Target of Target",
	focus = "Focus",
	focustarget = "Focus Target",
}

local function RoundToNearestInt(value)
	if value >= 0 then
		return math.floor(value + 0.5)
	end

	return math.ceil(value - 0.5)
end

local function EnableDragging(frame)
	frame:SetMovable(true)
	frame:SetClampedToScreen(true)
	frame:EnableMouse(true)
	frame:RegisterForDrag("LeftButton")

	frame:SetScript("OnDragStart", function(self)
		if InCombatLockdown() then
			return
		end

		self:StartMoving()
	end)

	frame:SetScript("OnDragStop", function(self)
		self:StopMovingOrSizing()

		if InCombatLockdown() then
			return
		end

		local centerX, centerY = self:GetCenter()
		local parentCenterX, parentCenterY = UIParent:GetCenter()
		if not centerX or not centerY or not parentCenterX or not parentCenterY then
			return
		end

		local _, physicalHeight = GetPhysicalScreenSize()
		local pixelStep = (768 / physicalHeight) / UIParent:GetEffectiveScale()
		local positionXPx = RoundToNearestInt((centerX - parentCenterX) / pixelStep)
		local positionYPx = RoundToNearestInt((centerY - parentCenterY) / pixelStep)
		positionXPx = RoundToNearestInt(positionXPx / PP.globalScale)
		positionYPx = RoundToNearestInt(positionYPx / PP.globalScale)

		local position = addon.Database:GetProfile().frames[self.settingsUnit].position
		position.x = RoundToNearestInt(positionXPx * pixelStep)
		position.y = RoundToNearestInt(positionYPx * pixelStep)

		addon.UpdateScheduler:Notify("layoutChanged", self.settingsUnit)
		addon.Options:RefreshProfile()
	end)

	frame:SetScript("OnHide", function(self)
		self:StopMovingOrSizing()
	end)
end

function Frames:CreateDummyFrame(unit, frameName, parent)
	local bossIndex = unit:match("^boss(%d+)$")
	local frame = CreateFrame("Frame", frameName, parent or UIParent)
	frame:Hide()
	frame.isDummy = true
	frame.settingsUnit = bossIndex and "boss" or unit
	frame:SetFrameStrata("MEDIUM")
	frame:SetFrameLevel(10)
	frame:SetSize(1, 1)

	frame.background = frame:CreateTexture(nil, "BACKGROUND")
	frame.background:SetAllPoints(frame)
	frame.background:SetColorTexture(0.10, 0.10, 0.10, 1)

	frame.label = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	frame.label:SetAllPoints(frame)
	frame.label:SetJustifyH("CENTER")
	frame.label:SetJustifyV("MIDDLE")
	frame.label:SetWordWrap(false)
	frame.label:SetTextColor(1, 1, 1, 1)
	frame.label:SetText(bossIndex and ("Boss " .. bossIndex) or dummyLabels[unit] or unit)

	addon.Frames.Widgets.Border:Ensure(frame)
	for _, texture in ipairs({ frame.border.top, frame.border.bottom, frame.border.left, frame.border.right }) do
		texture:SetColorTexture(0.00, 0.42, 1.00, 0.85)
	end

	EnableDragging(frame)

	PP:RegisterForUpdate(function()
		addon.Frames.Widgets.Border:UpdateSettings(frame)
		frame.label:SetFont("Fonts\\ARIALN.TTF", PP:ScaleFont(12), "OUTLINE")
	end)

	return frame
end

function Frames:CreateDummyBossGroup(frameName)
	local container = CreateFrame("Frame", frameName, UIParent)
	container:Hide()
	container.isDummy = true
	container.settingsUnit = "boss"
	container.frames = {}
	container:SetFrameStrata("MEDIUM")
	container:SetFrameLevel(9)
	container:SetSize(1, 1)
	EnableDragging(container)

	for bossIndex = 1, 5 do
		local childName = frameName and (frameName .. "_Boss" .. bossIndex) or nil
		local frame = self:CreateDummyFrame("boss" .. bossIndex, childName, container)
		frame:SetMovable(false)
		frame:EnableMouse(false)
		frame:Show()
		container.frames[bossIndex] = frame
	end

	return container
end
