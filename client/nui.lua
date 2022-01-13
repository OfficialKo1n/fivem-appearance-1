local client = client

RegisterNUICallback('appearance_get_locales', function(_, cb)
	local locales = LoadResourceFile(GetCurrentResourceName(), ('locales/%s.json'):format(GetConvar('fivem-appearance:locale', 'en')))
	cb(locales)
end)

RegisterNUICallback('appearance_get_settings_and_data', function(_, cb)
	cb({ client.getConfig(), client.getAppearance(), client.getAppearanceSettings() })
end)

RegisterNUICallback('appearance_set_camera', function(camera, cb)
	cb(1)
	client.setCamera(camera)
end)

RegisterNUICallback('appearance_turn_around', function(_, cb)
	cb(1)
	client.pedTurnAround(PlayerPedId())
end)

RegisterNUICallback('appearance_rotate_camera', function(direction, cb)
	cb(1)
	client.rotateCamera(direction)
end)

RegisterNUICallback('appearance_change_model', function(model, cb)
	local playerPed = client.setPlayerModel(model)

	SetEntityHeading(PlayerPedId(), client.getHeading())
	SetEntityInvincible(playerPed, true)
	TaskStandStill(playerPed, -1)

	cb({ client.getAppearanceSettings(), client.getPedAppearance(playerPed) })
end)

RegisterNUICallback('appearance_change_component', function(component, cb)
	local playerPed = PlayerPedId()
	client.setPedComponent(playerPed, component)
	cb(client.getComponentSettings(playerPed, component.component_id))
end)

RegisterNUICallback('appearance_change_prop', function(prop, cb)
	local playerPed = PlayerPedId()
	client.setPedProp(playerPed, prop)
	cb(client.getPropSettings(playerPed, prop.prop_id))
end)

RegisterNUICallback('appearance_change_head_blend', function(headBlend, cb)
	cb(1)
	client.setPedHeadBlend(PlayerPedId(), headBlend)
end)

RegisterNUICallback('appearance_change_face_feature', function(faceFeatures, cb)
	cb(1)
	client.setPedFaceFeatures(PlayerPedId(), faceFeatures)
end)

RegisterNUICallback('appearance_change_head_overlay', function(headOverlays, cb)
	cb(1)
	client.setPedHeadOverlays(PlayerPedId(), headOverlays)
end)

RegisterNUICallback('appearance_change_hair', function(hair, cb)
	cb(1)
	client.setPedHair(PlayerPedId(), hair)
end)

RegisterNUICallback('appearance_change_eye_color', function(eyeColor, cb)
	cb(1)
	client.setPedEyeColor(PlayerPedId(), eyeColor)
end)

RegisterNUICallback('appearance_save', function(appearance, cb)
	cb(1)
	client.exitPlayerCustomization(appearance)
end)

RegisterNUICallback('appearance_exit', function(_, cb)
	cb(1)
	client.exitPlayerCustomization()
end)
