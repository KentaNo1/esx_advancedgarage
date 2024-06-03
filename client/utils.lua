local carBlips = {}
local privateBlips = {}
local userProperties = {}
local jobBlips = {}
local LastZone = nil

---@param tab table
---@param val string
---@return boolean
local function has_value(tab, val)
	for i = 1, #tab do
		if tab[i] == val then
			return true
		end
	end
	return false
end

---Wait for vehicle model
---@param model number
---@return string?
local function waitForModel(model)
    local DrawScreenText = function(text, red, green, blue, alpha)
        SetTextFont(4)
        SetTextScale(0.0, 0.5)
        SetTextColour(red, green, blue, alpha)
        SetTextDropshadow(0, 0, 0, 0, 255)
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

---Create blips
---@param coords table
---@param text string
---@param sprite number
---@param color number
---@param scale number
local function createBlip(coords, text, sprite, color, scale)
    local x, y = table.unpack(coords)
	local blip = AddBlipForCoord(x, y, 30.0)
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
		if v.Private and has_value(userProperties or {}, v.Private) then
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

local function deleteBlips()
	if jobBlips then
		for i = 1, #jobBlips do
			RemoveBlip(jobBlips[i])
			jobBlips[i] = nil
		end
	end
end

local function refreshBlips()
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
		local job = ESX.PlayerData.job.name
		if job and job == 'police' then
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

		if job and job == 'sheriff' then
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

		if job and job == 'ambulance' then
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
		createBlip(blipList[i].coords, blipList[i].text, blipList[i].sprite, blipList[i].color, blipList[i].scale)
	end

	for i = 1, #jobBlips do
		createBlip(jobBlips[i].coords, jobBlips[i].text, jobBlips[i].sprite, jobBlips[i].color, jobBlips[i].scale)
	end
end

---Setting vehicle properties
---@param vehicle number
---@param vehicleProps table
local function SetVehicleProperties(vehicle, vehicleProps)
    ESX.Game.SetVehicleProperties(vehicle, vehicleProps)
end

---Garage camera
---@param cam vector3
---@param camrot vector3
---@param toggle boolean
function HandleCamera(cam, camrot, toggle)
    if not camrot then DestroyCam(CachedData.cam, false) return end
    if not cam then DestroyCam(CachedData.cam, false) return end

	if not toggle then
		if CachedData.cam then
			DestroyCam(CachedData.cam, false)
		end

		if DoesEntityExist(CachedData.vehicle) then
			DeleteEntity(CachedData.vehicle)
		end

		RenderScriptCams(false, true, 750, true, false)
		return
	end

	if CachedData.cam then
		DestroyCam(CachedData.cam, false)
	end

	CachedData.cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)

	SetCamCoord(CachedData.cam, cam.x, cam.y, cam.z)
	SetCamRot(CachedData.cam, camrot.x, camrot.y, camrot.z, 2)
	SetCamActive(CachedData.cam, true)

	RenderScriptCams(true, true, 750, true, true)
end

