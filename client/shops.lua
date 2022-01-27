local ESX = exports.es_extended:getSharedObject()

local allMyOutfits = {}

local shops = {
	clothing = {
		vec(-169.0882, -298.8425, 39.73331),
		vec(430.3655, -800.147, 29.4911),
		vec(-3173.083, 1046.625, 20.86324),
		vec(-830.0149, -1073.183, 11.3281),
		vec(1190.329, 2714.304, 38.22261),
		vec(1697.771, 4830.376, 42.07066),
		vec(12.44993, 6513.748, 31.87785),
		--[[vec(122.98, -222.27, 53.5),
		vec(1696.3, 4829.3, 41.1),
		vec(618.1, 2759.6, 41.1),
		vec(1190.6, 2713.4, 37.2),
		vec(-1193.4, -772.3, 16.3),
		vec(-3172.5, 1048.1, 19.9),
		vec(-1108.4, 2708.9, 18.1),]]
		-- add 4th argument to create vector4 and disable blip
		vec(300.60162353516, -597.76068115234, 42.18409576416, 0),
		vec(461.47720336914, -998.05444335938, 30.201751708984, 0),
		vec(-1622.6466064453, -1034.0192871094, 13.145475387573, 0),
		vec(1861.1047363281, 3689.2331542969, 34.276859283447, 0),
		vec(1834.5977783203, 3690.5405273438, 34.270645141602, 0),
		vec(1742.1407470703, 2481.5856933594, 45.740657806396, 0),
		vec(516.8916015625, 4823.5693359375, -66.18879699707, 0),
	},

	barber = {
		vec(137.2754, -1707.463, 29.29163),
		vec(-814.4005, -183.8495, 37.56887),
		vec(1931.854, 3729.995, 32.84447),
		vec(-277.6419, 6227.773, 31.69551),
		vec(-1282.594, -1116.763, 6.990126),
	}
}

local function createBlip(name, sprite, colour, scale, location)
	if not location.w then
		local blip = AddBlipForCoord(location.x, location.y)
		SetBlipSprite(blip, sprite)
		SetBlipDisplay(blip, 4)
		SetBlipScale(blip, scale)
		SetBlipColour(blip, colour)
		SetBlipAsShortRange(blip, true)
		BeginTextCommandSetBlipName('STRING')
		AddTextComponentString(name)
		EndTextCommandSetBlipName(blip)
	end
end

for i = 1, #shops.clothing do
	createBlip('Clothing store', 73, 47, 0.7, shops.clothing[i])
end

for i = 1, #shops.barber do
	createBlip('Barber shop', 71, 47, 0.7, shops.barber[i])
end
---target

local clothes = {
	`s_f_y_shop_low`,
	`s_f_y_shop_mid`
}
exports['qtarget']:AddTargetModel(clothes, {
	options = {
		{
			event = 'esx_skin:clothingShop',
			icon = 'fas fa-tshirt',
			label = "Clothes Shop"
		},
	},
	distance = 3.5
})


local biker = {
	`s_f_m_fembarber`
}

exports['qtarget']:AddTargetModel(biker, {
	options = {
		{
			event = 'esx_skin:barbershop',
			icon = 'fas fa-cut',
			label = "Barber Shop"
		},
	},
	distance = 3.5
})

-- menu

RegisterNetEvent('esx_skin:clothingShop', function()
    TriggerEvent('nh-context:sendMenu', {
		{
            id = 1,
            header = "Change clothing",
            txt = "Belanja Pakaian",
			params = {
				event = "esx_skin:clothingMenu"
			}
        },
        {
            id = 2,
            header = "Change Outfit",
            txt = "Mengganti Pakaian",
            params = {
                event = "esx_skin:pickNewOutfit",
                args = {
                    number = 1,
                    id = 2
                }
            }
        },
		{
            id = 3,
            header = "Save New Outfit",
            txt = "Menyimpan pakaian saat ini",
			params = {
				event = "esx_skin:saveOutfit"
			}
        },
		{
			id = 4,
            header = "Delete Outfit",
            txt = "Menghapus pakaian",
            params = {
                event = "esx_skin:deleteOutfitMenu",
                args = {
                    number = 1,
                    id = 2
                }
            }
        }
    })
end)

---- barbershop event
RegisterNetEvent('esx_skin:barbershop', function()
	local config = {
		ped = false,
		headBlend = false,
		faceFeatures = false,
		headOverlays = true,
		components = false,
		props = false
	}
	
	local barber = 250
	local ped = PlayerPedId()
	local oldPedAppearance = client.getPedAppearance(ped)
	Wait(150)
	client.startPlayerCustomization(function(appearance)
		if (appearance) then
			ESX.TriggerServerCallback('esx_skin:BuyOutfit', function(result) 
				if result then
					TriggerServerEvent('esx_skin:save', appearance)
				else
					client.setPlayerAppearance(oldPedAppearance)
				end
			end, barber)
		else
			client.setPlayerAppearance(oldPedAppearance)
			print('Canceled')
		end
	end, config)
end)

