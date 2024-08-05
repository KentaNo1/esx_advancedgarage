---@diagnostic disable undefined-global
local carBlips = {}
local privateBlips = {}
local userProperties = {}
local jobBlips = {}
local LastZone = nil
local Stopmove = false
local DrawMarker = DrawMarker

---Vehicle blip
---@param entity integer
local function toggleBlip(entity)
    if DoesBlipExist(carBlips[entity]) then
        RemoveBlip(carBlips[entity])
    else
        if DoesEntityExist(entity) then
            carBlips[entity] = AddBlipForEntity(entity)

            SetBlipSprite(carBlips[entity], GetVehicleClass(entity) == 8 and 226 or 523)

            SetBlipScale(carBlips[entity], 1.05)

            SetBlipColour(carBlips[entity], 30)

            BeginTextCommandSetBlipName("STRING")

            AddTextComponentString("Vehicle - " .. GetVehicleNumberPlateText(entity))
			if Config.Debug then
                print("Added plate to vehicle - " .. GetVehicleNumberPlateText(entity))
			end
            EndTextCommandSetBlipName(carBlips[entity])
        end
    end
end

local function stopmov()
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

local function drawScreenText(text, red, green, blue, alpha)
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

---Wait for vehicle model
---@param model number
---@return string?
local function waitForModel(model)
    if not IsModelValid(model) then
        return ESX.ShowNotification("This model does not exist ingame.")
    end

	if not HasModelLoaded(model) then
		RequestModel(model)
	end

	local name = GetDisplayNameFromVehicleModel(model)

	while not HasModelLoaded(model) do
		Wait(0)
		drawScreenText("Loading model " .. name .. "...", 255, 255, 255, 150)
	end
end

---Garage camera
---@param cam vector3
---@param camrot vector3
---@param toggle boolean
local function handleCamera(cam, camrot, toggle)
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

-- Create Blips
local function privateGarageBlips()
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
		local job = ESX.GetPlayerData().job.name
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

---Getting vehicle properties
---@param vehicle number
---@return table
function GetVehicleProperties(vehicle)
    if DoesEntityExist(vehicle) then
        local vehicleProps = ESX.Game.GetVehicleProperties(vehicle)
        if vehicleProps.fuelLevel then
			if Config.Debug then
                print("Fuel:" ..vehicleProps.fuelLevel)
			end
        else
			if Config.Debug then
                print("Fuel: nil")
			end
        end
        return vehicleProps
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
				local job = ESX.GetPlayerData().job
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

---Store Vehicles
---@param vehicle number
---@param vehicleProps table
local function storeVehicle(vehicle, vehicleProps)
	TaskLeaveVehicle(ESX.PlayerData.ped, vehicle, 1)
	Wait(1000)
	ESX.Game.DeleteVehicle(vehicle)
	if not vehicleProps then return ESX.ShowNotification('Nem sikerült elmenteni a jármüvet') end
	TriggerServerEvent('esx_advancedgarage:setVehicleState2', vehicleProps, 1, vehicleProps.plate)
	ESX.ShowNotification(_U('vehicle_in_garage'))
end

---Setting vehicle properties
---@param vehicle number
---@param vehicleProps table
local function SetVehicleProperties(vehicle, vehicleProps)
    return ESX.Game.SetVehicleProperties(vehicle, vehicleProps)
end

---Spawn local vehicle
---@param vehicleProps table
---@param pos vector4|table
local function SpawnLocalVehicle(vehicleProps, pos)
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
			if i == #_pos then return ESX.ShowNotification("Kérjük, mozgassa az útban lévö jármüvet.") end
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

