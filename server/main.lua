local cachedData = {}
-- Make sure all Vehicles are Stored on restart
--[[MySQL.ready(function()
	ParkVehicles()
end)

function ParkVehicles()
	MySQL.update('UPDATE owned_vehicles SET `stored` = true WHERE `stored` = @stored', {
		['@stored'] = false
	}, function(rowsChanged)
		if rowsChanged > 0 then
			print(('esx_advancedgarage: %s vehicle(s) have been stored!'):format(rowsChanged))
		end
	end)
end]]

-- Add Command for Getting Properties
if Config.UseCommand then
	ESX.RegisterCommand('getgarages', 'user', function(xPlayer, args, showError)
		xPlayer.triggerEvent('esx_advancedgarage:getPropertiesC')
	end, true, {help = 'Get Private Garages', validate = false})
end

-- Add Print Command for Getting Properties
RegisterServerEvent('esx_advancedgarage:printGetProperties')
AddEventHandler('esx_advancedgarage:printGetProperties', function()
	print('Getting Properties')
end)

-- Get Owned Properties
ESX.RegisterServerCallback('esx_advancedgarage:getOwnedProperties', function(source, cb)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local properties = {}

	MySQL.query('SELECT * FROM owned_properties WHERE owner = @owner', {
		['@owner'] = xPlayer.getIdentifier()
	}, function(data)
		for _,v in pairs(data) do
			table.insert(properties, v.name)
		end
		cb(properties)
	end)
end)

-- Start of Ambulance Code
ESX.RegisterServerCallback('esx_advancedgarage:getOwnedAmbulanceCars', function(source, cb)
	local ownedAmbulanceCars = {}
	local xPlayer = ESX.GetPlayerFromId(source)

	if Config.ShowVehicleLocation then
		MySQL.query('SELECT * FROM `owned_vehicles` WHERE `owner` = ? AND `type` = ? AND `job` = ?', {xPlayer.identifier, 'car', 'ambulance'}, function(data)
			for _,v in pairs(data) do
				local vehicle = json.decode(v.vehicle)
				table.insert(ownedAmbulanceCars, {vehicle = vehicle, stored = v.stored, plate = v.plate})
			end
			cb(ownedAmbulanceCars)
		end)
	else
		MySQL.query('SELECT * FROM `owned_vehicles` WHERE `owner` = ? AND `type` = ? AND `job` = ? AND `stored` = ?', {xPlayer.identifier, 'car', 'ambulance', true}, function(data)
			for _,v in pairs(data) do
				local vehicle = json.decode(v.vehicle)
				table.insert(ownedAmbulanceCars, {vehicle = vehicle, stored = v.stored, plate = v.plate})
			end
			cb(ownedAmbulanceCars)
		end)
	end
end)

