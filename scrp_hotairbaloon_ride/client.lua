local keys = { ['G'] = 0x760A9C6F, ['S'] = 0xD27782E3, ['W'] = 0x8FD015D8, ['H'] = 0x24978A28, ['G'] = 0x5415BE48, ["ENTER"] = 0xC7B5340A, ['E'] = 0xDFF812F9 }

local pressTime = 0
local pressLeft = 0

local recentlySpawned = 0

local baloonModel;
local baloonspawn = {}
local Numberbaloonspawn = 0

local blips = {

	-- add dealers blips to map
	{ name = 'Valentine HOB Ride', sprite = 553094466, x= -354.6, y = 706.22, z = 116.93 }, -- Valentine HOB
}

-- do not touch code below
Citizen.CreateThread(function()
	for _, info in pairs(blips) do
        local blip = N_0x554d9d53f696d002(1664425300, info.x, info.y, info.z)
        SetBlipSprite(blip, info.sprite, 1)
		SetBlipScale(blip, 0.2)
		Citizen.InvokeNative(0x9CB1A1623062F402, blip, info.name)
    end  
end)

--Config baloons Here

local baloons = {
	    [1] = {
		['Text'] = "[$50] Hot Air Balloon",
		['SubText'] = "",
		['Desc'] = "",
		['Param'] = {
			['Price'] = 50,
			['Model'] = "HOTAIRBALLOON01",
			['Level'] = 1
		}
	}

}
local function IsNearZone ( location )

	local player = PlayerPedId()
	local playerloc = GetEntityCoords(player, 0)

	for i=1,#location do
		if #(playerloc - location[i]) < 3.0 then
			return true
		end
	end

end

local function DisplayHelp( _message, x, y, w, h, enableShadow, col1, col2, col3, a, centre )

	local str = CreateVarString(10, "LITERAL_STRING", _message, Citizen.ResultAsLong())

	SetTextScale(w, h)
	SetTextColor(col1, col2, col3, a)

	SetTextCentre(centre)

	if enableShadow then
		SetTextDropshadow(1, 0, 0, 0, 255)
	end

	Citizen.InvokeNative(0xADA9255D, 10);

	DisplayText(str, x, y)

end

local function ShowNotification( _message )
	local timer = 200
	while timer > 0 do
		DisplayHelp(_message, 0.50, 0.90, 0.6, 0.6, true, 161, 3, 0, 255, true, 10000)
		timer = timer - 1
		Citizen.Wait(0)
	end
end

Citizen.CreateThread( function()
	WarMenu.CreateMenu('id_baloon', 'Shop baloons')
	while true do
		if WarMenu.IsMenuOpened('id_baloon') then
			for i = 1, #baloons do
				if WarMenu.Button(baloons[i]['Text'], baloons[i]['SubText']) then
					TriggerServerEvent('scrp:buybaloon', baloons[i]['Param']) 
			end
			end
			WarMenu.Display()
		end
		Citizen.Wait(0)
	end
end)

Citizen.CreateThread(function()
	while true do

		if IsNearZone( Config.Coords ) then
			DisplayHelp(Config.Shoptext, 0.50, 0.95, 0.6, 0.6, true, 255, 255, 255, 255, true, 10000)
			if IsControlJustReleased(0, keys['E']) then
				WarMenu.OpenMenu('id_baloon')
			end
		end

		Citizen.Wait(0)
	end
end)

-- | Blips | --

Citizen.CreateThread(function()
	CreateBlips ( )
end)

-- | Notification | --

RegisterNetEvent('UI:DrawNotification')
AddEventHandler('UI:DrawNotification', function( _message )
	ShowNotification( _message )
end)

-- | Spawn baloon | --

RegisterNetEvent( 'scrp:spawnbaloon' )
AddEventHandler( 'scrp:spawnbaloon', function ( baloon )

	local player = PlayerPedId()

	local model = GetHashKey( baloon )
	local x,y,z = table.unpack( GetOffsetFromEntityInWorldCoords( player, 0.0, 4.0, 0.5 ) )

	local heading = GetEntityHeading( player ) + 90

	local oldIdOfThebaloon = idOfThebaloon
	
	local idOfThebaloon = Numberbaloonspawn + 1

	RequestModel( model )

	while not HasModelLoaded( model ) do
		Wait(500)
	end

	if ( baloonspawn[idOfThebaloon] ~= oldIdOfThebaloon ) then
		DeleteEntity( baloonspawn[idOfThebaloon].model )
	end

	baloonModel = CreateVehicle( model, x, y, z, heading, 1, 1 )

	SET_PED_DEFAULT_OUTFIT (baloonModel)
	Citizen.InvokeNative(0x23f74c2fda6e7c61, -1230993421, baloonModel)
	
	baloonspawn[idOfThebaloon] = { id = idOfThebaloon, model = baloonModel }

end )


function SET_PED_DEFAULT_OUTFIT ( baloon )
	return Citizen.InvokeNative(0xAF35D0D2583051B0, baloon, true )
end



-- | Timer | --

RegisterCommand("rideballoon", function(source, args, raw)
    if recentlySpawned <= 0 then
				recentlySpawned = 10
				TriggerServerEvent('scrp:dropbaloon')
			else
				TriggerEvent('chat:systemMessage', 'Please wait ' .. recentlySpawned .. ' seconds before dropping your baloon.')
				TriggerEvent('chat:addMessage', {
					color = { 171, 59, 36 },
					multiline = true,
					args = {"Anti-Spam", 'Please wait ' .. recentlySpawned .. ' seconds before dropping your baloon.'}
				})
			end
   end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
		if recentlySpawned > 0 then
			recentlySpawned = recentlySpawned - 1
		end
    end
end)
