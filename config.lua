Config = {}

Config.Locale = 'en'
Config.UseCommand = false
Config.LegacyFuel = true -- ture = Using LegacyFuel & you want Fuel to Save.
Config.KickPossibleCheaters = true -- If true it will kick the player that tries store a vehicle that they changed the Hash or Plate.
Config.UseCustomKickMessage = true -- If KickPossibleCheaters is true you can set a Custom Kick Message in the locales.
Config.UseDamageMult = true -- If true it costs more to store a Broken Vehicle.
Config.DamageMult = 3 -- Higher Number = Higher Repair Price.

Config.CarPoundPrice      = 1500 -- Car Pound Price.
Config.BoatPoundPrice     = 500 -- Boat Pound Price.
Config.AircraftPoundPrice = 3000 -- Aircraft Pound Price.
Config.PolicePoundPrice  = 300 -- Policing Pound Price.
Config.TaxingPoundPrice  = 300 -- Policing Pound Price.
Config.SheriffPoundPrice  = 300 -- Policing Pound Price.
Config.AmbulancePoundPrice = 300 -- Ambulance Pound Price.
Config.UseCarGarages        = true -- Allows use of Car Garages.
Config.UseBoatGarages       = true -- Allows use of Boat Garages.
Config.UseAircraftGarages   = true -- Allows use of Aircraft Garages.
Config.UsePrivateCarGarages = false -- Allows use of Private Car Garages.
Config.UseJobCarGarages     = true -- Allows use of Job Garages.
Config.Parkvehicles         = false --All Vehicles are Stored on restart
Config.DontShowPoundCarsInGarage = true -- If set to true it won't show Cars at the Pound in the Garage.
Config.ShowVehicleLocation       = true -- If set to true it will show the Location of the Vehicle in the Pound/Garage in the Garage menu.
Config.UseVehicleNamesLua        = false -- Must setup a vehicle_names.lua for Custom Addon Vehicles.
Config.ShowGarageSpacer1 = false -- If true it shows Spacer 1 in the List.
Config.ShowGarageSpacer2 = false -- If true it shows Spacer 2 in the List | Don't use if spacer3 is set to true.
Config.ShowGarageSpacer3 = false -- If true it shows Spacer 3 in the List | Don't use if Spacer2 is set to true.
Config.ShowPoundSpacer2 = false -- If true it shows Spacer 2 in the List | Don't use if spacer3 is set to true.
Config.ShowPoundSpacer3 = false -- If true it shows Spacer 3 in the List | Don't use if Spacer2 is set to true.
Config.MarkerType   = 6
Config.DrawDistance = 55.0
Config.MarkerDistance = 2.0
Config.MarkerDistance2 = 20.0

Config.BlipGarage = { Sprite = 289, Color = 38, Display = 1, Scale = 1.07 }

Config.BlipGaragePrivate = { Sprite = 290, Color = 53, Display = 2, Scale = 0.4 }

Config.BlipPound = {
	Sprite = 67,
	Color = 64,
	Display = 2,
	Scale = 0.8
}

Config.BlipJobPound = {
	Sprite = 67,
	Color = 49,
	Display = 2,
	Scale = 0.8
}

Config.PointMarker = {
	r = 14, g = 230, b = 14,     -- Green Color
	x = 1.5, y = 1.5, z = 1.5  -- Standard Size Circle
}

Config.DeleteMarker = {
	r = 255, g = 0, b = 0,     -- Red Color
	x = 5.0, y = 5.0, z = 5.0  -- Big Size Circle
}

Config.DeleteMarker2 = {
	r = 255, g = 0, b = 0,     -- Red Color
	x = 30.0, y = 30.0, z = 30.0  -- Big Size Circle
}

Config.PoundMarker = {
	r = 255, g = 0, b = 0,     -- Blue Color
	x = 1.5, y = 1.5, z = 1.5  -- Standard Size Circle
}

Config.JobPoundMarker = {
	r = 255, g = 0, b = 0,     -- Red Color
	x = 1.5, y = 1.5, z = 1.5  -- Standard Size Circle
}

-- Start of Jobs

Config.PolicePounds = {

	Pound_LosSantos = {

		PoundPoint = { x = 374.42, y = -1620.68, z = 28.29 },

		SpawnPoint = { x = 391.74, y = -1619.0, z = 28.29, h = 318.34 }

	},

	Pound_Sandy = {

		PoundPoint = { x = 1646.01, y = 3812.06, z = 37.65 },

		SpawnPoint = { x = 1627.84, y = 3788.45, z = 33.77, h = 308.53 }

	},

	Pound_Paleto = {

		PoundPoint = { x = -223.6, y = 6243.37, z = 30.49 },

		SpawnPoint = { x = -230.88, y = 6255.89, z = 30.49, h = 136.5 }

	}

}

Config.TaxiPounds = {

	Pound_LosSantos = {

		PoundPoint = { x = 374.42, y = -1620.68, z = 28.29 },

		SpawnPoint = { x = 391.74, y = -1619.0, z = 28.29, h = 318.34 }

	},

	Pound_Sandy = {

		PoundPoint = { x = 1646.01, y = 3812.06, z = 37.65 },

		SpawnPoint = { x = 1627.84, y = 3788.45, z = 33.77, h = 308.53 }

	},

	Pound_Paleto = {

		PoundPoint = { x = -223.6, y = 6243.37, z = 30.49 },

		SpawnPoint = { x = -230.88, y = 6255.89, z = 30.49, h = 136.5 }

	}

}

Config.SheriffPounds = {

	Pound_LosSantos = {

		PoundPoint = { x = 374.42, y = -1620.68, z = 28.29 },

		SpawnPoint = { x = 391.74, y = -1619.0, z = 28.29, h = 318.34 }

	},

	Pound_Sandy = {

		PoundPoint = { x = 1646.01, y = 3812.06, z = 37.65 },

		SpawnPoint = { x = 1627.84, y = 3788.45, z = 33.77, h = 308.53 }

	},

	Pound_Paleto = {

		PoundPoint = { x = -223.6, y = 6243.37, z = 30.49 },

		SpawnPoint = { x = -230.88, y = 6255.89, z = 30.49, h = 136.5 }

	}

}

Config.AmbulancePounds = {

	Pound_LosSantos = {

		PoundPoint = { x = 374.42, y = -1620.68, z = 28.29 },

		SpawnPoint = { x = 391.74, y = -1619.0, z = 28.29, h = 318.34 }

	},

	Pound_Sandy = {

		PoundPoint = { x = 1646.01, y = 3812.06, z = 37.65 },

		SpawnPoint = { x = 1627.84, y = 3788.45, z = 33.77, h = 308.53 }

	},

	Pound_Paleto = {

		PoundPoint = { x = -223.6, y = 6243.37, z = 30.49 },

		SpawnPoint = { x = -230.88, y = 6255.89, z = 30.49, h = 136.5 }

	}

}
-- End of Jobs

-- Start of Cars
Config.CarPounds = {

	Pound_LosSantos = {

		PoundPoint = { x = 408.61, y = -1625.47, z = 28.29 },

		SpawnPoint = { x = 405.64, y = -1643.4, z = 27.61, h = 229.54 }

	},

	Pound_Sandy = {

		PoundPoint = { x = 1651.38, y = 3804.84, z = 37.65 },

		SpawnPoint = { x = 1627.84, y = 3788.45, z = 33.77, h = 308.53 }

	},

	Pound_Paleto = {

		PoundPoint = { x = -234.82, y = 6198.65, z = 30.94 },

		SpawnPoint = { x = -230.08, y = 6190.24, z = 30.49, h = 140.24 }

	}

}
-- End of Cars

