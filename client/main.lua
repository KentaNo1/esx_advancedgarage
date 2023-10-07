local DrawMarker = DrawMarker
local AddBlipForCoord = AddBlipForCoord
local HasAlreadyEnteredMarker = false
local LastZone = nil
local CurrentAction = nil
local CurrentActionMsg = ''
local CurrentActionData = {}
local userProperties = {}
local privateBlips = {}
local JobBlips = {}
this_Garage = {}
carBlips = {}
cachedData = {}

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	if Config.UsePrivateCarGarages then
		ESX.TriggerServerCallback('esx_advancedgarage:getOwnedProperties', function(properties)
			userProperties = properties
			PrivateGarageBlips()
		end)
	end
	Wait(5500)
	ESX.PlayerData = xPlayer
	refreshBlips()
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    ESX.PlayerData.job = job
	deleteBlips()
	refreshBlips()
end)

CreateThread(function()
     Wait(11580)
     refreshBlips()
end)

CreateThread(function()
	for i = 1, #Config.Garages do
        local b = Config.Garages[i].menuposition
		local garageBlip = AddBlipForCoord(b.x, b.y, b.z)

		SetBlipSprite(garageBlip, 289)
		SetBlipDisplay(garageBlip, 4)
		SetBlipScale (garageBlip, 1.1)
		SetBlipColour(garageBlip, 38)
		SetBlipAsShortRange(garageBlip, true)
		BeginTextCommandSetBlipName("STRING")
		if Config.OneBlipName then
			AddTextComponentString(Config.GarageName)
		else
		AddTextComponentString(Config.GarageName .. ": " .. garage)
		end
		EndTextCommandSetBlipName(garageBlip)
	end
	while true do
		local sleep = 1500
		local ped = ESX.PlayerData.ped
		local pedCoords = GetEntityCoords(ped)
		for i = 1, #Config.Garages do
			local garage = Config.Garages[i]
			    local pos = garage.menuposition
				local dst = #(pedCoords - pos)
				local g = garage.garage
				if dst <= 50.0 then
					sleep = 3
                    local markersize = 1.5

					if dst <= markersize then
						ESX.ShowHelpNotification(string.format(Config.Labels.menu, g))
						if IsControlJustPressed(0, 38) then
							cachedData.currentGarage = g
							OpenGarageMenu(garage.spawnposition, garage.camera, garage.camrotation)
						end
					end
                    DrawMarker(6, pos.x, pos.y, pos.z - 0.985, 0.0, 0.0, 0.0, -90.0, -90.0, -90.0, markersize, markersize, markersize, 51, 255, 0, 100, false, true, 2, false, false, false, false)
				end
		end
		Wait(sleep)
	end
end)

CreateThread(function()
	while true do
		local sleep = 1500
		local ped = ESX.PlayerData.ped
		if IsPedInAnyVehicle(ped, false) then
			local pedCoords = GetEntityCoords(ped)
		    for i = 1, #Config.Garages do
			local garage = Config.Garages[i]
			local gpos = garage.vehicleposition
				local dst = #(pedCoords - gpos)
				if dst <= 50.0 then
					sleep = 3
                    local markersize = 5

					if dst <= markersize then
						 ESX.ShowHelpNotification(Config.Labels.vehicle)
						if IsControlJustPressed(0, 38) then
							cachedData.currentGarage = garage.garage
							PutInVehicle()
						end
					end
                    DrawMarker(6, gpos.x, gpos.y, gpos.z - 0.985, 0.0, 0.0, 0.0, -90.0, -90.0, -90.0, markersize, markersize, markersize, 51, 255, 0, 100, false, true, 2, false, false, false, false)
				end
		    end
	    end
		Wait(sleep)
	end
end)

-- Exited Marker
AddEventHandler('garage:hasExitedMarker', function()
	ESX.UI.Menu.CloseAll()
	CurrentAction = nil
end)

---@param tab table
---@param val string
---@return boolean
local function has_value (tab, val)
	for i = 1, #tab do
		if tab[i] == val then
			return true
		end
	end
	return false
end

---Open Main Menu
---@param PointType string
---@return nil
function OpenMenuGarage(PointType)
	ESX.UI.Menu.CloseAll()
	local elements = {}

	if PointType == 'boat_garage_point' then

		table.insert(elements, {label = _U('list_owned_boats'), value = 'list_owned_boats'})

	elseif PointType == 'aircraft_garage_point' then

		table.insert(elements, {label = _U('list_owned_aircrafts'), value = 'list_owned_aircrafts'})

	elseif PointType == 'car_store_point' then

		StoreOwnedCarsMenu()

		return

		table.insert(elements, {label = _U('store_owned_cars'), value = 'store_owned_cars'})

	elseif PointType == 'boat_store_point' then

		table.insert(elements, {label = _U('store_owned_boats'), value = 'store_owned_boats'})
	elseif PointType == 'aircraft_store_point' then
		table.insert(elements, {label = _U('store_owned_aircrafts'), value = 'store_owned_aircrafts'})
	elseif PointType == 'car_pound_point' then
		table.insert(elements, {label = _U('return_owned_cars').." ($"..Config.CarPoundPrice..")", value = 'return_owned_cars'})
	elseif PointType == 'boat_pound_point' then
		table.insert(elements, {label = _U('return_owned_boats').." ($"..Config.BoatPoundPrice..")", value = 'return_owned_boats'})
	elseif PointType == 'aircraft_pound_point' then
		table.insert(elements, {label = _U('return_owned_aircrafts').." ($"..Config.AircraftPoundPrice..")", value = 'return_owned_aircrafts'})
	elseif PointType == 'policing_pound_point' then
		table.insert(elements, {label = _U('return_owned_policing').." ($"..Config.PolicePoundPrice..")", value = 'return_owned_policing'})
	elseif PointType == 'taxing_pound_point' then
		table.insert(elements, {label = _U('return_owned_taxing').." ($"..Config.TaxingPoundPrice..")", value = 'return_owned_taxing'})
	elseif PointType == 'Sheriff_pound_point' then
		table.insert(elements, {label = _U('return_owned_sheriff').." ($"..Config.SheriffPoundPrice..")", value = 'return_owned_sheriff'})
	elseif PointType == 'ambulance_pound_point' then
		table.insert(elements, {label = _U('return_owned_ambulance').." ($"..Config.AmbulancePoundPrice..")", value = 'return_owned_ambulance'})
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
		elseif action== 'store_owned_cars' then
			StoreOwnedCarsMenu()
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

