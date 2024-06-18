--!strict
--!version: 1.0.0

--[[
{Lost Media}

-[MusicController] Controller
    A controller that plays music from a folder in ReplicatedStorage.
    The music is played at random and loops when it ends.
--]]

local SETTINGS = {
    MusicFolder = game:GetService("ReplicatedStorage").Music,
    SoundParent = game:GetService("SoundService"),
    Volume = 0.25;
};

----- Private variables -----

local ReplicatedStorage = game:GetService("ReplicatedStorage")

---@type LMEngineClient
local LMEngine = require(ReplicatedStorage.LMEngine);

---@type Trove
local Trove = LMEngine.GetShared("Trove");

---@class MusicController
local MusicController = LMEngine.CreateController({
    Name = "MusicController",
});

local TroveObject = Trove.new();

----- Public functions -----

function MusicController:Init()
    print("[MusicController] initialized");

end

function MusicController:Start()
    print("[MusicController] started")

    pcall(function()
        self:PlayMusic()
    end)
end

function MusicController:PlayMusic()
    assert(SETTINGS.MusicFolder ~= nil, "Music folder not found in ReplicatedStorage")
    
    local music = SETTINGS.MusicFolder:GetChildren();

    assert(#music > 0, "No music found in Music folder");

    local random_music: Sound = music[math.random(1, #music)];
    local cloned_music: Sound = TroveObject:Clone(random_music);
    cloned_music.Parent = SETTINGS.SoundParent;
    cloned_music.Volume = SETTINGS.Volume;
    cloned_music:Play();

    cloned_music.Ended:Connect(function()
        TroveObject:Clean();
        self:PlayMusic();
    end)
end

return MusicController;
