local _, addon = ...

addon.Style = addon.Style or {}
addon.Style.Fonts = addon.Style.Fonts or {}

local Fonts = addon.Style.Fonts
local LSM = LibStub("LibSharedMedia-3.0")
local fontTable = LSM:HashTable("font")

LSM:Register(
	"font",
	"Philosopher Bold",
	"Interface\\AddOns\\Michs_UnitFrames\\Media\\Fonts\\Philosopher-Bold.ttf"
)

function Fonts:GetOptions(selectedFontName)
	local options = {}
	local selectedFontListed = false

	for _, fontName in ipairs(LSM:List("font")) do
		options[#options + 1] = {
			value = fontName,
			text = fontName,
			font = fontTable[fontName],
		}

		if fontName == selectedFontName then
			selectedFontListed = true
		end
	end

	if selectedFontName and not selectedFontListed then
		options[#options + 1] = {
			value = selectedFontName,
			text = selectedFontName .. " (Unavailable)",
		}
	end

	return options
end
