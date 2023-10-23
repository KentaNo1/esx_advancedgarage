local DrawMarker = DrawMarker
local AddBlipForCoord = AddBlipForCoord
local LastZone = nil
local CurrentAction = nil
local CurrentActionMsg = ''
local userProperties = {}
privateBlips = {}
this_Garage = {}
jobBlips = {}
cachedData = {}

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	if Config.UsePrivateCarGarages then
		ESX.TriggerServerCallback('esx_advancedgarage:getOwnedProperties', function(properties)
			userProperties = properties
			PrivateGarageBlips()
		end)
	end
	drawMarkers()
	activateMenus()
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
	 drawMarkers()
	 activateMenus()
end)

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
		local sleep = 1500
		local ped = ESX.PlayerData.ped
		local pedCoords = GetEntityCoords(ped)
		local markersize = 1.5
		for i = 1, #Config.Garages do
			local garage = Config.Garages[i]
			    local pos = garage.menuposition
				local dst = #(pedCoords - pos)
				local g = garage.garage
				if dst <= 50.0 then
					sleep = 3
                    markersize = 1.5

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

---Draw Markers
function drawMarkers()
	CreateThread(function()
		while true do
			Wait(3)
			local playerPed = ESX.PlayerData.ped
			local coords    = GetEntityCoords(playerPed)
			local canSleep  = true

			if Config.UseCarGarages then
				for _,v in pairs(Config.CarPounds) do
					if #(coords - v.PoundPoint) < Config.DrawDistance then
						canSleep = false
						DrawMarker(Config.MarkerType, v.PoundPoint.x, v.PoundPoint.y, v.PoundPoint.z, 0.0, 0.0, 0.0, 270.0, 0.0, 0.0, Config.PoundMarker.x, Config.PoundMarker.y, Config.PoundMarker.z, Config.PoundMarker.r, Config.PoundMarker.g, Config.PoundMarker.b, 100, false, true, 2, false, false, false, false)
					end
				end
			end

			if Config.UseBoatGarages then
				for _,v in pairs(Config.BoatGarages) do
					if #(coords - v.GaragePoint) < Config.DrawDistance then
						canSleep = false
						DrawMarker(Config.MarkerType, v.GaragePoint.x, v.GaragePoint.y, v.GaragePoint.z, 0.0, 0.0, 0.0, 270.0, 0.0, 0.0, Config.PointMarker.x, Config.PointMarker.y, Config.PointMarker.z, Config.PointMarker.r, Config.PointMarker.g, Config.PointMarker.b, 100, false, true, 2, false, false, false, false)	
						DrawMarker(Config.MarkerType, v.DeletePoint.x, v.DeletePoint.y, v.DeletePoint.z, 0.0, 0.0, 0.0, 270.0, 0.0, 0.0, Config.DeleteMarker.x, Config.DeleteMarker.y, Config.DeleteMarker.z, Config.DeleteMarker.r, Config.DeleteMarker.g, Config.DeleteMarker.b, 100, false, true, 2, false, false, false, false)	
					end
				end

				for _,v in pairs(Config.BoatPounds) do
					if #(coords - v.PoundPoint) < Config.DrawDistance then
						canSleep = false
						DrawMarker(Config.MarkerType, v.PoundPoint.x, v.PoundPoint.y, v.PoundPoint.z, 0.0, 0.0, 0.0, 270.0, 0.0, 0.0, Config.PoundMarker.x, Config.PoundMarker.y, Config.PoundMarker.z, Config.PoundMarker.r, Config.PoundMarker.g, Config.PoundMarker.b, 100, false, true, 2, false, false, false, false)
					end
				end
			end

			if Config.UseAircraftGarages then
				for _,v in pairs(Config.AircraftGarages) do
					if #(coords - v.GaragePoint) < Config.DrawDistance then
						canSleep = false
						DrawMarker(Config.MarkerType, v.GaragePoint.x, v.GaragePoint.y, v.GaragePoint.z, 0.0, 0.0, 0.0, 270.0, 0.0, 0.0, Config.PointMarker.x, Config.PointMarker.y, Config.PointMarker.z, Config.PointMarker.r, Config.PointMarker.g, Config.PointMarker.b, 100, false, true, 2, false, false, false, false)
							if #(coords - v.DeletePoint) < 80 then
								canSleep = false
								DrawMarker(Config.MarkerType, v.DeletePoint.x, v.DeletePoint.y, v.DeletePoint.z, 0.0, 0.0, 0.0, 270.0, 0.0, 0.0, Config.DeleteMarker2.x, Config.DeleteMarker2.y, Config.DeleteMarker2.z, Config.DeleteMarker2.r, Config.DeleteMarker2.g, Config.DeleteMarker2.b, 100, false, true, 2, false, false, false, false)
							end
					end
				end

				for _,v in pairs(Config.AircraftPounds) do
					if #(coords - v.PoundPoint) < Config.DrawDistance then
						canSleep = false
						DrawMarker(Config.MarkerType, v.PoundPoint.x, v.PoundPoint.y, v.PoundPoint.z, 0.0, 0.0, 0.0, 270.0, 0.0, 0.0, Config.PoundMarker.x, Config.PoundMarker.y, Config.PoundMarker.z, Config.PoundMarker.r, Config.PoundMarker.g, Config.PoundMarker.b, 100, false, true, 2, false, false, false, false)
					end
				end
			end

			if Config.UsePrivateCarGarages then
				for _,v in pairs(Config.PrivateCarGarages) do
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
				local job = ESX.PlayerData.job
				local jobname = job.name
				if job and jobname == 'police' then
					for _,v in pairs(Config.PolicePounds) do
						if #(coords - vector3(v.PoundPoint.x, v.PoundPoint.y, v.PoundPoint.z)) < Config.DrawDistance then
							canSleep = false
							DrawMarker(Config.MarkerType, v.PoundPoint.x, v.PoundPoint.y, v.PoundPoint.z, 0.0, 0.0, 0.0, 270.0, 0.0, 0.0, Config.JobPoundMarker.x, Config.JobPoundMarker.y, Config.JobPoundMarker.z, Config.JobPoundMarker.r, Config.JobPoundMarker.g, Config.JobPoundMarker.b, 100, false, true, 2, false, false, false, false)
						end
					end
				end

				if job and jobname == 'taxi' then
					for _,v in pairs(Config.TaxiPounds) do
						if #(coords - vector3(v.PoundPoint.x, v.PoundPoint.y, v.PoundPoint.z)) < Config.DrawDistance then
							canSleep = false
							DrawMarker(Config.MarkerType, v.PoundPoint.x, v.PoundPoint.y, v.PoundPoint.z, 0.0, 0.0, 0.0, 270.0, 0.0, 0.0, Config.JobPoundMarker.x, Config.JobPoundMarker.y, Config.JobPoundMarker.z, Config.JobPoundMarker.r, Config.JobPoundMarker.g, Config.JobPoundMarker.b, 100, false, true, 2, false, false, false, false)
						end
					end
				end

				if job and jobname == 'sheriff' then
					for _,v in pairs(Config.SheriffPounds) do
						if #(coords - vector3(v.PoundPoint.x, v.PoundPoint.y, v.PoundPoint.z)) < Config.DrawDistance then
							canSleep = false
							DrawMarker(Config.MarkerType, v.PoundPoint.x, v.PoundPoint.y, v.PoundPoint.z, 0.0, 0.0, 0.0, 270.0, 0.0, 0.0, Config.JobPoundMarker.x, Config.JobPoundMarker.y, Config.JobPoundMarker.z, Config.JobPoundMarker.r, Config.JobPoundMarker.g, Config.JobPoundMarker.b, 100, false, true, 2, false, false, false, false)
						end
					end
				end

				if job and jobname == 'ambulance' then
					for _,v in pairs(Config.AmbulancePounds) do
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
end

-- Activate Menu when in Markers
function activateMenus()
	CreateThread(function()
		local currentZone = 'garage'
		while true do
			Wait(1)
			local coords = GetEntityCoords(ESX.PlayerData.ped)
			local isInMarker = false
			if Config.UseCarGarages then
				for _,v in pairs(Config.CarPounds) do
					if #(coords - v.PoundPoint) <= Config.MarkerDistance then
						isInMarker  = true
						this_Garage = v
						currentZone = 'car_pound_point'
					end
				end
			end

			if Config.UseBoatGarages then
				for _,v in pairs(Config.BoatGarages) do
					if #(coords - v.GaragePoint) <= Config.MarkerDistance then
						isInMarker  = true
						this_Garage = v
						currentZone = 'boat_garage_point'
					end

					if #(coords - v.DeletePoint) <= Config.MarkerDistance then
						isInMarker  = true
						this_Garage = v
						currentZone = 'boat_store_point'
					end
				end

				for _,v in pairs(Config.BoatPounds) do
					if #(coords - v.PoundPoint) <= Config.MarkerDistance then
						isInMarker  = true
						this_Garage = v
						currentZone = 'boat_pound_point'
					end
				end
			end

			if Config.UseAircraftGarages then
				for _,v in pairs(Config.AircraftGarages) do
					if #(coords - v.GaragePoint) <= Config.MarkerDistance then
						isInMarker  = true
						this_Garage = v
						currentZone = 'aircraft_garage_point'
					end

					if #(coords - v.DeletePoint) <= Config.MarkerDistance2 then
						isInMarker  = true
						this_Garage = v
						currentZone = 'aircraft_store_point'
					end
				end

				for _,v in pairs(Config.AircraftPounds) do
					if #(coords - v.PoundPoint) <= Config.MarkerDistance then
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
				local job = ESX.PlayerData.job
				local jobname = job.name
				if job and jobname == 'police' then
					for _,v in pairs(Config.PolicePounds) do
						if #(coords - vector3(v.PoundPoint.x, v.PoundPoint.y, v.PoundPoint.z)) <= Config.MarkerDistance then
							isInMarker  = true
							this_Garage = v
							currentZone = 'policing_pound_point'
						end
					end
				end

				if job and jobname == 'sheriff' then
					for _,v in pairs(Config.SheriffPounds) do
						if #(coords - vector3(v.PoundPoint.x, v.PoundPoint.y, v.PoundPoint.z)) <= Config.MarkerDistance then
							isInMarker  = true
							this_Garage = v
							currentZone = 'Sheriff_pound_point'
						end
					end
				end

				if job and jobname == 'ambulance' then
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
				Wait(1000)
			end
		end
	end)
end

-- Key Controls
CreateThread(function()
	while true do
		local sleep = 1000
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
	CurrentAction = nil
end)

-- Exited Marker
AddEventHandler('garage:hasExitedMarker', function()
	ESX.UI.Menu.CloseAll()
	CurrentAction = nil
end)
