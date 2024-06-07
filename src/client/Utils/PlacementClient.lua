--!strict

local RS = game:GetService("ReplicatedStorage");
local TweenService = game:GetService("TweenService");
local RunService = game:GetService("RunService");
local UIS = game:GetService("UserInputService");

local State = require(RS.Shared.Types.PlacementState);
local Plot = require(RS.Shared.Types.Plot);
local Mouse = require(script.Parent.Parent.Utils.Mouse);
local StructuresUtils = require(RS.Shared.Structures.Utils);
local Signal = require(RS.Packages.Signal);

-- Constants
local LEVEL_HEIGHT = 8;
local ROTATION_STEP = 90;
local TRANSPARENCY_DIM_FACTOR = 2;
local TWEEN_INFO = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0);

type IPlacementClient = {
    __index: IPlacementClient,
    new: (plot: Plot.Plot) -> PlacementClient,

    GetMouse: (self: PlacementClient) -> Mouse.Mouse,
    Update: (self: PlacementClient, deltaTime: number) -> (),
    Destroy: (self: PlacementClient) -> (),
    StartPlacement: (self: PlacementClient, structureId: string) -> (),
    StopPlacement: (self: PlacementClient) -> (),
    GenerateGhostStructureFromId: (self: PlacementClient, structureId: string) -> Model,
    PartIsTile: (self: PlacementClient, part: BasePart) -> boolean,
    PartIsFromStructure: (self: PlacementClient, part: BasePart) -> boolean,
    GetTileFromName: (self: PlacementClient, name: string) -> BasePart?,
    GetStructureFromPart: (self: PlacementClient, part: BasePart) -> Model?,
    SnapToTile: (self: PlacementClient, tile: BasePart) -> (),
    SnapToAttachment: (self: PlacementClient, attachment: Attachment) -> (),
    MoveModelToCF: (self: PlacementClient, model: Model, cframe: CFrame, instant: boolean) -> (),
    Rotate: (self: PlacementClient) -> (),
    GetAttachmentsFromStructure: (self: PlacementClient, model: Model) -> {Attachment},
    GetAllAttachmentsFromPlot: (self: PlacementClient, tile: BasePart) -> {Attachment},
    
}

export type PlacementClient = typeof(setmetatable({} :: {
    mouse: Mouse.Mouse,
    plot: Plot.Plot,
    state: ClientState,
    onRenderStep: RBXScriptConnection,
    signals: {
        OnPlacementStarted: Signal.Signal,
        OnPlacementEnded: Signal.Signal,
        OnTileChanged: Signal.Signal,
        OnRotate: Signal.Signal,
        OnStructureHover: Signal.Signal,
        OnStacked: Signal.Signal,
        OnStackedAttachmentChanged: Signal.Signal,
    },
    structureCollectionEntry: table,

}, {} :: IPlacementClient))

type ClientState = {
    isPlacing: boolean,
    canConfirmPlacement: boolean,

    structureId: string?,
    ghostStructure: Model?,
    tile: BasePart?,

    rotation: number,
    level: number,

    mountedAttachment: Attachment,
    attachments: {Attachment},
    stackedStructure: Model,

    isStacked: boolean,
}

local function dimModel(model: Model)
    -- If the model is already dimmed, no need to dim it again
    if (model:GetAttribute("Dimmed") == true) then
        return;
    end

    for _, instance in ipairs(model:GetDescendants()) do
        if (instance:IsA("BasePart")) then
            instance.Transparency = 1 - (1 - instance.Transparency) / TRANSPARENCY_DIM_FACTOR
        end
    end

    model:SetAttribute("Dimmed", true)
end

local function uncollideModel(model: Model)
    for _, instance in ipairs(model:GetDescendants()) do
        if (instance:IsA("BasePart")) then
            instance.CanCollide = false;
        end
    end
end

local PlacementClient = {};
PlacementClient.__index = PlacementClient;


