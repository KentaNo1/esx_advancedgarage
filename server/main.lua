---Make sure all Vehicles are Stored on restart
if Config.Parkvehicles then
    MySQL.ready(function()
	    ParkVehicles()
    end)
end

function ParkVehicles()
	MySQL.update('UPDATE `owned_vehicles` SET `stored` = ? WHERE `stored` = ?', {true, false}, function(rowsChanged)
		if rowsChanged > 0 then
			print(('esx_advancedgarage: %s vehicle(s) have been stored!'):format(rowsChanged))
		end
	end)
end

---Add Command for Getting Properties
if Config.UseCommand then
	ESX.RegisterCommand('getgarages', 'user', function(xPlayer, args, showError)
		xPlayer.triggerEvent('esx_advancedgarage:getPropertiesC')
	end, true, {help = 'Get Private Garages', validate = false})
end

---Add Print Command for Getting Properties
RegisterServerEvent('esx_advancedgarage:printGetProperties')
AddEventHandler('esx_advancedgarage:printGetProperties', function()
	print('Getting Properties')
end)

---Get Owned Properties
---@param source number
---@param cb function
ESX.RegisterServerCallback('esx_advancedgarage:getOwnedProperties', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	local properties = {}

	MySQL.query('SELECT * FROM `owned_properties` WHERE `owner` = ?', {xPlayer.identifier}, function(data)
		for i = 1, #data do
			table.insert(properties, data[i].name)
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
		MySQL.query('SELECT * FROM `owned_vehicles` WHERE `owner` = ? AND `type` = ? AND `job` = ?', {xPlayer.identifier, 'car', 'ambulance'}, function(data)
			for i = 1, #data do
				local vehicle = json.decode(data[i].vehicle)
				table.insert(ownedAmbulanceCars, {vehicle = vehicle})
			end
			cb(ownedAmbulanceCars)
		end)
	else
		MySQL.query('SELECT * FROM `owned_vehicles` WHERE `owner` = ? AND `type` = ? AND `job` = ? AND `stored` = ?', {xPlayer.identifier, 'car', 'ambulance', 1}, function(data)
			for i = 1, #data do
				local vehicle = json.decode(data[i].vehicle)
				table.insert(ownedAmbulanceCars, {vehicle = vehicle})
			end
			cb(ownedAmbulanceCars)
		end)
	end
end)

ESX.RegisterServerCallback('esx_advancedgarage:getOwnedAmbulanceAircrafts', function(source, cb)
	local ownedAmbulanceAircrafts = {}
	local xPlayer = ESX.GetPlayerFromId(source)

	if Config.ShowVehicleLocation then
		MySQL.query('SELECT * FROM `owned_vehicles` WHERE `owner` = ? AND `type` = ? AND `job` = ?', {xPlayer.identifier, 'helicopter', 'ambulance'}, function(data)
			for i = 1, #data do
				local vehicle = json.decode(data[i].vehicle)
				table.insert(ownedAmbulanceAircrafts, {vehicle = vehicle})
			end
			cb(ownedAmbulanceAircrafts)
		end)
	else
		MySQL.query('SELECT * FROM `owned_vehicles` WHERE `owner` = ? AND `type` = ? AND `job` = ? AND `stored` = ?', {xPlayer.identifier, 'helicopter', 'ambulance', 1}, function(data)
			for i = 1, #data do
				local vehicle = json.decode(data[i].vehicle)
				table.insert(ownedAmbulanceAircrafts, {vehicle = vehicle})
			end
			cb(ownedAmbulanceAircrafts)
		end)
	end
end)

ESX.RegisterServerCallback('esx_advancedgarage:getOutOwnedAmbulanceCars', function(source, cb)
	local ownedAmbulanceCars = {}
	local xPlayer = ESX.GetPlayerFromId(source)

	MySQL.query('SELECT * FROM `owned_vehicles` WHERE `owner` = ? AND `job` = ? AND `stored` = ?', {xPlayer.identifier, 'ambulance', 0}, function(data) 
		for i = 1, #data do
			local vehicle = json.decode(data[i].vehicle)
			table.insert(ownedAmbulanceCars, vehicle)
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

RegisterServerEvent('esx_advancedgarage:payAmbulance')
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
		MySQL.query('SELECT * FROM `owned_vehicles` WHERE `owner` = ? AND `type` = ? AND `job` = ?', {xPlayer.identifier, 'car', 'police'}, function(data)
			for i = 1, #data do
				local vehicle = json.decode(data[i].vehicle)
				table.insert(ownedPoliceCars, {vehicle = vehicle})
			end
			cb(ownedPoliceCars)
		end)
	else
		MySQL.query('SELECT * FROM `owned_vehicles` WHERE `owner` = ? AND `type` = ? AND `job` = ? AND `stored` = ?', {xPlayer.identifier, 'car', 'police', 1}, function(data)
			for i = 1, #data do
				local vehicle = json.decode(data[i].vehicle)
				table.insert(ownedPoliceCars, {vehicle = vehicle})
			end
			cb(ownedPoliceCars)
		end)
	end
end)

ESX.RegisterServerCallback('esx_advancedgarage:getOwnedSheriffCars', function(source, cb)
	local ownedSheriffCars = {}
	local xPlayer = ESX.GetPlayerFromId(source)

	if Config.ShowVehicleLocation then
		MySQL.query('SELECT * FROM `owned_vehicles` WHERE `owner` = ? AND `type` = ? AND `job` = ?', {xPlayer.identifier, 'car', 'sheriff'}, function(data)
			for i = 1, #data do
				local vehicle = json.decode(data[i].vehicle)
				local stored = data[i].stored
				table.insert(ownedSheriffCars, {vehicle = vehicle, stored = stored})
			end
			cb(ownedSheriffCars)
		end)
	else
		MySQL.query('SELECT * FROM `owned_vehicles` WHERE `owner` = ? AND `type` = ? AND `job` = ? AND `stored` = ?', {xPlayer.identifier, 'car', 'sheriff', 1}, function(data)
			for i = 1, #data do
				local vehicle = json.decode(data[i].vehicle)
				table.insert(ownedSheriffCars, {vehicle = vehicle})
			end
			cb(ownedSheriffCars)
		end)
	end
end)

ESX.RegisterServerCallback('esx_advancedgarage:getOwnedPoliceAircrafts', function(source, cb)
	local ownedPoliceAircrafts = {}
	local xPlayer = ESX.GetPlayerFromId(source)

	if Config.ShowVehicleLocation then
		MySQL.query('SELECT * FROM `owned_vehicles` WHERE `owner` = ? AND `type` = ? AND `job` = ?', {xPlayer.identifier, 'helicopter', 'police'}, function(data)
			for i = 1, #data do
				local vehicle = json.decode(data[i].vehicle)
				local stored = data[i].stored
				table.insert(ownedPoliceAircrafts, {vehicle = vehicle, stored = stored})
			end
			cb(ownedPoliceAircrafts)
		end)
	else
		MySQL.query('SELECT * FROM `owned_vehicles` WHERE `owner` = ? AND `type` = ? AND `job` = ? AND `stored` = ?', {xPlayer.identifier, 'helicopter', 'police', 1}, function(data)
			for i = 1, #data do
				local vehicle = json.decode(data[i].vehicle)
				table.insert(ownedPoliceAircrafts, {vehicle = vehicle})
			end
			cb(ownedPoliceAircrafts)
		end)
	end
end)

ESX.RegisterServerCallback('esx_advancedgarage:getOutOwnedPoliceCars', function(source, cb)
	local ownedPoliceCars = {}
	local xPlayer = ESX.GetPlayerFromId(source)

	MySQL.query('SELECT * FROM `owned_vehicles` WHERE `owner` = ? AND `job` = ? AND `stored` = ?', {xPlayer.identifier, 'police', 0}, function(data)
		for i = 1, #data do
			local vehicle = json.decode(data[i].vehicle)
			table.insert(ownedPoliceCars, vehicle)
		end
		cb(ownedPoliceCars)
	end)
end)

ESX.RegisterServerCallback('esx_advancedgarage:getOutOwnedTaxingCars', function(source, cb)
	local ownedTaxiCars = {}
	local xPlayer = ESX.GetPlayerFromId(source)

	MySQL.query('SELECT * FROM `owned_vehicles` WHERE `owner` = ? AND `job` = ? AND `stored` = ?', {xPlayer.identifier, 'taxi', 0}, function(data)
		for i = 1, #data do
			local vehicle = json.decode(data[i].vehicle)
			table.insert(ownedTaxiCars, vehicle)
		end
		cb(ownedTaxiCars)
	end)
end)

ESX.RegisterServerCallback('esx_advancedgarage:getOutOwnedSheriffCars', function(source, cb)
	local ownedSheriffCars = {}
	local xPlayer = ESX.GetPlayerFromId(source)

	MySQL.query('SELECT * FROM `owned_vehicles` WHERE `owner` = ? AND `job` = ? AND `stored` = ?', {xPlayer.identifier, 'sheriff', 0}, function(data)
		for i = 1, #data do
			local vehicle = json.decode(data[i].vehicle)
			table.insert(ownedSheriffCars, vehicle)
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

ESX.RegisterServerCallback('esx_advancedgarage:checkMoneySheriff', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	if xPlayer.getMoney() >= Config.SheriffPoundPrice then
		cb(true)
	else
		cb(false)
	end
end)

RegisterServerEvent('esx_advancedgarage:payPolice')
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

RegisterServerEvent('esx_advancedgarage:paySheriff')
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
	local ownedAircrafts = {}
	local xPlayer = ESX.GetPlayerFromId(source)

	if Config.ShowVehicleLocation then
		MySQL.query('SELECT * FROM `owned_vehicles` WHERE `owner` = ? AND `type` = ? AND `job` = ?', {xPlayer.identifier, 'jet', 'civ'}, function(data)
			for i = 1, #data do
				local vehicle = json.decode(data[i].vehicle)
				local stored = data[i].stored
				table.insert(ownedAircrafts, {vehicle = vehicle, stored = stored})
			end
			cb(ownedAircrafts)
		end)
	else
		MySQL.query('SELECT * FROM `owned_vehicles` WHERE `owner` = ? AND `type` = ? AND `job` = ? AND `stored` = ?', {xPlayer.identifier, 'jet', 'civ', 1}, function(data)
			for i = 1, #data do
				local vehicle = json.decode(data[i].vehicle)
				table.insert(ownedAircrafts, vehicle)
			end
			cb(ownedAircrafts)
		end)
	end
end)

ESX.RegisterServerCallback('esx_advancedgarage:getOutOwnedAircrafts', function(source, cb)
	local ownedAircrafts = {}
	local xPlayer = ESX.GetPlayerFromId(source)

	MySQL.query('SELECT * FROM `owned_vehicles` WHERE `owner` = ? AND `type` = ? AND `stored` = ?', {xPlayer.identifier, 'jet', 0}, function(data)
		for i = 1, #data do
			local vehicle = json.decode(data[i].vehicle)
			table.insert(ownedAircrafts, vehicle)
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

RegisterServerEvent('esx_advancedgarage:payAircraft')
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
	local ownedBoats = {}
	local xPlayer = ESX.GetPlayerFromId(source)

	if Config.ShowVehicleLocation then
		MySQL.query('SELECT * FROM `owned_vehicles` WHERE `owner` = ? AND `type` = ? AND `job` = ?', {xPlayer.identifier, 'boat', 'civ'}, function(data)
			for i = 1, #data do
				local vehicle = json.decode(data[i].vehicle)
				local stored = data[i].stored
				table.insert(ownedBoats, {vehicle = vehicle, stored = stored})
			end
			cb(ownedBoats)
		end)
	else
		MySQL.query('SELECT * FROM `owned_vehicles` WHERE `owner` = ? AND `type` = ? AND `job` = ? AND `stored` = ?', {xPlayer.identifier, 'boat', 'civ', 1}, function(data)
			for i = 1, #data do
				local vehicle = json.decode(data[i].vehicle)
				table.insert(ownedBoats, vehicle)
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
	MySQL.query('SELECT * FROM `owned_vehicles` WHERE `owner` = ? AND `type` = ? AND `job` = ? AND `stored` = ?', {xPlayer.identifier, 'boat', 'civ', 0}, function(data)
		for i = 1, #data do
			local vehicle = json.decode(data[i].vehicle)
			table.insert(ownedBoats, vehicle)
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

RegisterServerEvent('esx_advancedgarage:payBoat')
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

RegisterServerEvent('esx_advancedgarage:payCar')
AddEventHandler('esx_advancedgarage:payCar', function()
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeMoney(Config.CarPoundPrice)
	TriggerClientEvent('esx:showNotification', source, _U('you_paid') .. Config.CarPoundPrice)

	if Config.GiveSocietyMoney then
		TriggerEvent('esx_addonaccount:getSharedAccount', 'society_mechanic', function(account)
			account.addMoney(Config.CarPoundPrice)
		end)
	end
end)

---Store vehicles
---@param source number
---@param cb function
---@param vehicleProps table
ESX.RegisterServerCallback('esx_advancedgarage:storeBoat', function (source, cb, vehicleProps)
	local xPlayer = ESX.GetPlayerFromId(source)
	MySQL.query('SELECT * FROM `owned_vehicles` WHERE `owner` = ? AND `plate` = ?', {xPlayer.identifier, vehicleProps.plate}, function(result)
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
	MySQL.query('SELECT * FROM `owned_vehicles` WHERE `owner` = ? AND `type` = ? AND `job` = ? AND `plate` = ?', {xPlayer.identifier, 'jet', 'civ', vehicleProps.plate}, function (result)
		if result then
            cb(true)
        else
			print(('esx_advancedgarage: %s attempted to store an vehicle they don\'t own!'):format(xPlayer.identifier))
			cb(false)
		end
	end)
end)

-- Pay to Return Broken Vehicles
RegisterServerEvent('esx_advancedgarage:payhealth')
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

local query51 = 'UPDATE `owned_vehicles` SET `stored` = ? WHERE `plate` = ?'
local query5 = 'UPDATE `owned_vehicles` SET `vehicle` = ?, `stored` = ? WHERE `plate` = ?'

-- Modify State of Vehicles
RegisterServerEvent('esx_advancedgarage:setVehicleState')
AddEventHandler('esx_advancedgarage:setVehicleState', function(plate, state)
	MySQL.prepare.await(query51, {tonumber(state), plate})
end)

-- Modify State of Vehicles
RegisterServerEvent('esx_advancedgarage:setVehicleState2')
AddEventHandler('esx_advancedgarage:setVehicleState2', function(vehicleProps, state, plate)
	MySQL.prepare.await(query5, {json.encode(vehicleProps), tonumber(state), plate})
end)

--------------------------- Új garázs --------------------------------
local query = 'SELECT * FROM `owned_vehicles` WHERE `owner` = ? AND `type` = ? AND `garage` = ? AND `job` = ? AND `stored` = ?'
local query1 = 'UPDATE `owned_vehicles` SET `vehicle` = ?, `stored` = ?, `garage` = ? WHERE `plate` = ?'
local query2 = 'SELECT * FROM `owned_vehicles` WHERE `plate` = ? AND `job` = ? AND `type` = ? AND `owner` = ?'
local query3 = 'SELECT * FROM `owned_vehicles` WHERE `owner` = ? AND `type` = ? AND `stored` = ?'
local query4 = 'UPDATE `owned_vehicles` SET `stored` = ? WHERE `plate` = ?'

---Fetch player vehicles
---@param source number
---@param cb function
---@param garage string
ESX.RegisterServerCallback("esx_advancedgarage:fetchPlayerVehicles", function(source, cb, garage)
	local xPlayer = ESX.GetPlayerFromId(source)
    local identifier = xPlayer.identifier

	if xPlayer then
		MySQL.rawExecute(query, {identifier, 'car', garage, 'civ', 1}, function(result)
	        local Vehicles = {}
            if result then
			    for i = 1, #result do  --table.insert(Vehicles, {plate = result[i].plate, props = json.decode(result[i].vehicle)})
					vehicle = json.decode(result[i].vehicle)
				    table.insert(Vehicles, vehicle)
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
                MySQL.prepare.await(query1, {json.encode(vehicleProps), 1, garage, rendszam})
				print(('Saved vehicle (%.4f ms)'):format((os.nanotime() - start) / 1e6))
				cb(true)
			else
				cb(false)
			end
        end)
	else
		cb(false)
	end
end)

RegisterServerEvent("esx_advancedgarage:takecar", function(plate, state)
	if Config.EnableLogs then
		msg = GetPlayerName(source) .. " has taken out car " .. plate
		sendToDiscord(Config.GarageWebhook, Config.ColourInfo, Config.GarageName, msg, " ")
	end
    MySQL.prepare.await(query4, {state, plate})
end)

---Fetch impounded Cars
---@param source number
---@param cb function
ESX.RegisterServerCallback("esx_advancedgarage:getOutOwnedCars", function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	local ownedCars = {}

	MySQL.rawExecute(query3, {xPlayer.identifier, 'car', 0}, function(data)
		for i = 1, #data do
			local vehicle = json.decode(data[i].vehicle)
			table.insert(ownedCars, vehicle)
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
RegisterServerEvent('garage:payCar', function(plate)
	local xPlayer = ESX.GetPlayerFromId(source)
	if Config.EnableLogs then
		msg = GetPlayerName(source) .. " has recovered " .. plate .. " from the impound " 
		sendToDiscord(Config.ImpoundWebhook, Config.ColourInfo, Config.ImpoundName, msg, " ")
	end
	xPlayer.removeAccountMoney('bank', Config.ImpoundPrice)
	TriggerClientEvent('esx:showNotification', source, 'Te fizett�l ennyit: ' .. Config.ImpoundPrice)
end)

---logging
function sendToDiscord(webhook, color, name, message, footer)
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