ESX.RegisterServerCallback('esx_advancedgarage:getOwnedAmbulanceAircrafts', function(source, cb)
	local ownedAmbulanceAircrafts = {}
	local xPlayer = ESX.GetPlayerFromId(source)

	if Config.UsingAdvancedVehicleShop then
		if Config.ShowVehicleLocation then
			MySQL.query('SELECT * FROM owned_vehicles WHERE owner = @owner AND Type = @Type AND job = @job', { -- job = NULL
				['@owner'] = xPlayer.identifier,
				['@Type'] = 'aircraft',
				['@job'] = 'ambulance'
			}, function(data)
				for _,v in pairs(data) do
					local vehicle = json.decode(v.vehicle)
					table.insert(ownedAmbulanceAircrafts, {vehicle = vehicle, stored = v.stored, plate = v.plate, vtype = 'aircraft'})
				end
				cb(ownedAmbulanceAircrafts)
			end)
		else
			MySQL.query('SELECT * FROM owned_vehicles WHERE owner = @owner AND Type = @Type AND job = @job AND `stored` = @stored', { -- job = NULL
				['@owner'] = xPlayer.identifier,
				['@Type'] = 'aircraft',
				['@job'] = 'ambulance',
				['@stored'] = true
			}, function(data)
				for _,v in pairs(data) do
					local vehicle = json.decode(v.vehicle)
					table.insert(ownedAmbulanceAircrafts, {vehicle = vehicle, stored = v.stored, plate = v.plate, vtype = 'aircraft'})
				end
				cb(ownedAmbulanceAircrafts)
			end)
		end
	else
		if Config.ShowVehicleLocation then
			MySQL.query('SELECT * FROM owned_vehicles WHERE owner = @owner AND Type = @Type AND job = @job', { -- job = NULL
				['@owner'] = xPlayer.identifier,
				['@Type'] = 'helicopter',
				['@job'] = 'ambulance'
			}, function(data)
				for _,v in pairs(data) do
					local vehicle = json.decode(v.vehicle)
					table.insert(ownedAmbulanceAircrafts, {vehicle = vehicle, stored = v.stored, plate = v.plate, vtype = 'helicopter'})
				end
				cb(ownedAmbulanceAircrafts)
			end)
		else
			MySQL.query('SELECT * FROM owned_vehicles WHERE owner = @owner AND Type = @Type AND job = @job AND `stored` = @stored', { -- job = NULL
				['@owner'] = xPlayer.identifier,
				['@Type'] = 'helicopter',
				['@job'] = 'ambulance',
				['@stored'] = true
			}, function(data)
				for _,v in pairs(data) do
					local vehicle = json.decode(v.vehicle)
					table.insert(ownedAmbulanceAircrafts, {vehicle = vehicle, stored = v.stored, plate = v.plate, vtype = 'helicopter'})
				end
				cb(ownedAmbulanceAircrafts)
			end)
		end
	end
end)

ESX.RegisterServerCallback('esx_advancedgarage:getOutOwnedAmbulanceCars', function(source, cb)
	local ownedAmbulanceCars = {}
	local xPlayer = ESX.GetPlayerFromId(source)

	MySQL.query('SELECT * FROM `owned_vehicles` WHERE `owner` = ? AND `job` = ? AND `stored` = ?', {xPlayer.identifier, 'ambulance', false}, function(data) 
		for _,v in pairs(data) do
			local vehicle = json.decode(v.vehicle)
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
			for _,v in pairs(data) do
				local vehicle = json.decode(v.vehicle)
				table.insert(ownedPoliceCars, {vehicle = vehicle, stored = v.stored, plate = v.plate})
			end
			cb(ownedPoliceCars)
		end)
	else
		MySQL.query('SELECT * FROM `owned_vehicles` WHERE `owner` = ? AND `type` = ? AND `job` = ? AND `stored` = ?', {xPlayer.identifier, 'car', 'police', true}, function(data)
			for _,v in pairs(data) do
				local vehicle = json.decode(v.vehicle)
				table.insert(ownedPoliceCars, {vehicle = vehicle, stored = v.stored, plate = v.plate})
			end
			cb(ownedPoliceCars)
		end)
	end
end)

ESX.RegisterServerCallback('esx_advancedgarage:getOwnedSheriffCars', function(source, cb)
	local ownedSheriffCars = {}
	local xPlayer = ESX.GetPlayerFromId(source)

	if Config.ShowVehicleLocation then
		MySQL.query('SELECT * FROM owned_vehicles WHERE owner = @owner AND Type = @Type AND job = @job', { -- job = NULL
			['@owner'] = xPlayer.identifier,
			['@Type'] = 'car',
			['@job'] = 'sheriff'
		}, function(data)
			for _,v in pairs(data) do
				local vehicle = json.decode(v.vehicle)
				table.insert(ownedSheriffCars, {vehicle = vehicle, stored = v.stored, plate = v.plate})
			end
			cb(ownedSheriffCars)
		end)
	else
		MySQL.query('SELECT * FROM owned_vehicles WHERE owner = @owner AND Type = @Type AND job = @job AND `stored` = @stored', { -- job = NULL
			['@owner'] = xPlayer.identifier,
			['@Type'] = 'car',
			['@job'] = 'sheriff',
			['@stored'] = true
		}, function(data)
			for _,v in pairs(data) do
				local vehicle = json.decode(v.vehicle)
				table.insert(ownedSheriffCars, {vehicle = vehicle, stored = v.stored, plate = v.plate})
			end
			cb(ownedSheriffCars)
		end)
	end
end)

