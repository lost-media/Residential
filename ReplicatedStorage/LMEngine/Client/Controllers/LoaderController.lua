--!strict

--[[
{Lost Media}

-[LoaderController] Controller
    A controller that manages the opening and closing of frames in the UI
--]]

local SETTINGS = {
	DotLoadedColor3 = Color3.fromRGB(76, 119, 102),
	DotLoadingColor3 = Color3.fromRGB(113, 176, 151),
	DotInactiveColor3 = Color3.fromRGB(181, 178, 172),
}

----- Private variables -----
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

---@type LMEngineClient
local LMEngine = require(ReplicatedStorage.LMEngine.Client)
local Player = game:GetService("Players").LocalPlayer

local Promise = require(LMEngine.SharedDir.Promise)
local Signal = require(LMEngine.SharedDir.Signal)

---@class LoaderController
local LoaderController = LMEngine.CreateController({
	Name = "LoaderController",

	LoadComplete = Signal.new(),
})

----- Private functions -----

----- Public functions -----

function LoaderController:Start()
	---@type FrameController
	local FrameController = LMEngine.GetController("FrameController")

	LMEngine.GameLoaded():andThen(function()
		-- All UI is loaded
		local playerGui = Player.PlayerGui

		local lmEngineLoader = playerGui:FindFirstChild("LMEngineLoader")

		if lmEngineLoader == nil then
			return
		end

		-- Handle the loading screen logic
		local container = lmEngineLoader.Container
		local dotContainer = container.DotContainer

		local function makeDotTween(dot: ImageLabel)
			local tweenInfo = TweenInfo.new(
				0.5,
				Enum.EasingStyle.Quad,
				Enum.EasingDirection.InOut,
				-1,
				true,
				0.25
			)

			dot.ImageColor3 = SETTINGS.DotInactiveColor3

			local tween = TweenService:Create(dot, tweenInfo, {
				ImageColor3 = SETTINGS.DotLoadingColor3,
			})

			return tween
		end

		local currentTask = 1
		local tasksToComplete = {
			[1] = function()
				return true
			end,

			[2] = function()
				-- See if the server loaded
				while task.wait(1) do
					if ReplicatedStorage.LMEngine:FindFirstChild("LMEngineServerStarted") then
						break
					end
				end
			end,

			[3] = function()
				-- see if the game loaded
				while task.wait(1) do
					if game:IsLoaded() then
						break
					end
				end
			end,

			[4] = function()
				-- Preload all assets

				---@type PreloadController
				local PreloadController = LMEngine.GetController("PreloadController")

				PreloadController:PreloadAssets()

				return true
			end,
		}

		lmEngineLoader.Enabled = true

		FrameController:RegisterFrame("Loader", function(trove)
			-- Open the loading screen

			-- Start the loading process
			for i = currentTask, #tasksToComplete do
				local task = tasksToComplete[i]

				local dotImage = dotContainer:FindFirstChild(tostring(currentTask))
				if dotImage == nil then
					break
				end

				local tween = makeDotTween(dotImage)
				tween:Play()

				if task() == false then
					break
				end

				tween:Cancel()

				TweenService:Create(dotImage, TweenInfo.new(0.25), {
					ImageColor3 = SETTINGS.DotLoadedColor3,
				}):Play()

				currentTask = currentTask + 1
			end

			-- fire the load complete signal
			self.LoadComplete:Fire()

			-- Close the loading screen
			Promise.delay(2):andThen(function()
				FrameController:CloseFrame("Loader")
			end)
		end, function(trove)
			-- Close the loading screen
			local frame = lmEngineLoader.Frame

			local uiGradient = frame:FindFirstChildWhichIsA("UIGradient")

			local function tweenGradientIn()
				local numbervalue = Instance.new("NumberValue")
				numbervalue.Value = uiGradient.Transparency.Keypoints[1].Value

				local nv2 = Instance.new("NumberValue")
				nv2.Value = uiGradient.Transparency.Keypoints[2].Value

				local number_con = numbervalue.Changed:Connect(function()
					uiGradient.Transparency = NumberSequence.new(numbervalue.Value, nv2.Value)
				end)

				local number_con2 = nv2.Changed:Connect(function()
					uiGradient.Transparency = NumberSequence.new(numbervalue.Value, nv2.Value)
				end)

				local tweenInfoFade =
					TweenInfo.new(0.21, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
				local tweenInfoFade2 =
					TweenInfo.new(0.07, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

				local tw = TweenService:Create(numbervalue, tweenInfoFade, { Value = 0 })
				local tw2 = TweenService:Create(nv2, tweenInfoFade2, { Value = 0 })

				local tw_con
				tw_con = tw.Completed:Connect(function()
					number_con:Disconnect()
					tw_con:Disconnect()
					numbervalue:Destroy()
					nv2:Destroy()
				end)

				tw:Play()
				tw2:Play()
			end

			local function tweenGradientOut()
				local numbervalue = Instance.new("NumberValue")
				numbervalue.Value = uiGradient.Transparency.Keypoints[1].Value

				local nv2 = Instance.new("NumberValue")
				nv2.Value = uiGradient.Transparency.Keypoints[2].Value

				local number_con = numbervalue.Changed:Connect(function()
					uiGradient.Transparency = NumberSequence.new(numbervalue.Value, nv2.Value)
				end)

				local number_con2 = nv2.Changed:Connect(function()
					uiGradient.Transparency = NumberSequence.new(numbervalue.Value, nv2.Value)
				end)

				local tweenInfoFade =
					TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
				local tweenInfoFade2 =
					TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

				local tw = TweenService:Create(numbervalue, tweenInfoFade, { Value = 1 })
				local tw2 = TweenService:Create(nv2, tweenInfoFade2, { Value = 1 })

				local tw_con
				tw_con = tw2.Completed:Connect(function()
					number_con:Disconnect()
					tw_con:Disconnect()
					numbervalue:Destroy()
					nv2:Destroy()

					lmEngineLoader.Enabled = false
				end)

				tw:Play()
				tw2:Play()
			end

			tweenGradientIn()
			task.wait(1)
			container.Visible = false
			tweenGradientOut()
		end, true)
	end)
end

return LoaderController
