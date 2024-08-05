Config = {}

Config.Debug = true
Config.ServerSpawn = true
Config.Oxlib = true
Config.Locale = 'en'
Config.OneBlipName = true
Config.UseCommand = false
Config.LegacyFuel = true -- ture = Using LegacyFuel & you want Fuel to Save.
Config.KickPossibleCheaters = true -- If true it will kick the player that tries store a vehicle that they changed the Hash or Plate.
Config.UseCustomKickMessage = true -- If KickPossibleCheaters is true you can set a Custom Kick Message in the locales.
Config.UseDamageMult = true -- If true it costs more to store a Broken Vehicle.
Config.DamageMult = 3 -- Higher Number = Higher Repair Price.
Config.GiveSocietyMoney = false
Config.CarPoundPrice      = 1500 -- Car Pound Price.
Config.BoatPoundPrice     = 500 -- Boat Pound Price.
Config.AircraftPoundPrice = 3000 -- Aircraft Pound Price.
Config.PolicePoundPrice  = 300 -- Policing Pound Price.
Config.TaxiPoundPrice  = 300 -- Taxi Pound Price.
Config.SheriffPoundPrice  = 300 -- Policing Pound Price.
Config.AmbulancePoundPrice = 300 -- Ambulance Pound Price.
Config.UseCarGarages        = true -- Allows use of Car Garages.
Config.UseBoatGarages       = true -- Allows use of Boat Garages.
Config.UseAircraftGarages   = true -- Allows use of Aircraft Garages.
Config.UsePrivateCarGarages = false -- Allows use of Private Car Garages.
Config.UseJobCarGarages     = true -- Allows use of Job Garages.
Config.Parkvehicles         = false --All Vehicles are Stored on restart
Config.ShowVehicleLocation  = true -- If set to true it will show the Location of the Vehicle in the Pound/Garage in the Garage menu.
Config.UseVehicleNamesLua   = false -- Must setup a vehicle_names.lua for Custom Addon Vehicles.
Config.MarkerType   = 6
Config.DrawDistance = 55.0
Config.MarkerDistance = 2.0
Config.MarkerDistance2 = 20.0
Config.GarageName = "Garázs | Publikus"
Config.ImpoundName = "Garázs | Lefoglalt"
Config.Labels = {
    menu = "~w~Nyomd meg a(z)~r~ ~INPUT_CONTEXT~ ~w~ hogy megnyisd a(z) %s garázst.~r~",
    vehicle = "~w~Nyomd meg a(z) ~INPUT_CONTEXT~ hogy beparkolj a garázsba~r~"
}

Config.Trim = function(value)
    if value then
        return (string.gsub(value, "^%s*(.-)%s*$", "%1"))
    else
        return nil
    end
end

Config.AlignMenu = "top-left" -- this is where the menu is located [left, right, center, top-right, top-left etc.]
--Logging
Config.EnableLogs = false

--Webhooks
Config.GarageWebhook = ""
Config.ImpoundWebhook = ""

--Colours
--use this for help getting decimal colour https://convertingcolors.com/mass-conversion.html
Config.ColourExploit = 16711680
Config.ColourInfo = 65280

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

