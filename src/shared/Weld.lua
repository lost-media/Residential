local Weld = {};

function Weld.WeldPartsToPrimaryPart(model: Model)
    local primaryPart = model.PrimaryPart;
    if not primaryPart then
        warn("No primary part found in model: " .. model.Name);
        return;
    end

    for _, part in ipairs(model:GetDescendants()) do
        if part:IsA("BasePart") and part ~= primaryPart then
            local weld = Instance.new("WeldConstraint");
            weld.Name = "Weld";
            weld.Parent = primaryPart;
            weld.Part0 = primaryPart;
            weld.Part1 = part;

            part.Anchored = false;
        end
    end
end

return Weld;