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
