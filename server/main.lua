---@diagnostic disable undefined-global

local function parkVehicles()
	MySQL.update('UPDATE `owned_vehicles` SET `stored` = ? WHERE `stored` = ?', {1, 0}, function(rowsChanged)
		if rowsChanged > 0 then
			print(('esx_advancedgarage: %s vehicle(s) have been stored!'):format(rowsChanged))
		end
	end)
end

---Make sure all Vehicles are Stored on restart
if Config.Parkvehicles then
    MySQL.ready(function()
	    parkVehicles()
    end)
end

---Logging
---@param webhook string
---@param color number
---@param name string
---@param message string
---@param footer string?
local function sendToDiscord(webhook, color, name, message, footer)
	local embed = {
		  {
			  ["color"] = color,
			  ["title"] = "**".. name .."**",
			  ["description"] = message,
			  ["footer"] = {
				  ["text"] = footer,
			  },
		  }
	  }
	PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', json.encode({username = name, embeds = embed}), { ['Content-Type'] = 'application/json' })
end

---Add Command for Getting Properties
if Config.UseCommand then
	ESX.RegisterCommand('getgarages', 'user', function(xPlayer, args, showError)
		xPlayer.triggerEvent('esx_advancedgarage:getPropertiesC')
	end, true, {help = 'Get Private Garages', validate = false})
end

---Add Print Command for Getting Properties
RegisterNetEvent('esx_advancedgarage:printGetProperties')
AddEventHandler('esx_advancedgarage:printGetProperties', function()
	if Config.Debug then
        print('Getting Properties')
	end
end)

