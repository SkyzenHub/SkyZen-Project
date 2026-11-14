-- ==========================================
-- 🌟 SKYZENHUB - PET 99 🌟
-- ==========================================

if getgenv().KeyPassed == nil then getgenv().KeyPassed = true end
if not getgenv().KeyPassed then return end

getgenv().SkyZenHub_IsRunning = true 

local player = game:GetService("Players").LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Network = ReplicatedStorage:WaitForChild("Network")
local workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local vim = game:GetService("VirtualInputManager")
local CoreGui = game:GetService("CoreGui")

getgenv().IsMachineActionActive = false
getgenv().LastPrintedQuest = "" 
getgenv().HasDoneInitialRankTeleport = false
getgenv().IsDoingSpecificQuest = false
getgenv().DoingLegendaryQuest = false

-- =========================================================
-- 🔥 HACK THREAD IDENTITY (CỔNG LẤY DATA BẤT TỬ CHO PC/WAVE)
-- =========================================================
local SaveModule
pcall(function() SaveModule = require(ReplicatedStorage:WaitForChild("Library"):WaitForChild("Client"):WaitForChild("Save")) end)

local FetchSaveEvent = Instance.new("BindableEvent")
local LiveSaveData = nil

FetchSaveEvent.Event:Connect(function()
    pcall(function() LiveSaveData = SaveModule.Get() end)
end)

-- ==========================================
-- 0. HỆ THỐNG CONFIG (LƯU/TẢI DỮ LIỆU)
-- ==========================================
local configFileName = "SkyZenHub_Pet99_Config.json"
local hideKeyEnum = Enum.KeyCode.K

local Toggles = { Farm = false, FastFarm = false, InfPetSpeed = false, Orbs = false, Rank = false, Hatch = false, HatchBest = false, HideEgg = false, BuyZone = false, TpArea = false, GoldBest = false, GoldAll = false, RainBest = false, RainAll = false, BuySlot = false, BuyEggSlot = false, AutoBundleEnchant = false, AutoBundlePotion = false, AutoBundleFruit = false, AutoBundleFlag = false, Ultimate = false, AutoFarmArea = false, KaitunMode = false, AutoClaimMail = false, AntiAFK = true }
local RankConfig = { Comet = true, Jar = true, Pinata = true, Lucky = true, Flag = true, Fruit = true, Potion = true, Area = true, UpPotion = true, UpEnchant = true, Hatch = true, Gold = true, Rainbow = true, Legendary = true }
local WHConfig = { Url = "", PingID = "", TargetRank = 0, HasSentRank = false, PingEnabled = false }
local SavedEnchants = {} 
getgenv().uiScaleValue = 1.0
getgenv().MinRankArea = 5 
getgenv().TargetEquipSlots = 99
getgenv().TargetEggSlots = 99
getgenv().TargetUltimate = getgenv().TargetUltimate or "Ground Pound"
getgenv().AutoTapMode = getgenv().AutoTapMode or "Closest"
getgenv().LegendaryEggOffset = getgenv().LegendaryEggOffset or 1

getgenv().FastFarmSpeedMs = getgenv().FastFarmSpeedMs or 300 
getgenv().FastFarmTargets = getgenv().FastFarmTargets or 10 
getgenv().FarmRadius = getgenv().FarmRadius or 150

local function SaveConfig()
    if writefile then
        local dataToSave = {
            Toggles = Toggles, RankConfig = RankConfig, SavedEnchants = SavedEnchants,
            WHConfig = WHConfig,
            HideKey = hideKeyEnum.Name, UIScale = getgenv().uiScaleValue, MinRankArea = getgenv().MinRankArea,
            TargetEquipSlots = getgenv().TargetEquipSlots, TargetEggSlots = getgenv().TargetEggSlots,
            TargetUltimate = getgenv().TargetUltimate, AutoTapMode = getgenv().AutoTapMode,
            FastFarmSpeedMs = getgenv().FastFarmSpeedMs, FastFarmTargets = getgenv().FastFarmTargets, FarmRadius = getgenv().FarmRadius,
            LegendaryEggOffset = getgenv().LegendaryEggOffset
        }
        pcall(function() writefile(configFileName, HttpService:JSONEncode(dataToSave)) end)
    end
end

local function LoadConfig()
    if isfile and isfile(configFileName) then
        local success, data = pcall(function() return HttpService:JSONDecode(readfile(configFileName)) end)
        if success and type(data) == "table" then
            if data.Toggles then for k, v in pairs(data.Toggles) do Toggles[k] = v end end
            if data.RankConfig then for k, v in pairs(data.RankConfig) do RankConfig[k] = v end end
            if data.SavedEnchants then for k, v in pairs(data.SavedEnchants) do SavedEnchants[tonumber(k)] = v end end
            if data.WHConfig then for k, v in pairs(data.WHConfig) do WHConfig[k] = v end end
            if data.UIScale ~= nil then getgenv().uiScaleValue = data.UIScale end
            if data.MinRankArea ~= nil then getgenv().MinRankArea = data.MinRankArea end
            if data.TargetEquipSlots ~= nil then getgenv().TargetEquipSlots = math.min(99, tonumber(data.TargetEquipSlots) or 99) end
            if data.TargetEggSlots ~= nil then getgenv().TargetEggSlots = math.min(99, tonumber(data.TargetEggSlots) or 99) end
            if data.TargetUltimate ~= nil then getgenv().TargetUltimate = data.TargetUltimate end
            if data.AutoTapMode ~= nil then getgenv().AutoTapMode = data.AutoTapMode end
            if data.FastFarmSpeedMs ~= nil then getgenv().FastFarmSpeedMs = data.FastFarmSpeedMs end
            if data.FastFarmTargets ~= nil then getgenv().FastFarmTargets = data.FastFarmTargets end
            if data.FarmRadius ~= nil then getgenv().FarmRadius = data.FarmRadius end
            if data.LegendaryEggOffset ~= nil then getgenv().LegendaryEggOffset = data.LegendaryEggOffset end
            if data.HideKey then pcall(function() hideKeyEnum = Enum.KeyCode[data.HideKey] end) end
        end
    end
end
LoadConfig()

-- ==========================================
-- 🚀 ANTI-AFK CHUẨN XÁC
-- ==========================================
if not getgenv().SkyZenHub_AntiAFK_Setup then
    getgenv().SkyZenHub_AntiAFK_Setup = true
    pcall(function()
        player.Idled:Connect(function() 
            if Toggles.AntiAFK and getgenv().SkyZenHub_IsRunning then 
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
                VirtualUser:Button2Down(Vector2.new(0,0))
                task.wait(0.1)
                VirtualUser:Button2Up(Vector2.new(0,0))
            end 
        end)
    end)
    task.spawn(function()
        while task.wait(60) do
            if not getgenv().SkyZenHub_IsRunning then break end
            if Toggles.AntiAFK then 
                pcall(function()
                    vim:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
                    task.wait(0.1)
                    vim:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
                    local char = player.Character
                    if char then
                        local h = char:FindFirstChildOfClass("Humanoid")
                        if h then h.Jump = true end
                    end
                end) 
            end
        end
    end)
end

-- ==========================================
-- 0. TỪ ĐIỂN ZONE & LIBRARIES 
-- ==========================================
local Library, RankCmds, PlayerPet
pcall(function() Library = require(ReplicatedStorage:WaitForChild("Library")) end)
pcall(function() RankCmds = require(ReplicatedStorage:WaitForChild("Library"):WaitForChild("Client"):WaitForChild("RankCmds")) end)
pcall(function() PlayerPet = require(ReplicatedStorage:WaitForChild("Library"):WaitForChild("Client"):WaitForChild("PlayerPet")) end)

if PlayerPet and type(PlayerPet.CalculateSpeedMultiplier) == "function" and not getgenv().PetSpeedHooked then
    getgenv().PetSpeedHooked = true
    local originalCalc = PlayerPet.CalculateSpeedMultiplier
    PlayerPet.CalculateSpeedMultiplier = function(self, ...)
        if Toggles.InfPetSpeed and getgenv().SkyZenHub_IsRunning then return 75 end
        return originalCalc(self, ...)
    end
end

local function checkSuperComputer()
    local hasSC = false
    if SaveModule then pcall(function() local sd = SaveModule.Get(); if sd and ((sd.Rebirths and sd.Rebirths >= 4) or (sd.UnlockedZones and (sd.UnlockedZones["74 | Tech City"] or sd.UnlockedZones["100 | Void"]))) then hasSC = true end end) end
    return hasSC
end
local HAS_SUPER_COMPUTER = checkSuperComputer()

local ZoneDict, ZoneNameByNum = {}, {}
pcall(function()
    local zDir = ReplicatedStorage:FindFirstChild("__DIRECTORY") and ReplicatedStorage.__DIRECTORY:FindFirstChild("Zones")
    if zDir then
        for _, mod in ipairs(zDir:GetDescendants()) do
            if mod:IsA("ModuleScript") then
                local numStr = string.match(mod.Name, "^(%d+)")
                local clean = string.match(mod.Name, "%d+%s*|%s*(.+)")
                if numStr and clean then local num = tonumber(numStr); ZoneDict[clean] = num; ZoneDict[mod.Name] = num; ZoneNameByNum[num] = clean end
            end
        end
    end
end)

local function getCurrentWorldBounds()
    local pId = game.PlaceId
    if pId == 8737899170 then return 1, 99 elseif pId == 16498369169 then return 100, 199 elseif pId == 17503543197 then return 200, 239 elseif pId == 140403681187145 or pId == 17720827393 then return 240, 999 end 
    return 1, 999 
end

local function parseZoneNumber(zName, pId)
    local num = tonumber(string.match(zName, "^(%d+)"))
    if num then return num end
    local ln = string.lower(zName)
    if string.find(ln, "shop") or string.find(ln, "spawn") then
        if pId == 16498369169 then return 100 elseif pId == 17503543197 then return 200 elseif pId == 140403681187145 or pId == 17720827393 then return 240 else return 1 end
    end
    return ZoneDict[zName]
end

local CachedZones = nil
local function getAllZoneInstances()
    if CachedZones then return CachedZones end
    local zones = {}
    for _, mn in ipairs({"Map", "Map2", "Map3", "Map4"}) do
        local m = workspace:FindFirstChild(mn)
        if m then for _, z in ipairs(m:GetChildren()) do if not string.find(string.lower(z.Name), "vip") then table.insert(zones, z) end end end
    end
    CachedZones = zones; return zones
end

local function getZoneInstanceByNumber(zNum)
    local fallback = nil
    for _, z in ipairs(getAllZoneInstances()) do
        if parseZoneNumber(z.Name, game.PlaceId) == zNum then 
            if string.match(z.Name, "^(%d+)") then return z else fallback = z end
        end
    end
    return fallback
end

local function getZoneName(num)
    local pId = game.PlaceId
    if pId == 8737899170 and num == 1 then return "Spawn" elseif pId == 16498369169 and num == 100 then return "Tech Spawn" elseif pId == 17503543197 and num == 200 then return "Void Spawn" elseif (pId == 140403681187145 or pId == 17720827393) and num == 240 then return "Fantasy Spawn" end
    return ZoneNameByNum[num]
end

local function getHighestUnlockedZoneNumAndInst()
    local maxNum = -1
    local minZ, maxZ = getCurrentWorldBounds()
    local tm = player.PlayerGui:FindFirstChild("TeleportMap")
    if tm then
        for _, d in ipairs(tm:GetDescendants()) do
            if d.Name == "textHolder" then
                local tl, nl = d:FindFirstChild("Title"), d:FindFirstChild("Number")
                if tl and nl and tl:IsA("TextLabel") and nl:IsA("TextLabel") and tl.Text ~= "???" and tl.Text ~= "Locked" then
                    local nm = string.match(nl.Text, "%d+")
                    if nm then local n = tonumber(nm); if n and n >= minZ and n <= maxZ and n > maxNum then maxNum = n end end
                end
            end
        end
    end
    if maxNum == -1 and SaveModule then
        pcall(function() local d = SaveModule.Get() if d and d.UnlockedZones then for zn, _ in pairs(d.UnlockedZones) do local n = parseZoneNumber(zn, game.PlaceId) if n and n >= minZ and n <= maxZ and n > maxNum then maxNum = n end end end end)
    end
    return maxNum, getZoneInstanceByNumber(maxNum)
end

local function isAreaUnlocked(req) if HAS_SUPER_COMPUTER then return true end local m, _ = getHighestUnlockedZoneNumAndInst() return m >= req end

getgenv().EggNameToNumber = {}
getgenv().EggNumberToName = {}
local function getEggDataList()
    local edl = {}
    local pId = game.PlaceId
    local eDir = ReplicatedStorage:FindFirstChild("__DIRECTORY") and ReplicatedStorage.__DIRECTORY:FindFirstChild("Eggs")
    if eDir then
        for _, mod in ipairs(eDir:GetDescendants()) do
            if mod:IsA("ModuleScript") then
                local s, d = pcall(require, mod)
                if s and type(d) == "table" and d.eggNumber then
                    local eNum = d.eggNumber; local iv = true
                    if pId == 8737899170 and eNum > 112 then iv = false elseif pId == 16498369169 and (eNum <= 112 or eNum >= 213) then iv = false elseif pId == 17503543197 and (eNum < 213 or eNum >= 240) then iv = false elseif (pId == 140403681187145 or pId == 17720827393) and eNum < 240 then iv = false end
                    if iv then
                        local cn = string.match(mod.Name, "|%s*(.+)") or mod.Name
                        getgenv().EggNameToNumber[cn] = eNum; getgenv().EggNumberToName[eNum] = cn
                        table.insert(edl, { name = cn, num = eNum, zoneNum = d.zoneNumber or eNum })
                    end
                end
            end
        end
    end
    table.sort(edl, function(a, b) return a.num < b.num end); return edl
end
local GLOBAL_EGG_DATA = getEggDataList()

local function getEnchantDataList()
    local l, m = {}, {}
    local eDir = ReplicatedStorage:FindFirstChild("__DIRECTORY") and ReplicatedStorage.__DIRECTORY:FindFirstChild("Enchants")
    if eDir then for _, mod in ipairs(eDir:GetDescendants()) do if mod:IsA("ModuleScript") then local cn = string.match(mod.Name, "|%s*(.+)") or mod.Name if not m[cn] then m[cn] = true; table.insert(l, cn) end end end end
    table.sort(l); return l
end
local GLOBAL_ENCHANT_LIST = getEnchantDataList()

local function getUltimateList()
    local l = {}
    local uDir = ReplicatedStorage:FindFirstChild("__DIRECTORY") and ReplicatedStorage.__DIRECTORY:FindFirstChild("Ultimates")
    if uDir then for _, mod in ipairs(uDir:GetChildren()) do if mod:IsA("ModuleScript") then table.insert(l, string.match(mod.Name, "|%s*(.+)") or mod.Name) end end end
    table.sort(l); if #l == 0 then l = {"Pet Surge", "Ground Pound", "Black Hole", "Tornado", "Tsunami", "Lightning Storm", "Hidden Treasure", "Nightmare", "TNT Shower", "UFO"} end; return l
end
local GLOBAL_ULTIMATE_LIST = getUltimateList()

-- ==========================================
-- 🔄 KHÔI PHỤC LOGIC TÌM KIẾM ĐỒ CHUẨN XÁC
-- ==========================================
local function getPetsFromEgg(eggName)
    local pets = {}
    local eggsDir = ReplicatedStorage:FindFirstChild("__DIRECTORY") and ReplicatedStorage.__DIRECTORY:FindFirstChild("Eggs")
    if eggsDir and eggName then
        for _, mod in ipairs(eggsDir:GetDescendants()) do
            local cleanName = string.match(mod.Name, "|%s*(.+)") or mod.Name
            if cleanName == eggName then
                local s, d = pcall(require, mod)
                if s and type(d) == "table" then
                    local target = d.pets or d.Pets or d.drops or d.Drops or d.items or d.Items or d.rewards
                    if target and type(target) == "table" then
                        for _, p in pairs(target) do 
                            if type(p) == "table" and (p[1] or p.id or p.name) then 
                                pets[tostring(p[1] or p.id or p.name)] = true 
                            elseif type(p) == "string" then 
                                pets[p] = true 
                            end
                        end
                    end
                end
                break
            end
        end
    end
    return pets
