---@diagnostic disable: undefined-global
local DrawMarker = DrawMarker
local AddBlipForCoord = AddBlipForCoord
local currentAction = nil
local currentActionMsg = ''
local carBlips = {}
local privateBlips = {}
local userProperties = {}
local jobBlips = {}
local LastZone = nil
local stopmove = false
local this_Garage = {}
local cachedData = {}
cachedData.vehicle = {}

---Delete local entity
---@return boolean
local function deleteCachedVehicle()
    if type(cachedData.vehicle) == "table" then
        for i=1, #cachedData.vehicle do
            if DoesEntityExist(cachedData.vehicle[i]) then
                SetEntityAsMissionEntity(cachedData.vehicle[i], true, true)
                DeleteVehicle(cachedData.vehicle[i])
            end
            while DoesEntityExist(cachedData.vehicle[i]) do
                SetEntityAsMissionEntity(cachedData.vehicle[i], true, true)
                DeleteVehicle(cachedData.vehicle[i])
                Wait(0)
            end
        end
    else
        if DoesEntityExist(cachedData.vehicle) then
            SetEntityAsMissionEntity(cachedData.vehicle, true, true)
            DeleteVehicle(cachedData.vehicle)
            while DoesEntityExist(cachedData.vehicle) do
                SetEntityAsMissionEntity(cachedData.vehicle, true, true)
                DeleteVehicle(cachedData.vehicle)
                Wait(0)
            end
            return true
        end
    end
    return true
end

---Vehicle blip
---@param entity integer
local function toggleBlip(entity)
    if not Config.VehBlip then return end
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
                print("Added blip to vehicle - " .. GetVehicleNumberPlateText(entity))
			end
            EndTextCommandSetBlipName(carBlips[entity])
        end
    end
end

RegisterNetEvent("esx_advancedgarage:toggleBlip", function(netId)
	if not Config.VehBlip then return end
	if not netId then return end
	Wait(1000)
	local v = NetworkGetEntityFromNetworkId(netId)
    toggleBlip(v)
end)

local function stopmov()
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
local function waitForModel(model)
	if not HasModelLoaded(model) then
		RequestModel(model)
	end

	local name = GetDisplayNameFromVehicleModel(model)

	while not HasModelLoaded(model) do
		Wait(0)
		drawScreenText("Loading model " .. name .. "...", 255, 255, 255, 150)
	end
end

---Store Vehicles
---@param vehicle number
---@param vehicleProps table
local function storeVehicle(vehicle, vehicleProps)
	TaskLeaveVehicle(ESX.PlayerData.ped, vehicle, 1)
	Wait(1000)
	ESX.Game.DeleteVehicle(vehicle)
	if not vehicleProps then return ESX.ShowNotification('Nem sikerült elmenteni a jármüvet') end
	TriggerServerEvent('esx_advancedgarage:setVehicleState', vehicleProps, 1, vehicleProps.plate, cachedData.currentGarage)
	ESX.ShowNotification(_U('vehicle_in_garage'))
end

---Getting vehicle properties
---@param vehicle number
---@return table
local function GetVehicleProperties(vehicle)
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
	return {}
end

---Setting vehicle properties
---@param vehicle number
---@param vehicleProps table
local function SetVehicleProperties(vehicle, vehicleProps)
    return ESX.Game.SetVehicleProperties(vehicle, vehicleProps)
end

---Garage camera
---@param cam vector3?
---@param camrot vector3?
---@param toggle boolean
local function handleCamera(cam, camrot, toggle)
    if not camrot then DestroyCam(cachedData.cam, false) return end
    if not cam then DestroyCam(cachedData.cam, false) return end

	if not toggle then
		if cachedData.cam then
			DestroyCam(cachedData.cam, false)
		end

		if DoesEntityExist(cachedData.vehicle) then
			DeleteEntity(cachedData.vehicle)
		end

		RenderScriptCams(false, true, 750, true, false)
		return
	end

	if cachedData.cam then
		DestroyCam(cachedData.cam, false)
	end

	cachedData.cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)

	SetCamCoord(cachedData.cam, cam.x, cam.y, cam.z)
	SetCamRot(cachedData.cam, camrot.x, camrot.y, camrot.z, 2)
	SetCamActive(cachedData.cam, true)
	RenderScriptCams(true, true, 750, true, true)
end

---Spawn local vehicle
---@param vehicleProps table
---@param pos vector4|table
local function SpawnLocalVehicle(vehicleProps, pos)
	if not pos then return end

	deleteCachedVehicle()

    local model = vehicleProps.vehicle?.model or vehicleProps.model
    local veh = vehicleProps?.vehicle or vehicleProps
    local _pos = pos
    if not IsModelValid(model) then
		return
	end

	waitForModel(model)

	if type(_pos) == "table" then
		for i = 1, #_pos do
			local coords = _pos[i]
			if ESX.Game.IsSpawnPointClear(coords, 3.0) then
				return ESX.Game.SpawnLocalVehicle(model, coords, coords.w --[[@as number]], function(yourVehicle)
					cachedData.vehicle[#cachedData.vehicle+1] = yourVehicle
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
                cachedData.vehicle = yourVehicle
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
	stopmove = false

	deleteCachedVehicle()

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

	if type(this_Garage.SpawnPoint) == 'table' then
		for i=1, #this_Garage.SpawnPoint do
			local coords = this_Garage.SpawnPoint[i]
			if ESX.Game.IsSpawnPointClear(vec3(coords.x, coords.y, coords.z), 3.0) then
				deleteCachedVehicle()
				Wait(1000)
				if Config.ServerSpawn then
					TriggerServerEvent('esx_advancedgarage:spawnVeh', vehicle, coords)
					handleCamera(_, _, false)
					return
				end
				return ESX.Game.SpawnVehicle(vehicle.model, vec3(coords.x, coords.y, coords.z + 1), coords.w, function(callback_vehicle)
					SetVehicleProperties(callback_vehicle, vehicle)
					TaskWarpPedIntoVehicle(ESX.PlayerData.ped, callback_vehicle, -1)
					if Config.VehBlip then
						toggleBlip(callback_vehicle)
					end
					handleCamera(_, _, false)
				end)
			else
				ESX.ShowNotification("Please move the vehicle that is in the way.")
				handleCamera(_, _, false)
			end
		end
	else
		if ESX.Game.IsSpawnPointClear(vec3(this_Garage.SpawnPoint.x, this_Garage.SpawnPoint.y, this_Garage.SpawnPoint.z), 3.0) then
			local coords = this_Garage.SpawnPoint
			deleteCachedVehicle()
			Wait(1000)
			if Config.ServerSpawn then
				TriggerServerEvent('esx_advancedgarage:spawnVeh', vehicle, coords)
				handleCamera(_, _, false)
				return
			end
			return ESX.Game.SpawnVehicle(vehicle.model, vec3(coords.x, coords.y, coords.z + 1), coords.w, function(callback_vehicle)
				SetVehicleProperties(callback_vehicle, vehicle)
				TaskWarpPedIntoVehicle(ESX.PlayerData.ped, callback_vehicle, -1)
				if Config.VehBlip then
					toggleBlip(callback_vehicle)
				end
				handleCamera(_, _, false)
			end)
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

    deleteCachedVehicle()

	stopmove = false
    local model = vehicleProps.vehicle?.model or vehicleProps.model
	local veh = vehicleProps?.vehicle or vehicleProps
	local spawnpoint = pos

	waitForModel(model)

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
			deleteCachedVehicle()
            Wait(1000)
			if Config.ServerSpawn then
				TriggerServerEvent('esx_advancedgarage:spawnVeh', veh, coords)
				TriggerServerEvent("esx_advancedgarage:takecar", veh.plate, 0)
				handleCamera(z, zy, false)
				return
			end
            return ESX.Game.SpawnVehicle(model, coords, coords.w --[[@as number]], function(yourVehicle)
                SetVehicleProperties(yourVehicle, veh)
                NetworkFadeInEntity(yourVehicle, true)
                SetModelAsNoLongerNeeded(model)
                TaskWarpPedIntoVehicle(ESX.PlayerData.ped, yourVehicle, -1)
                if Config.VehBlip then
                    toggleBlip(yourVehicle)
                end
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
	if Config.OxlibMenu then
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
				stopmove = false
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
		stopmove = false
	end)
end
end

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
						end, props, cachedData.currentGarage)
				    end
					ESX.Game.DeleteVehicle(vehicle)
			else
				ESX.ShowNotification("Ez nem a te jármüved!")
			end
		end, vehicleProps, cachedData.currentGarage)
	end
