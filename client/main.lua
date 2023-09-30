Keys = {
	["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57, 
	["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177, 
	["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
	["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
	["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
	["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70, 
	["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
	["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
	["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

cachedData = {}

local carInWorld = {}

local JobBlips = {}

local HasAlreadyEnteredMarker = false

local LastZone = nil

local CurrentAction = nil

local CurrentActionMsg = ''

local CurrentActionData = {}

local userProperties = {}

local privateBlips = {}

this_Garage = {}

carBlips = {}


--[[CreateThread(function()
      Wait(5580)
	refreshBlips()
end)]]

CreateThread(function()
	local CanDraw = function(action)
		if action == "vehicle" then
			if IsPedInAnyVehicle(ESX.PlayerData.ped) then
				local vehicle = GetVehiclePedIsIn(ESX.PlayerData.ped)

				if GetPedInVehicleSeat(vehicle, -1) == ESX.PlayerData.ped then
					return true
				else
					return false
				end
			else
				return false
			end
		end

		return true
	end

	local GetDisplayText = function(action, garage)
		if not Config.Labels[action] then Config.Labels[action] = action end

		return string.format(Config.Labels[action], action == "vehicle" and GetLabelText(GetDisplayNameFromVehicleModel(GetEntityModel(GetVehiclePedIsUsing(ESX.PlayerData.ped)))) or garage)
	end

	for garage, garageData in pairs(Config.Garages) do
		local garageBlip = AddBlipForCoord(garageData["positions"]["menu"]["position"])

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
		local sleepThread = 1500

		local ped = ESX.PlayerData.ped
		local pedCoords = GetEntityCoords(ped)

		for garage, garageData in pairs(Config.Garages) do
			for action, actionData in pairs(garageData["positions"]) do
				local dstCheck = #(pedCoords - actionData["position"])

				if dstCheck <= 40.0 then
					sleepThread = 3

					local draw = CanDraw(action)

					if draw then
						local markerSize = action == "vehicle" and 5.0 or 1.5

						if dstCheck <= markerSize - 0.1 then
							local usable, displayText = not DoesCamExist(cachedData["cam"]), GetDisplayText(action, garage)
							
							ESX.ShowHelpNotification(usable and displayText or "Válaszd ki az autót.")

							if usable then
								if IsControlJustPressed(0, 38) then
									cachedData["currentGarage"] = garage

									HandleAction(action)
								end
							end
						end
    					
						DrawScriptMarker({
							["type"] = 6,
							["pos"] = actionData["position"] - vector3(0.0, 0.0, 0.985),
							["sizeX"] = markerSize,
							["sizeY"] = markerSize,
							["sizeZ"] = markerSize,
							["rotate"] = -180.0,
							["r"] = 51,
							["g"] = 255,
							["b"] = 0
						})
					end
				end
			end
		end
		Wait(sleepThread)
	end
end)

-- Exited Marker
AddEventHandler('garage:hasExitedMarker', function()
	ESX.UI.Menu.CloseAll()
	CurrentAction = nil
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	if Config.UsePrivateCarGarages == true then
		ESX.TriggerServerCallback('esx_advancedgarage:getOwnedProperties', function(properties)
			userProperties = properties
			PrivateGarageBlips()
		end)
	end
	
	ESX.PlayerData = xPlayer
	refreshBlips()
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    ESX.PlayerData.job = job
	deleteBlips()
	refreshBlips()
end)

local function has_value (tab, val)
	for index, value in ipairs(tab) do
		if value == val then
			return true
		end
	end
	return false
end

-- Open Main Menu
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
	elseif PointType == 'ballas_pound_point' then
		table.insert(elements, {label = _U('return_owned_ballas').." ($"..Config.ballasPoundPrice..")", value = 'return_owned_ballas'})
	elseif PointType == 'soa_pound_point' then
		table.insert(elements, {label = _U('return_owned_soa').." ($"..Config.soaPoundPrice..")", value = 'return_owned_soa'})
	elseif PointType == 'mufflers_pound_point' then
		table.insert(elements, {label = _U('return_owned_mufflers').." ($"..Config.mufflersPoundPrice..")", value = 'return_owned_mufflers'})
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
		elseif action == 'return_owned_mufflers' then
			ReturnOwnedmufflersMenu()
		elseif action == 'return_owned_soa' then
			ReturnOwnedsoaMenu()
		elseif action == 'return_owned_ballas' then
			ReturnOwnedballasMenu()
		end
	end, function(data, menu)
		menu.close()
	end)
end

-- List Owned Cars Menu


-- List Owned Boats Menu
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
			--exports['mythic_notify']:SendAlert('inform', _U('garage_noboats'), 3000, { ['background-color'] = '#FF0000', ['color'] = '#ffffff' })
		else
			for _,v in pairs(ownedBoats) do
				if Config.UseVehicleNamesLua then
					local hashVehicule = v.vehicle.model
					local aheadVehName = GetDisplayNameFromVehicleModel(hashVehicule)
					local vehicleName  = GetLabelText(aheadVehName)
					local plate        = v.plate
					local labelvehicle
					
					if Config.ShowVehicleLocation then
						if v.stored then
							labelvehicle = '| '..plate..' | '..vehicleName..' | '.._U('loc_garage')..' |'
						else
							labelvehicle = '| '..plate..' | '..vehicleName..' | '.._U('loc_pound')..' |'
						end
					else
						if v.stored then
							labelvehicle = '| '..plate..' | '..vehicleName..' |'
						else
							labelvehicle = '| '..plate..' | '..vehicleName..' |'
						end
					end
					
					table.insert(elements, {label = labelvehicle, value = v})
				else
					local hashVehicule = v.vehicle.model
					local vehicleName  = GetDisplayNameFromVehicleModel(hashVehicule)
					local plate        = v.plate
					local labelvehicle
					
					if Config.ShowVehicleLocation then
						if v.stored then
							labelvehicle = '| '..plate..' | '..vehicleName..' | '.._U('loc_garage')..' |'
						else
							labelvehicle = '| '..plate..' | '..vehicleName..' | '.._U('loc_pound')..' |'
						end
					else
						if v.stored then
							labelvehicle = '| '..plate..' | '..vehicleName..' |'
						else
							labelvehicle = '| '..plate..' | '..vehicleName..' |'
						end
					end
					
					table.insert(elements, {label = labelvehicle, value = v})
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
				SpawnVehicle(data.current.value.vehicle, data.current.value.plate)
			else
				ESX.ShowNotification(_U('boat_is_impounded'))
				--exports['mythic_notify']:SendAlert('inform', _U('boat_is_impounded'), 3000, { ['background-color'] = '#FF0000', ['color'] = '#ffffff' })
			end
		end, function(data, menu)
			menu.close()
		end)
	end)
end

-- List Owned Aircrafts Menu
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
			for _,v in pairs(ownedAircrafts) do
				if Config.UseVehicleNamesLua then
					local hashVehicule = v.vehicle.model
					local aheadVehName = GetDisplayNameFromVehicleModel(hashVehicule)
					local vehicleName  = GetLabelText(aheadVehName)
					local plate        = v.plate
					local labelvehicle
					
					if Config.ShowVehicleLocation then
						if v.stored then
							labelvehicle = '| '..plate..' | '..vehicleName..' | '.._U('loc_garage')..' |'
						else
							labelvehicle = '| '..plate..' | '..vehicleName..' | '.._U('loc_pound')..' |'
						end
					else
						if v.stored then
							labelvehicle = '| '..plate..' | '..vehicleName..' |'
						else
							labelvehicle = '| '..plate..' | '..vehicleName..' |'
						end
					end
					
					table.insert(elements, {label = labelvehicle, value = v})
				else
					local hashVehicule = v.vehicle.model
					local vehicleName  = GetDisplayNameFromVehicleModel(hashVehicule)
					local plate        = v.plate
					local labelvehicle
					
					if Config.ShowVehicleLocation then
						if v.stored then
							labelvehicle = '| '..plate..' | '..vehicleName..' | '.._U('loc_garage')..' |'
						else
							labelvehicle = '| '..plate..' | '..vehicleName..' | '.._U('loc_pound')..' |'
						end
					else
						if v.stored then
							labelvehicle = '| '..plate..' | '..vehicleName..' |'
						else
							labelvehicle = '| '..plate..' | '..vehicleName..' |'
						end
					end
					
					table.insert(elements, {label = labelvehicle, value = v})
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
				SpawnVehicle(data.current.value.vehicle, data.current.value.plate)
			else
				ESX.ShowNotification(_U('aircraft_is_impounded'))
				--exports['mythic_notify']:SendAlert('inform', _U('aircraft_is_impounded'), 3000, { ['background-color'] = '#FF0000', ['color'] = '#ffffff' })
			end
		end, function(data, menu)
			menu.close()
		end)
	end)
end

-- Store Owned Cars Menu
function StoreOwnedCarsMenu()
        local currentGarage = cachedData["currentGarage"]
        if not currentGarage then return end
	local playerPed  = ESX.PlayerData.ped
	if IsPedInAnyVehicle(playerPed,  false) then
		local playerPed    = ESX.PlayerData.ped
		local coords       = GetEntityCoords(playerPed)
		local vehicle      = GetVehiclePedIsIn(playerPed, false)
		local vehicleProps = ESX.Game.GetVehicleProperties(vehicle)
		local current 	   = GetPlayersLastVehicle(ESX.PlayerData.ped, true)
		local engineHealth = GetVehicleEngineHealth(current)
		local plate        = vehicleProps.plate
		
		ESX.TriggerServerCallback('esx_advancedgarage:storeVehicle', function(valid)
			if valid then
					StoreVehicle(vehicle, vehicleProps)	
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

-- Store Owned Boats Menu
function StoreOwnedBoatsMenu()
	local playerPed  = ESX.PlayerData.ped
	if IsPedInAnyVehicle(playerPed,  false) then
		local coords        = GetEntityCoords(playerPed)
		local vehicle       = GetVehiclePedIsIn(playerPed, false)
		local vehicleProps  = ESX.Game.GetVehicleProperties(vehicle)
		local current 	    = GetPlayersLastVehicle(ESX.PlayerData.ped, true)
		local engineHealth  = GetVehicleEngineHealth(current)
		local plate         = vehicleProps.plate
		
		ESX.TriggerServerCallback('esx_advancedgarage:storeVehicle', function(valid)
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

-- Store Owned Aircrafts Menu
function StoreOwnedAircraftsMenu()
	local playerPed  = ESX.PlayerData.ped
	if IsPedInAnyVehicle(playerPed,  false) then
		local coords        = GetEntityCoords(playerPed)
		local vehicle       = GetVehiclePedIsIn(playerPed, false)
		local vehicleProps  = ESX.Game.GetVehicleProperties(vehicle)
		local current 	    = GetPlayersLastVehicle(ESX.PlayerData.ped, true)
		local engineHealth  = GetVehicleEngineHealth(current)
		local plate         = vehicleProps.plate
		
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

-- Pound Owned Cars Menu
function ReturnOwnedCarsMenu()
	ESX.TriggerServerCallback('esx_advancedgarage:getOutOwnedCars', function(ownedCars)
		local elements = {}
		
		if Config.ShowPoundSpacer2 then
			table.insert(elements, {label = _U('spacer2')})
		end
		
		if Config.ShowPoundSpacer3 then
			table.insert(elements, {label = _U('spacer3')})
		end
		
		for _,v in pairs(ownedCars) do
			if Config.UseVehicleNamesLua then
				local hashVehicule = v.model
				local aheadVehName = GetDisplayNameFromVehicleModel(hashVehicule)
				local vehicleName  = GetLabelText(aheadVehName)
				local plate        = v.plate
				local labelvehicle
				
				labelvehicle = '| '..plate..' | '..vehicleName..' | '.._U('return')..' |'
				
				table.insert(elements, {label = labelvehicle, value = v})
			else
				local hashVehicule = v.model
				local vehicleName  = GetDisplayNameFromVehicleModel(hashVehicule)
				local plate        = v.plate
				local labelvehicle
				
				labelvehicle = '| '..plate..' | '..vehicleName..' | '.._U('return')..' |'
				
				table.insert(elements, {label = labelvehicle, value = v})
			end
		end
		
			ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'return_owned_car', {
				title = _U('pound_cars', ESX.Math.GroupDigits(Config.CarPoundPrice)),
			        align    = 'bottom-right',
				elements = elements
			}, function(data, menu)
			ESX.TriggerServerCallback('esx_advancedgarage:checkMoneyCars', function(hasEnoughMoney)
				if hasEnoughMoney then
					TriggerServerEvent('esx_advancedgarage:payCar')
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

-- Pound Owned Boats Menu
function ReturnOwnedBoatsMenu()
	ESX.TriggerServerCallback('esx_advancedgarage:getOutOwnedBoats', function(ownedBoats)
		local elements = {}
		
		if Config.ShowPoundSpacer2 then
			table.insert(elements, {label = _U('spacer2')})
		end
		
		if Config.ShowPoundSpacer3 then
			table.insert(elements, {label = _U('spacer3')})
		end
		
		for _,v in pairs(ownedBoats) do
			if Config.UseVehicleNamesLua then
				local hashVehicule = v.model
				local aheadVehName = GetDisplayNameFromVehicleModel(hashVehicule)
				local vehicleName  = GetLabelText(aheadVehName)
				local plate        = v.plate
				local labelvehicle
				
				labelvehicle = '| '..plate..' | '..vehicleName..' | '.._U('return')..' |'
				
				table.insert(elements, {label = labelvehicle, value = v})
			else
				local hashVehicule = v.model
				local vehicleName  = GetDisplayNameFromVehicleModel(hashVehicule)
				local plate        = v.plate
				local labelvehicle
				
				labelvehicle = '| '..plate..' | '..vehicleName..' | '.._U('return')..' |'
				
				table.insert(elements, {label = labelvehicle, value = v})
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

-- Spawn Pound Boats
function SpawnPoundedBoat(vehicle, plate)

	if ESX.Game.IsSpawnPointClear(vector3(this_Garage.SpawnPoint.x, this_Garage.SpawnPoint.y, this_Garage.SpawnPoint.z), 3.0) then 

		ESX.Game.SpawnVehicle(vehicle.model, {

			x = this_Garage.SpawnPoint.x,

			y = this_Garage.SpawnPoint.y,

			z = this_Garage.SpawnPoint.z + 1

		}, this_Garage.SpawnPoint.h, function(callback_vehicle)

			SetVehicleProperties(callback_vehicle, vehicle)

			SetVehRadioStation(callback_vehicle, "OFF")

            --SetVehicleBodyHealth(callback_vehicle, 1000.0)

            --SetVehicleFixed(callback_vehicle)

            --SetVehicleEngineHealth(callback_vehicle, 1000)

	        --SetVehicleDeformationFixed(callback_vehicle)

			TaskWarpPedIntoVehicle(ESX.PlayerData.ped, callback_vehicle, -1)

			--AddVehicleKeys(callback_vehicle)

			--TriggerServerEvent('LegacyFuel:UpdateServerFuelTable', plate, vehicle.fuelLevel)



			if gps ~= nil and gps > 0 then

				ToggleBlip(callback_vehicle)

			end

			table.insert(carInWorld, {vehicleentity = callback_vehicle, plate = plate})

		end)
	
		--TriggerServerEvent('esx_advancedgarage:setVehicleState', plate, false)
	else

		ESX.ShowNotification("Please move the vehicle that is in the way.")
		--exports['mythic_notify']:SendAlert('inform', 'Útban van egy autó!', 3000, { ['background-color'] = '#FF0000', ['color'] = '#ffffff' })

	end
end

-- Pound Owned Aircrafts Menu
function ReturnOwnedAircraftsMenu()
	ESX.TriggerServerCallback('esx_advancedgarage:getOutOwnedAircrafts', function(ownedAircrafts)
		local elements = {}
		
		if Config.ShowPoundSpacer2 then
			table.insert(elements, {label = _U('spacer2')})
		end
		
		if Config.ShowPoundSpacer3 then
			table.insert(elements, {label = _U('spacer3')})
		end
		
		for _,v in pairs(ownedAircrafts) do
			if Config.UseVehicleNamesLua then
				local hashVehicule = v.model
				local aheadVehName = GetDisplayNameFromVehicleModel(hashVehicule)
				local vehicleName  = GetLabelText(aheadVehName)
				local plate        = v.plate
				local labelvehicle
				
				labelvehicle = '| '..plate..' | '..vehicleName..' | '.._U('return')..' |'
				
				table.insert(elements, {label = labelvehicle, value = v})
			else
				local hashVehicule = v.model
				local vehicleName  = GetDisplayNameFromVehicleModel(hashVehicule)
				local plate        = v.plate
				local labelvehicle
				
				labelvehicle = '| '..plate..' | '..vehicleName..' | '.._U('return')..' |'
				
				table.insert(elements, {label = labelvehicle, value = v})
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

-- Spawn Pound Aircraft with repair
function SpawnPoundedAircraft(vehicle, plate)

	if ESX.Game.IsSpawnPointClear(vector3(this_Garage.SpawnPoint.x, this_Garage.SpawnPoint.y, this_Garage.SpawnPoint.z), 3.0) then 

		ESX.Game.SpawnVehicle(vehicle.model, {

			x = this_Garage.SpawnPoint.x,

			y = this_Garage.SpawnPoint.y,

			z = this_Garage.SpawnPoint.z + 1

		}, this_Garage.SpawnPoint.h, function(callback_vehicle)

			SetVehicleProperties(callback_vehicle, vehicle)

			SetVehRadioStation(callback_vehicle, "OFF")

            --SetVehicleBodyHealth(callback_vehicle, 1000.0)

            --SetVehicleFixed(callback_vehicle)

            --SetVehicleEngineHealth(callback_vehicle, 1000)

	        --SetVehicleDeformationFixed(callback_vehicle)

			TaskWarpPedIntoVehicle(ESX.PlayerData.ped, callback_vehicle, -1)

			--AddVehicleKeys(callback_vehicle)

			--TriggerServerEvent('LegacyFuel:UpdateServerFuelTable', plate, vehicle.fuelLevel)



			if gps ~= nil and gps > 0 then

				ToggleBlip(callback_vehicle)

			end

			table.insert(carInWorld, {vehicleentity = callback_vehicle, plate = plate})

		end)
	
		--TriggerServerEvent('esx_advancedgarage:setVehicleState', plate, false)
	else

		ESX.ShowNotification("Valami útban van.")
		--exports['mythic_notify']:SendAlert('inform', 'Útban van egy autó!', 3000, { ['background-color'] = '#FF0000', ['color'] = '#ffffff' })

	end
end

-- Pound Owned Policing Menu
function ReturnOwnedPolicingMenu()
	ESX.TriggerServerCallback('esx_advancedgarage:getOutOwnedPoliceCars', function(ownedPolicingCars)
		local elements = {}
		
		if Config.ShowPoundSpacer2 then
			table.insert(elements, {label = _U('spacer2')})
		end
		
		if Config.ShowPoundSpacer3 then
			table.insert(elements, {label = _U('spacer3')})
		end
		
		for _,v in pairs(ownedPolicingCars) do
			if Config.UseVehicleNamesLua then
				local hashVehicule = v.model
				local aheadVehName = GetDisplayNameFromVehicleModel(hashVehicule)
				local vehicleName  = GetLabelText(aheadVehName)
				local plate        = v.plate
				local labelvehicle
				
				labelvehicle = '| '..plate..' | '..vehicleName..' | '.._U('return')..' |'
				
				table.insert(elements, {label = labelvehicle, value = v})
			else
				local hashVehicule = v.model
				local vehicleName  = GetDisplayNameFromVehicleModel(hashVehicule)
				local plate        = v.plate
				local labelvehicle
				
				labelvehicle = '| '..plate..' | '..vehicleName..' | '.._U('return')..' |'
				
				table.insert(elements, {label = labelvehicle, value = v})
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

-- Pound Owned Taxing Menu
function ReturnOwnedTaxingMenu()
	ESX.TriggerServerCallback('esx_advancedgarage:getOutOwnedTaxingCars', function(ownedTaxingCars)
		local elements = {}
		
		if Config.ShowPoundSpacer2 then
			table.insert(elements, {label = _U('spacer2')})
		end
		
		if Config.ShowPoundSpacer3 then
			table.insert(elements, {label = _U('spacer3')})
		end
		
		for _,v in pairs(ownedTaxingCars) do
			if Config.UseVehicleNamesLua then
				local hashVehicule = v.model
				local aheadVehName = GetDisplayNameFromVehicleModel(hashVehicule)
				local vehicleName  = GetLabelText(aheadVehName)
				local plate        = v.plate
				local labelvehicle
				
				labelvehicle = '| '..plate..' | '..vehicleName..' | '.._U('return')..' |'
				
				table.insert(elements, {label = labelvehicle, value = v})
			else
				local hashVehicule = v.model
				local vehicleName  = GetDisplayNameFromVehicleModel(hashVehicule)
				local plate        = v.plate
				local labelvehicle
				
				labelvehicle = '| '..plate..' | '..vehicleName..' | '.._U('return')..' |'
				
				table.insert(elements, {label = labelvehicle, value = v})
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

-- Pound Owned Sheriff Menu
function ReturnOwnedSheriffMenu()
	ESX.TriggerServerCallback('esx_advancedgarage:getOutOwnedSheriffCars', function(ownedSheriffCars)
		local elements = {}
		
		if Config.ShowPoundSpacer2 then
			table.insert(elements, {label = _U('spacer2')})
		end
		
		if Config.ShowPoundSpacer3 then
			table.insert(elements, {label = _U('spacer3')})
		end
		
		for _,v in pairs(ownedSheriffCars) do
			if Config.UseVehicleNamesLua then
				local hashVehicule = v.model
				local aheadVehName = GetDisplayNameFromVehicleModel(hashVehicule)
				local vehicleName  = GetLabelText(aheadVehName)
				local plate        = v.plate
				local labelvehicle
				
				labelvehicle = '| '..plate..' | '..vehicleName..' | '.._U('return')..' |'
				
				table.insert(elements, {label = labelvehicle, value = v})
			else
				local hashVehicule = v.model
				local vehicleName  = GetDisplayNameFromVehicleModel(hashVehicule)
				local plate        = v.plate
				local labelvehicle
				
				labelvehicle = '| '..plate..' | '..vehicleName..' | '.._U('return')..' |'
				
				table.insert(elements, {label = labelvehicle, value = v})
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

-- Pound Owned Ambulance Menu
function ReturnOwnedAmbulanceMenu()
	ESX.TriggerServerCallback('esx_advancedgarage:getOutOwnedAmbulanceCars', function(ownedAmbulanceCars)
		local elements = {}
		
		if Config.ShowPoundSpacer2 then
			table.insert(elements, {label = _U('spacer2')})
		end
		
		if Config.ShowPoundSpacer3 then
			table.insert(elements, {label = _U('spacer3')})
		end
		
		for _,v in pairs(ownedAmbulanceCars) do
			if Config.UseVehicleNamesLua then
				local hashVehicule = v.model
				local aheadVehName = GetDisplayNameFromVehicleModel(hashVehicule)
				local vehicleName  = GetLabelText(aheadVehName)
				local plate        = v.plate
				local labelvehicle
				
				labelvehicle = '| '..plate..' | '..vehicleName..' | '.._U('return')..' |'
				
				table.insert(elements, {label = labelvehicle, value = v})
			else
				local hashVehicule = v.model
				local vehicleName  = GetDisplayNameFromVehicleModel(hashVehicule)
				local plate        = v.plate
				local labelvehicle
				
				labelvehicle = '| '..plate..' | '..vehicleName..' | '.._U('return')..' |'
				
				table.insert(elements, {label = labelvehicle, value = v})
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

-- Pound Owned ballas Menu
function ReturnOwnedballasMenu()
	ESX.TriggerServerCallback('esx_advancedgarage:getOutOwnedballasCars', function(ownedballasCars)
		local elements = {}
		
		if Config.ShowPoundSpacer2 then
			table.insert(elements, {label = _U('spacer2')})
		end
		
		if Config.ShowPoundSpacer3 then
			table.insert(elements, {label = _U('spacer3')})
		end
		
		for _,v in pairs(ownedballasCars) do
			if Config.UseVehicleNamesLua then
				local hashVehicule = v.model
				local aheadVehName = GetDisplayNameFromVehicleModel(hashVehicule)
				local vehicleName  = GetLabelText(aheadVehName)
				local plate        = v.plate
				local labelvehicle
				
				labelvehicle = '| '..plate..' | '..vehicleName..' | '.._U('return')..' |'
				
				table.insert(elements, {label = labelvehicle, value = v})
			else
				local hashVehicule = v.model
				local vehicleName  = GetDisplayNameFromVehicleModel(hashVehicule)
				local plate        = v.plate
				local labelvehicle
				
				labelvehicle = '| '..plate..' | '..vehicleName..' | '.._U('return')..' |'
				
				table.insert(elements, {label = labelvehicle, value = v})
			end
		end
		
		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'return_owned_ballas', {
			title    = _U('pound_ballas'),
			align    = 'bottom-right',
			elements = elements
		}, function(data, menu)
			ESX.TriggerServerCallback('esx_advancedgarage:checkMoneyballas', function(hasEnoughMoney)
				if hasEnoughMoney then
					TriggerServerEvent('esx_advancedgarage:payballas')
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

-- Pound Owned soa Menu
function ReturnOwnedsoaMenu()
	ESX.TriggerServerCallback('esx_advancedgarage:getOutOwnedsoaCars', function(ownedsoaCars)
		local elements = {}
		
		if Config.ShowPoundSpacer2 then
			table.insert(elements, {label = _U('spacer2')})
		end
		
		if Config.ShowPoundSpacer3 then
			table.insert(elements, {label = _U('spacer3')})
		end
		
		for _,v in pairs(ownedsoaCars) do
			if Config.UseVehicleNamesLua then
				local hashVehicule = v.model
				local aheadVehName = GetDisplayNameFromVehicleModel(hashVehicule)
				local vehicleName  = GetLabelText(aheadVehName)
				local plate        = v.plate
				local labelvehicle
				
				labelvehicle = '| '..plate..' | '..vehicleName..' | '.._U('return')..' |'
				
				table.insert(elements, {label = labelvehicle, value = v})
			else
				local hashVehicule = v.model
				local vehicleName  = GetDisplayNameFromVehicleModel(hashVehicule)
				local plate        = v.plate
				local labelvehicle
				
				labelvehicle = '| '..plate..' | '..vehicleName..' | '.._U('return')..' |'
				
				table.insert(elements, {label = labelvehicle, value = v})
			end
		end
		
		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'return_owned_soa', {
			title    = _U('pound_soa'),
			align    = 'bottom-right',
			elements = elements
		}, function(data, menu)
			ESX.TriggerServerCallback('esx_advancedgarage:checkMoneysoa', function(hasEnoughMoney)
				if hasEnoughMoney then
					TriggerServerEvent('esx_advancedgarage:paysoa')
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

-- Pound Owned mufflers Menu
function ReturnOwnedmufflersMenu()
	ESX.TriggerServerCallback('esx_advancedgarage:getOutOwnedmufflersCars', function(ownedmufflersCars)
		local elements = {}
		
		if Config.ShowPoundSpacer2 then
			table.insert(elements, {label = _U('spacer2')})
		end
		
		if Config.ShowPoundSpacer3 then
			table.insert(elements, {label = _U('spacer3')})
		end
		
		for _,v in pairs(ownedmufflersCars) do
			if Config.UseVehicleNamesLua then
				local hashVehicule = v.model
				local aheadVehName = GetDisplayNameFromVehicleModel(hashVehicule)
				local vehicleName  = GetLabelText(aheadVehName)
				local plate        = v.plate
				local labelvehicle
				
				labelvehicle = '| '..plate..' | '..vehicleName..' | '.._U('return')..' |'
				
				table.insert(elements, {label = labelvehicle, value = v})
			else
				local hashVehicule = v.model
				local vehicleName  = GetDisplayNameFromVehicleModel(hashVehicule)
				local plate        = v.plate
				local labelvehicle
				
				labelvehicle = '| '..plate..' | '..vehicleName..' | '.._U('return')..' |'
				
				table.insert(elements, {label = labelvehicle, value = v})
			end
		end
		
		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'return_owned_mufflers', {
			title    = _U('pound_mufflers'),
			align    = 'bottom-right',
			elements = elements
		}, function(data, menu)
			ESX.TriggerServerCallback('esx_advancedgarage:checkMoneymufflers', function(hasEnoughMoney)
				if hasEnoughMoney then
					TriggerServerEvent('esx_advancedgarage:paymufflers')
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

-- Repair Vehicles
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
			vehicleProps.bodyHealth = 1000.0 -- must be a decimal value!!!
			vehicleProps.engineHealth = 1000
                        SetVehicleUndriveable(vehicle, false)
                        SetVehicleFixed(vehicle)
                        Wait(200)
                        local vehicleProps  = ESX.Game.GetVehicleProperties(vehicle)
			StoreVehicle2(vehicle, vehicleProps)
		elseif data.current.value == 'no' then
			ESX.ShowNotification(_U('visit_mechanic'))
			--exports['mythic_notify']:SendAlert('inform', _U('visit_mechanic'), 3000, { ['background-color'] = '#FF0000', ['color'] = '#ffffff' })
		end
	end, function(data, menu)
		menu.close()
	end)
end

-- Store Vehicles
function StoreVehicle(vehicle, vehicleProps)
	TaskLeaveVehicle(ESX.PlayerData.ped, vehicle, 1)
	Citizen.Wait(1000)
	ESX.Game.DeleteVehicle(vehicle)
	TriggerServerEvent('esx_advancedgarage:setVehicleState', vehicleProps.plate, 1)
	ESX.ShowNotification(_U('vehicle_in_garage'))
	--exports['mythic_notify']:SendAlert('inform', _U('vehicle_in_garage'), 3000, { ['background-color'] = '#FF0000', ['color'] = '#ffffff' })
end

function StoreVehicle2(vehicle, vehicleProps)
	TaskLeaveVehicle(ESX.PlayerData.ped, vehicle, 1)
	Citizen.Wait(1000)
	ESX.Game.DeleteVehicle(vehicle)
	TriggerServerEvent('esx_advancedgarage:setVehicleState2', vehicleProps, 1, vehicleProps.plate)
	ESX.ShowNotification(_U('vehicle_in_garage'))
	--exports['mythic_notify']:SendAlert('inform', _U('vehicle_in_garage'), 3000, { ['background-color'] = '#FF0000', ['color'] = '#ffffff' })
end

-- Spawn Vehicles
function SpawnVehicle(vehicle, plate, gps)
	local gameVehicles = ESX.Game.GetVehicles()

	for i = 1, #gameVehicles do

	local vehicle = gameVehicles[i]

        if DoesEntityExist(vehicle) then

			if string.gsub(GetVehicleNumberPlateText(vehicle),'^%s*(.-)%s*$', '%1') == string.gsub(plate,'^%s*(.-)%s*$', '%1') then

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

			--AddVehicleKeys(callback_vehicle)

			--TriggerServerEvent('LegacyFuel:UpdateServerFuelTable', plate, vehicle.fuelLevel)



			if gps ~= nil and gps then

				ToggleBlip(callback_vehicle)

			end

		end)
	
		TriggerServerEvent('esx_advancedgarage:setVehicleState', plate, false)

	else

		ESX.ShowNotification("Egy jármü útban van.")
		--exports['mythic_notify']:SendAlert('inform', 'Útban van egy jármű!', 3000, { ['background-color'] = '#FF0000', ['color'] = '#ffffff' })

	end
end

-- Spawn Pound Vehicles
function SpawnPoundedVehicle(vehicle, plate)

	if ESX.Game.IsSpawnPointClear(vector3(this_Garage.SpawnPoint.x, this_Garage.SpawnPoint.y, this_Garage.SpawnPoint.z), 3.0) then 

		ESX.Game.SpawnVehicle(vehicle.model, {

			x = this_Garage.SpawnPoint.x,

			y = this_Garage.SpawnPoint.y,

			z = this_Garage.SpawnPoint.z + 1

		}, this_Garage.SpawnPoint.h, function(callback_vehicle)

			SetVehicleProperties(callback_vehicle, vehicle)

			SetVehRadioStation(callback_vehicle, "OFF")

			TaskWarpPedIntoVehicle(ESX.PlayerData.ped, callback_vehicle, -1)

			--AddVehicleKeys(callback_vehicle)

			--TriggerServerEvent('LegacyFuel:UpdateServerFuelTable', plate, vehicle.fuelLevel)



			if gps ~= nil and gps > 0 then

				ToggleBlip(callback_vehicle)

			end

			table.insert(carInWorld, {vehicleentity = callback_vehicle, plate = plate})

		end)
	
		--TriggerServerEvent('esx_advancedgarage:setVehicleState', plate, false)
	else

		ESX.ShowNotification("Please move the vehicle that is in the way.")
		--exports['mythic_notify']:SendAlert('inform', 'Útban van egy autó!', 3000, { ['background-color'] = '#FF0000', ['color'] = '#ffffff' })

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
	elseif zone == 'mufflers_pound_point' then
		CurrentAction     = 'mufflers_pound_point'
		CurrentActionMsg  = _U('press_to_impound')
		CurrentActionData = {}
	elseif zone == 'soa_pound_point' then
		CurrentAction     = 'soa_pound_point'
		CurrentActionMsg  = _U('press_to_impound')
		CurrentActionData = {}
	elseif zone == 'ballas_pound_point' then
		CurrentAction     = 'ballas_pound_point'
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
                                end
                                if #(coords - vector3(v.DeletePoint.x, v.DeletePoint.y, v.DeletePoint.z)) < 80 then
					canSleep = false
					DrawMarker(Config.MarkerType, v.DeletePoint.x, v.DeletePoint.y, v.DeletePoint.z, 0.0, 0.0, 0.0, 270.0, 0.0, 0.0, Config.DeleteMarker2.x, Config.DeleteMarker2.y, Config.DeleteMarker2.z, Config.DeleteMarker2.r, Config.DeleteMarker2.g, Config.DeleteMarker2.b, 100, false, true, 2, false, false, false, false)
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

			if ESX.PlayerData.job ~= nil and ESX.PlayerData.job.name == 'ballas' then
				for k,v in pairs(Config.ballasPounds) do
					if #(coords - vector3(v.PoundPoint.x, v.PoundPoint.y, v.PoundPoint.z)) < Config.DrawDistance then
						canSleep = false
						DrawMarker(Config.MarkerType, v.PoundPoint.x, v.PoundPoint.y, v.PoundPoint.z, 0.0, 0.0, 0.0, 270.0, 0.0, 0.0, Config.JobPoundMarker.x, Config.JobPoundMarker.y, Config.JobPoundMarker.z, Config.JobPoundMarker.r, Config.JobPoundMarker.g, Config.JobPoundMarker.b, 100, false, true, 2, false, false, false, false)
					end
				end
			end
			
			if ESX.PlayerData.job ~= nil and ESX.PlayerData.job.name == 'soa' then
				for k,v in pairs(Config.soaPounds) do
					if #(coords - vector3(v.PoundPoint.x, v.PoundPoint.y, v.PoundPoint.z)) < Config.DrawDistance then
						canSleep = false
						DrawMarker(Config.MarkerType, v.PoundPoint.x, v.PoundPoint.y, v.PoundPoint.z, 0.0, 0.0, 0.0, 270.0, 0.0, 0.0, Config.JobPoundMarker.x, Config.JobPoundMarker.y, Config.JobPoundMarker.z, Config.JobPoundMarker.r, Config.JobPoundMarker.g, Config.JobPoundMarker.b, 100, false, true, 2, false, false, false, false)
					end
				end
			end
			
			if ESX.PlayerData.job ~= nil and ESX.PlayerData.job.name == 'mufflers' then
				for k,v in pairs(Config.mufflersPounds) do
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
		

			for k,v in pairs(Config.CarPounds) do

				if #(coords - vector3(v.PoundPoint.x, v.PoundPoint.y, v.PoundPoint.z)) <= Config.MarkerDistance then

					isInMarker  = true

					this_Garage = v

					currentZone = 'car_pound_point'

				end

			end

		end
		
		if Config.UseBoatGarages then
			for k,v in pairs(Config.BoatGarages) do
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
			
			for k,v in pairs(Config.BoatPounds) do
				if #(coords - vector3(v.PoundPoint.x, v.PoundPoint.y, v.PoundPoint.z)) <= Config.MarkerDistance then
					isInMarker  = true
					this_Garage = v
					currentZone = 'boat_pound_point'
				end
			end
		end
		
		if Config.UseAircraftGarages then
			for k,v in pairs(Config.AircraftGarages) do
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
			
			for k,v in pairs(Config.AircraftPounds) do
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
			if ESX.PlayerData.job ~= nil and ESX.PlayerData.job.name == 'police' then
				for k,v in pairs(Config.PolicePounds) do
					if #(coords - vector3(v.PoundPoint.x, v.PoundPoint.y, v.PoundPoint.z)) <= Config.MarkerDistance then
						isInMarker  = true
						this_Garage = v
						currentZone = 'policing_pound_point'
					end
				end
			end

			--[[if ESX.PlayerData.job ~= nil and ESX.PlayerData.job.name == 'taxi' then
				for k,v in pairs(Config.TaxiPounds) do
					if (GetDistanceBetweenCoords(coords, v.PoundPoint.x, v.PoundPoint.y, v.PoundPoint.z, true) <= Config.MarkerDistance) then
						isInMarker  = true
						this_Garage = v
						currentZone = 'taxing_pound_point'
					end
				end
			end]]

			if ESX.PlayerData.job ~= nil and ESX.PlayerData.job.name == 'sheriff' then
				for k,v in pairs(Config.SheriffPounds) do
					if #(coords - vector3(v.PoundPoint.x, v.PoundPoint.y, v.PoundPoint.z)) <= Config.MarkerDistance then
						isInMarker  = true
						this_Garage = v
						currentZone = 'Sheriff_pound_point'
					end
				end
			end
			
			if ESX.PlayerData.job ~= nil and ESX.PlayerData.job.name == 'ambulance' then
				for k,v in pairs(Config.AmbulancePounds) do
					if #(coords - vector3(v.PoundPoint.x, v.PoundPoint.y, v.PoundPoint.z)) <= Config.MarkerDistance then
						isInMarker  = true
						this_Garage = v
						currentZone = 'ambulance_pound_point'
					end
				end
			end
		end
		
		--[[if ESX.PlayerData.job ~= nil and ESX.PlayerData.job.name == 'mufflers' then
			for k,v in pairs(Config.mufflersPounds) do
				if #(coords - vector3(v.PoundPoint.x, v.PoundPoint.y, v.PoundPoint.z)) <= Config.MarkerDistance then
					isInMarker  = true
					this_Garage = v
					currentZone = 'mufflers_pound_point'
				end
			end
		end
		
		if ESX.PlayerData.job ~= nil and ESX.PlayerData.job.name == 'soa' then
			for k,v in pairs(Config.soaPounds) do
				if (GetDistanceBetweenCoords(coords, v.PoundPoint.x, v.PoundPoint.y, v.PoundPoint.z, true) <= Config.MarkerDistance) then
					isInMarker  = true
					this_Garage = v
					currentZone = 'soa_pound_point'
				end
			end
		end
		
		if ESX.PlayerData.job ~= nil and ESX.PlayerData.job.name == 'ballas' then
			for k,v in pairs(Config.ballasPounds) do
				if (GetDistanceBetweenCoords(coords, v.PoundPoint.x, v.PoundPoint.y, v.PoundPoint.z, true) <= Config.MarkerDistance) then
					isInMarker  = true
					this_Garage = v
					currentZone = 'ballas_pound_point'
				end
			end
		end]]

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
			
			if IsControlJustReleased(0, Keys['E']) then
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
			Wait(1500)
		end
	end
end)

-- Create Blips

function PrivateGarageBlips()

	for _,blip in pairs(privateBlips) do

		RemoveBlip(blip)

	end

	

	privateBlips = {}

	

	for zoneKey,zoneValues in pairs(Config.PrivateCarGarages) do

		if zoneValues.Private and has_value(userProperties, zoneValues.Private) then

			local blip = AddBlipForCoord(zoneValues.GaragePoint.x, zoneValues.GaragePoint.y, zoneValues.GaragePoint.z)

			SetBlipSprite(blip, Config.BlipGaragePrivate.Sprite)

			SetBlipDisplay(blip, Config.BlipGaragePrivate.Display)

			SetBlipScale(blip, Config.BlipGaragePrivate.Scale)

			SetBlipColour(blip, Config.BlipGaragePrivate.Color)

			SetBlipAsShortRange(blip, true)

			BeginTextCommandSetBlipName("STRING")

			AddTextComponentString(_U('blip_garage_private'))

			EndTextCommandSetBlipName(blip)

		end

		Citizen.Wait(50)

	end

end



function deleteBlips()

	if JobBlips[1] ~= nil then

		for i=1, #JobBlips, 1 do

			RemoveBlip(JobBlips[i])

			JobBlips[i] = nil

		end

	end

end



function refreshBlips()

	local blipList = {}

	local JobBlips = {}



	if Config.UseCarGarages then		

		for k,v in pairs(Config.CarPounds) do

			table.insert(blipList, {

				coords = { v.PoundPoint.x, v.PoundPoint.y },

				text   = _U('blip_pound'),

				sprite = Config.BlipPound.Sprite,

				color  = Config.BlipPound.Color,

				scale  = Config.BlipPound.Scale

			})

		end

	end

	

	if Config.UseBoatGarages then

		for k,v in pairs(Config.BoatGarages) do

			table.insert(blipList, {

				coords = { v.GaragePoint.x, v.GaragePoint.y },

				text   = _U('garage_boats'),

				sprite = Config.BlipGarage.Sprite,

				color  = Config.BlipGarage.Color,

				scale  = Config.BlipGarage.Scale

			})

		end

		

		for k,v in pairs(Config.BoatPounds) do

			table.insert(blipList, {

				coords = { v.PoundPoint.x, v.PoundPoint.y },

				text   = _U('blip_pound'),

				sprite = Config.BlipPound.Sprite,

				color  = Config.BlipPound.Color,

				scale  = Config.BlipPound.Scale

			})

		end

	end

	

	if Config.UseAircraftGarages then

		for k,v in pairs(Config.AircraftGarages) do

			table.insert(blipList, {

				coords = { v.GaragePoint.x, v.GaragePoint.y },

				text   = _U('garage_aircrafts'),

				sprite = Config.BlipGarage.Sprite,

				color  = Config.BlipGarage.Color,

				scale  = Config.BlipGarage.Scale

			})

		end

		

		for k,v in pairs(Config.AircraftPounds) do

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

		if ESX.PlayerData.job ~= nil and ESX.PlayerData.job.name == 'police' then

			for k,v in pairs(Config.PolicePounds) do

				table.insert(JobBlips, {

					coords = { v.PoundPoint.x, v.PoundPoint.y },

					text   = _U('blip_police_pound'),

					sprite = Config.BlipJobPound.Sprite,

					color  = Config.BlipJobPound.Color,

					scale  = Config.BlipJobPound.Scale

				})

			end

		end

		if ESX.PlayerData.job ~= nil and ESX.PlayerData.job.name == 'sheriff' then

			for k,v in pairs(Config.PolicePounds) do

				table.insert(JobBlips, {

					coords = { v.PoundPoint.x, v.PoundPoint.y },

					text   = _U('blip_sheriff_pound'),

					sprite = Config.BlipJobPound.Sprite,

					color  = Config.BlipJobPound.Color,

					scale  = Config.BlipJobPound.Scale

				})

			end

		end
		

		if ESX.PlayerData.job ~= nil and ESX.PlayerData.job.name == 'ambulance' then

			for k,v in pairs(Config.AmbulancePounds) do

				table.insert(JobBlips, {

					coords = { v.PoundPoint.x, v.PoundPoint.y },

					text   = _U('blip_ambulance_pound'),

					sprite = Config.BlipJobPound.Sprite,

					color  = Config.BlipJobPound.Color,

					scale  = Config.BlipJobPound.Scale

				})

			end

		end

		--[[if ESX.PlayerData.job ~= nil and ESX.PlayerData.job.name == 'mufflers' then

			for k,v in pairs(Config.mufflersPounds) do
		
				table.insert(JobBlips, {
		
					coords = { v.PoundPoint.x, v.PoundPoint.y },
		
					text   = _U('blip_mufflers_pound'),
		
					sprite = Config.BlipJobPound.Sprite,
		
					color  = Config.BlipJobPound.Color,
		
					scale  = Config.BlipJobPound.Scale
		
				})
		
			end
		
		end
		
		if ESX.PlayerData.job ~= nil and ESX.PlayerData.job.name == 'soa' then
		
			for k,v in pairs(Config.soaPounds) do
		
				table.insert(JobBlips, {
		
					coords = { v.PoundPoint.x, v.PoundPoint.y },
		
					text   = _U('blip_soa_pound'),
		
					sprite = Config.BlipJobPound.Sprite,
		
					color  = Config.BlipJobPound.Color,
		
					scale  = Config.BlipJobPound.Scale
		
				})
		
			end
		
		end
		
		if ESX.PlayerData.job ~= nil and ESX.PlayerData.job.name == 'ballas' then
		
			for k,v in pairs(Config.ballasPounds) do
		
				table.insert(JobBlips, {
		
					coords = { v.PoundPoint.x, v.PoundPoint.y },
		
					text   = _U('blip_ballas_pound'),
		
					sprite = Config.BlipJobPound.Sprite,
		
					color  = Config.BlipJobPound.Color,
		
					scale  = Config.BlipJobPound.Scale
		
				})
		
			end
		
		end]]

	end



	for i=1, #blipList, 1 do

		CreateBlip(blipList[i].coords, blipList[i].text, blipList[i].sprite, blipList[i].color, blipList[i].scale)

	end

	

	for i=1, #JobBlips, 1 do

		CreateBlip(JobBlips[i].coords, JobBlips[i].text, JobBlips[i].sprite, JobBlips[i].color, JobBlips[i].scale)

	end

end



function CreateBlip(coords, text, sprite, color, scale)

	local blip = AddBlipForCoord(table.unpack(coords))

	

	SetBlipSprite(blip, sprite)

	SetBlipScale(blip, scale)

	SetBlipColour(blip, color)

	SetBlipAsShortRange(blip, true)

	

	BeginTextCommandSetBlipName('STRING')

	AddTextComponentSubstringPlayerName(text)

	EndTextCommandSetBlipName(blip)

	table.insert(JobBlips, blip)

end