--Garages
Config.Garages = {
    {
        garage = "A",
        menuposition = vec3(215.80, -810.05, 30.72),
        spawnposition = {
			vec4(233.44, -805.46, 29.88, 68.03),
			vec4(231.2967, -809.2615, 30.00439, 68.03149),
			vec4(234.1187, -799.978, 30.03809, 68.03149),
			vec4(236.3604, -795.0461, 30.05493, 68.03149),
			vec4(238.8396, -806.3736, 29.88647, 345.8268)
		},
        vehicleposition = vec3(224.13, -759.21, 30.8),
        camera = vec3(226.54, -808.01, 34.01),
        camrotation = vec3(-33.63, 0.0, -68.73)

    },
	{
        garage = "A1",
        menuposition = vec3(57.12, -874.02, 30.44),
        spawnposition = {
			vec4(60.59, -866.29, 30.12, 340.15),
			vec4(57.44, -865.01, 30.13, 342.99),
			vec4(54.07, -863.90, 30.13, 340.15),
			vec4(50.95, -862.56, 30.15, 342.99),
			vec4(47.51, -861.54, 30.15, 342.99),
			vec4(50.70, -873.17, 30.00, 158.74)
		},
        vehicleposition = vec3(26.94, -892.10, 30.18),
        camera = vec3(48.79, -844.37, 34.63),
        camrotation = vec3(-3.63, 0.0, -168.73)

    },
	{
        garage = "A2",
        menuposition = vec3(99.824181, -1075.437378, 29.229248),
        spawnposition = {
			vec4(119.037361, -1070.188965, 28.757568, 0.00),
			vec4(122.360443, -1069.951660, 28.757568, 0.00),
			vec4(125.657143, -1069.912109, 28.757568, 0.00),
			vec4(128.940659, -1069.648315, 28.757568, 0.00)
		},
        vehicleposition = vec3(104.53, -1078.36, 29.45),
        camera = vec3(110.228569, -1056.461548, 33.239502),
        camrotation = vec3(-3.63, 0.0, -148.73)

    },
    {
        garage = "B",
        menuposition = vec3(1737.59, 3710.2, 34.10),
        spawnposition = {
			vec4(1742.72, 3718.81, 33.37, 17.47),
		},
        vehicleposition = vec3(1722.66, 3713.74, 34.14),
        camera = vec3(1733.02, 3722.65, 38.01),
        camrotation = vec3(-150.7, 180.0, 70.8)
    },
	{
        garage = "C",
        menuposition = vec3(105.359, 6613.586, 32.5),
        spawnposition = {
			vec4(111.69, 6609.11, 31.6, 267.69),
		},
        vehicleposition = vec3(127.75, 6624.26, 31.9),
        camera = vec3(119.12, 6614.85, 35.36),
        camrotation = vec3(200.01, 180.01, 300.73)
    },
    {
		garage = "D",
        menuposition = vec3(1846.56, 2585.86, 45.7),
        spawnposition = {
			vec4(1856.71, 2593.14, 45.4, 274.33),
		},
        vehicleposition = vec3(1855.21, 2615.3, 45.8),
        camera = vec(1860.41, 2587.44, 48.07),
        camrotation = vec3(-25.63, 0.01, 20.73)
    },
    {
		garage = "E",
        menuposition = vec3(598.23, 89.65, 92.9),
        spawnposition = {
			vec4(608.38, 104.05, 92.6, 68.46),
			vec4(610.3912, 111.5209, 92.50037, 68.03149)
		},
        vehicleposition = vec3(630.38, 127.09, 92.9),
        camera = vec3(610.65, 98.12, 95.17),
        camrotation = vec3(-23.63, 0.0, 16.73)
    },
    {
		garage = "F",
        menuposition = vec3(-1186.720, -1506.341, 4.50),
        spawnposition = {
			vec4(-1193.51, -1499.69, 3.98, 305.85),
		},
        vehicleposition = vec3(-1201.823, -1488.213, 4.51),
        camera = vec3(-1191.85, -1494.21, 6.38),
        camrotation = vec3(-25.63, 0.0, 170.73)
    },
    {
		garage = "H",
        menuposition = vec3(344.77, -1689.78, 32.7),
        spawnposition = {
			vec4(359.604401, -1702.061523, 32.09, 321.19),
		},
        vehicleposition = vec3( 375.72, -1647.6, 32.7),
        camera = vec3(367.44, -1701.01, 35.48),
        camrotation = vec3(-25.63, 0.0, 100.73)
    },
    {
        garage = "J",
        menuposition = vec3(-584.37, 195.3, 71.5),
        spawnposition = {
			vec4(-589.15, 191.39, 71.01, 89.99),
		},
        vehicleposition = vec3(-594.91, 200.9, 71.5),
        camera = vec3(-586.02, 197.72, 74.64),
        camrotation = vec3(-33.63, 0.0, 150.73)
    },
    {
		garage = "K",
        menuposition = vec3(1171.96, -1527.64, 35.1),
        spawnposition = {
			vec4(1166.91, -1549.62, 33.88, 271.81),
			vec4(1167.534, -1553.103, 34.25061, 269.2914),
			vec4(1167.521, -1556.677, 34.25061, 272.126)
		},
        vehicleposition = vec3(1211.36, -1540.52, 35.0),
        camera = vec3(1170.72, -1545.84, 36.68),
        camrotation = vec3(-27.63, 0.0, 140.73)
    },
    {
		garage = "L",
        menuposition = vec3(-1607.23, -1021.73, 13.10),
        spawnposition = {
			vec4(-1580.24, -1054.4, 11.8, 73.62),
		},
        vehicleposition = vec3(-1609.93, -1038.08, 13.2),
        camera = vec3(-1574.33, -1048.0, 17.06),
        camrotation = vec3(-33.63, 0.0, 120.73)
    },
	{
        garage = "G",
        menuposition = vec3(-829.31, -2350.67, 14.7),
        spawnposition = {
			vec4(-824.04, -2359.64, 14.24, 331.80),
		},
        vehicleposition = vec3(-818.42, -2389.9, 14.7),
        camera = vec3(-825.82,-2351.72, 17.07),
        camrotation = vec3(-26.63, 0.0, 200.73)
    },
	{
		garage = "N",
        menuposition = vec3(841.753845, -3205.846191, 6.010254),
        spawnposition = {
			vec4(834.527466, -3210.145020, 5.454, 175.74),
		},
        vehicleposition = vec3(849.151672, -3207.388916, 5.892334),
        camera = vec3(841.82, -3213.72, 9.47),
        camrotation = vec3(-23.63, 0.0, 50.73)
    },
	{
		garage = "O",
        menuposition = vec3(-657.520874, -735.903320, 27.224121),
        spawnposition = {
			vec4(-666.989014, -743.828552, 26.567017, 0.01),
		},
        vehicleposition = vec3(-666.567017, -732.474731, 27.216479),
        camera = vec3(-672.82, -738.72, 29.47),
        camrotation = vec3(-22.637795701623, 0.0, 220.73)
    },
    {
		garage = "P",
        menuposition = vec3(2136.118652, 4792.140625, 40.956787),
        spawnposition = {
			vec4(2140.443848, 4785.389160, 40.333374, 22.67),
		},
        vehicleposition = vec3(2133.270264, 4777.173828, 41.033374),
        camera = vec3(2135.82, 4786.72, 42.47),
        camrotation = vec3(-22.637, 0.0, 250.73)
    },
    {
		garage = "Q",
        menuposition = vec3(1038.145020, -764.241760, 57.907715),
        spawnposition = {
			vec4(1045.780273, -774.527466, 57.385376, 90.67),
			vec4(1045.332, -781.978, 57.55383, 87.87402),
			vec4(1041.864, -790.3912, 57.53699, 0.00)
		},
        vehicleposition = vec3(1011.692322, -765.916504, 57.950488),
        camera = vec3(1027.82, -789.72, 60.47),
        camrotation = vec3(-10.63, 0.0, 278.73)
    },
    {
		garage = "R",
		menuposition = vec3(-773.353821, 5597.881348, 33.593384),
        spawnposition = {
			vec4(-773.182434, 5578.338379, 32.852051, 87.67),
		},
        vehicleposition = vec3(-776.189026, 5589.151855, 33.352051),
        camera = vec3(-777.82, 5585.72, 35.47),
        camrotation = vec3(-18.63, 0.0, 208.73)
    },
	{
		garage = "S",
		menuposition = vec3(-48.817581, 1884.435181, 195.419067),
        spawnposition = {
			vec4(-43.476921, 1880.373657, 195.385376, 147.67),
		},
        vehicleposition = vec3(-61.542854, 1892.030762, 195.999951),
        camera = vec3(-51.82, 1878.72, 197.47),
        camrotation = vec3(-18.63, 0.0, 280.73)
    },
	{
		garage = "SZ",
		menuposition = vec3(-1642.443970, -215.261536, 55.329712),
        spawnposition = {
			vec4(-1654.615356, -195.454941, 54.756836, 252.67),
		},
        vehicleposition = vec3(-1624.707642, -208.391205, 55.01),
        camera = vec3(-1652.82, -202.72, 57.47),
        camrotation = vec3(-18.637, 0.0, 15.73)
    },
	{
		garage = "T",
		menuposition = vec3(-346.826355, -874.707703, 31.082764),
        spawnposition = {
			vec4(-343.872528, -876.540649, 30.442505, 167.67),
			vec4(-336.8571, -878.4264, 30.62781, 164.4095)
		},
        vehicleposition = vec3(-360.303284, -889.252747, 31.0659),
        camera = vec3(-350.82, -879.72, 32.47),
        camrotation = vec3(-18.63, 0.0, 295.73)
    },
	{
		garage = "U",
		menuposition = vec3(-2201.393, 4248, 47.83154),
        spawnposition = {
			vec4(-2206.127, 4248.896, 47.09, 36.85),
		},
        vehicleposition = vec3(-2218.642, 4234.444, 47.3374),
        camera = vec3(-2204.11, 4257.16, 49.55),
        camrotation = vec3(-13.63, 0.0, 158.73)
    },
	{
		garage = "V",
        menuposition = vec3(-753.6, -1511.697, 5.016113),
        spawnposition = {
			vec4(-743.222, -1503.969, 4.37, 19.84),
		},
        vehicleposition = vec3(-732.5275, -1497.349, 4.875854),
        camera = vec3(-750.81, -1500.16, 6.75),
        camrotation = vec3(-13.63, 0.0, 248.73)
    },
	{
		garage = "Z",
		menuposition = vec3(67.84615, 13.06813, 69.21387),
        spawnposition = {
			vec4(54.55384, 19.62198, 68.94, 340.15),
		},
        vehicleposition = vec3(58.81319, 29.70989, 69.99929),
        camera = vec3(61.81, 21.16, 70.75),
        camrotation = vec3(-13.63, 0.0, 99.73)
    },
	{
		garage = "ZS",
		menuposition = vec3(-1513.358, -589.9648, 23.51721),
        spawnposition = {
			vec4(-1517.776, -601.556, 22.64099, 0.11),
		},
        vehicleposition = vec3(-1505.341, -587.5648, 23.39),
        camera = vec3(-1524.55, -592.96, 26.17),
        camrotation = vec3(-13.63, 0.0, 223.73)
    },
	{
		garage = "CAYO",
        menuposition = vec3(4442.044, -4478.756, 4.32),
        spawnposition = {
			vec4(4438.062, -4469.67, 3.88, 201.11),
		},
		vehicleposition = vec3(4440.765, -4457.183, 4.38),
        camera = vec3(4443.71, -4472.56, 5.55),
        camrotation = vec3(-13.637795701623, 0.0, 65.73)
    },
	{
		garage = "M",
        menuposition = vec3(-3238.008789, 986.808777, 12.49),
        spawnposition = {
			vec4(-3245.60, 987.52, 11.09, 0.11),
		},
        vehicleposition = vec3(-3253.094482, 987.692322, 12.446899),
        camera = vec3(-3250.42, 991.72, 14.07),
        camrotation = vec3(-25.63, 0.0, 225.73)
    },
	{
		garage = "NBR",
        menuposition = vec3(3587.02, -6612.80, 1389.88),
        spawnposition = {
			vec4(3588.00, -6609.11, 1389.88, 226.71),
		},
        vehicleposition = vec3(3591.69, -6603.13, 1389.88),
        camera = vec3(3603.42, -6613.26, 1392.44),
        camrotation = vec3(-25.63, 0.0, -288.73)
    },
	{
		garage = "M1",
        menuposition = vec3(477.28, 5392.14, 671.76),
        spawnposition = {
			vec4(471.54, 5390.42, 670.60, 0.0),
		},
        vehicleposition = vec3(456.94, 5384.69, 671.56),
        camera = vec3(459.65, 5401.72, 674.07),
        camrotation = vec3(-5.63, 0.0, 205.73)
    }
}

