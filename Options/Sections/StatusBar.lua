local addonName, addon = ...

addon.Options = addon.Options or {}
addon.Options.Sections = addon.Options.Sections or {}
addon.Options.Sections.StatusBar = addon.Options.Sections.StatusBar or {}

local StatusBar = addon.Options.Sections.StatusBar
local PP = addon.PixelPerfect
local statusBar
local addonVersion = C_AddOns.GetAddOnMetadata(addonName, "Version") or ""

function StatusBar:Ensure(parent)
	if statusBar then
		return statusBar
	end

	statusBar = CreateFrame("Frame", nil, parent)

	statusBar.text = statusBar:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	statusBar.text:SetJustifyH("LEFT")
	statusBar.text:SetTextColor(0.65, 0.65, 0.68, 1)
	statusBar.text:SetText(("Version %s | Active Profile: |cff00ff00%s|r"):format(addonVersion, "Default"))

	statusBar.topBorder = statusBar:CreateTexture(nil, "OVERLAY")
	statusBar.topBorder:SetColorTexture(0.15, 0.17, 0.20, 1)

	return statusBar
end

function StatusBar:UpdateLayout()
	statusBar.text:ClearAllPoints()
	statusBar.text:SetPoint("LEFT", statusBar, "LEFT", PP:ToUIScaled(10), 0)
	statusBar.text:SetPoint("RIGHT", statusBar, "RIGHT", PP:ToUIScaled(-8), 0)
	statusBar.text:SetFont("Fonts\\ARIALN.TTF", PP:ScaleFont(12), "")

	statusBar.topBorder:ClearAllPoints()
	statusBar.topBorder:SetPoint("TOPLEFT", statusBar, "TOPLEFT", PP:ToUIScaled(8), 0)
	statusBar.topBorder:SetPoint("TOPRIGHT", statusBar, "TOPRIGHT", PP:ToUIScaled(-8), 0)
	statusBar.topBorder:SetHeight(PP:ToUIScaled(1))
end
