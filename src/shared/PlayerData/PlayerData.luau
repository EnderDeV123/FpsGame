local Shared = {}

export type GunInventory = {
	MainGun: string,
	SecondaryGun: string,
	MedKit: string,
}

export type PlayerData = {
	GunInventory: GunInventory,
}

Shared.DEFAULT_PLAYER_DATA = {
	GunInventory = {
		MainGun = "Sniper",
		SecondaryGun = "Pistol",
		MedKit = "Medkit",
	},
}

return Shared