-- Start of Cars
Config.CarPounds = {
	Pound_LosSantos = {
		PoundPoint = vec3(408.61, -1625.47, 28.29),
		SpawnPoint = {
			vec4(405.64, -1643.40, 27.61, 229.54),
			vec4(409.01, -1638.96, 29.01, 229.60),
			vec4(400.06, -1638.19, 29.01, 323.14)
		},
		cam = vec3(421.411, -1633.965, 33.391),
		camrot = vec3(-25.63, 0.0, 105.73)
	},

	Pound_Sandy = {
		PoundPoint = vec3(1651.38, 3804.84, 37.65),
		SpawnPoint = {
			vec4(1627.873, 3789.679, 34.38538, 306.1417),
			vec4(1633.266, 3785.143, 34.36853, 306.1417)
		},
		cam = vec3(1644.053, 3805.793, 40.66),
		camrot = vec3(-20.63, 0.0, 135.73)
	},

	Pound_Paleto = {
		PoundPoint = vec3(-234.82, 6198.65, 30.94),
		SpawnPoint = {
			vec4(-229.1736, 6196.114, 31.21753, 136.063),
			vec4(-222.2242, 6188.347, 31.21753, 136.063)
	    },
	    cam = vec3(-240.7516, 6180.171, 35.75),
	    camrot = vec3(-15.63, 0.0, 305.73)
	}
}
-- End of Cars