---Spawn Pound Vehicles
---@param vehicle table
---@param plate string
local function SpawnPoundedVehicle(vehicle, plate)
	if DoesEntityExist(CachedData.vehicle) then
		DeleteEntity(CachedData.vehicle)
	end
	local gameVehicles = ESX.Game.GetVehicles()

	for i = 1, #gameVehicles do
	local veh = gameVehicles[i]
        if DoesEntityExist(veh) then
			if Config.Trim(GetVehicleNumberPlateText(veh)) == Config.Trim(plate) then
				ESX.ShowNotification("Ez az autó már kint van az utcán.")
				handleCamera(_, _, false)
				return
			end
		end
	end

	if type(This_Garage.SpawnPoint) == 'table' then
		for i=1, #This_Garage.SpawnPoint do
			local coords = This_Garage.SpawnPoint[i]
			if ESX.Game.IsSpawnPointClear(vec3(coords.x, coords.y, coords.z), 3.0) then
				if Config.ServerSpawn then
					TriggerServerEvent('esx_advancedgarage:spawn', vehicle, coords)
					handleCamera(_, _, false)
					return
				end

				return ESX.Game.SpawnVehicle(vehicle.model, vec3(coords.x, coords.y, coords.z + 1),

                    coords.w, function(callback_vehicle)

					SetVehicleProperties(callback_vehicle, vehicle)

					TaskWarpPedIntoVehicle(ESX.PlayerData.ped, callback_vehicle, -1)

					--if gps and gps > 0 then
						toggleBlip(callback_vehicle)
					--end
					handleCamera(_, _, false)
				end)
			else
				ESX.ShowNotification("Please move the vehicle that is in the way.")
				handleCamera(_, _, false)
			end
		end
	else
		if ESX.Game.IsSpawnPointClear(vec3(This_Garage.SpawnPoint.x, This_Garage.SpawnPoint.y, This_Garage.SpawnPoint.z), 3.0) then

			ESX.Game.SpawnVehicle(vehicle.model, vec3(This_Garage.SpawnPoint.x, This_Garage.SpawnPoint.y, This_Garage.SpawnPoint.z + 1),

                This_Garage.SpawnPoint.w, function(callback_vehicle)

				SetVehicleProperties(callback_vehicle, vehicle)

				TaskWarpPedIntoVehicle(ESX.PlayerData.ped, callback_vehicle, -1)

				--if gps and gps > 0 then
					toggleBlip(callback_vehicle)
				--end
			end)
			handleCamera(_, _, false)
		else
			ESX.ShowNotification("Please move the vehicle that is in the way.")
			handleCamera(_, _, false)
		end
	end
end

