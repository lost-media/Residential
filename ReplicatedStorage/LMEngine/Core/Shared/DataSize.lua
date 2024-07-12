local HttpService = game:GetService("HttpService")

local DataSize = {}

function DataSize.GetDataSizeInBytes(data: any): number
	local dataString = HttpService:JSONEncode(data)
	local dataSize = string.len(dataString)
	return dataSize
end

function DataSize.GetDataSizeInKilobytes(data: any): number
	local dataSize = DataSize.GetDataSizeInBytes(data)
	dataSize = DataSize / 1024
	return dataSize
end

function DataSize.GetDataSizeInMegabytes(data: any): number
	local dataSize = DataSize.GetDataSizeInKilobytes(data)
	dataSize = DataSize / 1024
	return dataSize
end

return DataSize