end

local function getOrderedConsumablePotionUID(targetTier)
    local orderList = {"Coins", "Damage", "Diamonds", "Lucky Eggs", "Treasure Hunter"}
    if SaveModule then
        local success, data = pcall(function() return SaveModule.Get() end)
        if success and data and data.Inventory and data.Inventory.Potion then
            for _, name in ipairs(orderList) do
                local fallbackUid, fallbackTier = nil, 999
                for uid, item in pairs(data.Inventory.Potion) do
                    if tostring(item.id) == name then
                        local tier, amount = tonumber(item.tn) or 1, tonumber(item._am) or 1
                        if targetTier then
                            if tier == tonumber(targetTier) and amount >= 1 then return uid, name end
                        else
                            if tier < fallbackTier and amount >= 1 then fallbackTier = tier; fallbackUid = uid end
                        end
                    end
                end
                if not targetTier and fallbackUid then return fallbackUid, name end
            end
        end
    end
    return nil, nil
end

local function getLiveUID(iName, tNum, cat, minAmt)
    if SaveModule then local s, d = pcall(SaveModule.Get); if s and d and d.Inventory and d.Inventory[cat] then for u, dt in pairs(d.Inventory[cat]) do if tostring(dt.id) == iName and (tonumber(dt.tn) or 1) == tonumber(tNum) and (tonumber(dt._am) or 1) >= (minAmt or 1) then return u end end end end
    return nil
end

local function getMiscItemUID(iName, avoidShiny)
    if SaveModule then local s, d = pcall(SaveModule.Get); if s and d and d.Inventory then for _, c in ipairs({"Misc", "Lootbox", "Consumable", "Fruit"}) do if d.Inventory[c] then for u, dt in pairs(d.Inventory[c]) do if tostring(dt.id) == iName then if not (avoidShiny and dt.sh) then return u end end end end end end end
    return nil
end

local function getValidBreakZone(zoneInstance)
    local interact = zoneInstance:FindFirstChild("INTERACT")
    if interact then
        local spawnFolder = interact:FindFirstChild("BREAKABLE_SPAWNS")
        if spawnFolder then
            local main = spawnFolder:FindFirstChild("Main")
            if main then return main end
        end
    end
    return nil
end

local function getZonePosition(zInst)
    if not zInst then return Vector3.new(0,0,0) end
    if zInst:IsA("Model") or zInst:IsA("BasePart") then return zInst:GetPivot().Position end
    local i = zInst:FindFirstChild("INTERACT")
    if i then local sf = i:FindFirstChild("BREAKABLE_SPAWNS") if sf and sf:FindFirstChild("Main") then return sf.Main:GetPivot().Position end end
    local p = zInst:FindFirstChild("PERSISTENT")
    if p then local fp = p:FindFirstChildWhichIsA("BasePart", true) if fp then return fp.Position end end
    local ap = zInst:FindFirstChildWhichIsA("BasePart", true); if ap then return ap.Position end
    return Vector3.new(0,0,0)
end

local function getCurrentAreaNumber()
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart"); if not hrp then return 0 end
    local ray = workspace:Raycast(hrp.Position, Vector3.new(0, -100, 0), (function() local p = RaycastParams.new(); p.FilterDescendantsInstances = {player.Character, workspace:FindFirstChild("__THINGS")}; p.FilterType = Enum.RaycastFilterType.Exclude; return p end)())
    if ray and ray.Instance then
        local c = ray.Instance
        while c and c ~= workspace do
            if c.Parent and string.match(string.lower(c.Parent.Name), "map") then local n = parseZoneNumber(c.Name, game.PlaceId) if n then return n end end
            c = c.Parent
        end
    end
    local md, an = math.huge, 0
    for _, z in ipairs(getAllZoneInstances()) do local pos = getZonePosition(z); if pos ~= Vector3.new(0,0,0) then local dist = (hrp.Position - pos).Magnitude; if dist < md then md = dist; an = parseZoneNumber(z.Name, game.PlaceId) or 0 end end end
    return an
end

local function getPlayerRank() 
    local r = 1; pcall(function() if SaveModule then local d = SaveModule.Get(); if d and d.Rank then r = d.Rank end end end); return r 
end

local function getMaxHatchAmount() 
    local a = 1
    pcall(function() 
        if SaveModule then 
            local d = SaveModule.Get(); 
            if d then 
                a = d.EggHatchCount or (d.EggSlotsPurchased or 0) + 1 
            end 
        end 
    end)
    return a 
end

local function getBestEggNameForPlayer()
    local mZ, _ = getHighestUnlockedZoneNumAndInst()
    if mZ == 100 then for i = #GLOBAL_EGG_DATA, 1, -1 do if GLOBAL_EGG_DATA[i].num == 113 then return GLOBAL_EGG_DATA[i].name end end end
    local bN, mE = nil, 0; for _, e in ipairs(GLOBAL_EGG_DATA) do if e.zoneNum <= mZ and e.num > mE then mE = e.num; bN = e.name end end; return bN
end

local function stealthTeleport(zInst)
    local c = player.Character or player.CharacterAdded:Wait()
    local hrp = c:WaitForChild("HumanoidRootPart", 5)
    if not hrp or not zInst then return false end
    local p = zInst:FindFirstChild("PERSISTENT"); if not p then return false end
    local tp = p:FindFirstChild("Teleport") or p:FindFirstChildWhichIsA("BasePart", true); if not tp then return false end
    local tCF = tp:IsA("Model") and tp:GetPivot() or tp.CFrame
    hrp.AssemblyLinearVelocity = Vector3.new(0,0,0); hrp.CFrame = tCF * CFrame.new(0, 15, 0)
    local bT = nil; local t = tick()
    repeat task.wait(0.1) local i = zInst:FindFirstChild("INTERACT") if i then local sf = i:FindFirstChild("BREAKABLE_SPAWNS") if sf then bT = sf:FindFirstChild("Main") end end until bT or (tick() - t > 3.5)
    if not bT then return false end
    pcall(function() Network.Pets_UnequipAll:FireServer() end); task.wait(0.1); pcall(function() Network.Pets_Restore:FireServer() end)
    hrp.AssemblyLinearVelocity = Vector3.new(0,0,0); hrp.CFrame = bT:IsA("Model") and bT:GetPivot() * CFrame.new(0, 5, 0) or bT.CFrame * CFrame.new(0, 5, 0)
    return true
end

local function forceTeleportToBestZone()
    local mN, bI = getHighestUnlockedZoneNumAndInst()
    if bI and stealthTeleport(bI) then return true end
    local zN = getZoneName(mN)
    if zN then pcall(function() Network.Teleports_RequestTeleport:InvokeServer(zN) end); task.wait(1.5); local rI = getZoneInstanceByNumber(mN); if rI then return stealthTeleport(rI) end return true end
    return false
end

local function teleportToZoneNum(zNum)
    local inst = getZoneInstanceByNumber(zNum)
    if inst and stealthTeleport(inst) then return true end
    local zN = getZoneName(zNum)
    if zN then pcall(function() Network.Teleports_RequestTeleport:InvokeServer(zN) end); task.wait(1.5); local rI = getZoneInstanceByNumber(zNum); if rI then return stealthTeleport(rI) end return true end
    return false
end

local function teleportToEgg(eName)
    local n = getgenv().EggNameToNumber[eName]; if not n then return end
    local cN = tostring(n) .. " - Egg Capsule"; local t = workspace:FindFirstChild("__THINGS"); if not t then return end
    local pId, cap = game.PlaceId, nil
    if pId == 17503543197 then local ef = t:FindFirstChild("Eggs") if ef then cap = ef:FindFirstChild(cN, true) end end
    if not cap then local ze = t:FindFirstChild("ZoneEggs") if ze then cap = ze:FindFirstChild(cN, true) end end
    if not cap then local ef = t:FindFirstChild("Eggs") if ef then cap = ef:FindFirstChild(cN, true) end end
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if cap and hrp then hrp.AssemblyLinearVelocity = Vector3.new(0,0,0); hrp.CFrame = cap:GetPivot() * CFrame.new(0, 4, 6) end
end

local function safeMachineFire(mTab, rName, uid, amt)
    local r = Network:FindFirstChild(rName); if not r then return end
    local el = Network:FindFirstChild("EventLog_Once")
    local pId = game.PlaceId
    local uSC = HAS_SUPER_COMPUTER and (pId == 16498369169 or pId == 17503543197 or pId == 140403681187145 or pId == 17720827393)
    if el then pcall(function() el:FireServer("OpenTab", uSC and "SuperMachine" or mTab) end) task.wait(0.1) end
    pcall(function() r:InvokeServer(uid, amt) end)
    if el then task.wait(0.1) pcall(function() el:FireServer("CloseTab", uSC and "SuperMachine" or mTab) end) end
end

local function performMachineAction(act, zNum, mName)
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart"); if not hrp then return end
    local pId = game.PlaceId; local uSC = HAS_SUPER_COMPUTER and (pId == 16498369169 or pId == 17503543197 or pId == 140403681187145 or pId == 17720827393)
    if uSC then if pId == 16498369169 then zNum = 100 elseif pId == 17503543197 then zNum = 200 elseif pId == 140403681187145 or pId == 17720827393 then zNum = 240 end; mName = "SuperMachine" end
    getgenv().IsMachineActionActive = true; local o = hrp.CFrame; teleportToZoneNum(zNum); task.wait(0.5) 
    local appr = Network:FindFirstChild("Machines: Mark Approached"); if appr and mName then pcall(function() appr:FireServer(mName) end) end
    pcall(act); task.wait(0.3); hrp.CFrame = o; getgenv().IsMachineActionActive = false
end

local function getBulkUpgradableItems(category, requiredCrafts, targetTierNum)
    local results = {} 
    local orderList = category == "Potion" and {"Coins", "Damage", "Diamonds", "Lucky Eggs", "Treasure Hunter", "Speed"} or {"Treasure Hunter", "Tap Power", "Strong Pets", "Speed", "Magnet", "Lucky Eggs", "Diamonds", "Criticals", "Coins"}
    local craftsRemaining = requiredCrafts

    if SaveModule then
        local success, data = pcall(function() return SaveModule.Get() end)
        if success and data and data.Inventory and data.Inventory[category] then
            if targetTierNum then
                local targetInputTier = targetTierNum - 1
                for _, name in ipairs(orderList) do
                    for uid, item in pairs(data.Inventory[category]) do
                        if tostring(item.id) == name and (tonumber(item.tn) or 1) == targetInputTier then
                            local amount = tonumber(item._am) or 1
                            local possibleCrafts = math.floor(amount / 5)
                            if possibleCrafts > 0 then
                                local craftsToTake = math.min(possibleCrafts, craftsRemaining)
                                table.insert(results, {uid = uid, name = name, crafts = craftsToTake})
                                craftsRemaining = craftsRemaining - craftsToTake
                                if craftsRemaining <= 0 then return results end
                            end
                        end
                    end
                end
            else
                for currentSearchTier = 1, 7 do
                    for _, name in ipairs(orderList) do
                        for uid, item in pairs(data.Inventory[category]) do
                            if tostring(item.id) == name and (tonumber(item.tn) or 1) == currentSearchTier then
                                local isMax = false
                                if category == "Potion" and name == "Speed" and currentSearchTier >= 3 then isMax = true end
                                if category == "Enchant" and name == "Magnet" and currentSearchTier >= 3 then isMax = true end
                                if category == "Enchant" and name == "Speed" and currentSearchTier >= 5 then isMax = true end
                                if currentSearchTier >= 8 then isMax = true end

                                if not isMax then
                                    local amount = tonumber(item._am) or 1
                                    local possibleCrafts = math.floor(amount / 5)
                                    if possibleCrafts > 0 then
                                        local craftsToTake = math.min(possibleCrafts, craftsRemaining)
                                        table.insert(results, {uid = uid, name = name, crafts = craftsToTake})
                                        craftsRemaining = craftsRemaining - craftsToTake
                                        if craftsRemaining <= 0 then return results end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return results
end

-- ==========================================
-- 🛠️ HÀM TẮT POPUP BẰNG CLICK ẢO SIÊU MƯỢT
-- ==========================================
task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            for _, g in ipairs(player.PlayerGui:GetChildren()) do 
                if g:IsA("ScreenGui") and g.Enabled then
                    local n = string.lower(g.Name)
                    if string.find(n, "rankup") or string.find(n, "masteryperk") or string.find(n, "levelup") or string.find(n, "newperk") then 
                        local cam = workspace.CurrentCamera
                        if cam then
                            local cx = cam.ViewportSize.X * 0.5
                            local cy = cam.ViewportSize.Y * 0.5
                            for i = 1, 3 do
                                pcall(function() VirtualUser:ClickButton1(Vector2.new(cx, cy)) end)
                                pcall(function() vim:SendMouseButtonEvent(cx, cy, 0, true, game, 1) end)
                                task.wait(0.1)
                                pcall(function() vim:SendMouseButtonEvent(cx, cy, 0, false, game, 1) end)
                                task.wait(0.1)
                            end
                        end
                    end
                end 
            end
        end)
    end
end)

local function GetActiveRankQuests()
    local quests = {}
    local goalsSide = player.PlayerGui:FindFirstChild("GoalsSide")
    local holder = goalsSide and goalsSide:FindFirstChild("QuestsHolder", true)
    if holder then
        for _, item in pairs(holder:GetChildren()) do
            local titleLbl = item:FindFirstChild("Title", true) or item:FindFirstChild("Desc", true)
            if titleLbl and titleLbl.Text ~= "" then
                local text = string.lower(titleLbl.Text)
                if not string.find(text, "rankup ready") then
                    
                    local questFullText = ""
                    for _, desc in ipairs(item:GetDescendants()) do
                        if desc:IsA("TextLabel") and desc.Text ~= "" then
                            questFullText = questFullText .. " " .. string.lower(desc.Text)
                        end
                    end
                    
                    local prog = 0
                    local maxNum = 1
                    local slash = string.char(47)
                    local pattern = "(%d+)%s*" .. slash .. "%s*(%d+)"
                    local pMatch, mMatch = string.match(questFullText, pattern)
                    
                    if pMatch and mMatch then
                        prog = tonumber(pMatch)
                        maxNum = tonumber(mMatch)
                    else
                        local n = string.match(text, "(%d+)")
                        maxNum = n and tonumber(n) or 1
                    end
                    
                    local remaining = math.max(1, maxNum - prog)
                    table.insert(quests, {txt = text, remaining = remaining, raw = titleLbl.Text, ignored = false})
                end
            end
        end
    end
    return quests
end

-- ==========================================
-- TỐI ƯU ENCHANT DATA THREAD-SAFE (CHO WAVE PC)
-- ==========================================
local function getEquippedEnchants_Live()
    local equipped = {}
    if LiveSaveData and LiveSaveData.EquippedEnchants then
        for slotStr, uid in pairs(LiveSaveData.EquippedEnchants) do
            local slotNum = tonumber(string.match(slotStr, "%d+"))
            if slotNum then
                local eName, eTier, isTls = "Unknown", 1, false
                if LiveSaveData.Inventory and LiveSaveData.Inventory.Enchant and LiveSaveData.Inventory.Enchant[uid] then
                    eName = tostring(LiveSaveData.Inventory.Enchant[uid].id)
                    local tierRaw = tonumber(LiveSaveData.Inventory.Enchant[uid].tn)
                    if tierRaw then eTier = tierRaw else eTier = 99; isTls = true end
                end
                equipped[slotNum] = {name = eName, tier = eTier, uid = uid, isTierless = isTls}
            end
        end
    end
    return equipped
