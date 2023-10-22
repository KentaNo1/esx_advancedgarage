local carBlips = {}

---Create blips
---@param coords table
---@param text string
---@param sprite number
---@param color number
---@param scale number
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
	jobBlips[#jobBlips+1] = blip
end

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
	if jobBlips then
		for i = 1, #jobBlips do
			RemoveBlip(jobBlips[i])
			jobBlips[i] = nil
		end
	end
end

function refreshBlips()
	local blipList = {}
	local jobBlips = {}
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
			blipList[#blipList+1] = {
				coords = { v.GaragePoint.x, v.GaragePoint.y },
				text   = _U('garage_aircrafts'),
				sprite = Config.BlipGarage.Sprite,
				color  = Config.BlipGarage.Color,
				scale  = Config.BlipGarage.Scale
			}
		end

		for _,v in pairs(Config.AircraftPounds) do
			blipList[#blipList+1] = {
				coords = { v.PoundPoint.x, v.PoundPoint.y },
				text   = _U('blip_pound'),
				sprite = Config.BlipPound.Sprite,
				color  = Config.BlipPound.Color,
				scale  = Config.BlipPound.Scale
			}
		end
	end

	if Config.UseJobCarGarages then
		if ESX.PlayerData.job and ESX.PlayerData.job.name == 'police' then
			for _,v in pairs(Config.PolicePounds) do
				jobBlips[#jobBlips+1] = {
					coords = {v.PoundPoint.x, v.PoundPoint.y},
					text   = _U('blip_police_pound'),
					sprite = Config.BlipJobPound.Sprite,
					color  = Config.BlipJobPound.Color,
					scale  = Config.BlipJobPound.Scale
				}
			end
		end

		if ESX.PlayerData.job and ESX.PlayerData.job.name == 'sheriff' then
			for _,v in pairs(Config.SheriffPounds) do
				jobBlips[#jobBlips+1] = {
					coords = {v.PoundPoint.x, v.PoundPoint.y},
					text   = _U('blip_sheriff_pound'),
					sprite = Config.BlipJobPound.Sprite,
					color  = Config.BlipJobPound.Color,
					scale  = Config.BlipJobPound.Scale
				}
			end
		end

		if ESX.PlayerData.job and ESX.PlayerData.job.name == 'ambulance' then
			for _,v in pairs(Config.AmbulancePounds) do
				jobBlips[#jobBlips+1] = {
					coords = {v.PoundPoint.x, v.PoundPoint.y},
					text   = _U('blip_ambulance_pound'),
					sprite = Config.BlipJobPound.Sprite,
					color  = Config.BlipJobPound.Color,
					scale  = Config.BlipJobPound.Scale
				}
			end
		end
	end

	for i = 1, #blipList do
		CreateBlip(blipList[i].coords, blipList[i].text, blipList[i].sprite, blipList[i].color, blipList[i].scale)
	end

	for i = 1, #jobBlips do
		CreateBlip(jobBlips[i].coords, jobBlips[i].text, jobBlips[i].sprite, jobBlips[i].color, jobBlips[i].scale)
	end
end

---@param tab table
---@param val string
---@return boolean
function has_value(tab, val)
	for i = 1, #tab do
		if tab[i] == val then
			return true
		end
	end
	return false
end

---Garage camera
---@param cam vector3
---@param camrot vector3
---@param toggle boolean
function HandleCamera(cam, camrot, toggle)
    local Camerapos = cam
    if not camrot then DestroyCam(cachedData.cam) return end
    if not Camerapos then DestroyCam(cachedData.cam) return end

	if not toggle then
		if cachedData.cam then
			DestroyCam(cachedData.cam)
		end

		if DoesEntityExist(cachedData.vehicle) then
			DeleteEntity(cachedData.vehicle)
		end

		RenderScriptCams(false, true, 750, true, false)
        stopmove = false
		return
	end

	if cachedData.cam then
		DestroyCam(cachedData.cam)
	end

	cachedData.cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)

	SetCamCoord(cachedData.cam, cam.x, cam.y, cam.z)
	SetCamRot(cachedData.cam, camrot.x, camrot.y, camrot.z)
	SetCamActive(cachedData.cam, true)

	RenderScriptCams(true, true, 750, true, true)
