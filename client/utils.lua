local stopmove = false

stopmov = function()
    CreateThread(function()
        while stopmove do
	   	--DisableControlAction(0, Keys['W'], true) -- W
		--DisableControlAction(0, Keys['A'], true) -- A
		DisableControlAction(0, 31, true) -- S (fault in Keys table!)
		DisableControlAction(0, 30, true) -- D (fault in Keys table!)
		--DisableControlAction(0, Keys['A'], true) -- Disable Moving
		--DisableControlAction(0, Keys['D'], true) -- Disable Moving
		DisableControlAction(0, 59, true) -- Disable steering in vehicle
		--DisableControlAction(0, Keys['LEFTCTRL'], true) -- Disable going stealth
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

---Garage camera
---@param cam vector3
---@param camrot vector3
---@param toggle boolean
HandleCamera = function(cam, camrot, toggle)
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

---Open main garage
---@param x vector4
---@param z vector3
---@param zy vector3
OpenGarageMenu = function(x, z, zy)
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
                ["label"] = "Ide nem parkoltál semmit."
            }
        elseif #menuElements > 0 then
            SpawnLocalVehicle(menuElements[1], x)
        end
            stopmove = true
            stopmov()
        ESX.UI.Menu.Open("default", GetCurrentResourceName(), "main_garage_menu", {
            ["title"] = "Garage - " .. currentGarage,
            ["align"] = Config.AlignMenu,
            ["elements"] = menuElements
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

---Spawn vehicles
---@param vehicleProps table
---@param pos vector4
---@param z vector3
---@param zy vector3
---@return nil
SpawnVeh = function(vehicleProps, pos, z, zy)
	local spawnpoint = pos

	WaitForModel(vehicleProps.vehicle.model)

	if DoesEntityExist(cachedData.vehicle) then
		DeleteEntity(cachedData.vehicle)
	end

	if not ESX.Game.IsSpawnPointClear(spawnpoint, 3.0) then
		ESX.ShowNotification("Kérjük, mozgassa az útban lévö járművet.")
		return HandleCamera(z, zy, false)
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

	ESX.Game.SpawnVehicle(vehicleProps.vehicle.model, spawnpoint, spawnpoint.w, function(yourVehicle)
	    SetVehicleProperties(yourVehicle, vehicleProps.vehicle)
        NetworkFadeInEntity(yourVehicle, true, true)
	    SetModelAsNoLongerNeeded(vehicleProps.vehicle.model)
	    TaskWarpPedIntoVehicle(ESX.PlayerData.ped, yourVehicle, -1)
        --if gps then
            ToggleBlip(yourVehicle)
        --end
        HandleCamera(z, zy, false)
	end)
    TriggerServerEvent("esx_advancedgarage:takecar", vehicleProps.vehicle.plate, 0)
end

PutInVehicle = function()
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
---@param vehicle number
---@param vehicleProps table
SetVehicleProperties = function(vehicle, vehicleProps)
    ESX.Game.SetVehicleProperties(vehicle, vehicleProps)
end

---Getting vehicle properties
---@param vehicle number
---@return table?
GetVehicleProperties = function(vehicle)
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

---Spawn local vehicle
---@param vehicleProps table
---@param pos vector4
SpawnLocalVehicle = function(vehicleProps, pos)
	WaitForModel(vehicleProps.vehicle.model)

	if DoesEntityExist(cachedData.vehicle) then
		DeleteEntity(cachedData.vehicle)
	end
	while DoesEntityExist(cachedData.vehicle) do
        Wait(10)
	    DeleteEntity(cachedData.vehicle)
	end

	if not ESX.Game.IsSpawnPointClear(pos, 3.0) then
	    ESX.ShowNotification("Kérjük, mozgassa az útban lévö jármüvet.")
	    return
    end

	if not IsModelValid(vehicleProps.vehicle.model) then
		return
	end

	ESX.Game.SpawnLocalVehicle(vehicleProps.vehicle.model, pos, pos.w, function(yourVehicle)
	if DoesEntityExist(cachedData.vehicle) then
		DeleteEntity(cachedData.vehicle)
	end
		cachedData.vehicle = yourVehicle

		SetVehicleProperties(yourVehicle, vehicleProps.vehicle)

		SetModelAsNoLongerNeeded(vehicleProps.vehicle.model)
	end)
end

---Wait for vehicle model
---@param model number
---@return string?
WaitForModel = function(model)
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
ToggleBlip = function(entity)
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
