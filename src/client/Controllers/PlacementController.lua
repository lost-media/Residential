--!strict

local RS = game:GetService("ReplicatedStorage");
local TS = game:GetService("TweenService");

local Placeables: Folder = RS.Placeables;
local ClientUtils: Folder = script.Parent.Parent.Utils;

local Knit = require(RS.Packages.Knit);
local InstanceUtils = require(ClientUtils.InstanceUtils)
local Mouse = require(ClientUtils.Mouse);

local PLACEMENT_TWEEN_DURATION = 0.1;

local PlacementController = Knit.CreateController {
    Name = "PlacementController";

    State = {
        Placing = false;
        CurrentPlaceable = nil;
        OriginalPlaceable = nil;
    };

    Plot = nil;
};

function PlacementController:KnitInit()
    print("PlacementController initialized");

    self.Mouse = Mouse.new();
    self.Mouse:SetFilterType(Enum.RaycastFilterType.Include);
end

function PlacementController:KnitStart()
    print("PlacementController started");

    -- Bind render stepped
    game:GetService("RunService").RenderStepped:Connect(function()

        if (self.State.Placing == true) then
            self:RenderStepped(self.Mouse:GetPosition());
        end
    end);

    -- Bind mouse click
    game:GetService("UserInputService").InputBegan:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseButton1) then
            if (self.State.Placing == true) then
                print("Placing");
                self:StopPlacing();
            else
                print("Not placing");
                self:StartPlacing(Placeables.Road["Normal Road"]);
            end
        end
    end);
end

function PlacementController:StartPlacing(placeable: Model)
    if (self.State.Placing == true) then
        warn("Already placing a placeable");
        return;
    end

    if (placeable == nil) then
        warn("No placeable provided");
        return;
    end

    local PlotController = Knit.GetController("PlotController");

    local tiles: Folder = PlotController:GetPlot():FindFirstChild("Tiles");

    self.Mouse:SetTargetFilter({
        tiles,
    });

    self.State.Placing = true;
    self.State.OriginalPlaceable = placeable;

    -- Clone the placeable model
    local clone = placeable:Clone();
    self.State.CurrentPlaceable = clone;

    clone.Parent = workspace.Debris;

    -- Dim the model and uncollide it
    InstanceUtils:dimModel(clone);
    InstanceUtils:uncollideModel(clone);

    -- Choose a random tile to place the placeable on initially
    local randomTile: BasePart? = InstanceUtils:getRandomInstance(tiles:GetChildren());
    
    if (randomTile == nil) then
        warn("No tiles found");
        return;
    end

    self:MovePlaceableToTile(randomTile, true);
end

function PlacementController:StopPlacing()
    if (self.State.Placing == false) then
        warn("Not placing a placeable");
        return;
    end

    self.State.Placing = false;

    if self.State.CurrentPlaceable then
        self.State.CurrentPlaceable:Destroy();
    end

    self.State.CurrentPlaceable = nil;
    self.State.OriginalPlaceable = nil;
end

function PlacementController:RenderStepped(mouse: Vector2)
    if (self.State.Placing == false) then
        return;
    end

    local plot = Knit.GetController("PlotController"):GetPlot();

    if (plot == nil) then
        return;
    end

    -- Raycast to the ground
    local target: BasePart? = self.Mouse:GetTarget();

    if (target == nil) then
        return;
    end

    self:MovePlaceableToTile(target);
end

function PlacementController:MovePlaceableToTile(tile: BasePart, instant: boolean?)
    if (self.State.CurrentPlaceable == nil) then
        return;
    end

    local plot = Knit.GetController("PlotController"):GetPlot();

    if (plot == nil) then
        return;
    end

    local tileHeight: number = tile.Size.Y;
    local _, placeableSize = self.State.CurrentPlaceable:GetBoundingBox();
    
    local objectPosition = tile.Position + Vector3.new(0, (placeableSize.Y / 2) + (tileHeight / 2), 0);
    
    -- Tween the placeable's position

    if (instant == true) then
        self.State.CurrentPlaceable.PrimaryPart.CFrame = CFrame.new(objectPosition);
        return;
    end
    
    local tweenInfo = TweenInfo.new(PLACEMENT_TWEEN_DURATION, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0, false, 0);

    local tween = TS:Create(self.State.CurrentPlaceable.PrimaryPart, tweenInfo, {
        CFrame = CFrame.new(objectPosition);
    });

    tween:Play();
end

return PlacementController;