---List Owned Boats Menu
function ListOwnedBoatsMenu()
	local elements = {}

	if Config.ShowGarageSpacer1 then
		table.insert(elements, {label = _U('spacer1')})
	end

	if Config.ShowGarageSpacer2 then
		table.insert(elements, {label = _U('spacer2')})
	end

	if Config.ShowGarageSpacer3 then
		table.insert(elements, {label = _U('spacer3')})
	end

	ESX.TriggerServerCallback('esx_advancedgarage:getOwnedBoats', function(ownedBoats)
		if #ownedBoats == 0 then
			ESX.ShowNotification(_U('garage_noboats'))
		else
			for i = 1, #ownedBoats do
				if Config.UseVehicleNamesLua then
					local hashVehicule = ownedBoats[i].vehicle.model
					local aheadVehName = GetDisplayNameFromVehicleModel(hashVehicule)
					local vehicleName  = GetLabelText(aheadVehName)
					local plate        = ownedBoats[i].vehicle.plate
					local labelvehicle

					if Config.ShowVehicleLocation then
						if ownedBoats[i].stored then
							labelvehicle = '| '..plate..' | '..vehicleName..' | '.._U('loc_garage')..' |'
						else
							labelvehicle = '| '..plate..' | '..vehicleName..' | '.._U('loc_pound')..' |'
						end
					else
						if ownedBoats[i].stored then
							labelvehicle = '| '..plate..' | '..vehicleName..' |'
						else
							labelvehicle = '| '..plate..' | '..vehicleName..' |'
						end
					end

					table.insert(elements, {label = labelvehicle, value = ownedBoats[i]})
				else
					local hashVehicule = ownedBoats[i].vehicle.model
					local vehicleName  = GetDisplayNameFromVehicleModel(hashVehicule)
					local plate        = ownedBoats[i].vehicle.plate
					local labelvehicle
					if Config.ShowVehicleLocation then
						if ownedBoats[i].stored then
							labelvehicle = '| '..plate..' | '..vehicleName..' | '.._U('loc_garage')..' |'
						else
							labelvehicle = '| '..plate..' | '..vehicleName..' | '.._U('loc_pound')..' |'
						end
					else
						if ownedBoats[i].stored then
							labelvehicle = '| '..plate..' | '..vehicleName..' |'
						else
							labelvehicle = '| '..plate..' | '..vehicleName..' |'
						end
					end

					table.insert(elements, {label = labelvehicle, value = ownedBoats[i]})
				end
			end
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'spawn_owned_boat', {
			title    = _U('garage_boats'),
			align    = 'bottom-right',
			elements = elements
		}, function(data, menu)
			if data.current.value.stored then
				menu.close()
				SpawnVehicle(data.current.value.vehicle, data.current.value.vehicle.plate)
			else
				ESX.ShowNotification(_U('boat_is_impounded'))
				--exports['mythic_notify']:SendAlert('inform', _U('boat_is_impounded'), 3000, { ['background-color'] = '#FF0000', ['color'] = '#ffffff' })
			end
		end, function(data, menu)
			menu.close()
		end)
	end)
end

---Pound Owned Boats Menu
function ReturnOwnedBoatsMenu()
	ESX.TriggerServerCallback('esx_advancedgarage:getOutOwnedBoats', function(ownedBoats)
		local elements = {}

		if Config.ShowPoundSpacer2 then
			table.insert(elements, {label = _U('spacer2')})
		end

		if Config.ShowPoundSpacer3 then
			table.insert(elements, {label = _U('spacer3')})
		end

		for i = 1, #ownedBoats do
			if Config.UseVehicleNamesLua then
				local hashVehicule = ownedBoats[i].model
				local aheadVehName = GetDisplayNameFromVehicleModel(hashVehicule)
				local vehicleName  = GetLabelText(aheadVehName)
				local plate        = ownedBoats[i].plate
				local labelvehicle

				labelvehicle = '| '..plate..' | '..vehicleName..' | '.._U('return')..' |'

				table.insert(elements, {label = labelvehicle, value = ownedBoats[i]})
			else
				local hashVehicule = ownedBoats[i].model
				local vehicleName  = GetDisplayNameFromVehicleModel(hashVehicule)
				local plate        = ownedBoats[i].plate
				local labelvehicle

				labelvehicle = '| '..plate..' | '..vehicleName..' | '.._U('return')..' |'

				table.insert(elements, {label = labelvehicle, value = ownedBoats[i]})
			end
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'return_owned_boat', {
			title    = _U('pound_boats'),
			align    = 'bottom-right',
			elements = elements
		}, function(data, menu)
			ESX.TriggerServerCallback('esx_advancedgarage:checkMoneyBoats', function(hasEnoughMoney)
				if hasEnoughMoney then
					TriggerServerEvent('esx_advancedgarage:payBoat')
					SpawnPoundedBoat(data.current.value, data.current.value.plate)
				else
					ESX.ShowNotification(_U('not_enough_money'))
					--exports['mythic_notify']:SendAlert('inform', _U('not_enough_money'), 3000, { ['background-color'] = '#FF0000', ['color'] = '#ffffff' })
				end
			end)
		end, function(data, menu)
			menu.close()
		end)
	end)
end

---Spawn Pounded Boats
---@param vehicle string|number
---@param plate string
function SpawnPoundedBoat(vehicle, plate)

	if ESX.Game.IsSpawnPointClear(vector3(this_Garage.SpawnPoint.x, this_Garage.SpawnPoint.y, this_Garage.SpawnPoint.z), 3.0) then

		ESX.Game.SpawnVehicle(vehicle.model, {

			x = this_Garage.SpawnPoint.x,

			y = this_Garage.SpawnPoint.y,

			z = this_Garage.SpawnPoint.z + 1

		}, this_Garage.SpawnPoint.h, function(callback_vehicle)

			SetVehicleProperties(callback_vehicle, vehicle)

			SetVehRadioStation(callback_vehicle, "OFF")

			TaskWarpPedIntoVehicle(ESX.PlayerData.ped, callback_vehicle, -1)

			if gps ~= nil and gps > 0 then

				ToggleBlip(callback_vehicle)

			end
		end)
	else
		ESX.ShowNotification("Please move the vehicle that is in the way.")
		--exports['mythic_notify']:SendAlert('inform', 'Útban van egy autó!', 3000, { ['background-color'] = '#FF0000', ['color'] = '#ffffff' })
	end
end

