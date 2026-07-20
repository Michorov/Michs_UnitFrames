local _, addon = ...

addon.Options = addon.Options or {}
addon.Options.Sections = addon.Options.Sections or {}
addon.Options.Sections.Header = addon.Options.Sections.Header or {}

local Header = addon.Options.Sections.Header
local PP = addon.PixelPerfect
local header

function Header:Ensure(parent)
	if header then
		return header
	end

	header = CreateFrame("Frame", nil, parent)

	header.title = header:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	header.title:SetJustifyH("LEFT")
	header.title:SetText("Mich's UnitFrames")
	header.title:SetTextColor(0.96, 0.66, 0.31, 1)

	header.closeButton = addon.Options.Controls.Button:Create(header, "X")
	header.closeButton:SetLayoutSize(24, 24)
	header.closeButton:SetBorderSize(0)
	header.closeButton:SetFontSize(16)
	header.closeButton:SetLayoutPoint("TOPRIGHT", header, "TOPRIGHT", -8, -8)
	header.closeButton:SetBackdropColor(0, 0, 0, 0)
	header.closeButton.text:SetTextColor(0.65, 0.65, 0.68, 1)

	header.closeButton:SetOnClick(function()
		addon.Options:Close()
	end)

	header.closeButton:SetScript("OnEnter", function(self)
		self.text:SetTextColor(0.96, 0.66, 0.31, 1)
	end)

	header.closeButton:SetScript("OnLeave", function(self)
		self.text:SetTextColor(0.65, 0.65, 0.68, 1)
	end)

	return header
end

function Header:UpdateLayout()
	header.title:ClearAllPoints()
	header.title:SetPoint("TOPLEFT", header, "TOPLEFT", PP:ToUIScaled(8), PP:ToUIScaled(-8))
	header.title:SetFont(
		"Interface\\AddOns\\Michs_UnitFrames\\Media\\Fonts\\Philosopher-Bold.ttf",
		PP:ScaleFont(22),
		""
	)
end
