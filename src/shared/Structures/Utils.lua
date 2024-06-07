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
    local structure = StructuresCollection[structureId];

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

return StructuresUtils