function PlacementClient.new(plot: Plot.Plot)

    -- Validate the plot before creating the PlacementClient instance
    if (Plot.isPlotValid(plot) == false) then
        error("Plot is invalid");
    end

    local self = setmetatable({}, PlacementClient);

    self.mouse = Mouse.new();
    self.mouse:SetFilterType(Enum.RaycastFilterType.Exclude);
    self.mouse:SetTargetFilter({

    });

    self.plot = plot;

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

    -- Signals
    self.signals = {
        OnPlacementStarted = Signal.new(),
        OnPlacementEnded = Signal.new(),
        OnTileChanged = Signal.new(),
        OnRotate = Signal.new(),
        OnStructureHover = Signal.new(),
        OnStacked = Signal.new(),
        OnStackedAttachmentChanged = Signal.new(),
    };


    
    return self;
end

function PlacementClient:GenerateGhostStructureFromId(structureId: string)
    local structure = StructuresUtils.GetStructureModelFromId(structureId);

    if (structure == nil) then
        warn("Structure not found");
        return;
    end

    local ghostStructure = structure:Clone();
    ghostStructure.Parent = workspace;

    self.highlightInstance = self:MakeHighlight(ghostStructure);
    self.selectionBox = self:MakeSelectionBox(ghostStructure);

    self.state.ghostStructure = ghostStructure;
    --dimModel(ghostStructure);
    uncollideModel(ghostStructure);
    
    return ghostStructure;
end

function PlacementClient:StartPlacement(structureId: string)
    self.state.isPlacing = true;
    self.state.structureId = structureId;

    self.structureCollectionEntry = StructuresUtils.GetStructureFromId(structureId);

    if (self.structureCollectionEntry == nil) then
        warn("Structure not found");
        return;
    end

    local model = self:GenerateGhostStructureFromId(structureId);

    -- Set up render stepped
    self.onRenderStep = RunService.RenderStepped:Connect(function(dt: number)
        self:Update(dt);
    end);

    self.onInputBegan = UIS.InputBegan:Connect(function(input: InputObject)
        if (input.KeyCode == Enum.KeyCode.R) then
            self:Rotate();
        end
    end);

    self.signals.OnPlacementStarted:Fire();
end

function PlacementClient:MakeHighlight(instance: Instance)
    local highlight = Instance.new("Highlight");
    highlight.Parent = instance;
    highlight.FillColor = Color3.fromRGB(0, 255, 0);
    highlight.FillTransparency = 0.5;
    highlight.Adornee = instance;

    return highlight;
end

function PlacementClient:MakeSelectionBox(instance: Instance)
    local selectionBox = Instance.new("SelectionBox");
    selectionBox.Parent = instance;
    selectionBox.Color3 = Color3.fromRGB(0, 255, 0);
    selectionBox.LineThickness = 0.05;
    selectionBox.Adornee = instance;

    return selectionBox;
end

function PlacementClient:StopPlacement()
    self.state.isPlacing = false;
    self.onRenderStep:Disconnect();
end

function PlacementClient:GetMouse()
    return self.mouse;
end

function PlacementClient:PartIsTile(part: BasePart)
    return part:IsA("Part") and part:IsDescendantOf(self.plot.Tiles);
end

function PlacementClient:PartIsFromStructure(part: BasePart)
    if (part == nil) then
        return false;
    end

    if (part:IsA("Part") == false) then
        return false;
    end

    if (part:IsDescendantOf(self.plot.Structures) == false) then
        return false;
    end

    local structure: Model? = part:FindFirstAncestorWhichIsA("Model");
    if (structure == nil) then
        return false;
    end

    if (structure:GetAttribute("Id") == nil) then
        return false;
    end

    if (structure:GetAttribute("Tile") == nil) then
        return false;
    end

    if (self:GetTileFromName(structure:GetAttribute("Tile")) == nil) then
        return false;
    end

    return true;
end

function PlacementClient:GetTileFromName(name: string)
    return self.plot.Tiles:FindFirstChild(name);
end

function PlacementClient:GetStructureFromPart(part: BasePart)
    if (self:PartIsFromStructure(part) == false) then
        return nil;
    end

    local structure: Model? = part:FindFirstAncestorWhichIsA("Model");
    return structure;
end

function PlacementClient:Update(deltaTime: number)
    -- If the player is not placing a structure, return
    if (not self.state.isPlacing) then
        return;
    end

    local mouse: Mouse.Mouse = self.mouse;

    -- Get the closest base part to the hit position
    local closestInstance = mouse:GetClosestInstanceToMouseFromParent(self.plot);

    if (closestInstance == nil) then
        return;
    end

    -- Check if its a tile
    if (self:PartIsTile(closestInstance) == true) then
        self:AttemptToSnapToTile(closestInstance);
    else
        self:AttemptToSnapToAttachment(closestInstance);
    end

    self:UpdatePosition();
    self:UpdateHighlight();
