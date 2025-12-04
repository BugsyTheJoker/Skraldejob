local jobActive = false
local hasTruck = false
local playerTruck = nil
local binsCollected = 0
local PAY_PER_BIN = 25

-- Start jobbet "knap"
local function ShowHelpText(Tryk /E/ for at starte jobbet)
    BeginTextCommandDisplayHelp("STRING")
    AddTextComponentSubstringPlayerName("Tryk /E/ for at starte jobbet")
    EndTextCommandDisplayHelp(0, false, true, -1)
end

-- Opret NPC'en ved jobstart
CreateThread(function()
    local npcInfo = Config.NPC

    RequestModel(npcInfo.model)
    while not HasModelLoaded(npcInfo.model) do
        Wait(10)
    end

    local ped = CreatePed(
        4,
        GetHashKey(npcInfo.model),
        npcInfo.coords.x,
        npcInfo.coords.y,
        npcInfo.coords.z - 1.0,
        npcInfo.coords.w,
        false,
        true
    )

    SetEntityInvincible(ped, true)
    FreezeEntityPosition(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
end)

-- Spawn skraldebil ved jobstart
local function SpawnTruck()
    if hasTruck and DoesEntityExist(playerTruck) then
        return
    end

    local model = GetHashKey(Config.Truck.model)
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(10)
    end

    local coords = Config.Truck.spawn
    playerTruck = CreateVehicle(
        model,
        coords.x, coords.y, coords.z,
        coords.w,
        true,
        false
    )

    SetVehicleOnGroundProperly(playerTruck)
    SetPedIntoVehicle(PlayerPedId(), playerTruck, -1)
    SetEntityAsMissionEntity(playerTruck, true, true)

    hasTruck = true
end

-- Start jobbet
local function StartGarbageJob()
    if jobActive then
        return
    end

    jobActive = true
    binsCollected = 0
    SpawnTruck()
    TriggerEvent('chat:addMessage', { args = { '^2Skraldejob', 'Formanden har en tur til dig! Find skraldespande på kortet og tøm dem.' } })
end

-- Counter der tæller tømte skraldespande og giver spiller besked om tømt skraldespand
local function CollectBin()
    if jobActive then
        binsCollected = binsCollected + 1
        TriggerEvent('chat:addMessage', { args = { '^2Skraldejob', 'Skraldespand tømt! Total: ' .. binsCollected } })
    end
end

-- Stop jobbet
local function StopGarbageJob()
    jobActive = false
    if hasTruck and DoesEntityExist(playerTruck) then
        DeleteVehicle(playerTruck)
    end
    hasTruck = false
    playerTruck = nil
    
    -- Beregner løn ud fra antal tømte skraldespande
    local totalPay = binsCollected * PAY_PER_BIN
    
    TriggerEvent('chat:addMessage', { args = { '^2Skraldejob', 'Formanden takker for din tid og engagement.' } })
    TriggerEvent('chat:addMessage', { args = { '^2Skraldejob', 'Du tømte ' .. binsCollected .. ' spande og tjente DKK' .. totalPay } })
    TriggerEvent('paycheck:givePaycheck', totalPay)
    
    binsCollected = 0
end

-- Interaktion med NPC
CreateThread(function()
    local npcInfo = Config.NPC
    local interactionDistance = npcInfo.interactionDistance

    while true do
        Wait(0)
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local distance = #(playerCoords - vector3(npcInfo.coords.x, npcInfo.coords.y, npcInfo.coords.z))

        if distance < interactionDistance then
            ShowHelpText("Tryk ~INPUT_CONTEXT~ for at tale med formanden")

            if IsControlJustReleased(0, 51) then -- E key
                if not jobActive then
                    StartGarbageJob()
                else
                    StopGarbageJob()
                end
            end
        end
    end
end)

-- Markør ved skraldespande - og lad spilleren tømme dem
CreateThread(function()
    while true do
        local sleep = 1000

        if jobActive then
            sleep = 0
            local ped = PlayerPedId()
            local pCoords = GetEntityCoords(ped)

            for i, dump in ipairs(Config.Dumpsters) do
                local dist = #(pCoords - dump.coords)

                if dist < 30.0 then
                    DrawMarker(1, dump.coords.x, dump.coords.y, dump.coords.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.3, 1.3, 0.5, 0, 255, 0, 120, false, true, 2, nil, nil, false)
                end

                if dist < 2.0 then
                    ShowHelpText("Tryk /E/ for at tømme skraldespanden")
                    if IsControlJustReleased(0, 38) then
                        TriggerServerEvent('garbagejob:tryCollectDumpster', i)
                    end
                end
            end
        end

        Wait(sleep)
    end
end)

-- Modtag besked hvis skraldespand er i cooldown
RegisterNetEvent('garbagejob:dumpsterCooldown')
AddEventHandler('garbagejob:dumpsterCooldown', function()
    TriggerEvent('chat:addMessage', { args = { '^2Skraldejob', 'Denne skraldespand er næsten lige blevet tømt. Prøv igen senere.' } })
end)

-- Modtag besked om succesfuld tømning
RegisterNetEvent('garbagejob:collected')
AddEventHandler('garbagejob:collected', function(payout)
    -- Lille animation kunne tilføjes her hvis du vil
    TriggerEvent('chat:addMessage', { args = { '^2Skraldejob', ('Du har tømt skraldespanden') } })
end)