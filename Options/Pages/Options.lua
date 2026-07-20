local _, addon = ...

addon.Options = addon.Options or {}
addon.Options.Pages = addon.Options.Pages or {}
addon.Options.Pages.Options = addon.Options.Pages.Options or {}

local OptionsPage = addon.Options.Pages.Options
local PP = addon.PixelPerfect
local page

function OptionsPage:Ensure(parent)
	if page then
		return page
	end

	page = CreateFrame("Frame", nil, parent)
	page.header = CreateFrame("Frame", nil, page)
	page.header:SetPoint("TOPLEFT", page, "TOPLEFT", 0, 0)
	page.header:SetPoint("TOPRIGHT", page, "TOPRIGHT", 0, 0)

	page.body = CreateFrame("Frame", nil, page)
	page.body:SetPoint("BOTTOMLEFT", page, "BOTTOMLEFT", 0, 0)
	page.body:SetPoint("BOTTOMRIGHT", page, "BOTTOMRIGHT", 0, 0)

	page.header.title = page.header:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	page.header.title:SetPoint("LEFT", page.header, "LEFT", 0, 0)
	page.header.title:SetJustifyH("LEFT")
	page.header.title:SetTextColor(0.88, 0.89, 0.92, 1)
	page.header.title:SetText("Options")

	function page:UpdateLayout()
		self.header:SetHeight(PP:ToUIScaled(32))
		self.header.title:SetFont("Fonts\\ARIALN.TTF", PP:ScaleFont(20), "")
		self.body:SetPoint("TOPLEFT", self.header, "BOTTOMLEFT", 0, PP:ToUIScaled(-16))
		self.body:SetPoint("TOPRIGHT", self.header, "BOTTOMRIGHT", 0, PP:ToUIScaled(-16))
	end

	return page
end
