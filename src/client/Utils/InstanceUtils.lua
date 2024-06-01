--!strict

local InstanceUtils = {}

local TRANSPARENCY_DIM_FACTOR = 2

function InstanceUtils:dimModel(model: Model)
    -- If the model is already dimmed, no need to dim it again
    if (model:GetAttribute("Dimmed") == true) then
        return;
    end

    for _, instance in ipairs(model:GetDescendants()) do
        if (instance:IsA("BasePart")) then
            instance.Transparency /= TRANSPARENCY_DIM_FACTOR
        end
    end

    model:SetAttribute("Dimmed", true)
end

function InstanceUtils:undimModel(model: Model)
    -- If the model is not dimmed, no need to undim it
    if (model:GetAttribute("Dimmed") ~= true) then
        return;
    end

    for _, instance in ipairs(model:GetDescendants()) do
        if (instance:IsA("BasePart")) then
            instance.Transparency *= TRANSPARENCY_DIM_FACTOR
        end
    end

    -- Erase the Dimmed attribute
    model:SetAttribute("Dimmed", nil)
end



return InstanceUtils