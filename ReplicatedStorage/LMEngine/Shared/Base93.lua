local Base93 = {}
local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!\"#$%&'()*+,-./:;<=>?@[\\]^_`{|}~"

-- Helper function to convert a number to a Base93 string
local function ToBase93(num)
	local result = ""
	repeat
		local remainder = num % 93
		result = chars:sub(remainder + 1, remainder + 1) .. result
		num = (num - remainder) / 93
	until num == 0
	return result
end

-- Helper function to convert a Base93 string to a number
local function FromBase93(s)
	local num = 0
	for i = 1, #s do
		num = num * 93 + (chars:find(s:sub(i, i)) - 1)
	end
	return num
end

-- Encode a string to Base93
function Base93.ToBase93(input: string)
	local bytes = { input:byte(1, #input) }
	local num = 0
	for i, byte in ipairs(bytes) do
		num = num * 256 + byte
	end
	return ToBase93(num)
end

-- Decode a Base93 string
function Base93.FromBase93(input: string)
	local num = FromBase93(input)
	local bytes = {}
	while num > 0 do
		table.insert(bytes, 1, num % 256)
		num = math.floor(num / 256)
	end
	return string.char(unpack(bytes))
end

return Base93
