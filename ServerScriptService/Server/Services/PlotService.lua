--!strict
--!version: 1.0.0

--[[
{Lost Media}

-[PlotService] Service
    Central service that manages the plots in the game.
	This service is responsible for assigning plots to players
	and serializing the plot data to the client.

	Members:

		PlotService._plots   [table] -- Player -> Plot
			Stores the mapping of players to plots

	Methods [RateLimiter]:

		PlotService:AssignPlot(player: Player, plot: Instance) -- Assigns a plot to a player
			player [Player]
			plot   [Instance]
--]]

local SETTINGS = {
	PLOTS_LOCATION = workspace.Plots :: Folder,
	MAX_RETRIES = 5,
}

----- Private variables -----

local ReplicatedStorage = game:GetService("ReplicatedStorage")

---@type LMEngineClient
local LMEngine = require(ReplicatedStorage.LMEngine)

---@type RateLimiter
local RateLimiter = LMEngine.GetModule("RateLimiter")

---@type RetryAsync
local RetryAsync = LMEngine.GetShared("RetryAsync")

-- Create any rate limiters here --
local PlotServiceRateLimiter = RateLimiter.NewRateLimiter(5)

---@class PlotService
local PlotService = LMEngine.CreateService({
	Name = "PlotService",
	Client = {
		PlotAssigned = LMEngine.CreateSignal(),
		Test = LMEngine.CreateSignal(),
		--PlaceStructure = Knit.CreateSignal();
	},

	_plots = {},
})

----- Private functions -----

local function GetPlots()
	return SETTINGS.PLOTS_LOCATION:GetChildren()
end

local function GetFreePlots(): { Instance }
	local plots = GetPlots()
	local free_plots = {}

	for _, plot in ipairs(plots) do
		local occupied: boolean? = plot:GetAttribute("Occupied")

		if not occupied then
			table.insert(free_plots, plot)
		end
	end

	return free_plots
end

local function GetRandomFreePlot(): Instance?
	local free_plots = GetFreePlots()

	assert(free_plots, "[PlotService] GetRandomFreePlot: Free plots is nil")
	assert(#free_plots > 0, "[PlotService] GetRandomFreePlot: No free plots available")

	if #free_plots == 0 then
		return nil
	end

	local random = free_plots[math.random(1, #free_plots)]

	return random
end

local function GetRandomPlot()
	local plots = SETTINGS.PLOTS_LOCATION:GetChildren()
	local random = plots[math.random(1, #plots)]

	local occupied: boolean? = random:GetAttribute("Occupied")

	if occupied then
		return GetRandomPlot()
	end

	return nil
end

local function AssignPlot(player: Player, plot: Instance)
	plot:SetAttribute("Occupied", true)
end

----- Public functions -----

function PlotService:Init()
	print("[PlotService] initialized")
end

function PlotService:Start()
	print("[PlotService] started")

	---@type PlayerService
	local PlayerService = LMEngine.GetService("PlayerService")

	PlayerService:RegisterPlayerAdded(function(player)
		local success, data = RetryAsync(function()
			local plot = GetRandomFreePlot()
			self:AssignPlot(player, plot)
		end, SETTINGS.MAX_RETRIES)

		if not success then
			warn("[PlotService] Failed to assign plot to player: " .. data)
			return
		end

		print("[PlotService] Assigned plot to player: " .. player.Name)
	end)
end

function PlotService:AssignPlot(player: Player, plot: Instance)
	assert(player, "[PlotService] AssignPlot: Player is nil")
	assert(plot, "[PlotService] AssignPlot: Plot is nil")
	assert(plot:GetAttribute("Occupied") ~= true, "[PlotService] AssignPlot: Plot is already occupied")

	AssignPlot(player, plot)

	PlotService._plots[player] = plot
	PlotService.Client.PlotAssigned:Fire(player, plot)
end

return PlotService
