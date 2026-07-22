local _, addon = ...

addon.Frames = addon.Frames or {}
addon.Frames.Widgets = addon.Frames.Widgets or {}
addon.Frames.Widgets.Indicators = addon.Frames.Widgets.Indicators or {}
addon.Frames.Widgets.Indicators.GroupStatus = addon.Frames.Widgets.Indicators.GroupStatus or {}

local GroupStatus = addon.Frames.Widgets.Indicators.GroupStatus
local PP = addon.PixelPerfect

function GroupStatus:Ensure(frame, settings)
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

	self:UpdateSettings(frame, settings)
end

function GroupStatus:UpdateSettings(frame, settings)
	if frame.unit ~= "player" or not frame.groupStatus then
		return
	end

	local groupStatusSettings = (settings and settings.groupStatus) or {}
	local anchor = groupStatusSettings.anchor or "TOPLEFT"
	local position = groupStatusSettings.position or {}
	local size = PP:ToUIScaled(groupStatusSettings.size or 16)
	frame.groupStatus.enabled = groupStatusSettings.enabled ~= false
	frame.groupStatus.showLeader = groupStatusSettings.showLeader ~= false
	frame.groupStatus.showAssistant = groupStatusSettings.showAssistant ~= false
	frame.groupStatus:SetSize(size, size)
	frame.groupStatus:ClearAllPoints()
	frame.groupStatus:SetPoint(
		anchor,
		frame,
		anchor,
		PP:ToUIScaled(position.x or 0),
		PP:ToUIScaled(position.y or 0)
	)
	self:UpdateState(frame)
end

function GroupStatus:UpdateState(frame)
	if frame.unit ~= "player" or not frame.groupStatus or not frame.groupStatus.enabled then
		if frame.groupStatus then
			frame.groupStatus:Hide()
		end
		return
	end

	local texture
	if UnitIsGroupLeader("player") and frame.groupStatus.showLeader then
		texture = "Interface\\GroupFrame\\UI-Group-LeaderIcon"
	elseif UnitIsGroupAssistant("player") and frame.groupStatus.showAssistant then
		texture = "Interface\\GroupFrame\\UI-Group-AssistantIcon"
	end

	if not texture then
		frame.groupStatus:Hide()
		return
	end

	frame.groupStatus.texture:SetTexture(texture)
	frame.groupStatus:Show()
end