---Spawn vehicles
---@param vehicleProps table
---@param pos vector4
---@param z vector3
---@param zy vector3
---@return nil
function SpawnVeh(vehicleProps, pos, z, zy)
	Stopmove = false
    local model = vehicleProps.vehicle?.model or vehicleProps.model
	local veh = vehicleProps?.vehicle or vehicleProps
	local spawnpoint = pos

	waitForModel(model)

	if DoesEntityExist(CachedData.vehicle) then
		DeleteEntity(CachedData.vehicle)
	end

    local gameVehicles = ESX.Game.GetVehicles()

    for i = 1, #gameVehicles do
    local vehicle = gameVehicles[i]

        if DoesEntityExist(vehicle) then
            if Config.Trim(GetVehicleNumberPlateText(vehicle)) == Config.Trim(veh.plate) then
                ESX.ShowNotification("Ez a jármü az utcán van, ugyanabból a jármüböl kettöt nem lehet kivenni.")
                return HandleCamera(z, zy, false)
            end
        end
    end

    for i = 1, #spawnpoint do
		local coords = spawnpoint[i]
	    if ESX.Game.IsSpawnPointClear(coords, 3.0) then
            return ESX.Game.SpawnVehicle(model, coords, coords.w, function(yourVehicle)
                SetVehicleProperties(yourVehicle, veh)
                NetworkFadeInEntity(yourVehicle, true)
                SetModelAsNoLongerNeeded(model)
                TaskWarpPedIntoVehicle(ESX.PlayerData.ped, yourVehicle, -1)
                --if gps then
                    ToggleBlip(yourVehicle)
                --end
                HandleCamera(z, zy, false)
                TriggerServerEvent("esx_advancedgarage:takecar", veh.plate, 0)
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
	if DoesEntityExist(CachedData.vehicle) then
		DeleteEntity(CachedData.vehicle)
	end
	local gameVehicles = ESX.Game.GetVehicles()

	for i = 1, #gameVehicles do
	local veh = gameVehicles[i]
        if DoesEntityExist(veh) then
			if Config.Trim(GetVehicleNumberPlateText(veh)) == Config.Trim(plate) then
				ESX.ShowNotification("Ez az autó már kint van az utcán.")
				HandleCamera(_, _, false)
				return
			end
		end
	end

	if type(This_Garage.SpawnPoint) == 'table' then
		for i=1, #This_Garage.SpawnPoint do
			local coords = This_Garage.SpawnPoint[i]
			if ESX.Game.IsSpawnPointClear(vec3(coords.x, coords.y, coords.z), 3.0) then

				return ESX.Game.SpawnVehicle(vehicle.model, vec3(coords.x, coords.y, coords.z + 1),

                    coords.w, function(callback_vehicle)

					SetVehicleProperties(callback_vehicle, vehicle)

					TaskWarpPedIntoVehicle(ESX.PlayerData.ped, callback_vehicle, -1)

					--if gps and gps > 0 then
						ToggleBlip(callback_vehicle)
					--end
					HandleCamera(_, _, false)
				end)
			else
				ESX.ShowNotification("Please move the vehicle that is in the way.")
				HandleCamera(_, _, false)
			end
		end
	else
		if ESX.Game.IsSpawnPointClear(vec3(This_Garage.SpawnPoint.x, This_Garage.SpawnPoint.y, This_Garage.SpawnPoint.z), 3.0) then

			ESX.Game.SpawnVehicle(vehicle.model, vec3(This_Garage.SpawnPoint.x, This_Garage.SpawnPoint.y, This_Garage.SpawnPoint.z + 1),

                This_Garage.SpawnPoint.w, function(callback_vehicle)

				SetVehicleProperties(callback_vehicle, vehicle)

				TaskWarpPedIntoVehicle(ESX.PlayerData.ped, callback_vehicle, -1)

				--if gps and gps > 0 then
					ToggleBlip(callback_vehicle)
				--end
			end)
			HandleCamera(_, _, false)
		else
			ESX.ShowNotification("Please move the vehicle that is in the way.")
			HandleCamera(_, _, false)
		end
	end
end

---Spawn local vehicle
---@param vehicleProps table
---@param pos vector4
function SpawnLocalVehicle(vehicleProps, pos)
	if not pos then return end
    local model = vehicleProps.vehicle?.model or vehicleProps.model
    local veh = vehicleProps?.vehicle or vehicleProps
    local _pos = pos
    if not IsModelValid(model) then
		return
	end
	waitForModel(model)

	if DoesEntityExist(CachedData.vehicle) then
		DeleteEntity(CachedData.vehicle)
	end
	while DoesEntityExist(CachedData.vehicle) do
        Wait(100)
	    DeleteEntity(CachedData.vehicle)
	end
	if type(_pos) == "table" then
		for i = 1, #_pos do
			local coords = _pos[i]
			if ESX.Game.IsSpawnPointClear(coords, 3.0) then
				return ESX.Game.SpawnLocalVehicle(model, coords, coords.w, function(yourVehicle)
					CachedData.vehicle = yourVehicle
					SetVehicleProperties(yourVehicle, veh)
					SetVehicleOnGroundProperly(yourVehicle)
					SetEntityCollision(yourVehicle, false, false)
					--SetEntityAlpha(yourVehicle, 51)
					FreezeEntityPosition(yourVehicle, true)
					SetModelAsNoLongerNeeded(model)
				end)
			end
			if i == #_pos then ESX.ShowNotification("Kérjük, mozgassa az útban lévö jármüvet.") end
		end
	else
		if ESX.Game.IsSpawnPointClear(_pos, 3.0) then
            return ESX.Game.SpawnLocalVehicle(model, _pos, _pos.w, function(yourVehicle)
                CachedData.vehicle = yourVehicle

                SetVehicleProperties(yourVehicle, veh)
                SetVehicleOnGroundProperly(yourVehicle)
                SetEntityCollision(yourVehicle, false, false)
                --SetEntityAlpha(yourVehicle, 51)
                FreezeEntityPosition(yourVehicle, true)
                SetModelAsNoLongerNeeded(model)
            end)
        end
    end
end

---Store Vehicles
---@param vehicle number
---@param vehicleProps table
function StoreVehicle(vehicle, vehicleProps)
	TaskLeaveVehicle(ESX.PlayerData.ped, vehicle, 1)
	Wait(1000)
	ESX.Game.DeleteVehicle(vehicle)
	if not vehicleProps then return ESX.ShowNotification('Nem sikerült elmenteni a jármüvet') end
	TriggerServerEvent('esx_advancedgarage:setVehicleState2', vehicleProps, 1, vehicleProps.plate)
	ESX.ShowNotification(_U('vehicle_in_garage'))
end

---Getting vehicle properties
---@param vehicle number
---@return table|nil
function GetVehicleProperties(vehicle)
    if DoesEntityExist(vehicle) then
        local vehicleProps = ESX.Game.GetVehicleProperties(vehicle)
		if not vehicleProps then return end
        if not vehicleProps.fuelLevel then
           print("Fuel: nincs érték")
        else
           print("Fuel:" ..vehicleProps.fuelLevel)
        end
        return vehicleProps
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

-- Activate Menu when in Markers
local function activateMenus()
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
						This_Garage = v
						currentZone = 'car_pound_point'
					end
				end
			end

			if Config.UseBoatGarages then
				for _,v in pairs(Config.BoatGarages) do
					if #(coords - v.GaragePoint) <= Config.MarkerDistance then
						isInMarker  = true
						This_Garage = v
						currentZone = 'boat_garage_point'
					end

					if #(coords - v.DeletePoint) <= Config.MarkerDistance then
						isInMarker  = true
						This_Garage = v
						currentZone = 'boat_store_point'
					end
				end

				for _,v in pairs(Config.BoatPounds) do
					if #(coords - v.PoundPoint) <= Config.MarkerDistance then
						isInMarker  = true
						This_Garage = v
						currentZone = 'boat_pound_point'
					end
				end
			end

			if Config.UseAircraftGarages then
				for _,v in pairs(Config.AircraftGarages) do
					if #(coords - v.GaragePoint) <= Config.MarkerDistance then
						isInMarker  = true
						This_Garage = v
						currentZone = 'aircraft_garage_point'
					end

					if #(coords - v.DeletePoint) <= Config.MarkerDistance2 then
						isInMarker  = true
						This_Garage = v
						currentZone = 'aircraft_store_point'
					end
				end

				for _,v in pairs(Config.AircraftPounds) do
					if #(coords - v.PoundPoint) <= Config.MarkerDistance then
						isInMarker  = true
						This_Garage = v
						currentZone = 'aircraft_pound_point'
					end
				end
			end

			if Config.UsePrivateCarGarages then
				for _,v in pairs(Config.PrivateCarGarages) do
					if not v.Private or has_value(userProperties, v.Private) then
						if #(coords - vec3(v.GaragePoint.x, v.GaragePoint.y, v.GaragePoint.z)) <= Config.MarkerDistance then
							isInMarker  = true
							This_Garage = v
							currentZone = 'car_garage_point'
						end

						if #(coords - vec3(v.DeletePoint.x, v.DeletePoint.y, v.DeletePoint.z)) <= Config.MarkerDistance then
							isInMarker  = true
							This_Garage = v
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
						if #(coords - vec3(v.PoundPoint.x, v.PoundPoint.y, v.PoundPoint.z)) <= Config.MarkerDistance then
							isInMarker  = true
							This_Garage = v
							currentZone = 'policing_pound_point'
						end
					end
				end

				if job and jobname == 'sheriff' then
					for _,v in pairs(Config.SheriffPounds) do
						if #(coords - vec3(v.PoundPoint.x, v.PoundPoint.y, v.PoundPoint.z)) <= Config.MarkerDistance then
							isInMarker  = true
							This_Garage = v
							currentZone = 'Sheriff_pound_point'
						end
					end
				end

				if job and jobname == 'ambulance' then
					for _,v in pairs(Config.AmbulancePounds) do
						if #(coords - vec3(v.PoundPoint.x, v.PoundPoint.y, v.PoundPoint.z)) <= Config.MarkerDistance then
							isInMarker  = true
							This_Garage = v
							currentZone = 'ambulance_pound_point'
						end
					end
				end
			end

			if isInMarker and not HasAlreadyEnteredMarker then
				HasAlreadyEnteredMarker = true
				LastZone = currentZone
				TriggerEvent('esx_advancedgarage:hasEnteredMarker', currentZone)
			end

			if not isInMarker and HasAlreadyEnteredMarker then
				HasAlreadyEnteredMarker = false
				TriggerEvent('esx_advancedgarage:hasExitedMarker', LastZone)
			end

			if not isInMarker then
				Wait(500)
			end
		end
	end)
