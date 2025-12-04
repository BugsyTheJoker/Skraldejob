Config = {}

-- Chefen
Config.NPC = {
    model = 'a_m_m_fatlatin_01',
    coords = vector4(-469.03, -1718.16, 18.69, 284.68),
    interactionDistance = 2.0
}

-- Skraldebil
Config.Truck = {
    model = 'trash',
    spawnCoords = vector4(-450.3, -1706.65, 18.85, 298.7)
}

-- Skraldespande
Config.Dumpsters = {
    { coords = vector3(-304.89, -1515.74, 27.54), label = "Industrikvarter 1" },
    { coords = vector3(-298.33, -1498.10, 27.54), label = "Industrikvarter 2" },
    { coords = vector3(-291.98, -1479.35, 30.55), label = "Industrikvarter 3" }
}

-- Cooldown per skraldespand (sekunder)
    Config.DumpsterCooldown = 120

-- Betaling pr. tømte skraldespand
Config.PaymentPerDumpster = 50