end

---Spawn pounded vehicle
---@param vehicleProps table
---@param pos vector4
---@param z vector3
---@param zy vector3
---@return nil
function SpawnPoundedVeh(vehicleProps, pos, z, zy)
    local model = vehicleProps.model
	local spawnpoint = pos

	WaitForModel(model)

	if DoesEntityExist(cachedData.vehicle) then
		DeleteEntity(cachedData.vehicle)
	end

    local gameVehicles = ESX.Game.GetVehicles()

    for i = 1, #gameVehicles do
    local veh = gameVehicles[i]

        if DoesEntityExist(veh) then
            if Config.Trim(GetVehicleNumberPlateText(veh)) == Config.Trim(vehicleProps.plate) then
                ESX.ShowNotification("Ez a jármü az utcán van, ugyanabból a jármüböl kettöt nem lehet kivenni.")
                return HandleCamera(z, zy, false)
            end
        end
    end

    for i = 1, #spawnpoint do
	    if ESX.Game.IsSpawnPointClear(spawnpoint[i], 2.5) then
            return ESX.Game.SpawnVehicle(model, spawnpoint[i], spawnpoint[i].w, function(yourVehicle)
                SetVehicleProperties(yourVehicle, vehicleProps)
                NetworkFadeInEntity(yourVehicle, true, true)
                SetModelAsNoLongerNeeded(model)
                TaskWarpPedIntoVehicle(ESX.PlayerData.ped, yourVehicle, -1)
                --if gps then
                    ToggleBlip(yourVehicle)
                --end
                HandleCamera(z, zy, false)
            end)
	    end
        if i == #spawnpoint then ESX.ShowNotification("Kérjük, mozgassa az útban lévö jármüvet.") end
    end
    ESX.ShowNotification("Kérjük, mozgassa az útban lévö jármüvet.")
    return HandleCamera(z, zy, false)
end

---Spawn vehicle
---@param vehicleProps table
---@param pos vector4
---@param z vector3
---@param zy vector3
---@return nil
SpawnVeh2 = function(vehicleProps, pos, z, zy)
    local model = vehicleProps.model
	local spawnpoint = pos

	WaitForModel(model)

	if DoesEntityExist(cachedData.vehicle) then
		DeleteEntity(cachedData.vehicle)
	end

    local gameVehicles = ESX.Game.GetVehicles()

    for i = 1, #gameVehicles do
    local veh = gameVehicles[i]

        if DoesEntityExist(veh) then
            if Config.Trim(GetVehicleNumberPlateText(veh)) == Config.Trim(vehicleProps.plate) then
                ESX.ShowNotification("Ez a jármü az utcán van, ugyanabból a jármüböl kettöt nem lehet kivenni.")
                return HandleCamera(z, zy, false)
            end
        end
    end

    for i = 1, #spawnpoint do
	    if ESX.Game.IsSpawnPointClear(spawnpoint[i], 2.5) then
            return ESX.Game.SpawnVehicle(model, spawnpoint[i], spawnpoint[i].w, function(yourVehicle)
                SetVehicleProperties(yourVehicle, vehicleProps)
                NetworkFadeInEntity(yourVehicle, true, true)
                SetModelAsNoLongerNeeded(model)
                TaskWarpPedIntoVehicle(ESX.PlayerData.ped, yourVehicle, -1)
                --if gps then
                    ToggleBlip(yourVehicle)
                --end
                HandleCamera(z, zy, false)
				TriggerServerEvent("esx_advancedgarage:takecar", vehicleProps.plate, 0)
            end)
	    end
        if i == #spawnpoint then ESX.ShowNotification("Kérjük, mozgassa az útban lévö jármüvet.") end
    end
    ESX.ShowNotification("Kérjük, mozgassa az útban lévö jármüvet.")
    return HandleCamera(z, zy, false)
end

