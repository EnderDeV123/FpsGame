local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemotesFolder = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes")

local ShootServiceUtils = {}

function ShootServiceUtils:CreateUtils()
    
    local existing = RemotesFolder:FindFirstChild("ShootEvent")
    if existing then
        return existing
    end

    local remote = Instance.new("RemoteEvent")
    remote.Name = "ShootEvent"
    remote.Parent = RemotesFolder

    local ReloadRemote = Instance.new("RemoteEvent")
    ReloadRemote.Name = "ReloadEvent"
    ReloadRemote.Parent = RemotesFolder

    local UpdateAmmoRemote = Instance.new("RemoteEvent")
    UpdateAmmoRemote.Name = "UpdateAmmoEvent"
    UpdateAmmoRemote.Parent = RemotesFolder

    return remote
end

return ShootServiceUtils