end

---Open main garage
---@param x vector4
---@param z vector3
---@param zy vector3
local function OpenGarageMenu(x, z, zy)
    ESX.UI.Menu.CloseAll()
    local currentGarage = cachedData.currentGarage

    if not currentGarage then return end

	handleCamera(z, zy, true)

    ESX.TriggerServerCallback("esx_advancedgarage:fetchPlayerVehicles", function(Vehicles)
		if Config.OxlibMenu then
			stopmove = true
			stopmov()
			local options = {}
			for i = 1, #Vehicles do
				local vehicleProps = Vehicles[i]
				local plate = vehicleProps.vehicle.plate
				local label = GetDisplayNameFromVehicleModel(vehicleProps.vehicle.model)
				local seat = GetVehicleModelNumberOfSeats(vehicleProps.vehicle.model)
				local fuel = ESX.Math.Round(vehicleProps.vehicle?.fuelLevel or 50.0)
				local body = vehicleProps.vehicle?.bodyHealth and ESX.Math.Round(vehicleProps.vehicle?.bodyHealth / 1000 * 100) or 100
				local engine = vehicleProps.vehicle?.engineHealth and ESX.Math.Round(vehicleProps.vehicle?.engineHealth / 1000 * 100) or 100
				if Config.ShowVehicleLocation then
					if vehicleProps.stored == 1 then
						options[i] = {
							label = ""..label.." | Rendszám: "..plate .." | Engine: "..engine.."%".." | Body: "..body.."%".." | Fuel: "..fuel.."%".." | Seats: "..seat.." | ".._U('loc_garage'),
							args = vehicleProps,
						}
					else
						options[i] = {
							label = ""..label.." | Rendszám: "..plate .." | Engine: "..engine.."%".." | Body: "..body.."%".." | Fuel: "..fuel.."%".." |  Seats: "..seat.." | ".._U('loc_pound'),
							args = vehicleProps,
						}
					end
				else
					options[i] = {
						label = ""..label.." | Rendszám: "..plate .." | Engine: "..engine.."%".." | Body: "..body.."%".." | Fuel: "..fuel.."%".." | Seats: "..seat.."",
						args = vehicleProps,
					}
				end
			end
			if #Vehicles == 0 then
				ESX.ShowNotification("Ide nem parkoltál semmit.")
				Wait(1000)
				handleCamera(z, zy, false)
				stopmove = false
				return
			end
			lib.registerMenu({
				id = 'esx_advancedgarage:GarageMenu',
				title = 'Garázs',
				options = options,
				onExit = true,
				onClose = function()
					deleteCachedVehicle()
                    lib.hideMenu(true)
					handleCamera(z, zy, false)
					stopmove = false
				end,
				onSelected = function(_, _, args)
					deleteCachedVehicle()
					SpawnLocalVehicle(args.vehicle, x)
				end,
			}, function(_, _, args)
				if args.stored == 1 then
					deleteCachedVehicle()
				    SpawnVeh(args.vehicle, x, z, zy)
				else
					deleteCachedVehicle()
					ESX.ShowNotification(_U('car_is_impounded'))
					lib.hideMenu(true)
					handleCamera(z, zy, false)
					stopmove = false
				end
			end)
			lib.showMenu('esx_advancedgarage:GarageMenu')
		else
			stopmove = true
			stopmov()
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
				deleteCachedVehicle()

				SpawnLocalVehicle(menuElements[1], x)
			end
        ESX.UI.Menu.Open("default", GetCurrentResourceName(), "main_garage_menu", {
            title = "Garage - " .. currentGarage,
            align = Config.AlignMenu,
            elements = menuElements
        }, function(menuData, menuHandle)
            local currentVehicle = menuData.current.vehicle
            if currentVehicle then
                menuHandle.close()
                stopmove = false
				deleteCachedVehicle()
                SpawnVeh(currentVehicle, x, z, zy)
            end
        end, function(_, menuHandle)
            handleCamera(z, zy, false)
            stopmove = false
            menuHandle.close()
        end, function(menuData, _)
            local currentVehicle = menuData.current.vehicle
            if currentVehicle then
				deleteCachedVehicle()
                SpawnLocalVehicle(currentVehicle, x)
            end
        end)
	end
    end, currentGarage)
end

---List Owned Boats Menu
local function ListOwnedBoatsMenu()
	local currentGarage = cachedData.currentGarage
    handleCamera(this_Garage.cam, this_Garage.camrot, true)
    ESX.TriggerServerCallback('esx_advancedgarage:getOwnedBoats', function(ownedBoats)
		if Config.OxlibMenu then
			stopmove = true
			stopmov()
			local options = {}
			for i = 1, #ownedBoats do
				local vehicleProps = ownedBoats[i]
				local label = GetDisplayNameFromVehicleModel(vehicleProps.vehicle.model)
				local plate = vehicleProps.vehicle.plate
				local fuel = ESX.Math.Round(vehicleProps.vehicle.fuelLevel)
				local body = ESX.Math.Round(vehicleProps.vehicle.bodyHealth / 1000 * 100)
				local engine = ESX.Math.Round(vehicleProps.vehicle.engineHealth / 1000 * 100)
				if Config.ShowVehicleLocation then
					if vehicleProps.stored == 1 then
						options[i] = {
							label = ""..label.." | Rendszám: "..plate .." | Engine: "..engine.."%".." | Body: "..body.."%".." | Fuel: "..fuel.."%".." | ".._U('loc_garage'),
							args = vehicleProps,
						}
					else
						options[i] = {
							label = ""..label.." | Rendszám: "..plate .." | Engine: "..engine.."%".." | Body: "..body.."%".." | Fuel: "..fuel.."%".." | ".._U('loc_pound'),
							args = vehicleProps,
						}
					end
				else
					options[i] = {
						label = ""..label.." | Rendszám: "..plate .." | Engine: "..engine.."%".." | Body: "..body.."%".." | Fuel: "..fuel.."%",
						args = vehicleProps,
					}
				end
			end
			if #ownedBoats == 0 then
				stopmove = false
				ESX.ShowNotification("Ide nem parkoltál semmit.")
				Wait(1000)
				handleCamera(this_Garage.cam, this_Garage.camrot, false)
				return
			end
			lib.registerMenu({
				id = 'esx_advancedgarage:getOwnedBoats',
				title = 'Garázs',
				options = options,
				onExit = true,
				onClose = function()
					lib.hideMenu(true)
					handleCamera(this_Garage.cam, this_Garage.camrot, false)
					stopmove = false
					deleteCachedVehicle()
				end,
				onSelected = function(_, _, args)
					deleteCachedVehicle()
					SpawnLocalVehicle(args.vehicle, this_Garage.SpawnPoint)
				end,
			}, function(_, _, args)
				if args.stored == 1 then
					deleteCachedVehicle()
					SpawnVeh(args.vehicle, this_Garage.SpawnPoint, this_Garage.cam, this_Garage.camrot)
				else
					deleteCachedVehicle()
					ESX.ShowNotification(_U('boat_is_impounded'))
					lib.hideMenu(true)
					handleCamera(this_Garage.cam, this_Garage.camrot, false)
					stopmove = false
			    end
			end)
			lib.showMenu('esx_advancedgarage:getOwnedBoats')
		else
		if #ownedBoats == 0 then
			ESX.ShowNotification(_U('garage_noboats'))
			stopmove = false
		else
			local elements = {}
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
			deleteCachedVehicle()
            SpawnLocalVehicle(elements[1].value, this_Garage.SpawnPoint)
        end
		stopmove = true
		stopmov()
		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'spawn_owned_boat', {
			title = _U('garage_boats'),
			align  = 'Config.AlignMenu',
			elements = elements
		}, function(data, menu)
			local currentVehicle = data.current.value
			    if currentVehicle.stored then
					menu.close()
					stopmove = false
					deleteCachedVehicle()
					SpawnVeh(currentVehicle.vehicle, this_Garage.SpawnPoint, this_Garage.cam, this_Garage.camrot)
				else
					ESX.ShowNotification(_U('boat_is_impounded'))
			    end
		end, function(_, menu)
			deleteCachedVehicle()
            handleCamera(this_Garage.cam, this_Garage.camrot, false)
            stopmove = false
            menu.close()
		end, function(data, _)
			local currentVehicle = data.current.value
			if currentVehicle then
				deleteCachedVehicle()
				SpawnLocalVehicle(currentVehicle, this_Garage.SpawnPoint)
			end
		end)
	end
    end, currentGarage)
