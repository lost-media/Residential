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
            instance.Transparency = 1 - (1 - instance.Transparency) / TRANSPARENCY_DIM_FACTOR
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
            instance.Transparency = 1 - (1 - instance.Transparency) * TRANSPARENCY_DIM_FACTOR
        end
    end

    -- Erase the Dimmed attribute
    model:SetAttribute("Dimmed", nil)
end

function InstanceUtils:uncollideModel(model: Model)
    for _, instance in ipairs(model:GetDescendants()) do
        if (instance:IsA("BasePart")) then
            instance.CanCollide = false
        end
    end
end

function InstanceUtils:getClosestInstance(instances: {BasePart}, position: Vector3) : BasePart?
    local closestInstance: BasePart? = nil
    local closestDistance: number = math.huge

    for _, instance in ipairs(instances) do
        local distance = (instance.Position - position).Magnitude

        if (distance < closestDistance) then
            closestInstance = instance
            closestDistance = distance
        end
    end

    return closestInstance
end

function InstanceUtils:getRandomInstance(instances: {BasePart}?) : BasePart?
    if (instances == nil) then
        return nil
    end
    
    if (#instances == 0) then
        return nil
    end

    return instances[math.random(1, #instances)]
end



return InstanceUtils