end

function PlacementClient:AttemptToSnapToTile(closestInstance: BasePart)
    local currentTile = self.state.tile;
    if (currentTile == nil or currentTile ~= closestInstance) then
        self.state.tile = closestInstance;
        self.signals.OnTileChanged:Fire(closestInstance);
    end

    self:RemoveStacked();

    -- Snap the ghost structure to the tile
    self.state.canConfirmPlacement = true;
end

function PlacementClient:AttemptToSnapToAttachment(closestInstance: BasePart)
    local mouse: Mouse.Mouse = self.mouse;

    -- Check if the part is from a structure
    if (self:PartIsFromStructure(closestInstance) == true) then
        local structure: Model = self:GetStructureFromPart(closestInstance);
        if (structure == nil) then
            self.signals.OnStructureHover:Fire(nil);
            self:RemoveStacked();
            
            return;
        end

        local structureId = structure:GetAttribute("Id");
        local structureTile = self:GetTileFromName(structure:GetAttribute("Tile"));

        self.signals.OnStructureHover:Fire(structure);

        -- Determine if the structure is stackable
        local isStackable = StructuresUtils.CanStackStructureWith(structureId, self.state.structureId);

        if (isStackable == false) then
            -- If the structure is not stackable, then just snap to the structures tile
            self:RemoveStacked();
            
            -- Error if the structure is already occupied
            self.state.canConfirmPlacement = false;
        else
            -- get the attachments of the structure
            local whitelistedSnapPoints = StructuresUtils.GetStackingWhitelistedSnapPointsWith(structureId, self.state.structureId);
            
            if (whitelistedSnapPoints ~= nil) then
                whitelistedSnapPoints = self:GetAttachmentsFromStringList(whitelistedSnapPoints);
            else
                whitelistedSnapPoints = {};
            end

            local attachments = (#whitelistedSnapPoints > 0) and whitelistedSnapPoints or self:GetAttachmentsFromStructure(structure);
            
            -- Get the closest attachment to the mouse
            local closestAttachment = mouse:GetClosestAttachmentToMouse(attachments);
            
            if (closestAttachment == nil) then
                self:RemoveStacked();
                return;
            end

            -- check if the attachment is occupied

            if (closestAttachment:GetAttribute("Occupied") == true) then
                self:RemoveStacked();
                return;
            end

            if (self.state.isStacked == false) then
                self.signals.OnStacked:Fire(structure, closestAttachment);
            end

            self.state.isStacked = true;

            local attachmentPointToSnapTo = StructuresUtils.GetMountedAttachmentPointFromStructures(structure, self.state.structureId, closestAttachment);
            
            if (attachmentPointToSnapTo == nil) then
                self:RemoveStacked();
                --dwdwself.state.canConfirmPlacement = false;
                return;
            end

            if (self.state.mountedAttachment == nil or self.state.mountedAttachment ~= attachmentPointToSnapTo) then
                self.signals.OnStackedAttachmentChanged:Fire(attachmentPointToSnapTo, self.state.mountedAttachment);
            end

            self.state.attachments = attachments;
            self.state.mountedAttachment = attachmentPointToSnapTo;
            self.state.stackedStructure = structure;
            self.state.tile = structureTile;

            self.signals.OnTileChanged:Fire(structureTile);

            self.state.canConfirmPlacement = true;
            
            --self:SnapToAttachment(attachmentPointToSnapTo);
        end

    else
        self.signals.OnStructureHover:Fire(nil);
        self:RemoveStacked();
        self.state.canConfirmPlacement = false;
    end
end

function PlacementClient:GetAttachmentsFromStringList(attachments: {string}?) : {Attachment}
    if (attachments == nil) then
        return {};
    end

    if (self.state.stackedStructure == nil) then
        return {};
    end
    
    local attachmentInstances = {};

    for _, attachmentName in ipairs(attachments) do
        local attachment = self.state.stackedStructure.PrimaryPart:FindFirstChild(attachmentName);
        if (attachment ~= nil) then
            table.insert(attachmentInstances, attachment);
        end
    end

    return attachmentInstances;
end

function PlacementClient:RemoveStacked()
    self.state.isStacked = false;
    self.state.mountedAttachment = nil;
    self.state.attachments = {};
    self.state.stackedStructure = nil;
end

function PlacementClient:UpdatePosition()
    -- Completely state dependent
    if (self.state.isStacked) then
        self:SnapToAttachment(self.state.mountedAttachment, self.state.tile);
    else
        self:SnapToTile(self.state.tile);
    end
end

function PlacementClient:UpdateHighlight()
    if (self.state.ghostStructure == nil) then
        return;
    end

    if (self.state.highlightInstance == nil) then
        self.state.highlightInstance = self:MakeHighlight(self.state.ghostStructure);
    end

    if (self.state.canConfirmPlacement == true) then
        self.state.highlightInstance.FillColor = Color3.fromRGB(0, 255, 0);
    else
        self.state.highlightInstance.FillColor = Color3.fromRGB(255, 0, 0);
    end
end

function PlacementClient:SnapToTile(tile: BasePart)
    local ghostStructure = self.state.ghostStructure;

    if (ghostStructure == nil) then
        return;
    end

    local tileHeight = tile.Size.Y;

    local pos = tile.Position + Vector3.new(0, tileHeight / 2 + .5, 0);
    local newCFrame = CFrame.new(pos);
    newCFrame = newCFrame * CFrame.Angles(0, math.rad(self.state.rotation), 0);
    newCFrame = newCFrame * CFrame.new(0, self.state.level * LEVEL_HEIGHT, 0);
    
    self:MoveModelToCF(ghostStructure, newCFrame, false);
end

function PlacementClient:SnapToAttachment(attachment: Attachment, tile: BasePart)
    local ghostStructure = self.state.ghostStructure;

    if (ghostStructure == nil) then
        return;
    end

    if (self.structureCollectionEntry == nil) then
        return;
    end

    local _, ghostStructureSize = ghostStructure:GetBoundingBox();
    local tileHeight = tile.Size.Y;
    
    if (self.structureCollectionEntry.FullArea == false) then
        tileHeight = tileHeight / 2;
    end

    local pos = attachment.WorldPosition;
    local yVal = (tile.Position + Vector3.new(0, tileHeight, 0)).Y;

    if (self.structureCollectionEntry.FullArea == false) then
        yVal = pos.Y + tileHeight;
    end

    pos = Vector3.new(pos.X, yVal, pos.Z);

    local newCFrame = CFrame.new(pos)
    newCFrame = newCFrame * CFrame.Angles(0, math.rad(self.state.rotation), 0);
    newCFrame = newCFrame * CFrame.new(0, self.state.level * LEVEL_HEIGHT, 0);
    self:MoveModelToCF(ghostStructure, newCFrame, false);
end

function PlacementClient:MoveModelToCF(model: Model, cframe: CFrame, instant: boolean)
    if (instant) then
        model:PivotTo(cframe);
    else
        local tween = TweenService:Create(model.PrimaryPart, TWEEN_INFO, {CFrame = cframe});
        tween:Play();
    end
end

function PlacementClient:Rotate()
    self.state.rotation = self.state.rotation + ROTATION_STEP;
    if (self.state.rotation >= 360) then
        self.state.rotation = 0;
    end

    self.signals.OnRotate:Fire(self.state.rotation);
end

function PlacementClient:GetAttachmentsFromStructure(model: Model)
    local attachments = {};

    for _, instance in ipairs(model:GetDescendants()) do
        if (instance:IsA("Attachment")) then
            table.insert(attachments, instance);
        end
    end

    return attachments;
end

function PlacementClient:GetAllAttachmentsFromPlot(tile: BasePart)
    local attachments = {};

    for _, structure in ipairs(self.plot.Structures:GetChildren()) do
        if (structure:IsA("Model")) then
            if (structure:GetAttribute("Tile") == tile.Name) then
                for _, attachment in ipairs(self:GetAttachmentsFromStructure(structure)) do
                    table.insert(attachments, attachment);
                end
            end
        end
    end

    return attachments;
end

function PlacementClient:Destroy()
    self.onRenderStep:Disconnect();
end

return PlacementClient;