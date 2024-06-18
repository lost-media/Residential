--!strict
--!version: 1.0.0

--[[
{Lost Media}

-[PlotService] Controller
    A controller that listens for the PlotAssigned event from the PlotService and assigns the plot to the PlotController.
    The PlotController is then used to get the plot assigned to the player.
--]]


local SETTINGS = {
    PLOTS_LOCATION = workspace.Plots :: Folder;
};

----- Private variables -----

local ReplicatedStorage = game:GetService("ReplicatedStorage");

---@type LMEngineClient
local LMEngine = require(ReplicatedStorage.LMEngine);

---@type RateLimiter
local RateLimiter = LMEngine.GetModule("RateLimiter");

-- Create any rate limiters here --
local TestRateLimiter = RateLimiter.NewRateLimiter(5);

---@class PlotService
local PlotService = LMEngine.CreateService({
	Name = "PlotService",
	Client = {
		PlotAssigned = LMEngine.CreateSignal(),
        Test = LMEngine.CreateSignal(),
		--PlaceStructure = Knit.CreateSignal();
	},

	_plots = {},
});

----- Public functions -----

function PlotService:Init()
	print("[PlotService] initialized");
end

function PlotService:Start()
	print("[PlotService] started");
end

function PlotService.Client:Test(player: Player)
    assert(TestRateLimiter:CheckRate(player) == true, "[PlotService] Rate limit exceeded");

    print("[PlotService] Test signal received");
end

return PlotService;
