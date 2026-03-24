local module = {}

module.Guns = {
	Pistol = {
		actualGun = { Name = "Pistol", Damage = 10, DebounceTime = 0.2, recoil = 0.5, MaxAmmo = 30, Totalammo = 50 },
		Id = 1,
	},
	HandGun = {
		actualGun = { Name = "Sniper", Damage = 100, DebounceTime = 0.3, recoil = 1, MaxAmmo = 20, Totalammo = 40 },
		Id = 2,
	},
}

return module
