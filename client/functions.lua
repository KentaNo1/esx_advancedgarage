local stopmove = false

---Open main garage
---@param x vector4
---@param z vector3
---@param zy vector3
 function OpenGarageMenu(x, z, zy)
    ESX.UI.Menu.CloseAll()
    local currentGarage = cachedData.currentGarage

    if not currentGarage then return end

    HandleCamera(z, zy, true)

    ESX.TriggerServerCallback("esx_advancedgarage:fetchPlayerVehicles", function(Vehicles)
        local menuElements = {}
        for i = 1, #Vehicles do
            local vehicleProps = Vehicles[i]
            local plate        = Vehicles[i].plate
            menuElements[#menuElements+1] = {
                label = "" .. GetDisplayNameFromVehicleModel(vehicleProps.model) .. " Rendszám: " .. plate,
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
        stopmove = true
        stopmov()
        ESX.UI.Menu.Open("default", GetCurrentResourceName(), "main_garage_menu", {
            title = "Garage - " .. currentGarage,
            align = Config.AlignMenu,
            elements = menuElements
        }, function(menuData, menuHandle)
            local currentVehicle = menuData.current
            if currentVehicle then
                menuHandle.close()
                stopmove = false
                SpawnVeh(currentVehicle, x, z, zy)
            end
        end, function(menuData, menuHandle)
            HandleCamera(z, zy, false)
            stopmove = false
            menuHandle.close()
        end, function(menuData, menuHandle)
            local currentVehicle = menuData.current

            if currentVehicle then
                stopmove = false
                SpawnLocalVehicle(currentVehicle, x)
            end
        end)
    end, currentGarage)
end

---List Owned Boats Menu
function ListOwnedBoatsMenu()
	local elements = {}
	HandleCamera(this_Garage.cam, this_Garage.camrot, true)
	ESX.TriggerServerCallback('esx_advancedgarage:getOwnedBoats', function(ownedBoats)
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
					print(plate)
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
            SpawnLocalVehicle(elements[1].value, this_Garage.SpawnPoint)
        end
		stopmove = true
		stopmov()
		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'spawn_owned_boat', {
			title = _U('garage_boats'),
			align    = 'bottom-right',
			elements = elements
		}, function(data, menu)
			local currentVehicle = data.current.value
			    if currentVehicle.stored then
					menu.close()
					stopmove = false
					SpawnVeh2(currentVehicle.vehicle, this_Garage.SpawnPoint, this_Garage.cam, this_Garage.camrot)
				else
					ESX.ShowNotification(_U('boat_is_impounded'))
			    end
		end, function(data, menu)
            HandleCamera(this_Garage.cam, this_Garage.camrot, false)
            stopmove = false
            menu.close()
		end, function(data, menu)
			local currentVehicle = data.current.value
			if currentVehicle then
				SpawnLocalVehicle(currentVehicle, this_Garage.SpawnPoint)
			end
		end)
	end)
end

---Pound Owned Boats Menu
function ReturnOwnedBoatsMenu()
	ESX.TriggerServerCallback('esx_advancedgarage:getOutOwnedBoats', function(ownedBoats)
		HandleCamera(this_Garage.cam, this_Garage.camrot, true)
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
            SpawnPoundedLocalVehicle(elements[1].value, this_Garage.SpawnPoint)
        end
        stopmove = true
        stopmov()
		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'return_owned_boat', {
			title    = _U('pound_boats', ESX.Math.GroupDigits(Config.BoatPoundPrice)),
			align    = 'bottom-right',
			elements = elements
		}, function(data, menu)
			ESX.TriggerServerCallback('esx_advancedgarage:checkMoneyBoats', function(hasEnoughMoney)
				local currentVehicle = data.current.value
				if data.current.value then
				    if hasEnoughMoney then
					    TriggerServerEvent('esx_advancedgarage:payBoat')
					    SpawnPoundedVeh(currentVehicle, this_Garage.SpawnPoint, this_Garage.cam, this_Garage.camrot)
						HandleCamera(this_Garage.cam, this_Garage.camrot, false)
				    else
					    ESX.ShowNotification(_U('not_enough_money'))
				    end
			    end
			end)
		end, function(data, menu)
            HandleCamera(this_Garage.cam, this_Garage.camrot, false)
            stopmove = false
            menu.close()
		end, function(data, menu)
			local currentVehicle = data.current.value
			if currentVehicle then
				SpawnPoundedLocalVehicle(currentVehicle, this_Garage.SpawnPoint)
			end
		end)
	end)
end

