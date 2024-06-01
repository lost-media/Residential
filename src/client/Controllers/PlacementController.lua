--!strict

local RS = game:GetService("ReplicatedStorage");
local TS = game:GetService("TweenService");

local Placeables: Folder = RS.Placeables;
local ClientUtils: Folder = script.Parent.Parent.Utils;

local Knit = require(RS.Packages.Knit);
local InstanceUtils = require(ClientUtils.InstanceUtils)
local Mouse = require(ClientUtils.Mouse);

local PlacementController = Knit.CreateController {
    Name = "PlacementController";

    State = {
        Placing = false;
        CurrentPlaceable = nil;
        OriginalPlaceable = nil;
    };
};

function PlacementController:KnitInit()
    print("PlacementController initialized");

    self.Mouse = Mouse.new();

    -- Set the filter descendants
    self.Mouse:SetFilterType(Enum.RaycastFilterType.Include);
    self.Mouse:SetTargetFilter(workspace.Plots);
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

    self.State.Placing = true;
    self.State.OriginalPlaceable = placeable;

    -- Clone the placeable model
    local clone = placeable:Clone();
    self.State.CurrentPlaceable = clone;

    clone.Parent = workspace.Debris;

    -- Dim the model
    InstanceUtils:dimModel(clone);
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

    -- Raycast to the ground
    local target = self.Mouse:GetTarget();

    print(target)

    if (target == nil) then
        return;
    end

    -- Get the position of the target


    -- Position the placeable
    --[[

        Calculate the position of the target by
        getting the height of the target and
        adding the height of the placeable
    ]]--

    local targetHeight = target.Position.Y;
    local placeableHeight = self.State.CurrentPlaceable.PrimaryPart.Size.Y / 2;
    local targetPosition = Vector3.new(target.Position.X, targetHeight + placeableHeight, target.Position.Z);
    
    -- Tween the placeable's position
    local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0, false, 0);

    local tween = TS:Create(self.State.CurrentPlaceable.PrimaryPart, tweenInfo, {
        CFrame = CFrame.new(targetPosition);
    });

    tween:Play();
end

return PlacementController;