-- Start of Boats
Config.BoatGarages = {

	Garage_LSDock = {

		GaragePoint = { x = -781.49, y = -1487.48, z = 1.3 },

		SpawnPoint = { x = -801.17, y = -1504.18, z = 0.17, h = 110.0 },

		DeletePoint = { x = -795.15, y = -1488.31, z = 0.47 }

	},

	Garage_SandyDock = {

		GaragePoint = { x = 1333.2, y = 4269.92, z = 30.5 },

		SpawnPoint = { x = 1334.61, y = 4264.68, z = 29.86, h = 87.0 },

		DeletePoint = { x = 1323.73, y = 4269.94, z = 29.86 }

	},

	Garage_PaletoDock = {

		GaragePoint = { x = -283.74, y = 6629.51, z = 5.3 },

		SpawnPoint = { x = -290.46, y = 6622.72, z = -0.47477427124977, h = 52.0 },

		DeletePoint = { x = -304.66, y = 6607.36, z = 0.17477427124977 }

	},

	Garage_CayoPerico = {

		GaragePoint = { x = 5140.57, y = -4645.16, z = 0.61 },

		SpawnPoint = { x = 5143.84, y = -4645.91, z = 0.41, h = 164.40 },

		DeletePoint = { x = 5145.78, y = -4644.18, z = -0.03 }

	},

}



Config.BoatPounds = {

	Pound_LSDock = {

		PoundPoint = { x = -738.67, y = -1400.43, z = 4.0 },

		SpawnPoint = { x = -738.33, y = -1381.51, z = 0.12, h = 137.85 }

	},

	Pound_SandyDock = {

		PoundPoint = { x = 1299.36, y = 4217.93, z = 32.91 },

		SpawnPoint = { x = 1294.35, y = 4226.31, z = 29.86, h = 345.0 }

	},

	Pound_PaletoDock = {

		PoundPoint = { x = -270.2, y = 6642.43, z = 6.36 },

		SpawnPoint = { x = -290.38, y = 6638.54, z = -0.47477427124977, h = 130.0 }

	},

}
-- End of Boats

-- Start of Aircrafts
Config.AircraftGarages = {

	Garage_LSAirport = {

		GaragePoint = { x = -1617.14, y = -3145.52, z = 12.99 },

		SpawnPoint = { x = -1657.99, y = -3134.38, z = 12.99, h = 330.11 },

		DeletePoint = { x = -1642.62, y = -3143.25, z = 12.99 }

	},

	Garage_SandyAirport = {

		GaragePoint = { x = 1723.84, y = 3288.29, z = 40.16 },

		SpawnPoint = { x = 1710.85, y = 3259.06, z = 40.69, h = 104.66 },

		DeletePoint = { x = 1714.45, y = 3246.75, z = 40.07 }

	},

	Garage_CayoPerico = {

		GaragePoint = { x = 4449.56, y = -4476.07, z = 3.32 },

		SpawnPoint = { x = 4450.33, y = -4490.57, z = 4.21, h = 194.66 },

		DeletePoint = { x = 4465.35, y = -4497.11, z = 2.41 }

	},

	Garage_GrapeseedAirport = {

		GaragePoint = { x = 2152.83, y = 4797.03, z = 40.19 },

		SpawnPoint = { x = 2122.72, y = 4804.85, z = 40.78, h = 115.04 },

		DeletePoint = { x = 2082.36, y = 4806.06, z = 40.07 }

	}

}

Config.AircraftPounds = {

	Pound_LSAirport = {

		PoundPoint = { x = -1243.0, y = -3391.92, z = 12.94 },

		SpawnPoint = { x = -1272.27, y = -3382.46, z = 12.94, h = 330.25 }

	}

}
-- End of Aircrafts

