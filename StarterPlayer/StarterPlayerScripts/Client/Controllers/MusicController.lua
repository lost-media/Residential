--!strict

--[[
*{Residential} -[MusicController]- v1.0.0 -----------------------------------
Controls the client-side music for the game.

Author: brandon-kong (ijmod)
Last Modified: 2024-07-01

Dependencies:
	- Deque
	- TableUtil
	- Trove

Usage:
	local MusicController = LMEngine.GetController("MusicController")
	MusicController:PlayMusic()

Members [MusicController]:
	- _queue: Deque.Deque (A queue of music to play)

Methods [MusicController]:
	- PlayMusic(): void (Plays music from the queue)

Changelog:
	v1.0.0 - Initial implementation
--]]

local SETTINGS = {
	SoundParent = game:GetService("SoundService"),
	Volume = 0.15,

	Sounds = {
		{
			Name = "Just A Normal Day Underscore A",
			Id = "rbxassetid://9046515361",
		},

		{
			Name = "Playful Afternoon",
			Id = "rbxassetid://1839690393",
		},

		{
			Name = "Playful Electro Funk",
			Id = "rbxassetid://1836160504",
		},
	},
}

----- Private variables -----

local ReplicatedStorage = game:GetService("ReplicatedStorage")

---@type LMEngineClient
local LMEngine = require(ReplicatedStorage.LMEngine.Client)

local dirShared = LMEngine.SharedDir
local Deque = require(dirShared.DS.Deque)
local TableUtil = require(dirShared.TableUtil)
local Trove = require(dirShared.Trove)

---@class MusicController
local MusicController = LMEngine.CreateController({
	Name = "MusicController",

	_queue = Deque.new(),
})

local troveObject = Trove.new()

----- Private functions -----

local function InitializeMusicQueue(queue: Deque.Deque)
	local music = SETTINGS.Sounds

	-- Create a shuffled list of sounds
	local shuffled = TableUtil.Shuffle(music)

	for _, sound in shuffled do
		queue:PushRight(sound)
	end
end

local function MakeSound(sound: { Name: string, Id: string }): Sound
	local sound_instance = Instance.new("Sound")
	sound_instance.Name = sound.Name
	sound_instance.SoundId = sound.Id

	return sound_instance
end

local function PlayMusicFromQueue(queue: Deque.Deque)
	local sound = queue:PopLeft()

	if sound == nil then
		InitializeMusicQueue(queue)
		sound = queue:PopLeft()
	end

	local clonedSound = troveObject:Add(MakeSound(sound))

	clonedSound.Parent = SETTINGS.SoundParent
	clonedSound.Volume = SETTINGS.Volume

	clonedSound:Play()

	clonedSound.Ended:Connect(function()
		troveObject:Clean()
		PlayMusicFromQueue(queue)
	end)
end

----- Public functions -----

function MusicController:Start()
	pcall(function()
		self:PlayMusic()
	end)
end

function MusicController:PlayMusic()
	PlayMusicFromQueue(self._queue)
end

return MusicController