end

local function getEquippedEnchants()
    local equipped = {}
    pcall(function()
        local data = SaveModule.Get()
        if data and data.EquippedEnchants then
            for slotStr, uid in pairs(data.EquippedEnchants) do
                local slotNum = tonumber(string.match(slotStr, "%d+"))
                if slotNum then
                    local eName, eTier, isTls = "Unknown", 1, false
                    if data.Inventory and data.Inventory.Enchant and data.Inventory.Enchant[uid] then
                        eName = tostring(data.Inventory.Enchant[uid].id)
                        local tierRaw = tonumber(data.Inventory.Enchant[uid].tn)
                        if tierRaw then eTier = tierRaw else eTier = 99; isTls = true end
                    end
                    equipped[slotNum] = {name = eName, tier = eTier, uid = uid, isTierless = isTls}
                end
            end
        end
    end)
    return equipped
end

local function getEnchantMasteryLvl()
    local lvl = nil 
    pcall(function()
        local masteryUI = player.PlayerGui:FindFirstChild("Main") and player.PlayerGui.Main:FindFirstChild("Mastery")
        if masteryUI then
            local enchantsFrame = masteryUI:FindFirstChild("Container", true) and masteryUI.Container:FindFirstChild("ItemsFrame") and masteryUI.Container.ItemsFrame:FindFirstChild("Enchants")
            if enchantsFrame and enchantsFrame:FindFirstChild("LevelTitle") then lvl = tonumber(string.match(enchantsFrame.LevelTitle.Text, "%d+")) end
        end
    end)
    return lvl
end

local targetEggName = nil
local lastRankClaim, lastItemUse = 0, 0
local globalIgnoredQuests = {}
local rankFruitList = {"Rainbow Fruit", "Watermelon", "Pineapple", "Orange", "Banana", "Apple"}
local currentRankFruitIndex = 1
local lastRankFruitProgress = -1
local ROMAN_MAP = {["i"] = 1, ["ii"] = 2, ["iii"] = 3, ["iv"] = 4, ["v"] = 5, ["vi"] = 6, ["vii"] = 7, ["viii"] = 8, ["ix"] = 9, ["x"] = 10}

-- ==========================================
-- 🎨 SKYZENHUB UI
-- ==========================================
local WorldStatus, ZoneStatus, ConfirmFrame, Main, ToggleHubUI
local AddTab, CreateHeader, CreateStatusLabel, CreateCleanToggle, CreateButton, CreateInput, SetupCollapse