---List Owned Aircrafts Menu
function ListOwnedAircraftsMenu()
	local elements = {}

	if Config.ShowGarageSpacer1 then
		table.insert(elements, {label = _U('spacer1')})
	end

	if Config.ShowGarageSpacer2 then
		table.insert(elements, {label = _U('spacer2')})
	end

	if Config.ShowGarageSpacer3 then
		table.insert(elements, {label = _U('spacer3')})
	end

	ESX.TriggerServerCallback('esx_advancedgarage:getOwnedAircrafts', function(ownedAircrafts)
		if #ownedAircrafts == 0 then
			ESX.ShowNotification(_U('garage_noaircrafts'))
			--exports['mythic_notify']:SendAlert('inform', _U('garage_noaircrafts'), 3000, { ['background-color'] = '#FF0000', ['color'] = '#ffffff' })
		else
			for i = 1, #ownedAircrafts do
				if Config.UseVehicleNamesLua then
					local hashVehicule = ownedAircrafts[i].vehicle.model
					local aheadVehName = GetDisplayNameFromVehicleModel(hashVehicule)
					local vehicleName  = GetLabelText(aheadVehName)
					local plate        = ownedAircrafts[i].vehicle.plate
					local labelvehicle

					if Config.ShowVehicleLocation then
						if ownedAircrafts[i].stored then
							labelvehicle = '| '..plate..' | '..vehicleName..' | '.._U('loc_garage')..' |'
						else
							labelvehicle = '| '..plate..' | '..vehicleName..' | '.._U('loc_pound')..' |'
						end
					else
						if ownedAircrafts[i].stored then
							labelvehicle = '| '..plate..' | '..vehicleName..' |'
						else
							labelvehicle = '| '..plate..' | '..vehicleName..' |'
						end
					end

					table.insert(elements, {label = labelvehicle, value = ownedAircrafts[i]})
				else
					local hashVehicule = ownedAircrafts[i].vehicle.model
					local vehicleName  = GetDisplayNameFromVehicleModel(hashVehicule)
					local plate        = ownedAircrafts[i].vehicle.plate
					local labelvehicle
					if Config.ShowVehicleLocation then
						if ownedAircrafts[i].stored then
							labelvehicle = '| '..plate..' | '..vehicleName..' | '.._U('loc_garage')..' |'
						else
							labelvehicle = '| '..plate..' | '..vehicleName..' | '.._U('loc_pound')..' |'
						end
					else
						if ownedAircrafts[i].stored then
							labelvehicle = '| '..plate..' | '..vehicleName..' |'
						else
							labelvehicle = '| '..plate..' | '..vehicleName..' |'
						end
					end

					table.insert(elements, {label = labelvehicle, value = ownedAircrafts[i]})
				end
			end
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'spawn_owned_aircraft', {
			title    = _U('garage_aircrafts'),
			align    = 'bottom-right',
			elements = elements
		}, function(data, menu)
			if data.current.value.stored then
				menu.close()
				SpawnVehicle(data.current.value.vehicle, data.current.value.vehicle.plate)
			else
				ESX.ShowNotification(_U('aircraft_is_impounded'))
				--exports['mythic_notify']:SendAlert('inform', _U('aircraft_is_impounded'), 3000, { ['background-color'] = '#FF0000', ['color'] = '#ffffff' })
			end
		end, function(data, menu)
			menu.close()
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
						RepairVehicle(apprasial, vehicle, vehicleProps)
					else
						local apprasial = math.floor((1000 - engineHealth)/1000*Config.BoatPoundPrice)
						RepairVehicle(apprasial, vehicle, vehicleProps)
					end
				else
					StoreVehicle2(vehicle, vehicleProps)
				end
			else
				ESX.ShowNotification(_U('cannot_store_vehicle'))
				--exports['mythic_notify']:SendAlert('inform', _U('cannot_store_vehicle'), 3000, { ['background-color'] = '#FF0000', ['color'] = '#ffffff' })
			end
		end, vehicleProps)
	else
		ESX.ShowNotification(_U('no_vehicle_to_enter'))
		--exports['mythic_notify']:SendAlert('inform', _U('no_vehicle_to_enter'), 3000, { ['background-color'] = '#FF0000', ['color'] = '#ffffff' })
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
						RepairVehicle(apprasial, vehicle, vehicleProps)
					else
						local apprasial = math.floor((1000 - engineHealth)/1000 * Config.AircraftPoundPrice)
						RepairVehicle(apprasial, vehicle, vehicleProps)
					end
				else
					StoreVehicle2(vehicle, vehicleProps)
				end
			else
				ESX.ShowNotification(_U('cannot_store_vehicle'))
				--exports['mythic_notify']:SendAlert('inform', _U('cannot_store_vehicle'), 3000, { ['background-color'] = '#FF0000', ['color'] = '#ffffff' })
			end
		end, vehicleProps)
	else
		ESX.ShowNotification(_U('no_vehicle_to_enter'))
		--exports['mythic_notify']:SendAlert('inform', _U('cannot_store_vehicle'), 3000, { ['background-color'] = '#FF0000', ['color'] = '#ffffff' })
	end
end

---Pound Owned Cars Menu
function ReturnOwnedCarsMenu()
	ESX.TriggerServerCallback('esx_advancedgarage:getOutOwnedCars', function(ownedCars)
		local elements = {}

		if Config.ShowPoundSpacer2 then
			table.insert(elements, {label = _U('spacer2')})
		end

		if Config.ShowPoundSpacer3 then
			table.insert(elements, {label = _U('spacer3')})
		end

		for i = 1, #ownedCars do
			if Config.UseVehicleNamesLua then
				local hashVehicule = ownedCars[i].model
				local aheadVehName = GetDisplayNameFromVehicleModel(hashVehicule)
				local vehicleName  = GetLabelText(aheadVehName)
				local plate        = ownedCars[i].plate
				local labelvehicle

				labelvehicle = '| '..plate..' | '..vehicleName..' | '.._U('return')..' |'

				table.insert(elements, {label = labelvehicle, value = ownedCars[i]})
			else
				local hashVehicule = ownedCars[i].model
				local vehicleName  = GetDisplayNameFromVehicleModel(hashVehicule)
				local plate        = ownedCars[i].plate
				local labelvehicle

				labelvehicle = '| '..plate..' | '..vehicleName..' | '.._U('return')..' |'

				table.insert(elements, {label = labelvehicle, value = ownedCars[i]})
			end
		end

			ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'return_owned_car', {
				title = _U('pound_cars', ESX.Math.GroupDigits(Config.CarPoundPrice)),
			        align    = 'bottom-right',
				elements = elements
			}, function(data, menu)
			ESX.TriggerServerCallback('esx_advancedgarage:checkMoneyCars', function(hasEnoughMoney)
				if hasEnoughMoney then
					SpawnPoundedVehicle(data.current.value, data.current.value.plate)
					TriggerServerEvent('esx_advancedgarage:payCar', data.current.value.plate)
				else
					ESX.ShowNotification(_U('not_enough_money'))
					--exports['mythic_notify']:SendAlert('inform', _U('not_enough_money'), 3000, { ['background-color'] = '#FF0000', ['color'] = '#ffffff' })
				end
			end)
		end, function(data, menu)
			menu.close()
		end)
	end)
end

---Pound Owned Aircrafts Menu
function ReturnOwnedAircraftsMenu()
	ESX.TriggerServerCallback('esx_advancedgarage:getOutOwnedAircrafts', function(ownedAircrafts)
		local elements = {}

		if Config.ShowPoundSpacer2 then
			table.insert(elements, {label = _U('spacer2')})
		end

		if Config.ShowPoundSpacer3 then
			table.insert(elements, {label = _U('spacer3')})
		end

		for i = 1, #ownedAircrafts do
			if Config.UseVehicleNamesLua then
				local hashVehicule = ownedAircrafts[i].model
				local aheadVehName = GetDisplayNameFromVehicleModel(hashVehicule)
				local vehicleName  = GetLabelText(aheadVehName)
				local plate        = ownedAircrafts[i].plate
				local labelvehicle

				labelvehicle = '| '..plate..' | '..vehicleName..' | '.._U('return')..' |'

				table.insert(elements, {label = labelvehicle, value = ownedAircrafts[i]})
			else
				local hashVehicule = ownedAircrafts[i].model
				local vehicleName  = GetDisplayNameFromVehicleModel(hashVehicule)
				local plate        = ownedAircrafts[i].plate
				local labelvehicle

				labelvehicle = '| '..plate..' | '..vehicleName..' | '.._U('return')..' |'

				table.insert(elements, {label = labelvehicle, value = ownedAircrafts[i]})
			end
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'return_owned_aircraft', {
			title    = _U('pound_aircrafts', ESX.Math.GroupDigits(Config.AircraftPoundPrice)),
			align    = 'bottom-right',
			elements = elements
		}, function(data, menu)
			ESX.TriggerServerCallback('esx_advancedgarage:checkMoneyAircrafts', function(hasEnoughMoney)
				if hasEnoughMoney then
					TriggerServerEvent('esx_advancedgarage:payAircraft')
					SpawnPoundedAircraft(data.current.value, data.current.value.plate)
				else
					ESX.ShowNotification(_U('not_enough_money'))
					--exports['mythic_notify']:SendAlert('inform', _U('not_enough_money'), 3000, { ['background-color'] = '#FF0000', ['color'] = '#ffffff' })
				end
			end)
		end, function(data, menu)
			menu.close()
		end)
	end)