-- Start of Private Garages
Config.PrivateCarGarages = {

	-- Maze Bank Building Garages

	Garage_MazeBankBuilding = {

		Private = "MazeBankBuilding",

		GaragePoint = { x = -60.38, y = -790.31, z = 43.23 },

		SpawnPoint = { x = -44.031, y = -787.363, z = 43.186, h = 254.322 },

		DeletePoint = { x = -58.88, y = -778.625, z = 43.175 }

	},

	Garage_OldSpiceWarm = {

		Private = "OldSpiceWarm",

		GaragePoint = { x = -60.38, y = -790.31, z = 43.23 },

		SpawnPoint = { x = -44.031, y = -787.363, z = 43.186, h = 254.322 },

		DeletePoint = { x = -58.88, y = -778.625, z = 43.175 }

	},

	Garage_OldSpiceClassical = {

		Private = "OldSpiceClassical",

		GaragePoint = { x = -60.38, y = -790.31, z = 43.23 },

		SpawnPoint = { x = -44.031, y = -787.363, z = 43.186, h = 254.322 },

		DeletePoint = { x = -58.88, y = -778.625, z = 43.175 }

	},

	Garage_OldSpiceVintage = {

		Private = "OldSpiceVintage",

		GaragePoint = { x = -60.38, y = -790.31, z = 43.23 },

		SpawnPoint = { x = -44.031, y = -787.363, z = 43.186, h = 254.322 },

		DeletePoint = { x = -58.88, y = -778.625, z = 43.175 }

	},

	Garage_ExecutiveRich = {

		Private = "ExecutiveRich",

		GaragePoint = { x = -60.38, y = -790.31, z = 43.23 },

		SpawnPoint = { x = -44.031, y = -787.363, z = 43.186, h = 254.322 },

		DeletePoint = { x = -58.88, y = -778.625, z = 43.175 }

	},

	Garage_ExecutiveCool = {

		Private = "ExecutiveCool",

		GaragePoint = { x = -60.38, y = -790.31, z = 43.23 },

		SpawnPoint = { x = -44.031, y = -787.363, z = 43.186, h = 254.322 },

		DeletePoint = { x = -58.88, y = -778.625, z = 43.175 }

	},

	Garage_ExecutiveContrast = {

		Private = "ExecutiveContrast",

		GaragePoint = { x = -60.38, y = -790.31, z = 43.23 },

		SpawnPoint = { x = -44.031, y = -787.363, z = 43.186, h = 254.322 },

		DeletePoint = { x = -58.88, y = -778.625, z = 43.175 }

	},

	Garage_PowerBrokerIce = {

		Private = "PowerBrokerIce",

		GaragePoint = { x = -60.38, y = -790.31, z = 43.23 },

		SpawnPoint = { x = -44.031, y = -787.363, z = 43.186, h = 254.322 },

		DeletePoint = { x = -58.88, y = -778.625, z = 43.175 }

	},

	Garage_PowerBrokerConservative = {

		Private = "PowerBrokerConservative",

		GaragePoint = { x = -60.38, y = -790.31, z = 43.23 },

		SpawnPoint = { x = -44.031, y = -787.363, z = 43.186, h = 254.322 },

		DeletePoint = { x = -58.88, y = -778.625, z = 43.175 }

	},

	Garage_PowerBrokerPolished = {

		Private = "PowerBrokerPolished",

		GaragePoint = { x = -60.38, y = -790.31, z = 43.23 },

		SpawnPoint = { x = -44.031, y = -787.363, z = 43.186, h = 254.322 },

		DeletePoint = { x = -58.88, y = -778.625, z = 43.175 }

	},
	-- End of Maze Bank Building Garages

	-- Start of Lom Bank Garages
	Garage_LomBank = {

		Private = "LomBank",

		GaragePoint = { x = -1545.17, y = -566.24, z = 24.85 },

		SpawnPoint = { x = -1551.88, y = -581.383, z = 24.708, h = 331.176 },

		DeletePoint = { x = -1538.564, y = -576.049, z = 24.708 }

	},

	Garage_LBOldSpiceWarm = {

		Private = "LBOldSpiceWarm",

		GaragePoint = { x = -1545.17, y = -566.24, z = 24.85 },

		SpawnPoint = { x = -1551.88, y = -581.383, z = 24.708, h = 331.176 },

		DeletePoint = { x = -1538.564, y = -576.049, z = 24.708 }

	},

	Garage_LBOldSpiceClassical = {

		Private = "LBOldSpiceClassical",

		GaragePoint = { x = -1545.17, y = -566.24, z = 24.85 },

		SpawnPoint = { x = -1551.88, y = -581.383, z = 24.708, h = 331.176 },

		DeletePoint = { x = -1538.564, y = -576.049, z = 24.708 }

	},

	Garage_LBOldSpiceVintage = {

		Private = "LBOldSpiceVintage",

		GaragePoint = { x = -1545.17, y = -566.24, z = 24.85 },

		SpawnPoint = { x = -1551.88, y = -581.383, z = 24.708, h = 331.176 },

		DeletePoint = { x = -1538.564, y = -576.049, z = 24.708 }

	},

	Garage_LBExecutiveRich = {

		Private = "LBExecutiveRich",

		GaragePoint = { x = -1545.17, y = -566.24, z = 24.85 },

		SpawnPoint = { x = -1551.88, y = -581.383, z = 24.708, h = 331.176 },

		DeletePoint = { x = -1538.564, y = -576.049, z = 24.708 }

	},

	Garage_LBExecutiveCool = {

		Private = "LBExecutiveCool",

		GaragePoint = { x = -1545.17, y = -566.24, z = 24.85 },

		SpawnPoint = { x = -1551.88, y = -581.383, z = 24.708, h = 331.176 },

		DeletePoint = { x = -1538.564, y = -576.049, z = 24.708 }

	},

	Garage_LBExecutiveContrast = {

		Private = "LBExecutiveContrast",

		GaragePoint = { x = -1545.17, y = -566.24, z = 24.85 },

		SpawnPoint = { x = -1551.88, y = -581.383, z = 24.708, h = 331.176 },

		DeletePoint = { x = -1538.564, y = -576.049, z = 24.708 }

	},

	Garage_LBPowerBrokerIce = {

		Private = "LBPowerBrokerIce",

		GaragePoint = { x = -1545.17, y = -566.24, z = 24.85 },

		SpawnPoint = { x = -1551.88, y = -581.383, z = 24.708, h = 331.176 },

		DeletePoint = { x = -1538.564, y = -576.049, z = 24.708 }

	},

	Garage_LBPowerBrokerConservative = {

		Private = "LBPowerBrokerConservative",

		GaragePoint = { x = -1545.17, y = -566.24, z = 24.85 },

		SpawnPoint = { x = -1551.88, y = -581.383, z = 24.708, h = 331.176 },

		DeletePoint = { x = -1538.564, y = -576.049, z = 24.708 }

	},

	Garage_LBPowerBrokerPolished = {

		Private = "LBPowerBrokerPolished",

		GaragePoint = { x = -1545.17, y = -566.24, z = 24.85 },

		SpawnPoint = { x = -1551.88, y = -581.383, z = 24.708, h = 331.176 },

		DeletePoint = { x = -1538.564, y = -576.049, z = 24.708 }

	},
	-- End of Lom Bank Garages

	-- Start of Maze Bank West Garages
	Garage_MazeBankWest = {

		Private = "MazeBankWest",

		GaragePoint = { x = -1368.14, y = -468.01, z = 30.6 },

		SpawnPoint = { x = -1376.93, y = -474.32, z = 30.5, h = 97.95 },

		DeletePoint = { x = -1362.065, y = -471.982, z = 30.5 }

	},

	Garage_MBWOldSpiceWarm = {

		Private = "MBWOldSpiceWarm",

		GaragePoint = { x = -1368.14, y = -468.01, z = 30.6 },

		SpawnPoint = { x = -1376.93, y = -474.32, z = 30.5, h = 97.95 },

		DeletePoint = { x = -1362.065, y = -471.982, z = 30.5 }

	},

	Garage_MBWOldSpiceClassical = {

		Private = "MBWOldSpiceClassical",

		GaragePoint = { x = -1368.14, y = -468.01, z = 30.6 },

		SpawnPoint = { x = -1376.93, y = -474.32, z = 30.5, h = 97.95 },

		DeletePoint = { x = -1362.065, y = -471.982, z = 30.5 }

	},

	Garage_MBWOldSpiceVintage = {

		Private = "MBWOldSpiceVintage",

		GaragePoint = { x = -1368.14, y = -468.01, z = 30.6 },

		SpawnPoint = { x = -1376.93, y = -474.32, z = 30.5, h = 97.95 },

		DeletePoint = { x = -1362.065, y = -471.982, z = 30.5 }

	},

	Garage_MBWExecutiveRich = {

		Private = "MBWExecutiveRich",

		GaragePoint = { x = -1368.14, y = -468.01, z = 30.6 },

		SpawnPoint = { x = -1376.93, y = -474.32, z = 30.5, h = 97.95 },

		DeletePoint = { x = -1362.065, y = -471.982, z = 30.5 }

	},

	Garage_MBWExecutiveCool = {

		Private = "MBWExecutiveCool",

		GaragePoint = { x = -1368.14, y = -468.01, z = 30.6 },

		SpawnPoint = { x = -1376.93, y = -474.32, z = 30.5, h = 97.95 },

		DeletePoint = { x = -1362.065, y = -471.982, z = 30.5 }

	},

	Garage_MBWExecutiveContrast = {

		Private = "MBWExecutiveContrast",

		GaragePoint = { x = -1368.14, y = -468.01, z = 30.6 },

		SpawnPoint = { x = -1376.93, y = -474.32, z = 30.5, h = 97.95 },

		DeletePoint = { x = -1362.065, y = -471.982, z = 30.5 }

	},

	Garage_MBWPowerBrokerIce = {

		Private = "MBWPowerBrokerIce",

		GaragePoint = { x = -1368.14, y = -468.01, z = 30.6 },

		SpawnPoint = { x = -1376.93, y = -474.32, z = 30.5, h = 97.95 },

		DeletePoint = { x = -1362.065, y = -471.982, z = 30.5 }

	},

	Garage_MBWPowerBrokerConvservative = {

		Private = "MBWPowerBrokerConvservative",

		GaragePoint = { x = -1368.14, y = -468.01, z = 30.6 },

		SpawnPoint = { x = -1376.93, y = -474.32, z = 30.5, h = 97.95 },

		DeletePoint = { x = -1362.065, y = -471.982, z = 30.5 }

	},

	Garage_MBWPowerBrokerPolished = {

		Private = "MBWPowerBrokerPolished",

		GaragePoint = { x = -1368.14, y = -468.01, z = 30.6 },

		SpawnPoint = { x = -1376.93, y = -474.32, z = 30.5, h = 97.95 },

		DeletePoint = { x = -1362.065, y = -471.982, z = 30.5 }

	},
	-- End of Maze Bank West Garages

	-- Start of Intergrity Way Garages
	Garage_IntegrityWay = {

		Private = "IntegrityWay",

		GaragePoint = { x = -14.1, y = -614.93, z = 34.86 },

		SpawnPoint = { x = -7.351, y = -635.1, z = 34.724, h = 66.632 },

		DeletePoint = { x = -37.575, y = -620.391, z = 34.073 }

	},

	Garage_IntegrityWay28 = {

		Private = "IntegrityWay28",

		GaragePoint = { x = -14.1, y = -614.93, z = 34.86 },

		SpawnPoint = { x = -7.351, y = -635.1, z = 34.724, h = 66.632 },

		DeletePoint = { x = -37.575, y = -620.391, z = 34.073 }

	},

	Garage_IntegrityWay30 = {

		Private = "IntegrityWay30",

		GaragePoint = { x = -14.1, y = -614.93, z = 34.86 },

		SpawnPoint = { x = -7.351, y = -635.1, z = 34.724, h = 66.632 },

		DeletePoint = { x = -37.575, y = -620.391, z = 34.073 }

	},

	-- End of Intergrity Way Garages

	-- Start of Dell Perro Heights Garages

	Garage_DellPerroHeights = {

		Private = "DellPerroHeights",

		GaragePoint = { x = -1477.15, y = -517.17, z = 33.74 },

		SpawnPoint = { x = -1483.16, y = -505.1, z = 31.81, h = 299.89 },

		DeletePoint = { x = -1452.612, y = -508.782, z = 30.582 }

	},

	Garage_DellPerroHeightst4 = {

		Private = "DellPerroHeightst4",

		GaragePoint = { x = -1477.15, y = -517.17, z = 33.74 },

		SpawnPoint = { x = -1483.16, y = -505.1, z = 31.81, h = 299.89 },

		DeletePoint = { x = -1452.612, y = -508.782, z = 30.582 }

	},

	Garage_DellPerroHeightst7 = {

		Private = "DellPerroHeightst7",

		GaragePoint = { x = -1477.15, y = -517.17, z = 33.74 },

		SpawnPoint = { x = -1483.16, y = -505.1, z = 31.81, h = 299.89 },

		DeletePoint = { x = -1452.612, y = -508.782, z = 30.582 }

	},

	-- End of Dell Perro Heights Garages

	-- Start of Milton Drive Garages

	Garage_MiltonDrive = {

		Private = "MiltonDrive",

		GaragePoint = { x = -795.96, y = 331.83, z = 84.5 },

		SpawnPoint = { x = -800.496, y = 333.468, z = 84.5, h = 180.494 },

		DeletePoint = { x = -791.755, y = 333.468, z = 84.5 }

	},

	Garage_Modern1Apartment = {

		Private = "Modern1Apartment",

		GaragePoint = { x = -795.96, y = 331.83, z = 84.5 },

		SpawnPoint = { x = -800.496, y = 333.468, z = 84.5, h = 180.494 },

		DeletePoint = { x = -791.755, y = 333.468, z = 84.5 }

	},

	Garage_Modern2Apartment = {

		Private = "Modern2Apartment",

		GaragePoint = { x = -795.96, y = 331.83, z = 84.5 },

		SpawnPoint = { x = -800.496, y = 333.468, z = 84.5, h = 180.494 },

		DeletePoint = { x = -791.755, y = 333.468, z = 84.5 }

	},

	Garage_Modern3Apartment = {

		Private = "Modern3Apartment",

		GaragePoint = { x = -795.96, y = 331.83, z = 84.5 },

		SpawnPoint = { x = -800.496, y = 333.468, z = 84.5, h = 180.494 },

		DeletePoint = { x = -791.755, y = 333.468, z = 84.5 }

	},

	Garage_Mody1Apartment = {

		Private = "Mody1Apartment",

		GaragePoint = { x = -795.96, y = 331.83, z = 84.5 },

		SpawnPoint = { x = -800.496, y = 333.468, z = 84.5, h = 180.494 },

		DeletePoint = { x = -791.755, y = 333.468, z = 84.5 }

	},

	Garage_Mody2Apartment = {

		Private = "Mody2Apartment",

		GaragePoint = { x = -795.96, y = 331.83, z = 84.5 },

		SpawnPoint = { x = -800.496, y = 333.468, z = 84.5, h = 180.494 },

		DeletePoint = { x = -791.755, y = 333.468, z = 84.5 }

	},

	Garage_Mody3Apartment = {

		Private = "Mody3Apartment",

		GaragePoint = { x = -795.96, y = 331.83, z = 84.5 },

		SpawnPoint = { x = -800.496, y = 333.468, z = 84.5, h = 180.494 },

		DeletePoint = { x = -791.755, y = 333.468, z = 84.5 }

	},

	Garage_Vibrant1Apartment = {

		Private = "Vibrant1Apartment",

		GaragePoint = { x = -795.96, y = 331.83, z = 84.5 },

		SpawnPoint = { x = -800.496, y = 333.468, z = 84.5, h = 180.494 },

		DeletePoint = { x = -791.755, y = 333.468, z = 84.5 }

	},

	Garage_Vibrant2Apartment = {

		Private = "Vibrant2Apartment",

		GaragePoint = { x = -795.96, y = 331.83, z = 84.5 },

		SpawnPoint = { x = -800.496, y = 333.468, z = 84.5, h = 180.494 },

		DeletePoint = { x = -791.755, y = 333.468, z = 84.5 }

	},

	Garage_Vibrant3Apartment = {

		Private = "Vibrant3Apartment",

		GaragePoint = { x = -795.96, y = 331.83, z = 84.5 },

		SpawnPoint = { x = -800.496, y = 333.468, z = 84.5, h = 180.494 },

		DeletePoint = { x = -791.755, y = 333.468, z = 84.5 }

	},

	Garage_Sharp1Apartment = {

		Private = "Sharp1Apartment",

		GaragePoint = { x = -795.96, y = 331.83, z = 84.5 },

		SpawnPoint = { x = -800.496, y = 333.468, z = 84.5, h = 180.494 },

		DeletePoint = { x = -791.755, y = 333.468, z = 84.5 }

	},

	Garage_Sharp2Apartment = {

		Private = "Sharp2Apartment",

		GaragePoint = { x = -795.96, y = 331.83, z = 84.5 },

		SpawnPoint = { x = -800.496, y = 333.468, z = 84.5, h = 180.494 },

		DeletePoint = { x = -791.755, y = 333.468, z = 84.5 }

	},

	Garage_Sharp3Apartment = {

		Private = "Sharp3Apartment",

		GaragePoint = { x = -795.96, y = 331.83, z = 84.5 },

		SpawnPoint = { x = -800.496, y = 333.468, z = 84.5, h = 180.494 },

		DeletePoint = { x = -791.755, y = 333.468, z = 84.5 }

	},

	Garage_Monochrome1Apartment = {

		Private = "Monochrome1Apartment",

		GaragePoint = { x = -795.96, y = 331.83, z = 84.5 },

		SpawnPoint = { x = -800.496, y = 333.468, z = 84.5, h = 180.494 },

		DeletePoint = { x = -791.755, y = 333.468, z = 84.5 }

	},

	Garage_Monochrome2Apartment = {

		Private = "Monochrome2Apartment",

		GaragePoint = { x = -795.96, y = 331.83, z = 84.5 },

		SpawnPoint = { x = -800.496, y = 333.468, z = 84.5, h = 180.494 },

		DeletePoint = { x = -791.755, y = 333.468, z = 84.5 }

	},

	Garage_Monochrome3Apartment = {

		Private = "Monochrome3Apartment",

		GaragePoint = { x = -795.96, y = 331.83, z = 84.5 },

		SpawnPoint = { x = -800.496, y = 333.468, z = 84.5, h = 180.494 },

		DeletePoint = { x = -791.755, y = 333.468, z = 84.5 }

	},

	Garage_Seductive1Apartment = {

		Private = "Seductive1Apartment",

		GaragePoint = { x = -795.96, y = 331.83, z = 84.5 },

		SpawnPoint = { x = -800.496, y = 333.468, z = 84.5, h = 180.494 },

		DeletePoint = { x = -791.755, y = 333.468, z = 84.5 }

	},

	Garage_Seductive2Apartment = {

		Private = "Seductive2Apartment",

		GaragePoint = { x = -795.96, y = 331.83, z = 84.5 },

		SpawnPoint = { x = -800.496, y = 333.468, z = 84.5, h = 180.494 },

		DeletePoint = { x = -791.755, y = 333.468, z = 84.5 }

	},

	Garage_Seductive3Apartment = {

		Private = "Seductive3Apartment",

		GaragePoint = { x = -795.96, y = 331.83, z = 84.5 },

		SpawnPoint = { x = -800.496, y = 333.468, z = 84.5, h = 180.494 },

		DeletePoint = { x = -791.755, y = 333.468, z = 84.5 }

	},

	Garage_Regal1Apartment = {

		Private = "Regal1Apartment",

		GaragePoint = { x = -795.96, y = 331.83, z = 84.5 },

		SpawnPoint = { x = -800.496, y = 333.468, z = 84.5, h = 180.494 },

		DeletePoint = { x = -791.755, y = 333.468, z = 84.5 }

	},

	Garage_Regal2Apartment = {

		Private = "Regal2Apartment",

		GaragePoint = { x = -795.96, y = 331.83, z = 84.5 },

		SpawnPoint = { x = -800.496, y = 333.468, z = 84.5, h = 180.494 },

		DeletePoint = { x = -791.755, y = 333.468, z = 84.5 }

	},

	Garage_Regal3Apartment = {

		Private = "Regal3Apartment",

		GaragePoint = { x = -795.96, y = 331.83, z = 84.5 },

		SpawnPoint = { x = -800.496, y = 333.468, z = 84.5, h = 180.494 },

		DeletePoint = { x = -791.755, y = 333.468, z = 84.5 }

	},

	Garage_Aqua1Apartment = {

		Private = "Aqua1Apartment",

		GaragePoint = { x = -795.96, y = 331.83, z = 84.5 },

		SpawnPoint = { x = -800.496, y = 333.468, z = 84.5, h = 180.494 },

		DeletePoint = { x = -791.755, y = 333.468, z = 84.5 }

	},

	Garage_Aqua2Apartment = {

		Private = "Aqua2Apartment",

		GaragePoint = { x = -795.96, y = 331.83, z = 84.5 },

		SpawnPoint = { x = -800.496, y = 333.468, z = 84.5, h = 180.494 },

		DeletePoint = { x = -791.755, y = 333.468, z = 84.5 }

	},

	Garage_Aqua3Apartment = {

		Private = "Aqua3Apartment",

		GaragePoint = { x = -795.96, y = 331.83, z = 84.5 },

		SpawnPoint = { x = -800.496, y = 333.468, z = 84.5, h = 180.494 },

		DeletePoint = { x = -791.755, y = 333.468, z = 84.5 }

	},

	-- End of Milton Drive Garages

	-- Start of Single Garages

	Garage_RichardMajesticApt2 = {

		Private = "RichardMajesticApt2",

		GaragePoint = { x = -887.5, y = -349.58, z = 33.534 },

		SpawnPoint = { x = -886.03, y = -343.78, z = 33.534, h = 206.79 },

		DeletePoint = { x = -894.324, y = -349.326, z = 33.534 }

	},

	Garage_WildOatsDrive = {

		Private = "WildOatsDrive",

		GaragePoint = { x = -178.65, y = 503.45, z = 135.85 },

		SpawnPoint = { x = -189.98, y = 505.8, z = 133.48, h = 282.62 },

		DeletePoint = { x = -189.28, y = 500.56, z = 132.93 }

	},

	Garage_WhispymoundDrive = {

		Private = "WhispymoundDrive",

		GaragePoint = { x = 123.65, y = 565.75, z = 183.04 },

		SpawnPoint = { x = 130.11, y = 571.47, z = 182.42, h = 270.71 },

		DeletePoint = { x = 131.97, y = 566.77, z = 181.95 }

	},

	Garage_NorthConkerAvenue2044 = {

		Private = "NorthConkerAvenue2044",

		GaragePoint = { x = 348.18, y = 443.01, z = 146.7 },

		SpawnPoint = { x = 358.397, y = 437.064, z = 144.277, h = 285.911 },

		DeletePoint = { x = 351.383, y = 438.865, z = 145.66 }

	},

	Garage_NorthConkerAvenue2045 = {

		Private = "NorthConkerAvenue2045",

		GaragePoint = { x = 370.69, y = 430.76, z = 144.11 },

		SpawnPoint = { x = 392.88, y = 434.54, z = 142.17, h = 264.94 },

		DeletePoint = { x = 389.72, y = 429.95, z = 141.81 }

	},

	Garage_HillcrestAvenue2862 = {

		Private = "HillcrestAvenue2862",

		GaragePoint = { x = -688.71, y = 597.57, z = 142.64 },

		SpawnPoint = { x = -683.72, y = 609.88, z = 143.28, h = 338.06 },

		DeletePoint = { x = -685.259, y = 601.083, z = 142.365 }

	},

	Garage_HillcrestAvenue2868 = {

		Private = "HillcrestAvenue2868",

		GaragePoint = { x = -752.753, y = 624.901, z = 141.2 },

		SpawnPoint = { x = -749.32, y = 628.61, z = 141.48, h = 197.14 },

		DeletePoint = { x = -754.286, y = 631.581, z = 141.2 }

	},

	Garage_HillcrestAvenue2874 = {

		Private = "HillcrestAvenue2874",

		GaragePoint = { x = -859.01, y = 695.95, z = 147.93 },

		SpawnPoint = { x = -863.681, y = 698.72, z = 147.052, h = 341.77 },

		DeletePoint = { x = -855.66, y = 698.77, z = 147.81 }

	},

	Garage_MadWayneThunder = {

		Private = "MadWayneThunder",

		GaragePoint = { x = -1290.95, y = 454.52, z = 96.66 },

		SpawnPoint = { x = -1297.62, y = 459.28, z = 96.48, h = 285.652 },

		DeletePoint = { x = -1298.088, y = 468.952, z = 96.0 }

	},

	Garage_TinselTowersApt12 = {

		Private = "TinselTowersApt12",

		GaragePoint = { x = -616.74, y = 56.38, z = 42.736 },

		SpawnPoint = { x = -620.588, y = 60.102, z = 42.736, h = 109.316 },

		DeletePoint = { x = -621.128, y = 52.691, z = 42.735 }

	},

	-- End of Single Garages

	-- Start of VENT Custom Garages

	Garage_MedEndApartment1 = {

		Private = "MedEndApartment1",

		GaragePoint = { x = 240.23, y = 3102.84, z = 41.49 },

		SpawnPoint = { x = 233.58, y = 3094.29, z = 41.49, h = 93.91 },

		DeletePoint = { x = 237.52, y = 3112.63, z = 41.39 }

	},

	Garage_MedEndApartment2 = {

		Private = "MedEndApartment2",

		GaragePoint = { x = 246.08, y = 3174.63, z = 41.72 },

		SpawnPoint = { x = 234.15, y = 3164.37, z = 41.54, h = 102.03 },

		DeletePoint = { x = 240.72, y = 3165.53, z = 41.65 }

	},

	Garage_MedEndApartment3 = {

		Private = "MedEndApartment3",

		GaragePoint = { x = 984.92, y = 2668.95, z = 39.06 },

		SpawnPoint = { x = 993.96, y = 2672.68, z = 39.06, h = 0.61 },

		DeletePoint = { x = 994.04, y = 2662.1, z = 39.13 }

	},

	Garage_MedEndApartment4 = {

		Private = "MedEndApartment4",

		GaragePoint = { x = 196.49, y = 3027.48, z = 42.89 },

		SpawnPoint = { x = 203.1, y = 3039.47, z = 42.08, h = 271.3 },

		DeletePoint = { x = 192.24, y = 3037.95, z = 42.89 }

	},

	Garage_MedEndApartment5 = {

		Private = "MedEndApartment5",

		GaragePoint = { x = 1724.49, y = 4638.13, z = 42.31 },

		SpawnPoint = { x = 1723.98, y = 4630.19, z = 42.23, h = 117.88 },

		DeletePoint = { x = 1733.66, y = 4635.08, z = 42.24 }

	},

	Garage_MedEndApartment6 = {

		Private = "MedEndApartment6",

		GaragePoint = { x = 1670.76, y = 4740.99, z = 41.08 },

		SpawnPoint = { x = 1673.47, y = 4756.51, z = 40.91, h = 12.82 },

		DeletePoint = { x = 1668.46, y = 4750.83, z = 40.88 }

	},

	Garage_MedEndApartment7 = {

		Private = "MedEndApartment7",

		GaragePoint = { x = 15.24, y = 6573.38, z = 31.72 },

		SpawnPoint = { x = 16.77, y = 6581.68, z = 31.42, h = 222.6 },

		DeletePoint = { x = 10.45, y = 6588.04, z = 31.47 }

	},

	Garage_MedEndApartment8 = {

		Private = "MedEndApartment8",

		GaragePoint = { x = -374.73, y = 6187.06, z = 30.54 },

		SpawnPoint = { x = -377.97, y = 6183.73, z = 30.49, h = 223.71 },

		DeletePoint = { x = -383.31, y = 6188.85, z = 30.49 }

	},

	Garage_MedEndApartment9 = {

		Private = "MedEndApartment9",

		GaragePoint = { x = -24.6, y = 6605.99, z = 30.45 },

		SpawnPoint = { x = -16.0, y = 6607.74, z = 30.18, h = 35.31 },

		DeletePoint = { x = -9.36, y = 6598.86, z = 30.47 }

	},

	Garage_MedEndApartment10 = {

		Private = "MedEndApartment10",

		GaragePoint = { x = -365.18, y = 6323.95, z = 28.9 },

		SpawnPoint = { x = -359.49, y = 6327.41, z = 28.83, h = 218.58 },

		DeletePoint = { x = -353.47, y = 6334.57, z = 28.83 }

	}

	-- End of VENT Custom Garages

}
-- End of Private Garages
-------------------------------------- New garage ------------------------------------------

