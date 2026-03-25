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
				ShootAnimation = 0,
			},
			SFX = {
				Shoot = 156820338,
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
				DebounceAnimation = 122970814071616,
				ShootAnimation = 138572993898717,
			},
			SFX = {
				Shoot = 116571995883810,
			},
		},
	},
}

return module
