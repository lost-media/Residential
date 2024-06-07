--!strict

local RS = game:GetService("ReplicatedStorage");
local RunService = game:GetService("RunService");

local State = require(RS.Shared.Types.PlacementState);
local Plot = require(RS.Shared.Types.Plot);
local Mouse = require(script.Parent.Parent.Utils.Mouse);

type IPlacementClient = {
    __index: IPlacementClient,
    new: (plot: Plot.Plot) -> PlacementClient,

    GetMouse: (self: PlacementClient) -> Mouse.Mouse,
    Update: (self: PlacementClient, deltaTime: number) -> (),
    Destroy: (self: PlacementClient) -> (),
}

export type PlacementClient = typeof(setmetatable({} :: {

    mouse: Mouse.Mouse,
    plot: Plot.Plot,
    state: State.PlacementState,
    onRenderStep: RBXScriptConnection,

}, {} :: IPlacementClient))

local PlacementClient = {};
PlacementClient.__index = PlacementClient;

function PlacementClient.new(plot: Plot.Plot)

    -- Validate the plot before creating the PlacementClient instance
    if (Plot.isPlotValid(plot) == false) then
        error("Plot is invalid");
    end

    local self = setmetatable({}, PlacementClient);

    self.mouse = Mouse.new();

    self.state = {
        isPlacing = false,
        canConfirmPlacement = false,

        structureId = nil,
        ghostStructure = nil,
        tile = nil,

        rotation = 0,
        level = 0,

        isStacked = false,
    };

    -- Set up render stepped
    self.onRenderStep = RunService.RenderStepped:Connect(function()
        self.mouse.currentPosition = self.mouse:GetPosition();
    end);
    
    return self;
end

function PlacementClient:GetMouse()
    return self.mouse;
end

function PlacementClient:Update(deltaTime: number)
    -- If the player is not placing a structure, return
    if (not self.state.isPlacing) then
        return;
    end

end

function PlacementClient:Destroy()
    self.onRenderStep:Disconnect();
end

return PlacementClient;