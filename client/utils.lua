local stopmove = false

stopmov = function()
    CreateThread(function()
        print("stop")
        while stopmove do
	   	DisableControlAction(0, Keys['W'], true) -- W
		DisableControlAction(0, Keys['A'], true) -- A
		DisableControlAction(0, 31, true) -- S (fault in Keys table!)
		DisableControlAction(0, 30, true) -- D (fault in Keys table!)
		DisableControlAction(0, Keys['A'], true) -- Disable Moving
		DisableControlAction(0, Keys['D'], true) -- Disable Moving
		DisableControlAction(0, 59, true) -- Disable steering in vehicle
		DisableControlAction(0, Keys['LEFTCTRL'], true) -- Disable going stealth
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
                Wait(3)
        end
   end)
end

HandleCamera = function(garage, toggle)
    local Camerapos = Config.Garages[garage]["camera"]

    if not Camerapos then return end

	if not toggle then
		if cachedData["cam"] then
			DestroyCam(cachedData["cam"])
		end
		
		if DoesEntityExist(cachedData["vehicle"]) then
			DeleteEntity(cachedData["vehicle"])
		end

		RenderScriptCams(0, 1, 750, 1, 0)

		return
	end

	if cachedData["cam"] then
		DestroyCam(cachedData["cam"])
	end

	cachedData["cam"] = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)

	SetCamCoord(cachedData["cam"], Camerapos["x"], Camerapos["y"], Camerapos["z"])
	SetCamRot(cachedData["cam"], Camerapos["rotationX"], Camerapos["rotationY"], Camerapos["rotationZ"])
	SetCamActive(cachedData["cam"], true)

	RenderScriptCams(1, 1, 750, 1, 1)

	Citizen.Wait(500)
end

OpenGarageMenu = function()
    ESX.UI.Menu.CloseAll()
    local currentGarage = cachedData["currentGarage"]

    if not currentGarage then return end

    HandleCamera(currentGarage, true)

    ESX.TriggerServerCallback("garage:fetchPlayerVehicles", function(fetchedVehicles)
        local menuElements = {}

        for key, vehicleData in pairs(fetchedVehicles) do
            local vehicleProps = vehicleData["props"]
            local plate        = vehicleData["plate"]

            table.insert(menuElements, {
                ["label"] = "" .. GetDisplayNameFromVehicleModel(vehicleProps["model"]) .. " Rendszám: - " .. vehicleData["plate"],
                ["vehicle"] = vehicleData
            })
        end

        if #menuElements == 0 then
            table.insert(menuElements, {
                ["label"] = "Ide nem parkoltál semmit."
            })
        elseif #menuElements > 0 then
            SpawnLocalVehicle(menuElements[1]["vehicle"]["props"], currentGarage)
        end
            stopmove = true
            stopmov()
        ESX.UI.Menu.Open("default", GetCurrentResourceName(), "main_garage_menu", {
            ["title"] = "Garage - " .. currentGarage,
            ["align"] = Config.AlignMenu,
            ["elements"] = menuElements
        }, function(menuData, menuHandle)
                
            local currentVehicle = menuData["current"]["vehicle"]

            if currentVehicle then
                menuHandle.close()
                stopmove = false
                SpawnVehicl(currentVehicle["props"])
            end
        end, function(menuData, menuHandle)
            HandleCamera(currentGarage, false)
            stopmove = false
            menuHandle.close()
        end, function(menuData, menuHandle)
            local currentVehicle = menuData["current"]["vehicle"]

            if currentVehicle then
                stopmove = false
                SpawnLocalVehicle(currentVehicle["props"])
            end
        end)
    end, currentGarage)
end


DrawScriptMarker = function(markerData)
    DrawMarker(markerData["type"] or 1, 
        markerData["pos"] or vector3(0.0, 0.0, 0.0), 
        0.0, 0.0, 0.0, 
        (markerData["type"] == 6 and -90.0 or markerData["rotate"] and -180.0) or 0.0, 0.0, 0.0, 
        markerData["sizeX"] or 1.0, 
        markerData["sizeY"] or 1.0, 
        markerData["sizeZ"] or 1.0, 
        markerData["r"] or 1.0, 
        markerData["g"] or 1.0, 
        markerData["b"] or 1.0, 
        100, false, true, 2, false, false, false, false)
end