-- clothingshop menu
RegisterNetEvent('esx_skin:clothingMenu', function()
	local config = {
		ped = false,
		headBlend = false,
		faceFeatures = false,
		headOverlays = false,
		components = true,
		props = true
	}

	local price = 250
	local ped = PlayerPedId()
	local oldPedAppearance = client.getPedAppearance(ped)
	Wait(150)
	client.startPlayerCustomization(function(appearance)
		if (appearance) then
			ESX.TriggerServerCallback('esx_skin:BuyOutfit', function(result) 
				if result then
					TriggerServerEvent('esx_skin:save', appearance)
				else
					client.setPlayerAppearance(oldPedAppearance)
				end
			end, price)
		else
			client.setPlayerAppearance(oldPedAppearance)
			print('Canceled')
		end
	end, config)
end)

RegisterNetEvent('esx_skin:pickNewOutfit', function(data)
    local id = data.id
    local number = data.number
	TriggerEvent('esx_skin:getOutfits')
    TriggerEvent('nh-context:sendMenu', {
        {
            id = 1,
            header = "< Go Back",
            txt = "",
            params = {
                event = "esx_skin:clothingShop"
            }
        },
    })
	Wait(300)
	for i=1, #allMyOutfits, 1 do
		TriggerEvent('nh-context:sendMenu', {
			{
				id = (1 + i),
				header = allMyOutfits[i].name,
				txt = "",
				params = {
					event = 'esx_skin:setOutfit',
					args = allMyOutfits[i].pedModel, 
					arg2 = allMyOutfits[i].pedComponents, 
					arg3 = allMyOutfits[i].pedProps
				}
			},
		})
	end
end)

RegisterNetEvent('esx_skin:getOutfits')
AddEventHandler('esx_skin:getOutfits', function()
	TriggerServerEvent('esx_skin:getOutfits')
end)

RegisterNetEvent('esx_skin:sendOutfits')
AddEventHandler('esx_skin:sendOutfits', function(myOutfits)
	local Outfits = {}
	for i=1, #myOutfits, 1 do
		table.insert(Outfits, {id = myOutfits[i].id, name = myOutfits[i].name, pedModel = myOutfits[i].ped, pedComponents = myOutfits[i].components, pedProps = myOutfits[i].props})
	end
	allMyOutfits = Outfits
end)

RegisterNetEvent('esx_skin:setOutfit')
AddEventHandler('esx_skin:setOutfit', function(pedModel, pedComponents, pedProps)
	local playerPed = PlayerPedId()
	local currentPedModel = client.getPedModel(playerPed)
	if currentPedModel ~= pedModel then
    	client.setPlayerModel(pedModel)
		Wait(500)
		playerPed = PlayerPedId()
		client.setPedComponents(playerPed, pedComponents)
		client.setPedProps(playerPed, pedProps)
		local appearance = client.getPedAppearance(playerPed)
		TriggerServerEvent('esx_skin:save', appearance)
	else
		client.setPedComponents(playerPed, pedComponents)
		client.setPedProps(playerPed, pedProps)
		local appearance = client.getPedAppearance(playerPed)
		TriggerServerEvent('esx_skin:save', appearance)
	end
end)

RegisterNetEvent('esx_skin:saveOutfit', function()
	local keyboard = exports.ox_inventory:Keyboard('Name Outfit', {''})
	
	if keyboard then
		local playerPed = PlayerPedId()
		local pedModel = client.getPedModel(playerPed)
		local pedComponents = client.getPedComponents(playerPed)
		local pedProps = client.getPedProps(playerPed)
		Wait(500)
		TriggerServerEvent('esx_skin:saveOutfit', keyboard[1], pedModel, pedComponents, pedProps)

		ESX.ShowNotification('outfit name ' ..keyboard[1] .. ' saved', 'success')
	end
end)

RegisterNetEvent('esx_skin:deleteOutfitMenu', function(data)
    local id = data.id
    local number = data.number
	TriggerEvent('esx_skin:getOutfits')
	Wait(150)
    TriggerEvent('nh-context:sendMenu', {
        {
            id = 1,
            header = "< Go Back",
            txt = "",
            params = {
                event = "esx_skin:clothingShop"
            }
        },
    })
	for i=1, #allMyOutfits, 1 do
		TriggerEvent('nh-context:sendMenu', {
			{
				id = (1 + i),
				header = allMyOutfits[i].name,
				txt = "",
				params = {
					event = 'esx_skin:deleteOutfit',
					args = allMyOutfits[i].id
				}
			},
		})
	end
end)

RegisterNetEvent('esx_skin:deleteOutfit')
AddEventHandler('esx_skin:deleteOutfit', function(id)
	TriggerServerEvent('esx_skin:deleteOutfit', id)
	ESX.ShowNotification('Outfit Number ' .. id .. ' deleted', 'error')
end)

----- for admin
RegisterNetEvent('esx_skin:AdminMenu')
AddEventHandler('esx_skin:AdminMenu', function(submitCb, cancelCb)
	local config = {
		ped = true,
		headBlend = true,
		faceFeatures = true,
		headOverlays = true,
		components = true,
		props = true
	}
	
	local ped = PlayerPedId()
	local oldPedAppearance = client.getPedAppearance(ped)
	Wait(150)
	client.startPlayerCustomization(function(appearance)
		if (appearance) then
			TriggerServerEvent('esx_skin:save', appearance)
		else
			client.setPlayerAppearance(oldPedAppearance)
			print('Canceled')
		end
	end, config)
end)
