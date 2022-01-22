# ox_appearance

A fork of [fivem-appearance](https://github.com/pedr0fontoura/fivem-appearance/) written in Lua and providing some niche changes.

- Refer to the link above for all standard features.
- Basic support for ESX using skinchanger and esx_skin event handlers.
- Clothing stores and barber shops.

Appearance data can be saved to server-kvp, but requires setup to use included exports.  
Data is stored as `identifier:appearance`, where identifier can be any unique identifying value, i.e.  
- rockstar license
- citizenid
- auto-incrementing id
```lua
-- Example using cfx-server-data/player-data with a statebag
local id = Player(source).state['cfx.re/playerData@id']
local appearance = exports['fivem-appearance']:loadAppearance(source, id)

-- Example using ESX, if moving away from storing skin in the database
local skin = exports['fivem-appearance']:loadAppearance(xPlayer.source, xPlayer.identifier)
```

## Preview


<h3 align='center'><a href='https://streamable.com/t59gdt'>Video preview</a></h3>


![Customization Preview](https://imgur.com/VgNAvgC.png "Customization Preview")
![Customization Preview](https://i.imgur.com/wzY7XNu.png "Customization Preview")
![Customization Preview](https://imgur.com/B0m6g6q.png "Customization Preview")

## Convars

Since this is a client script, you will need to use **setr** to set these convars.

| Convar                  | Default | Type   | Description
| ---                     | ---     | ---    | ---
| fivem-appearance:locale | "en"    | string | Name of a file inside `locales/`. Choose the locale file for the customization interface.
| fivem-appearance:radar  | 1       | int    | Enables hiding/showing the radar when opening the customization interface.


config.cfg example:

```cfg
setr fivem-appearance:locale "en"
ensure fivem-appearance
```

## Client Exports

### Appearance

| Export              | Parameters                                     | Return            |
| ------------------- | ---------------------------------------------- | ----------------- |
| getPedModel         | ped: _number_                                  | _string_          |
| getPedComponents    | ped: _number_                                  | _PedComponent[]_  |
| getPedProps         | ped: _number_                                  | _PedProp[]_       |
| getPedHeadBlend     | ped: _number_                                  | _PedHeadBlend_    |
| getPedFaceFeatures  | ped: _number_                                  | _PedFaceFeatures_ |
| getPedHeadOverlays  | ped: _number_                                  | _PedHeadOverlays_ |
| getPedHair          | ped: _number_                                  | _PedHair_         |
| getPedAppearance    | ped: _number_                                  | _PedAppearance_   |
| setPlayerModel      | model: _string_                                | _Promise\<void\>_ |
| setPedComponent     | ped: _number_, component: _PedComponent_       | _void_            |
| setPedComponents    | ped: _number_, components: _PedComponent[]_    | _void_            |
| setPedProp          | ped: _number_, prop: _PedProp_                 | _void_            |
| setPedProps         | ped: _number_, props: _PedProp[]_              | _void_            |
| setPedFaceFeatures  | ped: _number_, faceFeatures: _PedFaceFeatures_ | _void_            |
| setPedHeadOverlays  | ped: _number_, headOverlays: _PedHeadOverlays_ | _void_            |
| setPedHair          | ped: _number_, hair: _PedHair_                 | _void_            |
| setPedEyeColor      | ped: _number_, eyeColor: _number_              | _void_            |
| setPlayerAppearance | appearance: _PedAppearance_                    | _void_            |
| setPedAppearance    | ped: _number_, appearance: _PedAppearance_     | _void_            |
| startPlayerCustomization | callback: _((appearance: PedAppearance \| undefined) => void)_, config? _CustomizationConfig_ | _void_ |

## Examples

**Customization command (Lua)**

```lua
RegisterCommand('customization', function()
  local config = {
    ped = true,
    headBlend = true,
    faceFeatures = true,
    headOverlays = true,
    components = true,
    props = true,
  }

  exports['fivem-appearance']:startPlayerCustomization(function(appearance)
    if appearance then
      print('Saved')
    else
      print('Canceled')
    end
  end, config)
end, false)
```

**Start player customization with callback (TypeScript)**

```typescript
const exp = (global as any).exports;

exp["fivem-appearance"].startPlayerCustomization((appearance) => {
  if (appearance) {
    console.log("Customization saved");
    emitNet("genericSaveAppearanceDataServerEvent", JSON.stringify(appearance));
  } else {
    console.log("Customization canceled");
  }
});
```

**Set player appearance (TypeScript)**

```typescript
const exp = (global as any).exports;

onNet("genericPlayerAppearanceLoadedServerEvent", (appearance) => {
  exp["fivem-appearance"].setPlayerAppearance(appearance);
});
```

## Data

Scripts used to generate some of the resource's data.

[Peds](https://gist.github.com/snakewiz/b37a18e92cc0b112ce0fa57b1096b96b "Gist")

## Credits

- [TomGrobbe](https://github.com/TomGrobbe) for the customization camera behavior
- [root-cause](https://github.com/root-cause) for some of the game data
- [xIAlexanderIx](https://github.com/xIAlexanderIx) for general inspiration