ESX.RegisterServerCallback('esx_advancedgarage:getOwnedPoliceAircrafts', function(source, cb)
	local ownedPoliceAircrafts = {}
	local xPlayer = ESX.GetPlayerFromId(source)

	if Config.UsingAdvancedVehicleShop then
		if Config.ShowVehicleLocation then
			MySQL.query('SELECT * FROM owned_vehicles WHERE owner = @owner AND Type = @Type AND job = @job', { -- job = NULL
				['@owner'] = xPlayer.identifier,
				['@Type'] = 'aircraft',
				['@job'] = 'police'
			}, function(data)
				for _,v in pairs(data) do
					local vehicle = json.decode(v.vehicle)
					table.insert(ownedPoliceAircrafts, {vehicle = vehicle, stored = v.stored, plate = v.plate, vtype = 'aircraft'})
				end
				cb(ownedPoliceAircrafts)
			end)
		else
			MySQL.query('SELECT * FROM owned_vehicles WHERE owner = @owner AND Type = @Type AND job = @job AND `stored` = @stored', { -- job = NULL
				['@owner'] = xPlayer.identifier,
				['@Type'] = 'aircraft',
				['@job'] = 'police',
				['@stored'] = true
			}, function(data)
				for _,v in pairs(data) do
					local vehicle = json.decode(v.vehicle)
					table.insert(ownedPoliceAircrafts, {vehicle = vehicle, stored = v.stored, plate = v.plate, vtype = 'aircraft'})
				end
				cb(ownedPoliceAircrafts)
			end)
		end
	else
		if Config.ShowVehicleLocation then
			MySQL.query('SELECT * FROM owned_vehicles WHERE owner = @owner AND Type = @Type AND job = @job', { -- job = NULL
				['@owner'] = xPlayer.identifier,
				['@Type'] = 'helicopter',
				['@job'] = 'police'
			}, function(data)
				for _,v in pairs(data) do
					local vehicle = json.decode(v.vehicle)
					table.insert(ownedPoliceAircrafts, {vehicle = vehicle, stored = v.stored, plate = v.plate, vtype = 'helicopter'})
				end
				cb(ownedPoliceAircrafts)
			end)
		else
			MySQL.query('SELECT * FROM owned_vehicles WHERE owner = @owner AND Type = @Type AND job = @job AND `stored` = @stored', { -- job = NULL
				['@owner'] = xPlayer.identifier,
				['@Type'] = 'helicopter',
				['@job'] = 'police',
				['@stored'] = true
			}, function(data)
				for _,v in pairs(data) do
					local vehicle = json.decode(v.vehicle)
					table.insert(ownedPoliceAircrafts, {vehicle = vehicle, stored = v.stored, plate = v.plate, vtype = 'helicopter'})
				end
				cb(ownedPoliceAircrafts)
			end)
		end
	end
end)

ESX.RegisterServerCallback('esx_advancedgarage:getOutOwnedPoliceCars', function(source, cb)
	local ownedPoliceCars = {}
	local xPlayer = ESX.GetPlayerFromId(source)

	MySQL.query('SELECT * FROM `owned_vehicles` WHERE `owner` = ? AND `job` = ? AND `stored` = ?', {xPlayer.identifier, 'police', false}, function(data) 
		for _,v in pairs(data) do
			local vehicle = json.decode(v.vehicle)
			table.insert(ownedPoliceCars, vehicle)
		end
		cb(ownedPoliceCars)
	end)
end)