---Spawn vehicles
---@param vehicleProps table
---@param pos vector4
---@param z vector3
---@param zy vector3
---@return nil
local function SpawnVeh(vehicleProps, pos, z, zy)
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
                return handleCamera(z, zy, false)
            end
        end
    end

    for i = 1, #spawnpoint do
		local coords = spawnpoint[i]
	    if ESX.Game.IsSpawnPointClear(coords, 3.0) then
			if Config.ServerSpawn then
				TriggerServerEvent('esx_advancedgarage:spawn', veh, coords)
				TriggerServerEvent("esx_advancedgarage:takecar", veh.plate, 0)
				handleCamera(_, _, false)
				return
			end
            return ESX.Game.SpawnVehicle(model, coords, coords.w, function(yourVehicle)
                SetVehicleProperties(yourVehicle, veh)
                NetworkFadeInEntity(yourVehicle, true)
                SetModelAsNoLongerNeeded(model)
                TaskWarpPedIntoVehicle(ESX.PlayerData.ped, yourVehicle, -1)
                --if gps then
                    toggleBlip(yourVehicle)
                --end
                handleCamera(z, zy, false)
                TriggerServerEvent("esx_advancedgarage:takecar", veh.plate, 0)
            end)
	    end
        if i == #spawnpoint then return ESX.ShowNotification("Kérjük, mozgassa az útban lévö jármüvet.") end
    end
    ESX.ShowNotification("Kérjük, mozgassa az útban lévö jármüvet.")
    return handleCamera(z, zy, false)
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
				storeVehicle(vehicle, vehicleProps)
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
			storeVehicle(vehicle, vehicleProps)
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

	handleCamera(z, zy, true)
    Stopmove = true
    stopmov()

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
				handleCamera(z, zy, false)
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
					handleCamera(z, zy, false)
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
            handleCamera(z, zy, false)
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
    handleCamera(This_Garage.cam, This_Garage.camrot, true)
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
				handleCamera(This_Garage.cam, This_Garage.camrot, false)
				return
			end
			lib.registerMenu({
				id = 'esx_advancedgarage:getOwnedBoats',
				title = 'Garázs',
				options = options,
				onExit = true,
				onClose = function()
					lib.hideMenu(true)
					handleCamera(This_Garage.cam, This_Garage.camrot, false)
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
		stopmov()
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
            handleCamera(This_Garage.cam, This_Garage.camrot, false)
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
		handleCamera(This_Garage.cam, This_Garage.camrot, true)
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
				handleCamera(This_Garage.cam, This_Garage.camrot, false)
				return
			end
			lib.registerMenu({
				id = 'esx_advancedgarage:getOutOwnedBoats',
				title = 'Garázs',
				options = options,
				onExit = true,
				onClose = function()
					lib.hideMenu(true)
					handleCamera(This_Garage.cam, This_Garage.camrot, false)
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
						handleCamera(This_Garage.cam, This_Garage.camrot, false)
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
        stopmov()
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
						handleCamera(This_Garage.cam, This_Garage.camrot, false)
						Stopmove = false
				    else
					    ESX.ShowNotification(_U('not_enough_money'))
				    end
			    end
			end)
		end, function(_, menu)
            handleCamera(This_Garage.cam, This_Garage.camrot, false)
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
	handleCamera(This_Garage.cam, This_Garage.camrot, true)
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
				handleCamera(This_Garage.cam, This_Garage.camrot, false)
				return
			end
			lib.registerMenu({
				id = 'esx_advancedgarage:getOwnedAircrafts',
				title = 'Garázs',
				options = options,
				onExit = true,
				onClose = function()
					lib.hideMenu(true)
					handleCamera(This_Garage.cam, This_Garage.camrot, false)
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
		stopmov()
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
            handleCamera(This_Garage.cam, This_Garage.camrot, false)
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
		handleCamera(This_Garage.cam, This_Garage.camrot, true)
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
				handleCamera(This_Garage.cam, This_Garage.camrot, false)
				return
			end
			lib.registerMenu({
				id = 'esx_advancedgarage:getOutOwnedAircrafts',
				title = 'Garázs',
				options = options,
				onExit = true,
				onClose = function()
					lib.hideMenu(true)
					handleCamera(This_Garage.cam, This_Garage.camrot, false)
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
						handleCamera(This_Garage.cam, This_Garage.camrot, false)
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
        stopmov()
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
						handleCamera(This_Garage.cam, This_Garage.camrot, false)
						Stopmove = false
					else
						ESX.ShowNotification(_U('not_enough_money'))
					end
				end
			end)
		end, function(_, menu)
			handleCamera(This_Garage.cam, This_Garage.camrot, false)
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
						storeVehicle(vehicle, vehicleProps)
					end
				else
					storeVehicle(vehicle, vehicleProps)
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
						storeVehicle(vehicle, vehicleProps)
					end
				else
					storeVehicle(vehicle, vehicleProps)
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
	handleCamera(This_Garage.cam, This_Garage.camrot, true)
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
				handleCamera(This_Garage.cam, This_Garage.camrot, false)
				return
			end
			lib.registerMenu({
				id = 'esx_advancedgarage:getOutOwnedCars',
				title = 'Garázs',
				options = options,
				onExit = true,
				onClose = function()
					lib.hideMenu(true)
					handleCamera(This_Garage.cam, This_Garage.camrot, false)
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
		stopmov()
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
            handleCamera(This_Garage.cam, This_Garage.camrot, false)
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
				handleCamera(This_Garage.cam, This_Garage.camrot, false)
				return
			end
			lib.registerMenu({
				id = 'esx_advancedgarage:getOutOwnedPoliceCars',
				title = 'Garázs',
				options = options,
				onExit = true,
				onClose = function()
					lib.hideMenu(true)
					handleCamera(This_Garage.cam, This_Garage.camrot, false)
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
				handleCamera(This_Garage.cam, This_Garage.camrot, false)
				return
			end
			lib.registerMenu({
				id = 'esx_advancedgarage:getOutOwnedTaxiCars',
				title = 'Garázs',
				options = options,
				onExit = true,
				onClose = function()
					lib.hideMenu(true)
					handleCamera(This_Garage.cam, This_Garage.camrot, false)
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
				handleCamera(This_Garage.cam, This_Garage.camrot, false)
				return
			end
			lib.registerMenu({
				id = 'esx_advancedgarage:getOutOwnedSheriffCars',
				title = 'Garázs',
				options = options,
				onExit = true,
				onClose = function()
					lib.hideMenu(true)
					handleCamera(This_Garage.cam, This_Garage.camrot, false)
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
				handleCamera(This_Garage.cam, This_Garage.camrot, false)
				return
			end
			lib.registerMenu({
				id = 'esx_advancedgarage:getOutOwnedAmbulanceCars',
				title = 'Garázs',
				options = options,
				onExit = true,
				onClose = function()
					lib.hideMenu(true)
					handleCamera(This_Garage.cam, This_Garage.camrot, false)
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

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    ESX.PlayerData.job = job
	deleteBlips()
        Wait(1000)
	refreshBlips()
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	if Config.UsePrivateCarGarages then
		ESX.TriggerServerCallback('esx_advancedgarage:getOwnedProperties', function(properties)
			userProperties = properties
			privateGarageBlips()
		end)
	end
	drawMarkers()
	activateMenus()
	Wait(1000)
	ESX.PlayerData = xPlayer
	refreshBlips()
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
