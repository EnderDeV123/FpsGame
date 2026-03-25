local module = {}

module.Guns = {
	Pistol = {
		Id = 1,
		actualGun = {
			Name = "Pistol",
			Damage = 10,
			DebounceTime = 0.2,
			recoil = 0.5,
			MaxAmmo = 30,
			Totalammo = 50,
			Animations = {
				DebounceAnimation = 0,
			},
		},
	},

	Sniper = {
		Id = 2,
		actualGun = {
			Name = "Sniper",
			Damage = 100,
			DebounceTime = 1.5,
			recoil = 1,
			MaxAmmo = 5,
			Totalammo = 20,
			Animations = {
				DebounceAnimation = 104179898786451,
			},
		},
	},
}

return module