end

---Spawn Pound Aircraft with repair
---@param vehicle string|number
---@param plate string
function SpawnPoundedAircraft(vehicle, plate)
	if ESX.Game.IsSpawnPointClear(vector3(this_Garage.SpawnPoint.x, this_Garage.SpawnPoint.y, this_Garage.SpawnPoint.z), 3.0) then
		ESX.Game.SpawnVehicle(vehicle.model, {

			x = this_Garage.SpawnPoint.x,

			y = this_Garage.SpawnPoint.y,

			z = this_Garage.SpawnPoint.z + 1

		}, this_Garage.SpawnPoint.h, function(callback_vehicle)

			SetVehicleProperties(callback_vehicle, vehicle)

			SetVehRadioStation(callback_vehicle, "OFF")

			TaskWarpPedIntoVehicle(ESX.PlayerData.ped, callback_vehicle, -1)

		end)
	else
		ESX.ShowNotification("Valami útban van.")
	end
end

---Pound Owned Policing Menu
function ReturnOwnedPolicingMenu()
	ESX.TriggerServerCallback('esx_advancedgarage:getOutOwnedPoliceCars', function(ownedPolicingCars)
		local elements = {}

		if Config.ShowPoundSpacer2 then
			table.insert(elements, {label = _U('spacer2')})
		end

		if Config.ShowPoundSpacer3 then
			table.insert(elements, {label = _U('spacer3')})
		end

		for i = 1, #ownedPolicingCars do
			if Config.UseVehicleNamesLua then
				local hashVehicule = ownedPolicingCars[i].model
				local aheadVehName = GetDisplayNameFromVehicleModel(hashVehicule)
				local vehicleName  = GetLabelText(aheadVehName)
				local plate        = ownedPolicingCars[i].plate
				local labelvehicle

				labelvehicle = '| '..plate..' | '..vehicleName..' | '.._U('return')..' |'

				table.insert(elements, {label = labelvehicle, value = ownedPolicingCars[i]})
			else
				local hashVehicule = ownedPolicingCars[i].model
				local vehicleName  = GetDisplayNameFromVehicleModel(hashVehicule)
				local plate        = ownedPolicingCars[i].plate
				local labelvehicle

				labelvehicle = '| '..plate..' | '..vehicleName..' | '.._U('return')..' |'

				table.insert(elements, {label = labelvehicle, value = ownedPolicingCars[i]})
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
					--exports['mythic_notify']:SendAlert('inform', _U('not_enough_money'), 3000, { ['background-color'] = '#FF0000', ['color'] = '#ffffff' })
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

		if Config.ShowPoundSpacer2 then
			table.insert(elements, {label = _U('spacer2')})
		end

		if Config.ShowPoundSpacer3 then
			table.insert(elements, {label = _U('spacer3')})
		end

		for i = 1, #ownedTaxingCars do
			if Config.UseVehicleNamesLua then
				local hashVehicule = ownedTaxingCars[i].model
				local aheadVehName = GetDisplayNameFromVehicleModel(hashVehicule)
				local vehicleName  = GetLabelText(aheadVehName)
				local plate        = ownedTaxingCars[i].plate
				local labelvehicle

				labelvehicle = '| '..plate..' | '..vehicleName..' | '.._U('return')..' |'

				table.insert(elements, {label = labelvehicle, value = ownedTaxingCars[i]})
			else
				local hashVehicule = ownedTaxingCars[i].model
				local vehicleName  = GetDisplayNameFromVehicleModel(hashVehicule)
				local plate        = ownedTaxingCars[i].plate
				local labelvehicle

				labelvehicle = '| '..plate..' | '..vehicleName..' | '.._U('return')..' |'

				table.insert(elements, {label = labelvehicle, value = ownedTaxingCars[i]})
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
					--exports['mythic_notify']:SendAlert('inform', _U('not_enough_money'), 3000, { ['background-color'] = '#FF0000', ['color'] = '#ffffff' })
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

		if Config.ShowPoundSpacer2 then
			table.insert(elements, {label = _U('spacer2')})
		end

		if Config.ShowPoundSpacer3 then
			table.insert(elements, {label = _U('spacer3')})
		end

		for i = 1, #ownedSheriffCars do
			if Config.UseVehicleNamesLua then
				local hashVehicule = ownedSheriffCars[i].model
				local aheadVehName = GetDisplayNameFromVehicleModel(hashVehicule)
				local vehicleName  = GetLabelText(aheadVehName)
				local plate        = ownedSheriffCars[i].plate
				local labelvehicle

				labelvehicle = '| '..plate..' | '..vehicleName..' | '.._U('return')..' |'

				table.insert(elements, {label = labelvehicle, value = ownedSheriffCars[i]})
			else
				local hashVehicule = ownedSheriffCars[i].model
				local vehicleName  = GetDisplayNameFromVehicleModel(hashVehicule)
				local plate        = ownedSheriffCars[i].plate
				local labelvehicle

				labelvehicle = '| '..plate..' | '..vehicleName..' | '.._U('return')..' |'

				table.insert(elements, {label = labelvehicle, value = ownedSheriffCars[i]})
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
					--exports['mythic_notify']:SendAlert('inform', _U('not_enough_money'), 3000, { ['background-color'] = '#FF0000', ['color'] = '#ffffff' })
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

		if Config.ShowPoundSpacer2 then
			table.insert(elements, {label = _U('spacer2')})
		end

		if Config.ShowPoundSpacer3 then
			table.insert(elements, {label = _U('spacer3')})
		end

		for i = 1, #ownedAmbulanceCars do
			if Config.UseVehicleNamesLua then
				local hashVehicule = ownedAmbulanceCars[i].model
				local aheadVehName = GetDisplayNameFromVehicleModel(hashVehicule)
				local vehicleName  = GetLabelText(aheadVehName)
				local plate        = ownedAmbulanceCars[i].plate
				local labelvehicle

				labelvehicle = '| '..plate..' | '..vehicleName..' | '.._U('return')..' |'

				table.insert(elements, {label = labelvehicle, value = ownedAmbulanceCars[i]})
			else
				local hashVehicule = ownedAmbulanceCars[i].model
				local vehicleName  = GetDisplayNameFromVehicleModel(hashVehicule)
				local plate        = ownedAmbulanceCars[i].plate
				local labelvehicle

				labelvehicle = '| '..plate..' | '..vehicleName..' | '.._U('return')..' |'

				table.insert(elements, {label = labelvehicle, value = ownedAmbulanceCars[i]})
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
					--exports['mythic_notify']:SendAlert('inform', _U('not_enough_money'), 3000, { ['background-color'] = '#FF0000', ['color'] = '#ffffff' })
				end
			end)
		end, function(data, menu)
			menu.close()
		end)
	end)
end

