--[[
*{LMEngine} -[NumberFormatter]- v1.0.0 -----------------------------------
Library for formatting numbers into a more readable format (e.g., "$5.4k")

Author: brandon-kong (ijmod)
Last Modified: 2024-07-04

Dependencies:
    - None

Usage:
    local NumberFormatter = require(game.ReplicatedStorage.Modules.NumberFormatter)
    NumberFormatter.MonetaryFormat(5000) -- Returns "$5k"

Functions:
    - functionName(param1: type, param2: type): returnType
      Brief description of the function
    - ...

Members [ClassName]:
    - memberName: type (brief description)
    - ...

Methods [ClassName]:
    - methodName(param1: type, param2: type): returnType
      Brief description of the method
    - ...

Changelog:
    v1.0.0 - Initial implementation
--]]

local SETTINGS = {
	Suffixes = { "", "k", "M", "B", "T" },
}

-- NumberFormatter.lua
local NumberFormatter = {}

-- Formats number into a more readable format (e.g., "$5.4k")
function NumberFormatter.MonetaryFormat(number: number, includeDollarSign: boolean?): string
	local suffixIndex = 1

	while number >= 1000 and suffixIndex < #SETTINGS.Suffixes do
		number = number / 1000
		suffixIndex = suffixIndex + 1
	end

	-- Format number to one decimal place if it's not an integer
	local formattedNumber = number % 1 == 0 and tostring(number) or string.format("%.1f", number)

	if includeDollarSign == true then
		return "$" .. formattedNumber .. SETTINGS.Suffixes[suffixIndex]
	end

	return formattedNumber .. SETTINGS.Suffixes[suffixIndex]
end

function NumberFormatter.CommaFormat(number: number): string
	return string.format("%d", number):reverse():gsub("%d%d%d", "%1,"):reverse():gsub("^,", "")
end

return NumberFormatter
