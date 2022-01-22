local function isPedFreemodeModel(ped)
	local model = GetEntityModel(ped)
	return model == `mp_m_freemode_01` or model == `mp_f_freemode_01`
end

local pedModelsByHash do
	local size = #constants.PED_MODELS
	pedModelsByHash = table.create(0, size)
	for i = 1, size do
		local v = constants.PED_MODELS[i]
		pedModelsByHash[joaat(v)] = v
	end
end

---@param ped number entity id
---@return string
--- Get the model name from an entity's model hash
local function getPedModel(ped)
	return pedModelsByHash[GetEntityModel(ped)]
end

---@param ped number entity id
---@return table<number, table<string, number>>
local function getPedComponents(ped)
	local count = 0
	local size = #constants.PED_COMPONENTS_IDS
	local components = table.create(size, 0)

	for i = 1, size do
		local componentId = constants.PED_COMPONENTS_IDS[i]
		count += 1
		components[count] = {
			component_id = componentId,
			drawable = GetPedDrawableVariation(ped, componentId),
			texture = GetPedTextureVariation(ped, componentId),
		}
	end

	return components
end

---@param ped number entity id
---@return table<number, table<string, number>>
local function getPedProps(ped)
	local count = 0
	local size = #constants.PED_PROPS_IDS
	local props = table.create(size, 0)

	for i = 1, size do
		local propId = constants.PED_PROPS_IDS[i]
		count += 1
		props[count] = {
			prop_id = propId,
			drawable = GetPedPropIndex(ped, propId),
			texture = GetPedPropTextureIndex(ped, propId),
		}
	end
	return props
end

local function round(number, decimalPlaces)
	return tonumber(string.format('%.' .. (decimalPlaces or 0) .. 'f', number))
end

---@param ped number entity id
---@return table <number, number>
---```
---{ shapeFirst, shapeSecond, shapeThird, skinFirst, skinSecond, skinThird, shapeMix, skinMix, thirdMix }
---```
local function getPedHeadBlend(ped)
	-- GET_PED_HEAD_BLEND_DATA
	local shapeFirst, shapeSecond, shapeThird, skinFirst, skinSecond, skinThird, shapeMix, skinMix, thirdMix = Citizen.InvokeNative(0x2746BD9D88C5C5D0, ped, Citizen.PointerValueIntInitialized(0), Citizen.PointerValueIntInitialized(0), Citizen.PointerValueIntInitialized(0), Citizen.PointerValueIntInitialized(0), Citizen.PointerValueIntInitialized(0), Citizen.PointerValueIntInitialized(0), Citizen.PointerValueFloatInitialized(0), Citizen.PointerValueFloatInitialized(0), Citizen.PointerValueFloatInitialized(0))
	return {
		shapeFirst = shapeFirst,
		shapeSecond = shapeSecond,
		-- shapeThird = shapeThird,
		skinFirst = skinFirst,
		skinSecond = skinSecond,
		-- skinThird = skinThird,
		shapeMix = round(shapeMix, 1),
		skinMix = round(skinMix, 1),
		-- thirdMix = round(thirdMix, 1)
	}
end

---@param ped number entity id
---@return table<number, table<string, number>>
local function getPedFaceFeatures(ped)
	local size = #constants.FACE_FEATURES
	local faceFeatures = table.create(0, size)

	for i = 1, size do
		local feature = constants.FACE_FEATURES[i]
		faceFeatures[feature] = round(GetPedFaceFeature(ped, i-1), 1)
	end

	return faceFeatures
end

---@param ped number entity id
---@return table<number, table<string, number>>
local function getPedHeadOverlays(ped)
	local size = #constants.HEAD_OVERLAYS
	local headOverlays = table.create(0, size)

	for i = 1, size do
		local overlay = constants.HEAD_OVERLAYS[i]
		local _, value, _, firstColor, secondColor, opacity = GetPedHeadOverlayData(ped, i-1)

		if value ~= 255 then
			opacity = round(opacity, 1)
		else
			value = 0
			opacity = 0
		end

		headOverlays[overlay] = {style = value, opacity = opacity, color = firstColor, secondColor = secondColor}
	end

	return headOverlays
end

---@param ped number entity id
---@return table<string, number>
local function getPedHair(ped)
	return {
		style = GetPedDrawableVariation(ped, 2),
		color = GetPedHairColor(ped),
		highlight = GetPedHairHighlightColor(ped)
	}
end

local function getPedHairDecorationType(ped)
	local pedModel = GetEntityModel(ped)
	local hairDecorationType

	if pedModel == `mp_m_freemode_01` then
		hairDecorationType = 'male'
	elseif pedModel == `mp_f_freemode_01` then
		hairDecorationType = 'female'
	end

	return hairDecorationType
end

local function getPedHairDecoration(ped, hairStyle)
	local hairType = getPedHairDecorationType(ped)

	if hairType then
		if hairStyle and constants.HAIR_DECORATIONS[hairType][hairStyle] then
			return constants.HAIR_DECORATIONS[hairType][hairStyle]
		end
		return constants.HAIR_DECORATIONS[hairType][0]
	end
end

local function getPedAppearance(ped)
	local eyeColor = GetPedEyeColor(ped)

	return {
		model = getPedModel(ped) or 'mp_m_freemode_01',
		headBlend = getPedHeadBlend(ped),
		faceFeatures = getPedFaceFeatures(ped),
		headOverlays = getPedHeadOverlays(ped),
		components = getPedComponents(ped),
		props = getPedProps(ped),
		hair = getPedHair(ped),
		eyeColor = eyeColor < #constants.EYE_COLORS and eyeColor or 0
	}
