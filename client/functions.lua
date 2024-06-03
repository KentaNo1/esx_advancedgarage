Stopmove = false

function Stopmov()
    CreateThread(function()
        local DisableControlAction = DisableControlAction
        while Stopmove do
            DisableControlAction(0, 32, true) -- W
            DisableControlAction(0, 34, true) -- A
            DisableControlAction(0, 31, true) -- S (fault in Keys table!)
            DisableControlAction(0, 30, true) -- D (fault in Keys table!)
            DisableControlAction(0, 23, true) -- F
            DisableControlAction(0, 59, true) -- Disable steering in vehicle
            DisableControlAction(0, 36, true) -- Disable going stealth
            DisableControlAction(0, 47, true)  -- Disable weapon
            DisableControlAction(0, 264, true) -- Disable melee
            DisableControlAction(0, 257, true) -- Disable melee
            DisableControlAction(0, 140, true) -- Disable melee
            DisableControlAction(0, 141, true) -- Disable melee
            DisableControlAction(0, 142, true) -- Disable melee
            DisableControlAction(0, 143, true) -- Disable melee
            DisableControlAction(0, 75, true)  -- Disable exit vehicle
            DisableControlAction(27, 75, true) -- Disable exit vehicle
            DisableControlAction(0, 69, true) -- INPUT_VEH_ATTACK
            DisableControlAction(0, 92, true) -- INPUT_VEH_PASSENGER_ATTACK
            DisableControlAction(0, 114, true) -- INPUT_VEH_FLY_ATTACK
            DisableControlAction(0, 140, true) -- INPUT_MELEE_ATTACK_LIGHT
            DisableControlAction(0, 141, true) -- INPUT_MELEE_ATTACK_HEAVY
            DisableControlAction(0, 142, true) -- INPUT_MELEE_ATTACK_ALTERNATE
            DisableControlAction(0, 257, true) -- INPUT_ATTACK2
            DisableControlAction(0, 263, true) -- INPUT_MELEE_ATTACK1
            DisableControlAction(0, 264, true) -- INPUT_MELEE_ATTACK2
            DisableControlAction(0, 24, true) -- INPUT_ATTACK
            DisableControlAction(0, 25, true) -- INPUT_AIM
            Wait(0)
        end
   end)
end

---Repair Vehicles
---@param apprasial number
---@param vehicle number
local function repairVehicle(apprasial, vehicle)
	if Config.Oxlib then
		local options = {}
			options = {
				{label = _U('return_vehicle').." ($"..apprasial..")", value = 'yes'},
				{label = _U('see_mechanic'), value = 'no'}
			}
		lib.registerMenu({
			id = 'esx_advancedgarage:GarageMenuRepair',
			title = 'Garázs',
			options = options,
			onExit = true,
			onClose = function()
				lib.hideMenu(true)
				Stopmove = false
			end,
		}, function(selected, _, _)
			if selected == 1 then
				TriggerServerEvent('esx_advancedgarage:payhealth', apprasial)
				SetVehicleEngineHealth(vehicle, 1000)
				SetVehicleBodyHealth(vehicle, 1000.0)
				SetVehicleUndriveable(vehicle, false)
				SetVehicleFixed(vehicle)
				Wait(200)
				local vehicleProps = GetVehicleProperties(vehicle)
				StoreVehicle(vehicle, vehicleProps)
			else
				ESX.ShowNotification(_U('visit_mechanic'))
			end
		end)
		lib.showMenu('esx_advancedgarage:GarageMenuRepair')
	else

	ESX.UI.Menu.CloseAll()
	local elements = {
		{label = _U('return_vehicle').." ($"..apprasial..")", value = 'yes'},
		{label = _U('see_mechanic'), value = 'no'}
	}

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'delete_menu', {
		title = _U('damaged_vehicle'),
		align = Config.AlignMenu,
		elements = elements
	}, function(data, menu)
		menu.close()

		if data.current.value == 'yes' then
			TriggerServerEvent('esx_advancedgarage:payhealth', apprasial)
			SetVehicleEngineHealth(vehicle, 1000)
			SetVehicleBodyHealth(vehicle, 1000.0)
            SetVehicleUndriveable(vehicle, false)
            SetVehicleFixed(vehicle)
            Wait(200)
            local vehicleProps = GetVehicleProperties(vehicle)
			StoreVehicle(vehicle, vehicleProps)
		elseif data.current.value == 'no' then
			ESX.ShowNotification(_U('visit_mechanic'))
		end
	end, function(_, menu)
		menu.close()
		Stopmove = false
	end)
end
end

---Open main garage
---@param x vector4
---@param z vector3
---@param zy vector3
function OpenGarageMenu(x, z, zy)
    ESX.UI.Menu.CloseAll()
    local currentGarage = CachedData.currentGarage

    if not currentGarage then return end

	HandleCamera(z, zy, true)
    Stopmove = true
    Stopmov()

    ESX.TriggerServerCallback("esx_advancedgarage:fetchPlayerVehicles", function(Vehicles)
		if Config.Oxlib then
			local options = {}
			for i = 1, #Vehicles do
				local vehicleProps = Vehicles[i]
				local plate = vehicleProps.plate
				local label = GetDisplayNameFromVehicleModel(vehicleProps.model)
				local seat = GetVehicleModelNumberOfSeats(vehicleProps.model)
				local fuel = ESX.Math.Round(vehicleProps.fuelLevel)
				local body = ESX.Math.Round(vehicleProps.bodyHealth / 1000 * 100)
				local engine = ESX.Math.Round(vehicleProps.engineHealth / 1000 * 100)
				options[i] = {
					label = ""..label.." | Rendszám: "..plate .." | Engine: "..engine.."%".." | Body: "..body.."%".." | Fuel: "..fuel.."%".." | Seats: "..seat.."",
					args = vehicleProps,
				}
			end
			if #Vehicles == 0 then
				ESX.ShowNotification("Ide nem parkoltál semmit.")
				Wait(1000)
				HandleCamera(z, zy, false)
				Stopmove = false
				return
			end
			lib.registerMenu({
				id = 'esx_advancedgarage:GarageMenu',
				title = 'Garázs',
				options = options,
				onExit = true,
				onClose = function()
                    lib.hideMenu(true)
					HandleCamera(z, zy, false)
					Stopmove = false
				end,
				onSelected = function(_, _, args)
					SpawnLocalVehicle(args, x)
				end,
			}, function(_, _, args)
				SpawnVeh(args, x, z, zy)
			end)
			lib.showMenu('esx_advancedgarage:GarageMenu')
		else
			local menuElements = {}
			for i = 1, #Vehicles do
				local vehicleProps = Vehicles[i]
				local plate = Vehicles[i].plate
				local label = GetDisplayNameFromVehicleModel(vehicleProps.model)
				local seat = GetVehicleModelNumberOfSeats(vehicleProps.model)
				local fuel = ESX.Math.Round(vehicleProps.fuelLevel)
				local body = ESX.Math.Round(vehicleProps.bodyHealth / 1000 * 100)
				local engine = ESX.Math.Round(vehicleProps.engineHealth / 1000 * 100)
				if engine <= 10 then engine = 0 end
				menuElements[#menuElements+1] = {
					label = ""..label.." | Rendszám: "..plate .." | Engine: "..engine.."%".." | Body: "..body.."%".." | Fuel: "..fuel.."%".." | Seats: "..seat.."",
					vehicle = vehicleProps
				}
			end
			if #menuElements == 0 then
				menuElements[#menuElements+1] = {
					label = "Ide nem parkoltál semmit."
				}
			elseif #menuElements > 0 then
				SpawnLocalVehicle(menuElements[1], x)
			end
        ESX.UI.Menu.Open("default", GetCurrentResourceName(), "main_garage_menu", {
            title = "Garage - " .. currentGarage,
            align = Config.AlignMenu,
            elements = menuElements
        }, function(menuData, menuHandle)
            local currentVehicle = menuData.current
            if currentVehicle then
                menuHandle.close()
                Stopmove = false
                SpawnVeh(currentVehicle, x, z, zy)
            end
        end, function(_, menuHandle)
            HandleCamera(z, zy, false)
            Stopmove = false
            menuHandle.close()
        end, function(menuData, _)
            local currentVehicle = menuData.current
            if currentVehicle then
                SpawnLocalVehicle(currentVehicle, x)
            end
        end)
	end
    end, currentGarage)