ESX.RegisterServerCallback('esx_advancedgarage:getOutOwnedSheriffCars', function(source, cb)
	local ownedSheriffCars = {}
	local xPlayer = ESX.GetPlayerFromId(source)

	MySQL.query('SELECT * FROM `owned_vehicles` WHERE `owner` = ? AND `job` = ? AND `stored` = ?', {xPlayer.identifier, 'sheriff', false}, function(data) 
		for _,v in pairs(data) do
			local vehicle = json.decode(v.vehicle)
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
			for _,v in pairs(data) do
				local vehicle = json.decode(v.vehicle)
				table.insert(ownedAircrafts, {vehicle = vehicle, stored = v.stored, plate = v.plate})
			end
			cb(ownedAircrafts)
		end)
	else
		MySQL.query('SELECT * FROM `owned_vehicles` WHERE `owner` = ? AND `type` = ? AND `job` = ? AND `stored` = ?', {xPlayer.identifier, 'jet', 'civ', true}, function(data)
			for _,v in pairs(data) do
				local vehicle = json.decode(v.vehicle)
				table.insert(ownedAircrafts, {vehicle = vehicle, stored = v.stored, plate = v.plate})
			end
			cb(ownedAircrafts)
		end)
	end
end)

ESX.RegisterServerCallback('esx_advancedgarage:getOutOwnedAircrafts', function(source, cb)
	local ownedAircrafts = {}
	local xPlayer = ESX.GetPlayerFromId(source)

	MySQL.query('SELECT * FROM `owned_vehicles` WHERE `owner` = ? AND `type` = ? AND `stored` = ?', {xPlayer.identifier, 'jet', false}, function(data) 
		for _,v in pairs(data) do
			local vehicle = json.decode(v.vehicle)
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

-- Start of Boat Code
ESX.RegisterServerCallback('esx_advancedgarage:getOwnedBoats', function(source, cb)
	local ownedBoats = {}
	local xPlayer = ESX.GetPlayerFromId(source)

	if Config.ShowVehicleLocation then
		MySQL.query('SELECT * FROM `owned_vehicles` WHERE `owner` = ? AND `type` = ? AND `job` = ?', {xPlayer.identifier, 'boat', 'civ'}, function(data)
			for _,v in pairs(data) do
				local vehicle = json.decode(v.vehicle)
				table.insert(ownedBoats, {vehicle = vehicle, stored = v.stored, plate = v.plate})
			end
			cb(ownedBoats)
		end)
	else
		MySQL.query('SELECT * FROM `owned_vehicles` WHERE `owner` = ? AND `type` = ? AND `job` = ? AND `stored` = ?', {xPlayer.identifier, 'boat', 'civ', 1}, function(data)
			for _,v in pairs(data) do
				local vehicle = json.decode(v.vehicle)
				table.insert(ownedBoats, {vehicle = vehicle, stored = v.stored, plate = v.plate})
			end
			cb(ownedBoats)
		end)
	end
end)

ESX.RegisterServerCallback('esx_advancedgarage:getOutOwnedBoats', function(source, cb)
	local ownedBoats = {}
	local xPlayer = ESX.GetPlayerFromId(source)

	MySQL.query('SELECT * FROM `owned_vehicles` WHERE `owner` = ? AND `type` = ? AND `job` = ? AND `stored` = ?', {xPlayer.identifier, 'boat', 'civ', false}, function(data) 
		for _,v in pairs(data) do
			local vehicle = json.decode(v.vehicle)
			table.insert(ownedBoats, vehicle)
		end
		cb(ownedBoats)
	end)
end)

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
-- End of Boat Code

-- Start of Car Code
ESX.RegisterServerCallback('esx_advancedgarage:getOwnedCars', function(source, cb)
	local ownedCars = {}
	local xPlayer = ESX.GetPlayerFromId(source)

	if Config.ShowVehicleLocation then
		MySQL.query('SELECT * FROM owned_vehicles WHERE owner = @owner AND Type = @Type AND job = @job', { -- job = NULL
			['@owner'] = xPlayer.identifier,
			['@Type'] = 'car',
			['@job'] = 'civ'
		}, function(data)
			for _,v in pairs(data) do
				local vehicle = json.decode(v.vehicle)
				table.insert(ownedCars, {vehicle = vehicle, stored = v.stored, plate = v.plate})
			end
			cb(ownedCars)
		end)
	else
		MySQL.query('SELECT * FROM owned_vehicles WHERE owner = @owner AND Type = @Type AND job = @job AND `stored` = @stored', { -- job = NULL
			['@owner'] = xPlayer.identifier,
			['@Type'] = 'car',
			['@job'] = 'civ',
			['@stored'] = true
		}, function(data)
			for _,v in pairs(data) do
				local vehicle = json.decode(v.vehicle)
				table.insert(ownedCars, {vehicle = vehicle, stored = v.stored, plate = v.plate})
			end
			cb(ownedCars)
		end)
	end
end)

ESX.RegisterServerCallback('esx_advancedgarage:checkMoneyCars', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	if xPlayer.getMoney() >= Config.CarPoundPrice then
		cb(true)
	else
		cb(false)
	end
end)

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
-- End of Car Code

-- Store Vehicles
ESX.RegisterServerCallback('esx_advancedgarage:storeVehicle', function (source, cb, vehicleProps)
	local ownedCars = {}
	--local vehplate = vehicleProps.plate:match("^%s*(.-)%s*$")
	local vehiclemodel = vehicleProps.model
	local xPlayer = ESX.GetPlayerFromId(source)

	MySQL.query('SELECT * FROM `owned_vehicles` WHERE `owner` = ? AND `plate` = ?', {xPlayer.identifier, vehicleProps.plate}, function (result)
		if result[1] ~= nil then
			local originalvehprops = json.decode(result[1].vehicle)
			if originalvehprops.model == vehiclemodel then
				--[[MySQL.prepare('UPDATE `owned_vehicles` SET `vehicle` = ? WHERE `owner` = ? AND `plate` = ?', {json.encode(vehicleProps), xPlayer.identifier, vehicleProps.plate}, function (rowsChanged)
					if rowsChanged == 0 then
						print(('esx_advancedgarage: %s attempted to store an vehicle they don\'t own!'):format(xPlayer.identifier))
					end
					cb(true)
				end)]]
                                cb(true)
			else
				if Config.KickPossibleCheaters == true then
					if Config.UseCustomKickMessage == true then
						print(('esx_advancedgarage: %s attempted to Cheat! Tried Storing: ' .. vehiclemodel .. '. Original Vehicle: ' .. originalvehprops.model):format(xPlayer.identifier))

						DropPlayer(source, _U('custom_kick'))
						cb(false)
					else
						print(('esx_advancedgarage: %s attempted to Cheat! Tried Storing: ' .. vehiclemodel .. '. Original Vehicle: ' .. originalvehprops.model):format(xPlayer.identifier))

						DropPlayer(source, 'You have been Kicked from the Server for Possible Garage Cheating!!!')
						cb(false)
					end
				else
					print(('esx_advancedgarage: %s attempted to Cheat! Tried Storing: ' .. vehiclemodel .. '. Original Vehicle: '.. originalvehprops.model):format(xPlayer.identifier))
					cb(false)
				end
			end
		else
			print(('esx_advancedgarage: %s attempted to store an vehicle they don\'t own!'):format(xPlayer.identifier))
			cb(false)
		end
	end)
end)

ESX.RegisterServerCallback('esx_advancedgarage:storeAircraft', function (source, cb, vehicleProps)
	local ownedCars = {}
	--local vehplate = vehicleProps.plate:match("^%s*(.-)%s*$")
	local vehiclemodel = vehicleProps.model
	local xPlayer = ESX.GetPlayerFromId(source)

	MySQL.query('SELECT * FROM `owned_vehicles` WHERE `owner` = ? AND `type` = ? AND `job` = ? AND `plate` = ?', {xPlayer.identifier, 'jet', 'civ', vehicleProps.plate}, function (result)
		if result[1] ~= nil then
			local originalvehprops = json.decode(result[1].vehicle)
			if originalvehprops.model == vehiclemodel then
				--[[MySQL.prepare('UPDATE `owned_vehicles` SET `vehicle` = ? WHERE `owner` = ? AND `plate` = ?', {json.encode(vehicleProps), xPlayer.identifier, vehicleProps.plate}, function (rowsChanged)
					if rowsChanged == 0 then
						print(('esx_advancedgarage: %s attempted to store an vehicle they don\'t own!'):format(xPlayer.identifier))
					end
					cb(true)
				end)]]
                                cb(true)
			else
				if Config.KickPossibleCheaters == true then
					if Config.UseCustomKickMessage == true then
						print(('esx_advancedgarage: %s attempted to Cheat! Tried Storing: ' .. vehiclemodel .. '. Original Vehicle: ' .. originalvehprops.model):format(xPlayer.identifier))

						DropPlayer(source, _U('custom_kick'))
						cb(false)
					else
						print(('esx_advancedgarage: %s attempted to Cheat! Tried Storing: ' .. vehiclemodel .. '. Original Vehicle: ' .. originalvehprops.model):format(xPlayer.identifier))

						DropPlayer(source, 'You have been Kicked from the Server for Possible Garage Cheating!!!')
						cb(false)
					end
				else
					print(('esx_advancedgarage: %s attempted to Cheat! Tried Storing: ' .. vehiclemodel .. '. Original Vehicle: '.. originalvehprops.model):format(xPlayer.identifier))
					cb(false)
				end
			end
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
             --'UPDATE `owned_vehicles` SET `vehicle` = ?, `stored` = ? WHERE `plate` = ?'

-- Modify State of Vehicles
RegisterServerEvent('esx_advancedgarage:setVehicleState')
AddEventHandler('esx_advancedgarage:setVehicleState', function(plate, state)
	local xPlayer = ESX.GetPlayerFromId(source)

	MySQL.update.await(query51, {state, plate})
end)

-- Modify State of Vehicles
RegisterServerEvent('esx_advancedgarage:setVehicleState2')
AddEventHandler('esx_advancedgarage:setVehicleState2', function(vehicleProps, state, plate)
	local xPlayer = ESX.GetPlayerFromId(source)
	MySQL.prepare(query5, {json.encode(vehicleProps), state, plate})
end)

--------------------------- Új garázs --------------------------------
local xxx = 'SELECT `vehicle` FROM `owned_vehicles` WHERE `owner` = ? AND `type` = ? AND `garage` = ? AND `job` = ? AND `stored` = ?'
local query = 'SELECT * FROM `owned_vehicles` WHERE `owner` = ? AND `type` = ? AND `garage` = ? AND `job` = ? AND `stored` = ?'

---@param source number
---@param garage string
ESX.RegisterServerCallback("garage:fetchPlayerVehicles", function(source, callback, garage)
        --local timeStart = os.clock()
	local xPlayer = ESX.GetPlayerFromId(source)
        local identifier = xPlayer.identifier

	if xPlayer then
		MySQL.rawExecute(query, {identifier, 'car', garage, 'civ', 1}, function(result)
	             local Vehicles = {}
                     if result then
			for i = 1, #result do
				table.insert(Vehicles, {
					["plate"] = result[i].plate,
					["props"] = json.decode(result[i].vehicle)
				})
			end
			callback(Vehicles)
                        --print(('[^2INFO] query ^5%s^7 ms'):format(ESX.Math.Round((os.time() - timeStart) / 1000000, 2)))
                     else
		         callback(false)
                     end
		end)
	else
		callback(false)
	end
end)

local query1 = 'UPDATE `owned_vehicles` SET `vehicle` = ?, `stored` = ?, `garage` = ? WHERE `plate` = ?'
local query2 = 'SELECT * FROM `owned_vehicles` WHERE `plate` = ? AND `job` = ? AND `type` = ? AND `owner` = ?'
local query4 = 'UPDATE `owned_vehicles` SET `stored` = ? WHERE `plate` = ?'

---@param source number
---@param vehicleProps table
---@param garage string
ESX.RegisterServerCallback("garage:validateVehicle", function(source, cb, vehicleProps, garage)
	local xPlayer = ESX.GetPlayerFromId(source)
        local rendszam = vehicleProps["plate"]
	if xPlayer then
                MySQL.prepare(query2, {rendszam, 'civ', 'car', xPlayer.identifier}, function(result)
			if result then
                                MySQL.prepare(query1, {json.encode(vehicleProps), 1, garage, rendszam})
				cb(true)
			else
				cb(false)
			end
                end)
	else
		cb(false)
	end
end)

function validate(source, callback, vehicleProps, garage)
	local xPlayer = ESX.GetPlayerFromId(source)
        local rendszam = vehicleProps["plate"]
	if xPlayer then
                MySQL.prepare(query2, {rendszam, 'civ', 'car', xPlayer.identifier}, function(result)
			if result then --[1]
				--UpdateGarage(source, vehicleProps, garage)
                                MySQL.prepare(query1, {json.encode(vehicleProps), 1, garage, rendszam})
				return true
			else
				return false
			end
                end)
	else
		return false
	end
end

RegisterServerEvent('garage:takecar')
AddEventHandler('garage:takecar', function(plate, state)
	local xPlayer = ESX.GetPlayerFromId(source)
	local src = source
			if Config.EnableLogs then
				msg = GetPlayerName(src) .. " has taken out car " .. plate
				sendToDiscord(Config.GarageWebhook, Config.ColourInfo, Config.GarageName, msg, " ")
			end
	MySQL.prepare(query4, {state, plate})
end)

-- Fetch impounded Cars

local query3 = 'SELECT * FROM `owned_vehicles` WHERE `owner` = ? AND `type` = ? AND `stored` = ?'

ESX.RegisterServerCallback('esx_advancedgarage:getOutOwnedCars', function(source, cb)
	local ownedCars = {}
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	
	MySQL.query(query3, {xPlayer.identifier, 'car', false}, function(data)
		for i = 1, #data, 1 do
			local vehicle = json.decode(data[i].vehicle)
			table.insert(ownedCars, vehicle)
		end
		cb(ownedCars)
	end)
end)

-- Check Money for impounded Cars
ESX.RegisterServerCallback('garage:checkMoneyCars', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	if xPlayer.getAccount('bank').money >= Config.ImpoundPrice then
		cb(true)
	else
		cb(false)
	end
end)

-- Pay for Pounded Cars
RegisterServerEvent('garage:payCar')
AddEventHandler('garage:payCar', function(plate)
	local xPlayer = ESX.GetPlayerFromId(source)
	if Config.EnableLogs then
		msg = GetPlayerName(source) .. " has recovered " .. plate .. " from the impound " 
		sendToDiscord(Config.ImpoundWebhook, Config.ColourInfo, Config.ImpoundName, msg, " ")
	end
	xPlayer.removeAccountMoney('bank', Config.ImpoundPrice)
	TriggerClientEvent('esx:showNotification', source, 'Te fizett�l ennyit: ' .. Config.ImpoundPrice)
end)

RegisterServerEvent('esx_advancedgarage:setVehicleFuel')
AddEventHandler('esx_advancedgarage:setVehicleFuel', function(plate, fuel)
	local xPlayer = ESX.GetPlayerFromId(source)

	MySQL.update('UPDATE owned_vehicles SET fuel = ? WHERE plate = ?', {fuel, plate}, function(rowsChanged)
		if rowsChanged == 0 then
			print(('esx_advancedgarage: %s exploited the garage!'):format(xPlayer.identifier))
		end
	end)
end)

--logging

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
