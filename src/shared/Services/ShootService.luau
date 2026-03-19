local Players = game:GetService("Players")

local ShootService = {}

function ShootService:Shoot(origin: Vector3, direction: Vector3, maxDistance: number, params: RaycastParams)
    
    -- Normalize direction (VERY IMPORTANT)
    direction = direction.Unit

    -- Default params
    if not params then
        params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Blacklist
        params.IgnoreWater = true
        
        -- Ignore all player characters
        local ignoreList = {}
        for _, player in ipairs(Players:GetPlayers()) do
            if player.Character then
                table.insert(ignoreList, player.Character)
            end
        end
        
        params.FilterDescendantsInstances = ignoreList
    end

    local result = workspace:Raycast(origin, direction * maxDistance, params)
    return result
end

return ShootService