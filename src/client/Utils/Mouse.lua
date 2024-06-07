--!strict

local UserInputService = game:GetService('UserInputService')
local RunService = game:GetService('RunService')
local Camera = workspace.Camera


type IMouse = {
    __index: IMouse,
    new: () -> Mouse,
	
	GetViewSize: (self: Mouse) -> Vector2,
	GetPosition: (self: Mouse) -> Vector2,
	GetUnitRay: (self: Mouse) -> Ray,
	GetOrigin: (self: Mouse) -> Vector3,
	GetDelta: (self: Mouse) -> Vector2,
	ScreenPointToRay: (self: Mouse) -> RaycastParams,
	CastRay: (self: Mouse) -> RaycastResult,
	GetHit: (self: Mouse) -> Vector3?,
	GetTarget: (self: Mouse) -> Instance?,
	GetTargetFilter: (self: Mouse) -> {Instance},
	SetTargetFilter: (self: Mouse, object: Instance | {Instance}) -> (),
	GetRayLength: (self: Mouse) -> number,
	SetRayLength: (self: Mouse, length: number) -> (),
	GetFilterType: (self: Mouse) -> Enum.RaycastFilterType,
	SetFilterType: (self: Mouse, filterType: Enum.RaycastFilterType) -> (),
	EnableIcon: (self: Mouse) -> (),
	DisableIcon: (self: Mouse) -> (),
	GetModelOfTarget: (self: Mouse) -> Model?,
	GetClosestInstanceToMouseFromParent: (self: Mouse, parent: Instance) -> Instance?,

}

export type Mouse = typeof(setmetatable({} :: {
	currentPosition: Vector2,
	previousPosition: Vector2,
	filterDescendants: {Instance},
	filterType: Enum.RaycastFilterType,
	rayLength: number,
	ticks: number,
}, {} :: IMouse))

local Mouse: IMouse = {} :: IMouse
Mouse.__index = Mouse

local function onRenderStep(mouse: Mouse)
	if (mouse.ticks % 2 == 0) then
		mouse.currentPosition = mouse:GetPosition()
	else
		mouse.previousPosition = mouse:GetPosition()
	end
	mouse.ticks = mouse.ticks % 10 + 1
end

function Mouse.new()
	local self = setmetatable({}, Mouse);
	self.filterDescendants = {};
	self.filterType = Enum.RaycastFilterType.Exclude;
	self.rayLength = 500;
	self.currentPosition = Vector2.new(0, 0);
	self.previousPosition = Vector2.new(0, 0);
	self.ticks = 1;
	
	RunService:BindToRenderStep('MeasureMouseMovement', Enum.RenderPriority.Input.Value, function(step)
		onRenderStep(self);
	end)

	return self;
end

function Mouse:GetViewSize()
	return Camera.ViewportSize
end

function Mouse:GetPosition()
	return UserInputService:GetMouseLocation()
end

function Mouse:GetUnitRay()
	local position = self:GetPosition()
	return Camera:ViewportPointToRay(position.X, position.Y)
end

function Mouse:GetOrigin()
	return self:GetUnitRay().Origin
end

function Mouse:GetDelta()
	return (self.currentPosition - self.previousPosition)
end

function Mouse:ScreenPointToRay()
	local parameters = RaycastParams.new()
	parameters.FilterDescendantsInstances = self.filterDescendants
	parameters.FilterType = self.filterType
	return parameters
end

function Mouse:CastRay()
	local parameters = self:ScreenPointToRay()
	return workspace:Raycast(self:GetOrigin(), self:GetUnitRay().Direction * self.rayLength, parameters)
end

function Mouse:GetHit()
	local raycastResult = self:CastRay()
	return raycastResult and raycastResult.Position or nil
end

function Mouse:GetTarget()
	local raycastResult = self:CastRay()
	return raycastResult and raycastResult.Instance or nil
end

function Mouse:GetTargetFilter()
	return self.filterDescendants
end

function Mouse:SetTargetFilter(object: Instance | {Instance})
	local dataType = typeof(object)
	if dataType == 'Instance' then
		self.filterDescendants = {object :: Instance}
	elseif dataType == 'table' then
		self.filterDescendants = object :: {Instance}
	else
		error('object expected an instance or a table of instances, received: '..dataType)
	end
end

function Mouse:GetRayLength()
	return self.rayLength
end

function Mouse:SetRayLength(length)
	local dataType = typeof(length)
	assert(dataType == 'number' and length >= 0, 'length expected a number, received: ' .. dataType)
	self.rayLength = length;
end

function Mouse:GetFilterType()
	return self.filterType
end

function Mouse:SetFilterType(filterType)
	local filterTypes = Enum.RaycastFilterType:GetEnumItems()
	if table.find(filterTypes, filterType) then
		self.filterType = filterType
	else
		error('Invalid raycast filter type provided')
	end
end

function Mouse:EnableIcon()
	UserInputService.MouseIconEnabled = true;
end

function Mouse:DisableIcon()
	UserInputService.MouseIconEnabled = false
end

function Mouse:GetModelOfTarget()
	local target = self:GetTarget()
	if target then
		return target:IsA('BasePart') and target:FindFirstAncestorWhichIsA('Model') or nil
	end
	return nil
end

function Mouse:GetClosestInstanceToMouseFromParent(parent: Instance)
	local hit = self:GetHit()
	if hit then
		local closestInstance = nil
		local closestDistance = math.huge
		for _, descendant in ipairs(parent:GetDescendants()) do
			if descendant:IsA('BasePart') then
				local distance = (descendant.Position - hit).Magnitude
				if distance < closestDistance then
					closestDistance = distance
					closestInstance = descendant
				end
			end
		end
		return closestInstance
	end

	return nil
end

return Mouse