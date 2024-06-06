--!strict

local RS = game:GetService("ReplicatedStorage");

local State = require(RS.Shared.Types.PlacementState);
local Mouse = require(script.Parent.Parent.Utils.Mouse);

export type IPlacementClient = {
    __index: IPlacementClient,
    new: () -> PlacementClient,

    Update: (self: PlacementClient, deltaTime: number) -> (),
}

type PlacementClient = typeof(setmetatable({} :: {
    mouse: Mouse.Mouse,
    state: State.PlacementState,
}, {} :: IPlacementClient))

local PlacementClient = {};
PlacementClient.__index = PlacementClient;

function PlacementClient.new()
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

    return self;
end

function PlacementClient:Update(deltaTime: number)
    -- If the player is not placing a structure, return
    if (not self.state.isPlacing) then
        return;
    end

    self.Mouse.currentPosition = self.Mouse:GetPosition();
end

return PlacementClient;