---Get Owned Properties
---@param source number
---@param cb function
ESX.RegisterServerCallback('esx_advancedgarage:getOwnedProperties', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	local properties = {}

	MySQL.rawExecute('SELECT * FROM `owned_properties` WHERE `owner` = ?', {xPlayer.identifier}, function(data)
		for i = 1, #data do
			local name = data[i].name
			properties[#properties+1] = name
		end
		cb(properties)
	end)
end)

---Start of Ambulance Code
---@param source number
---@param cb function
ESX.RegisterServerCallback('esx_advancedgarage:getOwnedAmbulanceCars', function(source, cb)
	local ownedAmbulanceCars = {}
	local xPlayer = ESX.GetPlayerFromId(source)

	if Config.ShowVehicleLocation then
		MySQL.rawExecute('SELECT * FROM `owned_vehicles` WHERE `owner` = ? AND `type` = ? AND `job` = ?', {xPlayer.identifier, 'car', 'ambulance'}, function(data)
			for i = 1, #data do
				local vehicle = json.decode(data[i].vehicle)
				local stored = data[i].stored
				ownedAmbulanceCars[#ownedAmbulanceCars+1] = {vehicle = vehicle, stored = stored}
			end
			cb(ownedAmbulanceCars)
		end)
	else
		MySQL.rawExecute('SELECT * FROM `owned_vehicles` WHERE `owner` = ? AND `type` = ? AND `job` = ? AND `stored` = ?', {xPlayer.identifier, 'car', 'ambulance', 1}, function(data)
			for i = 1, #data do
				local vehicle = json.decode(data[i].vehicle)
				ownedAmbulanceCars[#ownedAmbulanceCars+1] = vehicle
			end
			cb(ownedAmbulanceCars)
		end)
	end
end)

ESX.RegisterServerCallback('esx_advancedgarage:getOwnedAmbulanceAircrafts', function(source, cb)
	local ownedAmbulanceAircrafts = {}
	local xPlayer = ESX.GetPlayerFromId(source)

	if Config.ShowVehicleLocation then
		MySQL.rawExecute('SELECT * FROM `owned_vehicles` WHERE `owner` = ? AND `type` = ? AND `job` = ?', {xPlayer.identifier, 'helicopter', 'ambulance'}, function(data)
			for i = 1, #data do
				local vehicle = json.decode(data[i].vehicle)
				local stored = data[i].stored
				ownedAmbulanceAircrafts[#ownedAmbulanceAircrafts+1] = {vehicle = vehicle, stored = stored}
			end
			cb(ownedAmbulanceAircrafts)
		end)
	else
		MySQL.rawExecute('SELECT * FROM `owned_vehicles` WHERE `owner` = ? AND `type` = ? AND `job` = ? AND `stored` = ?', {xPlayer.identifier, 'helicopter', 'ambulance', 1}, function(data)
			for i = 1, #data do
				local vehicle = json.decode(data[i].vehicle)
				ownedAmbulanceAircrafts[#ownedAmbulanceAircrafts+1] = vehicle
			end
			cb(ownedAmbulanceAircrafts)
		end)
	end
end)

ESX.RegisterServerCallback('esx_advancedgarage:getOutOwnedAmbulanceCars', function(source, cb)
	local ownedAmbulanceCars = {}
	local xPlayer = ESX.GetPlayerFromId(source)

	MySQL.rawExecute('SELECT * FROM `owned_vehicles` WHERE `owner` = ? AND `job` = ? AND `stored` = ?', {xPlayer.identifier, 'ambulance', 0}, function(data)
		for i = 1, #data do
			local vehicle = json.decode(data[i].vehicle)
			ownedAmbulanceCars[#ownedAmbulanceCars+1] = vehicle
		end
		cb(ownedAmbulanceCars)
	end)
end)

ESX.RegisterServerCallback('esx_advancedgarage:checkMoneyAmbulance', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	if xPlayer.getMoney() >= Config.AmbulancePoundPrice then
		cb(true)
	else
		cb(false)
	end
end)

RegisterNetEvent('esx_advancedgarage:payAmbulance')
AddEventHandler('esx_advancedgarage:payAmbulance', function()
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeMoney(Config.AmbulancePoundPrice)
	TriggerClientEvent('esx:showNotification', source, _U('you_paid') .. Config.AmbulancePoundPrice)

	if Config.GiveSocietyMoney then
		TriggerEvent('esx_addonaccount:getSharedAccount', 'society_mechanic', function(account)
			account.addMoney(Config.AmbulancePoundPrice)
		end)
	end
end)
-- End of Ambulance Code

-- Start of Police Code
ESX.RegisterServerCallback('esx_advancedgarage:getOwnedPoliceCars', function(source, cb)
	local ownedPoliceCars = {}
	local xPlayer = ESX.GetPlayerFromId(source)

	if Config.ShowVehicleLocation then
		MySQL.rawExecute('SELECT * FROM `owned_vehicles` WHERE `owner` = ? AND `type` = ? AND `job` = ?', {xPlayer.identifier, 'car', 'police'}, function(data)
			for i = 1, #data do
				local vehicle = json.decode(data[i].vehicle)
				local stored = data[i].stored
				ownedPoliceCars[#ownedPoliceCars+1] = {vehicle = vehicle, stored = stored}
			end
			cb(ownedPoliceCars)
		end)
	else
		MySQL.rawExecute('SELECT * FROM `owned_vehicles` WHERE `owner` = ? AND `type` = ? AND `job` = ? AND `stored` = ?', {xPlayer.identifier, 'car', 'police', 1}, function(data)
			for i = 1, #data do
				local vehicle = json.decode(data[i].vehicle)
				ownedPoliceCars[#ownedPoliceCars+1] = vehicle
			end
			cb(ownedPoliceCars)
		end)
	end
end)

ESX.RegisterServerCallback('esx_advancedgarage:getOwnedSheriffCars', function(source, cb)
	local ownedSheriffCars = {}
	local xPlayer = ESX.GetPlayerFromId(source)

	if Config.ShowVehicleLocation then
		MySQL.rawExecute('SELECT * FROM `owned_vehicles` WHERE `owner` = ? AND `type` = ? AND `job` = ?', {xPlayer.identifier, 'car', 'sheriff'}, function(data)
			for i = 1, #data do
				local vehicle = json.decode(data[i].vehicle)
				local stored = data[i].stored
				ownedSheriffCars[#ownedSheriffCars+1] = {vehicle = vehicle, stored = stored}
			end
			cb(ownedSheriffCars)
		end)
	else
		MySQL.rawExecute('SELECT * FROM `owned_vehicles` WHERE `owner` = ? AND `type` = ? AND `job` = ? AND `stored` = ?', {xPlayer.identifier, 'car', 'sheriff', 1}, function(data)
			for i = 1, #data do
				local vehicle = json.decode(data[i].vehicle)
				ownedSheriffCars[#ownedSheriffCars+1] = vehicle
			end
			cb(ownedSheriffCars)
		end)
	end
end)

ESX.RegisterServerCallback('esx_advancedgarage:getOwnedPoliceAircrafts', function(source, cb)
	local ownedPoliceAircrafts = {}
	local xPlayer = ESX.GetPlayerFromId(source)

	if Config.ShowVehicleLocation then
		MySQL.rawExecute('SELECT * FROM `owned_vehicles` WHERE `owner` = ? AND `type` = ? AND `job` = ?', {xPlayer.identifier, 'helicopter', 'police'}, function(data)
			for i = 1, #data do
				local vehicle = json.decode(data[i].vehicle)
				local stored = data[i].stored
				ownedPoliceAircrafts[#ownedPoliceAircrafts+1] = {vehicle = vehicle, stored = stored}
			end
			cb(ownedPoliceAircrafts)
		end)
	else
		MySQL.rawExecute('SELECT * FROM `owned_vehicles` WHERE `owner` = ? AND `type` = ? AND `job` = ? AND `stored` = ?', {xPlayer.identifier, 'helicopter', 'police', 1}, function(data)
			for i = 1, #data do
				local vehicle = json.decode(data[i].vehicle)
				ownedPoliceAircrafts[#ownedPoliceAircrafts+1] = vehicle
			end
			cb(ownedPoliceAircrafts)
		end)
	end
end)

ESX.RegisterServerCallback('esx_advancedgarage:getOutOwnedPoliceCars', function(source, cb)
	local ownedPoliceCars = {}
	local xPlayer = ESX.GetPlayerFromId(source)

	MySQL.rawExecute('SELECT * FROM `owned_vehicles` WHERE `owner` = ? AND `job` = ? AND `stored` = ?', {xPlayer.identifier, 'police', 0}, function(data)
		for i = 1, #data do
			local vehicle = json.decode(data[i].vehicle)
			ownedPoliceCars[#ownedPoliceCars+1] = vehicle
		end
		cb(ownedPoliceCars)
	end)
end)

ESX.RegisterServerCallback('esx_advancedgarage:getOutOwnedTaxiCars', function(source, cb)
	local ownedTaxiCars = {}
	local xPlayer = ESX.GetPlayerFromId(source)

	MySQL.rawExecute('SELECT * FROM `owned_vehicles` WHERE `owner` = ? AND `job` = ? AND `stored` = ?', {xPlayer.identifier, 'taxi', 0}, function(data)
		for i = 1, #data do
			local vehicle = json.decode(data[i].vehicle)
			ownedTaxiCars[#ownedTaxiCars+1] = vehicle
		end
		cb(ownedTaxiCars)
	end)
end)

ESX.RegisterServerCallback('esx_advancedgarage:getOutOwnedSheriffCars', function(source, cb)
	local ownedSheriffCars = {}
	local xPlayer = ESX.GetPlayerFromId(source)

	MySQL.rawExecute('SELECT * FROM `owned_vehicles` WHERE `owner` = ? AND `job` = ? AND `stored` = ?', {xPlayer.identifier, 'sheriff', 0}, function(data)
		for i = 1, #data do
			local vehicle = json.decode(data[i].vehicle)
			ownedSheriffCars[#ownedSheriffCars+1] = vehicle
		end
		cb(ownedSheriffCars)
	end)
end)

ESX.RegisterServerCallback('esx_advancedgarage:checkMoneyPolice', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	if xPlayer.getMoney() >= Config.PolicePoundPrice then
		cb(true)
	else
		cb(false)
	end
end)

ESX.RegisterServerCallback('esx_advancedgarage:checkMoneyTaxi', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	if xPlayer.getMoney() >= Config.TaxiPoundPrice then
		cb(true)
	else
		cb(false)
	end
end)

ESX.RegisterServerCallback('esx_advancedgarage:checkMoneySheriff', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	if xPlayer.getMoney() >= Config.SheriffPoundPrice then
		cb(true)
	else
		cb(false)
	end
end)

RegisterNetEvent('esx_advancedgarage:payTaxi')
AddEventHandler('esx_advancedgarage:payTaxi', function()
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeMoney(Config.TaxiPoundPrice)
	TriggerClientEvent('esx:showNotification', source, _U('you_paid') .. Config.TaxiPoundPrice)

	if Config.GiveSocietyMoney then
		TriggerEvent('esx_addonaccount:getSharedAccount', 'society_mechanic', function(account)
			account.addMoney(Config.TaxiPoundPrice)
		end)
	end
end)

RegisterNetEvent('esx_advancedgarage:payPolice')
AddEventHandler('esx_advancedgarage:payPolice', function()
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeMoney(Config.PolicePoundPrice)
	TriggerClientEvent('esx:showNotification', source, _U('you_paid') .. Config.PolicePoundPrice)

	if Config.GiveSocietyMoney then
		TriggerEvent('esx_addonaccount:getSharedAccount', 'society_mechanic', function(account)
			account.addMoney(Config.PolicePoundPrice)
		end)
	end
end)

RegisterNetEvent('esx_advancedgarage:paySheriff')
AddEventHandler('esx_advancedgarage:paySheriff', function()
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeMoney(Config.SheriffPoundPrice)
	TriggerClientEvent('esx:showNotification', source, _U('you_paid') .. Config.SheriffPoundPrice)

	if Config.GiveSocietyMoney then
		TriggerEvent('esx_addonaccount:getSharedAccount', 'society_mechanic', function(account)
			account.addMoney(Config.SheriffPoundPrice)
		end)
	end
end)
-- End of Police Code

-- Start of Aircraft Code
ESX.RegisterServerCallback('esx_advancedgarage:getOwnedAircrafts', function(source, cb)
	local start = os.nanotime()
	local ownedAircrafts = {}
	local xPlayer = ESX.GetPlayerFromId(source)

	if Config.ShowVehicleLocation then
		MySQL.rawExecute('SELECT * FROM `owned_vehicles` WHERE `owner` = ? AND `type` = ? AND `job` = ?', {xPlayer.identifier, 'jet', 'civ'}, function(data)
			for i = 1, #data do
				local vehicle = json.decode(data[i].vehicle)
				local stored = data[i].stored
				ownedAircrafts[#ownedAircrafts+1] = {vehicle = vehicle, stored = stored}
			end
			if Config.Debug then
				print(('Fetch aircrafts (%.4f ms)'):format((os.nanotime() - start) / 1e6))
			end
			cb(ownedAircrafts)
		end)
	else
		MySQL.rawExecute('SELECT * FROM `owned_vehicles` WHERE `owner` = ? AND `type` = ? AND `job` = ? AND `stored` = ?', {xPlayer.identifier, 'jet', 'civ', 1}, function(data)
			for i = 1, #data do
				local vehicle = json.decode(data[i].vehicle)
				ownedAircrafts[#ownedAircrafts+1] = vehicle
			end
			if Config.Debug then
				print(('Fetch aircrafts (%.4f ms)'):format((os.nanotime() - start) / 1e6))
			end
			cb(ownedAircrafts)
		end)
	end
end)

ESX.RegisterServerCallback('esx_advancedgarage:getOutOwnedAircrafts', function(source, cb)
	local ownedAircrafts = {}
	local xPlayer = ESX.GetPlayerFromId(source)

	MySQL.rawExecute('SELECT * FROM `owned_vehicles` WHERE `owner` = ? AND `type` = ? AND `stored` = ?', {xPlayer.identifier, 'jet', 0}, function(data)
		for i = 1, #data do
			local vehicle = json.decode(data[i].vehicle)
			ownedAircrafts[#ownedAircrafts+1] = vehicle
		end
		cb(ownedAircrafts)
	end)
end)

ESX.RegisterServerCallback('esx_advancedgarage:checkMoneyAircrafts', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	if xPlayer.getMoney() >= Config.AircraftPoundPrice then
		cb(true)
	else
		cb(false)
	end
end)

RegisterNetEvent('esx_advancedgarage:payAircraft')
AddEventHandler('esx_advancedgarage:payAircraft', function()
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeMoney(Config.AircraftPoundPrice)
	TriggerClientEvent('esx:showNotification', source, _U('you_paid') .. Config.AircraftPoundPrice)

	if Config.GiveSocietyMoney then
		TriggerEvent('esx_addonaccount:getSharedAccount', 'society_mechanic', function(account)
			account.addMoney(Config.AircraftPoundPrice)
		end)
	end
end)
-- End of Aircraft Code

---Start of Boat Code
---@param source number
---@param cb function
ESX.RegisterServerCallback('esx_advancedgarage:getOwnedBoats', function(source, cb)
	local start = os.nanotime()
	local ownedBoats = {}
	local xPlayer = ESX.GetPlayerFromId(source)

	if Config.ShowVehicleLocation then
		MySQL.rawExecute('SELECT * FROM `owned_vehicles` WHERE `owner` = ? AND `type` = ? AND `job` = ?', {xPlayer.identifier, 'boat', 'civ'}, function(data)
			for i = 1, #data do
				local vehicle = json.decode(data[i].vehicle)
				local stored = data[i].stored
				ownedBoats[#ownedBoats+1] = {vehicle = vehicle, stored = stored}
			end
			if Config.Debug then
				print(('Fetch boats (%.4f ms)'):format((os.nanotime() - start) / 1e6))
			end
			cb(ownedBoats)
		end)
	else
		MySQL.rawExecute('SELECT * FROM `owned_vehicles` WHERE `owner` = ? AND `type` = ? AND `job` = ? AND `stored` = ?', {xPlayer.identifier, 'boat', 'civ', 1}, function(data)
			for i = 1, #data do
				local vehicle = json.decode(data[i].vehicle)
				ownedBoats[#ownedBoats+1] = vehicle
			end
			if Config.Debug then
				print(('Fetch boats (%.4f ms)'):format((os.nanotime() - start) / 1e6))
			end
			cb(ownedBoats)
		end)
	end
end)

---Fetch impounded boats
---@param source number
---@param cb function
ESX.RegisterServerCallback('esx_advancedgarage:getOutOwnedBoats', function(source, cb)
	local ownedBoats = {}
	local xPlayer = ESX.GetPlayerFromId(source)
	MySQL.rawExecute('SELECT * FROM `owned_vehicles` WHERE `owner` = ? AND `type` = ? AND `job` = ? AND `stored` = ?', {xPlayer.identifier, 'boat', 'civ', 0}, function(data)
		for i = 1, #data do
			local vehicle = json.decode(data[i].vehicle)
			ownedBoats[#ownedBoats+1] = vehicle
		end
		cb(ownedBoats)
	end)
end)

---Check money
---@param source number
---@param cb function
ESX.RegisterServerCallback('esx_advancedgarage:checkMoneyBoats', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	if xPlayer.getMoney() >= Config.BoatPoundPrice then
		cb(true)
	else
		cb(false)
	end
end)

RegisterNetEvent('esx_advancedgarage:payBoat')
AddEventHandler('esx_advancedgarage:payBoat', function()
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeMoney(Config.BoatPoundPrice)
	TriggerClientEvent('esx:showNotification', source, _U('you_paid') .. Config.BoatPoundPrice)

	if Config.GiveSocietyMoney then
		TriggerEvent('esx_addonaccount:getSharedAccount', 'society_mechanic', function(account)
			account.addMoney(Config.BoatPoundPrice)
		end)
	end
end)
-- End of Boat Codes

---Store vehicles
---@param source number
---@param cb function
---@param vehicleProps table
ESX.RegisterServerCallback('esx_advancedgarage:storeBoat', function (source, cb, vehicleProps)
	local xPlayer = ESX.GetPlayerFromId(source)
	MySQL.prepare('SELECT 1 FROM `owned_vehicles` WHERE `owner` = ? AND `plate` = ?', {xPlayer.identifier, vehicleProps.plate}, function(result)
		if result then
            cb(true)
        else
			print(('esx_advancedgarage: %s attempted to store an vehicle they don\'t own!'):format(xPlayer.identifier))
			cb(false)
		end
	end)
end)

---Store aircraft
---@param source number
---@param cb function
---@param vehicleProps table
ESX.RegisterServerCallback('esx_advancedgarage:storeAircraft', function (source, cb, vehicleProps)
	local xPlayer = ESX.GetPlayerFromId(source)
	MySQL.prepare('SELECT 1 FROM `owned_vehicles` WHERE `owner` = ? AND `type` = ? AND `job` = ? AND `plate` = ?', {xPlayer.identifier, 'jet', 'civ', vehicleProps.plate}, function (result)
		if result then
            cb(true)
        else
			print(('esx_advancedgarage: %s attempted to store an vehicle they don\'t own!'):format(xPlayer.identifier))
			cb(false)
		end
	end)
end)

-- Pay to Return Broken Vehicles
RegisterNetEvent('esx_advancedgarage:payhealth')
AddEventHandler('esx_advancedgarage:payhealth', function(price)
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeMoney(price)
	TriggerClientEvent('esx:showNotification', source, _U('you_paid') .. price)

	if Config.GiveSocietyMoney then
		TriggerEvent('esx_addonaccount:getSharedAccount', 'society_mechanic', function(account)
			account.addMoney(price)
		end)
	end
end)

local query = 'SELECT * FROM `owned_vehicles` WHERE `owner` = ? AND `type` = ? AND `garage` = ? AND `job` = ? AND `stored` = ?'
local query1 = 'UPDATE `owned_vehicles` SET `vehicle` = ?, `stored` = ?, `garage` = ? WHERE `plate` = ?'
local query2 = 'SELECT 1 FROM `owned_vehicles` WHERE `plate` = ? AND `job` = ? AND `type` = ? AND `owner` = ?'
local query3 = 'SELECT * FROM `owned_vehicles` WHERE `owner` = ? AND `type` = ? AND `stored` = ?'
local query4 = 'UPDATE `owned_vehicles` SET `stored` = ? WHERE `plate` = ?'
local query5 = 'UPDATE `owned_vehicles` SET `vehicle` = ?, `stored` = ? WHERE `plate` = ?'

-- Modify State of Vehicles
RegisterNetEvent('esx_advancedgarage:setVehicleState')
AddEventHandler('esx_advancedgarage:setVehicleState', function(plate, state)
	local start = os.nanotime()
	MySQL.prepare.await(query4, {tonumber(state), plate})
	if Config.Debug then
		print(('Set vehicle state (%.4f ms)'):format((os.nanotime() - start) / 1e6))
	end
end)

-- Modify State of Vehicles
RegisterNetEvent('esx_advancedgarage:setVehicleState2')
AddEventHandler('esx_advancedgarage:setVehicleState2', function(vehicleProps, state, plate)
	local start = os.nanotime()
	MySQL.prepare.await(query5, {json.encode(vehicleProps), tonumber(state), plate})
	if Config.Debug then
		print(('Set vehicle state with props (%.4f ms)'):format((os.nanotime() - start) / 1e6))
	end
end)

---Fetch player vehicles
---@param source number
---@param cb function
---@param garage string|number
ESX.RegisterServerCallback("esx_advancedgarage:fetchPlayerVehicles", function(source, cb, garage)
	local start = os.nanotime()
	local xPlayer = ESX.GetPlayerFromId(source)
    local identifier = xPlayer.identifier

	if xPlayer then
		MySQL.rawExecute(query, {identifier, 'car', garage, 'civ', 1}, function(result)
            if result then
				local Vehicles = {}
			    for i = 1, #result do
					local vehicle = json.decode(result[i].vehicle)
					Vehicles[#Vehicles+1] = vehicle
			    end
				if Config.Debug then
                    print(('Fetch vehicles (%.4f ms)'):format((os.nanotime() - start) / 1e6))
				end
			    cb(Vehicles)
            else
		        cb(false)
            end
		end)
	else
		cb(false)
	end
end)

---Save vehicles
---@param source number
---@param cb function
---@param vehicleProps table
---@param garage string|number
ESX.RegisterServerCallback("esx_advancedgarage:validateVehicle", function(source, cb, vehicleProps, garage)
	local start = os.nanotime()
	local xPlayer = ESX.GetPlayerFromId(source)
	local rendszam = vehicleProps.plate
	if xPlayer then
        MySQL.prepare(query2, {rendszam, 'civ', 'car', xPlayer.identifier}, function(result)
			if result then
                MySQL.prepare(query1, {json.encode(vehicleProps), 1, garage, rendszam})
				if Config.Debug then
                    print(('Saved vehicle (%.4f ms)'):format((os.nanotime() - start) / 1e6))
				end
				cb(true)
			else
				cb(false)
			end
        end)
	else
		cb(false)
	end
end)

RegisterNetEvent("esx_advancedgarage:takecar", function(plate, state)
	local start = os.nanotime()
	if Config.EnableLogs then
		local msg = GetPlayerName(source) .. " has taken out car " .. plate
		sendToDiscord(Config.GarageWebhook, Config.ColourInfo, Config.GarageName, msg, " ")
	end
    MySQL.prepare.await(query4, {state, plate})
	if Config.Debug then
		print(('Took out vehicle (%.4f ms)'):format((os.nanotime() - start) / 1e6))
	end
end)

---Fetch impounded Cars
---@param source number
---@param cb function
ESX.RegisterServerCallback("esx_advancedgarage:getOutOwnedCars", function(source, cb)
	local start = os.nanotime()
	local xPlayer = ESX.GetPlayerFromId(source)
	local ownedCars = {}

	MySQL.rawExecute(query3, {xPlayer.identifier, 'car', 0}, function(data)
		for i = 1, #data do
			local vehicle = json.decode(data[i].vehicle)
			ownedCars[#ownedCars+1] = vehicle
		end
		if Config.Debug then
			print(('Took out pounded vehicle (%.4f ms)'):format((os.nanotime() - start) / 1e6))
		end
		cb(ownedCars)
	end)
end)

---Check Money for impounded Cars
---@param source number
---@param cb function
ESX.RegisterServerCallback('esx_advancedgarage:checkMoneyCars', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	if xPlayer.getMoney() >= Config.CarPoundPrice then
		cb(true)
	else
		cb(false)
	end
end)

---Pay for Pounded Cars
RegisterNetEvent('esx_advancedgarage:payCar', function(plate)
	local xPlayer = ESX.GetPlayerFromId(source)
	if Config.EnableLogs then
		local msg = GetPlayerName(source) .. " has recovered " .. plate .. " from the impound "
		sendToDiscord(Config.ImpoundWebhook, Config.ColourInfo, Config.ImpoundName, msg, " ")
	end
	if Config.Debug then
		local msg = GetPlayerName(source) .. " has recovered " .. plate .. " from the impound "
		print(msg)
	end
	xPlayer.removeMoney(Config.CarPoundPrice)
	TriggerClientEvent('esx:showNotification', source, _U('you_paid') .. Config.CarPoundPrice)
	if Config.GiveSocietyMoney then
		TriggerEvent('esx_addonaccount:getSharedAccount', 'society_mechanic', function(account)
			account.addMoney(Config.CarPoundPrice)
		end)
	end
end)

---Spawn Vehicle
---@param props table
---@param coords vector4
RegisterNetEvent('esx_advancedgarage:spawn', function(props, coords)
	local source = source
	local start = os.nanotime()
	local vehProps = props
	local vehicleModel = joaat(vehProps.model)
	local xPlayer = ESX.GetPlayerFromId(source)
	ESX.GetVehicleType(vehicleModel, xPlayer.source, function(vehicleType)
		if vehicleType then
			local createdVehicle = CreateVehicleServerSetter(vehicleModel, vehicleType, coords.x, coords.y, coords.z + 0.5, coords.w)
			local a = 0
			while not DoesEntityExist(createdVehicle) do
				Wait(50)
				a += 1
				if a > 20 then
                    return print('[^1ERROR^7] Unfortunately, this vehicle has not spawned')
                end
			end

			Entity(createdVehicle).state:set('VehicleProperties', vehProps, true)
			if Config.Debug then
                print(('Spawned vehicle (%.4f ms)'):format((os.nanotime() - start) / 1e6))
			end
			Wait(300)
			TaskWarpPedIntoVehicle(GetPlayerPed(source), createdVehicle, -1)
		else
			print(('[^1ERROR^7] Tried to spawn invalid vehicle - ^5%s^7!'):format(vehicleModel))
		end
	end)
end)
