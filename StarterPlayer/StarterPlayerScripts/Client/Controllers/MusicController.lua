--!strict

--[[
{Lost Media}

-[MusicController] Controller
    A controller that plays music from a folder in ReplicatedStorage.
    The music is played at random and loops when it ends.
--]]

local SETTINGS = {
	SoundParent = game:GetService("SoundService"),
	Volume = 0.25,

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

---@type Deque
local Deque = require(ReplicatedStorage.LMEngine.Shared.DS.Deque)

local TableUtil = require(LMEngine.SharedDir.TableUtil)

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

	local cloned_sound = TroveObject:Add(MakeSound(sound))

	cloned_sound.Parent = SETTINGS.SoundParent
	cloned_sound.Volume = SETTINGS.Volume

	cloned_sound:Play()

	cloned_sound.Ended:Connect(function()
		TroveObject:Clean()
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
