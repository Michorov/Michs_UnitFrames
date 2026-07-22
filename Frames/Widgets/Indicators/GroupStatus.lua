local _, addon = ...

addon.Frames = addon.Frames or {}
addon.Frames.Widgets = addon.Frames.Widgets or {}
addon.Frames.Widgets.Indicators = addon.Frames.Widgets.Indicators or {}
addon.Frames.Widgets.Indicators.GroupStatus = addon.Frames.Widgets.Indicators.GroupStatus or {}

local GroupStatus = addon.Frames.Widgets.Indicators.GroupStatus
local PP = addon.PixelPerfect
local settingsCache = {}

local function UpdateSettingsCache(frame)
	local settings = addon.Database:GetProfile().frames[frame.settingsUnit]
	settingsCache[frame.settingsUnit] = settings.groupStatus or {}
end

function GroupStatus:Ensure(frame)
	if frame.unit ~= "player" then
		return
	end

	if not frame.groupStatus then
		local indicator = CreateFrame("Frame", nil, frame)
		indicator:SetFrameLevel(33)
		indicator:Hide()

		indicator.texture = indicator:CreateTexture(nil, "OVERLAY")
		indicator.texture:SetAllPoints(indicator)

		frame.groupStatus = indicator
	end

	self:UpdateSettings(frame)
end

function GroupStatus:UpdateSettings(frame)
	if frame.unit ~= "player" or not frame.groupStatus then
		return
	end

	UpdateSettingsCache(frame)
	local cachedSettings = settingsCache[frame.settingsUnit]

	if cachedSettings.enabled == false then
		frame.groupStatus:Hide()
		return
	end

	local anchor = cachedSettings.anchor or "TOPLEFT"
	local position = cachedSettings.position or {}
	local size = PP:ToUIScaled(cachedSettings.size or 16)
	frame.groupStatus:SetSize(size, size)
	frame.groupStatus:ClearAllPoints()
	frame.groupStatus:SetPoint(anchor, frame, anchor, PP:ToUIScaled(position.x or 0), PP:ToUIScaled(position.y or 0))
	self:UpdateState(frame)
end

function GroupStatus:UpdateState(frame)
	if frame.unit ~= "player" or not frame.groupStatus then
		if frame.groupStatus then
			frame.groupStatus:Hide()
		end
		return
	end

	local cachedSettings = settingsCache[frame.settingsUnit]

	if cachedSettings.enabled == false then
		frame.groupStatus:Hide()
		return
	end

	local texture
	if UnitIsGroupLeader("player") and cachedSettings.showLeader ~= false then
		texture = "Interface\\GroupFrame\\UI-Group-LeaderIcon"
	elseif UnitIsGroupAssistant("player") and cachedSettings.showAssistant ~= false then
		texture = "Interface\\GroupFrame\\UI-Group-AssistantIcon"
	end

	if not texture then
		frame.groupStatus:Hide()
		return
	end

	frame.groupStatus.texture:SetTexture(texture)
	frame.groupStatus:Show()
end