Config.OneBlipName = true
Config.GarageName = "Garázs | Publikus"

--Logging
Config.EnableLogs = true

--Webhooks
Config.GarageWebhook = ""
Config.ImpoundWebhook = ""

--Colours
--use this for help getting decimal colour https://convertingcolors.com/mass-conversion.html
Config.ColourExploit = 16711680
Config.ColourInfo = 65280

--Garages
Config.Garages = {
    ["A"] = {
        ["positions"] = {
            ["menu"] = {
                ["position"] = vector3(215.800, -810.057, 30.72),
            },
            ["spawn"] = {
                ["position"] = vector3(233.446152, -805.463745, 29.886475),
                ["heading"] =  65.19
            },
            ["fospawn"] = {
                ["position"] = vector3(233.446152, -805.463745, 29.886475),
                ["heading"] =  65.19
            },
            ["vehicle"] = {
                ["position"] = vector3(224.13, -759.21, 30.8),
                ["heading"] =  158.47
            }
        },
        ["camera"] = {  -- camera is not needed just if you want cool effects.
        ["x"] = 226.54,
        ["y"] = -808.0,
        ["z"] = 34.0,
        ["rotationX"] = -33.637795701623,
        ["rotationY"] = 0.0,
        ["rotationZ"] = -68.73228356242
    }
},

    ["B"] = {
        ["positions"] = {
            ["menu"] = {
                ["position"] = vector3(1737.59, 3710.2, 34.10),
            },
            ["spawn"] = {
                ["position"] = vector3(1742.729614, 3718.813232, 33.375),
                ["heading"] =  22.51
            },
            ["fospawn"] = {
                ["position"] = vector3(1742.729614, 3718.813232, 33.375),
                ["heading"] =  22.22
            },
            ["vehicle"] = {
                ["position"] = vector3(1722.66, 3713.74, 34.14),
                ["heading"] =  158.47
            }
        },
        ["camera"] = {  -- camera is not needed just if you want cool effects.
        ["x"] = 1733.02,
        ["y"] = 3722.65,
        ["z"] = 38.01,
        ["rotationX"] = -200.7,
        ["rotationY"] = 180.0,
        ["rotationZ"] = 70.8
    }
},

    ["C"] = {
        ["positions"] = {
            ["menu"] = {
                ["position"] = vector3(105.359, 6613.586, 32.5),
            },
            ["spawn"] = {
                ["position"] = vector3(111.69, 6609.11, 31.6),
                ["heading"] =  267.69
            },
            ["fospawn"] = {
                ["position"] = vector3(111.69, 6609.11, 31.6),
                ["heading"] =  267.69
            },
            ["vehicle"] = {
                ["position"] = vector3(127.75, 6624.26, 31.9),
                ["heading"] =  158.47
            }
        },
        ["camera"] = {  -- camera is not needed just if you want cool effects.
        ["x"] = 119.12,
        ["y"] = 6614.85,
        ["z"] = 35.36,
        ["rotationX"] = 150.0,
        ["rotationY"] = 180.0,
        ["rotationZ"] = 300.73228356242
    }
},
    --SANDY
    ["D"] = {
        ["positions"] = {
            ["menu"] = {
                ["position"] = vector3(1846.56, 2585.86, 45.7),
            },
            ["spawn"] = {
                ["position"] = vector3(1856.71, 2593.14, 45.4),
                ["heading"] =  274.33
            },
            ["fospawn"] = {
                ["position"] = vector3(1856.71, 2593.14, 45.4),
                ["heading"] =  274.8
            },
            ["vehicle"] = {
                ["position"] = vector3(1855.21, 2615.3, 45.8),
                ["heading"] =  158.47
            }
        },
        ["camera"] = {  -- camera is not needed just if you want cool effects.
        ["x"] = 1860.41,
        ["y"] = 2587.44,
        ["z"] = 48.07,
        ["rotationX"] = -25.637795701623,
        ["rotationY"] = 0.0,
        ["rotationZ"] = 20.73228356242
    }
},
    --Város      
    ["E"] = {
        ["positions"] = {
            ["menu"] = {
                ["position"] = vector3(598.23, 89.65, 92.9),
            },
            ["spawn"] = {
                ["position"] = vector3(608.38, 104.05, 92.6),
                ["heading"] =  68.46 
            },
            ["fospawn"] = {
                ["position"] = vector3(608.38, 104.05, 92.6),
                ["heading"] =  68.46
            },
            ["vehicle"] = {
                ["position"] = vector3(630.38, 127.09, 92.9),
                ["heading"] =  158.47
            }
        },
        ["camera"] = {  -- camera is not needed just if you want cool effects.
        ["x"] = 610.65,
        ["y"] = 98.12,
        ["z"] = 95.17,
        ["rotationX"] = -23.637795701623,
        ["rotationY"] = 0.0,
        ["rotationZ"] = 16.73228356242
    }
},
    --Grapeseed    
    ["F"] = {
        ["positions"] = {
            ["menu"] = {
                ["position"] = vector3(-1186.720, -1506.341, 4.50),
            },
            ["spawn"] = {
                ["position"] = vector3(-1193.51, -1499.69, 3.98),
                ["heading"] =  305.85
            },
            ["fospawn"] = {
                ["position"] = vector3(-1200.01, -1482.69, 3.98),
                ["heading"] =   215.0
            },
            ["vehicle"] = {
                ["position"] = vector3(-1201.823, -1488.213, 4.5),
                ["heading"] =  158.47
            }
        },
        ["camera"] = {  -- camera is not needed just if you want cool effects.
        ["x"] = -1191.85,
        ["y"] = -1494.21,
        ["z"] = 6.38,
        ["rotationX"] = -25.637795701623,
        ["rotationY"] = 0.0,
        ["rotationZ"] = 170.73228356242
    }
},

["H"] = {
    ["positions"] = {
        ["menu"] = {
            ["position"] = vector3(344.77, -1689.78, 32.7),
        },
        ["spawn"] = {
            ["position"] = vector3(359.604401, -1702.061523, 32.09),
            ["heading"] =  321.19
        },
        ["fospawn"] = {
            ["position"] = vector3(359.604401, -1702.061523, 32.09),
            ["heading"] =   321.19
        },
        ["vehicle"] = {
            ["position"] = vector3( 375.72, -1647.6, 32.7),
            ["heading"] =  158.47
        }
    },
    ["camera"] = {  -- camera is not needed just if you want cool effects.
    ["x"] = 367.44,
    ["y"] = -1701.0,
    ["z"] = 35.48,
    ["rotationX"] = -25.637795701623,
    ["rotationY"] = 0.0,
    ["rotationZ"] = 100.73228356242
}
},

["J"] = {
    ["positions"] = {
        ["menu"] = {
            ["position"] = vector3(-584.37, 195.3, 71.5),
        },
        ["spawn"] = {
            ["position"] = vector3(-589.15, 191.39, 71.0),
            ["heading"] =  89.99
        },
        ["fospawn"] = {
            ["position"] = vector3(-589.15, 191.39, 71.0),
            ["heading"] =   89.0
        },
        ["vehicle"] = {
            ["position"] = vector3(-594.91, 200.9, 71.5),
            ["heading"] =  158.47
        }
    },
    ["camera"] = {  -- camera is not needed just if you want cool effects.
    ["x"] = -586.02,
    ["y"] = 197.72,
    ["z"] = 74.64,
    ["rotationX"] = -33.637795701623,
    ["rotationY"] = 0.0,
    ["rotationZ"] = 150.73228356242
}
},

["K"] = {
    ["positions"] = {
        ["menu"] = {
            ["position"] = vector3(1171.96, -1527.64, 35.1),
        },
        ["spawn"] = {
            ["position"] = vector3(1166.91, -1549.62, 33.88),
            ["heading"] =  271.81
        },
        ["fospawn"] = {
            ["position"] = vector3(1166.8, -1556.24, 34.44),
            ["heading"] =   271.54
        },
        ["vehicle"] = {
            ["position"] = vector3(1211.36, -1540.52, 35.0),
            ["heading"] =  158.47
        }
    },
    ["camera"] = {  -- camera is not needed just if you want cool effects.
    ["x"] = 1170.72,
    ["y"] = -1545.84,
    ["z"] = 36.68,
    ["rotationX"] = -27.637795701623,
    ["rotationY"] = 0.0,
    ["rotationZ"] = 140.73228356242
}
},

["L"] = {
    ["positions"] = {
        ["menu"] = {
            ["position"] = vector3(-1607.23, -1021.73, 13.10),
        },
        ["spawn"] = {
            ["position"] = vector3(-1580.24, -1054.4, 11.8),
            ["heading"] =  73.62
        },
        ["fospawn"] = {
            ["position"] = vector3(-1580.24, -1054.4, 11.8),
            ["heading"] =   73.62
        },
        ["vehicle"] = {
            ["position"] = vector3(-1609.93, -1038.08, 13.2),
            ["heading"] =  158.47
        }
    },
    ["camera"] = {  -- camera is not needed just if you want cool effects.
    ["x"] = -1574.33,
    ["y"] = -1048.0,
    ["z"] = 17.06,
    ["rotationX"] = -33.637795701623,
    ["rotationY"] = 0.0,
    ["rotationZ"] = 120.73228356242
}
},

   --Grove    
    ["G"] = {
        ["positions"] = {
            ["menu"] = {
                ["position"] = vector3(-829.31, -2350.67, 14.7),
            },
            ["spawn"] = {
                ["position"] = vector3(-824.043945, -2359.648438, 14.2498),
                ["heading"] =  331.8
            },
            ["fospawn"] = {
                ["position"] = vector3(-824.043945, -2359.648438, 14.2498),
                ["heading"] =  331.8
            },
            ["vehicle"] = {
                ["position"] = vector3(-818.42, -2389.9, 14.7),
                ["heading"] =  158.47
            }
        },
        ["camera"] = {  -- camera is not needed just if you want cool effects.
        ["x"] = -825.82,
        ["y"] = -2351.72,
        ["z"] = 17.07,
        ["rotationX"] = -26.637795701623,
        ["rotationY"] = 0.0,
        ["rotationZ"] = 200.73228356242
    }
},

-- Kikötő
    ["N"] = {
        ["positions"] = {
            ["menu"] = {
                ["position"] = vector3(841.753845, -3205.846191, 6.010254),
            },
            ["spawn"] = {
                ["position"] = vector3(834.527466, -3210.145020, 5.454224),
                ["heading"] =  175.74
            },
            ["fospawn"] = {
                ["position"] = vector3(834.527466, -3210.145020, 5.454224),
                ["heading"] =  175.74
            },
            ["vehicle"] = {
                ["position"] = vector3(849.151672, -3207.388916, 5.892334),
                ["heading"] =  158.47
            }
        },
        ["camera"] = {  -- camera is not needed just if you want cool effects.
        ["x"] = 841.82,
        ["y"] = -3213.72,
        ["z"] = 9.47,
        ["rotationX"] = -23.637795701623,
        ["rotationY"] = 0.0,
        ["rotationZ"] = 50.73228356242
    }
},


-- Város
    ["O"] = {
        ["positions"] = {
            ["menu"] = {
                ["position"] = vector3(-657.520874, -735.903320, 27.224121),
            },
            ["spawn"] = {
                ["position"] = vector3(-666.989014, -743.828552, 26.567017),
                ["heading"] =  0.0
            },
            ["fospawn"] = {
                ["position"] = vector3(-666.989014, -743.828552, 26.567017),
                ["heading"] =  0.0
            },
            ["vehicle"] = {
                ["position"] = vector3(-666.567017, -732.474731, 27.216479),
                ["heading"] =  158.47
            }
        },
        ["camera"] = {  -- camera is not needed just if you want cool effects.
        ["x"] = -672.82,
        ["y"] = -738.72,
        ["z"] = 29.47,
        ["rotationX"] = -22.637795701623,
        ["rotationY"] = 0.0,
        ["rotationZ"] = 220.73228356242
    }
},

-- Sandy mellett
    ["P"] = {
        ["positions"] = {
            ["menu"] = {
                ["position"] = vector3(2136.118652, 4792.140625, 40.956787),
            },
            ["spawn"] = {
                ["position"] = vector3(2140.443848, 4785.389160, 40.333374),
                ["heading"] =  22.67
            },
            ["fospawn"] = {
                ["position"] = vector3(2140.443848, 4785.389160, 40.333374),
                ["heading"] =  22.67
            },
            ["vehicle"] = {
                ["position"] = vector3(2133.270264, 4777.173828, 41.033374),
                ["heading"] =  158.47
            }
        },
        ["camera"] = {  -- camera is not needed just if you want cool effects.
        ["x"] = 2135.82,
        ["y"] = 4786.72,
        ["z"] = 42.47,
        ["rotationX"] = -22.63779501623,
        ["rotationY"] = 0.0,
        ["rotationZ"] = 250.73228356242
    }
},

-- Város szerelő mellett
    ["Q"] = {
        ["positions"] = {
            ["menu"] = {
                ["position"] = vector3(1038.145020, -764.241760, 57.907715),
            },
            ["spawn"] = {
                ["position"] = vector3(1045.780273, -774.527466, 57.385376),
                ["heading"] =  90.67
            },
            ["fospawn"] = {
                ["position"] = vector3(1045.780273, -774.527466, 57.385376),
                ["heading"] =  90.67
            },
            ["vehicle"] = {
                ["position"] = vector3(1011.692322, -765.916504, 57.950488),
                ["heading"] =  158.47
            }
        },
        ["camera"] = {  -- camera is not needed just if you want cool effects.
        ["x"] = 1041.82,
        ["y"] = -779.72,
        ["z"] = 60.47,
        ["rotationX"] = -23.637795701623,
        ["rotationY"] = 0.0,
        ["rotationZ"] = 318.73228356242
    }
},

-- Vadászat mellett
    ["R"] = {
        ["positions"] = {
            ["menu"] = {
                ["position"] = vector3(-773.353821, 5597.881348, 33.593384),
            },
            ["spawn"] = {
                ["position"] = vector3(-773.182434, 5578.338379, 32.852051),
                ["heading"] =  87.67
            },
            ["fospawn"] = {
                ["position"] = vector3(-773.182434, 5578.338379, 32.852051),
                ["heading"] =  87.67
            },
            ["vehicle"] = {
                ["position"] = vector3(-776.189026, 5589.151855, 33.352051),
                ["heading"] =  158.47
            }
        },
        ["camera"] = {  -- camera is not needed just if you want cool effects.
        ["x"] = -777.82,
        ["y"] = 5585.72,
        ["z"] = 35.47,
        ["rotationX"] = -18.637795701623,
        ["rotationY"] = 0.0,
        ["rotationZ"] = 208.73228356242
    }
},

-- Vadászat mellett
    ["S"] = {
        ["positions"] = {
            ["menu"] = {
                ["position"] = vector3(-48.817581, 1884.435181, 195.419067),
            },
            ["spawn"] = {
                ["position"] = vector3(-43.476921, 1880.373657, 195.385376),
                ["heading"] =  147.67
            },
            ["fospawn"] = {
                ["position"] = vector3(-43.476921, 1880.373657, 195.385376),
                ["heading"] =  147.67
            },
            ["vehicle"] = {
                ["position"] = vector3(-61.542854, 1892.030762, 195.999951),
                ["heading"] =  158.47
            }
        },
        ["camera"] = {  -- camera is not needed just if you want cool effects.
        ["x"] = -51.82,
        ["y"] = 1878.72,
        ["z"] = 197.47,
        ["rotationX"] = -18.637795701623,
        ["rotationY"] = 0.0,
        ["rotationZ"] = 280.73228356242
    }
},

-- Vadászat mellett
    ["SZ"] = {
        ["positions"] = {
            ["menu"] = {
                ["position"] = vector3(-1642.443970, -215.261536, 55.329712),
            },
            ["spawn"] = {
                ["position"] = vector3(-1654.615356, -195.454941, 54.756836),
                ["heading"] =  252.67
            },
            ["fospawn"] = {
                ["position"] = vector3(-1654.615356, -195.454941, 54.756836),
                ["heading"] =  252.67
            },
            ["vehicle"] = {
                ["position"] = vector3(-1624.707642, -208.391205, 55.01),
                ["heading"] =  158.47
            }
        },
        ["camera"] = {  -- camera is not needed just if you want cool effects.
        ["x"] = -1652.82,
        ["y"] = -202.72,
        ["z"] = 57.47,
        ["rotationX"] = -18.637795701623,
        ["rotationY"] = 0.0,
        ["rotationZ"] = 15.73228356242
    }
},

-- Vadászat mellett
    ["T"] = {
        ["positions"] = {
            ["menu"] = {
                ["position"] = vector3(-346.826355, -874.707703, 31.082764),
            },
            ["spawn"] = {
                ["position"] = vector3(-343.872528, -876.540649, 30.442505),
                ["heading"] =  167.67
            },
            ["fospawn"] = {
                ["position"] = vector3(-343.872528, -876.540649, 30.442505),
                ["heading"] =  167.67
            },
            ["vehicle"] = {
                ["position"] = vector3(-360.303284, -889.252747, 31.0659),
                ["heading"] =  158.47
            }
        },
        ["camera"] = {  -- camera is not needed just if you want cool effects.
        ["x"] = -350.82,
        ["y"] = -879.72,
        ["z"] = 32.47,
        ["rotationX"] = -18.637795701623,
        ["rotationY"] = 0.0,
        ["rotationZ"] = 295.73228356242
    }
},

-- Keleti
    ["U"] = {
        ["positions"] = {
            ["menu"] = {
                ["position"] = vector3(-2201.393, 4248, 47.83154),
            },
            ["spawn"] = {
                ["position"] = vector3(-2206.127, 4248.896, 47.09009),
                ["heading"] =  36.8504
            },
            ["fospawn"] = {
                ["position"] = vector3(-2206.127, 4248.896, 47.09009),
                ["heading"] =  36.8504
            },
            ["vehicle"] = {
                ["position"] = vector3(-2218.642, 4234.444, 47.3374),
                ["heading"] =  158.47
            }
        },
        ["camera"] = {  -- camera is not needed just if you want cool effects.
        ["x"] = -2204.11,
        ["y"] = 4257.16,
        ["z"] = 49.55,
        ["rotationX"] = -13.637795701623,
        ["rotationY"] = 0.0,
        ["rotationZ"] = 158.73228356242
    }
},

-- Hajó mellett
    ["V"] = {
        ["positions"] = {
            ["menu"] = {
                ["position"] = vector3(-753.6, -1511.697, 5.016113),
            },
            ["spawn"] = {
                ["position"] = vector3(-743.222, -1503.969, 4.375854),
                ["heading"] =  19.84252
            },
            ["fospawn"] = {
                ["position"] = vector3(-743.222, -1503.969, 4.375854),
                ["heading"] =  19.84252
            },
            ["vehicle"] = {
                ["position"] = vector3(-732.5275, -1497.349, 4.875854),
                ["heading"] =  158.47
            }
        },
        ["camera"] = {  -- camera is not needed just if you want cool effects.
        ["x"] = -750.81,
        ["y"] = -1500.16,
        ["z"] = 6.75,
        ["rotationX"] = -13.637795701623,
        ["rotationY"] = 0.0,
        ["rotationZ"] = 248.73228356242
    }
},

-- Város
    ["Z"] = {
        ["positions"] = {
            ["menu"] = {
                ["position"] = vector3(67.84615, 13.06813, 69.21387),
            },
            ["spawn"] = {
                ["position"] = vector3(54.55384, 19.62198, 68.94434),
                ["heading"] =  340.1575
            },
            ["fospawn"] = {
                ["position"] = vector3(54.55384, 19.62198, 68.94434),
                ["heading"] =  340.1575
            },
            ["vehicle"] = {
                ["position"] = vector3(58.81319, 29.70989, 69.99929),
                ["heading"] =  158.47
            }
        },
        ["camera"] = {  -- camera is not needed just if you want cool effects.
        ["x"] = 61.81,
        ["y"] = 21.16,
        ["z"] = 70.75,
        ["rotationX"] = -13.637795701623,
        ["rotationY"] = 0.0,
        ["rotationZ"] = 99.73228356242
    }
},

-- Város
    ["ZS"] = {
        ["positions"] = {
            ["menu"] = {
                ["position"] = vector3(-1513.358, -589.9648, 23.51721),
            },
            ["spawn"] = {
                ["position"] = vector3(-1517.776, -601.556, 22.64099),
                ["heading"] =  0.1
            },
            ["fospawn"] = {
                ["position"] = vector3(-1517.776, -601.556, 22.64099),
                ["heading"] =  0.1
            },
            ["vehicle"] = {
                ["position"] = vector3(-1505.341, -587.5648, 23.39),
                ["heading"] =  158.47
            }
        },
        ["camera"] = {  -- camera is not needed just if you want cool effects.
        ["x"] = -1522.11,
        ["y"] = -597.36,
        ["z"] = 24.55,
        ["rotationX"] = -13.637795701623,
        ["rotationY"] = 0.0,
        ["rotationZ"] = 223.73228356242
    }
},

-- cayo
    ["CAYO"] = {
        ["positions"] = {
            ["menu"] = {
                ["position"] = vector3(4442.044, -4478.756, 4.32),
            },
            ["spawn"] = {
                ["position"] = vector3(4438.062, -4469.67, 3.88),
                ["heading"] =  201.1
            },
            ["fospawn"] = {
                ["position"] = vector3(4438.062, -4469.67, 3.88),
                ["heading"] =  201.1
            },
            ["vehicle"] = {
                ["position"] = vector3(4440.765, -4457.183, 4.38),
                ["heading"] =  158.47
            }
        },
        ["camera"] = {  -- camera is not needed just if you want cool effects.
        ["x"] = 4443.71,
        ["y"] = -4472.56,
        ["z"] = 5.55,
        ["rotationX"] = -13.637795701623,
        ["rotationY"] = 0.0,
        ["rotationZ"] = 65.73
    }
},

    ["M"] = {
        ["positions"] = {
            ["menu"] = {
                ["position"] = vector3(-3238.008789, 986.808777, 12.49),
            },
            ["spawn"] = {
                ["position"] = vector3(-3245.60, 987.52, 11.09),
                ["heading"] =  0.1
            },
            ["fospawn"] = {
                ["position"] = vector3(-3245.60, 987.52, 11.09),
                ["heading"] =  0.1
            },
            ["vehicle"] = {
                ["position"] = vector3(-3253.094482, 987.692322, 12.446899),
                ["heading"] =  158.47
            }
        },
        ["camera"] = {  -- camera is not needed just if you want cool effects.
        ["x"] = -3250.42,
        ["y"] = 991.72,
        ["z"] = 14.07,
        ["rotationX"] = -25.637795701623,
        ["rotationY"] = 0.0,
        ["rotationZ"] = 225.73228356242
        }
    }
}
Config.Labels = {
    ["menu"] = "~w~Nyomd meg a(z)~r~ ~INPUT_CONTEXT~ ~w~ hogy megnyisd a(z) %s garázst.~r~",
    ["vehicle"] = "~w~Nyomd meg a(z) ~INPUT_CONTEXT~ hogy beparkolj a garázsba~r~",
    ["spawn"] = "",
    ["fospawn"] = ""
}

Config.Trim = function(value)
    if value then
        return (string.gsub(value, "^%s*(.-)%s*$", "%1"))
    else
        return nil
    end
end

Config.AlignMenu = "bottom-right" -- this is where the menu is located [left, right, center, top-right, top-left etc.]