---Spawn vehicles
---@param vehicleProps table
---@param pos vector4
---@param z vector3
---@param zy vector3
---@return nil
function SpawnVeh(vehicleProps, pos, z, zy)
    local model = vehicleProps.vehicle.model
	local spawnpoint = pos

	WaitForModel(model)

	if DoesEntityExist(cachedData.vehicle) then
		DeleteEntity(cachedData.vehicle)
	end

    local gameVehicles = ESX.Game.GetVehicles()

    for i = 1, #gameVehicles do
    local vehicle = gameVehicles[i]

        if DoesEntityExist(vehicle) then
            if Config.Trim(GetVehicleNumberPlateText(vehicle)) == Config.Trim(vehicleProps.vehicle.plate) then
                ESX.ShowNotification("Ez a jármü az utcán van, ugyanabból a jármüböl kettöt nem lehet kivenni.")
                return HandleCamera(z, zy, false)
            end
        end
    end

    for i = 1, #spawnpoint do
	    if ESX.Game.IsSpawnPointClear(spawnpoint[i], 2.5) then
            return ESX.Game.SpawnVehicle(model, spawnpoint[i], spawnpoint[i].w, function(yourVehicle)
                SetVehicleProperties(yourVehicle, vehicleProps.vehicle)
                NetworkFadeInEntity(yourVehicle, true, true)
                SetModelAsNoLongerNeeded(model)
                TaskWarpPedIntoVehicle(ESX.PlayerData.ped, yourVehicle, -1)
                --if gps then
                    ToggleBlip(yourVehicle)
                --end
                HandleCamera(z, zy, false)
                TriggerServerEvent("esx_advancedgarage:takecar", vehicleProps.vehicle.plate, 0)
            end)
	    end
        if i == #spawnpoint then ESX.ShowNotification("Kérjük, mozgassa az útban lévö jármüvet.") end
    end
    ESX.ShowNotification("Kérjük, mozgassa az útban lévö jármüvet.")
    return HandleCamera(z, zy, false)
end

---Spawn Pound Vehicles
---@param vehicle table
---@param plate string
function SpawnPoundedVehicle(vehicle, plate)
	local gameVehicles = ESX.Game.GetVehicles()

	for i = 1, #gameVehicles do
	local veh = gameVehicles[i]
        if DoesEntityExist(veh) then
			if Config.Trim(GetVehicleNumberPlateText(veh)) == Config.Trim(plate) then
				ESX.ShowNotification("Ez az autó már kint van az utcán.")
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

			if gps ~= nil and gps > 0 then

				ToggleBlip(callback_vehicle)

			end
		end)
	else
		ESX.ShowNotification("Please move the vehicle that is in the way.")
	end
end

---Spawn local vehicle
---@param vehicleProps table
---@param pos vector4
function SpawnLocalVehicle(vehicleProps, pos)
    local model = vehicleProps.vehicle.model
    local veh = vehicleProps.vehicle
    local _pos = pos
    if not IsModelValid(model) then
		return
	end
	WaitForModel(model)

	if DoesEntityExist(cachedData.vehicle) then
		DeleteEntity(cachedData.vehicle)
	end
	while DoesEntityExist(cachedData.vehicle) do
        Wait(100)
	    DeleteEntity(cachedData.vehicle)
	end
    for i = 1, #_pos do
	    if ESX.Game.IsSpawnPointClear(_pos[i], 2.5) then
            return ESX.Game.SpawnLocalVehicle(model, _pos[i], _pos[i].w, function(yourVehicle)
                cachedData.vehicle = yourVehicle

                SetVehicleProperties(yourVehicle, veh)

                SetModelAsNoLongerNeeded(model)
            end)
        end
        if i == #_pos then ESX.ShowNotification("Kérjük, mozgassa az útban lévö jármüvet.") end
    end
end

---Spawn local vehicle
---@param vehicleProps table
---@param pos vector4
function SpawnPoundedLocalVehicle(vehicleProps, pos)
    local model = vehicleProps.model
    local veh = vehicleProps
    local _pos = pos
    if not IsModelValid(model) then
		return
	end
	WaitForModel(model)

	if DoesEntityExist(cachedData.vehicle) then
		DeleteEntity(cachedData.vehicle)
	end
	while DoesEntityExist(cachedData.vehicle) do
        Wait(100)
	    DeleteEntity(cachedData.vehicle)
	end
    for i = 1, #_pos do
	    if ESX.Game.IsSpawnPointClear(_pos[i], 2.5) then
            return ESX.Game.SpawnLocalVehicle(model, _pos[i], _pos[i].w, function(yourVehicle)
                cachedData.vehicle = yourVehicle

                SetVehicleProperties(yourVehicle, veh)

                SetModelAsNoLongerNeeded(model)
            end)
        end
        if i == #_pos then ESX.ShowNotification("Kérjük, mozgassa az útban lévö jármüvet.") end
    end