---Repair Vehicles
---@param apprasial number
---@param vehicle number | string
---@param vehicleProps VehicleProperties
function RepairVehicle(apprasial, vehicle, vehicleProps)
	ESX.UI.Menu.CloseAll()

	local elements = {
		{label = _U('return_vehicle').." ($"..apprasial..")", value = 'yes'},
		{label = _U('see_mechanic'), value = 'no'}
	}

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'delete_menu', {
		title    = _U('damaged_vehicle'),
		align    = 'bottom-right',
		elements = elements
	}, function(data, menu)
		menu.close()

		if data.current.value == 'yes' then
			TriggerServerEvent('esx_advancedgarage:payhealth', apprasial)
			SetVehicleEngineHealth(vehicle, 1000)
			SetVehicleBodyHealth(vheicle, 1000.0)
            SetVehicleUndriveable(vehicle, false)
            SetVehicleFixed(vehicle)
            Wait(200)
            local vehicleProps  = ESX.Game.GetVehicleProperties(vehicle)
			StoreVehicle2(vehicle, vehicleProps)
		elseif data.current.value == 'no' then
			ESX.ShowNotification(_U('visit_mechanic'))
		end
	end, function(data, menu)
		menu.close()
	end)
end

---Store Vehicles
---@param vehicle string|number
---@param vehicleProps table
function StoreVehicle(vehicle, vehicleProps)
	TaskLeaveVehicle(ESX.PlayerData.ped, vehicle, 1)
	Citizen.Wait(1000)
	ESX.Game.DeleteVehicle(vehicle)
	TriggerServerEvent('esx_advancedgarage:setVehicleState', vehicleProps.plate, 1)
	ESX.ShowNotification(_U('vehicle_in_garage'))
	--exports['mythic_notify']:SendAlert('inform', _U('vehicle_in_garage'), 3000, { ['background-color'] = '#FF0000', ['color'] = '#ffffff' })
end

---Store Vehicles
---@param vehicle number | string
---@param vehicleProps table
function StoreVehicle2(vehicle, vehicleProps)
	TaskLeaveVehicle(ESX.PlayerData.ped, vehicle, 1)
	Citizen.Wait(1000)
	ESX.Game.DeleteVehicle(vehicle)
	TriggerServerEvent('esx_advancedgarage:setVehicleState2', vehicleProps, 1, vehicleProps.plate)
	ESX.ShowNotification(_U('vehicle_in_garage'))
	--exports['mythic_notify']:SendAlert('inform', _U('vehicle_in_garage'), 3000, { ['background-color'] = '#FF0000', ['color'] = '#ffffff' })
end

---Spawn Vehicles
---@param vehicle string|number
---@param plate string
---@param gps? any
function SpawnVehicle(vehicle, plate, gps)
	local gameVehicles = ESX.Game.GetVehicles()

	for i = 1, #gameVehicles do

	local vehicle = gameVehicles[i]

        if DoesEntityExist(vehicle) then

			if Config.Trim(GetVehicleNumberPlateText(vehicle)) == Config.Trim(plate) then

				ESX.ShowNotification("Ez az autó már kint van az utcán.")
				--exports['mythic_notify']:SendAlert('error', 'Ez az autó már kint van az utcákon!', 3000, { ['background-color'] = '#ff0000', ['color'] = '#ffffff' })

				return
			end
		end
	end

	if ESX.Game.IsSpawnPointClear(vector3(this_Garage.SpawnPoint.x, this_Garage.SpawnPoint.y, this_Garage.SpawnPoint.z), 3.0) then 

		ESX.Game.SpawnVehicle(vehicle.model, {

			x = this_Garage.SpawnPoint.x,

			y = this_Garage.SpawnPoint.y,

			z = this_Garage.SpawnPoint.z + 1

		}, this_Garage.SpawnPoint.h, function(callback_vehicle)
			SetVehicleProperties(callback_vehicle, vehicle)

			SetVehRadioStation(callback_vehicle, "OFF")

			TaskWarpPedIntoVehicle(ESX.PlayerData.ped, callback_vehicle, -1)

			if gps ~= nil and gps then
				ToggleBlip(callback_vehicle)
			end
		end)
		TriggerServerEvent('esx_advancedgarage:setVehicleState', plate, 0)
	else
		ESX.ShowNotification("Egy jármü útban van.")
	end
end

---Spawn Pound Vehicles
---@param vehicle string|number
---@param plate string
function SpawnPoundedVehicle(vehicle, plate)

	if ESX.Game.IsSpawnPointClear(vector3(this_Garage.SpawnPoint.x, this_Garage.SpawnPoint.y, this_Garage.SpawnPoint.z), 3.0) then

        local gameVehicles = ESX.Game.GetVehicles()

		for i = 1, #gameVehicles do
			local vehicle = gameVehicles[i]

			if DoesEntityExist(vehicle) then
				if Config.Trim(GetVehicleNumberPlateText(vehicle)) == Config.Trim(plate) then
					ESX.ShowNotification("Ez a jármü az utcán van, ugyanabból a jármüböl kettöt nem lehet kivenni.")
					return
				end
			end
		end

		ESX.Game.SpawnVehicle(vehicle.model, {

			x = this_Garage.SpawnPoint.x,

			y = this_Garage.SpawnPoint.y,

			z = this_Garage.SpawnPoint.z + 1

		}, this_Garage.SpawnPoint.h, function(callback_vehicle)

			SetVehicleProperties(callback_vehicle, vehicle)

			SetVehRadioStation(callback_vehicle, "OFF")

			TaskWarpPedIntoVehicle(ESX.PlayerData.ped, callback_vehicle, -1)

			if gps ~= nil and gps > 0 then

				ToggleBlip(callback_vehicle)

			end
		end)
	else
		ESX.ShowNotification("Please move the vehicle that is in the way.")
	end
end

-- Entered Marker
AddEventHandler('esx_advancedgarage:hasEnteredMarker', function(zone)
	if zone == 'car_garage_point' then
		CurrentAction     = 'car_garage_point'
		CurrentActionMsg  = _U('press_to_enter')
		CurrentActionData = {}
	elseif zone == 'boat_garage_point' then
		CurrentAction     = 'boat_garage_point'
		CurrentActionMsg  = _U('press_to_enter')
		CurrentActionData = {}
	elseif zone == 'aircraft_garage_point' then
		CurrentAction     = 'aircraft_garage_point'
		CurrentActionMsg  = _U('press_to_enter')
		CurrentActionData = {}
	elseif zone == 'car_store_point' then
		CurrentAction     = 'car_store_point'
		CurrentActionMsg  = _U('press_to_delete')
		CurrentActionData = {}
	elseif zone == 'boat_store_point' then
		CurrentAction     = 'boat_store_point'
		CurrentActionMsg  = _U('press_to_delete')
		CurrentActionData = {}
	elseif zone == 'aircraft_store_point' then
		CurrentAction     = 'aircraft_store_point'
		CurrentActionMsg  = _U('press_to_delete')
		CurrentActionData = {}
	elseif zone == 'car_pound_point' then
		CurrentAction     = 'car_pound_point'
		CurrentActionMsg  = _U('press_to_impound')
		CurrentActionData = {}
	elseif zone == 'boat_pound_point' then
		CurrentAction     = 'boat_pound_point'
		CurrentActionMsg  = _U('press_to_impound')
		CurrentActionData = {}
	elseif zone == 'aircraft_pound_point' then
		CurrentAction     = 'aircraft_pound_point'
		CurrentActionMsg  = _U('press_to_impound')
		CurrentActionData = {}
	elseif zone == 'policing_pound_point' then
		CurrentAction     = 'policing_pound_point'
		CurrentActionMsg  = _U('press_to_impound')
		CurrentActionData = {}
	elseif zone == 'taxing_pound_point' then
		CurrentAction     = 'taxing_pound_point'
		CurrentActionMsg  = _U('press_to_impound')
		CurrentActionData = {}
	elseif zone == 'Sheriff_pound_point' then
		CurrentAction     = 'Sheriff_pound_point'
		CurrentActionMsg  = _U('press_to_impound')
		CurrentActionData = {}
	elseif zone == 'ambulance_pound_point' then
		CurrentAction     = 'ambulance_pound_point'
		CurrentActionMsg  = _U('press_to_impound')
		CurrentActionData = {}
	end
end)