end

local function setPlayerModel(model)
	if model and IsModelInCdimage(model) then
		RequestModel(model)
		while not HasModelLoaded(model) do Wait(0) end

		SetPlayerModel(PlayerId(), model)
		SetModelAsNoLongerNeeded(model)
		local playerPed = PlayerPedId()

		if isPedFreemodeModel(playerPed) then
			SetPedDefaultComponentVariation(playerPed)
			SetPedHeadBlendData(playerPed, 0, 0, 0, 0, 0, 0, 0, 0, 0, false)
		end

		return playerPed
	end
	return PlayerPedId()
end

local function setPedHeadBlend(ped, headBlend)
	if headBlend and isPedFreemodeModel(ped) then
		SetPedHeadBlendData(ped, headBlend.shapeFirst, headBlend.shapeSecond, headBlend.shapeThird, headBlend.skinFirst, headBlend.skinSecond, headBlend.skinThird, headBlend.shapeMix, headBlend.skinMix, headBlend.thirdMix, false)
	end
end

local function setPedFaceFeatures(ped, faceFeatures)
	if faceFeatures then
		for k, v in pairs(constants.FACE_FEATURES) do
			SetPedFaceFeature(ped, k-1, faceFeatures[v])
		end
	end
end

local function setPedHeadOverlays(ped, headOverlays)
	if headOverlays then
		for k, v in pairs(constants.HEAD_OVERLAYS) do
			local headOverlay = headOverlays[v]
			SetPedHeadOverlay(ped, k-1, headOverlay.style, headOverlay.opacity)

			if headOverlay.color then
				local colorType = 1
				if v == 'blush' or v == 'lipstick' or v == 'makeUp' then
					colorType = 2
				end

				SetPedHeadOverlayColor(ped, k-1, colorType, headOverlay.color, headOverlay.secondColor)
			end
		end
	end
end

local function setPedHair(ped, hair)
	local hairDecoration = getPedHairDecoration(ped, hair?.style)

	if hair then
		SetPedComponentVariation(ped, 2, hair.style, 0, 0)
		SetPedHairColor(ped, hair.color, hair.highlight)
		ClearPedDecorations(ped)
	end

	if hairDecoration then
		AddPedDecorationFromHashes(ped, hairDecoration[1], hairDecoration[2])
	end
end

local function setPedEyeColor(ped, eyeColor)
	if eyeColor then
		SetPedEyeColor(ped, eyeColor)
	end
end

local function setPedComponent(ped, component)
	if component then
		if isPedFreemodeModel(ped) and (component.component_id == 0 or component.component_id == 2) then
			return
		end

		SetPedComponentVariation(ped, component.component_id, component.drawable, component.texture, 0)
	end
end

local function setPedComponents(ped, components)
	if components then
		for k, v in pairs(components) do
			setPedComponent(ped, v)
		end
	end
end

local function setPedProp(ped, prop)
	if prop then
		if prop.drawable == -1 then
			ClearPedProp(ped, prop.prop_id)
		else
			SetPedPropIndex(ped, prop.prop_id, prop.drawable, prop.texture, false)
		end
	end
end

local function setPedProps(ped, props)
	if props then
		for k, v in pairs(props) do
			setPedProp(ped, v)
		end
	end
end

local function setPedAppearance(ped, appearance)
	if appearance then
		setPedComponents(ped, appearance.components)
		setPedProps(ped, appearance.props)

		if appearance.headBlend then setPedHeadBlend(ped, appearance.headBlend) end
		if appearance.faceFeatures then setPedFaceFeatures(ped, appearance.faceFeatures) end
		if appearance.headOverlays then setPedHeadOverlays(ped, appearance.headOverlays) end
		if appearance.eyeColor then setPedEyeColor(ped, appearance.eyeColor) end
		setPedHair(ped, appearance.hair)
	end
end

local function setPlayerAppearance(appearance)
	if appearance then
		setPlayerModel(appearance.model)
		setPedAppearance(PlayerPedId(), appearance)
	end
end

exports('getPedModel', getPedModel);
exports('getPedComponents', getPedComponents);
exports('getPedProps', getPedProps);
exports('getPedHeadBlend', getPedHeadBlend);
exports('getPedFaceFeatures', getPedFaceFeatures);
exports('getPedHeadOverlays', getPedHeadOverlays);
exports('getPedHair', getPedHair);
exports('getPedAppearance', getPedAppearance);

exports('setPlayerModel', setPlayerModel);
exports('setPedHeadBlend', setPedHeadBlend);
exports('setPedFaceFeatures', setPedFaceFeatures);
exports('setPedHeadOverlays', setPedHeadOverlays);
exports('setPedHair', setPedHair);
exports('setPedEyeColor', setPedEyeColor);
exports('setPedComponent', setPedComponent);
exports('setPedComponents', setPedComponents);
exports('setPedProp', setPedProp);
exports('setPedProps', setPedProps);
exports('setPlayerAppearance', setPlayerAppearance);
exports('setPedAppearance', setPedAppearance);

client = {
	getPedAppearance = getPedAppearance,
	setPlayerModel = setPlayerModel,
	setPedHeadBlend = setPedHeadBlend,
	setPedFaceFeatures = setPedFaceFeatures,
	setPedHair = setPedHair,
	setPedHeadOverlays = setPedHeadOverlays,
	setPedEyeColor = setPedEyeColor,
	setPedComponent = setPedComponent,
	setPedProp = setPedProp,
	setPlayerAppearance = setPlayerAppearance,
}
