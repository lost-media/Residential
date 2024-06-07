local StructuresUtils = {}

local StructuresCollection = require(script.Parent);

function StructuresUtils.ParseStructureId(structureId: string)
    local split = string.split(structureId, "/");

    if (#split < 2) then
        warn("Invalid structureId");
        return;
    end

    return split[1], split[2];
end

function StructuresUtils.GetStructureFromId(structureId: string)
    local structureType, structureName = StructuresUtils.ParseStructureId(structureId);
    local structure = StructuresCollection[structureType][structureName];

    if (structure == nil) then
        warn("Structure not found");
        return;
    end

    return structure;
end

function StructuresUtils.GetStructureModelFromId(structureId: string) : Model?
    local structureType, structureName = StructuresUtils.ParseStructureId(structureId);

    if (structureType == nil or structureName == nil) then
        return;
    end

    return StructuresCollection[structureType][structureName].Model;
end

function StructuresUtils.GetIdFromStructure(structure: Model) : string?
    for structureType, structureCollection in pairs(StructuresCollection) do
        for structureName, structureData in pairs(structureCollection) do
            if (structureData.Model == structure) then
                return structureData.Id;
            end
        end
    end

    return nil;
end

function StructuresUtils.IsStructureStackable(structureId: string) : boolean
    local structure = StructuresUtils.GetStructureFromId(structureId);

    if (structure == nil) then
        return false;
    end

    return structure.Stacking ~= nil;
end

function StructuresUtils.CanStackStructureWith(structureId: string, otherStructureId: string) : boolean
    local structure = StructuresUtils.GetStructureFromId(structureId);

    if (structure == nil) then
        return false;
    end

    if (structure.Stacking == nil) then
        return false;
    end

    if (structure.Stacking.Allowed == false) then
        return false;
    end

    if (structure.Stacking.AllowedModels == nil) then
        return false;
    end

    return structure.Stacking.AllowedModels[otherStructureId] ~= nil;
end

return StructuresUtils