-- Exited Marker
AddEventHandler('esx_advancedgarage:hasExitedMarker', function()
	ESX.UI.Menu.CloseAll()
	--HandleCamera(false)
	CurrentAction = nil
end)

-- Draw Markers
CreateThread(function()
	while true do
		Wait(3)
		local playerPed = ESX.PlayerData.ped
		local coords    = GetEntityCoords(playerPed)
		local canSleep  = true

		if Config.UseCarGarages then
			for k,v in pairs(Config.CarPounds) do
				if #(coords - vector3(v.PoundPoint.x, v.PoundPoint.y, v.PoundPoint.z)) < Config.DrawDistance then
					canSleep = false
					DrawMarker(Config.MarkerType, v.PoundPoint.x, v.PoundPoint.y, v.PoundPoint.z, 0.0, 0.0, 0.0, 270.0, 0.0, 0.0, Config.PoundMarker.x, Config.PoundMarker.y, Config.PoundMarker.z, Config.PoundMarker.r, Config.PoundMarker.g, Config.PoundMarker.b, 100, false, true, 2, false, false, false, false)
				end
			end
        end

		if Config.UseBoatGarages then
			for k,v in pairs(Config.BoatGarages) do
				if #(coords - vector3(v.GaragePoint.x, v.GaragePoint.y, v.GaragePoint.z)) < Config.DrawDistance then
					canSleep = false
					DrawMarker(Config.MarkerType, v.GaragePoint.x, v.GaragePoint.y, v.GaragePoint.z, 0.0, 0.0, 0.0, 270.0, 0.0, 0.0, Config.PointMarker.x, Config.PointMarker.y, Config.PointMarker.z, Config.PointMarker.r, Config.PointMarker.g, Config.PointMarker.b, 100, false, true, 2, false, false, false, false)	
					DrawMarker(Config.MarkerType, v.DeletePoint.x, v.DeletePoint.y, v.DeletePoint.z, 0.0, 0.0, 0.0, 270.0, 0.0, 0.0, Config.DeleteMarker.x, Config.DeleteMarker.y, Config.DeleteMarker.z, Config.DeleteMarker.r, Config.DeleteMarker.g, Config.DeleteMarker.b, 100, false, true, 2, false, false, false, false)	
				end
			end

			for k,v in pairs(Config.BoatPounds) do
				if #(coords - vector3(v.PoundPoint.x, v.PoundPoint.y, v.PoundPoint.z)) < Config.DrawDistance then
					canSleep = false
					DrawMarker(Config.MarkerType, v.PoundPoint.x, v.PoundPoint.y, v.PoundPoint.z, 0.0, 0.0, 0.0, 270.0, 0.0, 0.0, Config.PoundMarker.x, Config.PoundMarker.y, Config.PoundMarker.z, Config.PoundMarker.r, Config.PoundMarker.g, Config.PoundMarker.b, 100, false, true, 2, false, false, false, false)
				end
			end
		end

		if Config.UseAircraftGarages then
			for k,v in pairs(Config.AircraftGarages) do
				if #(coords - vector3(v.GaragePoint.x, v.GaragePoint.y, v.GaragePoint.z)) < Config.DrawDistance then
					canSleep = false
					DrawMarker(Config.MarkerType, v.GaragePoint.x, v.GaragePoint.y, v.GaragePoint.z, 0.0, 0.0, 0.0, 270.0, 0.0, 0.0, Config.PointMarker.x, Config.PointMarker.y, Config.PointMarker.z, Config.PointMarker.r, Config.PointMarker.g, Config.PointMarker.b, 100, false, true, 2, false, false, false, false)
                        if #(coords - vector3(v.DeletePoint.x, v.DeletePoint.y, v.DeletePoint.z)) < 80 then
					        canSleep = false
					        DrawMarker(Config.MarkerType, v.DeletePoint.x, v.DeletePoint.y, v.DeletePoint.z, 0.0, 0.0, 0.0, 270.0, 0.0, 0.0, Config.DeleteMarker2.x, Config.DeleteMarker2.y, Config.DeleteMarker2.z, Config.DeleteMarker2.r, Config.DeleteMarker2.g, Config.DeleteMarker2.b, 100, false, true, 2, false, false, false, false)
						end
				end
			end

			for k,v in pairs(Config.AircraftPounds) do
				if #(coords - vector3(v.PoundPoint.x, v.PoundPoint.y, v.PoundPoint.z)) < Config.DrawDistance then
					canSleep = false
					DrawMarker(Config.MarkerType, v.PoundPoint.x, v.PoundPoint.y, v.PoundPoint.z, 0.0, 0.0, 0.0, 270.0, 0.0, 0.0, Config.PoundMarker.x, Config.PoundMarker.y, Config.PoundMarker.z, Config.PoundMarker.r, Config.PoundMarker.g, Config.PoundMarker.b, 100, false, true, 2, false, false, false, false)
				end
			end
		end

		if Config.UsePrivateCarGarages then
			for k,v in pairs(Config.PrivateCarGarages) do
				if not v.Private or has_value(userProperties, v.Private) then
					if #(coords - vector3(v.GaragePoint.x, v.GaragePoint.y, v.GaragePoint.z)) < Config.DrawDistance then
						canSleep = false
						DrawMarker(Config.MarkerType, v.GaragePoint.x, v.GaragePoint.y, v.GaragePoint.z, 0.0, 0.0, 0.0, 270.0, 0.0, 0.0, Config.PointMarker.x, Config.PointMarker.y, Config.PointMarker.z, Config.PointMarker.r, Config.PointMarker.g, Config.PointMarker.b, 100, false, true, 2, false, false, false, false)	
						DrawMarker(Config.MarkerType, v.DeletePoint.x, v.DeletePoint.y, v.DeletePoint.z, 0.0, 0.0, 0.0, 270.0, 0.0, 0.0, Config.DeleteMarker.x, Config.DeleteMarker.y, Config.DeleteMarker.z, Config.DeleteMarker.r, Config.DeleteMarker.g, Config.DeleteMarker.b, 100, false, true, 2, false, false, false, false)	
					end
				end
			end
		end

		if Config.UseJobCarGarages then
			if ESX.PlayerData.job ~= nil and ESX.PlayerData.job.name == 'police' then
				for k,v in pairs(Config.PolicePounds) do
					if #(coords - vector3(v.PoundPoint.x, v.PoundPoint.y, v.PoundPoint.z)) < Config.DrawDistance then
						canSleep = false
						DrawMarker(Config.MarkerType, v.PoundPoint.x, v.PoundPoint.y, v.PoundPoint.z, 0.0, 0.0, 0.0, 270.0, 0.0, 0.0, Config.JobPoundMarker.x, Config.JobPoundMarker.y, Config.JobPoundMarker.z, Config.JobPoundMarker.r, Config.JobPoundMarker.g, Config.JobPoundMarker.b, 100, false, true, 2, false, false, false, false)
					end
				end
			end

			if ESX.PlayerData.job ~= nil and ESX.PlayerData.job.name == 'taxi' then
				for k,v in pairs(Config.TaxiPounds) do
					if #(coords - vector3(v.PoundPoint.x, v.PoundPoint.y, v.PoundPoint.z)) < Config.DrawDistance then
						canSleep = false
						DrawMarker(Config.MarkerType, v.PoundPoint.x, v.PoundPoint.y, v.PoundPoint.z, 0.0, 0.0, 0.0, 270.0, 0.0, 0.0, Config.JobPoundMarker.x, Config.JobPoundMarker.y, Config.JobPoundMarker.z, Config.JobPoundMarker.r, Config.JobPoundMarker.g, Config.JobPoundMarker.b, 100, false, true, 2, false, false, false, false)
					end
				end
			end

			if ESX.PlayerData.job ~= nil and ESX.PlayerData.job.name == 'sheriff' then
				for k,v in pairs(Config.SheriffPounds) do
					if #(coords - vector3(v.PoundPoint.x, v.PoundPoint.y, v.PoundPoint.z)) < Config.DrawDistance then
						canSleep = false
						DrawMarker(Config.MarkerType, v.PoundPoint.x, v.PoundPoint.y, v.PoundPoint.z, 0.0, 0.0, 0.0, 270.0, 0.0, 0.0, Config.JobPoundMarker.x, Config.JobPoundMarker.y, Config.JobPoundMarker.z, Config.JobPoundMarker.r, Config.JobPoundMarker.g, Config.JobPoundMarker.b, 100, false, true, 2, false, false, false, false)
					end
				end
			end

			if ESX.PlayerData.job ~= nil and ESX.PlayerData.job.name == 'ambulance' then
				for k,v in pairs(Config.AmbulancePounds) do
					if #(coords - vector3(v.PoundPoint.x, v.PoundPoint.y, v.PoundPoint.z)) < Config.DrawDistance then
						canSleep = false
						DrawMarker(Config.MarkerType, v.PoundPoint.x, v.PoundPoint.y, v.PoundPoint.z, 0.0, 0.0, 0.0, 270.0, 0.0, 0.0, Config.JobPoundMarker.x, Config.JobPoundMarker.y, Config.JobPoundMarker.z, Config.JobPoundMarker.r, Config.JobPoundMarker.g, Config.JobPoundMarker.b, 100, false, true, 2, false, false, false, false)
					end
				end
			end
		end

		if canSleep then
			Wait(1500)
		end
	end
end)

