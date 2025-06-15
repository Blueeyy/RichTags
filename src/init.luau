--[[
    ┌─────────────────────────────────────────────────────────────────────────────┐
    │                                    API                                      │
    └─────────────────────────────────────────────────────────────────────────────┘
    
    ━━━ 1. richTags.format(templateString: string): string ━━━
    Main formatting function that processes custom tags into RichText markup.
    Supports nested tags and handles malformed input gracefully.
    
    Example:
        local result = richTags.format("<rare>Rare <damage>100</damage> Sword</rare>")
        -- Returns: Rich text with blue color, stroke, uppercase formatting + red damage text
    
    ━━━ 2. richTags.wrap(tagName: string, content: string): string ━━━
    Directly wraps content with a specific tag's markup (no tag processing).
    Useful for simple, non-nested formatting.
    
    Example:
        local result = richTags.wrap("legendary", "Golden Sword")
        -- Returns: "<font color='rgb(255, 204, 0)'><stroke...><uppercase>Golden Sword</uppercase></stroke></font>"
    
    ━━━ 3. richTags.getRawTag(tagName: string): {open: string, close: string}? ━━━
    Retrieves the raw open and close markup for a tag definition.
    Returns nil if tag doesn't exist.
    
    Example:
        local tagInfo = richTags.getRawTag("rare")
        print(tagInfo.open)  -- "<font color='rgb(33, 159, 255)'><stroke...><uppercase>"
        print(tagInfo.close) -- "</uppercase></stroke></font>"
    
    ━━━ 4. Dynamic Tag Functions: richTags[tagName](content: string): string ━━━
    Each defined tag gets its own function for quick access.
    Equivalent to calling richTags.wrap(tagName, content).
    
    Example:
        local result = richTags.rare("Legendary Drop")
        local result = richTags.damage("150")
        local result = richTags.b("Bold Text")
    
    ━━━ 5. Auto-Formatting with CollectionService ━━━
    When the module is required, it automatically formats all TextLabels tagged 
    with "formatText". Works with existing and newly tagged instances.
    
    Example:
        -- In Studio: Tag any TextLabel with "formatText"
        -- In Code:
        local CollectionService = game:GetService("CollectionService")
        CollectionService:AddTag(myTextLabel, "formatText")
        -- TextLabel is automatically formatted and RichText is enabled!
    
    ┌─────────────────────────────────────────────────────────────────────────────┐
    │                              BUILT-IN TAGS                                 │
    └─────────────────────────────────────────────────────────────────────────────┘
    
    Rarity Tags (with colors, strokes, uppercase):
    • <secret>text</secret>     - Red with stroke
    • <mythic>text</mythic>     - White with stroke  
    • <legendary>text</legendary> - Gold with stroke
    • <epic>text</epic>         - Purple with stroke
    • <rare>text</rare>         - Blue with stroke
    
    Attribute Tags:
    • <damage>text</damage>     - Red color
    • <critChance>text</critChance> - Orange with subtle stroke
    
    Standard RichText Tags (pass-through):
    • <b>, <i>, <u>, <s>, <sub>, <sup>, <small>, <br/>
    • <uppercase>/<uc>, <smallcaps>/<sc>
    
    ┌─────────────────────────────────────────────────────────────────────────────┐
    │                            EXTENDING TAGS                                   │
    └─────────────────────────────────────────────────────────────────────────────┘
    
    Add new tags in "./tags.luau":
    
        newTag = {
            open = '<font color="rgb(0, 255, 0)">',
            close = "</font>"
        }
    
    Custom tags can reference other custom tags:
        enhanced = { open = '<rare>', close = '</rare>' }  -- This works!
    
    ┌─────────────────────────────────────────────────────────────────────────────┐
    │                            USAGE EXAMPLES                                   │
    └─────────────────────────────────────────────────────────────────────────────┘
    
    Complex Formatting:
        "<rare>You found a <legendary>Mythical Sword</legendary>!</rare>"
        "<damage>Attack: <b>150</b></damage> | <critChance>Crit: 25%</critChance>"
        
    CollectionService Integration:
        local richTags = require(path.to.richTags)
        -- All TextLabels tagged "formatText" are now auto-formatted!
    
    ┌─────────────────────────────────────────────────────────────────────────────┐
    │                       IMPORTANT DEVELOPER NOTES                             │
    └─────────────────────────────────────────────────────────────────────────────┘
    
    • NEVER use numeric tags like <123>content</123> - only word characters allowed
    • Tags must be properly nested: <a><b>text</b></a> ✅ | <a><b>text</a></b> ❌  
    • Maximum 100 iterations prevents infinite loops - increase if needed
    • Original text is preserved in "OriginalText" attribute for CollectionService
    • System automatically enables RichText property on formatted TextLabels
    
    ┌─────────────────────────────────────────────────────────────────────────────┐
    │                           EDGE CASES & LIMITS                               │
    └─────────────────────────────────────────────────────────────────────────────┘
    
    • Malformed HTML mixed with custom tags may cause unexpected behavior
    • Tags with special characters (beyond \w regex) are not supported  
    • Very large strings with many nested tags may be slow
    • Self-referential tag chains deeper than 100 levels will be truncated
]]