SpawnVehicl = function(vehicleProps)
	local spawnpoint = Config.Garages[cachedData["currentGarage"]]["positions"]["fospawn"]

	WaitForModel(vehicleProps["model"])

	if DoesEntityExist(cachedData["vehicle"]) then
		DeleteEntity(cachedData["vehicle"])
	end
	
	if not ESX.Game.IsSpawnPointClear(spawnpoint["position"], 3.0) then 
		ESX.ShowNotification("Kérjük, mozgassa az útban lévő járművet.")
		return HandleCamera(cachedData["currentGarage"])
	end
	
	local gameVehicles = ESX.Game.GetVehicles()

	for i = 1, #gameVehicles do
		local vehicle = gameVehicles[i]

        if DoesEntityExist(fospawn) then
			if Config.Trim(GetVehicleNumberPlateText(fospawn)) == Config.Trim(vehicleProps["plate"]) then
				ESX.ShowNotification("Ez a jármű az utcán van, ugyanabból a járműből kettőt nem lehet kivenni.")

				return HandleCamera(cachedData["currentGarage"])
			end
		end
	end

	ESX.Game.SpawnVehicle(vehicleProps["model"], spawnpoint["position"], spawnpoint["heading"], function(yourVehicle)
		SetVehicleProperties(yourVehicle, vehicleProps)

        NetworkFadeInEntity(yourVehicle, true, true)

	SetModelAsNoLongerNeeded(vehicleProps["model"])

	TaskWarpPedIntoVehicle(ESX.PlayerData.ped, yourVehicle, -1)
 
        --ESX.ShowNotification("You spawned your vehicle.")

        HandleCamera(cachedData["currentGarage"])
	end)

        TriggerServerEvent("garage:takecar", vehicleProps["plate"], false)
    --TriggerServerEvent('esx_advancedgarage:setVehicleState', plate, false)
end

PutInVehicle = function()
    local vehicle = GetVehiclePedIsUsing(ESX.PlayerData.ped)

	if DoesEntityExist(vehicle) then
		local vehicleProps = GetVehicleProperties(vehicle)

		ESX.TriggerServerCallback("garage:validateVehicle", function(valid)
			if valid then
				TaskLeaveVehicle(ESX.PlayerData.ped, vehicle, 0)
	
				while IsPedInVehicle(ESX.PlayerData.ped, vehicle, true) do
					Wait(0)
				end
	
				Wait(500)
	
				NetworkFadeOutEntity(vehicle, true, true)
	
				Citizen.Wait(100)
	
				ESX.Game.DeleteVehicle(vehicle)

			--	ESX.ShowNotification("Leparkoltál.")
			else
				ESX.ShowNotification("Ez nem a te jármüved!")
			end

		end, vehicleProps, cachedData["currentGarage"])
	end
end

SetVehicleProperties = function(vehicle, vehicleProps)
    ESX.Game.SetVehicleProperties(vehicle, vehicleProps)
    --SetVehicleEngineHealth(vehicle, vehicleProps["engineHealth"] and vehicleProps["engineHealth"] + 0.0 or 1000.0)
    --SetVehicleBodyHealth(vehicle, vehicleProps["bodyHealth"] and vehicleProps["bodyHealth"] + 0.0 or 1000.0)
end

GetVehicleProperties = function(vehicle)
    if DoesEntityExist(vehicle) then
        local vehicleProps = ESX.Game.GetVehicleProperties(vehicle)
        if vehicleProps["fuelLevel"] == nil then
           print("Fuel: nil")
        else
           print("Fuel:" ..vehicleProps["fuelLevel"])
        end
        vehicleProps["engineHealth"] = GetVehicleEngineHealth(vehicle)
        vehicleProps["bodyHealth"] = GetVehicleBodyHealth(vehicle)

        return vehicleProps
    end
end

SpawnLocalVehicle = function(vehicleProps)
	local spawnpoint = Config.Garages[cachedData["currentGarage"]]["positions"]["spawn"]
	WaitForModel(vehicleProps["model"])

	if DoesEntityExist(cachedData["vehicle"]) then
		DeleteEntity(cachedData["vehicle"])
	end
	while DoesEntityExist(cachedData["vehicle"]) do
                Wait(10)
		DeleteEntity(cachedData["vehicle"])
	end
	
	if not ESX.Game.IsSpawnPointClear(spawnpoint["position"], 3.0) then
	       ESX.ShowNotification("Kérjük, mozgassa az útban lévö jármüvet.")

	       return
        end
	
	if not IsModelValid(vehicleProps["model"]) then
		return
	end

	ESX.Game.SpawnLocalVehicle(vehicleProps["model"], spawnpoint["position"], spawnpoint["heading"], function(yourVehicle)
	if DoesEntityExist(cachedData["vehicle"]) then
		DeleteEntity(cachedData["vehicle"])
	end
		cachedData["vehicle"] = yourVehicle

		SetVehicleProperties(yourVehicle, vehicleProps)

		SetModelAsNoLongerNeeded(vehicleProps["model"])
	end)
end

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
		Citizen.Wait(0)

		DrawScreenText("Loading model " .. GetLabelText(GetDisplayNameFromVehicleModel(model)) .. "...", 255, 255, 255, 150)
	end
end

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

            EndTextCommandSetBlipName(carBlips[entity])

        end

    end

end

HandleAction = function(action)
    if action == "menu" then
        OpenGarageMenu()
    elseif action == "vehicle" then
        PutInVehicle()
    end
end
