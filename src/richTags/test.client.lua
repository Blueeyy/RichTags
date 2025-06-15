local Players = game:GetService("Players")
local richTags = require(script.Parent)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local testScreenGui = Instance.new("ScreenGui")
testScreenGui.Name = "test"
testScreenGui.Parent = playerGui

local textLabel = Instance.new("TextLabel")
textLabel.Size = UDim2.fromScale(1, 1)
textLabel.Position = UDim2.fromScale(0.5, 0.5)
textLabel.AnchorPoint = Vector2.new(0.5, 0.5)
textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
textLabel.BackgroundTransparency = 1
textLabel.Text = "Starting text formatting test..."
textLabel.Parent = testScreenGui

local stroke = Instance.new("UIStroke")
stroke.Thickness = 2
stroke.Parent = textLabel

local testStrings = {
	-- Basic single tags
	"<rare>Basic rare text</rare>",
	"<epic>Epic purple text</epic>",
	"<legendary>Golden legendary text</legendary>",
	"<mythic>White mythic text</mythic>",
	"<secret>Red secret text</secret>",
	"<damage>Red damage text</damage>",
	"<critChance>Orange crit chance</critChance>",

	-- Standard RichText tags
	"<b>Bold text</b>",
	"<i>Italic text</i>",
	"<u>Underlined text</u>",
	"<s>Strikethrough text</s>",
	"<sub>Subscript text</sub>",
	"<sup>Superscript text</sup>",
	"<small>Small text</small>",
	"<uppercase>Uppercase text</uppercase>",
	"<uc>Short uppercase</uc>",
	"<smallcaps>Small caps text</smallcaps>",
	"<sc>Short small caps</sc>",

	-- Simple nested tags
	"<rare><b>Bold rare text</b></rare>",
	"<epic><i>Italic epic text</i></epic>",
	"<legendary><damage>Legendary damage</damage></legendary>",
	"<secret><critChance>Secret crit chance</critChance></secret>",
	"<damage><b>Bold damage</b></damage>",

	-- Complex nested combinations
	"<rare>Found <legendary>Golden Sword</legendary> with <damage>150 damage</damage>!</rare>",
	"<epic>Epic <b>Boss</b> drops <mythic>Mythic <i>Artifact</i></mythic>!</epic>",
	"<legendary>Legendary <damage>Fire Spell</damage> deals <critChance>25% crit</critChance></legendary>",
	"<secret>Secret <rare>Rare <epic>Epic Item</epic></rare> discovered!</secret>",

	-- Multiple tags in sequence
	"<rare>Rare</rare> <epic>Epic</epic> <legendary>Legendary</legendary> <mythic>Mythic</mythic> <secret>Secret</secret>",
	"<damage>100</damage> <critChance>25%</critChance> <b>Bold</b> <i>Italic</i> <u>Underlined</u>",
	"<rare>Blue</rare> + <epic>Purple</epic> = <legendary>Gold</legendary>",

	-- Deep nesting
	"<rare><epic><legendary><mythic>Deep nesting test</mythic></legendary></epic></rare>",
	"<damage><b><i><u>Triple nested formatting</u></i></b></damage>",
	"<secret><legendary><damage><critChance>Four levels deep</critChance></damage></legendary></secret>",

	-- Mixed content
	"Normal text <rare>rare text</rare> more normal text",
	"Start <epic>epic <b>bold</b> text</epic> middle <damage>damage</damage> end",
	"<rare>Rare</rare> normal <epic>epic</epic> normal <legendary>legendary</legendary>",

	-- Game-like examples
	"You found a <rare>Rare Sword</rare>! It deals <damage>85 damage</damage>.",
	"<legendary>Legendary Boss</legendary> defeated! Gained <critChance>+5% crit chance</critChance>.",
	"<epic>Epic Loot Drop:</epic> <mythic>Mythic Shield</mythic> with <damage>200 defense</damage>!",
	"<secret>SECRET AREA UNLOCKED!</secret> Contains <legendary>legendary treasures</legendary>!",

	-- Formatting combinations
	"<rare><b>Bold rare</b></rare> and <epic><i>italic epic</i></epic>",
	"<damage><u>Underlined damage</u></damage> with <critChance><s>strikethrough crit</s></critChance>",
	"<legendary><small>Small legendary</small></legendary> and <mythic><sup>Super mythic</sup></mythic>",

	-- Long text with multiple elements
	"Welcome to the <epic>Epic Dungeon</epic>! Here you'll find <rare>rare monsters</rare>, <legendary>legendary loot</legendary>, and <secret>secret passages</secret>. Watch out for <damage>high damage</damage> attacks with <critChance>critical hits</critChance>!",

	-- Edge cases
	"<rare></rare>", -- Empty tag
	"<rare>Single word</rare>",
	"<rare>   Spaces   </rare>",
	"<rare>Multiple<br/>Lines</rare>",

	-- Repeated tags
	"<rare>First rare</rare> and <rare>second rare</rare> and <rare>third rare</rare>",
	"<damage>10</damage> + <damage>20</damage> + <damage>30</damage> = <damage>60 total</damage>",

	-- Case sensitivity test
	"<RARE>Should not work</RARE> <rare>Should work</rare>",

	-- Special characters
	"<rare>Symbols: !@#$%^&*()</rare>",
	"<epic>Numbers: 123456789</epic>",
	"<legendary>Punctuation: .,;:!?</legendary>",

	-- Performance test
	"<rare><epic><legendary><mythic><secret><damage><critChance><b><i><u><s><sub><sup><small><uppercase>Deeply nested performance test</uppercase></small></sup></sub></s></u></i></b></critChance></damage></secret></mythic></legendary></epic></rare>",
}

local currentTestIndex = 1

local function runNextTest()
	local testString = testStrings[currentTestIndex]
	print(`Running test {currentTestIndex}/{#testStrings}: {testString}`)

	textLabel.Text = richTags.format(testString)
	textLabel.RichText = true

	currentTestIndex = currentTestIndex + 1
	if currentTestIndex > #testStrings then
		currentTestIndex = 1 -- Loop back to start
		print("All tests completed! Looping back to start...")
	end
end

task.wait(2)
print("Starting TextFormatter test")
print(`Total tests: {#testStrings}`)

runNextTest()

while true do
	task.wait(1)
	runNextTest()
end
