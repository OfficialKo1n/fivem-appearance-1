if GetResourceState('es_extended'):find('start') then
	ESX = true
	AddEventHandler('skinchanger:loadSkin', function(skin, cb)
		print(skin)
		if not skin.model then skin.model = 'mp_m_freemode_01' end
		client.setPlayerAppearance(skin)
		if cb then cb() end
	end)

	AddEventHandler('esx_skin:openSaveableMenu', function(submitCb, cancelCb)
		client.startPlayerCustomization(function (appearance)
			if (appearance) then
				TriggerServerEvent('esx_skin:save', appearance)
				if submitCb then submitCb() end
			else
				if cancelCb then cancelCb() end
			end
		end, {
			ped = true,
			headBlend = true,
			faceFeatures = true,
			headOverlays = true,
			components = true,
			props = true
		})
	end)
end