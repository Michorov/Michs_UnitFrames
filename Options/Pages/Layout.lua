local _, addon = ...

addon.Options = addon.Options or {}
addon.Options.Pages = addon.Options.Pages or {}
addon.Options.Pages.Layout = addon.Options.Pages.Layout or {}

local Layout = addon.Options.Pages.Layout
local PP = addon.PixelPerfect
local page

function Layout:Ensure(parent)
	if page then
		return page
	end

	page = CreateFrame("Frame", nil, parent)
	page.text = page:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	page.text:SetPoint("TOPLEFT", page, "TOPLEFT", 0, 0)
	page.text:SetText("Layout page")

	function page:UpdateLayout()
		self.text:SetFont("Fonts\\ARIALN.TTF", PP:ScaleFont(16), "")
	end

	return page
end
