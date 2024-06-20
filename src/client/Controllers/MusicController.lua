--!strict

local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local MusicFolder = RS.Music :: Folder

local Knit = require(RS.Packages.Knit)

local MusicController = Knit.CreateController({
	Name = "MusicController",
})

function MusicController:KnitInit()
	print("MusicController initialized")
end

function MusicController:KnitStart()
	print("MusicController started")
	self:PlayMusic()
end

function MusicController:PlayMusic()
	local music = MusicFolder:GetChildren()
	local randomMusic = music[math.random(1, #music)]
	local sound = Instance.new("Sound")
	sound.SoundId = randomMusic.SoundId
	sound.Parent = game.Workspace
	sound.Volume = 0.25
	sound:Play()
	sound.Ended:Connect(function()
		sound:Destroy()
		self:PlayMusic()
	end)
end

return MusicController
