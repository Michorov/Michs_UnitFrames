local _, addon = ...

addon.Style = addon.Style or {}
addon.Style.Fonts = addon.Style.Fonts or {}

local Fonts = addon.Style.Fonts
local LSM = LibStub("LibSharedMedia-3.0")
local fontTable = LSM:HashTable("font")
local defaultFont = LSM:GetDefault("font")
local fontTester = UIParent:CreateFontString(nil, "OVERLAY")
local usableFonts = {}

LSM:Register(
	"font",
	"Philosopher Bold",
	"Interface\\AddOns\\Michs_UnitFrames\\Media\\Fonts\\Philosopher-Bold.ttf"
)

function Fonts:IsUsable(fontName)
	if usableFonts[fontName] ~= nil then
		return usableFonts[fontName]
	end

	local fontPath = fontTable[fontName]
	local isUsable = fontPath and fontTester:SetFont(fontPath, 12, "") or false
	usableFonts[fontName] = isUsable
	return isUsable
end

function Fonts:GetOptions()
	local options = {}

	for _, fontName in ipairs(LSM:List("font")) do
		if self:IsUsable(fontName) then
			options[#options + 1] = {
				value = fontName,
				text = fontName,
			}
		end
	end

	return options
end

function Fonts:GetName(fontName)
	return self:IsUsable(fontName) and fontName or defaultFont
end

function Fonts:GetPath(fontName)
	return fontTable[self:GetName(fontName)] or fontTable[defaultFont]
end

function Fonts:SetFont(fontString, fontName, fontSize, flags)
	if fontString:SetFont(self:GetPath(fontName), fontSize, flags or "") then
		return
	end

	fontString:SetFont(fontTable[defaultFont], fontSize, flags or "")
end