---List Owned Aircrafts Menu
function ListOwnedAircraftsMenu()
	local elements = {}
	HandleCamera(this_Garage.cam, this_Garage.camrot, true)
	ESX.TriggerServerCallback('esx_advancedgarage:getOwnedAircrafts', function(ownedAircrafts)
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
            SpawnLocalVehicle(elements[1].value, this_Garage.SpawnPoint)
        end
		stopmove = true
		stopmov()
		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'spawn_owned_aircraft', {
			title = _U('garage_aircrafts'),
			align    = 'bottom-right',
			elements = elements
		}, function(data, menu)
			local currentVehicle = data.current.value
			    if currentVehicle.stored then
					menu.close()
					stopmove = false
					SpawnVeh2(currentVehicle.vehicle, this_Garage.SpawnPoint, this_Garage.cam, this_Garage.camrot)
				else
					ESX.ShowNotification(_U('aircraft_is_impounded'))
			    end
		end, function(data, menu)
            HandleCamera(this_Garage.cam, this_Garage.camrot, false)
            stopmove = false
            menu.close()
		end, function(data, menu)
			local currentVehicle = data.current.value
			if currentVehicle then
				SpawnLocalVehicle(currentVehicle, this_Garage.SpawnPoint)
			end
		end)
	end)
end

---Pound Owned Aircrafts Menu
function ReturnOwnedAircraftsMenu()
	ESX.TriggerServerCallback('esx_advancedgarage:getOutOwnedAircrafts', function(ownedAircrafts)
		HandleCamera(this_Garage.cam, this_Garage.camrot, true)
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
			SpawnPoundedLocalVehicle(elements[1].value, this_Garage.SpawnPoint)
		end
        stopmove = true
        stopmov()
		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'return_owned_aircraft', {
			title    = _U('pound_aircrafts', ESX.Math.GroupDigits(Config.AircraftPoundPrice)),
			align    = 'bottom-right',
			elements = elements
		}, function(data, menu)
			ESX.TriggerServerCallback('esx_advancedgarage:checkMoneyAircrafts', function(hasEnoughMoney)
				local currentVehicle = data.current.value
				if data.current.value then
					if hasEnoughMoney then
						TriggerServerEvent('esx_advancedgarage:payAircraft')
						SpawnPoundedVeh(currentVehicle, this_Garage.SpawnPoint, this_Garage.cam, this_Garage.camrot)
						HandleCamera(this_Garage.cam, this_Garage.camrot, false)
					else
						ESX.ShowNotification(_U('not_enough_money'))
					end
				end
			end)
		end, function(data, menu)
			HandleCamera(this_Garage.cam, this_Garage.camrot, false)
			stopmove = false
			menu.close()
		end, function(data, menu)
			local currentVehicle = data.current.value
			if currentVehicle then
				SpawnPoundedLocalVehicle(currentVehicle, this_Garage.SpawnPoint)
			end
		end)
	end)
end

---Store Owned Boats Menu
function StoreOwnedBoatsMenu()
	local playerPed  = ESX.PlayerData.ped
	if IsPedInAnyVehicle(playerPed,  false) then
		local vehicle       = GetVehiclePedIsIn(playerPed, false)
		local vehicleProps  = ESX.Game.GetVehicleProperties(vehicle)
		local engineHealth  = GetVehicleEngineHealth(vehicle)

		ESX.TriggerServerCallback('esx_advancedgarage:storeBoat', function(valid)
			if valid then
				if engineHealth < 900 then
					if Config.UseDamageMult then
						local apprasial = math.floor((1000 - engineHealth)/1000*Config.BoatPoundPrice*Config.DamageMult)
						RepairVehicle(apprasial, vehicle)
					else
						local apprasial = math.floor((1000 - engineHealth)/1000*Config.BoatPoundPrice)
						RepairVehicle(apprasial, vehicle)
					end
				else
					StoreVehicle2(vehicle, vehicleProps)
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
						RepairVehicle(apprasial, vehicle)
					else
						local apprasial = math.floor((1000 - engineHealth)/1000 * Config.AircraftPoundPrice)
						RepairVehicle(apprasial, vehicle)
					end
				else
					StoreVehicle2(vehicle, vehicleProps)
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
	HandleCamera(this_Garage.cam, this_Garage.camrot, true)
	ESX.TriggerServerCallback('esx_advancedgarage:getOutOwnedCars', function(ownedCars)
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
            SpawnLocalVehicle(elements[1], this_Garage.SpawnPoint)
        end
		stopmove = true
		stopmov()
		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'return_owned_car', {
			title = _U('pound_cars', ESX.Math.GroupDigits(Config.CarPoundPrice)),
			align    = 'bottom-right',
			elements = elements
		}, function(data, menu)
			local currentVehicle = data.current
			if currentVehicle then
			    ESX.TriggerServerCallback('esx_advancedgarage:checkMoneyCars', function(hasEnoughMoney)
				    if hasEnoughMoney then
						menu.close()
						stopmove = false
					    SpawnPoundedVeh(currentVehicle.vehicle, this_Garage.SpawnPoint, this_Garage.cam, this_Garage.camrot)
					    TriggerServerEvent('esx_advancedgarage:payCar', currentVehicle.vehicle.plate)
				    else
					    ESX.ShowNotification(_U('not_enough_money'))
				    end
			    end)
			end
		end, function(data, menu)
            HandleCamera(this_Garage.cam, this_Garage.camrot, false)
            stopmove = false
            menu.close()
		end, function(data, menu)
			local currentVehicle = data.current
			if currentVehicle then
				SpawnLocalVehicle(currentVehicle, this_Garage.SpawnPoint)
			end
		end)
	end)
