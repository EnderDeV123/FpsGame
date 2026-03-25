local SoundService = {}

function SoundService:PlaySound(SoundId: number, Object: Instance)
	task.spawn(function()
		local Sound = Instance.new("Sound")
		Sound.SoundId = "rbxassetid://" .. SoundId
		Sound.Parent = Object
		Sound:Play()

		Sound.Ended:Connect(function()
			Sound:Destroy()
		end)
	end)
end

return SoundService
