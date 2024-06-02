--!strict

local UIS = game:GetService("UserInputService");
local RS = game:GetService("ReplicatedStorage");
local TS = game:GetService("TweenService");

local Placeables: Folder = RS.Placeables;
local ClientUtils: Folder = script.Parent.Parent.Utils;

local PlaceablesModule = require(RS.Shared.Placeables);
local Knit = require(RS.Packages.Knit);
local InstanceUtils = require(ClientUtils.InstanceUtils)
local Mouse = require(ClientUtils.Mouse);

local PLACEMENT_TWEEN_DURATION = 0.1;
local ROTATION_INCREMENT = 90;
local LEVEL_HEIGHT = 6; -- The height of each level for stacking in studs
local LEVEL_MAX = 5;

local PlacementController = Knit.CreateController {
    Name = "PlacementController";

    State = {
        Placing = false;
        CurrentPlaceable = nil;
        OriginalPlaceable = nil;
        OriginalIdentifier = nil;
        Tile = nil;
        Rotation = 0;
        Level = 0; -- For stacking, used for calculating the height of the placeable
        
        Stacked = false;
        StackedOn = nil;
        SnappedPoint = nil;
    };

    Plot = nil;
};

function PlacementController:KnitInit()
    print("PlacementController initialized");

    self.Mouse = Mouse.new();
    self.Mouse:SetFilterType(Enum.RaycastFilterType.Exclude);
end

function PlacementController:KnitStart()
    print("PlacementController started");

    self.PlotController = Knit.GetController("PlotController");

    if (self.PlotController == nil) then
        warn("PlotController not found");
        return;
    end

    -- Bind render stepped
    game:GetService("RunService").RenderStepped:Connect(function()

        if (self.State.Placing == true) then
            self:RenderStepped();
        end
    end);

    -- Bind mouse click
    UIS.InputBegan:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseButton1) then
            if (self.State.Placing == true) then
                self:ConfirmPlacement();
            else
                print("Not placing");
                self:StartPlacing("Residence/House/Starter House");
            end
        elseif (input.KeyCode == Enum.KeyCode.R) then
            self:Rotate();
        elseif (input.KeyCode == Enum.KeyCode.E) then
            self.State.Level = math.min(self.State.Level + 1, LEVEL_MAX);
        elseif (input.KeyCode == Enum.KeyCode.Q) then
            self.State.Level = math.max(0, self.State.Level - 1);
        end
    end);
end

function PlacementController:StartPlacing(identifier: string)
    if (self.State.Placing == true) then
        warn("Already placing a placeable");
        return;
    end

    if (identifier == nil) then
        warn("No placeable identifier provided");
        return;
    end

    local placeable = PlaceablesModule.GetPlaceableFromId(identifier);

    if (placeable == nil) then
        warn("Placeable not found");
        return;
    end

    local plot = self.PlotController:GetPlot();
    if (plot == nil) then
        warn("No plot found");
        return;
    end

    local tiles: Folder = plot:FindFirstChild("Tiles");

    if (tiles == nil) then
        warn("Tiles folder not found in plot");
        return;
    end

    self.State.Placing = true;
    self.State.OriginalPlaceable = placeable;
    self.State.OriginalIdentifier = identifier;

    -- Clone the placeable model
    local clone = placeable.Model:Clone();
    self.State.CurrentPlaceable = clone;

    clone.Parent = workspace.Debris;

    -- Dim the model and uncollide it
    InstanceUtils:dimModel(clone);
    InstanceUtils:uncollideModel(clone);

    self.Mouse:SetTargetFilter({
        clone,
        InstanceUtils:getAllPlayerCharacters(),
    });

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

function PlacementController:RenderStepped()
    if (self.State.Placing == false) then
        return;
    end

    local plot = self.PlotController:GetPlot();

    if (plot == nil) then
        return;
    end

    -- Raycast to the ground
    local target: Vector3 = self.Mouse:GetHit();

    if (target == nil) then
        return;
    end

    local closestTile: BasePart? = InstanceUtils:getClosestInstance(plot:FindFirstChild("Tiles"):GetChildren(), target);

    self.State.Tile = closestTile;

    self:MovePlaceableToTile(closestTile);

    if closestTile then
        local snapped = self:SnapToClosestPoint();
        if (snapped == false) then
            self.State.Level = 0;
            self.State.Stacked = false;
            self.State.StackedOn = nil;
            self.State.SnappedPoint = nil;
        end
    end
end