end

---Pound Owned Boats Menu
local function ReturnOwnedBoatsMenu()
	ESX.TriggerServerCallback('esx_advancedgarage:getOutOwnedBoats', function(ownedBoats)
		handleCamera(this_Garage.cam, this_Garage.camrot, true)
		if Config.OxlibMenu then
			stopmove = true
			stopmov()
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
				handleCamera(this_Garage.cam, this_Garage.camrot, false)
				stopmove = false
				return
			end
			lib.registerMenu({
				id = 'esx_advancedgarage:getOutOwnedBoats',
				title = 'Garázs',
				options = options,
				onExit = true,
				onClose = function()
					lib.hideMenu(true)
					handleCamera(this_Garage.cam, this_Garage.camrot, false)
					stopmove = false
					deleteCachedVehicle()
				end,
				onSelected = function(_, _, args)
					deleteCachedVehicle()
					SpawnLocalVehicle(args, this_Garage.SpawnPoint)
				end,
			}, function(_, _, args)
				ESX.TriggerServerCallback('esx_advancedgarage:checkMoneyBoats', function(hasEnoughMoney)
					if hasEnoughMoney then
						deleteCachedVehicle()
						TriggerServerEvent('esx_advancedgarage:payBoat')
						SpawnPoundedVehicle(args, args.plate)
						handleCamera(this_Garage.cam, this_Garage.camrot, false)
						stopmove = false
					else
						deleteCachedVehicle()
						ESX.ShowNotification(_U('not_enough_money'))
						stopmove = false
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
			deleteCachedVehicle()
            SpawnLocalVehicle(elements[1].value, this_Garage.SpawnPoint)
        end
        stopmove = true
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
						deleteCachedVehicle()
					    TriggerServerEvent('esx_advancedgarage:payBoat')
					    SpawnVeh(currentVehicle, this_Garage.SpawnPoint, this_Garage.cam, this_Garage.camrot)
						handleCamera(this_Garage.cam, this_Garage.camrot, false)
						stopmove = false
				    else
					    ESX.ShowNotification(_U('not_enough_money'))
						stopmove = false
				    end
			    end
			end)
		end, function(_, menu)
            handleCamera(this_Garage.cam, this_Garage.camrot, false)
            stopmove = false
			deleteCachedVehicle()
            menu.close()
		end, function(data, _)
			local currentVehicle = data.current.value
			if currentVehicle then
				deleteCachedVehicle()
				SpawnLocalVehicle(currentVehicle, this_Garage.SpawnPoint)
			end
		end)
	end
	end)
end

---List Owned Aircrafts Menu
local function ListOwnedAircraftsMenu()
	local currentGarage = cachedData.currentGarage
	handleCamera(this_Garage.cam, this_Garage.camrot, true)
	ESX.TriggerServerCallback('esx_advancedgarage:getOwnedAircrafts', function(ownedAircrafts)
		if Config.OxlibMenu then
			stopmove = true
			stopmov()
			local options = {}
			for i = 1, #ownedAircrafts do

				local vehicleProps = ownedAircrafts[i]
				local label = GetDisplayNameFromVehicleModel(vehicleProps.vehicle.model)
				local plate = vehicleProps.vehicle.plate
				local fuel = ESX.Math.Round(vehicleProps.vehicle.fuelLevel)
				local body = ESX.Math.Round(vehicleProps.vehicle.bodyHealth / 1000 * 100)
				local engine = ESX.Math.Round(vehicleProps.vehicle.engineHealth / 1000 * 100)
				if Config.ShowVehicleLocation then
					if vehicleProps.stored == 1 then
						options[i] = {
							label = ""..label.." | Rendszám: "..plate .." | Engine: "..engine.."%".." | Body: "..body.."%".." | Fuel: "..fuel.."%".." | ".._U('loc_garage'),
							args = vehicleProps,
						}
					else
						options[i] = {
							label = ""..label.." | Rendszám: "..plate .." | Engine: "..engine.."%".." | Body: "..body.."%".." | Fuel: "..fuel.."%".." | ".._U('loc_pound'),
							args = vehicleProps,
						}
					end
				else
					options[i] = {
						label = ""..label.." | Rendszám: "..plate .." | Engine: "..engine.."%".." | Body: "..body.."%".." | Fuel: "..fuel.."%",
						args = vehicleProps,
					}
				end
			end
			if #ownedAircrafts == 0 then
				stopmove = false
				ESX.ShowNotification("Ide nem parkoltál semmit.")
				Wait(1000)
				handleCamera(this_Garage.cam, this_Garage.camrot, false)
				return
			end
			lib.registerMenu({
				id = 'esx_advancedgarage:getOwnedAircrafts',
				title = 'Garázs',
				options = options,
				onExit = true,
				onClose = function()
					lib.hideMenu(true)
					handleCamera(this_Garage.cam, this_Garage.camrot, false)
					stopmove = false
					deleteCachedVehicle()
				end,
				onSelected = function(_, _, args)
					deleteCachedVehicle()
					SpawnLocalVehicle(args.vehicle, this_Garage.SpawnPoint)
				end,
			}, function(_, _, args)
				if args.stored == 1 then
					deleteCachedVehicle()
					Wait(100)
					SpawnVeh(args.vehicle, this_Garage.SpawnPoint, this_Garage.cam, this_Garage.camrot)
				else
					ESX.ShowNotification(_U('aircraft_is_impounded'))
					lib.hideMenu(true)
					handleCamera(this_Garage.cam, this_Garage.camrot, false)
					stopmove = false
					deleteCachedVehicle()
			    end
			end)
			lib.showMenu('esx_advancedgarage:getOwnedAircrafts')
		else
		if #ownedAircrafts == 0 then
			ESX.ShowNotification(_U('garage_noaircrafts'))
			stopmove = false
		else
			local elements = {}
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
			deleteCachedVehicle()
            SpawnLocalVehicle(elements[1].value, this_Garage.SpawnPoint)
        end
		stopmove = true
		stopmov()
		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'spawn_owned_aircraft', {
			title = _U('garage_aircrafts'),
			align    = Config.AlignMenu,
			elements = elements
		}, function(data, menu)
			local currentVehicle = data.current.value
			    if currentVehicle.stored then
					menu.close()
					stopmove = false
					deleteCachedVehicle()
					Wait(100)
					SpawnVeh(currentVehicle.vehicle, this_Garage.SpawnPoint, this_Garage.cam, this_Garage.camrot)
				else
					ESX.ShowNotification(_U('aircraft_is_impounded'))
			    end
		end, function(_, menu)
            handleCamera(this_Garage.cam, this_Garage.camrot, false)
            stopmove = false
			deleteCachedVehicle()
            menu.close()
		end, function(data, _)
			local currentVehicle = data.current.value
			if currentVehicle then
				deleteCachedVehicle()
				SpawnLocalVehicle(currentVehicle, this_Garage.SpawnPoint)
			end
		end)
	end
	end, currentGarage)
