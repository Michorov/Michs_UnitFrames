local _, addon = ...

addon.Frames = addon.Frames or {}
addon.Frames.Widgets = addon.Frames.Widgets or {}
addon.Frames.Widgets.MouseoverHighlight = addon.Frames.Widgets.MouseoverHighlight or {}

local MouseoverHighlight = addon.Frames.Widgets.MouseoverHighlight
local settingsCache

local function UpdateSettingsCache()
	settingsCache = addon.Database:GetProfile().general
end

function MouseoverHighlight:Ensure(frame)
	if not frame.mouseoverHighlight then
		local highlight = CreateFrame("Frame", nil, frame)
		highlight:SetAllPoints(frame)
		highlight:SetFrameLevel(20)
		highlight:Hide()

		highlight.texture = highlight:CreateTexture(nil, "ARTWORK")
		highlight.texture:SetAllPoints(highlight)
		highlight.texture:SetTexture("Interface\\Buttons\\WHITE8x8")
		highlight.texture:SetVertexColor(1, 1, 1, 0.08)

		frame.mouseoverHighlight = highlight

		frame:HookScript("OnEnter", function()
			MouseoverHighlight:UpdateState(frame)
		end)

		frame:HookScript("OnLeave", function()
			highlight:Hide()
		end)
	end

	self:UpdateSettings(frame)
end

function MouseoverHighlight:UpdateSettings(frame)
	UpdateSettingsCache()
	local cachedSettings = settingsCache

	if cachedSettings.mouseoverHighlight == false then
		frame.mouseoverHighlight:Hide()
		return
	end

	self:UpdateState(frame)
end

function MouseoverHighlight:UpdateState(frame)
	local cachedSettings = settingsCache

	if cachedSettings.mouseoverHighlight == false then
		frame.mouseoverHighlight:Hide()
		return
	end

	if frame:IsMouseOver() then
		frame.mouseoverHighlight:Show()
	else
		frame.mouseoverHighlight:Hide()
	end
end
