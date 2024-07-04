local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

if game:IsLoaded() == false then
	game.Loaded:Wait()
end

local playerGui = Players.LocalPlayer.PlayerGui
local dirCoreUI = ReplicatedStorage.UI.Core

for _, gui in ipairs(dirCoreUI:GetChildren()) do
	gui:Clone().Parent = playerGui
end
