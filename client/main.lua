local DrawMarker = DrawMarker
local AddBlipForCoord = AddBlipForCoord
local CurrentAction = nil
local CurrentActionMsg = ''
This_Garage = {}
CachedData = {}

---Put vehicle in garage
local function putInVehicle()
    local ped = ESX.PlayerData.ped
    local vehicle = GetVehiclePedIsUsing(ped)

	if DoesEntityExist(vehicle) then
		local vehicleProps = GetVehicleProperties(vehicle)

		ESX.TriggerServerCallback("esx_advancedgarage:validateVehicle", function(valid)
			if valid then
				TaskLeaveVehicle(ped, vehicle, 0)
				while IsPedInVehicle(ped, vehicle, true) do
					Wait(0)
				end
				Wait(500)
				NetworkFadeOutEntity(vehicle, true, true)
				Wait(100)
				    local t, trailer = GetVehicleTrailerVehicle(vehicle)
				    if t then
						local props = GetVehicleProperties(trailer)
						ESX.TriggerServerCallback("esx_advancedgarage:validateVehicle", function(v)
							if v then
								if Config.Debug then
                                    print("Trailer deleted", props?.plate)
								end
								ESX.Game.DeleteVehicle(trailer)
							end
						end, props, CachedData.currentGarage)
				    end
				ESX.Game.DeleteVehicle(vehicle)
			else
				ESX.ShowNotification("Ez nem a te jármüved!")
			end
		end, vehicleProps, CachedData.currentGarage)
	end
end


CreateThread(function()
	Wait(3333)
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
		AddTextComponentString(Config.GarageName .. ": " .. Config.Garages[i].garage)
		end
		EndTextCommandSetBlipName(garageBlip)
	end
	while true do
		local sleep = 1000
		local ped = ESX.PlayerData.ped
		local pedCoords = GetEntityCoords(ped)
		local markersize = 1.5
		for i = 1, #Config.Garages do
			local garage = Config.Garages[i]
			    local pos = garage.menuposition
				local dst = #(pedCoords - pos)
				local g = garage.garage
				if dst <= 50.0 then
					sleep = 1
                    markersize = 1.5

					if dst <= markersize then
						ESX.ShowHelpNotification(string.format(Config.Labels.menu, g))
						if IsControlJustPressed(0, 38) then
							CachedData.currentGarage = g
							OpenGarageMenu(garage.spawnposition, garage.camera, garage.camrotation)
						end
					end
                    DrawMarker(6, pos.x, pos.y, pos.z - 0.985, 0.0, 0.0, 0.0, -90.0, -90.0, -90.0, markersize, markersize, markersize, 51, 255, 0, 100, false, true, 2, false, false, false, false)
				end
		end
		if IsPedInAnyVehicle(ped, false) then
		    for i = 1, #Config.Garages do
			local garage = Config.Garages[i]
			local gpos = garage.vehicleposition
				local dst = #(pedCoords - gpos)
				if dst <= 50.0 then
					sleep = 3
                    markersize = 5

					if dst <= markersize then
						ESX.ShowHelpNotification(Config.Labels.vehicle)
						if IsControlJustPressed(0, 38) then
							CachedData.currentGarage = garage.garage
							putInVehicle()
						end
					end
                    DrawMarker(6, gpos.x, gpos.y, gpos.z - 0.985, 0.0, 0.0, 0.0, -90.0, -90.0, -90.0, markersize, markersize, markersize, 51, 255, 0, 100, false, true, 2, false, false, false, false)
				end
		    end
	    end
		Wait(sleep)
	end
end)

-- Key Controls
CreateThread(function()
	while true do
		local sleep = 500
		if CurrentAction then
            sleep = 1
			ESX.ShowHelpNotification(CurrentActionMsg)

			if IsControlJustReleased(0, 38) then
				if CurrentAction == 'car_garage_point' then
					OpenMenuGarage('car_garage_point')
				elseif CurrentAction == 'car_store_point' then
					OpenMenuGarage('car_store_point')
				elseif CurrentAction == 'boat_garage_point' then
					OpenMenuGarage('boat_garage_point')
				elseif CurrentAction == 'aircraft_garage_point' then
					OpenMenuGarage('aircraft_garage_point')
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
				end
				CurrentAction = nil
				Stopmove = false
			end
		end
		Wait(sleep)
	end
end)

-- Entered Marker
AddEventHandler('esx_advancedgarage:hasEnteredMarker', function(zone)
	if zone == 'car_garage_point' then
		CurrentAction     = 'car_garage_point'
		CurrentActionMsg  = _U('press_to_enter')
	elseif zone == 'car_store_point' then
		CurrentAction     = 'car_store_point'
		CurrentActionMsg  = _U('press_to_enter')
	elseif zone == 'boat_garage_point' then
		CurrentAction     = 'boat_garage_point'
		CurrentActionMsg  = _U('press_to_enter')
	elseif zone == 'aircraft_garage_point' then
		CurrentAction     = 'aircraft_garage_point'
		CurrentActionMsg  = _U('press_to_enter')
	elseif zone == 'boat_store_point' then
		CurrentAction     = 'boat_store_point'
		CurrentActionMsg  = _U('press_to_delete')
	elseif zone == 'aircraft_store_point' then
		CurrentAction     = 'aircraft_store_point'
		CurrentActionMsg  = _U('press_to_delete')
	elseif zone == 'car_pound_point' then
		CurrentAction     = 'car_pound_point'
		CurrentActionMsg  = _U('press_to_impound')
	elseif zone == 'boat_pound_point' then
		CurrentAction     = 'boat_pound_point'
		CurrentActionMsg  = _U('press_to_impound')
	elseif zone == 'aircraft_pound_point' then
		CurrentAction     = 'aircraft_pound_point'
		CurrentActionMsg  = _U('press_to_impound')
	elseif zone == 'policing_pound_point' then
		CurrentAction     = 'policing_pound_point'
		CurrentActionMsg  = _U('press_to_impound')
	elseif zone == 'taxing_pound_point' then
		CurrentAction     = 'taxing_pound_point'
		CurrentActionMsg  = _U('press_to_impound')
	elseif zone == 'Sheriff_pound_point' then
		CurrentAction     = 'Sheriff_pound_point'
		CurrentActionMsg  = _U('press_to_impound')
	elseif zone == 'ambulance_pound_point' then
		CurrentAction     = 'ambulance_pound_point'
		CurrentActionMsg  = _U('press_to_impound')
	end
end)

-- Exited Marker
AddEventHandler('esx_advancedgarage:hasExitedMarker', function()
	ESX.UI.Menu.CloseAll()
        if DoesEntityExist(CachedData.vehicle) then
            DeleteEntity(CachedData.vehicle)
        end
        Stopmove = false
	CurrentAction = nil
end)
