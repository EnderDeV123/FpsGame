-- ReplicatedStorage/Services/MoveService.luau

-- Get RunService (used for frame updates)
local RunService = game:GetService("RunService")

-- Main module table
local MoveService = {}

-- Tables to track active moving objects
MoveService.ActiveEnemies = {} -- waypoint movement
MoveService.LinearObjects = {} -- straight line movement
MoveService.CurveObjects = {} -- bezier curve movement
MoveService.Projectiles = {} -- physics projectiles

-------------------------------------------------
-- WAYPOINTS
-------------------------------------------------
-- Converts a folder of parts into an ordered list of positions
local function GetPathFromFolder(folder)
	local parts = {}

	-- Collect all BaseParts inside folder
	for _, obj in ipairs(folder:GetChildren()) do
		if obj:IsA("BasePart") then
			table.insert(parts, obj)
		end
	end

	-- Sort parts by name (IMPORTANT: determines path order)
	table.sort(parts, function(a, b)
		return a.Name < b.Name
	end)

	-- Convert parts into position array
	local waypoints = table.create(#parts)
	for i, p in ipairs(parts) do
		waypoints[i] = p.Position
	end

	return waypoints
end

-------------------------------------------------
-- GET MOVER
-------------------------------------------------
-- Determines if object is Model or Part and returns usable mover
local function GetMover(instance)
	if instance:IsA("Model") then
		-- Model MUST have PrimaryPart
		if not instance.PrimaryPart then
			warn(instance.Name .. " has no PrimaryPart")
			return nil
		end
		return instance, true -- true = model
	elseif instance:IsA("BasePart") then
		return instance, false -- false = single part
	end
	return nil
end

-------------------------------------------------
-- TRANSFORM
-------------------------------------------------
-- Applies position + rotation to object
local function ApplyTransform(obj, isModel, position, rotationCF)
	if isModel then
		-- Move entire model using Pivot
		obj:PivotTo(CFrame.new(position) * rotationCF)
	else
		-- Move single part directly
		obj.CFrame = CFrame.new(position) * rotationCF
	end
end

-------------------------------------------------
-- BEZIER
-------------------------------------------------
-- Quadratic Bezier formula (curve movement)
local function Bezier(p0, p1, p2, t)
	return (1 - t) ^ 2 * p0 + 2 * (1 - t) * t * p1 + t ^ 2 * p2
end

-------------------------------------------------
-- WAYPOINT MOVEMENT
-------------------------------------------------
-- Moves enemy along path (folder or array)
function MoveService.MoveEnemy(enemy, pathSource, speed, settings)
	local mover, isModel = GetMover(enemy)
	if not mover then
		return
	end

	-- Get path (folder OR direct array)
	local path
	if typeof(pathSource) == "Instance" then
		path = GetPathFromFolder(pathSource)
	else
		path = pathSource
	end

	if not path or #path < 2 then
		return
	end

	-- Store movement data
	MoveService.ActiveEnemies[enemy] = {
		Mover = mover,
		IsModel = isModel,
		Path = path,
		Speed = speed,
		Index = 1, -- current waypoint index
		Traveled = 0, -- distance traveled between points

		LookAt = settings and settings.LookAt,
		Spin = settings and settings.Spin or Vector3.zero,
		Callback = settings and settings.OnFinish,
	}
end

-------------------------------------------------
-- LINEAR
-------------------------------------------------
-- Moves object in straight line
function MoveService.MoveLinear(obj, origin, direction, speed, settings)
	local mover, isModel = GetMover(obj)
	if not mover then
		return
	end

	local dir = direction.Unit -- normalize direction

	-- Store movement data
	MoveService.LinearObjects[obj] = {
		Mover = mover,
		IsModel = isModel,
		Direction = dir,
		Speed = speed,

		Time = 0,
		MaxTime = settings and settings.LifeTime or 3,

		Spin = settings and settings.Spin or Vector3.zero,
		Callback = settings and settings.OnFinish,
	}

	-- Set initial position + rotation
	ApplyTransform(mover, isModel, origin, CFrame.lookAt(origin, origin + dir))
end

-------------------------------------------------
-- CURVE
-------------------------------------------------
-- Moves object along Bezier curve
function MoveService.MoveCurve(obj, p0, p1, p2, duration, settings)
	local mover, isModel = GetMover(obj)
	if not mover then
		return
	end

	MoveService.CurveObjects[obj] = {
		Mover = mover,
		IsModel = isModel,

		P0 = p0, -- start
		P1 = p1, -- control
		P2 = p2, -- end

		Time = 0,
		Duration = duration,

		LookAt = settings and settings.LookAt ~= false,
		Spin = settings and settings.Spin or Vector3.zero,

		Callback = settings and settings.OnFinish,
	}
end

-------------------------------------------------
-- PROJECTILE
-------------------------------------------------
-- Launches object with physics (gravity + velocity)
function MoveService.LaunchProjectile(obj, origin, targetOrVelocity, settings)
	local mover, isModel = GetMover(obj)
	if not mover then
		return
	end

	local gravity = settings and settings.Gravity or Vector3.new(0, -workspace.Gravity, 0)
	local velocity

	-- If using target, calculate velocity needed to hit it
	if settings and settings.UseTarget then
		local target = targetOrVelocity
		local time = settings.Time or 1

		local displacement = target - origin
		local horizontal = Vector3.new(displacement.X, 0, displacement.Z)

		-- Solve vertical velocity
		local vy = (displacement.Y - 0.5 * gravity.Y * time ^ 2) / time
		local vxz = horizontal / time

		velocity = Vector3.new(vxz.X, vy, vxz.Z)
	else
		-- Direct velocity
		velocity = targetOrVelocity
	end

	-- Store projectile data
	MoveService.Projectiles[obj] = {
		Mover = mover,
		IsModel = isModel,

		Position = origin,
		Velocity = velocity,
		Gravity = gravity,

		Time = 0,
		MaxTime = settings and settings.LifeTime or 5,

		Spin = settings and settings.Spin or Vector3.zero,
		FaceVelocity = settings and settings.FaceVelocity ~= false,

		Callback = settings and settings.OnHit,
	}

	-- Set initial transform
	ApplyTransform(mover, isModel, origin, CFrame.identity)
end

-------------------------------------------------
-- STOP
-------------------------------------------------
-- Clears ALL movement
function MoveService.StopAll()
	table.clear(MoveService.ActiveEnemies)
	table.clear(MoveService.LinearObjects)
	table.clear(MoveService.CurveObjects)
	table.clear(MoveService.Projectiles)
end

-------------------------------------------------
-- HEARTBEAT LOOP (MAIN UPDATE SYSTEM)
-------------------------------------------------
RunService.Heartbeat:Connect(function(dt)
	-------------------------------------------------
	-- WAYPOINT UPDATE
	-------------------------------------------------
	for enemy, data in pairs(MoveService.ActiveEnemies) do
		local mover = data.Mover

		-- Remove if deleted
		if not mover or not mover.Parent then
			MoveService.ActiveEnemies[enemy] = nil
			continue
		end

		-- If reached final waypoint
		if data.Index >= #data.Path then
			MoveService.ActiveEnemies[enemy] = nil
			continue
		end

		local start = data.Path[data.Index]
		local goal = data.Path[data.Index + 1]

		local diff = goal - start
		local dist = diff.Magnitude
		local dir = diff.Unit

		-- Move forward
		data.Traveled += data.Speed * dt

		local pos
		if data.Traveled >= dist then
			-- Reached next waypoint
			pos = goal
			data.Index += 1
			data.Traveled = 0
		else
			pos = start + dir * data.Traveled
		end

		local rot = CFrame.identity

		-- Face movement direction
		if data.LookAt then
			rot = CFrame.lookAt(pos, pos + dir)
		end

		-- Apply spin
		if data.Spin.Magnitude > 0 then
			rot *= CFrame.Angles(math.rad(data.Spin.X * dt), math.rad(data.Spin.Y * dt), math.rad(data.Spin.Z * dt))
		end

		ApplyTransform(mover, data.IsModel, pos, rot)

		-- Finish callback
		if data.Index >= #data.Path then
			if data.Callback then
				data.Callback(enemy)
			end
			MoveService.ActiveEnemies[enemy] = nil
		end
	end

	-------------------------------------------------
	-- LINEAR UPDATE
	-------------------------------------------------
	for obj, data in pairs(MoveService.LinearObjects) do
		local mover = data.Mover

		if not mover or not mover.Parent then
			MoveService.LinearObjects[obj] = nil
			continue
		end

		data.Time += dt

		-- Lifetime check
		if data.Time >= data.MaxTime then
			if data.Callback then
				data.Callback(obj)
			end
			MoveService.LinearObjects[obj] = nil
			continue
		end

		-- Move forward
		local pos = data.IsModel and mover:GetPivot().Position or mover.Position
		local newPos = pos + data.Direction * data.Speed * dt

		local rot = CFrame.lookAt(newPos, newPos + data.Direction)

		-- Spin
		if data.Spin.Magnitude > 0 then
			rot *= CFrame.Angles(math.rad(data.Spin.X * dt), math.rad(data.Spin.Y * dt), math.rad(data.Spin.Z * dt))
		end

		ApplyTransform(mover, data.IsModel, newPos, rot)
	end

	-------------------------------------------------
	-- CURVE UPDATE
	-------------------------------------------------
	for obj, data in pairs(MoveService.CurveObjects) do
		local mover = data.Mover

		if not mover or not mover.Parent then
			MoveService.CurveObjects[obj] = nil
			continue
		end

		data.Time += dt
		local t = math.clamp(data.Time / data.Duration, 0, 1)

		local pos = Bezier(data.P0, data.P1, data.P2, t)

		local rot = CFrame.identity

		-- Face curve direction
		if data.LookAt then
			local future = Bezier(data.P0, data.P1, data.P2, math.min(t + 0.01, 1))
			rot = CFrame.lookAt(pos, future)
		end

		-- Spin
		if data.Spin.Magnitude > 0 then
			rot *= CFrame.Angles(math.rad(data.Spin.X * dt), math.rad(data.Spin.Y * dt), math.rad(data.Spin.Z * dt))
		end

		ApplyTransform(mover, data.IsModel, pos, rot)

		-- End
		if t >= 1 then
			if data.Callback then
				data.Callback(obj)
			end
			MoveService.CurveObjects[obj] = nil
		end
	end

	-------------------------------------------------
	-- PROJECTILE UPDATE
	-------------------------------------------------
	for obj, data in pairs(MoveService.Projectiles) do
		local mover = data.Mover

		if not mover or not mover.Parent then
			MoveService.Projectiles[obj] = nil
			continue
		end

		data.Time += dt

		-- Lifetime end
		if data.Time >= data.MaxTime then
			if data.Callback then
				data.Callback(obj, nil)
			end
			MoveService.Projectiles[obj] = nil
			continue
		end

		-- Apply physics
		data.Velocity += data.Gravity * dt
		data.Position += data.Velocity * dt

		local rot = CFrame.identity

		-- Face velocity direction
		if data.FaceVelocity and data.Velocity.Magnitude > 0 then
			rot = CFrame.lookAt(data.Position, data.Position + data.Velocity)
		end

		-- Spin
		if data.Spin.Magnitude > 0 then
			rot *= CFrame.Angles(math.rad(data.Spin.X * dt), math.rad(data.Spin.Y * dt), math.rad(data.Spin.Z * dt))
		end

		ApplyTransform(mover, data.IsModel, data.Position, rot)
	end
end)

return MoveService