end

---List Owned Boats Menu
function ListOwnedBoatsMenu()
    local elements = {}
    HandleCamera(This_Garage.cam, This_Garage.camrot, true)
    ESX.TriggerServerCallback('esx_advancedgarage:getOwnedBoats', function(ownedBoats)
		if Config.Oxlib then
			local options = {}
			for i = 1, #ownedBoats do

				local vehicleProps = ownedBoats[i].vehicle
				local label = GetDisplayNameFromVehicleModel(vehicleProps.model)
				local plate = vehicleProps.plate
				local fuel = ESX.Math.Round(vehicleProps.fuelLevel)
				local body = ESX.Math.Round(vehicleProps.bodyHealth / 1000 * 100)
				local engine = ESX.Math.Round(vehicleProps.engineHealth / 1000 * 100)
				options[i] = {
					label = ""..label.."| Rendszám: "..plate .."| Engine: "..engine.."%".."| Body: "..body.."%".."| Fuel: "..fuel.."%",
					args = vehicleProps,
				}
			end
			if #ownedBoats == 0 then
				ESX.ShowNotification("Ide nem parkoltál semmit.")
				Wait(1000)
				HandleCamera(This_Garage.cam, This_Garage.camrot, false)
				return
			end
			lib.registerMenu({
				id = 'esx_advancedgarage:getOwnedBoats',
				title = 'Garázs',
				options = options,
				onExit = true,
				onClose = function()
					lib.hideMenu(true)
					HandleCamera(This_Garage.cam, This_Garage.camrot, false)
					Stopmove = false
				end,
				onSelected = function(_, _, args)
					SpawnLocalVehicle(args, This_Garage.SpawnPoint)
				end,
			}, function(_, _, args)
				SpawnVeh(args, This_Garage.SpawnPoint, This_Garage.cam, This_Garage.camrot)
			end)
			lib.showMenu('esx_advancedgarage:getOwnedBoats')
		else
		if #ownedBoats == 0 then
			ESX.ShowNotification(_U('garage_noboats'))
		else
			for i = 1, #ownedBoats do
				local vehicleProps = ownedBoats[i]
				if Config.UseVehicleNamesLua then
					local hashVehicule = vehicleProps.vehicle.model
					local aheadVehName = GetDisplayNameFromVehicleModel(hashVehicule)
					local vehicleName  = GetLabelText(aheadVehName)
					local plate        = vehicleProps.vehicle.plate
					local labelvehicle

					if Config.ShowVehicleLocation then
						if vehicleProps.stored then
							labelvehicle = '| '..plate..' | '..vehicleName..' | '.._U('loc_garage')..' |'
						else
							labelvehicle = '| '..plate..' | '..vehicleName..' | '.._U('loc_pound')..' |'
						end
					else
						labelvehicle = '| '..plate..' | '..vehicleName..' |'
					end
					elements[#elements+1] = {label = labelvehicle, value = vehicleProps}
				else
					local hashVehicule = vehicleProps.vehicle.model
					local vehicleName  = GetDisplayNameFromVehicleModel(hashVehicule)
					local plate        = vehicleProps.vehicle.plate
					local labelvehicle
					if Config.ShowVehicleLocation then
						if vehicleProps.stored then
							labelvehicle = '| '..plate..' | '..vehicleName..' | '.._U('loc_garage')..' |'
						else
							labelvehicle = '| '..plate..' | '..vehicleName..' | '.._U('loc_pound')..' |'
						end
					else
						labelvehicle = '| '..plate..' | '..vehicleName..' |'
					end
					elements[#elements+1] = {label = labelvehicle, value = vehicleProps}
				end
			end
		end
		if #elements == 0 then
            elements[#elements+1] = {
                label = "Ide nem parkoltál semmit."
            }
        elseif #elements > 0 then
            SpawnLocalVehicle(elements[1].value, This_Garage.SpawnPoint)
        end
		Stopmove = true
		Stopmov()
		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'spawn_owned_boat', {
			title = _U('garage_boats'),
			align  = 'Config.AlignMenu',
			elements = elements
		}, function(data, menu)
			local currentVehicle = data.current.value
			    if currentVehicle.stored then
					menu.close()
					Stopmove = false
					SpawnVeh(currentVehicle.vehicle, This_Garage.SpawnPoint, This_Garage.cam, This_Garage.camrot)
				else
					ESX.ShowNotification(_U('boat_is_impounded'))
			    end
		end, function(_, menu)
            HandleCamera(This_Garage.cam, This_Garage.camrot, false)
            Stopmove = false
            menu.close()
		end, function(data, _)
			local currentVehicle = data.current.value
			if currentVehicle then
				SpawnLocalVehicle(currentVehicle, This_Garage.SpawnPoint)
			end
		end)
	end
    end)
end

---Pound Owned Boats Menu
function ReturnOwnedBoatsMenu()
	ESX.TriggerServerCallback('esx_advancedgarage:getOutOwnedBoats', function(ownedBoats)
		HandleCamera(This_Garage.cam, This_Garage.camrot, true)
		if Config.Oxlib then
			local options = {}
			for i = 1, #ownedBoats do

				local vehicleProps = ownedBoats[i]
				local label = GetDisplayNameFromVehicleModel(vehicleProps.model)
				local plate = vehicleProps.plate
				local fuel = ESX.Math.Round(vehicleProps.fuelLevel)
				local body = ESX.Math.Round(vehicleProps.bodyHealth / 1000 * 100)
				local engine = ESX.Math.Round(vehicleProps.engineHealth / 1000 * 100)
				options[i] = {
					label = ""..label.."| Rendszám: "..plate .."| Engine: "..engine.."%".."| Body: "..body.."%".."| Fuel: "..fuel.."%",
					args = vehicleProps,
				}
			end
			if #ownedBoats == 0 then
				ESX.ShowNotification("Ide nem parkoltál semmit.")
				Wait(1000)
				HandleCamera(This_Garage.cam, This_Garage.camrot, false)
				return
			end
			lib.registerMenu({
				id = 'esx_advancedgarage:getOutOwnedBoats',
				title = 'Garázs',
				options = options,
				onExit = true,
				onClose = function()
					lib.hideMenu(true)
					HandleCamera(This_Garage.cam, This_Garage.camrot, false)
					Stopmove = false
				end,
				onSelected = function(_, _, args)
					SpawnLocalVehicle(args, This_Garage.SpawnPoint)
				end,
			}, function(_, _, args)
				ESX.TriggerServerCallback('esx_advancedgarage:checkMoneyBoats', function(hasEnoughMoney)
					if hasEnoughMoney then
						TriggerServerEvent('esx_advancedgarage:payBoat')
						SpawnPoundedVehicle(args, args.plate)
						HandleCamera(This_Garage.cam, This_Garage.camrot, false)
						Stopmove = false
					else
						ESX.ShowNotification(_U('not_enough_money'))
					end
				end)
			end)
			lib.showMenu('esx_advancedgarage:getOutOwnedBoats')
		else
		local elements = {}

		for i = 1, #ownedBoats do
			local boats = ownedBoats[i]
			if Config.UseVehicleNamesLua then
				local hashVehicule = boats.model
				local aheadVehName = GetDisplayNameFromVehicleModel(hashVehicule)
				local vehicleName  = GetLabelText(aheadVehName)
				local plate        = boats.plate
				local labelvehicle

				labelvehicle = '| '..plate..' | '..vehicleName..' | '.._U('return')..' |'

				elements[#elements+1] = {label = labelvehicle, value = boats}
			else
				local hashVehicule = boats.model
				local vehicleName  = GetDisplayNameFromVehicleModel(hashVehicule)
				local plate        = boats.plate
				local labelvehicle

				labelvehicle = '| '..plate..' | '..vehicleName..' | '.._U('return')..' |'

				elements[#elements+1] = {label = labelvehicle, value = boats}
			end
		end
		if #elements == 0 then
            elements[#elements+1] = {label = "Itt nincs lefoglalt jármü."}
		elseif #elements > 0 then
            SpawnLocalVehicle(elements[1].value, This_Garage.SpawnPoint)
        end
        Stopmove = true
        Stopmov()
		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'return_owned_boat', {
			title = _U('pound_boats', ESX.Math.GroupDigits(Config.BoatPoundPrice)),
			align = Config.AlignMenu,
			elements = elements
		}, function(data, _)
			ESX.TriggerServerCallback('esx_advancedgarage:checkMoneyBoats', function(hasEnoughMoney)
				local currentVehicle = data.current.value
				if data.current.value then
				    if hasEnoughMoney then
					    TriggerServerEvent('esx_advancedgarage:payBoat')
					    SpawnVeh(currentVehicle, This_Garage.SpawnPoint, This_Garage.cam, This_Garage.camrot)
						HandleCamera(This_Garage.cam, This_Garage.camrot, false)
						Stopmove = false
				    else
					    ESX.ShowNotification(_U('not_enough_money'))
				    end
			    end
			end)
		end, function(_, menu)
            HandleCamera(This_Garage.cam, This_Garage.camrot, false)
            Stopmove = false
            menu.close()
		end, function(data, _)
			local currentVehicle = data.current.value
			if currentVehicle then
				SpawnLocalVehicle(currentVehicle, This_Garage.SpawnPoint)
			end
		end)
	end
	end)
end

---List Owned Aircrafts Menu
function ListOwnedAircraftsMenu()
	local elements = {}
	HandleCamera(This_Garage.cam, This_Garage.camrot, true)
	ESX.TriggerServerCallback('esx_advancedgarage:getOwnedAircrafts', function(ownedAircrafts)
		if Config.Oxlib then
			local options = {}
			for i = 1, #ownedAircrafts do

				local vehicleProps = ownedAircrafts[i].vehicle
				local label = GetDisplayNameFromVehicleModel(vehicleProps.model)
				local plate = vehicleProps.plate
				local fuel = ESX.Math.Round(vehicleProps.fuelLevel)
				local body = ESX.Math.Round(vehicleProps.bodyHealth / 1000 * 100)
				local engine = ESX.Math.Round(vehicleProps.engineHealth / 1000 * 100)
				options[i] = {
					label = ""..label.."| Rendszám: "..plate .."| Engine: "..engine.."%".."| Body: "..body.."%".."| Fuel: "..fuel.."%",
					args = vehicleProps,
				}
			end
			if #ownedAircrafts == 0 then
				ESX.ShowNotification("Ide nem parkoltál semmit.")
				Wait(1000)
				HandleCamera(This_Garage.cam, This_Garage.camrot, false)
				return
			end
			lib.registerMenu({
				id = 'esx_advancedgarage:getOwnedAircrafts',
				title = 'Garázs',
				options = options,
				onExit = true,
				onClose = function()
					lib.hideMenu(true)
					HandleCamera(This_Garage.cam, This_Garage.camrot, false)
					Stopmove = false
				end,
				onSelected = function(_, _, args)
					SpawnLocalVehicle(args, This_Garage.SpawnPoint)
				end,
			}, function(_, _, args)
				SpawnVeh(args, This_Garage.SpawnPoint, This_Garage.cam, This_Garage.camrot)
			end)
			lib.showMenu('esx_advancedgarage:getOwnedAircrafts')
		else
		if #ownedAircrafts == 0 then
			ESX.ShowNotification(_U('garage_noaircrafts'))
		else
			for i = 1, #ownedAircrafts do
				local vehicleProps = ownedAircrafts[i]
				if Config.UseVehicleNamesLua then
					local hashVehicule = vehicleProps.vehicle.model
					local aheadVehName = GetDisplayNameFromVehicleModel(hashVehicule)
					local vehicleName  = GetLabelText(aheadVehName)
					local plate        = vehicleProps.vehicle.plate
					local labelvehicle

					if Config.ShowVehicleLocation then
						if vehicleProps.stored then
							labelvehicle = '| '..plate..' | '..vehicleName..' | '.._U('loc_garage')..' |'
						else
							labelvehicle = '| '..plate..' | '..vehicleName..' | '.._U('loc_pound')..' |'
						end
					else
						labelvehicle = '| '..plate..' | '..vehicleName..' |'
					end
					elements[#elements+1] = {label = labelvehicle, value = vehicleProps}
				else
					local hashVehicule = vehicleProps.vehicle.model
					local vehicleName  = GetDisplayNameFromVehicleModel(hashVehicule)
					local plate        = vehicleProps.vehicle.plate
					local labelvehicle
					if Config.ShowVehicleLocation then
						if vehicleProps.stored then
							labelvehicle = '| '..plate..' | '..vehicleName..' | '.._U('loc_garage')..' |'
						else
							labelvehicle = '| '..plate..' | '..vehicleName..' | '.._U('loc_pound')..' |'
						end
					else
						labelvehicle = '| '..plate..' | '..vehicleName..' |'
					end
					elements[#elements+1] = {label = labelvehicle, value = vehicleProps}
				end
			end
		end
		if #elements == 0 then
            elements[#elements+1] = {
                label = "Ide nem parkoltál semmit."
            }
        elseif #elements > 0 then
            SpawnLocalVehicle(elements[1].value, This_Garage.SpawnPoint)
        end
		Stopmove = true
		Stopmov()
		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'spawn_owned_aircraft', {
			title = _U('garage_aircrafts'),
			align    = Config.AlignMenu,
			elements = elements
		}, function(data, menu)
			local currentVehicle = data.current.value
			    if currentVehicle.stored then
					menu.close()
					Stopmove = false
					SpawnVeh(currentVehicle.vehicle, This_Garage.SpawnPoint, This_Garage.cam, This_Garage.camrot)
				else
					ESX.ShowNotification(_U('aircraft_is_impounded'))
			    end
		end, function(_, menu)
            HandleCamera(This_Garage.cam, This_Garage.camrot, false)
            Stopmove = false
            menu.close()
		end, function(data, _)
			local currentVehicle = data.current.value
			if currentVehicle then
				SpawnLocalVehicle(currentVehicle, This_Garage.SpawnPoint)
			end
		end)
	end
	end)
end

---Pound Owned Aircrafts Menu
function ReturnOwnedAircraftsMenu()
	ESX.TriggerServerCallback('esx_advancedgarage:getOutOwnedAircrafts', function(ownedAircrafts)
		HandleCamera(This_Garage.cam, This_Garage.camrot, true)
		if Config.Oxlib then
			local options = {}
			for i = 1, #ownedAircrafts do

				local vehicleProps = ownedAircrafts[i]
				local label = GetDisplayNameFromVehicleModel(vehicleProps.model)
				local plate = vehicleProps.plate
				local fuel = ESX.Math.Round(vehicleProps.fuelLevel)
				local body = ESX.Math.Round(vehicleProps.bodyHealth / 1000 * 100)
				local engine = ESX.Math.Round(vehicleProps.engineHealth / 1000 * 100)
				options[i] = {
					label = ""..label.."| Rendszám: "..plate .."| Engine: "..engine.."%".."| Body: "..body.."%".."| Fuel: "..fuel.."%",
					args = vehicleProps,
				}
			end
			if #ownedAircrafts == 0 then
				ESX.ShowNotification("Ide nem parkoltál semmit.")
				Wait(1000)
				HandleCamera(This_Garage.cam, This_Garage.camrot, false)
				return
			end
			lib.registerMenu({
				id = 'esx_advancedgarage:getOutOwnedAircrafts',
				title = 'Garázs',
				options = options,
				onExit = true,
				onClose = function()
					lib.hideMenu(true)
					HandleCamera(This_Garage.cam, This_Garage.camrot, false)
					Stopmove = false
				end,
				onSelected = function(_, _, args)
					SpawnLocalVehicle(args, This_Garage.SpawnPoint)
				end,
			}, function(_, _, args)
				ESX.TriggerServerCallback('esx_advancedgarage:checkMoneyAircrafts', function(hasEnoughMoney)
					if hasEnoughMoney then
						TriggerServerEvent('esx_advancedgarage:payAircraft')
						SpawnPoundedVehicle(args, args.plate)
						HandleCamera(This_Garage.cam, This_Garage.camrot, false)
						Stopmove = false
					else
						ESX.ShowNotification(_U('not_enough_money'))
					end
				end)
			end)
			lib.showMenu('esx_advancedgarage:getOutOwnedAircrafts')
		else
		local elements = {}

		for i = 1, #ownedAircrafts do
			local aircrafts = ownedAircrafts[i]
			if Config.UseVehicleNamesLua then
				local hashVehicule = aircrafts.model
				local aheadVehName = GetDisplayNameFromVehicleModel(hashVehicule)
				local vehicleName  = GetLabelText(aheadVehName)
				local plate        = aircrafts.plate
				local labelvehicle

				labelvehicle = '| '..plate..' | '..vehicleName..' | '.._U('return')..' |'

				elements[#elements+1] = {label = labelvehicle, value = aircrafts}
			else
				local hashVehicule = aircrafts.model
				local vehicleName  = GetDisplayNameFromVehicleModel(hashVehicule)
				local plate        = aircrafts.plate
				local labelvehicle

				labelvehicle = '| '..plate..' | '..vehicleName..' | '.._U('return')..' |'

				elements[#elements+1] = {label = labelvehicle, value = aircrafts}
			end
		end
		if #elements == 0 then
			elements[#elements+1] = {label = "Itt nincs lefoglalt jármü."}
		elseif #elements > 0 then
			SpawnLocalVehicle(elements[1].value, This_Garage.SpawnPoint)
		end
        Stopmove = true
        Stopmov()
		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'return_owned_aircraft', {
			title    = _U('pound_aircrafts', ESX.Math.GroupDigits(Config.AircraftPoundPrice)),
			align    = Config.AlignMenu,
			elements = elements
		}, function(data, _)
			ESX.TriggerServerCallback('esx_advancedgarage:checkMoneyAircrafts', function(hasEnoughMoney)
				local currentVehicle = data.current.value
				if data.current.value then
					if hasEnoughMoney then
						TriggerServerEvent('esx_advancedgarage:payAircraft')
						SpawnPoundedVehicle(currentVehicle, This_Garage.SpawnPoint)
						HandleCamera(This_Garage.cam, This_Garage.camrot, false)
						Stopmove = false
					else
						ESX.ShowNotification(_U('not_enough_money'))
					end
				end
			end)
		end, function(_, menu)
			HandleCamera(This_Garage.cam, This_Garage.camrot, false)
			Stopmove = false
			menu.close()
		end, function(data, _)
			local currentVehicle = data.current.value
			if currentVehicle then
				SpawnLocalVehicle(currentVehicle, This_Garage.SpawnPoint)
			end
		end)
	end
	end)
end

---Store Owned Boats Menu
function StoreOwnedBoatsMenu()
	local playerPed  = ESX.PlayerData.ped
	if IsPedInAnyBoat(playerPed) then
		local vehicle       = GetVehiclePedIsIn(playerPed, false)
		local vehicleProps  = ESX.Game.GetVehicleProperties(vehicle)
		local engineHealth  = GetVehicleEngineHealth(vehicle)

		ESX.TriggerServerCallback('esx_advancedgarage:storeBoat', function(valid)
			if valid then
				if engineHealth < 900 then
					if Config.UseDamageMult then
						local apprasial = math.floor((1000 - engineHealth)/1000*Config.BoatPoundPrice*Config.DamageMult)
						repairVehicle(apprasial, vehicle)
					else
						StoreVehicle(vehicle, vehicleProps)
					end
				else
					StoreVehicle(vehicle, vehicleProps)
				end
			else
				ESX.ShowNotification(_U('cannot_store_vehicle'))
			end
		end, vehicleProps)
	else
		ESX.ShowNotification(_U('no_vehicle_to_enter'))
	end
end

---Store Owned Aircrafts Menu
function StoreOwnedAircraftsMenu()
	if IsPedInAnyVehicle(ESX.PlayerData.ped,  false) then
		local vehicle       = GetVehiclePedIsIn(ESX.PlayerData.ped, false)
		local vehicleProps  = ESX.Game.GetVehicleProperties(vehicle)
		local engineHealth  = GetVehicleEngineHealth(vehicle)

		ESX.TriggerServerCallback('esx_advancedgarage:storeAircraft', function(valid)
			if valid then
				if engineHealth < 900 then
					if Config.UseDamageMult then
						local apprasial = math.floor((1000 - engineHealth)/1000 * Config.AircraftPoundPrice * Config.DamageMult)
						repairVehicle(apprasial, vehicle)
					else
						StoreVehicle(vehicle, vehicleProps)
					end
				else
					StoreVehicle(vehicle, vehicleProps)
				end
			else
				ESX.ShowNotification(_U('cannot_store_vehicle'))
			end
		end, vehicleProps)
	else
		ESX.ShowNotification(_U('no_vehicle_to_enter'))
	end
end

---Pound Owned Cars Menu
function ReturnOwnedCarsMenu()
	ESX.UI.Menu.CloseAll()
	HandleCamera(This_Garage.cam, This_Garage.camrot, true)
	ESX.TriggerServerCallback('esx_advancedgarage:getOutOwnedCars', function(ownedCars)
		if Config.Oxlib then
			local options = {}
			for i = 1, #ownedCars do

				local vehicleProps = ownedCars[i]
				local label = GetDisplayNameFromVehicleModel(vehicleProps.model)
				local plate = vehicleProps.plate
				local fuel = 50
				if vehicleProps.fuelLevel then
				    fuel = ESX.Math.Round(vehicleProps.fuelLevel)
				end
				local body = 1000.0
				if vehicleProps.bodyHealth then
				    body = ESX.Math.Round(vehicleProps.bodyHealth / 1000 * 100)
			    end
				local engine = 1000.0
				if vehicleProps.engineHealth then
				    engine = ESX.Math.Round(vehicleProps.engineHealth / 1000 * 100)
				end
				options[i] = {
					label = ""..label.."| Rendszám: "..plate .."| Engine: "..engine.."%".."| Body: "..body.."%".."| Fuel: "..fuel.."%",
					args = vehicleProps,
				}
			end
			if #ownedCars == 0 then
				ESX.ShowNotification("Ide nem parkoltál semmit.")
				Wait(1000)
				HandleCamera(This_Garage.cam, This_Garage.camrot, false)
				return
			end
			lib.registerMenu({
				id = 'esx_advancedgarage:getOutOwnedCars',
				title = 'Garázs',
				options = options,
				onExit = true,
				onClose = function()
					lib.hideMenu(true)
					HandleCamera(This_Garage.cam, This_Garage.camrot, false)
					Stopmove = false
				end,
				onSelected = function(_, _, args)
					SpawnLocalVehicle(args, This_Garage.SpawnPoint)
				end,
			}, function(_, _, args)
			    ESX.TriggerServerCallback('esx_advancedgarage:checkMoneyCars', function(hasEnoughMoney)
				    if hasEnoughMoney then
					    SpawnPoundedVehicle(args, args.plate)
					    TriggerServerEvent('esx_advancedgarage:payCar', args.plate)
				    else
					    ESX.ShowNotification(_U('not_enough_money'))
				    end
			    end)
			end)
			lib.showMenu('esx_advancedgarage:getOutOwnedCars')
		else
		local elements = {}
		for i = 1, #ownedCars do
			local vehicleProps = ownedCars[i]
			if Config.UseVehicleNamesLua then
				local hashVehicule = ownedCars[i].model
				local aheadVehName = GetDisplayNameFromVehicleModel(hashVehicule)
				local vehicleName  = GetLabelText(aheadVehName)
				local plate        = ownedCars[i].plate
				local labelvehicle

				labelvehicle = '| '..plate..' | '..vehicleName..' | '.._U('return')..' |'

				elements[#elements+1] = {label = labelvehicle, vehicle = vehicleProps}
			else
				local hashVehicule = ownedCars[i].model
				local vehicleName  = GetDisplayNameFromVehicleModel(hashVehicule)
				local plate        = ownedCars[i].plate
				local labelvehicle

				labelvehicle = '| '..plate..' | '..vehicleName..' | '.._U('return')..' |'

				elements[#elements+1] = {label = labelvehicle, vehicle = vehicleProps}
			end
		end
		if #elements == 0 then
            elements[#elements+1] = {
                label = "Ide nem parkoltál semmit."
            }
        elseif #elements > 0 then
            SpawnLocalVehicle(elements[1], This_Garage.SpawnPoint)
        end
		Stopmove = true
		Stopmov()
		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'return_owned_car', {
			title = _U('pound_cars', ESX.Math.GroupDigits(Config.CarPoundPrice)),
			align    = Config.AlignMenu,
			elements = elements
		}, function(data, menu)
			local currentVehicle = data.current
			if currentVehicle then
			    ESX.TriggerServerCallback('esx_advancedgarage:checkMoneyCars', function(hasEnoughMoney)
				    if hasEnoughMoney then
						menu.close()
						Stopmove = false
					    SpawnVeh(currentVehicle.vehicle, This_Garage.SpawnPoint, This_Garage.cam, This_Garage.camrot)
					    TriggerServerEvent('esx_advancedgarage:payCar', currentVehicle.vehicle.plate)
				    else
					    ESX.ShowNotification(_U('not_enough_money'))
				    end
			    end)
			end
		end, function(_, menu)
            HandleCamera(This_Garage.cam, This_Garage.camrot, false)
            Stopmove = false
            menu.close()
		end, function(data, _)
			local currentVehicle = data.current
			if currentVehicle then
				SpawnLocalVehicle(currentVehicle, This_Garage.SpawnPoint)
			end
		end)
	end
	end)
end

---Pound Owned Policing Menu
function ReturnOwnedPolicingMenu()
	ESX.TriggerServerCallback('esx_advancedgarage:getOutOwnedPoliceCars', function(ownedPolicingCars)
		if Config.Oxlib then
			local options = {}
			for i = 1, #ownedPolicingCars do

				local vehicleProps = ownedPolicingCars[i]
				local label = GetDisplayNameFromVehicleModel(vehicleProps.model)
				local plate = vehicleProps.plate
				local fuel = ESX.Math.Round(vehicleProps.fuelLevel)
				local body = ESX.Math.Round(vehicleProps.bodyHealth / 1000 * 100)
				local engine = ESX.Math.Round(vehicleProps.engineHealth / 1000 * 100)
				options[i] = {
					label = ""..label.."| Rendszám: "..plate .."| Engine: "..engine.."%".."| Body: "..body.."%".."| Fuel: "..fuel.."%",
					args = vehicleProps,
				}
			end
			if #ownedPolicingCars == 0 then
				ESX.ShowNotification("Ide nem parkoltál semmit.")
				Wait(1000)
				HandleCamera(This_Garage.cam, This_Garage.camrot, false)
				return
			end
			lib.registerMenu({
				id = 'esx_advancedgarage:getOutOwnedPoliceCars',
				title = 'Garázs',
				options = options,
				onExit = true,
				onClose = function()
					lib.hideMenu(true)
					HandleCamera(This_Garage.cam, This_Garage.camrot, false)
					Stopmove = false
				end,
				onSelected = function(_, _, args)
					SpawnLocalVehicle(args, This_Garage.SpawnPoint)
				end,
			}, function(_, _, args)
				ESX.TriggerServerCallback('esx_advancedgarage:checkMoneyPolice', function(hasEnoughMoney)
					if hasEnoughMoney then
						TriggerServerEvent('esx_advancedgarage:payPolice')
						SpawnPoundedVehicle(args, args.plate)
					else
						ESX.ShowNotification(_U('not_enough_money'))
					end
				end)
			end)
			lib.showMenu('esx_advancedgarage:getOutOwnedPoliceCars')
		else
		local elements = {}

		for i = 1, #ownedPolicingCars do
			if Config.UseVehicleNamesLua then
				local hashVehicule = ownedPolicingCars[i].model
				local aheadVehName = GetDisplayNameFromVehicleModel(hashVehicule)
				local vehicleName  = GetLabelText(aheadVehName)
				local plate        = ownedPolicingCars[i].plate
				local labelvehicle

				labelvehicle = '| '..plate..' | '..vehicleName..' | '.._U('return')..' |'

				elements[#elements+1] = {label = labelvehicle, value = ownedPolicingCars[i]}
			else
				local hashVehicule = ownedPolicingCars[i].model
				local vehicleName  = GetDisplayNameFromVehicleModel(hashVehicule)
				local plate        = ownedPolicingCars[i].plate
				local labelvehicle

				labelvehicle = '| '..plate..' | '..vehicleName..' | '.._U('return')..' |'

				elements[#elements+1] = {label = labelvehicle, value = ownedPolicingCars[i]}
			end
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'return_owned_police', {
			title = _U('pound_police'),
			align = Config.AlignMenu,
			elements = elements
		}, function(data, _)
			ESX.TriggerServerCallback('esx_advancedgarage:checkMoneyPolice', function(hasEnoughMoney)
				if hasEnoughMoney then
					TriggerServerEvent('esx_advancedgarage:payPolice')
					SpawnPoundedVehicle(data.current.value, data.current.value.plate)
				else
					ESX.ShowNotification(_U('not_enough_money'))
				end
			end)
		end, function(_, menu)
			menu.close()
		end)
	end
	end)
end

---Pound Owned Taxing Menu
function ReturnOwnedTaxingMenu()
	ESX.TriggerServerCallback('esx_advancedgarage:getOutOwnedTaxiCars', function(ownedTaxingCars)
		if Config.Oxlib then
			local options = {}
			for i = 1, #ownedTaxingCars do

				local vehicleProps = ownedTaxingCars[i]
				local label = GetDisplayNameFromVehicleModel(vehicleProps.model)
				local plate = vehicleProps.plate
				local fuel = ESX.Math.Round(vehicleProps.fuelLevel)
				local body = ESX.Math.Round(vehicleProps.bodyHealth / 1000 * 100)
				local engine = ESX.Math.Round(vehicleProps.engineHealth / 1000 * 100)
				options[i] = {
					label = ""..label.."| Rendszám: "..plate .."| Engine: "..engine.."%".."| Body: "..body.."%".."| Fuel: "..fuel.."%",
					args = vehicleProps,
				}
			end
			if #ownedTaxingCars == 0 then
				ESX.ShowNotification("Ide nem parkoltál semmit.")
				Wait(1000)
				HandleCamera(This_Garage.cam, This_Garage.camrot, false)
				return
			end
			lib.registerMenu({
				id = 'esx_advancedgarage:getOutOwnedTaxiCars',
				title = 'Garázs',
				options = options,
				onExit = true,
				onClose = function()
					lib.hideMenu(true)
					HandleCamera(This_Garage.cam, This_Garage.camrot, false)
					Stopmove = false
				end,
				onSelected = function(_, _, args)
					SpawnLocalVehicle(args, This_Garage.SpawnPoint)
				end,
			}, function(_, _, args)
				ESX.TriggerServerCallback('esx_advancedgarage:checkMoneyTaxi', function(hasEnoughMoney)
					if hasEnoughMoney then
						TriggerServerEvent('esx_advancedgarage:payTaxi')
						SpawnPoundedVehicle(args, args.plate)
					else
						ESX.ShowNotification(_U('not_enough_money'))
					end
				end)
			end)
			lib.showMenu('esx_advancedgarage:getOutOwnedTaxiCars')
		else
		local elements = {}

		for i = 1, #ownedTaxingCars do
			if Config.UseVehicleNamesLua then
				local hashVehicule = ownedTaxingCars[i].model
				local aheadVehName = GetDisplayNameFromVehicleModel(hashVehicule)
				local vehicleName  = GetLabelText(aheadVehName)
				local plate        = ownedTaxingCars[i].plate
				local labelvehicle

				labelvehicle = '| '..plate..' | '..vehicleName..' | '.._U('return')..' |'

				elements[#elements+1] = {label = labelvehicle, value = ownedTaxingCars[i]}
			else
				local hashVehicule = ownedTaxingCars[i].model
				local vehicleName  = GetDisplayNameFromVehicleModel(hashVehicule)
				local plate        = ownedTaxingCars[i].plate
				local labelvehicle

				labelvehicle = '| '..plate..' | '..vehicleName..' | '.._U('return')..' |'

				elements[#elements+1] = {label = labelvehicle, value = ownedTaxingCars[i]}
			end
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'return_owned_taxing', {
			title = _U('pound_taxi'),
			align = Config.AlignMenu,
			elements = elements
		}, function(data, _)
			ESX.TriggerServerCallback('esx_advancedgarage:checkMoneyTaxi', function(hasEnoughMoney)
				if hasEnoughMoney then
					TriggerServerEvent('esx_advancedgarage:payTaxi')
					SpawnPoundedVehicle(data.current.value, data.current.value.plate)
				else
					ESX.ShowNotification(_U('not_enough_money'))
				end
			end)
		end, function(_, menu)
			menu.close()
		end)
	end
	end)
end

---Pound Owned Sheriff Menu
function ReturnOwnedSheriffMenu()
	ESX.TriggerServerCallback('esx_advancedgarage:getOutOwnedSheriffCars', function(ownedSheriffCars)
		if Config.Oxlib then
			local options = {}
			for i = 1, #ownedSheriffCars do

				local vehicleProps = ownedSheriffCars[i]
				local label = GetDisplayNameFromVehicleModel(vehicleProps.model)
				local plate = vehicleProps.plate
				local fuel = ESX.Math.Round(vehicleProps.fuelLevel)
				local body = ESX.Math.Round(vehicleProps.bodyHealth / 1000 * 100)
				local engine = ESX.Math.Round(vehicleProps.engineHealth / 1000 * 100)
				options[i] = {
					label = ""..label.."| Rendszám: "..plate .."| Engine: "..engine.."%".."| Body: "..body.."%".."| Fuel: "..fuel.."%",
					args = vehicleProps,
				}
			end
			if #ownedSheriffCars == 0 then
				ESX.ShowNotification("Ide nem parkoltál semmit.")
				Wait(1000)
				HandleCamera(This_Garage.cam, This_Garage.camrot, false)
				return
			end
			lib.registerMenu({
				id = 'esx_advancedgarage:getOutOwnedSheriffCars',
				title = 'Garázs',
				options = options,
				onExit = true,
				onClose = function()
					lib.hideMenu(true)
					HandleCamera(This_Garage.cam, This_Garage.camrot, false)
					Stopmove = false
				end,
				onSelected = function(_, _, args)
					SpawnLocalVehicle(args, This_Garage.SpawnPoint)
				end,
			}, function(_, _, args)
				ESX.TriggerServerCallback('esx_advancedgarage:checkMoneySheriff', function(hasEnoughMoney)
					if hasEnoughMoney then
						TriggerServerEvent('esx_advancedgarage:paySheriff')
						SpawnPoundedVehicle(args, args.plate)
					else
						ESX.ShowNotification(_U('not_enough_money'))
					end
				end)
			end)
			lib.showMenu('esx_advancedgarage:getOutOwnedSheriffCars')
		else
		local elements = {}

		for i = 1, #ownedSheriffCars do
			if Config.UseVehicleNamesLua then
				local hashVehicule = ownedSheriffCars[i].model
				local aheadVehName = GetDisplayNameFromVehicleModel(hashVehicule)
				local vehicleName  = GetLabelText(aheadVehName)
				local plate        = ownedSheriffCars[i].plate
				local labelvehicle

				labelvehicle = '| '..plate..' | '..vehicleName..' | '.._U('return')..' |'

				elements[#elements+1] = {label = labelvehicle, value = ownedSheriffCars[i]}
			else
				local hashVehicule = ownedSheriffCars[i].model
				local vehicleName  = GetDisplayNameFromVehicleModel(hashVehicule)
				local plate        = ownedSheriffCars[i].plate
				local labelvehicle

				labelvehicle = '| '..plate..' | '..vehicleName..' | '.._U('return')..' |'

				elements[#elements+1] = {label = labelvehicle, value = ownedSheriffCars[i]}
			end
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'return_owned_sheriff', {
			title = _U('pound_sheriff'),
			align = Config.AlignMenu,
			elements = elements
		}, function(data, _)
			ESX.TriggerServerCallback('esx_advancedgarage:checkMoneySheriff', function(hasEnoughMoney)
				if hasEnoughMoney then
					TriggerServerEvent('esx_advancedgarage:paySheriff')
					SpawnPoundedVehicle(data.current.value, data.current.value.plate)
				else
					ESX.ShowNotification(_U('not_enough_money'))
				end
			end)
		end, function(_, menu)
			menu.close()
		end)
	end
	end)
end

---Pound Owned Ambulance Menu
function ReturnOwnedAmbulanceMenu()
	ESX.TriggerServerCallback('esx_advancedgarage:getOutOwnedAmbulanceCars', function(ownedAmbulanceCars)
		if Config.Oxlib then
			local options = {}
			for i = 1, #ownedAmbulanceCars do

				local vehicleProps = ownedAmbulanceCars[i]
				local label = GetDisplayNameFromVehicleModel(vehicleProps.model)
				local plate = vehicleProps.plate
				local fuel = ESX.Math.Round(vehicleProps.fuelLevel)
				local body = ESX.Math.Round(vehicleProps.bodyHealth / 1000 * 100)
				local engine = ESX.Math.Round(vehicleProps.engineHealth / 1000 * 100)
				options[i] = {
					label = ""..label.."| Rendszám: "..plate .."| Engine: "..engine.."%".."| Body: "..body.."%".."| Fuel: "..fuel.."%",
					args = vehicleProps,
				}
			end
			if #ownedAmbulanceCars == 0 then
				ESX.ShowNotification("Ide nem parkoltál semmit.")
				Wait(1000)
				HandleCamera(This_Garage.cam, This_Garage.camrot, false)
				return
			end
			lib.registerMenu({
				id = 'esx_advancedgarage:getOutOwnedAmbulanceCars',
				title = 'Garázs',
				options = options,
				onExit = true,
				onClose = function()
					lib.hideMenu(true)
					HandleCamera(This_Garage.cam, This_Garage.camrot, false)
					Stopmove = false
				end,
				onSelected = function(_, _, args)
					SpawnLocalVehicle(args, This_Garage.SpawnPoint)
				end,
			}, function(_, _, args)
				ESX.TriggerServerCallback('esx_advancedgarage:checkMoneyAmbulance', function(hasEnoughMoney)
					if hasEnoughMoney then
						TriggerServerEvent('esx_advancedgarage:payAmbulance')
						SpawnPoundedVehicle(args, args.plate)
					else
						ESX.ShowNotification(_U('not_enough_money'))
					end
				end)
			end)
			lib.showMenu('esx_advancedgarage:getOutOwnedAmbulanceCars')
		else
		local elements = {}

		for i = 1, #ownedAmbulanceCars do
			if Config.UseVehicleNamesLua then
				local hashVehicule = ownedAmbulanceCars[i].model
				local aheadVehName = GetDisplayNameFromVehicleModel(hashVehicule)
				local vehicleName  = GetLabelText(aheadVehName)
				local plate        = ownedAmbulanceCars[i].plate
				local labelvehicle

				labelvehicle = '| '..plate..' | '..vehicleName..' | '.._U('return')..' |'

				elements[#elements+1] = {label = labelvehicle, value = ownedAmbulanceCars[i]}
			else
				local hashVehicule = ownedAmbulanceCars[i].model
				local vehicleName  = GetDisplayNameFromVehicleModel(hashVehicule)
				local plate        = ownedAmbulanceCars[i].plate
				local labelvehicle

				labelvehicle = '| '..plate..' | '..vehicleName..' | '.._U('return')..' |'

				elements[#elements+1] = {label = labelvehicle, value = ownedAmbulanceCars[i]}
			end
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'return_owned_ambulance', {
			title = _U('pound_ambulance'),
			align = Config.AlignMenu,
			elements = elements
		}, function(data, _)
			ESX.TriggerServerCallback('esx_advancedgarage:checkMoneyAmbulance', function(hasEnoughMoney)
				if hasEnoughMoney then
					TriggerServerEvent('esx_advancedgarage:payAmbulance')
					SpawnPoundedVehicle(data.current.value, data.current.value.plate)
				else
					ESX.ShowNotification(_U('not_enough_money'))
				end
			end)
		end, function(_, menu)
			menu.close()
		end)
	end
	end)
end

---Open Main Menu
---@param PointType string
---@return nil
function OpenMenuGarage(PointType)
	if Config.Oxlib then
		local elements = {}

		if PointType == 'boat_garage_point' then
			elements[#elements+1] = {label = _U('list_owned_boats'), args = 'list_owned_boats'}
		elseif PointType == 'aircraft_garage_point' then
			elements[#elements+1] = {label = _U('list_owned_aircrafts'), args = 'list_owned_aircrafts'}
		elseif PointType == 'boat_store_point' then
			elements[#elements+1] = {label = _U('store_owned_boats'), args = 'store_owned_boats'}
		elseif PointType == 'aircraft_store_point' then
			elements[#elements+1] = {label = _U('store_owned_aircrafts'), args = 'store_owned_aircrafts'}
		elseif PointType == 'car_pound_point' then
			elements[#elements+1] = {label = _U('return_owned_cars').." ($"..Config.CarPoundPrice..")", args = 'return_owned_cars'}
		elseif PointType == 'boat_pound_point' then
			elements[#elements+1] = {label = _U('return_owned_boats').." ($"..Config.BoatPoundPrice..")", args = 'return_owned_boats'}
		elseif PointType == 'aircraft_pound_point' then
			elements[#elements+1] = {label = _U('return_owned_aircrafts').." ($"..Config.AircraftPoundPrice..")", args = 'return_owned_aircrafts'}
		elseif PointType == 'policing_pound_point' then
			elements[#elements+1] = {label = _U('return_owned_policing').." ($"..Config.PolicePoundPrice..")", args = 'return_owned_policing'}
		elseif PointType == 'taxing_pound_point' then
			elements[#elements+1] = {label = _U('return_owned_taxing').." ($"..Config.TaxingPoundPrice..")", args = 'return_owned_taxing'}
		elseif PointType == 'Sheriff_pound_point' then
			elements[#elements+1] = {label = _U('return_owned_sheriff').." ($"..Config.SheriffPoundPrice..")", args = 'return_owned_sheriff'}
		elseif PointType == 'ambulance_pound_point' then
			elements[#elements+1] = {label = _U('return_owned_ambulance').." ($"..Config.AmbulancePoundPrice..")", args = 'return_owned_ambulance'}
		end
		lib.registerMenu({
			id = 'esx_advancedgarage:OpenMenuGarage',
			title = 'Garázs Menü',
			options = elements,
			onExit = true,
			onClose = function()
				lib.hideMenu(true)
			end,
		}, function(_, _, args)
			if args == 'list_owned_cars' then
				--ListOwnedCarsMenu()
			elseif args == 'list_owned_boats' then
				ListOwnedBoatsMenu()
			elseif args == 'list_owned_aircrafts' then
				ListOwnedAircraftsMenu()
			elseif args == 'store_owned_boats' then
				StoreOwnedBoatsMenu()
			elseif args == 'store_owned_aircrafts' then
				StoreOwnedAircraftsMenu()
			elseif args == 'return_owned_cars' then
				ReturnOwnedCarsMenu()
			elseif args == 'return_owned_boats' then
				ReturnOwnedBoatsMenu()
			elseif args == 'return_owned_aircrafts' then
				ReturnOwnedAircraftsMenu()
			elseif args == 'return_owned_policing' then
				ReturnOwnedPolicingMenu()
			elseif args == 'return_owned_taxing' then
				ReturnOwnedTaxingMenu()
			elseif args == 'return_owned_sheriff' then
				ReturnOwnedSheriffMenu()
			elseif args == 'return_owned_ambulance' then
				ReturnOwnedAmbulanceMenu()
			end
		end)
		lib.showMenu('esx_advancedgarage:OpenMenuGarage')
	else
		ESX.UI.Menu.CloseAll()
		local elements = {}

		if PointType == 'boat_garage_point' then
			elements[#elements+1] = {label = _U('list_owned_boats'), value = 'list_owned_boats'}
		elseif PointType == 'aircraft_garage_point' then
			elements[#elements+1] = {label = _U('list_owned_aircrafts'), value = 'list_owned_aircrafts'}
		elseif PointType == 'boat_store_point' then
			elements[#elements+1] = {label = _U('store_owned_boats'), value = 'store_owned_boats'}
		elseif PointType == 'aircraft_store_point' then
			elements[#elements+1] = {label = _U('store_owned_aircrafts'), value = 'store_owned_aircrafts'}
		elseif PointType == 'car_pound_point' then
			elements[#elements+1] = {label = _U('return_owned_cars').." ($"..Config.CarPoundPrice..")", value = 'return_owned_cars'}
		elseif PointType == 'boat_pound_point' then
			elements[#elements+1] = {label = _U('return_owned_boats').." ($"..Config.BoatPoundPrice..")", value = 'return_owned_boats'}
		elseif PointType == 'aircraft_pound_point' then
			elements[#elements+1] = {label = _U('return_owned_aircrafts').." ($"..Config.AircraftPoundPrice..")", value = 'return_owned_aircrafts'}
		elseif PointType == 'policing_pound_point' then
			elements[#elements+1] = {label = _U('return_owned_policing').." ($"..Config.PolicePoundPrice..")", value = 'return_owned_policing'}
		elseif PointType == 'taxing_pound_point' then
			elements[#elements+1] = {label = _U('return_owned_taxing').." ($"..Config.TaxingPoundPrice..")", value = 'return_owned_taxing'}
		elseif PointType == 'Sheriff_pound_point' then
			elements[#elements+1] = {label = _U('return_owned_sheriff').." ($"..Config.SheriffPoundPrice..")", value = 'return_owned_sheriff'}
		elseif PointType == 'ambulance_pound_point' then
			elements[#elements+1] = {label = _U('return_owned_ambulance').." ($"..Config.AmbulancePoundPrice..")", value = 'return_owned_ambulance'}
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'garage_menu', {
			title = _U('garage'),
			align = Config.AlignMenu,
			elements = elements
		}, function(data, menu)
			menu.close()
			local action = data.current.value

			if action == 'list_owned_cars' then
				--ListOwnedCarsMenu()
			elseif action == 'list_owned_boats' then
				ListOwnedBoatsMenu()
			elseif action == 'list_owned_aircrafts' then
				ListOwnedAircraftsMenu()
			elseif action == 'store_owned_boats' then
				StoreOwnedBoatsMenu()
			elseif action == 'store_owned_aircrafts' then
				StoreOwnedAircraftsMenu()
			elseif action == 'return_owned_cars' then
				ReturnOwnedCarsMenu()
			elseif action == 'return_owned_boats' then
				ReturnOwnedBoatsMenu()
			elseif action == 'return_owned_aircrafts' then
				ReturnOwnedAircraftsMenu()
			elseif action == 'return_owned_policing' then
				ReturnOwnedPolicingMenu()
			elseif action == 'return_owned_taxing' then
				ReturnOwnedTaxingMenu()
			elseif action == 'return_owned_sheriff' then
				ReturnOwnedSheriffMenu()
			elseif action == 'return_owned_ambulance' then
				ReturnOwnedAmbulanceMenu()
			end
		end, function(_, menu)
			menu.close()
		end)
	end
end