end

---Pound Owned Aircrafts Menu
local function ReturnOwnedAircraftsMenu()
	ESX.TriggerServerCallback('esx_advancedgarage:getOutOwnedAircrafts', function(ownedAircrafts)
		handleCamera(this_Garage.cam, this_Garage.camrot, true)
		if Config.OxlibMenu then
			stopmove = true
			stopmov()
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
				stopmove = false
				ESX.ShowNotification("Ide nem parkoltál semmit.")
				Wait(1000)
				handleCamera(this_Garage.cam, this_Garage.camrot, false)
				return
			end
			lib.registerMenu({
				id = 'esx_advancedgarage:getOutOwnedAircrafts',
				title = 'Garázs',
				options = options,
				onExit = true,
				onClose = function()
					lib.hideMenu(true)
					handleCamera(this_Garage.cam, this_Garage.camrot, false)
					stopmove = false
					deleteCachedVehicle()
				end,
				onSelected = function(_, _, args)
					deleteCachedVehicle()
					Wait(100)
					SpawnLocalVehicle(args, this_Garage.SpawnPoint)
				end,
			}, function(_, _, args)
				ESX.TriggerServerCallback('esx_advancedgarage:checkMoneyAircrafts', function(hasEnoughMoney)
					if hasEnoughMoney then
						deleteCachedVehicle()
						Wait(100)
						TriggerServerEvent('esx_advancedgarage:payAircraft')
						SpawnPoundedVehicle(args, args.plate)
						handleCamera(this_Garage.cam, this_Garage.camrot, false)
						stopmove = false
					else
						deleteCachedVehicle()
						ESX.ShowNotification(_U('not_enough_money'))
						stopmove = false
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
			deleteCachedVehicle()
			Wait(100)
			SpawnLocalVehicle(elements[1].value, this_Garage.SpawnPoint)
		end
        stopmove = true
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
						deleteCachedVehicle()
						Wait(100)
						TriggerServerEvent('esx_advancedgarage:payAircraft')
						SpawnPoundedVehicle(currentVehicle, data.current.value.plate)
						handleCamera(this_Garage.cam, this_Garage.camrot, false)
						stopmove = false
					else
						ESX.ShowNotification(_U('not_enough_money'))
					end
				end
			end)
		end, function(_, menu)
			handleCamera(this_Garage.cam, this_Garage.camrot, false)
			stopmove = false
			deleteCachedVehicle()
			menu.close()
		end, function(data, _)
			local currentVehicle = data.current.value
			if currentVehicle then
				deleteCachedVehicle()
				Wait(100)
				SpawnLocalVehicle(currentVehicle, this_Garage.SpawnPoint)
			end
		end)
	end
end)
end

---Store Owned Boats Menu
local function StoreOwnedBoatsMenu()
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
local function StoreOwnedAircraftsMenu()
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
local function ReturnOwnedCarsMenu()
	ESX.UI.Menu.CloseAll()
	handleCamera(this_Garage.cam, this_Garage.camrot, true)
	ESX.TriggerServerCallback('esx_advancedgarage:getOutOwnedCars', function(ownedCars)
		if Config.OxlibMenu then
			stopmove = true
			stopmov()
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
				stopmove = false
				ESX.ShowNotification("Ide nem parkoltál semmit.")
				Wait(1000)
				handleCamera(this_Garage.cam, this_Garage.camrot, false)
				return
			end
			lib.registerMenu({
				id = 'esx_advancedgarage:getOutOwnedCars',
				title = 'Garázs',
				options = options,
				onExit = true,
				onClose = function()
					lib.hideMenu(true)
					handleCamera(this_Garage.cam, this_Garage.camrot, false)
					stopmove = false
					deleteCachedVehicle()
				end,
				onSelected = function(_, _, args)
					deleteCachedVehicle()
					Wait(100)
					SpawnLocalVehicle(args, this_Garage.SpawnPoint)
				end,
			}, function(_, _, args)
			    ESX.TriggerServerCallback('esx_advancedgarage:checkMoneyCars', function(hasEnoughMoney)
				    if hasEnoughMoney then
						deleteCachedVehicle()
						Wait(100)
					    SpawnPoundedVehicle(args, args.plate)
					    TriggerServerEvent('esx_advancedgarage:payCar', args.plate)
				    else
						deleteCachedVehicle()
					    ESX.ShowNotification(_U('not_enough_money'))
						stopmove = false
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
			deleteCachedVehicle()
            SpawnLocalVehicle(elements[1], this_Garage.SpawnPoint)
        end
		stopmove = true
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
						stopmove = false
						deleteCachedVehicle()
						Wait(100)
					    SpawnVeh(currentVehicle.vehicle, this_Garage.SpawnPoint, this_Garage.cam, this_Garage.camrot)
					    TriggerServerEvent('esx_advancedgarage:payCar', currentVehicle.vehicle.plate)
				    else
					    ESX.ShowNotification(_U('not_enough_money'))
				    end
			    end)
			end
		end, function(_, menu)
            handleCamera(this_Garage.cam, this_Garage.camrot, false)
            stopmove = false
			deleteCachedVehicle()
            menu.close()
		end, function(data, _)
			local currentVehicle = data.current
			if currentVehicle then
				deleteCachedVehicle()
				Wait(100)
				SpawnLocalVehicle(currentVehicle, this_Garage.SpawnPoint)
			end
		end)
	end
	end)
end