-- Start of Jobs
Config.PolicePounds = {

	Pound_LosSantos = {

		PoundPoint = vec3(374.42, -1620.68, 28.29),

		SpawnPoint = vec4(391.74, -1619.0, 28.29, 318.34)

	},

	Pound_Sandy = {

		PoundPoint = vec3(1646.01, 3812.06, 37.65),

		SpawnPoint = vec4(1627.84, 3788.45, 33.77, 308.53)

	},

	Pound_Paleto = {

		PoundPoint = vec3(-223.6, 6243.37, 30.49),

		SpawnPoint = vec4(-230.88, 6255.89, 30.49, 136.5)

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

-- Start of Boats
Config.BoatGarages = {
	Garage_LSDock = {
		GaragePoint = vec3(-781.49, -1487.48, 1.34),
		SpawnPoint = {
		    vec4(-801.17, -1504.18, 0.17, 107.01),
			vec4(-809.6572, -1506.422, 0.112793, 107.7165)
		},
		DeletePoint = vec3(-795.15, -1488.31, 0.47),
		cam = vec3(-823.5033, -1495.2, 6.364136),
	    camrot = vec3(-15.63, 0.0, 245.73)
	},

	Garage_SandyDock = {
		GaragePoint = vec3(1333.2, 4269.92, 30.5),
		SpawnPoint = {
			vec4(1334.61, 4264.68, 29.86, 87.01)
		},
		DeletePoint = vec3(1323.73, 4269.94, 30.36),
		cam = vec3(1348.655, 4231.082, 39.94),
	    camrot = vec3(-15.63, 0.0, 15.73)
	},

	Garage_PaletoDock = {
		GaragePoint = vec3(-283.74, 6629.51, 6.3),
		SpawnPoint = {
			vec4(-290.46, 6622.72, -0.47, 52.01)
		},
		DeletePoint = vec3(-304.66, 6607.36, 0.1747),
		cam = vec3(-318.6198, 6623.842, 7.24),
	    camrot = vec3(-15.63, 0.0, 262.73)
	},

	Garage_CayoPerico = {
		GaragePoint = vec3(5140.57, -4645.16, 0.61),
		SpawnPoint = {
			vec4(5143.84, -4645.91, 0.41, 164.40)
		},
		DeletePoint = vec3(5145.78, -4644.18, 0.33),
		cam = vec3(5136.198, -4670.95, 6.68),
	    camrot = vec3(-15.63, 0.0, 345.73)
	},
}



Config.BoatPounds = {
	Pound_LSDock = {
		PoundPoint = vec3(-738.67, -1400.43, 4.0),
		SpawnPoint = {
			vec4(-738.33, -1381.51, 0.12, 137.85),
		},
		cam = vec3(-770.5187, -1393.49, 7.69),
	    camrot = vec3(-15.63, 0.0, 285.73)
	},

	Pound_SandyDock = {
		PoundPoint = vec3(1299.36, 4217.93, 32.91),
		SpawnPoint = {
			vec4(1287.89, 4222.998, 29.98755, 164.40),
		},
		cam = vec3(1271.829, 4179.93, 44.76),
	    camrot = vec3(-15.63, 0.0, -20.73)

	},

	Pound_PaletoDock = {

		PoundPoint = vec3(-270.2, 6642.43, 6.36),
		SpawnPoint = {
			vec4(-290.38, 6638.54, -0.47, 130.01),
		},
		cam = vec3(-309.2044, 6657.297, 10.37),
	    camrot = vec3(-20.63, 0.0, 225.73)
	},
}
-- End of Boats

-- Start of Aircrafts
Config.AircraftGarages = {

	Garage_LSAirport = {

		GaragePoint = vec3(-1617.14, -3145.52, 12.99),
		SpawnPoint = {
			vec4(-1657.99, -3134.38, 12.99, 330.11),
		},
		DeletePoint = vec3(-1642.62, -3143.25, 12.99),
		cam = vec3(-1615.556, -3098.11, 22.01),
	    camrot = vec3(-5.63, 0.0, 125.73)
	},

	Garage_SandyAirport = {

		GaragePoint = vec3(1723.84, 3288.29, 40.16),
		SpawnPoint = {
			vec4(1710.85, 3259.06, 40.69, 104.66),
		},
		DeletePoint = vec3(1714.45, 3246.75, 40.07),
		cam = vec3(1765.516, 3260.822, 47.73),
	    camrot = vec3(-5.63, 0.0, 85.3)
	},

	Garage_CayoPerico = {

		GaragePoint = vec3(4449.56, -4476.07, 3.32),
		SpawnPoint = {
			vec4(4450.33, -4490.57, 4.21, 194.66),
		},
		DeletePoint = vec3(4465.35, -4497.11, 2.41),
		cam = vec3(4495.82, -4497.284, 9.38),
	    camrot = vec3(-10.63, 0.0, 75.73)
	},

	Garage_GrapeseedAirport = {

		GaragePoint = vec3(2152.83, 4797.03, 40.19),
		SpawnPoint = {
			vec4(2122.72, 4804.85, 40.78, 115.04),
		},
		DeletePoint = vec3(2082.36, 4806.06, 40.07),
		cam = vec3(2090.11, 4806.58, 47.67),
	    camrot = vec3(-5.63, 0.0, 265.73)
	}
}

Config.AircraftPounds = {

	Pound_LSAirport = {

		PoundPoint = vec3(-1243.0, -3391.92, 12.94),
		SpawnPoint = {
			vec4(-1272.27, -3382.46, 12.94, 330.25),
		},
		cam = vec3(-1233.824, -3353.433, 20.07),
	    camrot = vec3(-5.63, 0.0, 125.73)
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
