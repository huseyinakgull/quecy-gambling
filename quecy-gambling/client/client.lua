local inCamera, sceneCam = false, false
local visible = false
local selected = nil

local betAmount = 2000

local function IncreaseBetAmount()
    betAmount = betAmount * 2
end

local function DecreaseBetAmount()
    if betAmount > 2000 then
        betAmount = betAmount / 2
    end
end

local Peds = {

    { 
        handle = nil, 
        model = "a_m_y_smartcaspat_01", 
        coords = {
            { handle = nil, coords = vector3(-99.363945007324, -430.97268676758, 36.211032867432), heading = 55.057880401611 },
        },
        name = "Gambler",
        type = "gambler",
        buttons = {
            { text = "Bet for Odd", icon = "bug", event = "ZarOyna_Quecy_Tek", param = "" },
            { text = "Bet for Even", icon = "bug", event = "ZarOyna_Quecy_Cift", param = "" },
            { text = "Increase Bet Amount", icon = "plus", event = "IncreaseBetAmount", param = "" },
            { text = "Decrease Bet Amount", icon = "minus", event = "DecreaseBetAmount", param = "" },    
            { text = "View Your Statistics", icon = "bug", event = "ZarOyna_Quecy_Istatistik", param = "" },
        }
    },
}


local BlipSprites = {
    ["gambler"] = 681,
}

Citizen.CreateThread(function()
	for k,v in pairs(Peds) do
        for _,x in pairs(v.coords) do
            local blip = AddBlipForCoord(x.coords.x, x.coords.y, x.coords.z)
            SetBlipSprite(blip, BlipSprites[v.type])
            SetBlipColour(blip, 4)
            SetBlipDisplay(blip, 5)
            SetBlipScale(blip, 0.4)
            SetBlipAsShortRange(blip, true)
            while not HasModelLoaded(v.model) do RequestModel(v.model) Citizen.Wait(100) end
            x.handle = CreatePed(4, v.model, x.coords.x, x.coords.y, x.coords.z-1.0, x.heading, false, false)
            SetPedDiesWhenInjured(x.handle, false)
            SetEntityInvincible(x.handle, true)
            FreezeEntityPosition(x.handle, true)
            TaskSetBlockingOfNonTemporaryEvents(x.handle, true)
            SetBlockingOfNonTemporaryEvents(x.handle, true)
            SetModelAsNoLongerNeeded(v.model)
        end
	end
end)

local DrawText3D = function(x, y, z, alpha, scale, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoords())
    if onScreen then
        SetTextScale(scale, scale)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, alpha)
        SetTextDropshadow(0)
        SetTextCentre(1)
        SetTextEntry("STRING")
        AddTextComponentString(text)
        DrawText(_x, _y)
        local factor = (string.len(text)) / 490
        DrawRect(_x,_y +0.0125, 0.030+ factor, 0.0250, 0, 0, 0, 125, alpha)
    end
end 

local DrawText3DS = function(x, y, z, alpha, scale, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoords())
    if onScreen then
        SetTextScale(scale, scale)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, alpha)
        SetTextDropshadow(0)
        SetTextCentre(1)
        SetTextEntry("STRING")
        AddTextComponentString(text)
        DrawText(_x, _y)
        local factor = (string.len(text)) / 490
        DrawRect(_x,_y +0.0125, 0.175+ factor, 0.0250, 0, 0, 0, 125, alpha)
    end
end 

local EntityDialog = function(k, x)
    local playerPed = PlayerPedId()
    Citizen.CreateThread(function()
        while inCamera do
            SetEntityVisible(playerPed, false, false)
            DisplayRadar(false)
            Citizen.Wait(0)
        end
        SetEntityVisible(playerPed, true, true)
        DisplayRadar(true)
    end)

    FreezeEntityPosition(playerPed, true)
	PlayAmbientSpeech1(Peds[k].coords[x].handle, "GENERIC_HI", "SPEECH_PARAMS_STANDARD")
	sceneCam = CreateCam("DEFAULT_SCRIPTED_CAMERA", false)
	SetCamActive(sceneCam, true)
	AttachCamToEntity(sceneCam, Peds[k].coords[x].handle, 0.0, 0.75, 0.6, true)
	SetCamRot(sceneCam, 0.0, 0.0, GetEntityHeading(Peds[k].coords[x].handle) - 180.0, 2)
	RenderScriptCams(1, 1, 750, 1, 0)

    for k,v in pairs(Peds[k].buttons) do
        v.translate = (v.text)
    end

    local npcName = Peds[k].name

        local text

        if npcName == "Gambler" then
        text = string.format("How about a dice game for %d points? You will try to know if it is odd or even.", betAmount)
      else
           text = "Hello, how can I help you?"
     end

    SendNUIMessage({
        action = "openDialog",
        ui = Peds[k].buttons,
        npcName = npcName,
        text = text,
    })
    SetNuiFocus(true, true)
end

Citizen.CreateThread(function()
    while true do
        local sleep = 1500
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        for k,x in pairs(Peds) do
            for _,v in pairs(x.coords) do
                local dst = #(playerCoords - v.coords)
                if dst <= 13 then
                    sleep = 1
                    if dst <= 7 and not inCamera then
                        local alpha = 255 - math.floor(dst) * 30
                        DrawText3D(v.coords.x, v.coords.y, v.coords.z+1.0, alpha, 0.35, x.name)
                        if dst <= 1.5 then
                            if IsControlJustPressed(0, 38) then
                                inCamera = true
                                Citizen.Wait(100)
                                selected = _
                                EntityDialog(k, _)
                            end
                        end
                    end
                end 
            end
        end
        Citizen.Wait(sleep)
    end
end)

local CloseUI = function()
    SendNUIMessage({
        action = "closeDialog"
    })
    SetNuiFocus(false, false)
    Citizen.Wait(400)
    inCamera = false
    ClearFocus()
    RenderScriptCams(false, false, 0, 1, 0)
    DestroyCam(sceneCam, false)
    FreezeEntityPosition(PlayerPedId(), false)
    return
end

local Menu = {
    ["ZarOyna_Quecy_Tek"] = function(param1, param2)
        TriggerServerEvent('zaroyna:playCift', betAmount)
    end,
    ["ZarOyna_Quecy_Cift"] = function(param1, param2)
        TriggerServerEvent('zaroyna:playTek', betAmount)
    end,
    ["ZarOyna_Quecy_Istatistik"] = function(param1, param2)
        TriggerServerEvent('zaroyna:getKumarStats')
    end,
    ["IncreaseBetAmount"] = function(param1, param2)
        IncreaseBetAmount()
    end,
    ["DecreaseBetAmount"] = function(param1, param2)
        DecreaseBetAmount()
    end,
}

RegisterNUICallback("closeDialog", function(data, cb)
    CloseUI()
    cb('ok')
end)

RegisterNUICallback("yes", function(data, cb)
    CloseUI()
    Citizen.Wait(250)
    if not Menu[data.button.event] then cb("ok") return end 
    Menu[data.button.event](data.button.event, data.button.param)
    cb("ok")
end)