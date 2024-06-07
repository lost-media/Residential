local RS = game:GetService("ReplicatedStorage");
local ServerUtil: Folder = script.Parent.Parent.Utils;
local Placeables: Folder = RS.Structures;

local StructuresModule = require(RS.Shared.Structures);
local StructuresUtils = require(RS.Shared.Structures.Utils);
local Knit = require(RS.Packages.Knit);
local Weld = require(RS.Shared.Weld);
local PlaceableType = require(RS.Shared.Enums.PlaceableType);

local PlaceableService = Knit.CreateService {
    Name = "PlaceableService";
    Client = {};

    Placeables = {};
};

function PlaceableService:KnitInit()
    print("PlaceableService initialized");

    -- Weld all models in each subfolder of Placeables

    for _, folder in ipairs(Placeables:GetChildren()) do
        for _, model in ipairs(folder:GetChildren()) do
            Weld.WeldPartsToPrimaryPart(model);
        end
    end

    print("PlaceableService: Welded all models in Placeables");

    -- Store all models in Placeables in PlaceableService.Placeables

    for _, folder in ipairs(Placeables:GetChildren()) do

        if (self:PlaceableTypeIsValid(folder.Name) == false) then
            warn("Invalid placeable type: " .. folder.Name);
            continue;
        end

        if (PlaceableService.Placeables[folder.Name] == nil) then
            PlaceableService.Placeables[folder.Name] = {};
        end

        for _, model in ipairs(folder:GetChildren()) do
            local id = StructuresUtils.GetIdFromStructure(model);
            if (id == nil) then
                warn("PlaceableService: Invalid ID for model: " .. model.Name);
                continue;
            end

            model:SetAttribute("Id", id);
            table.insert(PlaceableService.Placeables[folder.Name], model);
        end
    end
end

function PlaceableService:KnitStart()
    print("PlaceableService started");
end

function PlaceableService:PlaceableTypeIsValid(placeableType: string) : boolean
    for _, enum in pairs(PlaceableType) do
        if (enum.name == placeableType) then
            return true;
        end
    end

    return false;
end

function PlaceableService:GetPlaceable(id: string)
    return StructuresModule.GetPlaceableFromId(id);
end

function PlaceableService:CreatePlaceableFromIdentifier(identifier: string) : Model?
    local model =  StructuresModule.GetPlaceableFromId(identifier);

    if (model == nil) then
        warn("PlaceableService: Invalid identifier: " .. identifier);
        return nil;
    end

    return model.Model:Clone()
end

return PlaceableService;