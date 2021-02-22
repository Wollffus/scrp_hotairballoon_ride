local function GetAmmoutbaloons( Player_ID, Character_ID )
    local Hasbaloons = MySQL.Sync.fetchAll( "SELECT * FROM baloons WHERE identifier = @identifier AND charid = @charid ", {
        ['identifier'] = Player_ID,
        ['charid'] = Character_ID
    } )
    if #Hasbaloons > 0 then return true end
    return false
end

RegisterServerEvent('scrp:buybaloon')
AddEventHandler( 'scrp:buybaloon', function ( args )

    local _src   = source
    local _price = args['Price']
    local _level = args['Level']
    local _model = args['Model']

	TriggerEvent('redemrp:getPlayerFromId', _src, function(user)
        u_identifier = user.getIdentifier()
        u_level = user.getLevel()
        u_charid = user.getSessionVar("charid")
        u_money = user.getMoney()
    end)

    local _resul = GetAmmoutbaloons( u_identifier, u_charid )

    if u_money <= _price then
        TriggerClientEvent( 'UI:DrawNotification', _src, Config.NoMoney )
        return
    end

    if u_level <= _level then
        TriggerClientEvent( 'UI:DrawNotification', _src, Config.LevelMissing )
        return
    end

	TriggerEvent('redemrp:getPlayerFromId', _src, function(user)
        user.removeMoney(_price)
    end)

		
    if _resul ~= true then
        local Parameters = { ['identifier'] = u_identifier, ['charid'] = u_charid, ['baloon'] = _model }
        MySQL.Async.execute("INSERT INTO baloons ( `identifier`, `charid`, `baloon` ) VALUES ( @identifier, @charid, @baloon )", Parameters)
        TriggerClientEvent( 'UI:DrawNotification', _src, 'You Rented a new baloon !' )
    else
        local Parameters = { ['identifier'] = u_identifier, ['charid'] = u_charid, ['baloon'] = _model }
        MySQL.Async.execute(" UPDATE baloons SET baloon = @baloon WHERE identifier = @identifier AND charid = @charid ", Parameters)
        TriggerClientEvent( 'UI:DrawNotification', _src, '' )
    end

end)

RegisterServerEvent( 'scrp:dropbaloon' )
AddEventHandler( 'scrp:dropbaloon', function ( )

    local _src = source

	TriggerEvent('redemrp:getPlayerFromId', _src, function(user)
	    u_identifier = user.getIdentifier()
	    u_charid = user.getSessionVar("charid")
	end)

    local Parameters = { ['identifier'] = u_identifier, ['charid'] = u_charid }
    local Hasbaloons = MySQL.Sync.fetchAll( "SELECT * FROM baloons WHERE identifier = @identifier AND charid = @charid ", Parameters )

    if Hasbaloons[1] then
        local baloon = Hasbaloons[1].baloon
        TriggerClientEvent("scrp:spawnbaloon", _src, baloon)
    end

end )
