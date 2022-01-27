if GetResourceState('es_extended'):find('start') then
	local ESX = exports.es_extended:getSharedObject()

	ESX = {
		RegisterServerCallback = ESX.RegisterServerCallback,
		GetPlayerFromId = ESX.GetPlayerFromId,
	}

	RegisterNetEvent('esx_skin:save', function(appearance)
		local xPlayer = ESX.GetPlayerFromId(source)
		MySQL.update('UPDATE users SET skin = ? WHERE identifier = ?', { json.encode(appearance), xPlayer.identifier })
	end)

	ESX.RegisterServerCallback('esx_skin:getPlayerSkin', function(source, cb)
		local xPlayer = ESX.GetPlayerFromId(source)
		local appearance = MySQL.scalar.await('SELECT skin FROM users WHERE identifier = ?', { xPlayer.identifier })
		
		if appearance then appearance = json.decode(appearance) end

		cb(appearance)
	end)
end

local identifiers = {}

local function saveAppearance(identifier, appearance)
	SetResourceKvp(identifier..':appearance', json.encode(appearance))
end
exports('save', saveAppearance)

local function loadAppearance(source, identifier)
	local appearance = GetResourceKvpString(identifier..':appearance')
	identifiers[source] = identifier

	return appearance and json.decode(appearance) or {}
end
exports('load', loadAppearance)

RegisterNetEvent('fivem-appearance:save', function(appearance)
	local identifier = identifiers[source]

	if identifier then
		saveAppearance(identifier, appearance)
	end
end)

AddEventHandler('playerDropped', function()
	identifiers[source] = nil
end)