end

---Store Vehicles
---@param vehicle string|number
---@param vehicleProps table
function StoreVehicle(vehicle, vehicleProps)
	TaskLeaveVehicle(ESX.PlayerData.ped, vehicle, 1)
	Wait(1000)
	ESX.Game.DeleteVehicle(vehicle)
	TriggerServerEvent('esx_advancedgarage:setVehicleState', vehicleProps.plate, 1)
	ESX.ShowNotification(_U('vehicle_in_garage'))
end

---Store Vehicles
---@param vehicle number|string
---@param vehicleProps table
function StoreVehicle2(vehicle, vehicleProps)
	TaskLeaveVehicle(ESX.PlayerData.ped, vehicle, 1)
	Wait(1000)
	ESX.Game.DeleteVehicle(vehicle)
	TriggerServerEvent('esx_advancedgarage:setVehicleState2', vehicleProps, 1, vehicleProps.plate)
	ESX.ShowNotification(_U('vehicle_in_garage'))
end

---Put vehicle in garage
function PutInVehicle()
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

				ESX.Game.DeleteVehicle(vehicle)
			else
				ESX.ShowNotification("Ez nem a te jármüved!")
			end

		end, vehicleProps, cachedData.currentGarage)
	end
end

---Setting vehicle properties
---@param vehicle number|string
---@param vehicleProps table
function SetVehicleProperties(vehicle, vehicleProps)
    ESX.Game.SetVehicleProperties(vehicle, vehicleProps)
end

---Getting vehicle properties
---@param vehicle number|string
---@return table
function GetVehicleProperties(vehicle)
    if DoesEntityExist(vehicle) then
        local vehicleProps = ESX.Game.GetVehicleProperties(vehicle)
        if vehicleProps.fuelLevel == nil then
           print("Fuel: nil")
        else
           print("Fuel:" ..vehicleProps.fuelLevel)
        end
        return vehicleProps
    end
end

---Repair Vehicles
---@param apprasial number
---@param vehicle number
---@param vehicleProps table
function RepairVehicle(apprasial, vehicle)
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
			SetVehicleBodyHealth(vehicle, 1000.0)
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

---Wait for vehicle model
---@param model number
---@return string?
function WaitForModel(model)
    local DrawScreenText = function(text, red, green, blue, alpha)
        SetTextFont(4)
        SetTextScale(0.0, 0.5)
        SetTextColour(red, green, blue, alpha)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(1, 0, 0, 0, 255)
        SetTextDropShadow()
        SetTextOutline()
        SetTextCentre(true)
        BeginTextCommandDisplayText("STRING")
        AddTextComponentSubstringPlayerName(text)
        EndTextCommandDisplayText(0.5, 0.5)
    end

    if not IsModelValid(model) then
        return ESX.ShowNotification("This model does not exist ingame.")
    end

	if not HasModelLoaded(model) then
		RequestModel(model)
	end

	while not HasModelLoaded(model) do
		Wait(0)
		DrawScreenText("Loading model " .. GetDisplayNameFromVehicleModel(model) .. "...", 255, 255, 255, 150)
	end
end

---Vehicle blip
---@param entity table
 function ToggleBlip(entity)
    if DoesBlipExist(carBlips[entity]) then
        RemoveBlip(carBlips[entity])
    else
        if DoesEntityExist(entity) then
            carBlips[entity] = AddBlipForEntity(entity)

            SetBlipSprite(carBlips[entity], GetVehicleClass(entity) == 8 and 226 or 523)

            SetBlipScale(carBlips[entity], 1.05)

            SetBlipColour(carBlips[entity], 30)

            BeginTextCommandSetBlipName("STRING")

            AddTextComponentString("Személygépjármü - " .. GetVehicleNumberPlateText(entity))
            print("Személygépjármü - " .. GetVehicleNumberPlateText(entity))

            EndTextCommandSetBlipName(carBlips[entity])
        end
    end
end
