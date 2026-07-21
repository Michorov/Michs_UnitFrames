local _, addon = ...

addon.Frames = addon.Frames or {}
addon.Frames.Widgets = addon.Frames.Widgets or {}
addon.Frames.Widgets.MouseoverHighlight = addon.Frames.Widgets.MouseoverHighlight or {}

local MouseoverHighlight = addon.Frames.Widgets.MouseoverHighlight

function MouseoverHighlight:Ensure(frame, settings)
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

	self:UpdateSettings(frame, settings)
end

function MouseoverHighlight:UpdateSettings(frame, settings)
	frame.mouseoverHighlight.enabled = settings and settings.mouseoverHighlight ~= false
	self:UpdateState(frame)
end

function MouseoverHighlight:UpdateState(frame)
	if frame.mouseoverHighlight.enabled and frame:IsMouseOver() then
		frame.mouseoverHighlight:Show()
	else
		frame.mouseoverHighlight:Hide()
	end
end