function PlacementController:MovePlaceableToTile(tile: BasePart, instant: boolean?)
    if (self.State.CurrentPlaceable == nil) then
        return;
    end

    local plot = self.PlotController:GetPlot();

    if (plot == nil) then
        return;
    end

    if (tile:IsDescendantOf(plot) == false) then
        return;
    end

    local tileHeight: number = tile.Size.Y;
    local _, placeableSize = self.State.CurrentPlaceable:GetBoundingBox();
    
    local objectPosition = tile.Position + Vector3.new(0, (placeableSize.Y / 2) + (tileHeight / 2), 0);
    objectPosition = objectPosition + Vector3.new(0, self.State.Level * LEVEL_HEIGHT, 0);

    if (instant == true) then
        self.State.CurrentPlaceable.PrimaryPart.CFrame = CFrame.new(objectPosition) * CFrame.Angles(0, math.rad(self.State.Rotation), 0);
        return;
    end
    
    local tweenInfo = TweenInfo.new(PLACEMENT_TWEEN_DURATION, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0, false, 0);

    local tween = TS:Create(self.State.CurrentPlaceable.PrimaryPart, tweenInfo, {
        CFrame = CFrame.new(objectPosition) * CFrame.Angles(0, math.rad(self.State.Rotation), 0)
    });

    tween:Play();
end

function PlacementController:GetSnappedModelCFrame(model: Model, ground: Instance, point: CFrame)
    local tileHeight: number = ground.Size.Y;
    local _, placeableSize = self.State.CurrentPlaceable:GetBoundingBox();
    
    local objectPosition = ground.Position + Vector3.new(0, (placeableSize.Y / 2) + (tileHeight / 2), 0);
    objectPosition = objectPosition + Vector3.new(0, self.State.Level * LEVEL_HEIGHT, 0);

    return CFrame.new(objectPosition) * CFrame.Angles(0, math.rad(self.State.Rotation), 0);
end

function PlacementController:Rotate()
    if (self.State.CurrentPlaceable == nil) then
        return;
    end

    self.State.Rotation = (self.State.Rotation + ROTATION_INCREMENT) % 360;
end

function PlacementController:ConfirmPlacement()
    if (self.State.CurrentPlaceable == nil) then
        return;
    end

    local plot = self.PlotController:GetPlot();

    if (plot == nil) then
        return;
    end

    local tile = self.State.Tile;

    if (tile == nil) then
        return;
    end
    
    local PlotService = Knit.GetService("PlotService");

    local passedState = {
        Rotation = self.State.Rotation,
        Level = self.State.Level,
        Tile = tile,
        Stacked = self.State.Stacked,
        StackedOn = self.State.StackedOn,
        SnappedPoint = self.State.SnappedPoint,
    }

    PlotService.PlaceOnPlot:Fire(
        self.State.OriginalIdentifier,
        passedState
    );
end

function PlacementController:SnapToClosestPoint() : boolean
    if not self.State.CurrentPlaceable then
        return false;
    end

    local plot = self.PlotController:GetPlot();
    if not plot then
        return false;
    end

    local snapPoints = self:GetAllSnapPoints(plot);
    local closestSnapPoint, closestDistance = nil, math.huge;

    for _, snapPoint in pairs(snapPoints) do
        local distance = (self.State.CurrentPlaceable.PrimaryPart.Position - snapPoint.WorldCFrame.Position).Magnitude;
        if distance < closestDistance then
            closestSnapPoint = snapPoint;
            closestDistance = distance;
        end
    end

    if closestSnapPoint and closestDistance < 5 then -- Adjust threshold as needed
        local currentCFrame = self.State.CurrentPlaceable.PrimaryPart.CFrame
        if self:IsOrientationCompatible(currentCFrame, closestSnapPoint.WorldCFrame) then

            -- calculate the new position and adjust the height

            local placeableSnappedTo = self:GetPlaceableFromAttachment(closestSnapPoint);
            
            self.State.Stacked = true;
            self.State.StackedOn = placeableSnappedTo;
            self.State.SnappedPoint = closestSnapPoint;

            self.State.Level = placeableSnappedTo:GetAttribute("Level") + 1;

            local _, placeableSize = self.State.CurrentPlaceable:GetBoundingBox();
            local objectPosition = closestSnapPoint.WorldCFrame.Position;
            objectPosition = objectPosition + Vector3.new(0, placeableSize.Y / 2, 0);
            
            self.State.CurrentPlaceable.PrimaryPart:PivotTo(CFrame.new(objectPosition) * CFrame.Angles(0, math.rad(self.State.Rotation), 0));
            
            return true;
        end
    end

    

    return false;
end

function PlacementController:GetAllSnapPoints(plot) : {Attachment}
    local snapPoints = {}
    for _, placeable in ipairs(plot.Placeables:GetChildren()) do
        for _, attachment in ipairs(placeable.PrimaryPart:GetChildren()) do
            if attachment:IsA("Attachment") and (attachment.Name:find("TopSnap") or attachment.Name:find("BottomSnap")) then
                table.insert(snapPoints, attachment)
            end
        end
    end
    return snapPoints
end

function PlacementController:GetPlaceableFromAttachment(attachment: Attachment) : Model?
    local placeable = attachment.Parent

    if placeable:IsA("Model") then
        return placeable
    end

    if placeable:IsA("BasePart") then
        return placeable.Parent
    end

    return nil
end

function PlacementController:IsOrientationCompatible(cframe1, cframe2)
    -- TODO: Implement this
    return true
end

return PlacementController;