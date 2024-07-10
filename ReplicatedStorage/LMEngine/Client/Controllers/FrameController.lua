--!strict

--[[
{Lost Media}

-[FrameController] Controller
    A controller that manages the opening and closing of frames in the UI
--]]

local SETTINGS = {}

----- Private variables -----
local ReplicatedStorage = game:GetService("ReplicatedStorage")

---@type LMEngineClient
local LMEngine = require(ReplicatedStorage.LMEngine.Client)
local Player = game:GetService("Players").LocalPlayer

local Trove = require(LMEngine.SharedDir.Trove)

---@class FrameController
local FrameController = LMEngine.CreateController({
	Name = "FrameController",

	_frames = {},
})

----- Private functions -----

----- Public functions -----

function FrameController:RegisterFrame(
	name: string,
	openFunction: (trove: Trove.Trove) -> (),
	closeFunction: (trove: Trove.Trove) -> (),
	openIntitially: boolean?
)
	-- Handle the logic

	local cleanupTrove = Trove.new()

	self._frames[name] = {
		openFunction = openFunction,
		closeFunction = closeFunction,
		cleanupTrove = cleanupTrove,
		isOpen = false,
	}

	openIntitially = openIntitially or false

	if openIntitially == true then
		self:OpenFrame(name)
	else
		self:CloseFrame(name)
	end
end

function FrameController:OpenFrame(name: string)
	local frame = self._frames[name]

	if frame == nil then
		return
	end

	if frame.isOpen == true then
		return
	end

	coroutine.wrap(function()
		local success, err = pcall(function()
			frame.openFunction(frame.cleanupTrove)
		end)

		if success == false then
			warn("[FrameController] OpenFrame: Error opening frame ->", err)
			return
		end

		frame.isOpen = true
	end)()
end

function FrameController:CloseFrame(name: string | { string })
	if name == nil then
		return
	end

	if name == "all" then
		for _, frame in pairs(self._frames) do
			self:CloseFrame(frame)
		end
		return
	end

	if type(name) == "table" then
		for _, frame_name in ipairs(name) do
			self:CloseFrame(frame_name)
		end

		return
	end

	local frame = self._frames[name]

	if frame == nil then
		return
	end

	frame.isOpen = false

	coroutine.wrap(function()
		local success, err = pcall(function()
			frame.closeFunction(frame.cleanupTrove)
			frame.cleanupTrove:Destroy()
		end)

		if success == false then
			warn("[FrameController] CloseFrame: Error closing frame ->", err)
		end
	end)()
end

function FrameController:CloseAllFramesExcept(screens: { string })
	for frame_name, _ in pairs(self._frames) do
		if table.find(screens, frame_name) == nil then
			self:CloseFrame(frame_name)
		end
	end
end

function FrameController:ToggleFrame(name: string)
	local frame = self._frames[name]

	if frame == nil or frame.isToggling == true then
		return
	end

	frame.isToggling = true

	if frame.isOpen == true then
		self:CloseFrame(name)
	else
		self:OpenFrame(name)
	end

	frame.isToggling = false
end

function FrameController:IsFrameOpen(name: string): boolean
	local frame = self._frames[name]

	if frame == nil then
		return false
	end

	return frame.isOpen
end

return FrameController