local tagDefinitions = require(script.tags)
local CollectionService = game:GetService("CollectionService")

local richTags = {}
local isValidated = false

export type TagFormatterFunction = (content: string) -> string
export type RichTagsModule = typeof(richTags) & { [string]: TagFormatterFunction }

local MAX_ITERATIONS = 100
local FORMAT_TAG = "formatText"

-- Validation: Check for potential circular references in tag definitions
local function validateTagDefinitions()
	for tagName: string, tagDef in pairs(tagDefinitions) do
		-- Only flag as circular if the tag creates a different custom tag with the same name
		local fullOpenTag = "<" .. tagName .. ">"
		local fullCloseTag = "</" .. tagName .. ">"

		local isPassThrough = (tagDef.open == fullOpenTag and tagDef.close == fullCloseTag)

		if not isPassThrough then
			if string.find(tagDef.open, fullOpenTag) or string.find(tagDef.close, fullCloseTag) then
				error(
					`richTags: Circular reference detected in tag "{tagName}" - custom tag cannot reference itself in transformation`
				)
			end
		end
	end
end

-- Detect unclosed tags in the string
local function findUnclosedTags(str: string): string?
	local openTags: { string } = {}
	local pos = 1

	while pos <= #str do
		local openStart, openEnd, tagName = string.find(str, "<(%w+)>", pos)
		local closeStart, closeEnd, closeTagName = string.find(str, "</(%w+)>", pos)

		if openStart and openEnd and tagName and (not closeStart or openStart < closeStart) then
			table.insert(openTags, tagName)
			pos = openEnd + 1
		elseif closeStart and closeEnd and closeTagName then
			if #openTags == 0 then
				return `Closing tag "</{closeTagName}>" found without matching opening tag`
			end
			local lastTag = table.remove(openTags)
			if lastTag ~= closeTagName then
				return `Mismatched tags: expected "</{lastTag}>" but found "</{closeTagName}>"`
			end
			pos = closeEnd + 1
		else
			break
		end
	end

	if #openTags > 0 then
		return `Unclosed tag "<{openTags[#openTags]}>" - missing closing tag`
	end

	return nil
end

