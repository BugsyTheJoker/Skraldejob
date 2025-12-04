local dumpsterCooldowns = {}

-- Betaling
local function givePayout(src, amount)
    if config.useframeworkpayout then
        -- QBCore
        local xPlayer = QBCore.Functions.GetPlayer(src)
        if xPlayer then
            xPlayer.addMoney(amount)
        end

        -- ESX
        local xPlayer = ESX.GetPlayerFromId(src)
        if xPlayer then
            xPlayer.addMoney(amount)
        end
    else
        -- Standalone udbetaling
        print(("[Skraldejob] Udbetalt %d til spiller %d"):format(amount, src))
    end
end

RegisterNetEvent('garbagejob:tryCollectDumpster')
AddEventHandler('garbagejob:tryCollectDumpster', function(dumpsterId)
    local src = source
    local now = os.time()

    if not Config.Dumpsters[dumpsterId] then
        print(("[GarbageJob] Player %d sendte ugyldigt dumpsterId: %s"):format(src, tostring(dumpsterId)))
        return
    end

    local last = dumpsterCooldowns[dumpsterId] or 0
    local diff = now - last

    if diff < Config.DumpsterCooldown then
        local remaining = Config.DumpsterCooldown - diff
        TriggerClientEvent('garbagejob:cooldown', src, remaining)
        return
    end

    -- Opdater cooldown
    dumpsterCooldowns[dumpsterId] = now

    -- Udbetal penge
    local payout = Config.PaymentPerDumpster or 0
    if payout > 0 then
        givePayout(src, payout )
    end

    TriggerClientEvent('garbagejob:collected', src, payout)
end)
