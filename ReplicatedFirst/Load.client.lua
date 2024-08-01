local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

if game:IsLoaded() == false then
	game.Loaded:Wait()
end

local dirLMEngine = ReplicatedStorage.LMEngine
local dirLMEngineCoreUI = dirLMEngine.Core.UI
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
	if gui:IsA("ScreenGui") == false then
		continue
	end
	local clone = gui:Clone()
	if clone:IsA("ScreenGui") then
		clone.Enabled = true
	end
	clone.Parent = playerGui
end

for _, gui in ipairs(dirLMEngineCoreUI:GetChildren()) do
	if gui:IsA("ScreenGui") == false then
		continue
	end
	local clone = gui:Clone()
	if clone:IsA("ScreenGui") then
		clone.Enabled = true
	end
	clone.Parent = playerGui
end
