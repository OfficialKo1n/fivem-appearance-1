-- Handle esx_skin and skinchanger events for compatibility

AddEventHandler('skinchanger:loadSkin', function(skin, cb)
	if not skin.model then skin.model = 'mp_m_freemode_01' end
	client.setPlayerAppearance(skin)
	if cb ~= nil then
		cb()
	end
end)

AddEventHandler('esx_skin:openSaveableMenu', function(submitCb, cancelCb)
	client.startPlayerCustomization(function (appearance)
		if (appearance) then
			--todo: trigger save event
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
