-- ReplicatedStorage/Services/MoveService.luau

local RunService = game:GetService("RunService")

local MoveService = {}
MoveService.ActiveEnemies = {}
MoveService.LinearObjects = {}

-------------------------------------------------
-- WAYPOINTS (Point001, Point002, Point003...)
-------------------------------------------------
local function GetPathFromFolder(folder: Folder)
	local parts = {}

	for _, obj in ipairs(folder:GetChildren()) do
		if obj:IsA("BasePart") then
			table.insert(parts, obj)
		end
	end

	table.sort(parts, function(a, b)
		return a.Name < b.Name
	end)

	local waypoints = table.create(#parts)

	for i, p in ipairs(parts) do
		waypoints[i] = p.Position
	end

	return waypoints
end

-------------------------------------------------
-- GET MOVER (Model OR Part)
-------------------------------------------------
local function GetMover(instance: Instance)
	if instance:IsA("Model") then
		if not instance.PrimaryPart then
			warn(instance.Name .. " has no PrimaryPart set")
			return nil
		end
		return instance, true
	elseif instance:IsA("BasePart") then
		return instance, false
	end

	return nil
end

-------------------------------------------------
-- POSITION ONLY (NO ROTATION CHANGE)
-------------------------------------------------
local function SetPositionOnly(obj, isModel, position)
	if isModel then
		local pivot = obj:GetPivot()
		local rotation = pivot - pivot.Position
		obj:PivotTo(CFrame.new(position) * rotation)
	else
		local rotation = obj.CFrame - obj.Position
		obj.CFrame = CFrame.new(position) * rotation
	end
end

-------------------------------------------------
-- POSITION + DIRECTION (NEW)
-------------------------------------------------
local function SetPositionAndDirection(obj, isModel, position, direction)
	local lookCFrame = CFrame.lookAt(position, position + direction)

	if isModel then
		obj:PivotTo(lookCFrame)
	else
		obj.CFrame = lookCFrame
	end
end

-------------------------------------------------
-- WAYPOINT MOVEMENT
-------------------------------------------------
function MoveService.MoveEnemy(
	enemy: Instance,
	pathSource: Folder | {Vector3},
	speed: number,
	onReached: (() -> ())?
)
	local mover, isModel = GetMover(enemy)
	if not mover then return end

	local path

	if typeof(pathSource) == "Instance" and pathSource:IsA("Folder") then
		path = GetPathFromFolder(pathSource)
	elseif typeof(pathSource) == "table" then
		path = pathSource
	else
		warn("Invalid path input")
		return
	end

	if #path < 2 then
		warn("Path needs at least 2 waypoints")
		return
	end

	MoveService.ActiveEnemies[enemy] = {
		Mover = mover,
		IsModel = isModel,
		Path = path,
		Speed = speed,
		Index = 1,
		Traveled = 0,
		Callback = onReached,
	}

	SetPositionOnly(mover, isModel, path[1])
end

-------------------------------------------------
-- LINEAR MOVEMENT (ROTATION INCLUDED)
-------------------------------------------------
function MoveService.MoveLinear(
	obj: Instance,
	origin: Vector3,
	direction: Vector3,
	speed: number,
	onFinish: (() -> ())?,
	lifeTime: number?
)
	local mover, isModel = GetMover(obj)
	if not mover then return end

	if direction.Magnitude == 0 then
		warn("Direction cannot be zero")
		return
	end

	local dir = direction.Unit

	-- start position + rotation
	SetPositionAndDirection(mover, isModel, origin, dir)

	MoveService.LinearObjects[obj] = {
		Mover = mover,
		IsModel = isModel,
		Direction = dir,
		Speed = speed,
		Callback = onFinish,
		Time = 0,
		MaxTime = lifeTime or 3
	}
end

-------------------------------------------------
-- STOP FUNCTIONS
-------------------------------------------------
function MoveService.StopEnemy(enemy: Instance)
	MoveService.ActiveEnemies[enemy] = nil
end

function MoveService.StopLinear(obj: Instance)
	MoveService.LinearObjects[obj] = nil
end

function MoveService.StopAll()
	table.clear(MoveService.ActiveEnemies)
	table.clear(MoveService.LinearObjects)
end

-------------------------------------------------
-- HEARTBEAT UPDATE
-------------------------------------------------
RunService.Heartbeat:Connect(function(dt)

	-- WAYPOINT MOVEMENT
	for enemy, data in pairs(MoveService.ActiveEnemies) do
		local mover = data.Mover

		if not mover or not mover.Parent then
			MoveService.ActiveEnemies[enemy] = nil
			continue
		end

		if data.Index >= #data.Path then
			MoveService.ActiveEnemies[enemy] = nil
			continue
		end

		local start = data.Path[data.Index]
		local goal = data.Path[data.Index + 1]

		local diff = goal - start
		local dist = diff.Magnitude
		local dir = diff.Unit

		data.Traveled += data.Speed * dt

		if data.Traveled >= dist then
			SetPositionOnly(mover, data.IsModel, goal)

			data.Index += 1
			data.Traveled = 0

			if data.Index >= #data.Path then
				if data.Callback then
					data.Callback(enemy)
				end
				MoveService.ActiveEnemies[enemy] = nil
			end
		else
			local pos = start + dir * data.Traveled
			SetPositionOnly(mover, data.IsModel, pos)
		end
	end

	-- LINEAR MOVEMENT (WITH ROTATION)
	for obj, data in pairs(MoveService.LinearObjects) do
		local mover = data.Mover

		if not mover or not mover.Parent then
			MoveService.LinearObjects[obj] = nil
			continue
		end

		data.Time += dt

		if data.Time >= data.MaxTime then
			if data.Callback then
				data.Callback(obj)
			end
			MoveService.LinearObjects[obj] = nil
			continue
		end

		local currentPos
		if data.IsModel then
			currentPos = mover:GetPivot().Position
		else
			currentPos = mover.Position
		end

		local newPos = currentPos + (data.Direction * data.Speed * dt)

		-- 🔥 move + rotate
		SetPositionAndDirection(mover, data.IsModel, newPos, data.Direction)
	end
end)

return MoveService