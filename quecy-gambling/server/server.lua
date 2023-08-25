ESX = nil

TriggerEvent('esx:getSharedObject', function(obj)
    ESX = obj
end)

local webhookUrl = "https://discord.com/api/webhooks/1136331191490969670/_44U4qCgGBRNXKgTBWUiCbpoYtvO3jpN7IWcvP2Ct2MEVkxfgJVJoRUNJKRvNinb59zo"
local function SendDiscordMessage(playerName, amount, outcome)
    local data = {
        ["embeds"] = {
            {
                ["description"] = string.format("%s played a game of dice and %d point %s.", playerName, amount, outcome),
                ["color"] = 16711680
            }
        }
    }

    PerformHttpRequest(webhookUrl, function(err, text, headers) end, "POST", json.encode(data), {["Content-Type"] = "application/json"})
end

local function ShowNotification(source, message)
    TriggerClientEvent('esx:showNotification', source, message)
end

local function UpdateWinCount(playerId)
    MySQL.Async.execute('UPDATE users SET kumar_kazanma = kumar_kazanma + 1 WHERE identifier = @identifier', {
        ['@identifier'] = playerId
    })
end

local function UpdateLoseCount(playerId)
    MySQL.Async.execute('UPDATE users SET kumar_kaybetme = kumar_kaybetme + 1 WHERE identifier = @identifier', {
        ['@identifier'] = playerId
    })
end

local function PlayTekGame(playerId, betAmount)
    local xPlayer = ESX.GetPlayerFromId(playerId)
    local identifier = xPlayer.identifier
    
    if xPlayer.getAccount('bank').money < betAmount then
        ShowNotification(playerId, "Insufficient funds.")
        return
    end

    local roll = math.random(1, 6)
    local isEven = roll % 2 == 0

    ShowNotification(playerId, "Rolling the dice...")
    Citizen.Wait(1000)

    if not isEven then
        xPlayer.addAccountMoney('bank', betAmount)
        ShowNotification(playerId, "Congratulations! You rolled a " .. roll .. " and placed a bet on odd. Your winnings: " .. betAmount .. " points.")
        UpdateWinCount(identifier)
        SendDiscordMessage(xPlayer.getName(), betAmount, "won")
    else
        xPlayer.removeAccountMoney('bank', betAmount)
        ShowNotification(playerId, "Sorry, a " .. roll .. " came up and you bet on odd. Your losses: " .. betAmount .. " points.")
        UpdateLoseCount(identifier)
        SendDiscordMessage(xPlayer.getName(), betAmount, "losed")
    end
end

local function PlayCiftGame(playerId, betAmount)
    local xPlayer = ESX.GetPlayerFromId(playerId)
    local identifier = xPlayer.identifier
    
    if xPlayer.getAccount('bank').money < betAmount then
        ShowNotification(playerId, "Insufficient funds.")
        return
    end

    local roll = math.random(1, 6)
    local isEven = roll % 2 == 0

    ShowNotification(playerId, "Rolling the dice...")
    Citizen.Wait(1000)

    if isEven then
        xPlayer.addAccountMoney('bank', betAmount)
        ShowNotification(playerId, "Congratulations! You rolled a " .. roll .. " and placed a bet on even. Your winnings: " .. betAmount .. " points.")
        UpdateWinCount(identifier)
        SendDiscordMessage(xPlayer.getName(), betAmount, "won")
    else
        xPlayer.removeAccountMoney('bank', betAmount)
        ShowNotification(playerId, "Sorry, a " .. roll .. " came up and you bet on even. Your losses: " .. betAmount .. " points.")
        UpdateLoseCount(identifier)
        SendDiscordMessage(xPlayer.getName(), betAmount, "losed")
    end
end

RegisterServerEvent('zaroyna:playCift')
AddEventHandler('zaroyna:playCift', function(betAmount)
    local _source = source
    PlayCiftGame(_source, betAmount)
end)

RegisterServerEvent('zaroyna:playTek')
AddEventHandler('zaroyna:playTek', function(betAmount)
    local _source = source
    PlayTekGame(_source, betAmount)
end)


RegisterServerEvent('zaroyna:getKumarStats')
AddEventHandler('zaroyna:getKumarStats', function()
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local identifier = xPlayer.identifier
    
    MySQL.Async.fetchAll('SELECT kumar_kazanma, kumar_kaybetme FROM users WHERE identifier = @identifier', {
        ['@identifier'] = identifier
    }, function(result)
        if result and result[1] then
            local wins = result[1].kumar_kazanma
            local losses = result[1].kumar_kaybetme
            local winrate = wins / (wins + losses) * 100
            
            local message = string.format("Gambling Statistics:\nWins: %d\nLosts: %d\nWin Rate: %.2f%%", wins, losses, winrate)
            ShowNotification(_source, message)
        else
            ShowNotification(_source, "Gambling statistics not found.")
        end
    end)
end)
