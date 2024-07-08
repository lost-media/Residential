local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

if game:IsLoaded() == false then
	game.Loaded:Wait()
end

local playerGui = Players.LocalPlayer.PlayerGui
local dirCoreUI = ReplicatedStorage.UI.Core

for _, gui in ipairs(StarterGui:GetChildren()) do
	if gui:IsA("ScreenGui") then
		gui.Enabled = false
	end
end

for _, gui in ipairs(playerGui:GetChildren()) do
	if gui:IsA("ScreenGui") then
		gui.Enabled = false
	end
end

for _, gui in ipairs(dirCoreUI:GetChildren()) do
	local clone = gui:Clone()
	if clone:IsA("ScreenGui") then
		clone.Enabled = true
	end
	clone.Parent = playerGui
end