end

---Pound Owned Policing Menu
function ReturnOwnedPolicingMenu()
	ESX.TriggerServerCallback('esx_advancedgarage:getOutOwnedPoliceCars', function(ownedPolicingCars)
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
			title    = _U('pound_police'),
			align    = 'bottom-right',
			elements = elements
		}, function(data, menu)
			ESX.TriggerServerCallback('esx_advancedgarage:checkMoneyPolice', function(hasEnoughMoney)
				if hasEnoughMoney then
					TriggerServerEvent('esx_advancedgarage:payPolice')
					SpawnPoundedVehicle(data.current.value, data.current.value.plate)
				else
					ESX.ShowNotification(_U('not_enough_money'))
				end
			end)
		end, function(data, menu)
			menu.close()
		end)
	end)
end

---Pound Owned Taxing Menu
function ReturnOwnedTaxingMenu()
	ESX.TriggerServerCallback('esx_advancedgarage:getOutOwnedTaxingCars', function(ownedTaxingCars)
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
			title    = _U('pound_taxi'),
			align    = 'bottom-right',
			elements = elements
		}, function(data, menu)
			ESX.TriggerServerCallback('esx_advancedgarage:checkMoneyTaxing', function(hasEnoughMoney)
				if hasEnoughMoney then
					TriggerServerEvent('esx_advancedgarage:payTaxing')
					SpawnPoundedVehicle(data.current.value, data.current.value.plate)
				else
					ESX.ShowNotification(_U('not_enough_money'))
				end
			end)
		end, function(data, menu)
			menu.close()
		end)
	end)
end

---Pound Owned Sheriff Menu
function ReturnOwnedSheriffMenu()
	ESX.TriggerServerCallback('esx_advancedgarage:getOutOwnedSheriffCars', function(ownedSheriffCars)
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
			title    = _U('pound_sheriff'),
			align    = 'bottom-right',
			elements = elements
		}, function(data, menu)
			ESX.TriggerServerCallback('esx_advancedgarage:checkMoneySheriff', function(hasEnoughMoney)
				if hasEnoughMoney then
					TriggerServerEvent('esx_advancedgarage:paySheriff')
					SpawnPoundedVehicle(data.current.value, data.current.value.plate)
				else
					ESX.ShowNotification(_U('not_enough_money'))
				end
			end)
		end, function(data, menu)
			menu.close()
		end)
	end)
end

---Pound Owned Ambulance Menu
function ReturnOwnedAmbulanceMenu()
	ESX.TriggerServerCallback('esx_advancedgarage:getOutOwnedAmbulanceCars', function(ownedAmbulanceCars)
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
			title    = _U('pound_ambulance'),
			align    = 'bottom-right',
			elements = elements
		}, function(data, menu)
			ESX.TriggerServerCallback('esx_advancedgarage:checkMoneyAmbulance', function(hasEnoughMoney)
				if hasEnoughMoney then
					TriggerServerEvent('esx_advancedgarage:payAmbulance')
					SpawnPoundedVehicle(data.current.value, data.current.value.plate)
				else
					ESX.ShowNotification(_U('not_enough_money'))
				end
			end)
		end, function(data, menu)
			menu.close()
		end)
	end)
end

---Open Main Menu
---@param PointType string
---@return nil
function OpenMenuGarage(PointType)
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
		title    = _U('garage'),
		align    = 'bottom-right',
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
		elseif action== 'store_owned_boats' then
			StoreOwnedBoatsMenu()
		elseif action== 'store_owned_aircrafts' then
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
	end, function(data, menu)
		menu.close()
	end)
end

stopmov = function()
    CreateThread(function()
        local DisableControlAction = DisableControlAction
        while stopmove do
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
            Wait(1)
        end
   end)
end