do
    local TS = game:GetService("TweenService")
    local TITLE = "SKYZENHUB (Pet Simulator 99)"
    local PHOTO_URL = "https://raw.githubusercontent.com/SkyzenHub/FOTO-SKYZEN/refs/heads/main/file_00000000f5548211add457d612909d05.png"
    local LOADING_URL = "https://raw.githubusercontent.com/SkyzenHub/FOTO-SKYZEN/refs/heads/main/1794024795815.jpg"
    local LOAD_TIME = 10

    local RED = Color3.fromRGB(0, 0, 0)
    local DARK = Color3.fromRGB(10, 10, 14)
    local GREY = Color3.fromRGB(60, 60, 70)
    local OFFFILL = Color3.fromRGB(55, 55, 64)
    local PANEL = Color3.fromRGB(18, 18, 24)

    local parentGui = CoreGui
    if not pcall(function() local _ = CoreGui.Name end) then parentGui = player:WaitForChild("PlayerGui") end
    if type(gethui) == "function" then pcall(function() local h = gethui() if h then parentGui = h end end) end
    if parentGui:FindFirstChild("SkyzenGUI") then parentGui.SkyzenGUI:Destroy() end

    local gui = Instance.new("ScreenGui")
    gui.Name = "SkyzenGUI"
    gui.ResetOnSpawn = false
    gui.Parent = parentGui

    local function isImage(data)
        if type(data) ~= "string" or #data < 100 then return false end
        local h = data:sub(1, 4)
        return h == "\137PNG" or h:sub(1, 2) == "\255\216" or h == "RIFF"
    end

    local function loadImage(url, fname)
        if url == "" then return nil, "empty URL" end
        if not writefile then return nil, "executor has no writefile" end
        local getAsset = getcustomasset or getsynasset
        if not getAsset then return nil, "executor has no getcustomasset" end

        local data
        local req = (syn and syn.request) or request or http_request
        if req then
            local ok, res = pcall(function() return req({Url = url, Method = "GET"}) end)
            if ok and res and isImage(res.Body) then data = res.Body end
        end
        if not data then
            local ok, r = pcall(function() return game:HttpGet(url) end)
            if ok and isImage(r) then data = r end
        end
        if not data then return nil, "download failed or not an image" end

        local ok3, err3 = pcall(writefile, fname, data)
        if not ok3 then return nil, "writefile failed: " .. tostring(err3) end
        local ok4, id = pcall(getAsset, fname)
        if not ok4 or not id then return nil, "getcustomasset failed" end
        return id
    end

    local photoId, photoErr = loadImage(PHOTO_URL, "skyzenhub_bg.png")
    if not photoId then print("[SkyZenHub] Photo failed: " .. tostring(photoErr)) end
    local loadingId = loadImage(LOADING_URL, "skyzenhub_loading.jpg") or photoId

    local function makeLogo(obj)
        obj.BackgroundTransparency = 1
        local bg = Instance.new("Frame")
        bg.Size = UDim2.new(1, 0, 1, 0)
        bg.BackgroundColor3 = Color3.new(1, 1, 1)
        bg.BorderSizePixel = 0
        bg.ZIndex = 1
        bg.Parent = obj
        Instance.new("UICorner", bg).CornerRadius = UDim.new(1, 0)
        local g = Instance.new("UIGradient", bg)
        g.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, RED),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 0, 0)),
            ColorSequenceKeypoint.new(1, RED),
        })
        TS:Create(g, TweenInfo.new(3, Enum.EasingStyle.Linear, Enum.EasingDirection.In, -1), {Rotation = 360}):Play()
        local st = Instance.new("UIStroke", bg)
        st.Color = RED
        st.Thickness = 1.5

        if photoId then
            local img = Instance.new("ImageLabel")
            img.Size = UDim2.new(1, -4, 1, -4)
            img.Position = UDim2.new(0, 2, 0, 2)
            img.BackgroundTransparency = 1
            img.Image = photoId
            img.ScaleType = Enum.ScaleType.Crop
            img.ZIndex = 2
            img.Parent = obj
            Instance.new("UICorner", img).CornerRadius = UDim.new(1, 0)
        else
            local t = Instance.new("TextLabel")
            t.Size = UDim2.new(1, 0, 1, 0)
            t.BackgroundTransparency = 1
            t.Text = "SZ"
            t.Font = Enum.Font.GothamBlack
            t.TextScaled = true
            t.TextColor3 = Color3.new(1, 1, 1)
            t.ZIndex = 2
            t.Parent = obj
            Instance.new("UITextSizeConstraint", t).MaxTextSize = 20
        end
    end

    ---------------- LOADING SCREEN ----------------
    local loader, setProgress
    do
        loader = Instance.new("CanvasGroup")
        loader.Name = "Loader"
        loader.AnchorPoint = Vector2.new(0.5, 0.5)
        loader.Position = UDim2.new(0.5, 0, 0.5, 0)
        loader.Size = UDim2.new(0, 280, 0, 170)
        loader.BackgroundTransparency = 1
        loader.BorderSizePixel = 0
        loader.Active = true
        loader.ZIndex = 50
        loader.Parent = gui

        local lbg = Instance.new("Frame")
        lbg.Size = UDim2.new(1, 0, 1, 0)
        lbg.BackgroundColor3 = Color3.new(1, 1, 1)
        lbg.BorderSizePixel = 0
        lbg.Parent = loader
        Instance.new("UICorner", lbg).CornerRadius = UDim.new(0, 14)
        local lbgGrad = Instance.new("UIGradient", lbg)
        lbgGrad.Rotation = 90
        lbgGrad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 34)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(6, 6, 10)),
        })
        local lbgStroke = Instance.new("UIStroke", lbg)
        lbgStroke.Color = RED
        lbgStroke.Thickness = 1.5
        TS:Create(lbgStroke, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {Transparency = 0.7}):Play()

        if loadingId then
            local lImgBg = Instance.new("ImageLabel")
            lImgBg.Size = UDim2.new(1, 0, 1, 0)
            lImgBg.BackgroundTransparency = 1
            lImgBg.Image = loadingId
            lImgBg.ScaleType = Enum.ScaleType.Crop
            lImgBg.ImageTransparency = 0.15
            lImgBg.Parent = lbg
            Instance.new("UICorner", lImgBg).CornerRadius = UDim.new(0, 14)

            local lShade = Instance.new("Frame")
            lShade.Size = UDim2.new(1, 0, 1, 0)
            lShade.BackgroundColor3 = Color3.new(1, 1, 1)
            lShade.BackgroundTransparency = 0.4
            lShade.BorderSizePixel = 0
            lShade.Parent = lbg
            Instance.new("UICorner", lShade).CornerRadius = UDim.new(0, 14)
        end

        local lLogo = Instance.new("Frame")
        lLogo.AnchorPoint = Vector2.new(0.5, 0)
        lLogo.Position = UDim2.new(0.5, 0, 0, 18)
        lLogo.Size = UDim2.new(0, 56, 0, 56)
        lLogo.Parent = loader
        makeLogo(lLogo)

        local lTitle = Instance.new("TextLabel")
        lTitle.Position = UDim2.new(0, 0, 0, 82)
        lTitle.Size = UDim2.new(1, 0, 0, 24)
        lTitle.BackgroundTransparency = 1
        lTitle.Text = "SKYZENHUB"
        lTitle.Font = Enum.Font.GothamBlack
        lTitle.TextSize = 16
        lTitle.TextColor3 = Color3.fromRGB(0, 0, 0)
        lTitle.Parent = loader

        local lStatus = Instance.new("TextLabel")
        lStatus.Position = UDim2.new(0, 0, 0, 108)
        lStatus.Size = UDim2.new(1, 0, 0, 18)
        lStatus.BackgroundTransparency = 1
        lStatus.Text = "Initializing..."
        lStatus.Font = Enum.Font.GothamBlack
        lStatus.TextSize = 13
        lStatus.TextColor3 = Color3.fromRGB(0, 0, 0)
        lStatus.Parent = loader

        local lBar = Instance.new("Frame")
        lBar.AnchorPoint = Vector2.new(0.5, 0)
        lBar.Position = UDim2.new(0.5, 0, 0, 138)
        lBar.Size = UDim2.new(0, 220, 0, 6)
        lBar.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
        lBar.BorderSizePixel = 0
        lBar.Parent = loader
        Instance.new("UICorner", lBar).CornerRadius = UDim.new(1, 0)

        local lFill = Instance.new("Frame")
        lFill.Size = UDim2.new(0, 0, 1, 0)
        lFill.BackgroundColor3 = RED
        lFill.BorderSizePixel = 0
        lFill.Parent = lBar
        Instance.new("UICorner", lFill).CornerRadius = UDim.new(1, 0)

        setProgress = function(p, text, dur)
            lStatus.Text = text
            TS:Create(lFill, TweenInfo.new(dur or 0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(p, 0, 1, 0)}):Play()
        end
    end

    ---------------- MAIN WINDOW ----------------
    Main = Instance.new("Frame")
    Main.Size = UDim2.new(0, 340, 0, 280)
    Main.Position = UDim2.new(0.5, -170, 0.5, -140)
    Main.BackgroundColor3 = DARK
    Main.ClipsDescendants = true
    Main.Visible = false
    Main.Parent = gui
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)

    local grad = Instance.new("UIGradient", Main)
    grad.Rotation = 90
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 34)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(6, 6, 10)),
    })

    local stroke = Instance.new("UIStroke", Main)
    stroke.Color = RED
    stroke.Thickness = 1.5
    TS:Create(stroke, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {Transparency = 0.7}):Play()

    if photoId then
        local bgImg = Instance.new("ImageLabel")
        bgImg.Size = UDim2.new(1, 0, 1, 0)
        bgImg.BackgroundTransparency = 1
        bgImg.Image = photoId
        bgImg.ScaleType = Enum.ScaleType.Crop
        bgImg.ZIndex = 1
        bgImg.Parent = Main
        Instance.new("UICorner", bgImg).CornerRadius = UDim.new(0, 12)

        local shade = Instance.new("Frame")
        shade.Size = UDim2.new(1, 0, 1, 0)
        shade.BackgroundColor3 = Color3.new(0, 0, 0)
        shade.BackgroundTransparency = 0.45
        shade.BorderSizePixel = 0
        shade.ZIndex = 1
        shade.Parent = Main
        Instance.new("UICorner", shade).CornerRadius = UDim.new(0, 12)
    end

    -- Header
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 42)
    header.BackgroundTransparency = 1
    header.Parent = Main

    local logo = Instance.new("Frame")
    logo.Size = UDim2.new(0, 30, 0, 30)
    logo.Position = UDim2.new(0, 10, 0, 6)
    logo.Parent = header
    makeLogo(logo)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -130, 1, 0)
    title.Position = UDim2.new(0, 48, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = TITLE
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 13
    title.TextColor3 = Color3.fromRGB(235, 235, 240)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.TextTruncate = Enum.TextTruncate.AtEnd
    title.Parent = header

    local function topBtn(text, x)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0, 28, 0, 24)
        b.Position = UDim2.new(1, x, 0, 9)
        b.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
        b.Text = text
        b.Font = Enum.Font.GothamBold
        b.TextSize = 14
        b.TextColor3 = Color3.new(1, 1, 1)
        b.Parent = header
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
        return b
    end
    local minBtn = topBtn("-", -66)
    local closeBtn = topBtn("X", -34)

    local line = Instance.new("Frame")
    line.Size = UDim2.new(1, -24, 0, 1)
    line.Position = UDim2.new(0, 12, 0, 44)
    line.BackgroundColor3 = GREY
    line.BorderSizePixel = 0
    line.Parent = Main

    -- Status row (world / zone)
    WorldStatus = Instance.new("TextLabel")
    WorldStatus.Size = UDim2.new(0.5, -12, 0, 16)
    WorldStatus.Position = UDim2.new(0, 12, 1, -20)
    WorldStatus.BackgroundTransparency = 1
    WorldStatus.Text = "🌍 Loading..."
    WorldStatus.Font = Enum.Font.GothamBold
    WorldStatus.TextSize = 11
    WorldStatus.TextColor3 = Color3.fromRGB(0, 255, 255)
    WorldStatus.TextXAlignment = Enum.TextXAlignment.Left
    WorldStatus.Parent = Main

    ZoneStatus = Instance.new("TextLabel")
    ZoneStatus.Size = UDim2.new(0.5, -12, 0, 16)
    ZoneStatus.Position = UDim2.new(0.5, 0, 1, -20)
    ZoneStatus.BackgroundTransparency = 1
    ZoneStatus.Text = "📍 Zone: 0"
    ZoneStatus.Font = Enum.Font.GothamBold
    ZoneStatus.TextSize = 11
    ZoneStatus.TextColor3 = Color3.fromRGB(255, 150, 50)
    ZoneStatus.TextXAlignment = Enum.TextXAlignment.Right
    ZoneStatus.Parent = Main

    -- Tab bar (scrolls sideways because there are many tabs)
    local tabBar = Instance.new("ScrollingFrame")
    tabBar.Size = UDim2.new(1, -24, 0, 28)
    tabBar.Position = UDim2.new(0, 12, 0, 52)
    tabBar.BackgroundTransparency = 1
    tabBar.BorderSizePixel = 0
    tabBar.ScrollBarThickness = 0
    tabBar.CanvasSize = UDim2.new(0, 0, 0, 0)
    tabBar.AutomaticCanvasSize = Enum.AutomaticSize.X
    tabBar.ScrollingDirection = Enum.ScrollingDirection.X
    tabBar.Parent = Main
    local tl = Instance.new("UIListLayout", tabBar)
    tl.FillDirection = Enum.FillDirection.Horizontal
    tl.Padding = UDim.new(0, 6)

    local tabsList = {}
    local function selectTab(sel)
        for _, t in ipairs(tabsList) do
            local on = (t.btn == sel)
            t.page.Visible = on
            t.btn.BackgroundColor3 = on and RED or Color3.fromRGB(25, 25, 30)
            t.btn.TextColor3 = on and Color3.new(1, 1, 1) or Color3.fromRGB(150, 150, 160)
            t.stroke.Enabled = on
        end
    end

    -- Row styling shared by all content rows
    local function styleRow(b, fill)
        b.Size = UDim2.new(0.95, 0, 0, 30)
        b.BackgroundColor3 = fill
        b.BackgroundTransparency = 0.1
        b.Font = Enum.Font.GothamBold
        b.TextColor3 = Color3.new(1, 1, 1)
        b.AutoButtonColor = false
        b.TextScaled = true
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
        local pad = Instance.new("UIPadding", b)
        pad.PaddingLeft = UDim.new(0, 8)
        pad.PaddingRight = UDim.new(0, 8)
        local c = Instance.new("UITextSizeConstraint", b)
        c.MaxTextSize = 12
        c.MinTextSize = 8
        local s = Instance.new("UIStroke", b)
        s.Color = GREY
        return s
    end

    AddTab = function(name, color, isFirst)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0, 0, 1, 0)
        b.AutomaticSize = Enum.AutomaticSize.X
        b.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
        b.Text = name
        b.Font = Enum.Font.GothamBold
        b.TextSize = 11
        b.TextColor3 = Color3.fromRGB(150, 150, 160)
        b.AutoButtonColor = false
        b.Parent = tabBar
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
        local pad = Instance.new("UIPadding", b)
        pad.PaddingLeft = UDim.new(0, 10)
        pad.PaddingRight = UDim.new(0, 10)
        local st = Instance.new("UIStroke", b)
        st.Color = Color3.fromRGB(230, 230, 235)
        st.Thickness = 1
        st.Enabled = false

        local page = Instance.new("ScrollingFrame")
        page.Size = UDim2.new(1, -24, 1, -110)
        page.Position = UDim2.new(0, 12, 0, 86)
        page.BackgroundTransparency = 1
        page.BorderSizePixel = 0
        page.ScrollBarThickness = 3
        page.CanvasSize = UDim2.new(0, 0, 0, 0)
        page.AutomaticCanvasSize = Enum.AutomaticSize.Y
        page.Visible = false
        page.Parent = Main
        local layout = Instance.new("UIListLayout", page)
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding = UDim.new(0, 4)
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

        tabsList[#tabsList + 1] = {btn = b, page = page, stroke = st}
        b.MouseButton1Click:Connect(function() selectTab(b) end)
        if isFirst then selectTab(b) end
        return { container = page, order = 0 }
    end

    CreateHeader = function(tabData, text)
        tabData.order = tabData.order + 1
        local b = Instance.new("TextButton")
        styleRow(b, PANEL)
        b.Text = "▼ " .. text
        b.LayoutOrder = tabData.order
        b.Parent = tabData.container
        return b
    end

    CreateStatusLabel = function(tabData, defaultText)
        tabData.order = tabData.order + 1
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0.95, 0, 0, 28)
        frame.BackgroundColor3 = PANEL
        frame.BackgroundTransparency = 0.25
        frame.LayoutOrder = tabData.order
        frame.Parent = tabData.container
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
        local s = Instance.new("UIStroke", frame)
        s.Color = GREY

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -20, 1, 0)
        lbl.Position = UDim2.new(0, 10, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = defaultText
        lbl.TextColor3 = Color3.fromRGB(220, 220, 225)
        lbl.Font = Enum.Font.GothamBold
        lbl.TextScaled = true
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = frame
        local c = Instance.new("UITextSizeConstraint", lbl)
        c.MaxTextSize = 11
        c.MinTextSize = 7
        return lbl, frame
    end

    local toggleRefreshers = {}
    CreateCleanToggle = function(tabData, name, key, color)
        tabData.order = tabData.order + 1
        local b = Instance.new("TextButton")
        local s = styleRow(b, OFFFILL)
        b.LayoutOrder = tabData.order
        b.Parent = tabData.container

        local function refresh()
            local on = Toggles[key] and true or false
            b.Text = name .. "  :  " .. (on and "ON" or "OFF")
            b.BackgroundColor3 = on and RED or OFFFILL
            s.Color = on and Color3.fromRGB(230, 230, 235) or GREY
            s.Thickness = on and 2 or 1
        end
        refresh()
        b.MouseButton1Click:Connect(function()
            Toggles[key] = not Toggles[key]
            refresh()
            SaveConfig()
        end)
        toggleRefreshers[#toggleRefreshers + 1] = refresh
        return b
    end

    task.spawn(function()
        while task.wait(0.5) do
            if not getgenv().SkyZenHub_IsRunning then break end
            for _, r in ipairs(toggleRefreshers) do pcall(r) end
        end
    end)

    CreateButton = function(tabData, name, cb, color)
        tabData.order = tabData.order + 1
        local b = Instance.new("TextButton")
        styleRow(b, RED)
        b.Text = name
        b.LayoutOrder = tabData.order
        b.Parent = tabData.container
        b.MouseButton1Click:Connect(cb)
        return b
    end

    CreateInput = function(tabData, text, default, cb)
        tabData.order = tabData.order + 1
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0.95, 0, 0, 30)
        frame.BackgroundColor3 = PANEL
        frame.BackgroundTransparency = 0.25
        frame.LayoutOrder = tabData.order
        frame.Parent = tabData.container
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
        local s = Instance.new("UIStroke", frame)
        s.Color = GREY

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(0.5, 0, 1, 0)
        lbl.Position = UDim2.new(0, 10, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = text
        lbl.TextColor3 = Color3.fromRGB(220, 220, 225)
        lbl.Font = Enum.Font.GothamBold
        lbl.TextScaled = true
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = frame
        local lc = Instance.new("UITextSizeConstraint", lbl)
        lc.MaxTextSize = 11
        lc.MinTextSize = 7

        local box = Instance.new("TextBox")
        box.Name = "SearchInputBox"
        box.Size = UDim2.new(0.45, 0, 0.8, 0)
        box.Position = UDim2.new(0.5, 0, 0.1, 0)
        box.BackgroundColor3 = RED
        box.Text = tostring(default)
        box.TextColor3 = Color3.new(1, 1, 1)
        box.Font = Enum.Font.GothamBold
        box.TextSize = 11
        box.ClearTextOnFocus = false
        box.Parent = frame
        Instance.new("UICorner", box).CornerRadius = UDim.new(0, 6)
        box.FocusLost:Connect(function() cb(box.Text); SaveConfig() end)

        return {frame = frame, box = box}
    end

    SetupCollapse = function(headerBtn, items)
        local function setVisible(v)
            for _, item in ipairs(items) do
                if type(item) == "table" and item.frame then item.frame.Visible = v else item.Visible = v end
            end
        end
        headerBtn:SetAttribute("IsOpen", false)
        headerBtn.Text = "▶ " .. string.sub(headerBtn.Text, 5)
        setVisible(false)
        headerBtn.MouseButton1Click:Connect(function()
            local isOpen = not headerBtn:GetAttribute("IsOpen")
            headerBtn:SetAttribute("IsOpen", isOpen)
            headerBtn.Text = (isOpen and "▼ " or "▶ ") .. string.sub(headerBtn.Text, 5)
            setVisible(isOpen)
        end)
    end

    -- Minimized icon
    local icon = Instance.new("TextButton")
    icon.Size = UDim2.new(0, 50, 0, 50)
    icon.Position = UDim2.new(0, 15, 0.4, 0)
    icon.Text = ""
    icon.Visible = false
    icon.Parent = gui
    makeLogo(icon)

    local uiReady = false
    ToggleHubUI = function()
        if not uiReady then return end
        Main.Visible = not Main.Visible
        icon.Visible = not Main.Visible
        ConfirmFrame.Visible = false
    end
    minBtn.MouseButton1Click:Connect(ToggleHubUI)
    icon.MouseButton1Click:Connect(ToggleHubUI)
    UserInputService.InputBegan:Connect(function(input, gp)
        if not gp and input.KeyCode == hideKeyEnum then ToggleHubUI() end
    end)

    -- Close confirmation
    do
        ConfirmFrame = Instance.new("Frame")
        ConfirmFrame.Size = UDim2.new(1, 0, 1, 0)
        ConfirmFrame.BackgroundColor3 = Color3.new(0, 0, 0)
        ConfirmFrame.BackgroundTransparency = 0.35
        ConfirmFrame.BorderSizePixel = 0
        ConfirmFrame.Active = true
        ConfirmFrame.Visible = false
        ConfirmFrame.ZIndex = 20
        ConfirmFrame.Parent = Main

        local box = Instance.new("Frame")
        box.AnchorPoint = Vector2.new(0.5, 0.5)
        box.Position = UDim2.new(0.5, 0, 0.5, 0)
        box.Size = UDim2.new(0, 260, 0, 130)
        box.BackgroundColor3 = DARK
        box.ZIndex = 21
        box.Parent = ConfirmFrame
        Instance.new("UICorner", box).CornerRadius = UDim.new(0, 10)
        local bs = Instance.new("UIStroke", box)
        bs.Color = GREY
        bs.Thickness = 1.5

        local ct = Instance.new("TextLabel")
        ct.Size = UDim2.new(1, -20, 0, 24)
        ct.Position = UDim2.new(0, 10, 0, 12)
        ct.BackgroundTransparency = 1
        ct.Text = "Delete script?"
        ct.Font = Enum.Font.GothamBlack
        ct.TextSize = 16
        ct.TextColor3 = Color3.fromRGB(235, 235, 240)
        ct.ZIndex = 22
        ct.Parent = box

        local cs = Instance.new("TextLabel")
        cs.Size = UDim2.new(1, -20, 0, 34)
        cs.Position = UDim2.new(0, 10, 0, 38)
        cs.BackgroundTransparency = 1
        cs.Text = "The script will be closed and all features turned off."
        cs.Font = Enum.Font.Gotham
        cs.TextSize = 12
        cs.TextWrapped = true
        cs.TextColor3 = Color3.fromRGB(190, 190, 200)
        cs.ZIndex = 22
        cs.Parent = box

        local function confirmBtn(text, x, color)
            local b = Instance.new("TextButton")
            b.Size = UDim2.new(0.5, -15, 0, 32)
            b.Position = UDim2.new(x, x == 0 and 10 or 5, 1, -42)
            b.BackgroundColor3 = color
            b.Text = text
            b.Font = Enum.Font.GothamBold
            b.TextSize = 13
            b.TextColor3 = Color3.new(1, 1, 1)
            b.ZIndex = 22
            b.Parent = box
            Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
            return b
        end
        local cancelBtn = confirmBtn("Cancel", 0, Color3.fromRGB(35, 35, 42))
        local yesBtn = confirmBtn("Yes, Delete", 0.5, RED)

        closeBtn.MouseButton1Click:Connect(function() ConfirmFrame.Visible = true end)
        cancelBtn.MouseButton1Click:Connect(function() ConfirmFrame.Visible = false end)
        yesBtn.MouseButton1Click:Connect(function()
            pcall(SaveConfig)
            getgenv().SkyZenHub_IsRunning = false
            pcall(function() gui:Destroy() end)
        end)
    end

    -- Dragging
    local function makeDraggable(handle, obj)
        local dragging, start, startPos
        handle.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                start = i.Position
                startPos = obj.Position
                i.Changed:Connect(function()
                    if i.UserInputState == Enum.UserInputState.End then dragging = false end
                end)
            end
        end)
        UserInputService.InputChanged:Connect(function(i)
            if dragging and (i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseMovement) then
                local d = i.Position - start
                obj.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
            end
        end)
    end
    makeDraggable(header, Main)
    makeDraggable(icon, icon)

    -- Loading animation runs in the background while the script keeps loading
    task.spawn(function()
        local started = os.clock()
        setProgress(0.1, "Initializing...", 1.2)
        task.wait(1.5)
        local stages = {
            {0.3, "Loading assets..."},
            {0.5, "Building interface..."},
            {0.68, "Loading modules..."},
            {0.84, "Preparing features..."},
            {0.96, "Almost ready..."},
        }
        local remaining = math.max(0, LOAD_TIME - (os.clock() - started) - 0.6)
        for _, st in ipairs(stages) do
            local d = remaining / #stages
            setProgress(st[1], st[2], d)
            task.wait(d)
        end
        setProgress(1, "Ready", 0.4)
        task.wait(0.6)

        local mainScale = Instance.new("UIScale", Main)
        mainScale.Scale = 0.85
        Main.Visible = true
        uiReady = true
        TS:Create(mainScale, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play()
        TS:Create(loader, TweenInfo.new(0.35), {GroupTransparency = 1}):Play()
        task.wait(0.4)
        loader:Destroy()
    end)
end


-- ==========================================
-- 🛠️ KHỞI TẠO NỘI DUNG CÁC TAB
-- ==========================================
local tFarm = AddTab("⚔️ MAIN FARM", Color3.fromRGB(0, 150, 255), true)
local tHatch = AddTab("🥚 HATCH EGGS", Color3.fromRGB(255, 180, 50), false)
local tEnchant = AddTab("📚 ENCHANTS", Color3.fromRGB(150, 50, 200), false)
local tInv = AddTab("🎒 INVENTORY", Color3.fromRGB(50, 200, 150), false)
local tWorld = AddTab("🗺️ WORLD/MACHINES", Color3.fromRGB(200, 150, 50), false)
local tWeb = AddTab("🔔 WEBHOOK", Color3.fromRGB(200, 100, 50), false)
local tConfig = AddTab("⚙️ CONFIG", Color3.fromRGB(100, 100, 120), false)

-- [FARM TAB]
CreateButton(tFarm, "🚀 TELEPORT TO BEST AREA", function() task.spawn(forceTeleportToBestZone) end, Color3.fromRGB(150, 50, 200))

-- >>> [MỚI] TÍCH HỢP TELEPORT LẬP TỨC KHI BẬT AUTO FARM
local btnAutoFarmArea = CreateCleanToggle(tFarm, "AUTO FARM + BUY AREA", "AutoFarmArea", Color3.fromRGB(0, 180, 80))
btnAutoFarmArea.MouseButton1Click:Connect(function()
    if Toggles.AutoFarmArea then task.spawn(forceTeleportToBestZone) end
end)

CreateCleanToggle(tFarm, "FAST FARM (BULK + MULTI-TAP)", "FastFarm", Color3.fromRGB(200, 50, 50))
CreateCleanToggle(tFarm, "INF PET SPEED", "InfPetSpeed", Color3.fromRGB(200, 150, 50))
CreateCleanToggle(tFarm, "AUTO RANK QUESTS (MIN ZONE 41)", "Rank", Color3.fromRGB(255, 150, 50))

local hRank = CreateHeader(tFarm, "RANK QUEST CONFIG")
local iRank = {}
local rcKeys = {{"Comet/Meteor", "Comet"}, {"Coin Jars", "Jar"}, {"Pinatas", "Pinata"}, {"Lucky Blocks", "Lucky"}, {"Flags", "Flag"}, {"Fruits", "Fruit"}, {"Drink Potions", "Potion"}, {"Unlock Area", "Area"}, {"Up Potions", "UpPotion"}, {"Up Enchants", "UpEnchant"}, {"Hatch Eggs", "Hatch"}, {"Gold Pets", "Gold"}, {"Rainbow Pets", "Rainbow"}, {"Legendary Pets", "Legendary"}}
for _, v in ipairs(rcKeys) do
    table.insert(iRank, CreateButton(tFarm, (RankConfig[v[2]] and "✅ " or "❌ ") .. v[1], function() RankConfig[v[2]] = not RankConfig[v[2]]; SaveConfig() end, Color3.fromRGB(60, 60, 65)))
end
local btnOffset = CreateButton(tFarm, "🥚 L. Egg Offset: -" .. getgenv().LegendaryEggOffset, function() getgenv().LegendaryEggOffset = (getgenv().LegendaryEggOffset == 1) and 2 or 1; SaveConfig() end, Color3.fromRGB(150, 100, 200))
table.insert(iRank, btnOffset)
SetupCollapse(hRank, iRank)

task.spawn(function()
    while task.wait(0.5) do
        if not getgenv().SkyZenHub_IsRunning then break end
        pcall(function()
            for i, v in ipairs(rcKeys) do iRank[i].Text = (RankConfig[v[2]] and "✅ " or "❌ ") .. v[1]; iRank[i].BackgroundColor3 = RankConfig[v[2]] and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(55, 55, 64) end
            btnOffset.Text = "🥚 L. Egg Offset: -" .. getgenv().LegendaryEggOffset
        end)
    end
end)

local KaitunBtn = CreateCleanToggle(tFarm, "KAITUN RANK", "KaitunMode", Color3.fromRGB(180, 0, 80))

-- [HATCH TAB]
-- >>> [MỚI] TÍCH HỢP TELEPORT LẬP TỨC KHI BẬT AUTO HATCH
local btnHatchBest = CreateCleanToggle(tHatch, "AUTO HATCH BEST EGG", "HatchBest", Color3.fromRGB(0, 180, 80))
btnHatchBest.MouseButton1Click:Connect(function()
    if Toggles.HatchBest then task.spawn(forceTeleportToBestZone) end
end)

CreateCleanToggle(tHatch, "HIDE EGG UI & ANIMATION", "HideEgg", Color3.fromRGB(200, 100, 255))
local targetEggLabel = CreateButton(tHatch, "Target: None (Click to Stop)", function() targetEggName = nil; Toggles.HatchBest = false; SaveConfig() end, Color3.fromRGB(60, 60, 65))

local hEgg = CreateHeader(tHatch, "EGG LIST")
local iEgg = {}
for _, e in ipairs(GLOBAL_EGG_DATA) do
    local b = CreateButton(tHatch, string.format("[%d] %s", e.num, e.name), function() 
        targetEggName = e.name; Toggles.HatchBest = false; SaveConfig()
        task.spawn(function() 
            getgenv().IsMachineActionActive = true
            teleportToEgg(e.name)
            task.wait(0.6)
            pcall(function() Network:FindFirstChild("Eggs_RequestPurchase"):InvokeServer(e.name, getMaxHatchAmount()) end)
            task.wait(0.2)
            getgenv().IsMachineActionActive = false 
        end)
    end, Color3.fromRGB(40, 45, 50))
    table.insert(iEgg, b)
end
SetupCollapse(hEgg, iEgg)

task.spawn(function() while task.wait(0.5) do if not getgenv().SkyZenHub_IsRunning then break end pcall(function() targetEggLabel.Text = "Target: " .. (targetEggName or "None") .. " (Click to Stop)"; targetEggLabel.BackgroundColor3 = targetEggName and Color3.fromRGB(200, 50, 50) or Color3.fromRGB(60, 60, 65) end) end end)

-- [ENCHANTS TAB FIX WAVE PC - THREAD IDENTITY BYPASS]
local selectedEnchantSlot = 1

tEnchant.order = tEnchant.order + 1
local HFrameE = Instance.new("Frame", tEnchant.container)
HFrameE.Size = UDim2.new(0.95, 0, 0, 35); HFrameE.BackgroundTransparency = 1; HFrameE.LayoutOrder = tEnchant.order
local MBtnE = Instance.new("TextButton", HFrameE); MBtnE.Size = UDim2.new(0.2, 0, 1, 0); MBtnE.BackgroundColor3 = Color3.fromRGB(0, 0, 0); MBtnE.Text = "➖"; MBtnE.TextColor3 = Color3.new(1,1,1); MBtnE.Font = Enum.Font.GothamBold; Instance.new("UICorner", MBtnE).CornerRadius = UDim.new(0, 6)
local ABtnE = Instance.new("TextLabel", HFrameE); ABtnE.Size = UDim2.new(0.55, 0, 1, 0); ABtnE.Position = UDim2.new(0.225, 0, 0, 0); ABtnE.BackgroundColor3 = Color3.fromRGB(30, 30, 38); ABtnE.Text = "🎯 Target Slot: " .. selectedEnchantSlot; ABtnE.TextColor3 = Color3.new(1,1,1); ABtnE.Font = Enum.Font.GothamBold; ABtnE.TextSize = 12; Instance.new("UICorner", ABtnE).CornerRadius = UDim.new(0, 6)
local PBtnE = Instance.new("TextButton", HFrameE); PBtnE.Size = UDim2.new(0.2, 0, 1, 0); PBtnE.Position = UDim2.new(0.8, 0, 0, 0); PBtnE.BackgroundColor3 = Color3.fromRGB(0, 0, 0); PBtnE.Text = "➕"; PBtnE.TextColor3 = Color3.new(1,1,1); PBtnE.Font = Enum.Font.GothamBold; Instance.new("UICorner", PBtnE).CornerRadius = UDim.new(0, 6)

MBtnE.MouseButton1Click:Connect(function() selectedEnchantSlot = math.max(1, selectedEnchantSlot - 1); ABtnE.Text = "🎯 Target Slot: " .. selectedEnchantSlot end)
PBtnE.MouseButton1Click:Connect(function() selectedEnchantSlot = math.min(9, selectedEnchantSlot + 1); ABtnE.Text = "🎯 Target Slot: " .. selectedEnchantSlot end)

CreateButton(tEnchant, "🗑️ UNEQUIP TARGET SLOT", function() SavedEnchants[selectedEnchantSlot] = nil; SaveConfig(); pcall(function() Network.Enchants_ClearSlot:FireServer(selectedEnchantSlot) end) end, Color3.fromRGB(200, 50, 50))

local searchInputObj = CreateInput(tEnchant, "🔍 Search Enchant:", "", function() end)

local hList = CreateHeader(tEnchant, "ENCHANT LIST (Click to Equip)")
local iList = {}
for _, eName in ipairs(GLOBAL_ENCHANT_LIST) do
    table.insert(iList, CreateButton(tEnchant, "Set: " .. eName, function() SavedEnchants[selectedEnchantSlot] = eName; SaveConfig() end, Color3.fromRGB(40, 45, 50)))
end
SetupCollapse(hList, iList)

local hSlots = CreateHeader(tEnchant, "ENCHANT STATUS (View Only)")
local iSlots = {}
for i = 1, 9 do
    local lbl, frm = CreateStatusLabel(tEnchant, "Slot " .. i .. ": [Loading...]")
    table.insert(iSlots, {label = lbl, frame = frm})
end
SetupCollapse(hSlots, iSlots)

-- LOOP AN TOÀN FIX LỖI WAVE BẰNG RUNSERVICE + BINDABLE EVENT
local lastEnchantUIUpdate = 0
RunService.Heartbeat:Connect(function()
    if not getgenv().SkyZenHub_IsRunning then return end
    
    if tick() - lastEnchantUIUpdate >= 1.5 then
        lastEnchantUIUpdate = tick()
        
        -- Gọi Event Hacker để moi dữ liệu cực mạnh trên PC
        pcall(function() FetchSaveEvent:Fire() end)
        
        pcall(function()
            local pRank = getPlayerRank() or 1
            local eq = getEquippedEnchants_Live() or {}
            
            local getUnlockReq = function(idx) 
                if idx==1 then return 1 elseif idx==2 then return 3 elseif idx==3 then return 5 elseif idx==4 then return 8 elseif idx==5 then return 11 elseif idx==6 then return 20 else return 99 end 
            end
            
            for i = 1, 9 do
                local sName = SavedEnchants[i] or "None"
                local req = getUnlockReq(i)
                local prefix = "[UNLOCKED]"
                
                if i <= 6 and pRank < req then
                    prefix = "[LOCKED]"
                elseif i > 6 then
                    prefix = "[PREMIUM]"
                end
                
                local actStr = "Empty"
                if type(eq) == "table" and type(eq[i]) == "table" and eq[i].name then
                    actStr = tostring(eq[i].name)
                    if eq[i].isTierless then
                        actStr = actStr .. " (MAX)"
                    else
                        actStr = actStr .. " (T" .. tostring(eq[i].tier) .. ")"
                    end
                end
                
                if type(iSlots) == "table" and iSlots[i] and iSlots[i].label then
                    local displayStr = "Slot " .. tostring(i) .. " " .. prefix .. " | Set: " .. tostring(sName) .. " | Eq: " .. actStr
                    iSlots[i].label.Text = displayStr
                    iSlots[i].label.TextColor3 = (actStr ~= "Empty") and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(200, 200, 200)
                end
            end
        end)
        
        pcall(function()
            local filterText = ""
            if type(searchInputObj) == "table" and searchInputObj.box then
                filterText = string.lower(tostring(searchInputObj.box.Text))
            end
            
            local isListOpen = false
            if hList then isListOpen = hList:GetAttribute("IsOpen") end
            
            for j, eName in ipairs(GLOBAL_ENCHANT_LIST) do
                if iList[j] then
                    if isListOpen then
                        iList[j].Visible = (filterText == "" or string.find(string.lower(eName), filterText) ~= nil)
                    else
                        iList[j].Visible = false
                    end
                end
            end
        end)
    end
end)

-- Auto Equip Loop (Dùng SaveModule Gốc)
task.spawn(function()
    while task.wait(2) do
        if not getgenv().SkyZenHub_IsRunning then break end
        pcall(function()
            local pRank, eq, ml = getPlayerRank(), getEquippedEnchants(), getEnchantMasteryLvl()
            local mt = ml and (ml >= 70 and 10 or (ml >= 60 and 9 or (ml >= 50 and 8 or 7))) or 99
            local s, d = pcall(function() return SaveModule.Get() end)
            if not (s and d) then return end
            for slot = 1, 9 do
                local getUnlockReq = function(idx) if idx==1 then return 1 elseif idx==2 then return 3 elseif idx==3 then return 5 elseif idx==4 then return 8 elseif idx==5 then return 11 elseif idx==6 then return 20 else return 99 end end
                if (slot > 6 or (pRank or 1) >= getUnlockReq(slot)) and SavedEnchants[slot] then
                    local targetEnchant = SavedEnchants[slot]
                    if not eq[slot] or eq[slot].name ~= targetEnchant then
                        local bUid, bTier = nil, 0
                        local evt = Network:FindFirstChild("Enchants_Equip")
                        if evt and d.Inventory and d.Inventory.Enchant then
                            for uid, item in pairs(d.Inventory.Enchant) do
                                if tostring(item.id) == targetEnchant then
                                    local t = tonumber(item.tn)
                                    if t then if t <= mt and t > bTier then bTier = t; bUid = uid end else bUid = uid; break end
                                end
                            end
                        end
                        if bUid then pcall(function() Network.Enchants_ClearSlot:FireServer(slot) end); task.wait(0.1); pcall(function() evt:FireServer(bUid) end); task.wait(0.1) end
                    end
                end
            end
        end)
    end
end)

-- [INVENTORY & UPGRADES TAB]
CreateCleanToggle(tInv, "🎁 AUTO BUNDLE O' ENCHANTS", "AutoBundleEnchant", Color3.fromRGB(0, 150, 255))
CreateCleanToggle(tInv, "🎁 AUTO BUNDLE O' POTIONS", "AutoBundlePotion", Color3.fromRGB(150, 50, 200))
CreateCleanToggle(tInv, "🎁 AUTO BUNDLE O' FRUITS", "AutoBundleFruit", Color3.fromRGB(50, 180, 100))
CreateCleanToggle(tInv, "🎁 AUTO BUNDLE O' FLAGS", "AutoBundleFlag", Color3.fromRGB(200, 100, 50))

local hUpPots = CreateHeader(tInv, "UPGRADE POTIONS (Click to Use)")
local iUpPots = {}
for _, pType in ipairs({"Coins", "Damage", "Diamonds", "Lucky Eggs", "Treasure Hunter"}) do for t = 1, 6 do table.insert(iUpPots, CreateButton(tInv, "⬆️ Up " .. pType .. " T" .. t, function() local uid = getLiveUID(pType, t, "Potion", 5); if uid then pcall(function() Network.UpgradePotionsMachine_Activate:InvokeServer(uid, 1) end) end end, Color3.fromHSV(math.random(), 0.7, 0.7))) end end
SetupCollapse(hUpPots, iUpPots)

local hUpEncs = CreateHeader(tInv, "UPGRADE ENCHANTS (Click to Use)")
local iUpEncs = {}
for _, eType in ipairs({"Coins", "Criticals", "Diamonds", "Lucky Eggs", "Magnet", "Speed", "Strong Pets", "Tap Power", "Treasure Hunter"}) do for t = 1, 7 do table.insert(iUpEncs, CreateButton(tInv, "⬆️ Up " .. eType .. " T" .. t, function() local uid = getLiveUID(eType, t, "Enchant", 5); if uid then pcall(function() Network.UpgradeEnchantsMachine_Activate:InvokeServer(uid, 1) end) end end, Color3.fromHSV(math.random(), 0.7, 0.7))) end end
SetupCollapse(hUpEncs, iUpEncs)

local hUsePots = CreateHeader(tInv, "DRINK POTIONS (Click to Use)")
local iUsePots = {}
for _, pType in ipairs({"Coins", "Damage", "Diamonds", "Lucky Eggs", "Treasure Hunter"}) do for t = 1, 8 do table.insert(iUsePots, CreateButton(tInv, "💊 Drink " .. pType .. " T" .. t, function() local uid = getLiveUID(pType, t, "Potion", 1); if uid then pcall(function() Network["Potions: Consume"]:FireServer(uid, 1) end) end end, Color3.fromRGB(40, 60, 40))) end end
SetupCollapse(hUsePots, iUsePots)

-- [WORLD / MACHINES TAB]
CreateButton(tWorld, "🌍 JUMP TO SPAWN WORLD (W1)", function() pcall(function() Network.World1Teleport:InvokeServer() end) end, Color3.fromRGB(50, 150, 100))
CreateButton(tWorld, "🚀 JUMP TO TECH WORLD (W2)", function() pcall(function() Network.World2Teleport:InvokeServer() end) end, Color3.fromRGB(50, 100, 200))
CreateButton(tWorld, "🌌 JUMP TO VOID WORLD (W3)", function() pcall(function() Network.World3Teleport:InvokeServer() end) end, Color3.fromRGB(150, 50, 200))

local hMach = CreateHeader(tWorld, "MACHINES & MAILBOX")
local iMach = {}
local mailboxState = false
local mbBtn = CreateButton(tWorld, "📫 OPEN MAILBOX UI", function() end, Color3.fromRGB(80, 100, 200))
mbBtn.MouseButton1Click:Connect(function() mailboxState = not mailboxState; pcall(function() Network["Machines: Mark Approached"]:FireServer("MailboxMachine") end); local mUI = player.PlayerGui:FindFirstChild("_MACHINES") and player.PlayerGui._MACHINES:FindFirstChild("MailboxMachine"); if mailboxState then if mUI then mUI.Enabled = true end; mbBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50); mbBtn.Text = "📪 CLOSE MAILBOX UI" else if mUI then mUI.Enabled = false end; mbBtn.BackgroundColor3 = Color3.fromRGB(80, 100, 200); mbBtn.Text = "📫 OPEN MAILBOX UI" end end)
table.insert(iMach, mbBtn)
table.insert(iMach, CreateCleanToggle(tWorld, "AUTO CLAIM MAIL GIFT", "AutoClaimMail", Color3.fromRGB(200, 120, 50)))
table.insert(iMach, CreateCleanToggle(tWorld, "AUTO GOLD PET (CURRENT EGG)", "GoldBest", Color3.fromRGB(200, 180, 50)))
table.insert(iMach, CreateCleanToggle(tWorld, "AUTO GOLD PET (ALL)", "GoldAll", Color3.fromRGB(200, 180, 50)))
table.insert(iMach, CreateCleanToggle(tWorld, "AUTO RAINBOW PET (CURRENT EGG)", "RainBest", Color3.fromRGB(50, 200, 150)))
table.insert(iMach, CreateCleanToggle(tWorld, "AUTO RAINBOW PET (ALL)", "RainAll", Color3.fromRGB(50, 200, 150)))
SetupCollapse(hMach, iMach)

-- [WEBHOOK TAB]
local whUrlInput = CreateInput(tWeb, "Discord Link:", WHConfig.Url, function(v) WHConfig.Url = v end)
local whPingInput = CreateInput(tWeb, "Ping User ID:", WHConfig.PingID, function(v) WHConfig.PingID = v end)
local whRankInput = CreateInput(tWeb, "Rank Ping Target:", WHConfig.TargetRank, function(v) WHConfig.TargetRank = tonumber(v) or 0 end)

CreateCleanToggle(tWeb, "Enable Rank Ping", "PingEnabled", Color3.fromRGB(0, 180, 80))
CreateButton(tWeb, "Test Webhook", function()
    local requestFunc = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
    if requestFunc and WHConfig.Url ~= "" then pcall(function() requestFunc({ Url = WHConfig.Url, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = HttpService:JSONEncode({["content"] = "Webhook Test by SkyZenHub!", ["allowed_mentions"] = { ["parse"] = {"users", "roles", "everyone"} }}) }) end) end
end, Color3.fromRGB(0, 150, 255))

-- [CONFIG TAB]
CreateCleanToggle(tConfig, "AUTO BUY ZONES", "BuyZone", Color3.fromRGB(50, 180, 100))
CreateCleanToggle(tConfig, "AUTO COLLECT ORBS", "Orbs", Color3.fromRGB(200, 150, 50))

-- Thiết lập Auto Buy Pet Slots + Nút Chỉnh Target
CreateCleanToggle(tConfig, "AUTO BUY PET SLOTS", "BuySlot", Color3.fromRGB(150, 50, 200))
CreateInput(tConfig, " 🎯 Target Pet Slots:", getgenv().TargetEquipSlots, function(v) 
    local n = math.clamp(tonumber(v) or 99, 1, 99)
    getgenv().TargetEquipSlots = n
end)

-- Thiết lập Auto Buy Egg Slots + Nút Chỉnh Target
CreateCleanToggle(tConfig, "AUTO BUY EGG SLOTS", "BuyEggSlot", Color3.fromRGB(255, 150, 50))
CreateInput(tConfig, " 🎯 Target Egg Slots:", getgenv().TargetEggSlots, function(v) 
    local n = math.clamp(tonumber(v) or 99, 1, 99)
    getgenv().TargetEggSlots = n
end)

CreateCleanToggle(tConfig, "AUTO USE ULTIMATE", "Ultimate", Color3.fromRGB(150, 50, 150))

local hUlt = CreateHeader(tConfig, "SELECT ULTIMATE")
local iUlt = {}
local ultSelBtn = CreateButton(tConfig, "Current: " .. getgenv().TargetUltimate, function() end, Color3.fromRGB(150, 50, 150))
table.insert(iUlt, ultSelBtn)
for _, uName in ipairs(GLOBAL_ULTIMATE_LIST) do
    table.insert(iUlt, CreateButton(tConfig, uName, function() getgenv().TargetUltimate = uName; ultSelBtn.Text = "Current: " .. uName; SaveConfig() end, Color3.fromRGB(40, 45, 50)))
end
SetupCollapse(hUlt, iUlt)

CreateCleanToggle(tConfig, "ANTI AFK", "AntiAFK", Color3.fromRGB(80, 200, 80))

-- NÚT DESTROY SCRIPT CÓ XÁC NHẬN
CreateButton(tConfig, "🛑 DESTROY SCRIPT", function() 
    ConfirmFrame.Visible = true 
end, Color3.fromRGB(200, 40, 40))

-- Update Status UI
task.spawn(function()
    while task.wait(1) do
        if not getgenv().SkyZenHub_IsRunning then break end
        pcall(function()
            local pId, cZone = game.PlaceId, getCurrentAreaNumber()
            local world = pId == 8737899170 and "W1" or (pId == 16498369169 and "W2" or (pId == 17503543197 and "W3" or "W4"))
            local zt = tostring(cZone)
            if pId == 8737899170 and cZone == 1 then zt = "Spawn" elseif pId == 16498369169 and cZone == 100 then zt = "Tech Spawn" elseif pId == 17503543197 and cZone == 200 then zt = "Void Spawn" elseif (pId == 140403681187145 or pId == 17720827393) and cZone == 240 then zt = "Fantasy Spawn" end 
            WorldStatus.Text = "🌍 World: " .. world
            ZoneStatus.Text = "📍 Zone: " .. zt
            ZoneStatus.BackgroundTransparency = 1 -- FIX: Chỉnh sửa lại thuộc tính
        end)
    end
end)

-- ==========================================
-- 5. BACKGROUND LOOPS (FARM & RANK)
-- ==========================================

-- VÒNG LẶP AUTO GOLD & AUTO RAINBOW (ĐỘC LẬP)
task.spawn(function()
    while task.wait(5) do
        if not getgenv().SkyZenHub_IsRunning then break end
        
        -- Không tranh chấp nếu Rank Quests đang xài máy
        if getgenv().IsDoingSpecificQuest then continue end
        
        pcall(function()
            local s, d = pcall(function() return SaveModule.Get() end)
            if not s or not d or not d.Inventory or not d.Inventory.Pet then return end
            
            local pId = game.PlaceId
            local uSC = HAS_SUPER_COMPUTER and (pId == 16498369169 or pId == 17503543197 or pId == 140403681187145 or pId == 17720827393)
            
            -- AUTO GOLD
            if (Toggles.GoldBest or Toggles.GoldAll) and isAreaUnlocked(31) then
                local be = getBestEggNameForPlayer()
                local vP = be and getPetsFromEgg(be) or {}
                local nP = {}
                
                for u, petData in pairs(d.Inventory.Pet) do 
                    if not petData.l and not petData.locked and not petData.lk and (tonumber(petData.pt) or 0) == 0 then
                        local isTarget = false
                        if Toggles.GoldAll then 
                            isTarget = true 
                        elseif Toggles.GoldBest then
                            local id = tostring(petData.id)
                            for vp, _ in pairs(vP) do 
                                if id == vp or string.find(id, vp) or string.find(vp, id) then isTarget = true; break end 
                            end
                        end
                        
                        if isTarget then
                            local cr = math.floor((tonumber(petData._am) or 1) / 10)
                            if cr > 0 then table.insert(nP, {uid = u, crafts = cr}) end
                        end
                    end
                end
                
                if #nP > 0 then
                    getgenv().IsDoingSpecificQuest = true
                    if uSC then
                        for _, rq in ipairs(nP) do safeMachineFire("GoldMachine", "GoldMachine_Activate", rq.uid, rq.crafts); task.wait(0.2) end
                    else
                        performMachineAction(function()
                            for _, rq in ipairs(nP) do safeMachineFire("GoldMachine", "GoldMachine_Activate", rq.uid, rq.crafts); task.wait(0.2) end
                        end, 31, "GoldMachine")
                    end
                    getgenv().IsDoingSpecificQuest = false
                    task.wait(1)
                end
            end
            
            -- AUTO RAINBOW
            if (Toggles.RainBest or Toggles.RainAll) and isAreaUnlocked(41) then
                local be = getBestEggNameForPlayer()
                local vP = be and getPetsFromEgg(be) or {}
                local gP = {}
                
                for u, petData in pairs(d.Inventory.Pet) do 
                    if not petData.l and not petData.locked and not petData.lk and (tonumber(petData.pt) or 0) == 1 then
                        local isTarget = false
                        if Toggles.RainAll then 
                            isTarget = true 
                        elseif Toggles.RainBest then
                            local id = tostring(petData.id)
                            for vp, _ in pairs(vP) do 
                                if id == vp or string.find(id, vp) or string.find(vp, id) then isTarget = true; break end 
                            end
                        end
                        
                        if isTarget then
                            local cr = math.floor((tonumber(petData._am) or 1) / 10)
                            if cr > 0 then table.insert(gP, {uid = u, crafts = cr}) end
                        end
                    end
                end
                
                if #gP > 0 then
                    getgenv().IsDoingSpecificQuest = true
                    if uSC then
                        for _, rq in ipairs(gP) do safeMachineFire("RainbowMachine", "RainbowMachine_Activate", rq.uid, rq.crafts); task.wait(0.2) end
                    else
                        performMachineAction(function()
                            for _, rq in ipairs(gP) do safeMachineFire("RainbowMachine", "RainbowMachine_Activate", rq.uid, rq.crafts); task.wait(0.2) end
                        end, 41, "RainbowMachine")
                    end
                    getgenv().IsDoingSpecificQuest = false
                    task.wait(1)
                end
            end
        end)
    end
end)

local function KaitunClicker()
    pcall(function()
        local center = Main.AbsolutePosition + (Main.AbsoluteSize * 0.5)
        vim:SendMouseButtonEvent(center.X, center.Y, 0, true, game, 1); task.wait(0.05); vim:SendMouseButtonEvent(center.X, center.Y, 0, false, game, 1)
    end)
end

task.spawn(function()
    while task.wait(0.5) do
        if not getgenv().SkyZenHub_IsRunning then break end
        if Toggles.KaitunMode then
            pcall(function()
                for _, gui in ipairs(player.PlayerGui:GetChildren()) do
                    if gui:IsA("ScreenGui") and gui.Enabled then
                        local isS = false
                        for _, d in ipairs(gui:GetDescendants()) do if d:IsA("TextLabel") and string.find(string.lower(d.Text), "pick 2 pets") then isS = true; break end end
                        if isS then
                            local pB, oB = {}, nil
                            for _, d in ipairs(gui:GetDescendants()) do
                                if d:IsA("GuiButton") and d.Visible and d.AbsoluteSize.X > 30 then
                                    local isO = false
                                    if d:IsA("TextButton") and string.find(string.lower(d.Text), "ok") then isO = true end
                                    for _, c in ipairs(d:GetDescendants()) do if c:IsA("TextLabel") and string.find(string.lower(c.Text), "ok") then isO = true; break end end
                                    if isO then oB = d else local isC = false if d:IsA("TextButton") and (string.lower(d.Text) == "x" or string.find(string.lower(d.Text), "close")) then isC = true end if not isC then table.insert(pB, d) end end
                                end
                            end
                            table.sort(pB, function(a, b) return a.AbsolutePosition.X < b.AbsolutePosition.X end)
                            if #pB >= 2 then for i = 1, 2 do KaitunClicker(); task.wait(0.3) end end
                            if oB then task.wait(0.5); KaitunClicker() end
                            break
                        end
                    end
                end
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(1) do
        if not getgenv().SkyZenHub_IsRunning then break end
        if (Toggles.BuyZone or Toggles.AutoFarmArea) and not getgenv().IsMachineActionActive and not Toggles.HatchBest and not targetEggName and not getgenv().IsDoingSpecificQuest then
            local cM, _ = getHighestUnlockedZoneNumAndInst()
            if cM then
                for _, z in ipairs(getAllZoneInstances()) do
                    local n = tonumber(string.match(z.Name, "^(%d+)"))
                    if n == cM + 1 then 
                        local cl = string.match(z.Name, "%d+%s*|%s*(.+)") or z.Name
                        if cl then pcall(function() Network:FindFirstChild("Zones_RequestPurchase"):InvokeServer(cl) end); task.wait(0.5); local nM, _ = getHighestUnlockedZoneNumAndInst() if nM > cM then forceTeleportToBestZone() end end
                        break 
                    end 
                end
            end
        end
    end
end)

-- >>> VÒNG LẶP TELEPORT CHO AUTO FARM AREA + THUẬT TOÁN ĐO KHU VỰC SÀN BREAKZONE NHANH VÀ CHUẨN XÁC HƠN <<<
task.spawn(function()
    while task.wait(0.5) do
        if not getgenv().SkyZenHub_IsRunning then break end
        if (Toggles.AutoFarmArea or Toggles.Rank or Toggles.TpArea) and not getgenv().IsMachineActionActive and not Toggles.HatchBest and not targetEggName and not getgenv().IsDoingSpecificQuest and not getgenv().DoingLegendaryQuest then
            local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            local _, bI = getHighestUnlockedZoneNumAndInst()
            if hrp and bI then
                local zP = getZonePosition(bI)
                local bZone = getValidBreakZone(bI)
                
                local maxDist = 300
                if Toggles.AutoFarmArea then
                    maxDist = 50 
                    if bZone then
                        if bZone:IsA("BasePart") then
                            maxDist = (math.max(bZone.Size.X, bZone.Size.Z) / 2) + 15
                        elseif bZone:IsA("Model") then
                            local ext = bZone:GetExtentsSize()
                            maxDist = (math.max(ext.X, ext.Z) / 2) + 15
                        end
                    end
                    if maxDist < 40 then maxDist = 40 end -- Đảm bảo luôn có vùng đệm tối thiểu
                end

                if zP and (hrp.Position - zP).Magnitude > maxDist then 
                    forceTeleportToBestZone() 
                end
            end
        end
    end
end)

task.spawn(function()
    while task.wait(2) do
        if not getgenv().SkyZenHub_IsRunning then break end
        if Toggles.Ultimate and getgenv().TargetUltimate and not getgenv().IsMachineActionActive then
            pcall(function() Network:FindFirstChild("Ultimates: Activate"):InvokeServer(getgenv().TargetUltimate) end)
        end
        if Toggles.AutoBundleEnchant then pcall(function() Network:FindFirstChild("GiftBag_Open"):InvokeServer("Enchant Bundle", 100) end) end
        if Toggles.AutoBundlePotion then pcall(function() Network:FindFirstChild("GiftBag_Open"):InvokeServer("Potion Bundle", 100) end) end
        if Toggles.AutoBundleFruit then pcall(function() Network:FindFirstChild("GiftBag_Open"):InvokeServer("Fruit Bundle", 100) end) end
        if Toggles.AutoBundleFlag then pcall(function() Network:FindFirstChild("GiftBag_Open"):InvokeServer("Flag Bundle", 100) end) end
    end
end)

local cachedBreakables = {}
local lastCacheTime = 0
task.spawn(function()
    while true do
        local delayTime = (getgenv().FastFarmSpeedMs or 300) * 0.001
        task.wait(delayTime)
        if not getgenv().SkyZenHub_IsRunning then break end
        if (Toggles.AutoFarmArea or Toggles.FastFarm) and not getgenv().IsMachineActionActive then
            pcall(function()
                local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                if not hrp then return end
                local bf = workspace:FindFirstChild("__THINGS") and workspace.__THINGS:FindFirstChild("Breakables")
                if not bf then return end
                local mP = hrp.Position; local r = getgenv().FarmRadius or 150
                if tick() - lastCacheTime > 1.5 then
                    cachedBreakables = {}
                    for _, b in ipairs(bf:GetChildren()) do pcall(function() local dist = (mP - b:GetPivot().Position).Magnitude if dist <= r then table.insert(cachedBreakables, {n = b, d = dist}) end end) end
                    lastCacheTime = tick()
                end
                local vt = {}
                for _, i in ipairs(cachedBreakables) do if i.n and i.n.Parent then table.insert(vt, i) end end
                if #vt > 0 then
                    if Toggles.FastFarm then
                        local euids = {}
                        pcall(function() if PlayerPet and type(PlayerPet.GetAll) == "function" then for u, dt in pairs(PlayerPet.GetAll()) do if dt.owner == player then table.insert(euids, tostring(u)) end end end end)
                        if #euids > 0 then
                            local pl = {}; local bI = 1
                            for _, u in ipairs(euids) do pl[u] = vt[bI].n.Name; bI = bI + 1; if bI > #vt then bI = 1 end end
                            pcall(function() Network:FindFirstChild("Breakables_JoinPetBulk"):FireServer(pl) end)
                        end
                        local mT = getgenv().FastFarmTargets or 10; local tH = 0
                        local dr = Network:FindFirstChild("Breakables_PlayerDealDamage")
                        if dr then for _, bD in ipairs(vt) do if tH >= mT then break end tH = tH + 1 task.spawn(function() pcall(function() dr:FireServer(bD.n.Name) end) end) end end
                    else
                        local tN = (getgenv().AutoTapMode == "Random") and vt[math.random(1, #vt)].n or (table.sort(vt, function(a, b) return a.d < b.d end) and vt[1].n or vt[1].n)
                        if tN and tN.Name then pcall(function() Network:FindFirstChild("Breakables_PlayerDealDamage"):FireServer(tN.Name) end) end
                    end
                end
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(0.2) do
        if not getgenv().SkyZenHub_IsRunning then break end
        if (Toggles.Orbs or Toggles.AutoFarmArea) and not getgenv().IsMachineActionActive then
            pcall(function()
                local orbs = workspace:FindFirstChild("__THINGS") and workspace.__THINGS:FindFirstChild("Orbs")
                if orbs and #orbs:GetChildren() > 0 then
                    local ids = {}
                    for _, o in ipairs(orbs:GetChildren()) do table.insert(ids, tonumber(o.Name)) end
                    pcall(function() Network:FindFirstChild("Orbs: Collect"):FireServer(ids) end)
                    for _, o in ipairs(orbs:GetChildren()) do pcall(function() o:Destroy() end) end
                end
            end)
        end
    end
end)

-- VÒNG LẶP AUTO BUY SLOTS ĐÃ ĐƯỢC CHỈNH SỬA CƠ CHẾ KIỂM TRA TARGET LỚN HƠN HOẶC BẰNG
task.spawn(function()
    getgenv().SlotFailCounts = getgenv().SlotFailCounts or { Pet = 0, Egg = 0 }
    getgenv().SlotLastFailTime = getgenv().SlotLastFailTime or { Pet = 0, Egg = 0 }
    getgenv().LastRank_Slot = getgenv().LastRank_Slot or getPlayerRank()

    while task.wait(3) do
        if not getgenv().SkyZenHub_IsRunning then break end
        local cR = getPlayerRank()
        if cR > getgenv().LastRank_Slot then getgenv().SlotFailCounts.Pet = 0; getgenv().SlotFailCounts.Egg = 0; getgenv().LastRank_Slot = cR end

        -- Xử lý mua Pet Slot
        if Toggles.BuySlot then
            pcall(function()
                if getgenv().SlotFailCounts.Pet >= 3 and tick() - getgenv().SlotLastFailTime.Pet < 300 then return end
                local cP, pP = 4, 0
                if SaveModule then local d = SaveModule.Get() if d then cP = d.MaxPetsEquipped or 4; pP = d.PetSlotsPurchased or d.PetsSlotsPurchased or d.PetEquipsPurchased or d.EquipSlotsPurchased or 0 end end
                if pP == 0 and cP > 4 then pP = cP - 4 end
                
                -- ĐIỀU KIỆN MỚI: Nếu số slot hiện tại (cP) nhỏ hơn Target đặt ra thì mới mua tiếp
                if cP < getgenv().TargetEquipSlots then
                    local tU = pP + 1; local preP = pP
                    pcall(function() Network:FindFirstChild("EquipSlotsMachine_RequestPurchase"):InvokeServer(tU) end)
                    pcall(function() Network:FindFirstChild("PetSlotsMachine_RequestPurchase"):InvokeServer(tU) end)
                    pcall(function() Network:FindFirstChild("PetsSlotsMachine_RequestPurchase"):InvokeServer(tU) end)
                    task.wait(1.5)
                    local pPo = preP
                    pcall(function() local d = SaveModule.Get() pPo = d.PetSlotsPurchased or d.PetsSlotsPurchased or d.PetEquipsPurchased or preP end)
                    if pPo == preP then getgenv().SlotFailCounts.Pet = getgenv().SlotFailCounts.Pet + 1; getgenv().SlotLastFailTime.Pet = tick() else getgenv().SlotFailCounts.Pet = 0 end
                end
            end)
        end
        
        -- Xử lý mua Egg Slot
        if Toggles.BuyEggSlot then
            pcall(function()
                if getgenv().SlotFailCounts.Egg >= 3 and tick() - getgenv().SlotLastFailTime.Egg < 300 then return end
                local cE, pE = 1, 0
                if SaveModule then local d = SaveModule.Get() if d then cE = d.EggHatchCount or 1; pE = d.EggSlotsPurchased or d.HatchSlotsPurchased or 0 end end
                if pE == 0 and cE > 1 then pE = cE - 1 end
                
                -- ĐIỀU KIỆN MỚI: Nếu số slot trứng hiện tại (cE) nhỏ hơn Target đặt ra thì mới mua tiếp
                if cE < getgenv().TargetEggSlots then
                    local allowed = 0
                    pcall(function() allowed = RankCmds.GetEggSlotsBeforeRank(cR); local rD = require(ReplicatedStorage.Library.Directory.Ranks)[cR] if rD and rD.UnlockableEggSlots then allowed = allowed + rD.UnlockableEggSlots end end)
                    if not (allowed > 0 and pE < allowed or true) then return end
                    local tU = pE + 1; local preP = pE
                    local eReq = Network:FindFirstChild("EggHatchSlotsMachine_RequestPurchase")
                    if eReq then
                        if HAS_SUPER_COMPUTER and (game.PlaceId == 16498369169 or game.PlaceId == 17503543197 or game.PlaceId == 140403681187145 or game.PlaceId == 17720827393) then pcall(function() eReq:InvokeServer(tU) end) else performMachineAction(function() pcall(function() eReq:InvokeServer(tU) end) end, 8, "EggHatchSlotsMachine") end
                    end
                    task.wait(1.5)
                    local pPo = preP
                    pcall(function() local d = SaveModule.Get() pPo = d.EggSlotsPurchased or d.HatchSlotsPurchased or preP end)
                    if pPo == preP then getgenv().SlotFailCounts.Egg = getgenv().SlotFailCounts.Egg + 1; getgenv().SlotLastFailTime.Egg = tick() else getgenv().SlotFailCounts.Egg = 0 end
                end
            end)
        end
    end
end)

local isHatching = false
task.spawn(function()
    while task.wait(0.1) do 
        if not getgenv().SkyZenHub_IsRunning then break end
        if not isHatching then
            local tEgg = (Toggles.HatchBest and getBestEggNameForPlayer()) or targetEggName
            if tEgg then
                isHatching = true
                
                if Toggles.HatchBest then
                    local cZ, bZ = getCurrentAreaNumber(), getHighestUnlockedZoneNumAndInst()
                    if cZ ~= bZ then getgenv().IsMachineActionActive = true; forceTeleportToBestZone(); task.wait(0.5); getgenv().IsMachineActionActive = false end
                else
                    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                    local n = getgenv().EggNameToNumber[tEgg]
                    local cN = n and (tostring(n) .. " - Egg Capsule") or ""
                    local cap = nil
                    local t = workspace:FindFirstChild("__THINGS")
                    if t then
                        local pId = game.PlaceId
                        if pId == 17503543197 then cap = t:FindFirstChild("Eggs") and t.Eggs:FindFirstChild(cN, true) end
                        if not cap then cap = t:FindFirstChild("ZoneEggs") and t.ZoneEggs:FindFirstChild(cN, true) end
                        if not cap then cap = t:FindFirstChild("Eggs") and t.Eggs:FindFirstChild(cN, true) end
                    end
                    if hrp and cap and (hrp.Position - cap:GetPivot().Position).Magnitude > 50 then getgenv().IsMachineActionActive = true; teleportToEgg(tEgg); task.wait(0.5); getgenv().IsMachineActionActive = false end
                end
                
                task.spawn(function() 
                    local bm = getMaxHatchAmount()
                    pcall(function() Network:FindFirstChild("Eggs_RequestPurchase"):InvokeServer(tEgg, bm) end) 
                end)
                isHatching = false
            end
        end
    end
end)

-- AUTO CLAIM MAIL 
task.spawn(function()
    local function SnipeMail()
        pcall(function() Network:FindFirstChild("Machines: Mark Approached"):FireServer("MailboxMachine") end)
        task.wait(0.2)
        local cAll = Network:FindFirstChild("Mailbox: Claim All")
        if cAll then
            local s, err = pcall(function() return cAll:InvokeServer() end)
            if err == "You must wait 30 seconds before using the mailbox!" then task.wait(31); if Toggles.AutoClaimMail and getgenv().SkyZenHub_IsRunning then return SnipeMail() end end
        end
    end
    while task.wait(2) do if not getgenv().SkyZenHub_IsRunning then break end if Toggles.AutoClaimMail then SnipeMail(); task.wait(60) end end
end)

-- >>> KHỐI LỆNH TRƯỚC ĐÂY ĐÃ ĐƯỢC CHUYỂN HOÀN TOÀN SANG CƠ CHẾ ĐỌC QUEST THỨ TỰ MÀN HÌNH CHỐNG KẸT <<<
task.spawn(function()
    while task.wait(1) do
        if not getgenv().SkyZenHub_IsRunning then break end
        if Toggles.Rank and isAreaUnlocked(41) then
            pcall(function()
                if tick() - lastRankClaim >= 15 then 
                    lastRankClaim = tick()
                    task.spawn(function() local e = Network:FindFirstChild("Ranks_ClaimReward") if e then for i=1, 99 do pcall(function() e:FireServer(i) end) task.wait(0.02) end end end) 
                end

                local qs = GetActiveRankQuests()
                local tq = nil
                local function skip(raw) if raw then globalIgnoredQuests[raw] = tick() + 60 end end

                -- Duyệt tuần tự từ Quest 1 -> Quest 2 -> Quest 3 -> Quest 4
                for _, q in ipairs(qs) do
                    if not (globalIgnoredQuests[q.raw] and tick() < globalIgnoredQuests[q.raw]) then
                        local text = q.txt
                        local matched = false 
                        
                        -- 1. LEGENDARY
                        if RankConfig.Legendary and string.find(text, "legendary") then
                            getgenv().DoingLegendaryQuest = true; local be = getBestEggNameForPlayer()
                            if be then
                                local tE = be; local bI = 0
                                for i, e in ipairs(GLOBAL_EGG_DATA) do if e.name == be then bI = i; break end end
                                local off = getgenv().LegendaryEggOffset or 1
                                tE = (bI > off) and GLOBAL_EGG_DATA[bI - off].name or GLOBAL_EGG_DATA[1].name
                                
                                local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                                local n = getgenv().EggNameToNumber[tE]; local cN = n and (tostring(n) .. " - Egg Capsule") or ""; local cap = nil
                                local t = workspace:FindFirstChild("__THINGS")
                                if t then local pId = game.PlaceId if pId == 17503543197 then cap = t:FindFirstChild("Eggs") and t.Eggs:FindFirstChild(cN, true) end if not cap then cap = t:FindFirstChild("ZoneEggs") and t.ZoneEggs:FindFirstChild(cN, true) end if not cap then cap = t:FindFirstChild("Eggs") and t.Eggs:FindFirstChild(cN, true) end end
                                if hrp and cap and (hrp.Position - cap:GetPivot().Position).Magnitude > 50 then getgenv().IsMachineActionActive = true; teleportToEgg(tE); task.wait(0.5); getgenv().IsMachineActionActive = false end
                                
                                task.spawn(function() pcall(function() Network:FindFirstChild("Eggs_RequestPurchase"):InvokeServer(tE, getMaxHatchAmount()) end) end)
                                task.wait(0.1)
                            else skip(q.raw) end
                            matched = true

                        -- 2. HATCH
                        elseif RankConfig.Hatch and string.find(text, "hatch") and not string.find(text, "legendary") then
                            local be = getBestEggNameForPlayer()
                            if be then 
                                if getCurrentAreaNumber() ~= getHighestUnlockedZoneNumAndInst() and not getgenv().DoingLegendaryQuest then getgenv().IsMachineActionActive = true; forceTeleportToBestZone(); task.wait(0.5); getgenv().IsMachineActionActive = false end
                                task.spawn(function() pcall(function() Network:FindFirstChild("Eggs_RequestPurchase"):InvokeServer(be, getMaxHatchAmount()) end) end)
                                task.wait(0.1)
                            else skip(q.raw) end
                            matched = true

                        -- 3. DRINK POTION
                        elseif RankConfig.Potion and (string.find(text, "drink") or string.find(text, "use")) and string.find(text, "potion") then
                            if tick() - lastItemUse >= 1.25 then
                                local tNum = tonumber(string.match(text, "tier%s+([ivx%d]+)")) or ROMAN_MAP[string.match(text, "tier%s+([ivx%d]+)")] or 1
                                local u = getOrderedConsumablePotionUID(tNum)
                                if u then for i = 1, q.remaining do pcall(function() Network:FindFirstChild("Potions: Consume"):FireServer(u, 1) end); task.wait(0.1) end lastItemUse = tick(); skip(q.raw) else skip(q.raw) end
                            end
                            matched = true

                        -- 4. UNLOCK AREA
                        elseif RankConfig.Area and (string.find(text, "unlock") or string.find(text, "reach")) and string.find(text, "area") then
                            local ca = getCurrentAreaNumber()
                            for _, z in ipairs(getAllZoneInstances()) do if tonumber(string.match(z.Name, "^(%d+)")) == ca + 1 then local cl = string.match(z.Name, "%d+%s*|%s*(.+)") or z.Name if cl then pcall(function() Network:FindFirstChild("Zones_RequestPurchase"):InvokeServer(cl) end); task.wait(0.5); forceTeleportToBestZone() end break end end
                            matched = true

                        -- 5. UPGRADE POTION
                        elseif RankConfig.UpPotion and ((string.find(text, "potion") and string.find(text, "upgrade")) or (string.find(text, "collect") and string.find(text, "potion"))) and isAreaUnlocked(13) then
                            local r = getBulkUpgradableItems("Potion", q.remaining, tonumber(string.match(text, "tier%s+([ivx%d]+)")) or ROMAN_MAP[string.match(text, "tier%s+([ivx%d]+)")])
                            if r and #r > 0 then getgenv().IsDoingSpecificQuest = true; if HAS_SUPER_COMPUTER and (game.PlaceId == 16498369169 or game.PlaceId == 17503543197 or game.PlaceId == 140403681187145 or game.PlaceId == 17720827393) then for _, rq in ipairs(r) do safeMachineFire("UpgradePotionsMachine", "UpgradePotionsMachine_Activate", rq.uid, rq.crafts); task.wait(0.2) end else performMachineAction(function() for _, rq in ipairs(r) do safeMachineFire("UpgradePotionsMachine", "UpgradePotionsMachine_Activate", rq.uid, rq.crafts); task.wait(0.2) end end, 13, "UpgradePotionsMachine") end getgenv().IsDoingSpecificQuest = false; skip(q.raw) else skip(q.raw) end
                            matched = true

                        -- 6. UPGRADE ENCHANT
                        elseif RankConfig.UpEnchant and ((string.find(text, "enchant") and string.find(text, "upgrade")) or (string.find(text, "collect") and string.find(text, "enchant"))) and isAreaUnlocked(16) then
                            local r = getBulkUpgradableItems("Enchant", q.remaining, tonumber(string.match(text, "tier%s+([ivx%d]+)")) or ROMAN_MAP[string.match(text, "tier%s+([ivx%d]+)")])
                            if r and #r > 0 then getgenv().IsDoingSpecificQuest = true; if HAS_SUPER_COMPUTER and (game.PlaceId == 16498369169 or game.PlaceId == 17503543197 or game.PlaceId == 140403681187145 or game.PlaceId == 17720827393) then for _, rq in ipairs(r) do safeMachineFire("UpgradeEnchantsMachine", "UpgradeEnchantsMachine_Activate", rq.uid, rq.crafts); task.wait(0.2) end else performMachineAction(function() for _, rq in ipairs(r) do safeMachineFire("UpgradeEnchantsMachine", "UpgradeEnchantsMachine_Activate", rq.uid, rq.crafts); task.wait(0.2) end end, 16, "UpgradeEnchantsMachine") end getgenv().IsDoingSpecificQuest = false; skip(q.raw) else skip(q.raw) end
                            matched = true

                        -- 7. GOLDEN PETS
                        elseif RankConfig.Gold and string.find(text, "golden") and isAreaUnlocked(31) then
                            local be = getBestEggNameForPlayer(); local vP = be and getPetsFromEgg(be) or {}; local nP, tC = {}, 0
                            if SaveModule then pcall(function() for u, d in pairs(SaveModule.Get().Inventory.Pet) do if not d.l and not d.locked and not d.lk and (tonumber(d.pt) or 0) == 0 then local id = tostring(d.id); local iM = false; for vp, _ in pairs(vP) do if id == vp or string.find(id, vp) or string.find(vp, id) then iM = true; break end end if iM then local cr = math.floor((tonumber(d._am) or 1) / 10); if cr > 0 then table.insert(nP, {uid = u, crafts = cr}); tC = tC + cr end end end end end) end
                            if tC > 0 then
                                local cQ, cR = {}, q.remaining; table.sort(nP, function(a, b) return a.crafts > b.crafts end)
                                for _, it in ipairs(nP) do if cR > 0 then local tc = math.min(it.crafts, cR); table.insert(cQ, {uid = it.uid, amt = tc}); cR = cR - tc end end
                                if #cQ > 0 then getgenv().IsDoingSpecificQuest = true; if HAS_SUPER_COMPUTER and (game.PlaceId == 16498369169 or game.PlaceId == 17503543197 or game.PlaceId == 140403681187145 or game.PlaceId == 17720827393) then for _, rq in ipairs(cQ) do safeMachineFire("GoldMachine", "GoldMachine_Activate", rq.uid, rq.amt); task.wait(0.2) end else performMachineAction(function() for _, rq in ipairs(cQ) do safeMachineFire("GoldMachine", "GoldMachine_Activate", rq.uid, rq.amt); task.wait(0.2) end end, 31, "GoldMachine") end getgenv().IsDoingSpecificQuest = false end
                            end
                            if tC < q.remaining and be then if getCurrentAreaNumber() ~= getHighestUnlockedZoneNumAndInst() then getgenv().IsMachineActionActive = true; forceTeleportToBestZone(); task.wait(0.5); getgenv().IsMachineActionActive = false end task.spawn(function() pcall(function() Network:FindFirstChild("Eggs_RequestPurchase"):InvokeServer(be, getMaxHatchAmount()) end) end); task.wait(0.1) end
                            matched = true

                        -- 8. RAINBOW PETS
                        elseif RankConfig.Rainbow and string.find(text, "rainbow") and isAreaUnlocked(41) then
                            local be = getBestEggNameForPlayer(); local vP = be and getPetsFromEgg(be) or {}; local nP, gP, tC, tR = {}, {}, 0, 0
                            if SaveModule then pcall(function() for u, d in pairs(SaveModule.Get().Inventory.Pet) do if not d.l and not d.locked and not d.lk then local pt = tonumber(d.pt) or 0 if pt == 0 or pt == 1 then local id = tostring(d.id); local iM = false; for vp, _ in pairs(vP) do if id == vp or string.find(id, vp) or string.find(vp, id) then iM = true; break end end if iM then local cr = math.floor((tonumber(d._am) or 1) / 10); if cr > 0 then if pt == 0 then table.insert(nP, {uid = u, crafts = cr}); tC = tC + cr elseif pt == 1 then table.insert(gP, {uid = u, crafts = cr}); tR = tR + cr end end end end end end end) end
                            local pId, uSC = game.PlaceId, HAS_SUPER_COMPUTER and (game.PlaceId == 16498369169 or game.PlaceId == 17503543197 or game.PlaceId == 140403681187145 or game.PlaceId == 17720827393)
                            if tR > 0 then
                                local cQ, cR = {}, q.remaining; table.sort(gP, function(a, b) return a.crafts > b.crafts end)
                                for _, it in ipairs(gP) do if cR > 0 then local tc = math.min(it.crafts, cR); table.insert(cQ, {uid = it.uid, amt = tc}); cR = cR - tc end end
                                if #cQ > 0 then getgenv().IsDoingSpecificQuest = true; if uSC then for _, rq in ipairs(cQ) do safeMachineFire("RainbowMachine", "RainbowMachine_Activate", rq.uid, rq.amt); task.wait(0.2) end else performMachineAction(function() for _, rq in ipairs(cQ) do safeMachineFire("RainbowMachine", "RainbowMachine_Activate", rq.uid, rq.amt); task.wait(0.2) end end, 41, "RainbowMachine") end getgenv().IsDoingSpecificQuest = false end
                            end
                            if tR < q.remaining then
                                if tC > 0 then
                                    local mG = (q.remaining - tR) * 10; local cQ, cR = {}, mG; table.sort(nP, function(a, b) return a.crafts > b.crafts end)
                                    for _, it in ipairs(nP) do if cR > 0 then local tc = math.min(it.crafts, cR); table.insert(cQ, {uid = it.uid, amt = tc}); cR = cR - tc end end
                                    if #cQ > 0 then getgenv().IsDoingSpecificQuest = true; if uSC then for _, rq in ipairs(cQ) do safeMachineFire("GoldMachine", "GoldMachine_Activate", rq.uid, rq.amt); task.wait(0.2) end else performMachineAction(function() for _, rq in ipairs(cQ) do safeMachineFire("GoldMachine", "GoldMachine_Activate", rq.uid, rq.amt); task.wait(0.2) end end, 31, "GoldMachine") end getgenv().IsDoingSpecificQuest = false end
                                end
                                if (tR * 10 + tC) < (q.remaining * 10) and be then if getCurrentAreaNumber() ~= getHighestUnlockedZoneNumAndInst() then getgenv().IsMachineActionActive = true; forceTeleportToBestZone(); task.wait(0.5); getgenv().IsMachineActionActive = false end task.spawn(function() pcall(function() Network:FindFirstChild("Eggs_RequestPurchase"):InvokeServer(be, getMaxHatchAmount()) end) end); task.wait(0.1) end
                            end
                            matched = true

                        -- 9. FLAG
                        elseif RankConfig.Flag and string.find(text, "flag") then
                            if tick() - lastItemUse >= 1.25 then
                                local fL = {"Fortune Flag", "Strength Flag", "Magnet Flag", "Coins Flag", "Hasty Flag", "Diamonds Flag", "Rainbow Flag", "Shiny Flag"}
                                local fn = false; for _, f in ipairs(fL) do local u = getMiscItemUID(f, false); if u then pcall(function() Network:FindFirstChild("FlexibleFlags_Consume"):InvokeServer(f, u) end); lastItemUse = tick(); fn = true; break end end
                                if not fn then skip(q.raw) end
                            end
                            matched = true

                        -- 10. FRUIT
                        elseif RankConfig.Fruit and string.find(text, "fruit") then
                            if tick() - lastItemUse >= 1.25 then
                                if lastRankFruitProgress ~= -1 and q.prog == lastRankFruitProgress then currentRankFruitIndex = currentRankFruitIndex + 1; if currentRankFruitIndex > #rankFruitList then currentRankFruitIndex = 1 end end
                                local fU = rankFruitList[currentRankFruitIndex]; local u = getMiscItemUID(fU, false) or getMiscItemUID(fU=="Rainbow Fruit" and "Rainbow" or fU:gsub(" ",""), false)
                                if u then pcall(function() Network:FindFirstChild("Fruits: Consume"):FireServer(u, 1) end); lastItemUse = tick(); lastRankFruitProgress = q.prog else skip(q.raw) end
                            end
                            matched = true

                        -- 11. COMET
                        elseif RankConfig.Comet and string.find(text, "comet") then
                            if tick() - lastItemUse >= 1.25 then
                                local u = getMiscItemUID("Comet", false)
                                if u then for i = 1, q.remaining do pcall(function() Network:FindFirstChild("Comet_Spawn"):InvokeServer(u) end); task.wait(0.1) end lastItemUse = tick() else skip(q.raw) end
                            end
                            matched = true

                        -- 12. COIN JAR
                        elseif RankConfig.Jar and string.find(text, "coin") and string.find(text, "jar") then
                            if tick() - lastItemUse >= 1.25 then
                                local u = nil; for _, i in ipairs({"Basic Coin Jar", "CoinJar", "Coin Jar", "Jar"}) do u = getMiscItemUID(i, false); if u then break end end
                                if u then pcall(function() Network:FindFirstChild("CoinJar_Spawn"):InvokeServer(u) end); lastItemUse = tick() else skip(q.raw) end
                            end
                            matched = true

                        -- 13. PINATA
                        elseif RankConfig.Pinata and string.find(text, "pinata") then
                            if tick() - lastItemUse >= 1.25 then
                                local u = nil; for _, i in ipairs({"Mini Pinata", "MiniPinata"}) do u = getMiscItemUID(i, false); if u then break end end
                                if u then pcall(function() Network:FindFirstChild("MiniPinata_Consume"):InvokeServer(u) end); lastItemUse = tick() else skip(q.raw) end
                            end
                            matched = true

                        -- 14. LUCKY BLOCK
                        elseif RankConfig.Lucky and string.find(text, "lucky") and string.find(text, "block") then
                            if tick() - lastItemUse >= 1.25 then
                                local u = nil; for _, i in ipairs({"Mini Lucky Block", "MiniLuckyBlock"}) do u = getMiscItemUID(i, false); if u then break end end
                                if u then pcall(function() Network:FindFirstChild("MiniLuckyBlock_Consume"):InvokeServer(u) end); lastItemUse = tick() else skip(q.raw) end
                            end
                            matched = true
                        end

                        if matched then
                            tq = q
                            break
                        end
                    end
                end
                
                if not tq and getgenv().DoingLegendaryQuest then
                    getgenv().DoingLegendaryQuest = false
                    getgenv().IsMachineActionActive = true
                    forceTeleportToBestZone()
                    task.wait(0.5)
                    getgenv().IsMachineActionActive = false
                end

            end)
        end
    end
end)

-- ==========================================
-- 🚫 TỐI ƯU HÓA EGG ANIMATION BẰNG HOOK GETGC
-- ==========================================
local originalEggFuncs = {}
local function hookEggAnimations()
    pcall(function()
        for _, v in pairs(getgc(true)) do
            if type(v) == "table" then
                if rawget(v, "PlayEggAnimation") or rawget(v, "OpenEgg") or rawget(v, "PlayHatch") or rawget(v, "ShowEgg") then
                    
                    originalEggFuncs.PlayEggAnimation = originalEggFuncs.PlayEggAnimation or rawget(v, "PlayEggAnimation")
                    originalEggFuncs.OpenEgg = originalEggFuncs.OpenEgg or rawget(v, "OpenEgg")
                    originalEggFuncs.PlayHatch = originalEggFuncs.PlayHatch or rawget(v, "PlayHatch")
                    originalEggFuncs.ShowEgg = originalEggFuncs.ShowEgg or rawget(v, "ShowEgg")
                    
                    if type(rawget(v, "PlayEggAnimation")) == "function" then
                        rawset(v, "PlayEggAnimation", function(...)
                            if Toggles.HideEgg then return end
                            return originalEggFuncs.PlayEggAnimation(...)
                        end)
                    end
                    
                    if type(rawget(v, "OpenEgg")) == "function" then
                        rawset(v, "OpenEgg", function(...)
                            if Toggles.HideEgg then return end
                            return originalEggFuncs.OpenEgg(...)
                        end)
                    end
                    
                    if type(rawget(v, "PlayHatch")) == "function" then
                        rawset(v, "PlayHatch", function(...)
                            if Toggles.HideEgg then return end
                            return originalEggFuncs.PlayHatch(...)
                        end)
                    end
                    
                    if type(rawget(v, "ShowEgg")) == "function" then
                        rawset(v, "ShowEgg", function(...)
                            if Toggles.HideEgg then return end
                            return originalEggFuncs.ShowEgg(...)
                        end)
                    end
                end
            end
        end
    end)
end
task.spawn(hookEggAnimations)

-- CAMERA LOCK EGG HIDER & UI MOVER
task.spawn(function() 
    while task.wait(0.05) do 
        if not getgenv().SkyZenHub_IsRunning then break end
        if Toggles.HideEgg then
            pcall(function()
                local cam = workspace.CurrentCamera; local char = player.Character
                if cam and char and char:FindFirstChild("Humanoid") then if cam.CameraType == Enum.CameraType.Scriptable then cam.CameraType = Enum.CameraType.Custom; cam.CameraSubject = char.Humanoid end end
                for _, n in ipairs({"EggOpenAnimation", "EggHatch", "HatchUI"}) do local g = player.PlayerGui:FindFirstChild(n) if g then if g:IsA("ScreenGui") then g.Enabled = false end for _, c in ipairs(g:GetChildren()) do if c:IsA("GuiObject") then c.Position = UDim2.new(9999, 0, 9999, 0); c.Visible = false end end end end 
                for _, uN in ipairs({"Main", "MainUI", "HUD", "Bottom", "Right", "Left"}) do local mG = player.PlayerGui:FindFirstChild(uN) if mG and mG:IsA("ScreenGui") and not mG.Enabled then mG.Enabled = true end end
            end)
        else
            pcall(function() 
                for _, n in ipairs({"EggOpenAnimation", "EggHatch", "HatchUI"}) do local g = player.PlayerGui:FindFirstChild(n) if g then for _, c in ipairs(g:GetChildren()) do if c:IsA("GuiObject") and c.Position == UDim2.new(9999, 0, 9999, 0) then c.Position = UDim2.new(0.5, 0, 0.5, 0); c.Visible = true end end end end 
            end)
        end
    end 
end)

-- WEBHOOK
task.spawn(function()
    local wRUV = false
    while task.wait(1) do
        if not getgenv().SkyZenHub_IsRunning then break end
        local iRUV = false
        pcall(function() for _, g in ipairs(player.PlayerGui:GetChildren()) do if g:IsA("ScreenGui") and g.Enabled and string.find(string.lower(g.Name), "rankup") then iRUV = true; break end end end)
        if iRUV and not wRUV then
            if WHConfig.PingEnabled and WHConfig.Url ~= "" and WHConfig.TargetRank > 0 and not WHConfig.HasSentRank then
                task.wait(1) 
                local cR = getPlayerRank()
                if cR >= WHConfig.TargetRank then
                    WHConfig.HasSentRank = true
                    local pS = WHConfig.PingID ~= "" and "<@" .. WHConfig.PingID .. "> " or ""
                    local fM = pS .. player.Name .. " reached " .. tostring(cR) .. " rank"
                    if getgenv().AkumaHub and getgenv().AkumaHub.Webhook then
                        pcall(function() getgenv().AkumaHub.Webhook.Send(WHConfig.Url, WHConfig.PingID, "RANK UP!", fM, {}) end)
                    else
                        local rF = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
                        if rF then pcall(function() rF({ Url = WHConfig.Url, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = HttpService:JSONEncode({["content"] = fM, ["allowed_mentions"] = { ["parse"] = {"users", "roles", "everyone"} }}) }) end) end
                    end
                end
            end
        end
        wRUV = iRUV
    end
end)