-- Activate Menu when in Markers
CreateThread(function()
	local currentZone = 'garage'
	while true do
		Wait(1)
		local coords = GetEntityCoords(ESX.PlayerData.ped)
		local isInMarker = false

		if Config.UseCarGarages then
			for _,v in pairs(Config.CarPounds) do
				if #(coords - vector3(v.PoundPoint.x, v.PoundPoint.y, v.PoundPoint.z)) <= Config.MarkerDistance then
				    isInMarker  = true
					this_Garage = v
					currentZone = 'car_pound_point'
				end
			end
		end

		if Config.UseBoatGarages then
			for _,v in pairs(Config.BoatGarages) do
				if #(coords - vector3(v.GaragePoint.x, v.GaragePoint.y, v.GaragePoint.z)) <= Config.MarkerDistance then
					isInMarker  = true
					this_Garage = v
					currentZone = 'boat_garage_point'
				end

				if #(coords - vector3(v.DeletePoint.x, v.DeletePoint.y, v.DeletePoint.z)) <= Config.MarkerDistance then
					isInMarker  = true
					this_Garage = v
					currentZone = 'boat_store_point'
				end
			end

			for _,v in pairs(Config.BoatPounds) do
				if #(coords - vector3(v.PoundPoint.x, v.PoundPoint.y, v.PoundPoint.z)) <= Config.MarkerDistance then
					isInMarker  = true
					this_Garage = v
					currentZone = 'boat_pound_point'
				end
			end
		end

		if Config.UseAircraftGarages then
			for _,v in pairs(Config.AircraftGarages) do
				if #(coords - vector3(v.GaragePoint.x, v.GaragePoint.y, v.GaragePoint.z)) <= Config.MarkerDistance then
					isInMarker  = true
					this_Garage = v
					currentZone = 'aircraft_garage_point'
				end

				if #(coords - vector3(v.DeletePoint.x, v.DeletePoint.y, v.DeletePoint.z)) <= Config.MarkerDistance2 then
					isInMarker  = true
					this_Garage = v
					currentZone = 'aircraft_store_point'
				end
			end

			for _,v in pairs(Config.AircraftPounds) do
				if #(coords - vector3(v.PoundPoint.x, v.PoundPoint.y, v.PoundPoint.z)) <= Config.MarkerDistance then
					isInMarker  = true
					this_Garage = v
					currentZone = 'aircraft_pound_point'
				end
			end
		end

		if Config.UsePrivateCarGarages then
			for _,v in pairs(Config.PrivateCarGarages) do
				if not v.Private or has_value(userProperties, v.Private) then
					if #(coords - vector3(v.GaragePoint.x, v.GaragePoint.y, v.GaragePoint.z)) <= Config.MarkerDistance then
						isInMarker  = true
						this_Garage = v
						currentZone = 'car_garage_point'
					end

					if #(coords - vector3(v.DeletePoint.x, v.DeletePoint.y, v.DeletePoint.z)) <= Config.MarkerDistance then
						isInMarker  = true
						this_Garage = v
						currentZone = 'car_store_point'
					end
				end
			end
		end

		if Config.UseJobCarGarages then
			if ESX.PlayerData.job and ESX.PlayerData.job.name == 'police' then
				for _,v in pairs(Config.PolicePounds) do
					if #(coords - vector3(v.PoundPoint.x, v.PoundPoint.y, v.PoundPoint.z)) <= Config.MarkerDistance then
						isInMarker  = true
						this_Garage = v
						currentZone = 'policing_pound_point'
					end
				end
			end

			if ESX.PlayerData.job and ESX.PlayerData.job.name == 'sheriff' then
				for _,v in pairs(Config.SheriffPounds) do
					if #(coords - vector3(v.PoundPoint.x, v.PoundPoint.y, v.PoundPoint.z)) <= Config.MarkerDistance then
						isInMarker  = true
						this_Garage = v
						currentZone = 'Sheriff_pound_point'
					end
				end
			end

			if ESX.PlayerData.job and ESX.PlayerData.job.name == 'ambulance' then
				for _,v in pairs(Config.AmbulancePounds) do
					if #(coords - vector3(v.PoundPoint.x, v.PoundPoint.y, v.PoundPoint.z)) <= Config.MarkerDistance then
						isInMarker  = true
						this_Garage = v
						currentZone = 'ambulance_pound_point'
					end
				end
			end
		end

		if isInMarker and not hasAlreadyEnteredMarker then
			hasAlreadyEnteredMarker = true
			LastZone                = currentZone
			TriggerEvent('esx_advancedgarage:hasEnteredMarker', currentZone)
		end

		if not isInMarker and hasAlreadyEnteredMarker then
			hasAlreadyEnteredMarker = false
			TriggerEvent('esx_advancedgarage:hasExitedMarker', LastZone)
		end

		if not isInMarker then
			Wait(1500)
		end
	end
end)

