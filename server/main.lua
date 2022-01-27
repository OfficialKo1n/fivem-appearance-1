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

	ESX.RegisterServerCallback('esx_skin:BuyOutfit', function(source, cb, price)
		local xPlayer = ESX.GetPlayerFromId(source)
		local playerMoney = xPlayer.getMoney()
	
		if playerMoney >= price then
			xPlayer.removeMoney(price)		
			xPlayer.showNotification('You paid $'..price)
			cb(true)
		else
			xPlayer.showNotification('You dont have enough money, missing $'..(price - playerMoney))
			cb(false)
		end
	end)

	RegisterServerEvent("esx_skin:saveOutfit")
	AddEventHandler("esx_skin:saveOutfit", function(name, pedModel, pedComponents, pedProps)
		local xPlayer = ESX.GetPlayerFromId(source)

		MySQL.Async.insert('INSERT INTO `outfits` (`identifier`, `name`, `ped`, `components`, `props`) VALUES (@identifier, @name, @ped, @components, @props)', {
			['@ped'] = json.encode(pedModel),
			['@components'] = json.encode(pedComponents),
			['@props'] = json.encode(pedProps),
			['@name'] = name,
			['@identifier'] = xPlayer.identifier
		})
	end)


	RegisterServerEvent("esx_skin:getOutfits")
	AddEventHandler("esx_skin:getOutfits", function()
		local xPlayer = ESX.GetPlayerFromId(source)
		local oSource = source
		local myOutfits = {}

		MySQL.query('SELECT id, name, ped, components, props FROM outfits WHERE identifier = ?', {xPlayer.identifier}, function(result)
			for i=1, #result, 1 do
				table.insert(myOutfits, {id = result[i].id, name = result[i].name, ped = json.decode(result[i].ped), components = json.decode(result[i].components), props = json.decode(result[i].props)})
			end
			TriggerClientEvent('esx_skin:sendOutfits', oSource, myOutfits)
		end)
	end)

	RegisterServerEvent("esx_skin:deleteOutfit")
	AddEventHandler("esx_skin:deleteOutfit", function(id)
		local xPlayer = ESX.GetPlayerFromId(source)

		MySQL.update('DELETE FROM `outfits` WHERE `id` = ?', {id})
	end)

	RegisterCommand("skin", function(source, args)
		local player = ESX.GetPlayerFromId(source)
		if player.getGroup() == 'superadmin' or player.getGroup() == 'admin' then
			TriggerClientEvent("esx_skin:AdminMenu", source)
		end
	end, false)
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

RegisterNetEvent('esx_skin:save', function(appearance)
	local identifier = identifiers[source]

	if identifier then
		saveAppearance(identifier, appearance)
	end
end)

AddEventHandler('playerDropped', function()
	identifiers[source] = nil
end)