--[[
    Formats a template string by replacing custom tag placeholders with RichText markup.
    Placeholders are in the format: `<tagName>content</tagName>`.
    Nested tags are supported (ex:, `<bold>Important: <damage>100</damage></bold>`).
    Custom tags can contain other custom tags for complex formatting.

    @param templateString The string containing custom tag placeholders.
    @returns The string with placeholders replaced by their RichText equivalents.
]]
function richTags.format(templateString: string): string
	if not isValidated then
		validateTagDefinitions()
		isValidated = true
	end

	-- Check for numeric tags
	if string.find(templateString, "<%d") then
		warn("richTags: Numeric tags detected (e.g., <123>). Only use word characters in tag names!")
	end

	-- Check for unclosed/malformed tags
	local tagError = findUnclosedTags(templateString)
	if tagError then
		warn(`richTags: {tagError}. Returning original string.`)
		return templateString
	end

	local currentString = templateString
	local iterations = 0

	while iterations < MAX_ITERATIONS do
		local newString = string.gsub(
			currentString,
			"<(%w+)>(.-)</(%1)>",
			(
					function(tagNameSource: string, content: string): string
						local tagDef = tagDefinitions[tagNameSource]
						if tagDef then
							return tagDef.open .. content .. tagDef.close
						else
							-- Tag not defined
							return string.format("<%s>%s</%s>", tagNameSource, content, tagNameSource)
						end
					end
				) :: any
		)

		-- Only continue if the string actually changed
		if newString == currentString then
			break
		end

		currentString = newString
		iterations += 1
	end

	if iterations >= MAX_ITERATIONS then
		warn(
			`richTags: Maximum iterations ({MAX_ITERATIONS}) reached. This usually indicates circular tag references or extremely deep nesting. Returning current result.`
		)
	end

	return currentString
end

--[[
    Directly wraps content with a specified tag's RichText markup.
    Useful for simple, non-nested formatting.

    @param tagName The name of the tag (ex:, "damage", "critChance").
    @param content The string content to be wrapped.
    @returns The content string wrapped with the tag's RichText markup.
]]
function richTags.wrap(tagName: string, content: string): string
	local tagDef = tagDefinitions[tagName]
	if tagDef then
		return tagDef.open .. content .. tagDef.close
	else
		warn(`TextFormatting.wrap: Tag "{tagName}" not defined. Content not wrapped.`)
		return content
	end
end

--[[
    Retrieves the raw open and close RichText markup for a given tag.

    @param tagName The name of the tag.
    @returns A table with `open` and `close` string properties, or nil if tag not found.
]]
function richTags.getRawTag(tagName: string): { open: string, close: string }?
	local tagDef = tagDefinitions[tagName]
	if not tagDef then
		warn(`TextFormatting.getRawTag: Tag "{tagName}" not defined.`)
	end
	return tagDef
end

-- Auto-format TextLabels tagged with "formatText"
local function formatTextLabel(textLabel: TextLabel)
	if not textLabel:IsA("TextLabel") then
		warn(`richTags: Tagged instance "{textLabel.Name}" is not a TextLabel, skipping auto-format`)
		return
	end

	if not textLabel:GetAttribute("OriginalText") then
		textLabel:SetAttribute("OriginalText", textLabel.Text)
	end

	local originalText = textLabel:GetAttribute("OriginalText") :: string?
	if originalText then
		textLabel.RichText = true -- Enable RichText for formatting to work
		textLabel.Text = richTags.format(originalText)
	end
end

for _, instance in pairs(CollectionService:GetTagged(FORMAT_TAG)) do
	formatTextLabel(instance)
end

CollectionService:GetInstanceAddedSignal(FORMAT_TAG):Connect(formatTextLabel)

CollectionService:GetInstanceRemovedSignal(FORMAT_TAG):Connect(function(textLabel: TextLabel)
	if textLabel:IsA("TextLabel") then
		local originalText = textLabel:GetAttribute("OriginalText") :: string?
		if originalText then
			textLabel.Text = originalText
			textLabel:SetAttribute("OriginalText", nil)
		end
	end
end)

for tagNameSource, _ in pairs(tagDefinitions) do
	richTags[tagNameSource] = (
		function(content: string): string
			return richTags.wrap(tagNameSource, content)
		end
	) :: TagFormatterFunction
end

return richTags :: RichTagsModule
