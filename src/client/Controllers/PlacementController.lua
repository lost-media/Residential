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

local PLACEMENT_TWEEN_DURATION = 0.05;
local ROTATION_INCREMENT = 90;
local LEVEL_HEIGHT = 6; -- The height of each level for stacking in studs
local LEVEL_MAX = 5;
local SNAPPING_THRESHOLD = 8;
local STARTING_PLACEABLE = "Road/Elevated Road";
local PLACEABLE_CYCLE = {
    "Road/Elevated Road",
    "Road/Streetlight",
    "Road/Stoplight",
}

local PlacementController = Knit.CreateController {
    Name = "PlacementController";

    State = {
        CanPlace = false;
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
        SnappedPointsTaken = {};
    };

    CycleNum = 1;
    Plot = nil;
    SelectionBox = nil;
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
                self:StartPlacing(STARTING_PLACEABLE);
            end
        elseif (input.KeyCode == Enum.KeyCode.R) then
            self:Rotate();
        elseif (input.KeyCode == Enum.KeyCode.E) then
            self.CycleNum += 1;
            if (self.CycleNum > #PLACEABLE_CYCLE) then
                self.CycleNum = 1;
            end

            self:StopPlacing();
            self:StartPlacing(PLACEABLE_CYCLE[self.CycleNum]);
        elseif (input.KeyCode == Enum.KeyCode.Q) then
            self.CycleNum -= 1;
            if (self.CycleNum < 1) then
                self.CycleNum = #PLACEABLE_CYCLE;
            end
            self:StopPlacing();
            self:StartPlacing(PLACEABLE_CYCLE[self.CycleNum]);
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

    local boundingBox = Instance.new("SelectionBox");
    boundingBox.Color3 = Color3.fromRGB(0, 255, 0);
    boundingBox.LineThickness = 0.1;
    boundingBox.Adornee = clone.PrimaryPart;
    boundingBox.Parent = clone.PrimaryPart;

    self.SelectionBox = boundingBox;

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
    self.State.OriginalIdentifier = nil;
    self.State.Tile = nil;
    self.State.Level = 0;
    self.State.Stacked = false;
    self.State.StackedOn = nil;
    self.State.SnappedPoint = nil;
    self.State.SnappedPointsTaken = {};

    if self.SelectionBox then
        self.SelectionBox:Destroy();
    end

    self.SelectionBox = nil;

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

    if (closestTile == nil) then
        return;
    end

    if (self.State.CurrentPlaceable == nil) then
        return;
    end

    if (self.State.CanPlace == false) then
        self.SelectionBox.Color3 = Color3.fromRGB(255, 0, 0);
    else
        self.SelectionBox.Color3 = Color3.fromRGB(0, 255, 0);
    end

    local snapped = self:SnapToClosestPoint();
    if (snapped == false) then

        -- Check if the tile is occupied
        if (closestTile:GetAttribute("Occupied") == true) then
            return;
        end

        self:MovePlaceableToTile(closestTile);

        self.State.Level = 0;
        self.State.Stacked = false;
        self.State.StackedOn = nil;
        self.State.SnappedPoint = nil;
        
    end

    if (closestTile:GetAttribute("Occupied") == true) then
        return;
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

    self.State.CanPlace = true;

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
        SnappedPointsTaken = self.State.SnappedPointsTaken,
    }

    PlotService.PlaceOnPlot:Fire(
        self.State.OriginalIdentifier,
        passedState
    )
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

    local MousePosition = self.Mouse:GetHit();

    if MousePosition == nil then
        return false;
    end

    for _, snapPoint in pairs(snapPoints) do
        local distance = (snapPoint.WorldCFrame.Position - MousePosition).Magnitude;
        
        if (snapPoint:GetAttribute("Occupied") == true) then
            continue;
        end

        if distance < closestDistance then
            closestSnapPoint = snapPoint;
            closestDistance = distance;
        end
    end

    if closestSnapPoint and closestDistance < SNAPPING_THRESHOLD then
        local currentCFrame = self.State.CurrentPlaceable.PrimaryPart.CFrame
        -- Make sure that there is a top snap point that has the same position as the closest snap point

        -- get the placeable that the snap point is attached to
        local placeable = self:GetPlaceableFromAttachment(closestSnapPoint);
        if not placeable then
            return false;
        end

        local id = placeable:GetAttribute("Id");
        if id == nil then
            return false;
        end

        -- check if the orientation is strict for the placeable
        local placeableItem = PlaceablesModule.GetPlaceableFromId(id);

        if not placeableItem then
            return false;
        end

        local placeableStack = placeableItem.Stacking;

        if not placeableStack then
            return false;
        end

        if (placeableStack.Allowed ~= true) then
            return false;
        end

        local currentModelStackConfigs = placeableStack.AllowedModels[self.State.OriginalIdentifier];
        if not currentModelStackConfigs then
            return false;
        end

        -- get the snap points that the current placeable can snap to
        local currentPlaceableSnapPointsConfigs = currentModelStackConfigs.SnapPoints;

        if not currentPlaceableSnapPointsConfigs then
            return false;
        end

        local snapPointName = closestSnapPoint.Name;

        if not table.find(currentPlaceableSnapPointsConfigs, snapPointName) then
            return false;
        end

        local snapPointsTaken: {string}? = currentModelStackConfigs.SnapPointsTaken;

        local topBottomSnappingPoints = self:GetBottomSnapPoints(self.State.CurrentPlaceable);
        local stackedPlaceableTopSnappingPoints = {}

        for _, attachmentName in ipairs(currentPlaceableSnapPointsConfigs) do
            for _, attachment in ipairs(placeable.PrimaryPart:GetChildren()) do
                if attachment:IsA("Attachment") and attachment.Name == attachmentName then
                    table.insert(stackedPlaceableTopSnappingPoints, attachment);
                end
            end
        end

        -- Make sure each one of SnapPointsTaken is not occupied
        
        local pointsTaken = {}

        if snapPointsTaken then
            for _, snapPointTaken in ipairs(snapPointsTaken) do
                for _, attachment in ipairs(placeable.PrimaryPart:GetChildren()) do
                    if attachment:IsA("Attachment") and attachment.Name == snapPointTaken then
                        if (attachment:GetAttribute("Occupied") == true) then
                            return false;
                        end
                        table.insert(pointsTaken, attachment);
                    end
                end
            end
        else
            pointsTaken = {closestSnapPoint}
        end

        if (currentModelStackConfigs.OrientationStrict == true and self:IsOrientationCompatible(topBottomSnappingPoints, stackedPlaceableTopSnappingPoints)  or currentModelStackConfigs.OrientationStrict == false) then

            -- calculate the new position and adjust the height

            local placeableSnappedTo = self:GetPlaceableFromAttachment(closestSnapPoint);
            
            self.State.Stacked = true;
            self.State.StackedOn = placeableSnappedTo;
            self.State.SnappedPoint = closestSnapPoint;

            self.State.Level = placeableSnappedTo:GetAttribute("Level") + 1;

            local _, placeableSize = self.State.CurrentPlaceable:GetBoundingBox();


            local mountingPoint: Attachment? = nil
            if (currentModelStackConfigs.MountingPoint) then
                mountingPoint = placeableSnappedTo.PrimaryPart:FindFirstChild(currentModelStackConfigs.MountingPoint);
            end

            if (mountingPoint == nil) then
                mountingPoint = closestSnapPoint
            end

            self.State.SnappedPoint = mountingPoint;
            self.State.SnappedPointsTaken = pointsTaken;

            local objectPosition = mountingPoint.WorldCFrame.Position;
            objectPosition = objectPosition + Vector3.new(0, placeableSize.Y / 2, 0);
                        
            local tweenInfo = TweenInfo.new(PLACEMENT_TWEEN_DURATION, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0, false, 0);

            local tween = TS:Create(self.State.CurrentPlaceable.PrimaryPart, tweenInfo, {
                CFrame = CFrame.new(objectPosition) * CFrame.Angles(0, math.rad(self.State.Rotation), 0)
            });

            tween:Play();

            return true;
        end
    end

    

    return false;
end

function PlacementController:GetAllSnapPoints(plot) : {Attachment}
    local snapPoints = {}
    for _, placeable in ipairs(plot.Placeables:GetChildren()) do
        for _, attachment in ipairs(placeable.PrimaryPart:GetChildren()) do
            if attachment:IsA("Attachment") then
                
                if (attachment:GetAttribute("Occupied") == true) then
                    continue;
                end

                table.insert(snapPoints, attachment)
            end
        end
    end
    return snapPoints
end

function PlacementController:GetBottomSnapPoints(model: Model) : {Attachment}
    local snapPoints = {}
    for _, attachment in ipairs(model.PrimaryPart:GetChildren()) do
        if attachment:IsA("Attachment") and attachment.Name:find("Bottom") then
            table.insert(snapPoints, attachment)
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

function PlacementController:IsOrientationCompatible(topPlaceableAttachments: {Attachment}, bottomPlaceableAttachments: {Attachment}) : boolean
    if #topPlaceableAttachments ~= #bottomPlaceableAttachments then
        return false
    end

    for i, topAttachment in ipairs(topPlaceableAttachments) do
        for j, bottomAttachment in ipairs(bottomPlaceableAttachments) do
            -- compare the position of the attachments
            if (topAttachment.WorldCFrame.Position - bottomAttachment.WorldCFrame.Position).Magnitude > 0.05 then
                return false
            end
        end
    end

    return true
end

return PlacementController;