end

---Markers
local function drawMarkers()
	CreateThread(function()
		while true do
			Wait(0)
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
					end
					if #(coords - v.DeletePoint) < 80 then
						canSleep = false
						DrawMarker(Config.MarkerType, v.DeletePoint.x, v.DeletePoint.y, v.DeletePoint.z, 0.0, 0.0, 0.0, 270.0, 0.0, 0.0, Config.DeleteMarker2.x, Config.DeleteMarker2.y, Config.DeleteMarker2.z, Config.DeleteMarker2.r, Config.DeleteMarker2.g, Config.DeleteMarker2.b, 100, false, true, 2, false, false, false, false)
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
						if #(coords - vec3(v.GaragePoint.x, v.GaragePoint.y, v.GaragePoint.z)) < Config.DrawDistance then
							canSleep = false
							DrawMarker(Config.MarkerType, v.GaragePoint.x, v.GaragePoint.y, v.GaragePoint.z, 0.0, 0.0, 0.0, 270.0, 0.0, 0.0, Config.PointMarker.x, Config.PointMarker.y, Config.PointMarker.z, Config.PointMarker.r, Config.PointMarker.g, Config.PointMarker.b, 100, false, true, 2, false, false, false, false)	
							DrawMarker(Config.MarkerType, v.DeletePoint.x, v.DeletePoint.y, v.DeletePoint.z, 0.0, 0.0, 0.0, 270.0, 0.0, 0.0, Config.DeleteMarker.x, Config.DeleteMarker.y, Config.DeleteMarker.z, Config.DeleteMarker.r, Config.DeleteMarker.g, Config.DeleteMarker.b, 100, false, true, 2, false, false, false, false)	
						end
					end
				end
			end

			if Config.UseJobCarGarages then
				local job = ESX.GetPlayerData().job
				local jobname = job.name
				if job and jobname == 'police' then
					for _,v in pairs(Config.PolicePounds) do
						if #(coords - vec3(v.PoundPoint.x, v.PoundPoint.y, v.PoundPoint.z)) < Config.DrawDistance then
							canSleep = false
							DrawMarker(Config.MarkerType, v.PoundPoint.x, v.PoundPoint.y, v.PoundPoint.z, 0.0, 0.0, 0.0, 270.0, 0.0, 0.0, Config.JobPoundMarker.x, Config.JobPoundMarker.y, Config.JobPoundMarker.z, Config.JobPoundMarker.r, Config.JobPoundMarker.g, Config.JobPoundMarker.b, 100, false, true, 2, false, false, false, false)
						end
					end
				end

				if job and jobname == 'taxi' then
					for _,v in pairs(Config.TaxiPounds) do
						if #(coords - vec3(v.PoundPoint.x, v.PoundPoint.y, v.PoundPoint.z)) < Config.DrawDistance then
							canSleep = false
							DrawMarker(Config.MarkerType, v.PoundPoint.x, v.PoundPoint.y, v.PoundPoint.z, 0.0, 0.0, 0.0, 270.0, 0.0, 0.0, Config.JobPoundMarker.x, Config.JobPoundMarker.y, Config.JobPoundMarker.z, Config.JobPoundMarker.r, Config.JobPoundMarker.g, Config.JobPoundMarker.b, 100, false, true, 2, false, false, false, false)
						end
					end
				end

				if job and jobname == 'sheriff' then
					for _,v in pairs(Config.SheriffPounds) do
						if #(coords - vec3(v.PoundPoint.x, v.PoundPoint.y, v.PoundPoint.z)) < Config.DrawDistance then
							canSleep = false
							DrawMarker(Config.MarkerType, v.PoundPoint.x, v.PoundPoint.y, v.PoundPoint.z, 0.0, 0.0, 0.0, 270.0, 0.0, 0.0, Config.JobPoundMarker.x, Config.JobPoundMarker.y, Config.JobPoundMarker.z, Config.JobPoundMarker.r, Config.JobPoundMarker.g, Config.JobPoundMarker.b, 100, false, true, 2, false, false, false, false)
						end
					end
				end

				if job and jobname == 'ambulance' then
					for _,v in pairs(Config.AmbulancePounds) do
						if #(coords - vec3(v.PoundPoint.x, v.PoundPoint.y, v.PoundPoint.z)) < Config.DrawDistance then
							canSleep = false
							DrawMarker(Config.MarkerType, v.PoundPoint.x, v.PoundPoint.y, v.PoundPoint.z, 0.0, 0.0, 0.0, 270.0, 0.0, 0.0, Config.JobPoundMarker.x, Config.JobPoundMarker.y, Config.JobPoundMarker.z, Config.JobPoundMarker.r, Config.JobPoundMarker.g, Config.JobPoundMarker.b, 100, false, true, 2, false, false, false, false)
						end
					end
				end
			end

			if canSleep then
				Wait(500)
			end
		end
	end)
end

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