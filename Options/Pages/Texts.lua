local _, addon = ...

addon.Options = addon.Options or {}
addon.Options.Pages = addon.Options.Pages or {}
addon.Options.Pages.Texts = addon.Options.Pages.Texts or {}

local Texts = addon.Options.Pages.Texts
local PP = addon.PixelPerfect
local page

function Texts:Ensure(parent)
	if page then
		return page
	end

	page = CreateFrame("Frame", nil, parent)
	page.text = page:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	page.text:SetPoint("TOPLEFT", page, "TOPLEFT", 0, 0)
	page.text:SetText("Texts page")

	function page:UpdateLayout()
		self.text:SetFont("Fonts\\ARIALN.TTF", PP:ScaleFont(16), "")
	end

	return page
end
