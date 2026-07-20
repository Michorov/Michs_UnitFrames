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
	page.text = page:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	page.text:SetPoint("TOPLEFT", page, "TOPLEFT", 0, 0)
	page.text:SetText("Options page")

	function page:UpdateLayout()
		self.text:SetFont("Fonts\\ARIALN.TTF", PP:ScaleFont(16), "")
	end

	return page
end
