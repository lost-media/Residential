--!strict

--[[
{Lost Media}

-[MusicController] Controller
    A controller that plays music from a folder in ReplicatedStorage.
    The music is played at random and loops when it ends.
--]]

local SETTINGS = {
	MusicFolder = game:GetService("ReplicatedStorage").Music,
	SoundParent = game:GetService("SoundService"),
	Volume = 0.25,
}

----- Private variables -----

local ReplicatedStorage = game:GetService("ReplicatedStorage")

---@type LMEngineClient
local LMEngine = require(ReplicatedStorage.LMEngine.Client)

---@type Deque
local Deque = require(ReplicatedStorage.LMEngine.Shared.DS.Deque)

---@type Trove
local Trove = LMEngine.GetShared("Trove")

---@class MusicController
local MusicController = LMEngine.CreateController({
	Name = "MusicController",

	_queue = Deque.new(),
})

local TroveObject = Trove.new()

----- Private functions -----

local function InitializeMusicQueue(queue: Deque.Deque)
	local music = SETTINGS.MusicFolder:GetChildren()

	for _, sound in music do
		if sound:IsA("Sound") == false then
			continue
		end
		queue:PushRight(sound)
	end
end

local function PlayMusicFromQueue(queue: Deque.Deque)
	local sound = queue:PopLeft()

	if sound == nil then
		print("[MusicController] No music in queue, reinitializing")

		InitializeMusicQueue(queue)
		sound = queue:PopLeft()
	end

	local cloned_sound = TroveObject:Clone(sound)
	cloned_sound.Parent = SETTINGS.SoundParent
	cloned_sound.Volume = SETTINGS.Volume

	cloned_sound:Play()

	cloned_sound.Ended:Connect(function()
		TroveObject:Clean()
		PlayMusicFromQueue(queue)
	end)
end

----- Public functions -----

function MusicController:Init()
	print("[MusicController] initialized")

	--InitializeMusicQueue(self._queue);
end

function MusicController:Start()
	print("[MusicController] started")

	pcall(function()
		self:PlayMusic()
	end)
end

function MusicController:PlayMusic()
	PlayMusicFromQueue(self._queue)
end

return MusicController
