local RS = game:GetService("ReplicatedStorage");

local Knit = require(RS.Packages.Knit);
local Weld = require(RS.Shared.Weld);

local Placeables: Folder = RS.Placeables;

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

    print("Welded all models in Placeables");

    -- Store all models in Placeables in PlaceableService.Placeables
    --[[

    For now, there are 4 types of Placeables:
    - Factory
    - Residence
    - Commercial
    - Road
    
    Each type of Placeable has a different set of properties, such as:
    - Factory: Production rate, production capacity, production cost, production time
    - Residence: Population, population capacity, population growth rate, population growth time
    - Commercial: Revenue, revenue capacity, revenue growth rate, revenue growth time
    - Road: Cost, speed, capacity

    --]]

    for _, folder in ipairs(Placeables:GetChildren()) do
        if (not PlaceableService.Placeables[folder.Name]) then
            PlaceableService.Placeables[folder.Name] = {};
        end

        for _, model in ipairs(folder:GetChildren()) do
            table.insert(PlaceableService.Placeables[folder.Name], model);
        end
    end
end

function PlaceableService:KnitStart()
    print("PlaceableService started");
end

return PlaceableService;