---Pound Owned Policing Menu
local function ReturnOwnedPolicingMenu()
	ESX.TriggerServerCallback('esx_advancedgarage:getOutOwnedPoliceCars', function(ownedPolicingCars)
		if Config.OxlibMenu then
			stopmove = true
			stopmov()
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
				stopmove = false
				ESX.ShowNotification("Ide nem parkoltál semmit.")
				Wait(1000)
				handleCamera(this_Garage.cam, this_Garage.camrot, false)
				return
			end
			lib.registerMenu({
				id = 'esx_advancedgarage:getOutOwnedPoliceCars',
				title = 'Garázs',
				options = options,
				onExit = true,
				onClose = function()
					deleteCachedVehicle()
					lib.hideMenu(true)
					handleCamera(this_Garage.cam, this_Garage.camrot, false)
					stopmove = false
				end,
				onSelected = function(_, _, args)
					deleteCachedVehicle()
					Wait(100)
					SpawnLocalVehicle(args, this_Garage.SpawnPoint)
				end,
			}, function(_, _, args)
				ESX.TriggerServerCallback('esx_advancedgarage:checkMoneyPolice', function(hasEnoughMoney)
					if hasEnoughMoney then
						deleteCachedVehicle()
						Wait(100)
						TriggerServerEvent('esx_advancedgarage:payPolice')
						SpawnPoundedVehicle(args, args.plate)
					else
						deleteCachedVehicle()
						ESX.ShowNotification(_U('not_enough_money'))
						stopmove = false
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
		stopmove = true
		stopmov()
		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'return_owned_police', {
			title = _U('pound_police'),
			align = Config.AlignMenu,
			elements = elements
		}, function(data, _)
			ESX.TriggerServerCallback('esx_advancedgarage:checkMoneyPolice', function(hasEnoughMoney)
				if hasEnoughMoney then
					deleteCachedVehicle()
					Wait(100)
					TriggerServerEvent('esx_advancedgarage:payPolice')
					SpawnPoundedVehicle(data.current.value, data.current.value.plate)
				else
					deleteCachedVehicle()
					ESX.ShowNotification(_U('not_enough_money'))
					stopmove = false
				end
			end)
		end, function(_, menu)
			menu.close()
			stopmove = false
			deleteCachedVehicle()
		end)
	end
	end)
end

---Pound Owned taxi Menu
local function ReturnOwnedtaxiMenu()
	ESX.TriggerServerCallback('esx_advancedgarage:getOutOwnedTaxiCars', function(ownedtaxiCars)
		if Config.OxlibMenu then
			stopmove = true
			stopmov()
			local options = {}
			for i = 1, #ownedtaxiCars do
				local vehicleProps = ownedtaxiCars[i]
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
			if #ownedtaxiCars == 0 then
				stopmove = false
				ESX.ShowNotification("Ide nem parkoltál semmit.")
				Wait(1000)
				handleCamera(this_Garage.cam, this_Garage.camrot, false)
				return
			end
			lib.registerMenu({
				id = 'esx_advancedgarage:getOutOwnedTaxiCars',
				title = 'Garázs',
				options = options,
				onExit = true,
				onClose = function()
					lib.hideMenu(true)
					handleCamera(this_Garage.cam, this_Garage.camrot, false)
					stopmove = false
					deleteCachedVehicle()
				end,
				onSelected = function(_, _, args)
					deleteCachedVehicle()
					Wait(100)
					SpawnLocalVehicle(args, this_Garage.SpawnPoint)
				end,
			}, function(_, _, args)
				ESX.TriggerServerCallback('esx_advancedgarage:checkMoneyTaxi', function(hasEnoughMoney)
					if hasEnoughMoney then
						deleteCachedVehicle()
						Wait(100)
						TriggerServerEvent('esx_advancedgarage:payTaxi')
						SpawnPoundedVehicle(args, args.plate)
					else
						deleteCachedVehicle()
						ESX.ShowNotification(_U('not_enough_money'))
						stopmove = false
					end
				end)
			end)
			lib.showMenu('esx_advancedgarage:getOutOwnedTaxiCars')
		else
		local elements = {}

		for i = 1, #ownedtaxiCars do
			if Config.UseVehicleNamesLua then
				local hashVehicule = ownedtaxiCars[i].model
				local aheadVehName = GetDisplayNameFromVehicleModel(hashVehicule)
				local vehicleName  = GetLabelText(aheadVehName)
				local plate        = ownedtaxiCars[i].plate
				local labelvehicle

				labelvehicle = '| '..plate..' | '..vehicleName..' | '.._U('return')..' |'

				elements[#elements+1] = {label = labelvehicle, value = ownedtaxiCars[i]}
			else
				local hashVehicule = ownedtaxiCars[i].model
				local vehicleName  = GetDisplayNameFromVehicleModel(hashVehicule)
				local plate        = ownedtaxiCars[i].plate
				local labelvehicle

				labelvehicle = '| '..plate..' | '..vehicleName..' | '.._U('return')..' |'

				elements[#elements+1] = {label = labelvehicle, value = ownedtaxiCars[i]}
			end
		end
		stopmove = true
		stopmov()
		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'return_owned_taxi', {
			title = _U('pound_taxi'),
			align = Config.AlignMenu,
			elements = elements
		}, function(data, _)
			ESX.TriggerServerCallback('esx_advancedgarage:checkMoneyTaxi', function(hasEnoughMoney)
				if hasEnoughMoney then
					deleteCachedVehicle()
					Wait(100)
					TriggerServerEvent('esx_advancedgarage:payTaxi')
					SpawnPoundedVehicle(data.current.value, data.current.value.plate)
				else
					deleteCachedVehicle()
					ESX.ShowNotification(_U('not_enough_money'))
					stopmove = false
				end
			end)
		end, function(_, menu)
			menu.close()
			deleteCachedVehicle()
			stopmove = false
		end)
	end
	end)
end

---Pound Owned Sheriff Menu
local function ReturnOwnedSheriffMenu()
	ESX.TriggerServerCallback('esx_advancedgarage:getOutOwnedSheriffCars', function(ownedSheriffCars)
		if Config.OxlibMenu then
			stopmove = true
			stopmov()
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
				stopmove = false
				ESX.ShowNotification("Ide nem parkoltál semmit.")
				Wait(1000)
				handleCamera(this_Garage.cam, this_Garage.camrot, false)
				return
			end
			lib.registerMenu({
				id = 'esx_advancedgarage:getOutOwnedSheriffCars',
				title = 'Garázs',
				options = options,
				onExit = true,
				onClose = function()
					lib.hideMenu(true)
					handleCamera(this_Garage.cam, this_Garage.camrot, false)
					stopmove = false
					deleteCachedVehicle()
				end,
				onSelected = function(_, _, args)
					deleteCachedVehicle()
					SpawnLocalVehicle(args, this_Garage.SpawnPoint)
				end,
			}, function(_, _, args)
				ESX.TriggerServerCallback('esx_advancedgarage:checkMoneySheriff', function(hasEnoughMoney)
					if hasEnoughMoney then
						deleteCachedVehicle()
						Wait(100)
						TriggerServerEvent('esx_advancedgarage:paySheriff')
						SpawnPoundedVehicle(args, args.plate)
					else
						deleteCachedVehicle()
						ESX.ShowNotification(_U('not_enough_money'))
						stopmove = false
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
		stopmove = true
		stopmov()
		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'return_owned_sheriff', {
			title = _U('pound_sheriff'),
			align = Config.AlignMenu,
			elements = elements
		}, function(data, _)
			ESX.TriggerServerCallback('esx_advancedgarage:checkMoneySheriff', function(hasEnoughMoney)
				if hasEnoughMoney then
					deleteCachedVehicle()
					Wait(100)
					TriggerServerEvent('esx_advancedgarage:paySheriff')
					SpawnPoundedVehicle(data.current.value, data.current.value.plate)
				else
					deleteCachedVehicle()
					ESX.ShowNotification(_U('not_enough_money'))
					stopmove = false
				end
			end)
		end, function(_, menu)
			menu.close()
			deleteCachedVehicle()
			stopmove = false
		end)
	end
	end)
end

---Pound Owned Ambulance Menu
local function ReturnOwnedAmbulanceMenu()
	ESX.TriggerServerCallback('esx_advancedgarage:getOutOwnedAmbulanceCars', function(ownedAmbulanceCars)
		if Config.OxlibMenu then
			stopmove = true
			stopmov()
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
				stopmove = false
				ESX.ShowNotification("Ide nem parkoltál semmit.")
				Wait(1000)
				handleCamera(this_Garage.cam, this_Garage.camrot, false)
				return
			end
			lib.registerMenu({
				id = 'esx_advancedgarage:getOutOwnedAmbulanceCars',
				title = 'Garázs',
				options = options,
				onExit = true,
				onClose = function()
					lib.hideMenu(true)
					handleCamera(this_Garage.cam, this_Garage.camrot, false)
					stopmove = false
					deleteCachedVehicle()
				end,
				onSelected = function(_, _, args)
					deleteCachedVehicle()
					Wait(100)
					SpawnLocalVehicle(args, this_Garage.SpawnPoint)
				end,
			}, function(_, _, args)
				ESX.TriggerServerCallback('esx_advancedgarage:checkMoneyAmbulance', function(hasEnoughMoney)
					if hasEnoughMoney then
						deleteCachedVehicle()
						Wait(100)
						TriggerServerEvent('esx_advancedgarage:payAmbulance')
						SpawnPoundedVehicle(args, args.plate)
					else
						deleteCachedVehicle()
						ESX.ShowNotification(_U('not_enough_money'))
						stopmove = false
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
		stopmove = true
		stopmov()
		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'return_owned_ambulance', {
			title = _U('pound_ambulance'),
			align = Config.AlignMenu,
			elements = elements
		}, function(data, _)
			ESX.TriggerServerCallback('esx_advancedgarage:checkMoneyAmbulance', function(hasEnoughMoney)
				if hasEnoughMoney then
					deleteCachedVehicle()
					Wait(100)
					TriggerServerEvent('esx_advancedgarage:payAmbulance')
					SpawnPoundedVehicle(data.current.value, data.current.value.plate)
				else
					deleteCachedVehicle()
					ESX.ShowNotification(_U('not_enough_money'))
					stopmove = false
				end
			end)
		end, function(_, menu)
			menu.close()
			stopmove = false
			deleteCachedVehicle()
		end)
	end
	end)
end

---Open Main Menu
---@param PointType string
---@return nil
local function OpenMenuGarage(PointType)
	if Config.OxlibMenu then
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
		elseif PointType == 'taxi_pound_point' then
			elements[#elements+1] = {label = _U('return_owned_taxi').." ($"..Config.taxiPoundPrice..")", args = 'return_owned_taxi'}
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
			elseif args == 'return_owned_taxi' then
				ReturnOwnedtaxiMenu()
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
		elseif PointType == 'taxi_pound_point' then
			elements[#elements+1] = {label = _U('return_owned_taxi').." ($"..Config.taxiPoundPrice..")", value = 'return_owned_taxi'}
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
			elseif action == 'return_owned_taxi' then
				ReturnOwnedtaxiMenu()
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

CreateThread(function()
	Wait(3333)
	if not Config.UseCarGarages then return end
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
				sleep = 0
                markersize = 1.5
				if dst <= markersize then
					ESX.ShowHelpNotification(string.format(Config.Labels.menu, g))
					if IsControlJustPressed(0, 38) then
						cachedData.currentGarage = g
						OpenGarageMenu(garage.spawnposition, garage.camera, garage.camrotation)
					end
				end
				---@diagnostic disable-next-line: param-type-mismatch
                DrawMarker(6, pos.x, pos.y, pos.z - 0.985, 0.0, 0.0, 0.0, -90.0, -90.0, -90.0, markersize, markersize, markersize, 51, 255, 0, 100, false, true, 2, false, false, false, false)
			end
			if IsPedInAnyVehicle(ped, false) then
				local gpos = garage.vehicleposition
				local dst2 = #(pedCoords - gpos)
				if dst2 <= 50.0 then
					sleep = 0
					markersize = 5
					if dst2 <= markersize then
						ESX.ShowHelpNotification(Config.Labels.vehicle)
						if IsControlJustPressed(0, 38) then
							cachedData.currentGarage = g
							putInVehicle()
						end
					end
                    ---@diagnostic disable-next-line: param-type-mismatch
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
		if currentAction then
            sleep = 0
			ESX.ShowHelpNotification(currentActionMsg)

			if IsControlJustReleased(0, 38) then
				if currentAction == 'car_garage_point' then
					OpenMenuGarage('car_garage_point')
				elseif currentAction == 'car_store_point' then
					OpenMenuGarage('car_store_point')
				elseif currentAction == 'boat_garage_point' then
					OpenMenuGarage('boat_garage_point')
				elseif currentAction == 'aircraft_garage_point' then
					OpenMenuGarage('aircraft_garage_point')
				elseif currentAction == 'boat_store_point' then
					OpenMenuGarage('boat_store_point')
				elseif currentAction == 'aircraft_store_point' then
					OpenMenuGarage('aircraft_store_point')
				elseif currentAction == 'car_pound_point' then
					OpenMenuGarage('car_pound_point')
				elseif currentAction == 'boat_pound_point' then
					OpenMenuGarage('boat_pound_point')
				elseif currentAction == 'aircraft_pound_point' then
					OpenMenuGarage('aircraft_pound_point')
				elseif currentAction == 'policing_pound_point' then
					OpenMenuGarage('policing_pound_point')
				elseif currentAction == 'taxi_pound_point' then
					OpenMenuGarage('taxi_pound_point')
				elseif currentAction == 'Sheriff_pound_point' then
					OpenMenuGarage('Sheriff_pound_point')
				elseif currentAction == 'ambulance_pound_point' then
					OpenMenuGarage('ambulance_pound_point')
				end
				currentAction = nil
				stopmove = false
			end
		end
		Wait(sleep)
	end
end)

-- Entered Marker
AddEventHandler('esx_advancedgarage:hasEnteredMarker', function(zone)
	if zone == 'car_garage_point' then
		currentAction     = 'car_garage_point'
		currentActionMsg  = _U('press_to_enter')
	elseif zone == 'car_store_point' then
		currentAction     = 'car_store_point'
		currentActionMsg  = _U('press_to_enter')
	elseif zone == 'boat_garage_point' then
		currentAction     = 'boat_garage_point'
		currentActionMsg  = _U('press_to_enter')
	elseif zone == 'aircraft_garage_point' then
		currentAction     = 'aircraft_garage_point'
		currentActionMsg  = _U('press_to_enter')
	elseif zone == 'boat_store_point' then
		currentAction     = 'boat_store_point'
		currentActionMsg  = _U('press_to_delete')
	elseif zone == 'aircraft_store_point' then
		currentAction     = 'aircraft_store_point'
		currentActionMsg  = _U('press_to_delete')
	elseif zone == 'car_pound_point' then
		currentAction     = 'car_pound_point'
		currentActionMsg  = _U('press_to_impound')
	elseif zone == 'boat_pound_point' then
		currentAction     = 'boat_pound_point'
		currentActionMsg  = _U('press_to_impound')
	elseif zone == 'aircraft_pound_point' then
		currentAction     = 'aircraft_pound_point'
		currentActionMsg  = _U('press_to_impound')
	elseif zone == 'policing_pound_point' then
		currentAction     = 'policing_pound_point'
		currentActionMsg  = _U('press_to_impound')
	elseif zone == 'taxi_pound_point' then
		currentAction     = 'taxi_pound_point'
		currentActionMsg  = _U('press_to_impound')
	elseif zone == 'Sheriff_pound_point' then
		currentAction     = 'Sheriff_pound_point'
		currentActionMsg  = _U('press_to_impound')
	elseif zone == 'ambulance_pound_point' then
		currentAction     = 'ambulance_pound_point'
		currentActionMsg  = _U('press_to_impound')
	end
end)

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
		for i=1, #Config.CarPounds do
			local v = Config.CarPounds[i]
			blipList[#blipList+1] = {
				coords = v.PoundPoint,
				text   = _U('blip_pound'),
				sprite = Config.BlipPound.Sprite,
				color  = Config.BlipPound.Color,
				scale  = Config.BlipPound.Scale
			}
		end
	end

	if Config.UseBoatGarages then
        for i=1, #Config.BoatGarages do
            local v = Config.BoatGarages[i]
			blipList[#blipList+1] = {
				coords = { v.GaragePoint.x, v.GaragePoint.y },
				text   = _U('garage_boats'),
				sprite = Config.BlipGarage.Sprite,
				color  = Config.BlipGarage.Color,
				scale  = Config.BlipGarage.Scale
			}
		end

        for i=1, #Config.BoatPounds do
            local v = Config.BoatPounds[i]
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
        for i=1, #Config.AircraftGarages do
            local v = Config.AircraftGarages[i]
			blipList[#blipList+1] = {
				coords = { v.GaragePoint.x, v.GaragePoint.y },
				text   = _U('garage_aircrafts'),
				sprite = Config.BlipGarage.Sprite,
				color  = Config.BlipGarage.Color,
				scale  = Config.BlipGarage.Scale
			}
		end

        for i=1, #Config.AircraftPounds do
            local v = Config.AircraftPounds[i]
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
            for i=1, #Config.PolicePounds do
                local v = Config.PolicePounds[i]
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
			for i=1, #Config.SheriffPounds do
				local v = Config.SheriffPounds[i]
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
			for i=1, #Config.AmbulancePounds do
				local v = Config.AmbulancePounds[i]
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

-- Activate Menu when in Markers
local function activateMenus()
	CreateThread(function()
		local currentZone = 'garage'
		while true do
			Wait(200)
			local coords = GetEntityCoords(ESX.PlayerData.ped)
			local isInMarker = false
			if Config.UseCarGarages then
				for i=1, #Config.CarPounds do
					local v = Config.CarPounds[i]
					if #(coords - v.PoundPoint) <= Config.MarkerDistance then
						isInMarker  = true
						this_Garage = v
						currentZone = 'car_pound_point'
					end
				end
			end

			if Config.UseBoatGarages then
                for i=1, #Config.BoatGarages do
                    local v = Config.BoatGarages[i]
					if #(coords - v.GaragePoint) <= Config.MarkerDistance then
						isInMarker  = true
						cachedData.currentGarage = v.garage
						this_Garage = v
						currentZone = 'boat_garage_point'
					end

					if #(coords - v.DeletePoint) <= Config.MarkerDistance then
						isInMarker  = true
						cachedData.currentGarage = v.garage
						this_Garage = v
						currentZone = 'boat_store_point'
					end
				end

                for i=1, #Config.BoatPounds do
                    local v = Config.BoatPounds[i]
					if #(coords - v.PoundPoint) <= Config.MarkerDistance then
						isInMarker  = true
						this_Garage = v
						currentZone = 'boat_pound_point'
					end
				end
			end

			if Config.UseAircraftGarages then
				for i=1, #Config.AircraftGarages do
					local v = Config.AircraftGarages[i]
					if #(coords - v.GaragePoint) <= Config.MarkerDistance then
						isInMarker  = true
						cachedData.currentGarage = v.garage
						this_Garage = v
						currentZone = 'aircraft_garage_point'
					end

					if #(coords - v.DeletePoint) <= Config.MarkerDistance2 then
						isInMarker  = true
						cachedData.currentGarage = v.garage
						this_Garage = v
						currentZone = 'aircraft_store_point'
					end
				end

				for i=1, #Config.AircraftPounds do
					local v = Config.AircraftPounds[i]
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
						if #(coords - vec3(v.GaragePoint.x, v.GaragePoint.y, v.GaragePoint.z)) <= Config.MarkerDistance then
							isInMarker  = true
							this_Garage = v
							currentZone = 'car_garage_point'
						end

						if #(coords - vec3(v.DeletePoint.x, v.DeletePoint.y, v.DeletePoint.z)) <= Config.MarkerDistance then
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
                    for i=1, #Config.PolicePounds do
                        local v = Config.PolicePounds[i]
						if #(coords - vec3(v.PoundPoint.x, v.PoundPoint.y, v.PoundPoint.z)) <= Config.MarkerDistance then
							isInMarker  = true
							this_Garage = v
							currentZone = 'policing_pound_point'
						end
					end
				end

				if job and jobname == 'sheriff' then
					for i=1, #Config.SheriffPounds do
						local v = Config.SheriffPounds[i]
						if #(coords - vec3(v.PoundPoint.x, v.PoundPoint.y, v.PoundPoint.z)) <= Config.MarkerDistance then
							isInMarker  = true
							this_Garage = v
							currentZone = 'Sheriff_pound_point'
						end
					end
				end

				if job and jobname == 'ambulance' then
					for i=1, #Config.AmbulancePounds do
						local v = Config.AmbulancePounds[i]
						if #(coords - vec3(v.PoundPoint.x, v.PoundPoint.y, v.PoundPoint.z)) <= Config.MarkerDistance then
							isInMarker  = true
							this_Garage = v
							currentZone = 'ambulance_pound_point'
						end
					end
				end

				if job and jobname == 'taxi' then
                        for i=1, #Config.TaxiPounds do
                        local v = Config.TaxiPounds[i]
						if #(coords - vec3(v.PoundPoint.x, v.PoundPoint.y, v.PoundPoint.z)) <= Config.MarkerDistance then
							isInMarker  = true
							this_Garage = v
							currentZone = 'taxi_pound_point'
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
			local playerPed = ESX.PlayerData.ped
			local coords = GetEntityCoords(playerPed)
			local sleep = 500

			if Config.UseCarGarages then
				for i=1, #Config.CarPounds do
					local v = Config.CarPounds[i]
					if #(coords - v.PoundPoint) < Config.DrawDistance then
						sleep = 0
						---@diagnostic disable-next-line: param-type-mismatch
						DrawMarker(Config.MarkerType, v.PoundPoint.x, v.PoundPoint.y, v.PoundPoint.z, 0.0, 0.0, 0.0, 270.0, 0.0, 0.0, Config.PoundMarker.x, Config.PoundMarker.y, Config.PoundMarker.z, Config.PoundMarker.r, Config.PoundMarker.g, Config.PoundMarker.b, 100, false, true, 2, false, false, false, false)
					end
				end
			end

			if Config.UseBoatGarages then
				for i=1, #Config.BoatGarages do
					local v = Config.BoatGarages[i]
					if #(coords - v.GaragePoint) < Config.DrawDistance then
						sleep = 0
						---@diagnostic disable-next-line: param-type-mismatch
						DrawMarker(Config.MarkerType, v.GaragePoint.x, v.GaragePoint.y, v.GaragePoint.z, 0.0, 0.0, 0.0, 270.0, 0.0, 0.0, Config.PointMarker.x, Config.PointMarker.y, Config.PointMarker.z, Config.PointMarker.r, Config.PointMarker.g, Config.PointMarker.b, 100, false, true, 2, false, false, false, false)
						---@diagnostic disable-next-line: param-type-mismatch
						DrawMarker(Config.MarkerType, v.DeletePoint.x, v.DeletePoint.y, v.DeletePoint.z, 0.0, 0.0, 0.0, 270.0, 0.0, 0.0, Config.DeleteMarker.x, Config.DeleteMarker.y, Config.DeleteMarker.z, Config.DeleteMarker.r, Config.DeleteMarker.g, Config.DeleteMarker.b, 100, false, true, 2, false, false, false, false)
					end
				end

				for i=1, #Config.BoatPounds do
					local v = Config.BoatPounds[i]
					if #(coords - v.PoundPoint) < Config.DrawDistance then
						sleep = 0
						---@diagnostic disable-next-line: param-type-mismatch
						DrawMarker(Config.MarkerType, v.PoundPoint.x, v.PoundPoint.y, v.PoundPoint.z, 0.0, 0.0, 0.0, 270.0, 0.0, 0.0, Config.PoundMarker.x, Config.PoundMarker.y, Config.PoundMarker.z, Config.PoundMarker.r, Config.PoundMarker.g, Config.PoundMarker.b, 100, false, true, 2, false, false, false, false)
					end
				end
			end

			if Config.UseAircraftGarages then
                for i=1, #Config.AircraftGarages do
                    local v = Config.AircraftGarages[i]
					if #(coords - v.GaragePoint) < Config.DrawDistance then
						sleep = 0
						---@diagnostic disable-next-line: param-type-mismatch
						DrawMarker(Config.MarkerType, v.GaragePoint.x, v.GaragePoint.y, v.GaragePoint.z, 0.0, 0.0, 0.0, 270.0, 0.0, 0.0, Config.PointMarker.x, Config.PointMarker.y, Config.PointMarker.z, Config.PointMarker.r, Config.PointMarker.g, Config.PointMarker.b, 100, false, true, 2, false, false, false, false)
					end
					if #(coords - v.DeletePoint) < 80 then
						sleep = 0
						---@diagnostic disable-next-line: param-type-mismatch
						DrawMarker(Config.MarkerType, v.DeletePoint.x, v.DeletePoint.y, v.DeletePoint.z, 0.0, 0.0, 0.0, 270.0, 0.0, 0.0, Config.DeleteMarker2.x, Config.DeleteMarker2.y, Config.DeleteMarker2.z, Config.DeleteMarker2.r, Config.DeleteMarker2.g, Config.DeleteMarker2.b, 100, false, true, 2, false, false, false, false)
					end
				end

                for i=1, #Config.AircraftPounds do
                    local v = Config.AircraftPounds[i]
					if #(coords - v.PoundPoint) < Config.DrawDistance then
						sleep = 0
						---@diagnostic disable-next-line: param-type-mismatch
						DrawMarker(Config.MarkerType, v.PoundPoint.x, v.PoundPoint.y, v.PoundPoint.z, 0.0, 0.0, 0.0, 270.0, 0.0, 0.0, Config.PoundMarker.x, Config.PoundMarker.y, Config.PoundMarker.z, Config.PoundMarker.r, Config.PoundMarker.g, Config.PoundMarker.b, 100, false, true, 2, false, false, false, false)
					end
				end
			end

			if Config.UsePrivateCarGarages then
				for _,v in pairs(Config.PrivateCarGarages) do
					if not v.Private or has_value(userProperties, v.Private) then
						if #(coords - vec3(v.GaragePoint.x, v.GaragePoint.y, v.GaragePoint.z)) < Config.DrawDistance then
							sleep = 0
							---@diagnostic disable-next-line: param-type-mismatch
							DrawMarker(Config.MarkerType, v.GaragePoint.x, v.GaragePoint.y, v.GaragePoint.z, 0.0, 0.0, 0.0, 270.0, 0.0, 0.0, Config.PointMarker.x, Config.PointMarker.y, Config.PointMarker.z, Config.PointMarker.r, Config.PointMarker.g, Config.PointMarker.b, 100, false, true, 2, false, false, false, false)
							---@diagnostic disable-next-line: param-type-mismatch
							DrawMarker(Config.MarkerType, v.DeletePoint.x, v.DeletePoint.y, v.DeletePoint.z, 0.0, 0.0, 0.0, 270.0, 0.0, 0.0, Config.DeleteMarker.x, Config.DeleteMarker.y, Config.DeleteMarker.z, Config.DeleteMarker.r, Config.DeleteMarker.g, Config.DeleteMarker.b, 100, false, true, 2, false, false, false, false)
						end
					end
				end
			end

			if Config.UseJobCarGarages then
				local job = ESX.PlayerData.job
				local jobname = job.name
				if job and jobname == 'police' then
					for i=1, #Config.PolicePounds do
						local v = Config.PolicePounds[i]
						if #(coords - vec3(v.PoundPoint.x, v.PoundPoint.y, v.PoundPoint.z)) < Config.DrawDistance then
							sleep = 0
							---@diagnostic disable-next-line: param-type-mismatch
							DrawMarker(Config.MarkerType, v.PoundPoint.x, v.PoundPoint.y, v.PoundPoint.z, 0.0, 0.0, 0.0, 270.0, 0.0, 0.0, Config.JobPoundMarker.x, Config.JobPoundMarker.y, Config.JobPoundMarker.z, Config.JobPoundMarker.r, Config.JobPoundMarker.g, Config.JobPoundMarker.b, 100, false, true, 2, false, false, false, false)
						end
					end
				end

				if job and jobname == 'taxi' then
					for i=1, #Config.TaxiPounds do
						local v = Config.TaxiPounds[i]
						if #(coords - vec3(v.PoundPoint.x, v.PoundPoint.y, v.PoundPoint.z)) < Config.DrawDistance then
							sleep = 0
							---@diagnostic disable-next-line: param-type-mismatch
							DrawMarker(Config.MarkerType, v.PoundPoint.x, v.PoundPoint.y, v.PoundPoint.z, 0.0, 0.0, 0.0, 270.0, 0.0, 0.0, Config.JobPoundMarker.x, Config.JobPoundMarker.y, Config.JobPoundMarker.z, Config.JobPoundMarker.r, Config.JobPoundMarker.g, Config.JobPoundMarker.b, 100, false, true, 2, false, false, false, false)
						end
					end
				end

				if job and jobname == 'sheriff' then
					for i=1, #Config.SheriffPounds do
						local v = Config.SheriffPounds[i]
						if #(coords - vec3(v.PoundPoint.x, v.PoundPoint.y, v.PoundPoint.z)) < Config.DrawDistance then
							sleep = 0
							---@diagnostic disable-next-line: param-type-mismatch
							DrawMarker(Config.MarkerType, v.PoundPoint.x, v.PoundPoint.y, v.PoundPoint.z, 0.0, 0.0, 0.0, 270.0, 0.0, 0.0, Config.JobPoundMarker.x, Config.JobPoundMarker.y, Config.JobPoundMarker.z, Config.JobPoundMarker.r, Config.JobPoundMarker.g, Config.JobPoundMarker.b, 100, false, true, 2, false, false, false, false)
						end
					end
				end

				if job and jobname == 'ambulance' then
					for i=1, #Config.AmbulancePounds do
						local v = Config.AmbulancePounds[i]
						if #(coords - vec3(v.PoundPoint.x, v.PoundPoint.y, v.PoundPoint.z)) < Config.DrawDistance then
							sleep = 0
							---@diagnostic disable-next-line: param-type-mismatch
							DrawMarker(Config.MarkerType, v.PoundPoint.x, v.PoundPoint.y, v.PoundPoint.z, 0.0, 0.0, 0.0, 270.0, 0.0, 0.0, Config.JobPoundMarker.x, Config.JobPoundMarker.y, Config.JobPoundMarker.z, Config.JobPoundMarker.r, Config.JobPoundMarker.g, Config.JobPoundMarker.b, 100, false, true, 2, false, false, false, false)
						end
					end
				end
			end
			Wait(sleep)
		end
	end)
end

RegisterNetEvent('esx_advancedgarage:getPropertiesC')
AddEventHandler('esx_advancedgarage:getPropertiesC', function()
	if Config.UsePrivateCarGarages then
		ESX.TriggerServerCallback('esx_advancedgarage:getOwnedProperties', function(properties)
			userProperties = properties
			privateGarageBlips()
		end)

		ESX.ShowNotification(_U('get_properties'))
		TriggerServerEvent('esx_advancedgarage:printGetProperties')
	end
end)

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

AddEventHandler('onResourceStart', function(resourceName)
	if (GetCurrentResourceName() ~= resourceName) then
	  return
	end
	drawMarkers()
	activateMenus()
	Wait(1000)
	refreshBlips()
end)

-- Exited Marker
AddEventHandler('esx_advancedgarage:hasExitedMarker', function()
    ESX.UI.Menu.CloseAll()
    if DoesEntityExist(cachedData.vehicle) then
        DeleteEntity(cachedData.vehicle)
    end
    lib.hideMenu(true)
    stopmove = false
    currentAction = nil
end)