-- Key Controls
CreateThread(function()
	while true do
		Wait(3)
		if CurrentAction ~= nil then
			ESX.ShowHelpNotification(CurrentActionMsg)

			if IsControlJustReleased(0, 38) then
				if CurrentAction == 'car_garage_point' then
					OpenMenuGarage('car_garage_point')
				elseif CurrentAction == 'boat_garage_point' then
					OpenMenuGarage('boat_garage_point')
				elseif CurrentAction == 'aircraft_garage_point' then
					OpenMenuGarage('aircraft_garage_point')
				elseif CurrentAction == 'car_store_point' then
					OpenMenuGarage('car_store_point')
				elseif CurrentAction == 'boat_store_point' then
					OpenMenuGarage('boat_store_point')
				elseif CurrentAction == 'aircraft_store_point' then
					OpenMenuGarage('aircraft_store_point')
				elseif CurrentAction == 'car_pound_point' then
					OpenMenuGarage('car_pound_point')
				elseif CurrentAction == 'boat_pound_point' then
					OpenMenuGarage('boat_pound_point')
				elseif CurrentAction == 'aircraft_pound_point' then
					OpenMenuGarage('aircraft_pound_point')
				elseif CurrentAction == 'policing_pound_point' then
					OpenMenuGarage('policing_pound_point')
				elseif CurrentAction == 'taxing_pound_point' then
					OpenMenuGarage('taxing_pound_point')
				elseif CurrentAction == 'Sheriff_pound_point' then
					OpenMenuGarage('Sheriff_pound_point')
				elseif CurrentAction == 'ambulance_pound_point' then
					OpenMenuGarage('ambulance_pound_point')
				elseif CurrentAction == 'ballas_pound_point' then
					OpenMenuGarage('ballas_pound_point')
				elseif CurrentAction == 'soa_pound_point' then
					OpenMenuGarage('soa_pound_point')
				elseif CurrentAction == 'mufflers_pound_point' then
					OpenMenuGarage('mufflers_pound_point')
				end

				CurrentAction = nil
			end
		else
			Wait(1000)
		end
	end
end)

-- Create Blips

function PrivateGarageBlips()
	for _, blip in pairs(privateBlips) do
		RemoveBlip(blip)
	end

	privateBlips = {}

	for _, v in pairs(Config.PrivateCarGarages) do
		if v.Private and has_value(userProperties, v.Private) then
			local blip = AddBlipForCoord(v.GaragePoint.x, v.GaragePoint.y, v.GaragePoint.z)
			SetBlipSprite(blip, Config.BlipGaragePrivate.Sprite)
			SetBlipDisplay(blip, Config.BlipGaragePrivate.Display)
			SetBlipScale(blip, Config.BlipGaragePrivate.Scale)
			SetBlipColour(blip, Config.BlipGaragePrivate.Color)
			SetBlipAsShortRange(blip, true)
			BeginTextCommandSetBlipName("STRING")
			AddTextComponentString(_U('blip_garage_private'))
			EndTextCommandSetBlipName(blip)
		end
	end
end

function deleteBlips()
	if JobBlips[1] ~= nil then
		for i = 1, #JobBlips do
			RemoveBlip(JobBlips[i])
			JobBlips[i] = nil
		end
	end
end

function refreshBlips()
	local blipList = {}

	local JobBlips = {}

	if Config.UseCarGarages then
		for _,v in pairs(Config.CarPounds) do
			blipList[#blipList+1] = {
				coords = { v.PoundPoint.x, v.PoundPoint.y },
				text   = _U('blip_pound'),
				sprite = Config.BlipPound.Sprite,
				color  = Config.BlipPound.Color,
				scale  = Config.BlipPound.Scale
			}
		end
	end

	if Config.UseBoatGarages then
		for _,v in pairs(Config.BoatGarages) do
			blipList[#blipList+1] = {
				coords = { v.GaragePoint.x, v.GaragePoint.y },
				text   = _U('garage_boats'),
				sprite = Config.BlipGarage.Sprite,
				color  = Config.BlipGarage.Color,
				scale  = Config.BlipGarage.Scale
			}
		end

		for _,v in pairs(Config.BoatPounds) do
			blipList[#blipList+1] = {
				coords = { v.PoundPoint.x, v.PoundPoint.y },
				text   = _U('blip_pound'),
				sprite = Config.BlipPound.Sprite,
				color  = Config.BlipPound.Color,
				scale  = Config.BlipPound.Scale
			}
		end
	end

	if Config.UseAircraftGarages then
		for _,v in pairs(Config.AircraftGarages) do
			table.insert(blipList, {
				coords = { v.GaragePoint.x, v.GaragePoint.y },
				text   = _U('garage_aircrafts'),
				sprite = Config.BlipGarage.Sprite,
				color  = Config.BlipGarage.Color,
				scale  = Config.BlipGarage.Scale
			})
		end

		for _,v in pairs(Config.AircraftPounds) do
			table.insert(blipList, {
				coords = { v.PoundPoint.x, v.PoundPoint.y },
				text   = _U('blip_pound'),
				sprite = Config.BlipPound.Sprite,
				color  = Config.BlipPound.Color,
				scale  = Config.BlipPound.Scale
			})
		end
	end

	if Config.UseJobCarGarages then
		if ESX.PlayerData.job and ESX.PlayerData.job.name == 'police' then
			for _,v in pairs(Config.PolicePounds) do
				table.insert(JobBlips, {
					coords = { v.PoundPoint.x, v.PoundPoint.y },
					text   = _U('blip_police_pound'),
					sprite = Config.BlipJobPound.Sprite,
					color  = Config.BlipJobPound.Color,
					scale  = Config.BlipJobPound.Scale
				})
			end
		end

		if ESX.PlayerData.job and ESX.PlayerData.job.name == 'sheriff' then
			for _,v in pairs(Config.SheriffPounds) do
				table.insert(JobBlips, {
					coords = { v.PoundPoint.x, v.PoundPoint.y },
					text   = _U('blip_sheriff_pound'),
					sprite = Config.BlipJobPound.Sprite,
					color  = Config.BlipJobPound.Color,
					scale  = Config.BlipJobPound.Scale
				})
			end
		end

		if ESX.PlayerData.job and ESX.PlayerData.job.name == 'ambulance' then
			for _,v in pairs(Config.AmbulancePounds) do
				table.insert(JobBlips, {
					coords = { v.PoundPoint.x, v.PoundPoint.y },
					text   = _U('blip_ambulance_pound'),
					sprite = Config.BlipJobPound.Sprite,
					color  = Config.BlipJobPound.Color,
					scale  = Config.BlipJobPound.Scale
				})
			end
		end
	end

	for i = 1, #blipList do
		CreateBlip(blipList[i].coords, blipList[i].text, blipList[i].sprite, blipList[i].color, blipList[i].scale)
	end

	for i = 1, #JobBlips do
		CreateBlip(JobBlips[i].coords, JobBlips[i].text, JobBlips[i].sprite, JobBlips[i].color, JobBlips[i].scale)
	end

end

function CreateBlip(coords, text, sprite, color, scale)
    local x, y = table.unpack(coords)
	local blip = AddBlipForCoord(x, y)
	SetBlipSprite(blip, sprite)
	SetBlipScale(blip, scale)
	SetBlipColour(blip, color)
	SetBlipAsShortRange(blip, true)
	BeginTextCommandSetBlipName('STRING')
	AddTextComponentSubstringPlayerName(text)
	EndTextCommandSetBlipName(blip)
	table.insert(JobBlips, blip)
end
