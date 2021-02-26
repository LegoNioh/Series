require "PremiumPrediction"
require "GamsteronPrediction"
require "DamageLib"
require "2DGeometry"
require "MapPositionGOS"
require "GGPrediction"

local EnemyHeroes = {}
local AllyHeroes = {}
local EnemySpawnPos = nil
local AllySpawnPos = nil
-- [ AutoUpdate ] --
do
    
    local Version = 10101.00
    
    local Files = {
        Lua = {
            Path = SCRIPT_PATH,
            Name = "SeriesMelee.lua",
            Url = "https://raw.githubusercontent.com/LegoNioh/Series/master/SeriesMelee.lua"
        },
        Version = {
            Path = SCRIPT_PATH,
            Name = "SeriesMelee.version",
            Url = "https://raw.githubusercontent.com/LegoNioh/Series/master/SeriesMelee.version"    -- check if Raw Adress correct pls.. after you have create the version file on Github
        }
    }
    
    local function AutoUpdate()
        
        local function DownloadFile(url, path, fileName)
            DownloadFileAsync(url, path .. fileName, function() end)
            while not FileExist(path .. fileName) do end
        end
        
        local function ReadFile(path, fileName)
            local file = io.open(path .. fileName, "r")
            local result = file:read()
            file:close()
            return result
        end
        
        DownloadFile(Files.Version.Url, Files.Version.Path, Files.Version.Name)
        local textPos = myHero.pos:To2D()
        local NewVersion = tonumber(ReadFile(Files.Version.Path, Files.Version.Name))
        if NewVersion > Version then
            DownloadFile(Files.Lua.Url, Files.Lua.Path, Files.Lua.Name)
            print("New Series Version. Press 2x F6")     -- <-- you can change the massage for users here !!!!
        else
            print(Files.Version.Name .. ": No Updates Found")   --  <-- here too
        end
    
    end
    
    AutoUpdate()

end

local function IsNearEnemyTurret(pos, distance)
    --PrintChat("Checking Turrets")
    local turrets = _G.SDK.ObjectManager:GetTurrets(GetDistance(pos) + 1000)
    for i = 1, #turrets do
        local turret = turrets[i]
        if turret and GetDistance(turret.pos, pos) <= distance+915 and turret.team == 300-myHero.team then
            --PrintChat("turret")
            return turret
        end
    end
end

local function IsUnderEnemyTurret(pos)
    --PrintChat("Checking Turrets")
    local turrets = _G.SDK.ObjectManager:GetTurrets(GetDistance(pos) + 1000)
    for i = 1, #turrets do
        local turret = turrets[i]
        if turret and GetDistance(turret.pos, pos) <= 915 and turret.team == 300-myHero.team then
            --PrintChat("turret")
            return turret
        end
    end
end

function GetDifference(a,b)
    local Sa = a^2
    local Sb = b^2
    local Sdif = (a-b)^2
    return math.sqrt(Sdif)
end

function GetDistanceSqr(Pos1, Pos2)
    local Pos2 = Pos2 or myHero.pos
    local dx = Pos1.x - Pos2.x
    local dz = (Pos1.z or Pos1.y) - (Pos2.z or Pos2.y)
    return dx^2 + dz^2
end

function GetDistance(Pos1, Pos2)
    return math.sqrt(GetDistanceSqr(Pos1, Pos2))
end

function IsImmobile(unit)
    local MaxDuration = 0
    for i = 0, unit.buffCount do
        local buff = unit:GetBuff(i)
        if buff and buff.count > 0 then
            local BuffType = buff.type
            if BuffType == 5 or BuffType == 11 or BuffType == 21 or BuffType == 22 or BuffType == 24 or BuffType == 29 or buff.name == "recall" then
                local BuffDuration = buff.duration
                if BuffDuration > MaxDuration then
                    MaxDuration = BuffDuration
                end
            end
        end
    end
    return MaxDuration
end

function GetEnemyHeroes()
    for i = 1, Game.HeroCount() do
        local Hero = Game.Hero(i)
        if Hero.isEnemy then
            table.insert(EnemyHeroes, Hero)
            PrintChat(Hero.name)
        end
    end
    --PrintChat("Got Enemy Heroes")
end

function GetEnemyBase()
    for i = 1, Game.ObjectCount() do
        local object = Game.Object(i)
        
        if not object.isAlly and object.type == Obj_AI_SpawnPoint then 
            EnemySpawnPos = object
            break
        end
    end
end

function GetAllyBase()
    for i = 1, Game.ObjectCount() do
        local object = Game.Object(i)
        
        if object.isAlly and object.type == Obj_AI_SpawnPoint then 
            AllySpawnPos = object
            break
        end
    end
end

function GetAllyHeroes()
    for i = 1, Game.HeroCount() do
        local Hero = Game.Hero(i)
        if Hero.isAlly then
            table.insert(AllyHeroes, Hero)
            PrintChat(Hero.name)
        end
    end
    --PrintChat("Got Enemy Heroes")
end

function GetBuffStart(unit, buffname)
    for i = 0, unit.buffCount do
        local buff = unit:GetBuff(i)
        if buff.name == buffname and buff.count > 0 then 
            return buff.startTime
        end
    end
    return nil
end

function GetBuffExpire(unit, buffname)
    for i = 0, unit.buffCount do
        local buff = unit:GetBuff(i)
        if buff.name == buffname and buff.count > 0 then 
            return buff.expireTime
        end
    end
    return nil
end

function GetBuffStacks(unit, buffname)
    for i = 0, unit.buffCount do
        local buff = unit:GetBuff(i)
        if buff.name == buffname and buff.count > 0 then 
            return buff.count
        end
    end
    return 0
end

local function GetWaypoints(unit) -- get unit's waypoints
    local waypoints = {}
    local pathData = unit.pathing
    table.insert(waypoints, unit.pos)
    local PathStart = pathData.pathIndex
    local PathEnd = pathData.pathCount
    if PathStart and PathEnd and PathStart >= 0 and PathEnd <= 20 and pathData.hasMovePath then
        for i = pathData.pathIndex, pathData.pathCount do
            table.insert(waypoints, unit:GetPath(i))
        end
    end
    return waypoints
end

local function GetUnitPositionNext(unit)
    local waypoints = GetWaypoints(unit)
    if #waypoints == 1 then
        return nil -- we have only 1 waypoint which means that unit is not moving, return his position
    end
    return waypoints[2] -- all segments have been checked, so the final result is the last waypoint
end

local function GetUnitPositionAfterTime(unit, time)
    local waypoints = GetWaypoints(unit)
    if #waypoints == 1 then
        return unit.pos -- we have only 1 waypoint which means that unit is not moving, return his position
    end
    local max = unit.ms * time -- calculate arrival distance
    for i = 1, #waypoints - 1 do
        local a, b = waypoints[i], waypoints[i + 1]
        local dist = GetDistance(a, b)
        if dist >= max then
            return Vector(a):Extended(b, dist) -- distance of segment is bigger or equal to maximum distance, so the result is point A extended by point B over calculated distance
        end
        max = max - dist -- reduce maximum distance and check next segments
    end
    return waypoints[#waypoints] -- all segments have been checked, so the final result is the last waypoint
end

function GetTarget(range)
    if _G.SDK then
        return _G.SDK.TargetSelector:GetTarget(range, _G.SDK.DAMAGE_TYPE_MAGICAL);
    else
        return _G.GOS:GetTarget(range,"AD")
    end
end

function GotBuff(unit, buffname)
    for i = 0, unit.buffCount do
        local buff = unit:GetBuff(i)
        --PrintChat(buff.name)
        if buff.name == buffname and buff.count > 0 then 
            return buff.count
        end
    end
    return 0
end

function BuffActive(unit, buffname)
    for i = 0, unit.buffCount do
        local buff = unit:GetBuff(i)
        if buff.name == buffname and buff.count > 0 then 
            return true
        end
    end
    return false
end

function IsReady(spell)
    return myHero:GetSpellData(spell).currentCd == 0 and myHero:GetSpellData(spell).level > 0 and myHero:GetSpellData(spell).mana <= myHero.mana and Game.CanUseSpell(spell) == 0
end

function Mode()
    if _G.SDK then
        if _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_COMBO] then
            return "Combo"
        elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_HARASS] or Orbwalker.Key.Harass:Value() then
            return "Harass"
        elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_LANECLEAR] or Orbwalker.Key.Clear:Value() then
            return "LaneClear"
        elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_LASTHIT] or Orbwalker.Key.LastHit:Value() then
            return "LastHit"
        elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_FLEE] then
            return "Flee"
        end
    else
        return GOS.GetMode()
    end
end

function GetItemSlot(unit, id)
    for i = ITEM_1, ITEM_7 do
        if unit:GetItemData(i).itemID == id then
            return i
        end
    end
    return 0
end

function IsFacing(unit)
    local V = Vector((unit.pos - myHero.pos))
    local D = Vector(unit.dir)
    local Angle = 180 - math.deg(math.acos(V*D/(V:Len()*D:Len())))
    if math.abs(Angle) < 80 then 
        return true  
    end
    return false
end

function IsMyHeroFacing(unit)
    local V = Vector((myHero.pos - unit.pos))
    local D = Vector(myHero.dir)
    local Angle = 180 - math.deg(math.acos(V*D/(V:Len()*D:Len())))
    if math.abs(Angle) < 80 then 
        return true  
    end
    return false
end

function SetMovement(bool)
    if _G.PremiumOrbwalker then
        _G.PremiumOrbwalker:SetAttack(bool)
        _G.PremiumOrbwalker:SetMovement(bool)       
    elseif _G.SDK then
        _G.SDK.Orbwalker:SetMovement(bool)
        _G.SDK.Orbwalker:SetAttack(bool)
    end
end


local function CheckHPPred(unit, SpellSpeed)
     local speed = SpellSpeed
     local range = myHero.pos:DistanceTo(unit.pos)
     local time = range / speed
     if _G.SDK and _G.SDK.Orbwalker then
         return _G.SDK.HealthPrediction:GetPrediction(unit, time)
     elseif _G.PremiumOrbwalker then
         return _G.PremiumOrbwalker:GetHealthPrediction(unit, time)
    end
end

function EnableMovement()
    SetMovement(true)
end

local function IsValid(unit)
    if (unit and unit.valid and unit.isTargetable and unit.alive and unit.visible and unit.networkID and unit.pathing and unit.health > 0) then
        return true;
    end
    return false;
end


local function ValidTarget(unit, range)
    if (unit and unit.valid and unit.isTargetable and unit.alive and unit.visible and unit.networkID and unit.pathing and unit.health > 0) then
        if range then
            if GetDistance(unit.pos) <= range then
                return true;
            end
        else
            return true
        end
    end
    return false;
end
class "Manager"

function Manager:__init()
    if myHero.charName == "Xerath" then
        DelayAction(function() self:LoadXerath() end, 1.05)
    elseif myHero.charName == "Vayne" then
        DelayAction(function() self:LoadVayne() end, 1.05)
    elseif myHero.charName == "Twitch" then
        DelayAction(function() self:LoadTwitch() end, 1.05)
    end
end


function Manager:LoadXerath()
    Xerath:Spells()
    Xerath:Menu()
    --
    --GetEnemyHeroes()
    Callback.Add("Tick", function() Xerath:Tick() end)
    Callback.Add("Draw", function() Xerath:Draw() end)
    if _G.SDK then
        _G.SDK.Orbwalker:OnPreAttack(function(...) Xerath:OnPreAttack(...) end)
        _G.SDK.Orbwalker:OnPostAttackTick(function(...) Xerath:OnPostAttackTick(...) end)
        _G.SDK.Orbwalker:OnPostAttack(function(...) Xerath:OnPostAttack(...) end)
    end
end

function Manager:LoadTwitch()
    Twitch:Spells()
    Twitch:Menu()
    --
    --GetEnemyHeroes()
    Callback.Add("Tick", function() Twitch:Tick() end)
    Callback.Add("Draw", function() Twitch:Draw() end)
    if _G.SDK then
        _G.SDK.Orbwalker:OnPreAttack(function(...) Twitch:OnPreAttack(...) end)
        _G.SDK.Orbwalker:OnPostAttackTick(function(...) Twitch:OnPostAttackTick(...) end)
        _G.SDK.Orbwalker:OnPostAttack(function(...) Twitch:OnPostAttack(...) end)
    end
end

function Manager:LoadVayne()
    Vayne:Spells()
    Vayne:Menu()
    --
    --GetEnemyHeroes()
    Callback.Add("Tick", function() Vayne:Tick() end)
    Callback.Add("Draw", function() Vayne:Draw() end)
    if _G.SDK then
        _G.SDK.Orbwalker:OnPreAttack(function(...) Vayne:OnPreAttack(...) end)
        _G.SDK.Orbwalker:OnPostAttackTick(function(...) Vayne:OnPostAttackTick(...) end)
        _G.SDK.Orbwalker:OnPostAttack(function(...) Vayne:OnPostAttack(...) end)
    end
end


class "Xerath"

local EnemyLoaded = false
local TargetTime = 0

local CastingQ = false
local CastingW = false
local CastingE = false
local CastingR = false

local CastedQ = false
local TickQ = false
local CastedW = false
local TickE = false
local CastedE = false
local TickE = false
local CastedR = false
local TickR = false

local Item_HK = {}

local WasInRange = false

local ForceTarget = nil
local Rtarget = nil

local QBuff = nil
local WBuff = nil
local EBuff = nil
local RBuff = nil

local AARange = 0
local QRange = 1400
local ActiveQRange = 750
local QMaxRange = 1400
local QStarted = Game.Timer()
local RStarted = Game.Timer()
local WRange = 1000
local ERange = 1050
local RRange = 5000
local Q2Range = 700

local QCastType = "Manual"

local RStacks = 0
local MaxRStacks = 0

local CameraMoving = false

local Mounted = true

local EnemiesAroundHero = 0

local EnemiesRInfo = {}


function Xerath:Menu()
    self.Menu = MenuElement({type = MENU, id = "Xerath", name = "Xerath"})
    self.Menu:MenuElement({id = "UseRStackKey", name = "Fire A Single R Stack", key = string.byte("T"), value = false})
    self.Menu:MenuElement({id = "k4k", name = "4k Screen?", value = false})
    self.Menu:MenuElement({id = "ComboMode", name = "Combo", type = MENU})
    self.Menu.ComboMode:MenuElement({id = "UseQ", name = "(Q) Use Q", value = true})
    self.Menu.ComboMode:MenuElement({id = "UseQHitChance", name = "(Q) Hit Chance", value = 0, min = 0, max = 1.0, step = 0.05})
    self.Menu.ComboMode:MenuElement({id = "UseQHitChance2", name = "(Q) Hit Chance V2", value = 0, min = 0, max = 100, step = 5})
    self.Menu.ComboMode:MenuElement({id = "UseQExtraDistance", name = "(Q) Extra Distance Past Target", value = 30, min = 0, max = 200, step = 10})
    self.Menu.ComboMode:MenuElement({id = "UseW", name = "(W) Enabled", value = true})
    self.Menu.ComboMode:MenuElement({id = "UseWHitChance", name = "(W) Hit Chance", value = 0, min = 0, max = 1.0, step = 0.05})
    self.Menu.ComboMode:MenuElement({id = "UseE", name = "(E) Enabled", value = true})
    self.Menu.ComboMode:MenuElement({id = "UseEHitChance", name = "(E) Hit Chance", value = 0, min = 0, max = 1.0, step = 0.05})
    self.Menu.ComboMode:MenuElement({id = "UseEHitChance2", name = "(E) Hit Chance V2", value = 0, min = 0, max = 100, step = 5})
    self.Menu.ComboMode:MenuElement({id = "UseR", name = "(R) Enabled", value = true})
    self.Menu.ComboMode:MenuElement({id = "RSettings", name = "(R) Settings", type = MENU})
    self.Menu.ComboMode.RSettings:MenuElement({id = "UseRAutoStart", name = "(R) Auto Start", value = true})
    self.Menu.ComboMode.RSettings:MenuElement({id = "UseRAutoFire", name = "(R) Auto Fire Shots", value = true})
    self.Menu.ComboMode.RSettings:MenuElement({id = "UseRMiniMap", name = "(R) Minimap Targeting Enabled", value = true})
    self.Menu:MenuElement({id = "HarassMode", name = "Harass", type = MENU})
    self.Menu.HarassMode:MenuElement({id = "UseQ", name = "(Q) use Q", value = false})
    self.Menu.HarassMode:MenuElement({id = "UseW", name = "(W) Use W", value = false})
    self.Menu.HarassMode:MenuElement({id = "UseE", name = "(E) Use E", value = false})
    self.Menu.HarassMode:MenuElement({id = "UseR", name = "(R) Use R", value = false})
    self.Menu:MenuElement({id = "AutoMode", name = "Auto", type = MENU})
    self.Menu:MenuElement({id = "Draw", name = "Draw", type = MENU})
    self.Menu.Draw:MenuElement({id = "UseDraws", name = "Enable Draws", value = false})
    self.Menu.Draw:MenuElement({id = "DrawAA", name = "Draw AA range", value = false})
    self.Menu.Draw:MenuElement({id = "DrawQ", name = "Draw Q range", value = false})
    self.Menu.Draw:MenuElement({id = "DrawW", name = "Draw W range", value = false})
    self.Menu.Draw:MenuElement({id = "DrawE", name = "Draw E range", value = false})
    self.Menu.Draw:MenuElement({id = "DrawR", name = "Draw R range", value = false})
    self.Menu.Draw:MenuElement({id = "DrawRInfo", name = "Display Enemy Health Info", value = false})
    self.Menu.Draw:MenuElement({id = "RInfoX", name = "RInfo X Position", value = 1800, min = 0, max = 5000, step = 10})
    self.Menu.Draw:MenuElement({id = "RInfoY", name = "RInfo Y Position", value = 300, min = 0, max = 3000, step = 10})
    self.Menu.Draw:MenuElement({id = "RInfoSize", name = "RInfo Text Size", value = 10, min = 0, max = 50, step = 1})
    self.Menu.Draw:MenuElement({id = "DrawCustom", name = "Draw A Custom Range Circle", value = false})
    self.Menu.Draw:MenuElement({id = "DrawCustomRange", name = "Custom Range Circle", value = 500, min = 0, max = 2000, step = 10})
end

function Xerath:Spells()
    --ESpellData = {speed = math.huge, range = ERange, delay = 0, angle = 50, radius = 0, collision = {}, type = "conic"}

    QSpellData = {speed = math.huge, range = 1400, delay = 0.25, radius = 100, collision = {}, type = "linear"}
    WSpellData = {speed = math.huge, range = 1000, delay = 0.75, radius = 105, collision = {}, type = "circular"}
    ESpellData = {speed = 1400, range = 1050, delay = 0.25, radius = 60, collision = {"minion"}, type = "linear"}
    RSpellData = {speed = math.huge, range = 5000, delay = 0.627, radius = 70, collision = {}, type = "circular"}

end


function Xerath:Draw()
    if self.Menu.Draw.UseDraws:Value() then
        local AARange = _G.SDK.Data:GetAutoAttackRange(myHero)
        if self.Menu.Draw.DrawAA:Value() then
            Draw.Circle(myHero.pos, AARange, 1, Draw.Color(255, 0, 191, 0))
        end
        if self.Menu.Draw.DrawQ:Value() then
            Draw.Circle(myHero.pos, QRange, 1, Draw.Color(255, 255, 0, 255))
        end
        if self.Menu.Draw.DrawW:Value() then
            Draw.Circle(myHero.pos, WRange, 1, Draw.Color(255, 0, 0, 255))
        end
        if self.Menu.Draw.DrawE:Value() then
            Draw.Circle(myHero.pos, ERange, 1, Draw.Color(255, 0, 0, 255))
        end
        if self.Menu.Draw.DrawR:Value() then
            Draw.Circle(myHero.pos, RRange, 1, Draw.Color(255, 255, 255, 255))
        end
        if self.Menu.Draw.DrawCustom:Value() then
            Draw.Circle(myHero.pos, self.Menu.Draw.DrawCustomRange:Value(), 1, Draw.Color(255, 0, 191, 0))
        end
        if #EnemiesRInfo > 0 and self.Menu.Draw.DrawRInfo:Value() then
            for i = 1, #EnemiesRInfo do
                local TextSize = self.Menu.Draw.RInfoSize:Value()
                local YLevel = self.Menu.Draw.RInfoY:Value() + ((TextSize*5)*i)
                local Xlevel = self.Menu.Draw.RInfoX:Value()
                if EnemiesRInfo[i].MaxKillable then
                    Draw.Text(EnemiesRInfo[i].Name, TextSize, Xlevel, YLevel, Draw.Color(255, 0, 255, 0))
                    Draw.Text(math.floor(EnemiesRInfo[i].CurrentHealth), TextSize, Xlevel, YLevel+(TextSize*1.5), Draw.Color(255, 255, 255, 255))
                    Draw.Text("____", TextSize, Xlevel, YLevel+(TextSize*1.6), Draw.Color(255, 0, 0, 0))
                    Draw.Text(math.floor(EnemiesRInfo[i].MaxHealth), TextSize, Xlevel, YLevel+(TextSize*2.5), Draw.Color(255, 255, 255, 255))

                    Draw.Text(EnemiesRInfo[i].MaxRDamage, TextSize, Xlevel+(TextSize*2.6), YLevel+(TextSize*1.5), Draw.Color(255, 0, 255, 0))
                    Draw.Text("____", TextSize, Xlevel+(TextSize*2.6), YLevel+(TextSize*1.6), Draw.Color(255, 0, 0, 0))
                    Draw.Text("R Dmg", TextSize, Xlevel+(TextSize*2.6), YLevel+(TextSize*2.5), Draw.Color(255, 0, 255, 0))
                else
                    Draw.Text(EnemiesRInfo[i].Name, TextSize, Xlevel, YLevel, Draw.Color(255, 255, 0, 0))
                    Draw.Text(math.floor(EnemiesRInfo[i].CurrentHealth), TextSize, Xlevel, YLevel+(TextSize*1.5), Draw.Color(255, 255, 255, 255))
                    Draw.Text("____", TextSize, Xlevel, YLevel+(TextSize*1.6), Draw.Color(255, 0, 0, 0))
                    Draw.Text(math.floor(EnemiesRInfo[i].MaxHealth), TextSize, Xlevel, YLevel+(TextSize*2.5), Draw.Color(255, 255, 255, 255))

                    Draw.Text(EnemiesRInfo[i].MaxRDamage, TextSize, Xlevel+(TextSize*2.6), YLevel+(TextSize*1.5), Draw.Color(255, 0, 0, 255))
                    Draw.Text("____", TextSize, Xlevel+(TextSize*2.6), YLevel+(TextSize*1.6), Draw.Color(255, 0, 0, 0))
                    Draw.Text("R Dmg", TextSize, Xlevel+(TextSize*2.6), YLevel+(TextSize*2.5), Draw.Color(255, 0, 0, 255))
                end
            end
        end
        --InfoBarSprite = Sprite("SeriesSprites\\InfoBar.png", 1)
        --if self.Menu.ComboMode.UseEAA:Value() then
            --Draw.Text("Sticky E On", 10, myHero.pos:To2D().x+5, myHero.pos:To2D().y-130, Draw.Color(255, 0, 255, 0))
            --InfoBarSprite:Draw(myHero.pos:To2D().x,myHero.pos:To2D().y)
        --else
            --Draw.Text("Sticky E Off", 10, myHero.pos:To2D().x+5, myHero.pos:To2D().y-130, Draw.Color(255, 255, 0, 0))
            --InfoBarSprite:Draw(myHero.pos:To2D().x,myHero.pos:To2D().y)
        --end
    end
end



function Xerath:Tick()
    if _G.JustEvade and _G.JustEvade:Evading() or (_G.ExtLibEvade and _G.ExtLibEvade.Evading) or Game.IsChatOpen() or myHero.dead then return end
    target = GetTarget(5000)
    AARange = _G.SDK.Data:GetAutoAttackRange(myHero)
    if target then
        --PrintChat(target.pos:To2D())
        --PrintChat(mousePos:To2D())
    end
    --PrintChat(myHero.activeSpell.range)
    --PrintChat(myHero.activeSpell.speed)
    self:ProcessSpells()
    self:UpdateItems()
    self:Auto()
    self:CameraController()
    self:Logic()
    self:Items2()

    if TickQ then

        TickQ= false
    end
    if TickW then

        TickW = false
    end
    if TickE then

        TickE = false
    end
    if TickR then

        TickR = false
    end
    if EnemyLoaded == false then
        local CountEnemy = 0
        for i, enemy in pairs(EnemyHeroes) do
            CountEnemy = CountEnemy + 1
        end
        if CountEnemy < 1 then
            GetEnemyHeroes()
        else
            EnemyLoaded = true
            PrintChat("Enemy Loaded")
        end
    end
end


function Xerath:UpdateItems()
    Item_HK[ITEM_1] = HK_ITEM_1
    Item_HK[ITEM_2] = HK_ITEM_2
    Item_HK[ITEM_3] = HK_ITEM_3
    Item_HK[ITEM_4] = HK_ITEM_4
    Item_HK[ITEM_5] = HK_ITEM_5
    Item_HK[ITEM_6] = HK_ITEM_6
    Item_HK[ITEM_7] = HK_ITEM_7
end

function Xerath:Items1()
    if GetItemSlot(myHero, 3074) > 0 and ValidTarget(target, 300) then --rave 
        if myHero:GetSpellData(GetItemSlot(myHero, 3074)).currentCd == 0 then
            Control.CastSpell(Item_HK[GetItemSlot(myHero, 3074)])
        end
    end
    if GetItemSlot(myHero, 3077) > 0 and ValidTarget(target, 300) then --tiamat
        if myHero:GetSpellData(GetItemSlot(myHero, 3077)).currentCd == 0 then
            Control.CastSpell(Item_HK[GetItemSlot(myHero, 3077)])
        end
    end
    if GetItemSlot(myHero, 3144) > 0 and ValidTarget(target, 550) then --bilge
        if myHero:GetSpellData(GetItemSlot(myHero, 3144)).currentCd == 0 then
            Control.CastSpell(Item_HK[GetItemSlot(myHero, 3144)], target)
        end
    end
    if GetItemSlot(myHero, 3153) > 0 and ValidTarget(target, 550) then -- botrk
        if myHero:GetSpellData(GetItemSlot(myHero, 3153)).currentCd == 0 then
            Control.CastSpell(Item_HK[GetItemSlot(myHero, 3153)], target)
        end
    end
    if GetItemSlot(myHero, 3146) > 0 and ValidTarget(target, 700) then --gunblade hex
        if myHero:GetSpellData(GetItemSlot(myHero, 3146)).currentCd == 0 then
            Control.CastSpell(Item_HK[GetItemSlot(myHero, 3146)], target)
        end
    end
    if GetItemSlot(myHero, 3748) > 0 and ValidTarget(target, 300) then -- Titanic Hydra
        if myHero:GetSpellData(GetItemSlot(myHero, 3748)).currentCd == 0 then
            Control.CastSpell(Item_HK[GetItemSlot(myHero, 3748)])
        end
    end
end

function Xerath:Items2()
    if GetItemSlot(myHero, 3139) > 0 then
        if myHero:GetSpellData(GetItemSlot(myHero, 3139)).currentCd == 0 then
            if IsImmobile(myHero) then
                Control.CastSpell(Item_HK[GetItemSlot(myHero, 3139)], myHero)
            end
        end
    end
    if GetItemSlot(myHero, 3140) > 0 then
        if myHero:GetSpellData(GetItemSlot(myHero, 3140)).currentCd == 0 then
            if IsImmobile(myHero) then
                Control.CastSpell(Item_HK[GetItemSlot(myHero, 3140)], myHero)
            end
        end
    end
end

function Xerath:GetPassiveBuffs(unit, buffname)
    for i = 0, unit.buffCount do
        local buff = unit:GetBuff(i)
        if buff.name == buffname and buff.count > 0 then 
            return buff
        end
    end
    return nil
end


function Xerath:Auto()
    local LowestHPTarget = nil
    local StrongestKillableTarget = nil
    local ClosestKillableTarget = nil
    EnemiesAroundHero = 0
    local EnemiesRInfoTemp = {}
    for i, enemy in pairs(EnemyHeroes) do
        if enemy then
            local DamageLists = self:GetDamage(enemy)
            table.insert(EnemiesRInfoTemp, i, {Name = enemy.charName, MaxHealth = enemy.maxHealth, CurrentHealth = enemy.health, Killable = DamageLists.Rkills, MaxKillable = DamageLists.RMaxKills, RDamage = DamageLists.RDamage, MaxRDamage = DamageLists.MaxRDamage})
        end
        if enemy and not enemy.dead and ValidTarget(enemy) then
            if GetDistance(enemy.pos, myHero.pos) < 1200 then
                EnemiesAroundHero = EnemiesAroundHero + 1
            end
            if GetDistance(enemy.pos, myHero.pos) < RRange then

                if LowestHPTarget == nil or enemy.health < LowestHPTarget.health then
                    LowestHPTarget = enemy
                end
                local DamageLists = self:GetDamage(enemy)
                if DamageLists.Rkills then
                    local enemyDamageValue = enemy.ap + enemy.totalDamage
                    if StrongestKillableTarget == nil or enemyDamageValue > (StrongestKillableTarget.ap + StrongestKillableTarget.totalDamage) then
                        StrongestKillableTarget = enemy
                    end
                    if ClosestKillableTarget == nil or GetDistance(enemy.pos, myHero.pos) < GetDistance(ClosestKillableTarget.pos, myHero.pos) then
                        ClosestKillableTarget = enemy
                    end
                end
            end
        end
    end
    EnemiesRInfo = EnemiesRInfoTemp
    local DamageListsTarget = nil
    if target then
        DamageListsTarget = self:GetDamage(target)
    end
    if target and ValidTarget(target, RRange) and DamageListsTarget.Rkills then
        Rtarget = target
    elseif ClosestKillableTarget ~= nil and GetDistance(ClosestKillableTarget.pos, myHero.pos) < QMaxRange then
        Rtarget = ClosestKillableTarget
    elseif StrongestKillableTarget ~= nil then
        Rtarget = StrongestKillableTarget
    elseif LowestHPTarget ~= nil and not target then
        Rtarget = LowestHPTarget
    elseif target and ValidTarget(target, RRange) then
        Rtarget = target
    end

end 

function Xerath:CanUse(spell, mode)
    if mode == nil then
        mode = Mode()
    end
    --PrintChat(Mode())
    if spell == _Q then
        if mode == "Combo" and IsReady(spell) and self.Menu.ComboMode.UseQ:Value() then
            return true
        end
        if mode == "Harass" and IsReady(spell) and self.Menu.HarassMode.UseQ:Value() then
            return true
        end
        if mode == "Auto" and IsReady(spell) and self.Menu.AutoMode.UseQ:Value() then
            return true
        end
        if mode == "Force" and IsReady(spell) then
            return true
        end
    elseif spell == _W then
        if mode == "Combo" and IsReady(spell) and self.Menu.ComboMode.UseW:Value() then
            return true
        end
        if mode == "Harass" and IsReady(spell) and self.Menu.HarassMode.UseW:Value() then
            return true
        end
        if mode == "Force" and IsReady(spell) then
            return true
        end
    elseif spell == _E then
        if mode == "Combo" and IsReady(spell) and self.Menu.ComboMode.UseE:Value() then
            return true
        end
        if mode == "Harass" and IsReady(spell) and self.Menu.HarassMode.UseE:Value() then
            return true
        end
        if mode == "Force" and IsReady(spell) then
            return true
        end
    elseif spell == _R then
        if mode == "Combo" and IsReady(spell) and self.Menu.ComboMode.UseR:Value() then
            return true
        end
        if mode == "Harass" and IsReady(spell) and self.Menu.HarassMode.UseR:Value() then
            return true
        end
        if mode == "Force" and IsReady(spell) then
            return true
        end
    end
    return false
end

function Xerath:Logic()
    if target == nil then 
        if Game.Timer() - TargetTime > 2 then
            WasInRange = false
        end
        return 
    end

    if self:CanUse(_R, "Force") and self.Menu.UseRStackKey:Value() and Rtarget and ValidTarget(Rtarget, RRange) and self:CastingChecksR() and not (myHero.pathing and myHero.pathing.isDashing) and not _G.SDK.Attack:IsActive() then
        if CastingR == true and Game.Timer() - RStarted > 0.1 then
            if target.pos:ToScreen().onScreen then
                self:UseR(Rtarget)
            elseif self.Menu.ComboMode.RSettings.UseRMiniMap:Value() == true then
                self:UseRMap(Rtarget)
            end
        end
    end


    if Mode() == "Combo" or Mode() == "Harass" then
        if Rtarget then
            if self:CanUse(_R, Mode()) and ValidTarget(Rtarget, RRange) and self:CastingChecksR() and not (myHero.pathing and myHero.pathing.isDashing) and not _G.SDK.Attack:IsActive() then
                if CastingR == false then
                    local DamageLists = self:GetDamage(Rtarget)
                    --PrintChat(DamageLists.Rkills)
                    if DamageLists.Rkills and self.Menu.ComboMode.RSettings.UseRAutoStart:Value() and EnemiesAroundHero == 0 then
                        self:StartR(Rtarget)
                    end
                else
                    if Game.Timer() - RStarted > 0.1 and self.Menu.ComboMode.RSettings.UseRAutoFire:Value() then
                        --PrintChat("Using R")
                        if target.pos:ToScreen().onScreen then
                            self:UseR(Rtarget)
                        elseif self.Menu.ComboMode.RSettings.UseRMiniMap:Value() == true then
                            self:UseRMap(Rtarget)
                        end
                    end
                end
            end
        end
        if target then
            --PrintChat("Logic")
            TargetTime = Game.Timer()
            self:Items1()
            
            if GetDistance(target.pos) < AARange then
                WasInRange = true
            end

            if self:CanUse(_E, Mode()) and ValidTarget(target, ERange) and self:CastingChecks() and not (myHero.pathing and myHero.pathing.isDashing) and not _G.SDK.Attack:IsActive() then
                self:UseE(target)
            end

            if self:CanUse(_W, Mode()) and ValidTarget(target, WRange) and self:CastingChecks() and not (myHero.pathing and myHero.pathing.isDashing) and not _G.SDK.Attack:IsActive() then
                if LastSpellCasted == "E" or not self:CanUse(_Q, Mode()) then
                    self:UseW(target)
                end
            end

            if (self:CanUse(_Q, Mode()) or CastingQ == true) and ValidTarget(target, QRange) and self:CastingChecksQ() and not (myHero.pathing and myHero.pathing.isDashing) and not _G.SDK.Attack:IsActive() then
                if CastingQ == false then
                    --PrintChat("Starting Q")
                    self:StartQ(target)
                else
                    if Game.Timer() - QStarted > 0.1 then
                        --PrintChat("Using Q")
                        self:UseQ(target)
                    end
                end
            end
        end
    end     
end

function Xerath:GetDamage(unit)
    local Qdmg = getdmg("Q", unit, myHero)
    local Edmg = getdmg("E", unit, myHero)
    local Wdmg = getdmg("W", unit, myHero)
    local Rdmg = getdmg("R", unit, myHero)
    local AAdmg = getdmg("AA", unit, myHero)

    local UnitHealth = unit.health + unit.shieldAD

    local RCheck = (Rdmg * RStacks) > UnitHealth

    local RMaxCheck = (Rdmg * MaxRStacks) > UnitHealth

    local RMaxDmg = Rdmg * MaxRStacks

    local DamageArray = {EnemyHealth = UnitHealth, RDamage = Rdmg, QDamage = Qdmg, EDamage = Edmg, WDamage = Wdmg, AADamage = AAdmg, Rkills = RCheck, RMaxKills = RMaxCheck, MaxRDamage = RMaxDmg}
    return DamageArray

end


function Xerath:CameraController()
    if myHero.activeSpell.name == "XerathLocusOfPower2" then
        if Rtarget and ValidTarget(Rtarget) then
            if self.Menu.ComboMode.RSettings.UseRMiniMap:Value() == false then
                self:MoveCamera2(Rtarget)
            end
        end

    end
end

function Xerath:ProcessSpells()


    if Game.Timer() - QStarted > 0.15 and not CastingQ and QCastType == "Script" then
        if Control.IsKeyDown(HK_Q) then
            Control.KeyUp(HK_Q)
            QCastType = "Manual"
        end
    end


    CastingQ = myHero.activeSpell.name == "XerathArcanopulseChargeUp" or Game.Timer() - QStarted < 0.1 
    CastingW = myHero.activeSpell.name == "XerathArcaneBarrage2"
    CastingE = myHero.activeSpell.name == "XerathMageSpear"
    CastingR = myHero.activeSpell.name == "XerathLocusOfPower2" or Game.Timer() - RStarted < 0.1 

    QBuff = GetBuffStart(myHero, "XerathArcanopulseChargeUp")

    --PrintChat(CastingQ)

    MaxRStacks = 2+myHero:GetSpellData(_R).level
    if myHero:GetSpellData(_R).currentCd == 0 and myHero.activeSpell.name ~= "XerathLocusOfPower2" and Game.CanUseSpell(_R) == 0 then
        RStacks = MaxRStacks
    end

    

    if CastingQ and QBuff ~= nil then
        --QBuff = GetBuffStart(myHero, "XerathArcanopulseChargeUp")
        if ActiveQRange < 1400 then
            ActiveQRange = 750 + (65 * ((Game.Timer() - QBuff)/0.15))
        else
            ActiveQRange = 1400
        end
        --PrintChat(ActiveQRange)
    else
        ActiveQRange = 750
    end
    --PrintChat(CastingR)

    if CastingQ or CastingR then
        _G.SDK.Orbwalker:SetAttack(false)
    else
        _G.SDK.Orbwalker:SetAttack(true)
    end

    if myHero:GetSpellData(_Q).currentCd == 0 then
        CastedQ = false
    else
        if CastedQ == false then
            --GotBall = "ECast"
            TickQ = true
            if Control.IsKeyDown(HK_Q) then
                Control.KeyUp(HK_Q)
            end
            QCastType = "Manual"
            LastSpellCasted = "Q"
        end
        CastedQ = true
    end
    if myHero:GetSpellData(_W).currentCd == 0 then
        CastedW = false
    else
        if CastedW == false then
            --GotBall = "ECast"
            TickW = true
            LastSpellCasted = "W"
        end
        CastedW = true
    end
    if myHero:GetSpellData(_E).currentCd == 0 then
        CastedE = false
    else
        if CastedE == false then
            --GotBall = "ECast"
            TickE = true
            LastSpellCasted = "E"
        end
        CastedE = true
    end
    if myHero:GetSpellData(_R).currentCd == 0 then
        CastedR = false
    else
        if CastedR == false then
            --GotBall = "ECast"
            TickR = true
            if LastSpellCasted == "R" and Game.Timer() - RStarted < 5 then
                --PrintChat("Tick R")
                RStacks = RStacks - 1

            end
            RStarted = Game.Timer()
            LastSpellCasted = "R"
        end
        CastedR = true
    end
end

function Xerath:CastingChecks()
    if not CastingQ and not CastingW and not CastingE and not CastingR then
        return true
    else
        return false
    end
end

function Xerath:CastingChecksR()
    if not CastingW and not CastingE and not CastingQ then
        return true
    else
        return false
    end
end


function Xerath:CastingChecksQ()
    if not CastingW and not CastingE and not CastingR then
        return true
    else
        return false
    end
end

function Xerath:OnPostAttack(args)

end

function Xerath:OnPostAttackTick(args)
end

function Xerath:OnPreAttack(args)
end

function Xerath:StartQ(unit)
    local pred = _G.PremiumPrediction:GetPrediction(myHero, unit, QSpellData)
    if pred.CastPos and pred.HitChance > self.Menu.ComboMode.UseQHitChance:Value() and myHero.pos:DistanceTo(pred.CastPos) < QMaxRange then
        --Control.CastSpell(HK_Q, pred.CastPos)
        QStarted = Game.Timer()
        Control.KeyDown(HK_Q)
        QCastType = "Script"
    end 
end

function Xerath:UseQ(unit)
    local pred = _G.PremiumPrediction:GetPrediction(myHero, unit, QSpellData)
    local ExtraQDistance = self.Menu.ComboMode.UseQExtraDistance:Value()
    if myHero.pos:DistanceTo(pred.CastPos) + self.Menu.ComboMode.UseQExtraDistance:Value() > QMaxRange then
        ExtraQDistance = 0
    end

    if pred.CastPos and pred.HitChance > self.Menu.ComboMode.UseQHitChance:Value() and myHero.pos:DistanceTo(pred.CastPos) + ExtraQDistance < ActiveQRange then
        local StartPos = myHero.pos
        local CastPos = pred.CastPos

        local CastDirection = Vector((StartPos-unit.pos):Normalized())
        local PlacementPos2 = myHero.pos - CastDirection * QMaxRange

        local EndPos = PlacementPos2
        local ConeWidth = 101 - self.Menu.ComboMode.UseQHitChance2:Value()
        if _G.PremiumPrediction:IsPointInArc(StartPos, CastPos, EndPos, QMaxRange, ConeWidth) then
            --PrintChat("In DA CONE!")
            Control.CastSpell(HK_Q, pred.CastPos)
        end
    end 
end

function Xerath:UseW(unit)
    local pred = _G.PremiumPrediction:GetPrediction(myHero, unit, WSpellData)
    if pred.CastPos and pred.HitChance > self.Menu.ComboMode.UseWHitChance:Value() and myHero.pos:DistanceTo(pred.CastPos) < WRange then
        --PrintChat("Casting W")
        Control.CastSpell(HK_W, pred.CastPos)
    end 
end

function Xerath:UseE(unit)
    local pred = _G.PremiumPrediction:GetPrediction(myHero, unit, ESpellData)
    if pred.CastPos and pred.HitChance > self.Menu.ComboMode.UseEHitChance:Value() and myHero.pos:DistanceTo(pred.CastPos) < ERange then
        local StartPos = myHero.pos
        local CastPos = pred.CastPos

        local CastDirection = Vector((StartPos-unit.pos):Normalized())
        local PlacementPos2 = myHero.pos - CastDirection * ERange

        local EndPos = PlacementPos2
        local ConeWidth = 101 - self.Menu.ComboMode.UseEHitChance2:Value()
        if _G.PremiumPrediction:IsPointInArc(StartPos, CastPos, EndPos, ERange, ConeWidth) then
            --PrintChat("In DA CONE!")
            Control.CastSpell(HK_E, pred.CastPos)
        end
                --PrintChat("Woulda Cast")

    end 
end

function Xerath:StartR(unit)
    local pred = _G.PremiumPrediction:GetPrediction(myHero, unit, RSpellData)
    if pred.CastPos and myHero.pos:DistanceTo(pred.CastPos) < RRange then
        Control.CastSpell(HK_R)
    end 
end

function Xerath:UseR(unit)
    local pred = _G.PremiumPrediction:GetPrediction(myHero, unit, RSpellData)
    if pred.CastPos and myHero.pos:DistanceTo(pred.CastPos) < RRange then
        --PrintChat("Casting R")
        Control.CastSpell(HK_R, pred.CastPos)
    end 
end

function Xerath:UseRMap(unit)
    local pred = _G.PremiumPrediction:GetPrediction(myHero, unit, RSpellData)
    if pred.CastPos and myHero.pos:DistanceTo(pred.CastPos) < RRange then
        local MMSpot = Vector(pred.CastPos):ToMM()
        local MouseSpotBefore = mousePos
        Control.SetCursorPos(MMSpot.x, MMSpot.y)
        Control.KeyDown(HK_R); Control.KeyUp(HK_R)
        DelayAction(function() Control.SetCursorPos(MouseSpotBefore) end, 0.20)
        --Control.SetCursorPos(MouseSpotBefore)
        --Control.CastSpell(HK_E, Spot)
    end
end


function Xerath:StopCamera(unit)
    TargetMousePos = unit.pos:To2D()
    CurrentMousePos = mousePos:To2D()
    FinalMousePos = unit.pos:To2D()

    if GetDistance(CurrentMousePos, TargetMousePos) < 10 then
        Control.SetCursorPos(TargetMousePos.x, TargetMousePos.y)
        CameraMoving = false
    else
        Control.SetCursorPos(TargetMousePos.x, TargetMousePos.y)
    end
    
end




function Xerath:MoveCamera2(unit)
    --PrintChat("Moving Camera")
    --PrintChat(CastingR)
    --local MMSpot = Vector(unit.pos):ToMM()
    --Control.LeftClick(MMSpot.x, MMSpot.y)
    if unit.pos:ToScreen().onScreen then
        TargetOnScreen = true
    else
        TargetOnScreen = false
        TargetCentered = false
    end
    if TargetCentered == false then
        TargetMousePos = unit.pos:To2D()
        CurrentMousePos = mousePos:To2D()
        FinalMousePos = unit.pos:To2D()
        local CenterX = 960
        local CenterY = 590
        local EndX = 1910
        local StartX = 10
        local EndY = 1070
        local StartY = 10
        if self.Menu.k4k:Value() then
            CenterX = 1280
            CenterY = 720
            EndX = 2560
            EndY = 1440
        end
        local CenterPos = {x = 960, y = 590}
        local Xtracked = false
        local Ytracked = false
        local DistanceX = TargetMousePos.x - CenterX
        local DistanceY = TargetMousePos.y - CenterY
        --PrintChat(TargetMousePos)
        --PrintChat(CurrentMousePos)

        if TargetMousePos.x - CenterX < -300 then
            FinalMousePos.x = 10
        elseif TargetMousePos.x - CenterX > 300 then
            FinalMousePos.x = EndX
        else
            FinalMousePos.x = TargetMousePos.x
            Xtracked = true
        end

        if TargetMousePos.y - CenterY < -300 then
            FinalMousePos.y = 10
        elseif TargetMousePos.y - CenterY > 300 then
            FinalMousePos.y = EndY
        else
            FinalMousePos.y = TargetMousePos.y
            Ytracked = true
        end
        if Ytracked == false or Xtracked == false then
            Control.SetCursorPos(FinalMousePos.x, FinalMousePos.y)
            CameraMoving = true
        else
            if GetDifference(CurrentMousePos.x, CenterX) > 900 or GetDifference(CurrentMousePos.y, CenterY) > 530 then
                Control.SetCursorPos(TargetMousePos.x, TargetMousePos.y)
                CameraMoving = true
            else
                TargetCentered = true
                CameraMoving = false
            end
        end
    end
    --Control.KeyDown(HK_E); Control.KeyUp(HK_E)
    --DelayAction(function() Control.SetCursorPos(MouseSpotBefore) end, 0.20)
end

function Xerath:MoveCamera(unit)
    --PrintChat("Moving Camera")
    --PrintChat(CastingR)
    --local MMSpot = Vector(unit.pos):ToMM()
    --Control.LeftClick(MMSpot.x, MMSpot.y)
    TargetMousePos = unit.pos:To2D()
    CurrentMousePos = mousePos:To2D()
    FinalMousePos = unit.pos:To2D()
    CenterX = 960
    CenterY = 590
    --PrintChat(TargetMousePos)
    --PrintChat(CurrentMousePos)
    if TargetMousePos.x < 600 then
        FinalMousePos.x = 10
    elseif TargetMousePos.x > 1310 then
        FinalMousePos.x = 1910
    else
        FinalMousePos.x = TargetMousePos.x
        --PrintChat("Locked X")
    end

    if TargetMousePos.y < 200 then
        FinalMousePos.y = 10
    elseif TargetMousePos.y > 900 then
        FinalMousePos.y = 1070
    else
        FinalMousePos.y = TargetMousePos.y
        --PrintChat("Locked Y")
    end

    Control.SetCursorPos(FinalMousePos.x, FinalMousePos.y)
    CameraMoving = true
    --Control.KeyDown(HK_E); Control.KeyUp(HK_E)
    --DelayAction(function() Control.SetCursorPos(MouseSpotBefore) end, 0.20)
end

class "Vayne"

local EnemyLoaded = false
local TargetTime = 0

local CastingQ = false
local CastingW = false
local CastingE = false
local CastingR = false

local CastedQ = false
local TickQ = false
local CastedW = false
local TickE = false
local CastedE = false
local TickE = false
local CastedR = false
local TickR = false

local Item_HK = {}

local WasInRange = false

local ForceTarget = nil
local Rtarget = nil

local QBuff = nil
local WBuff = nil
local EBuff = nil
local RBuff = nil

local AARange = 0
local EAARange = 0
local QRange = 1400

local ActiveQRange = 750
local QMaxRange = 1400

local QStarted = Game.Timer()
local RStarted = Game.Timer()

local Flash = nil
local FlashSpell = nil

local WStacks = 0
local HadStun = false
local StunTime = Game.Timer()
local UseBuffs = false
local ReturnMouse = mousePos

local Kraken = false
local KrakenStacks = 0
local RActive = false

local PrimedFlashE = nil
local PrimedFlashETime = Game.Timer()

local Flash = nil
local FlashSpell = nil


local SilverBuff = 0
local UsedSilverBuff
local PredSilverBuff = 0

local WRange = 1000
local ERange = 550
local RRange = 5000
local QRange = 300

local QMouseSpot = nil

local WasAttacking = false

local CameraMoving = false

local Mounted = true


function Vayne:Menu()
    self.Menu = MenuElement({type = MENU, id = "Vayne", name = "Vayne"})
    self.Menu:MenuElement({id = "UseEFlashKey", name = "(E-Flash) To Stun the Target", key = string.byte("T"), value = false})
    self.Menu:MenuElement({id = "UseEFlashInfo", name = "E-Flash To A Spot To Stun Target", type = SPACE})
    self.Menu:MenuElement({id = "UseEProcKey", name = "(E) Proc Next Silver Bolts", key = string.byte("E"), value = false})
    self.Menu:MenuElement({id = "UseEProcInfo", name = "Chamber An E to proc Silver Bolts", type = SPACE})
    self.Menu:MenuElement({id = "ComboMode", name = "Combo", type = MENU})
    self.Menu.ComboMode:MenuElement({id = "UseQDodge", name = "(Q) To Dodge Targets Spells", value = false})
    self.Menu.ComboMode:MenuElement({id = "UseQDodgeCalc", name = "(Q)Sometimes Dodge Away From mouse", value = true})
    self.Menu.ComboMode:MenuElement({id = "UseQDodgeChamps", name = "Enemies Spells To Dodge", type = MENU})
    self.Menu.ComboMode:MenuElement({id = "ComboModeQ", name = "Q Settings Against Melee (R Not Active)", type = MENU})
    self.Menu.ComboMode.ComboModeQ:MenuElement({id = "UseQStun", name = "(Q) To Position For Stuns", value = true})
    self.Menu.ComboMode.ComboModeQ:MenuElement({id = "UseQStunInfo", name = "Use Q to Roll Into Spots That Will Stun Target", type = SPACE})
    self.Menu.ComboMode.ComboModeQ:MenuElement({id = "UseQPush", name = "(Q) To Move Away", value = true})
    self.Menu.ComboMode.ComboModeQ:MenuElement({id = "UseQPushInfo", name = "Use Q to Keep A Safe Distance", type = SPACE})
    self.Menu.ComboMode.ComboModeQ:MenuElement({id = "UseQPull", name = "(Q) To Get Closer", value = true})
    self.Menu.ComboMode.ComboModeQ:MenuElement({id = "UseQPullInfo", name = "Use Q to Get Into Attack Range", type = SPACE})
    self.Menu.ComboMode.ComboModeQ:MenuElement({id = "UseQProc", name = "(Q) To Proc 3rd Silver Bolt", value = false})
    self.Menu.ComboMode.ComboModeQ:MenuElement({id = "UseQProcInfo", name = "Always Use Q To Proc Silver Bolt", type = SPACE})
    self.Menu.ComboMode.ComboModeQ:MenuElement({id = "UseQDPS", name = "(Q) For DPS", value = false})
    self.Menu.ComboMode.ComboModeQ:MenuElement({id = "UseQDPSInfo", name = "Always Use Q to reset AA", type = SPACE})
    self.Menu.ComboMode.ComboModeQ:MenuElement({id = "UseQFinish", name = "(Q) To Finish Kills", value = true})
    self.Menu.ComboMode.ComboModeQ:MenuElement({id = "UseQFinishInfo", name = "Use Q Empowered AA to finish kills", type = SPACE})
    self.Menu.ComboMode:MenuElement({id = "ComboModeQR", name = "Q Settings Against Melee (R Active)", type = MENU})
    self.Menu.ComboMode.ComboModeQR:MenuElement({id = "UseQStun", name = "(Q) To Position For Stuns", value = true})
    self.Menu.ComboMode.ComboModeQR:MenuElement({id = "UseQStunInfo", name = "Use Q to Roll Into Spots That Will Stun Target", type = SPACE})
    self.Menu.ComboMode.ComboModeQR:MenuElement({id = "UseQPush", name = "(Q) To Move Away", value = true})
    self.Menu.ComboMode.ComboModeQR:MenuElement({id = "UseQPushInfo", name = "Use Q to Keep A Safe Distance", type = SPACE})
    self.Menu.ComboMode.ComboModeQR:MenuElement({id = "UseQPull", name = "(Q) To Get Closer", value = true})
    self.Menu.ComboMode.ComboModeQR:MenuElement({id = "UseQPullInfo", name = "Use Q to Get Into Attack Range", type = SPACE})
    self.Menu.ComboMode.ComboModeQR:MenuElement({id = "UseQProc", name = "(Q) To Proc 3rd Silver Bolt", value = true})
    self.Menu.ComboMode.ComboModeQR:MenuElement({id = "UseQProcInfo", name = "Always Use Q To Proc Silver Bolt", type = SPACE})
    self.Menu.ComboMode.ComboModeQR:MenuElement({id = "UseQDPS", name = "(Q) For DPS", value = false})
    self.Menu.ComboMode.ComboModeQR:MenuElement({id = "UseQDPSInfo", name = "Always Use Q to reset AA", type = SPACE})
    self.Menu.ComboMode.ComboModeQR:MenuElement({id = "UseQFinish", name = "(Q) To Finish Kills", value = true})
    self.Menu.ComboMode.ComboModeQR:MenuElement({id = "UseQFinishInfo", name = "Use Q Empowered AA to finish kills", type = SPACE})
    self.Menu.ComboMode:MenuElement({id = "ComboModeQRanged", name = "Q Settings Against Ranged (R Not Active)", type = MENU})
    self.Menu.ComboMode.ComboModeQRanged:MenuElement({id = "UseQStun", name = "(Q) To Position For Stuns", value = true})
    self.Menu.ComboMode.ComboModeQRanged:MenuElement({id = "UseQStunInfo", name = "Use Q to Roll Into Spots That Will Stun Target", type = SPACE})
    self.Menu.ComboMode.ComboModeQRanged:MenuElement({id = "UseQPush", name = "(Q) To Move Away", value = false})
    self.Menu.ComboMode.ComboModeQRanged:MenuElement({id = "UseQPushInfo", name = "Use Q to Keep A Safe Distance", type = SPACE})
    self.Menu.ComboMode.ComboModeQRanged:MenuElement({id = "UseQPull", name = "(Q) To Get Closer", value = true})
    self.Menu.ComboMode.ComboModeQRanged:MenuElement({id = "UseQPullInfo", name = "Use Q to Get Into Attack Range", type = SPACE})
    self.Menu.ComboMode.ComboModeQRanged:MenuElement({id = "UseQProc", name = "(Q) To Proc 3rd Silver Bolt", value = true})
    self.Menu.ComboMode.ComboModeQRanged:MenuElement({id = "UseQProcInfo", name = "Always Use Q To Proc Silver Bolt", type = SPACE})
    self.Menu.ComboMode.ComboModeQRanged:MenuElement({id = "UseQDPS", name = "(Q) For DPS", value = false})
    self.Menu.ComboMode.ComboModeQRanged:MenuElement({id = "UseQDPSInfo", name = "Always Use Q to reset AA", type = SPACE})
    self.Menu.ComboMode.ComboModeQRanged:MenuElement({id = "UseQFinish", name = "(Q) To Finish Kills", value = true})
    self.Menu.ComboMode.ComboModeQRanged:MenuElement({id = "UseQFinishInfo", name = "Use Q Empowered AA to finish kills", type = SPACE})
    self.Menu.ComboMode:MenuElement({id = "ComboModeQRangedR", name = "Q Settings Against Ranged (R Active)", type = MENU})
    self.Menu.ComboMode.ComboModeQRangedR:MenuElement({id = "UseQStun", name = "(Q) To Position For Stuns", value = true})
    self.Menu.ComboMode.ComboModeQRangedR:MenuElement({id = "UseQStunInfo", name = "Use Q to Roll Into Spots That Will Stun Target", type = SPACE})
    self.Menu.ComboMode.ComboModeQRangedR:MenuElement({id = "UseQPush", name = "(Q) To Move Away", value = false})
    self.Menu.ComboMode.ComboModeQRangedR:MenuElement({id = "UseQPushInfo", name = "Use Q to Keep A Safe Distance", type = SPACE})
    self.Menu.ComboMode.ComboModeQRangedR:MenuElement({id = "UseQPull", name = "(Q) To Get Closer", value = true})
    self.Menu.ComboMode.ComboModeQRangedR:MenuElement({id = "UseQPullInfo", name = "Use Q to Get Into Attack Range", type = SPACE})
    self.Menu.ComboMode.ComboModeQRangedR:MenuElement({id = "UseQProc", name = "(Q) To Proc 3rd Silver Bolt", value = true})
    self.Menu.ComboMode.ComboModeQRangedR:MenuElement({id = "UseQProcInfo", name = "Always Use Q To Proc Silver Bolt", type = SPACE})
    self.Menu.ComboMode.ComboModeQRangedR:MenuElement({id = "UseQDPS", name = "(Q) For DPS", value = false})
    self.Menu.ComboMode.ComboModeQRangedR:MenuElement({id = "UseQDPSInfo", name = "Always Use Q to reset AA", type = SPACE})
    self.Menu.ComboMode.ComboModeQRangedR:MenuElement({id = "UseQFinish", name = "(Q) To Finish Kills", value = true})
    self.Menu.ComboMode.ComboModeQRangedR:MenuElement({id = "UseQFinishInfo", name = "Use Q Empowered AA to finish kills", type = SPACE})
    self.Menu.ComboMode:MenuElement({id = "UseQ", name = "(Q) Enable/Disable All Usage", value = true})
    self.Menu.ComboMode:MenuElement({id = "ComboModeE", name = "E Settings", type = MENU})
    self.Menu.ComboMode.ComboModeE:MenuElement({id = "UseEStun", name = "(E) To Stun The Target", value = true})
    self.Menu.ComboMode.ComboModeE:MenuElement({id = "UseEStunInfo", name = "Stun Your Target With E", type = SPACE})
    self.Menu.ComboMode.ComboModeE:MenuElement({id = "UseEFinish", name = "(E) Finish Kills", value = true})
    self.Menu.ComboMode.ComboModeE:MenuElement({id = "UseEFinishInfo", name = "Proc 3rd Silver Bolt with E To Finish Kills", type = SPACE})
    self.Menu.ComboMode.ComboModeE:MenuElement({id = "UseEPush", name = "(E) To Push Away Target", value = true})
    self.Menu.ComboMode.ComboModeE:MenuElement({id = "UseEPushInfo", name = "Push Away Target If Too Close", type = SPACE})
    self.Menu.ComboMode.ComboModeE:MenuElement({id = "UseEPushChamps", name = "Enemies To Push away", type = MENU})
    self.Menu.ComboMode:MenuElement({id = "UseE", name = "(E) Enable/Disable All Usage", value = true})
    self.Menu:MenuElement({id = "HarassMode", name = "Harass", type = MENU})
    self.Menu.HarassMode:MenuElement({id = "HarassModeQ", name = "Q Settings", type = MENU})
    self.Menu.HarassMode:MenuElement({id = "UseQ", name = "(Q) Enable/Disable All Usage", value = true})
    self.Menu.HarassMode.HarassModeQ:MenuElement({id = "UseQStun", name = "(Q) To Position For Stuns", value = true})
    self.Menu.HarassMode.HarassModeQ:MenuElement({id = "UseQStunInfo", name = "Use Q to Roll Into Spots That Will Stun Target", type = SPACE})
    self.Menu.HarassMode.HarassModeQ:MenuElement({id = "UseQPush", name = "(Q) To Move Away", value = true})
    self.Menu.HarassMode.HarassModeQ:MenuElement({id = "UseQPushInfo", name = "Use Q to Keep A Safe Distance", type = SPACE})
    self.Menu.HarassMode.HarassModeQ:MenuElement({id = "UseQPull", name = "(Q) To Get Closer", value = false})
    self.Menu.HarassMode.HarassModeQ:MenuElement({id = "UseQPullInfo", name = "Use Q to Get Into Attack Range", type = SPACE})
    self.Menu.HarassMode.HarassModeQ:MenuElement({id = "UseQProc", name = "(Q) To Proc 3rd Silver Bolt", value = true})
    self.Menu.HarassMode.HarassModeQ:MenuElement({id = "UseQProcInfo", name = "Always Use Q To Proc Silver Bolt", type = SPACE})
    self.Menu.HarassMode.HarassModeQ:MenuElement({id = "UseQPrepair", name = "(Q) To Apply Second Silver Bolt", value = true})
    self.Menu.HarassMode.HarassModeQ:MenuElement({id = "UseQPrepairInfo", name = "Use Q to Prepair for E-3rd Silver bolt", type = SPACE})
    self.Menu.HarassMode.HarassModeQ:MenuElement({id = "UseQDPS", name = "(Q) For DPS", value = false})
    self.Menu.HarassMode.HarassModeQ:MenuElement({id = "UseQDPSInfo", name = "Always Use Q When In Range", type = SPACE})
    self.Menu.HarassMode.HarassModeQ:MenuElement({id = "UseQFinish", name = "(Q) To Finish Kills", value = true})
    self.Menu.HarassMode.HarassModeQ:MenuElement({id = "UseQFinishInfo", name = "Use Q Empowered AA to finish kills", type = SPACE})
    self.Menu.HarassMode:MenuElement({id = "HarassModeE", name = "E Settings", type = MENU})
    self.Menu.HarassMode:MenuElement({id = "UseE", name = "(E) Enable/Disable All Usage", value = true})
    self.Menu.HarassMode.HarassModeE:MenuElement({id = "UseEStun", name = "(E) To Stun The Target", value = true})
    self.Menu.HarassMode.HarassModeE:MenuElement({id = "UseEStunInfo", name = "Stun Your Target With E", type = SPACE})
    self.Menu.HarassMode.HarassModeE:MenuElement({id = "UseEPush", name = "(E) To Push Away Target", value = true})
    self.Menu.HarassMode.HarassModeE:MenuElement({id = "UseEPushInfo", name = "Push Away Target If Too Close", type = SPACE})
    self.Menu.HarassMode.HarassModeE:MenuElement({id = "UseEProc", name = "(E) Proc 3rd Silver Bolt", value = true})
    self.Menu.HarassMode.HarassModeE:MenuElement({id = "UseEProcInfo", name = "Proc 3rd Silver Bolt with E Always", type = SPACE})
    self.Menu.HarassMode.HarassModeE:MenuElement({id = "UseEFinish", name = "(E) Finish Kills", value = true})
    self.Menu.HarassMode.HarassModeE:MenuElement({id = "UseEFinishInfo", name = "Proc 3rd Silver Bolt with E To Finish Kills", type = SPACE})
    self.Menu:MenuElement({id = "VayneOrbMode", name = "Orbwalker", type = MENU})
    self.Menu.VayneOrbMode:MenuElement({id = "UseRangedHelperWalk", name = "RangedHelper: Movement Assist", value = false})
    self.Menu.VayneOrbMode:MenuElement({id = "UseRangedHelperWalkInfo", name = "Assist Movement To Kite Enemies", type = SPACE})
    self.Menu.VayneOrbMode:MenuElement({id = "RangedHelperMouseDistance", name = "Mouse Range From Target", value = 550, min = 0, max = 1500, step = 50})
    self.Menu.VayneOrbMode:MenuElement({id = "RangedHelperMouseDistanceInfo", name = "Max Mouse Distance From Target To Kite", type = SPACE})
    self.Menu.VayneOrbMode:MenuElement({id = "RangedHelperRange", name = "Kite Distance Adjustment", value = 100, min = -500, max = 500, step = 10})
    self.Menu.VayneOrbMode:MenuElement({id = "RangedHelperRangeInfo", name = "Adjust the Kiting Distance By This Much", type = SPACE})
    self.Menu.VayneOrbMode:MenuElement({id = "RangedHelperRangeFacing", name = "Kite Distance Adjustment (Fleeing)", value = -120, min = -500, max = 500, step = 10})
    self.Menu.VayneOrbMode:MenuElement({id = "RangedHelperRangeFacingInfo", name = "Adjust the Kiting Distance Against A Fleeing Target", type = SPACE})
    self.Menu.VayneOrbMode:MenuElement({id = "RangedHelperRangeQ1Info", name = "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!", type = SPACE})
    self.Menu.VayneOrbMode:MenuElement({id = "RangedHelperRangeQ2Info", name = "Kiting Range Effects Q's Location In Combo", type = SPACE})
    self.Menu.VayneOrbMode:MenuElement({id = "RangedHelperRangeQ3Info", name = "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!", type = SPACE})
    self.Menu:MenuElement({id = "AutoMode", name = "Auto", type = MENU})
    self.Menu:MenuElement({id = "Draw", name = "Draw", type = MENU})
    self.Menu.Draw:MenuElement({id = "UseDraws", name = "Enable Draws", value = false})
    self.Menu.Draw:MenuElement({id = "DrawAA", name = "Draw AA range", value = false})
    self.Menu.Draw:MenuElement({id = "DrawQ", name = "Draw Q range", value = false})
    self.Menu.Draw:MenuElement({id = "DrawW", name = "Draw W range", value = false})
    self.Menu.Draw:MenuElement({id = "DrawE", name = "Draw E range", value = false})
    self.Menu.Draw:MenuElement({id = "DrawR", name = "Draw R range", value = false})
    self.Menu.Draw:MenuElement({id = "DrawCustom", name = "Draw A Custom Range Circle", value = false})
    self.Menu.Draw:MenuElement({id = "DrawCustomRange", name = "Custom Range Circle", value = 500, min = 0, max = 2000, step = 10})
end

function Vayne:MenuPushE()
    for i, enemy in pairs(EnemyHeroes) do
        self.Menu.ComboMode.ComboModeE.UseEPushChamps:MenuElement({id = enemy.charName, name = enemy.charName, value = true})
    end
end

function Vayne:MenuEvadeQ()
    for i, enemy in pairs(EnemyHeroes) do
        self.Menu.ComboMode.UseQDodgeChamps:MenuElement({id = enemy.charName, name = enemy.charName, type = MENU})
        self.Menu.ComboMode.UseQDodgeChamps[enemy.charName]:MenuElement({id = enemy:GetSpellData(_Q).name, name = enemy.charName .. "Q".. enemy:GetSpellData(_Q).name, value = false})
        self.Menu.ComboMode.UseQDodgeChamps[enemy.charName]:MenuElement({id = enemy:GetSpellData(_W).name, name = enemy.charName .. "W" .. enemy:GetSpellData(_W).name, value = false})
        self.Menu.ComboMode.UseQDodgeChamps[enemy.charName]:MenuElement({id = enemy:GetSpellData(_E).name, name = enemy.charName .. "E" .. enemy:GetSpellData(_E).name, value = false})
        self.Menu.ComboMode.UseQDodgeChamps[enemy.charName]:MenuElement({id = enemy:GetSpellData(_R).name, name = enemy.charName .. "R" .. enemy:GetSpellData(_R).name, value = false})
    end
end

function Vayne:Spells()
    --ESpellData = {speed = math.huge, range = ERange, delay = 0, angle = 50, radius = 0, collision = {}, type = "conic"}

    QSpellData = {speed = math.huge, range = 1400, delay = 0.10, radius = 30, collision = {}, type = "linear"}
    WSpellData = {speed = math.huge, range = 1000, delay = 0.75, radius = 120, collision = {}, type = "circular"}
    ESpellData = {speed = 1400, range = 1125, delay = 0.25, radius = 210, collision = {}, type = "linear"}
    RSpellData = {speed = math.huge, range = 5000, delay = 0.627, radius = 130, collision = {}, type = "circular"}

end


function Vayne:Draw()
    if self.Menu.Draw.UseDraws:Value() then
        local AARange = _G.SDK.Data:GetAutoAttackRange(myHero)
        if self.Menu.Draw.DrawAA:Value() then
            Draw.Circle(myHero.pos, AARange, 1, Draw.Color(255, 0, 191, 0))
        end
        if self.Menu.Draw.DrawQ:Value() then
            Draw.Circle(myHero.pos, QRange, 1, Draw.Color(255, 255, 0, 255))
        end
        if self.Menu.Draw.DrawW:Value() then
            Draw.Circle(myHero.pos, WRange, 1, Draw.Color(255, 0, 0, 255))
        end
        if self.Menu.Draw.DrawE:Value() then
            Draw.Circle(myHero.pos, ERange, 1, Draw.Color(255, 0, 0, 255))
        end
        if self.Menu.Draw.DrawR:Value() then
            Draw.Circle(myHero.pos, RRange, 1, Draw.Color(255, 255, 255, 255))
        end
        if self.Menu.Draw.DrawCustom:Value() then
            Draw.Circle(myHero.pos, self.Menu.Draw.DrawCustomRange:Value(), 1, Draw.Color(255, 0, 191, 0))
        end
        if target then
            --self:DrawStunSpot(target, true, true)
            local TargetStunSpot = self:GetStunSpot(target, true, true)
            if TargetStunSpot then 
                --Draw.Circle(TargetStunSpot, 50, 1, Draw.Color(255, 255, 255, 255))
            end
        end
        --InfoBarSprite = Sprite("SeriesSprites\\InfoBar.png", 1)
        --if self.Menu.ComboMode.UseEAA:Value() then
            --Draw.Text("Sticky E On", 10, myHero.pos:To2D().x+5, myHero.pos:To2D().y-130, Draw.Color(255, 0, 255, 0))
            --InfoBarSprite:Draw(myHero.pos:To2D().x,myHero.pos:To2D().y)
        --else
            --Draw.Text("Sticky E Off", 10, myHero.pos:To2D().x+5, myHero.pos:To2D().y-130, Draw.Color(255, 255, 0, 0))
            --InfoBarSprite:Draw(myHero.pos:To2D().x,myHero.pos:To2D().y)
        --end
    end
end



function Vayne:Tick()
    if _G.JustEvade and _G.JustEvade:Evading() or (_G.ExtLibEvade and _G.ExtLibEvade.Evading) or Game.IsChatOpen() or myHero.dead then return end
    target = GetTarget(5000)
    AARange = _G.SDK.Data:GetAutoAttackRange(myHero)
    if target then
        EAARange = _G.SDK.Data:GetAutoAttackRange(target)
    end
    if target and ValidTarget(target) then
        --PrintChat(target.pos:To2D())
        --PrintChat(mousePos:To2D())
        QMouseSpot = self:RangedHelper(target)
    else
        _G.SDK.Orbwalker.ForceMovement = nil
    end
    
    self:ProcessSpells()
    self:UpdateItems()
    self:Logic()
    self:Auto()
    self:Items2()

    if TickQ then

        TickQ= false
    end
    if TickW then

        TickW = false
    end
    if TickE then

        TickE = false
    end
    if TickR then

        TickR = false
    end
    if EnemyLoaded == false then
        local CountEnemy = 0
        for i, enemy in pairs(EnemyHeroes) do
            CountEnemy = CountEnemy + 1
        end
        if CountEnemy < 1 then
            GetEnemyHeroes()
        else
            self:MenuPushE()
            self:MenuEvadeQ()
            EnemyLoaded = true
            PrintChat("Enemy Loaded")
        end
    end
end


function Vayne:UpdateItems()
    Item_HK[ITEM_1] = HK_ITEM_1
    Item_HK[ITEM_2] = HK_ITEM_2
    Item_HK[ITEM_3] = HK_ITEM_3
    Item_HK[ITEM_4] = HK_ITEM_4
    Item_HK[ITEM_5] = HK_ITEM_5
    Item_HK[ITEM_6] = HK_ITEM_6
    Item_HK[ITEM_7] = HK_ITEM_7
end

function Vayne:Items1()
    if GetItemSlot(myHero, 3074) > 0 and ValidTarget(target, 300) then --rave 
        if myHero:GetSpellData(GetItemSlot(myHero, 3074)).currentCd == 0 then
            Control.CastSpell(Item_HK[GetItemSlot(myHero, 3074)])
        end
    end
    if GetItemSlot(myHero, 3077) > 0 and ValidTarget(target, 300) then --tiamat
        if myHero:GetSpellData(GetItemSlot(myHero, 3077)).currentCd == 0 then
            Control.CastSpell(Item_HK[GetItemSlot(myHero, 3077)])
        end
    end
    if GetItemSlot(myHero, 3144) > 0 and ValidTarget(target, 550) then --bilge
        if myHero:GetSpellData(GetItemSlot(myHero, 3144)).currentCd == 0 then
            Control.CastSpell(Item_HK[GetItemSlot(myHero, 3144)], target)
        end
    end
    if GetItemSlot(myHero, 3153) > 0 and ValidTarget(target, 550) then -- botrk
        if myHero:GetSpellData(GetItemSlot(myHero, 3153)).currentCd == 0 then
            Control.CastSpell(Item_HK[GetItemSlot(myHero, 3153)], target)
        end
    end
    if GetItemSlot(myHero, 3146) > 0 and ValidTarget(target, 700) then --gunblade hex
        if myHero:GetSpellData(GetItemSlot(myHero, 3146)).currentCd == 0 then
            Control.CastSpell(Item_HK[GetItemSlot(myHero, 3146)], target)
        end
    end
    if GetItemSlot(myHero, 3748) > 0 and ValidTarget(target, 300) then -- Titanic Hydra
        if myHero:GetSpellData(GetItemSlot(myHero, 3748)).currentCd == 0 then
            Control.CastSpell(Item_HK[GetItemSlot(myHero, 3748)])
        end
    end
end

function Vayne:Items2()
    if GetItemSlot(myHero, 3139) > 0 then
        if myHero:GetSpellData(GetItemSlot(myHero, 3139)).currentCd == 0 then
            if IsImmobile(myHero) then
                Control.CastSpell(Item_HK[GetItemSlot(myHero, 3139)], myHero)
            end
        end
    end
    if GetItemSlot(myHero, 3140) > 0 then
        if myHero:GetSpellData(GetItemSlot(myHero, 3140)).currentCd == 0 then
            if IsImmobile(myHero) then
                Control.CastSpell(Item_HK[GetItemSlot(myHero, 3140)], myHero)
            end
        end
    end
end

function Vayne:GetPassiveBuffs(unit, buffname)
    for i = 0, unit.buffCount do
        local buff = unit:GetBuff(i)
        if buff.name == buffname and buff.count > 0 then 
            return buff
        end
    end
    return nil
end


function Vayne:Auto()
    for i, enemy in pairs(EnemyHeroes) do
        if enemy and not enemy.dead and ValidTarget(enemy) then
            local EEAARange = _G.SDK.Data:GetAutoAttackRange(enemy)
            if Mode() == "Combo" or Mode() == "Harass" then
                if self:CanUse(_Q, Mode()) and self:CastingChecksQ() and not (myHero.pathing and myHero.pathing.isDashing) then  
                    local BestQDodgeSpot = nil
                    if target and ValidTarget(target, QTargetRange) and (GetDistance(QMouseSpot, target.pos) < AARange or GetDistance(target.pos, myHero.pos) < AARange+150) then
                        BestQDodgeSpot = self:QDodge(enemy, QMouseSpot)
                    else
                        BestQDodgeSpot = self:QDodge(enemy)
                    end
                    if self.Menu.ComboMode.UseQDodge:Value() and BestQDodgeSpot ~= nil then
                        self:UseQ(BestQDodgeSpot, false)
                    end
                end
            end

            if Mode() == "Combo" then
                local EPushRange = 250
                if EAARange < 250 then
                    EPushRange = EEAARange + 10
                end
                if self:CanUse(_E, Mode()) and ValidTarget(enemy, ERange) and self:CastingChecksE() and not (myHero.pathing and myHero.pathing.isDashing) then
                    local CurrentStunSpot = self:CheckWallStun(enemy, true)
                    if self.Menu.ComboMode.ComboModeE.UseEStun:Value() and CurrentStunSpot ~= nil and UsedSilverBuff ~= 2 then
                        self:UseE(enemy)
                    elseif self.Menu.ComboMode.ComboModeE.UseEPush:Value() and GetDistance(enemy.pos, myHero.pos) <= EPushRange and UsedSilverBuff ~= 2 and self.Menu.ComboMode.ComboModeE.UseEPushChamps[enemy.charName]:Value() then
                        self:UseE(enemy)
                    end
                end
            end
        end
    end
end 

function Vayne:CanUse(spell, mode)
    if mode == nil then
        mode = Mode()
    end
    --PrintChat(Mode())
    if spell == _Q then
        if mode == "Combo" and IsReady(spell) and self.Menu.ComboMode.UseQ:Value() then
            return true
        end
        if mode == "Harass" and IsReady(spell) and self.Menu.HarassMode.UseQ:Value() then
            return true
        end
        if mode == "Auto" and IsReady(spell) and self.Menu.AutoMode.UseQ:Value() then
            return true
        end
        if mode == "Force" and IsReady(spell) then
            return true
        end
    elseif spell == _W then
        if mode == "Combo" and IsReady(spell) and self.Menu.ComboMode.UseW:Value() then
            return true
        end
        if mode == "Harass" and IsReady(spell) and self.Menu.HarassMode.UseW:Value() then
            return true
        end
        if mode == "Force" and IsReady(spell) then
            return true
        end
    elseif spell == _E then
        if mode == "Combo" and IsReady(spell) and self.Menu.ComboMode.UseE:Value() then
            return true
        end
        if mode == "Harass" and IsReady(spell) and self.Menu.HarassMode.UseE:Value() then
            return true
        end
        if mode == "Force" and IsReady(spell) then
            return true
        end
    elseif spell == _R then
        if mode == "Combo" and IsReady(spell) and self.Menu.ComboMode.UseR:Value() then
            return true
        end
        if mode == "Harass" and IsReady(spell) and self.Menu.HarassMode.UseR:Value() then
            return true
        end
        if mode == "Force" and IsReady(spell) then
            return true
        end
    end
    return false
end

function Vayne:Logic()

    if target == nil then 
        if Game.Timer() - TargetTime > 2 then
            WasInRange = false
        end
        return 
    end

    local QPostAttack = false
    if _G.SDK.Attack:IsActive() then
        WasAttacking = true

    else
        if WasAttacking == true then
            QPostAttack = true
            PredSilverBuff = SilverBuff + 1
            KrakenStacks = KrakenStacks + 1
        end
        WasAttacking = false
    end

    UsedSilverBuff = SilverBuff
    if QPostAttack == true then
        UsedSilverBuff = PredSilverBuff
    end

    if self.Menu.UseEFlashKey:Value() then
        local ClosestStunSpot = self:GetStunSpot(target, true, false)
        if ClosestStunSpot and GetDistance(ClosestStunSpot, myHero.pos) < 550 then
            self:Eflash(ClosestStunSpot)
        end
    end


    if self.Menu.UseEProcKey:Value() then
        self:PrimeEOnKey()
    end

    if Mode() == "Combo" or Mode() == "Harass" and target then

        local DamageList = self:DamageChecks(target)
        local ClosestStunSpot = self:GetStunSpot(target, true, true)
        local CurrentStunSpot = self:CheckWallStun(target, true)
        local QTargetRange = AARange + QRange + 50
        local EPushRange = 250
        if EAARange < 250 then
            EPushRange = EAARange + 10
        end
        self:Items1()

        local QAttackCheck = GetDistance(myHero.pos, target.pos) > AARange or QPostAttack
        if Game.Timer() - TargetTime > 2 then
            WasInRange = false
        end
        if GetDistance(myHero.pos, target.pos) < AARange then
            TargetTime = Game.Timer()
            WasInRange = true
        end
        if Mode() == "Combo" then
            if self:CanUse(_E, Mode()) and ValidTarget(target, ERange) and self:CastingChecksE() and not (myHero.pathing and myHero.pathing.isDashing) then
                if self.Menu.ComboMode.ComboModeE.UseEStun:Value() and CurrentStunSpot ~= nil then
                    self:UseE(target)
                elseif PrimedE == true and UsedSilverBuff == 2 then
                    self:UseE(target)
                elseif self.Menu.ComboMode.ComboModeE.UseEPush:Value() and GetDistance(target.pos, myHero.pos) <= EPushRange and EAARange <= 450 then
                    if self.Menu.ComboMode.ComboModeE.UseEPushChamps[target.charName]:Value() then
                        self:UseE(target)
                    end
                elseif self.Menu.ComboMode.ComboModeE.UseEFinish:Value() and UsedSilverBuff == 2 and DamageList.EWKills and not _G.SDK.Attack:IsActive() then
                    self:UseE(target)
                end
            end
            if self:CanUse(_Q, Mode()) and ValidTarget(target, QTargetRange) and self:CastingChecksQ() and not (myHero.pathing and myHero.pathing.isDashing) and (GetDistance(QMouseSpot, target.pos) < AARange or GetDistance(target.pos, myHero.pos) < AARange+150) then
                
                if QAttackCheck then
                    if EAARange < 430 then
                        if RActive == false then
                            if self.Menu.ComboMode.ComboModeQ.UseQStun:Value() and CurrentStunSpot == nil and ClosestStunSpot and GetDistance(myHero.pos, ClosestStunSpot) < QRange and self:CanUse(_E, Mode()) and self.Menu.ComboMode.ComboModeE.UseEStun:Value() and WasInRange then
                                self:UseQ(ClosestStunSpot, false)
                            elseif GetDistance(target.pos, myHero.pos) > AARange and self.Menu.ComboMode.ComboModeQ.UseQPull:Value() and WasInRange then
                                self:UseQ(QMouseSpot, false)
                            elseif GetDistance(target.pos, myHero.pos) < EAARange+45 and self.Menu.ComboMode.ComboModeQ.UseQPush:Value() and EAARange < 430 then
                                self:UseQ(QMouseSpot, false)
                            elseif self.Menu.ComboMode.ComboModeQ.UseQDPS:Value() and WasInRange then
                                self:UseQ(QMouseSpot, true)
                            elseif UsedSilverBuff == 2 and self.Menu.ComboMode.ComboModeQ.UseQProc:Value() then
                                self:UseQ(QMouseSpot, true)
                            elseif UsedSilverBuff == 2 and self.Menu.ComboMode.ComboModeQ.UseQFinish:Value() and DamageList.QWKills then
                                self:UseQ(QMouseSpot, true)
                            elseif UsedSilverBuff >= 1 and self.Menu.ComboMode.ComboModeQ.UseQFinish:Value() and DamageList.QEWKills and self.Menu.ComboMode.ComboModeE.UseEFinish:Value() and self:CanUse(_E, Mode()) then
                                self:UseQ(QMouseSpot, true)
                            elseif self.Menu.ComboMode.ComboModeQ.UseQFinish:Value() and DamageList.QEKills and self.Menu.ComboMode.ComboModeE.UseEFinish:Value() and self:CanUse(_E, Mode()) then
                                self:UseQ(QMouseSpot, true)
                            elseif self.Menu.ComboMode.ComboModeQ.UseQFinish:Value() and DamageList.QKills then
                                self:UseQ(QMouseSpot, true)
                            end
                        else
                            if self.Menu.ComboMode.ComboModeQR.UseQStun:Value() and CurrentStunSpot == nil and ClosestStunSpot and GetDistance(myHero.pos, ClosestStunSpot) < QRange and self:CanUse(_E, Mode()) and self.Menu.ComboMode.ComboModeE.UseEStun:Value() and WasInRange then
                                self:UseQ(ClosestStunSpot, false)
                            elseif GetDistance(target.pos, myHero.pos) > AARange and self.Menu.ComboMode.ComboModeQR.UseQPull:Value() and WasInRange then
                                self:UseQ(QMouseSpot, false)
                            elseif GetDistance(target.pos, myHero.pos) < EAARange+45 and self.Menu.ComboMode.ComboModeQR.UseQPush:Value() and EAARange < 430 then
                                self:UseQ(QMouseSpot, false)
                            elseif self.Menu.ComboMode.ComboModeQR.UseQDPS:Value() and WasInRange then
                                self:UseQ(QMouseSpot, true)
                            elseif UsedSilverBuff == 2 and self.Menu.ComboMode.ComboModeQR.UseQProc:Value() then
                                self:UseQ(QMouseSpot, true)
                            elseif UsedSilverBuff == 2 and self.Menu.ComboMode.ComboModeQR.UseQFinish:Value() and DamageList.QWKills then
                                self:UseQ(QMouseSpot, true)
                            elseif UsedSilverBuff >= 1 and self.Menu.ComboMode.ComboModeQR.UseQFinish:Value() and DamageList.QEWKills and self.Menu.ComboMode.ComboModeE.UseEFinish:Value() and self:CanUse(_E, Mode()) then
                                self:UseQ(QMouseSpot, true)
                            elseif self.Menu.ComboMode.ComboModeQR.UseQFinish:Value() and DamageList.QEKills and self.Menu.ComboMode.ComboModeE.UseEFinish:Value() and self:CanUse(_E, Mode()) then
                                self:UseQ(QMouseSpot, true)
                            elseif self.Menu.ComboMode.ComboModeQR.UseQFinish:Value() and DamageList.QKills then
                                self:UseQ(QMouseSpot, true)
                            end
                        end
                    else
                        if RActive == false then
                            if self.Menu.ComboMode.ComboModeQRanged.UseQStun:Value() and CurrentStunSpot == nil and ClosestStunSpot and GetDistance(myHero.pos, ClosestStunSpot) < QRange and self:CanUse(_E, Mode()) and self.Menu.ComboMode.ComboModeE.UseEStun:Value() and WasInRange then
                                self:UseQ(ClosestStunSpot, false)
                            elseif GetDistance(target.pos, myHero.pos) > AARange and self.Menu.ComboMode.ComboModeQRanged.UseQPull:Value() and WasInRange then
                                self:UseQ(QMouseSpot, false)
                            elseif GetDistance(target.pos, myHero.pos) < EAARange+45 and self.Menu.ComboMode.ComboModeQRanged.UseQPush:Value() and EAARange < 430 then
                                self:UseQ(QMouseSpot, false)
                            elseif self.Menu.ComboMode.ComboModeQRanged.UseQDPS:Value() and WasInRange then
                                self:UseQ(QMouseSpot, true)
                            elseif UsedSilverBuff == 2 and self.Menu.ComboMode.ComboModeQRanged.UseQProc:Value() then
                                self:UseQ(QMouseSpot, true)
                            elseif UsedSilverBuff == 2 and self.Menu.ComboMode.ComboModeQRanged.UseQFinish:Value() and DamageList.QWKills then
                                self:UseQ(QMouseSpot, true)
                            elseif UsedSilverBuff >= 1 and self.Menu.ComboMode.ComboModeQRanged.UseQFinish:Value() and DamageList.QEWKills and self.Menu.ComboMode.ComboModeE.UseEFinish:Value() and self:CanUse(_E, Mode()) then
                                self:UseQ(QMouseSpot, true)
                            elseif self.Menu.ComboMode.ComboModeQRanged.UseQFinish:Value() and DamageList.QEKills and self.Menu.ComboMode.ComboModeE.UseEFinish:Value() and self:CanUse(_E, Mode()) then
                                self:UseQ(QMouseSpot, true)
                            elseif self.Menu.ComboMode.ComboModeQRanged.UseQFinish:Value() and DamageList.QKills then
                                self:UseQ(QMouseSpot, true)
                            end
                        else
                            if self.Menu.ComboMode.ComboModeQRangedR.UseQStun:Value() and CurrentStunSpot == nil and ClosestStunSpot and GetDistance(myHero.pos, ClosestStunSpot) < QRange and self:CanUse(_E, Mode()) and self.Menu.ComboMode.ComboModeE.UseEStun:Value() and WasInRange then
                                self:UseQ(ClosestStunSpot, false)
                            elseif GetDistance(target.pos, myHero.pos) > AARange and self.Menu.ComboMode.ComboModeQRangedR.UseQPull:Value() and WasInRange then
                                self:UseQ(QMouseSpot, false)
                            elseif GetDistance(target.pos, myHero.pos) < EAARange+45 and self.Menu.ComboMode.ComboModeQRangedR.UseQPush:Value() and EAARange < 430 then
                                self:UseQ(QMouseSpot, false)
                            elseif self.Menu.ComboMode.ComboModeQRangedR.UseQDPS:Value() and WasInRange then
                                self:UseQ(QMouseSpot, true)
                            elseif UsedSilverBuff == 2 and self.Menu.ComboMode.ComboModeQRangedR.UseQProc:Value() then
                                self:UseQ(QMouseSpot, true)
                            elseif UsedSilverBuff == 2 and self.Menu.ComboMode.ComboModeQRangedR.UseQFinish:Value() and DamageList.QWKills then
                                self:UseQ(QMouseSpot, true)
                            elseif UsedSilverBuff >= 1 and self.Menu.ComboMode.ComboModeQRangedR.UseQFinish:Value() and DamageList.QEWKills and self.Menu.ComboMode.ComboModeE.UseEFinish:Value() and self:CanUse(_E, Mode()) then
                                self:UseQ(QMouseSpot, true)
                            elseif self.Menu.ComboMode.ComboModeQRangedR.UseQFinish:Value() and DamageList.QEKills and self.Menu.ComboMode.ComboModeE.UseEFinish:Value() and self:CanUse(_E, Mode()) then
                                self:UseQ(QMouseSpot, true)
                            elseif self.Menu.ComboMode.ComboModeQRangedR.UseQFinish:Value() and DamageList.QKills then
                                self:UseQ(QMouseSpot, true)
                            end
                        end
                    end
                end                        
            end
        elseif Mode() == "Harass" then
            if self:CanUse(_E, Mode()) and ValidTarget(target, ERange) and self:CastingChecksE() and not (myHero.pathing and myHero.pathing.isDashing) then
                if self.Menu.HarassMode.HarassModeE.UseEStun:Value() and CurrentStunSpot ~= nil then
                    self:UseE(target)
                elseif PrimedE == true and UsedSilverBuff == 2 then
                    self:UseE(target)
                elseif self.Menu.HarassMode.HarassModeE.UseEPush:Value() and GetDistance(target.pos, myHero.pos) <= EPushRange and EAARange <= 450 then 
                    self:UseE(target)
                elseif self.Menu.HarassMode.HarassModeE.UseEFinish:Value() and (DamageList.EKills or (SilverBuff == 2 and DamageList.EWKills)) and not _G.SDK.Attack:IsActive() then
                    self:UseE(target)
                elseif UsedSilverBuff == 2 and self.Menu.HarassMode.HarassModeE.UseEProc:Value() then
                    self:UseE(target)
                end
            end
            if self:CanUse(_Q, Mode()) and ValidTarget(target, QTargetRange) and self:CastingChecksQ() and not (myHero.pathing and myHero.pathing.isDashing) and not _G.SDK.Attack:IsActive() and (GetDistance(QMouseSpot, target.pos) < AARange or GetDistance(target.pos, myHero.pos) < AARange+150) then
                if self.Menu.HarassMode.HarassModeQ.UseQStun:Value() and CurrentStunSpot == nil and ClosestStunSpot and GetDistance(myHero.pos, ClosestStunSpot) < QRange and self:CanUse(_E, Mode()) and self.Menu.HarassMode.HarassModeE.UseEStun:Value() then
                    self:UseQ(ClosestStunSpot)
                elseif GetDistance(target.pos, myHero.pos) > AARange and self.Menu.HarassMode.HarassModeQ.UseQPull:Value() then
                    self:UseQ(QMouseSpot)
                elseif GetDistance(target.pos, myHero.pos) < EAARange+45 and self.Menu.HarassMode.HarassModeQ.UseQPush:Value() then
                    self:UseQ(QMouseSpot)
                elseif self.Menu.HarassMode.HarassModeQ.UseQDPS:Value() then
                    self:UseQ(QMouseSpot)
                elseif UsedSilverBuff == 2 and self.Menu.HarassMode.HarassModeQ.UseQProc:Value() then
                    self:UseQ(QMouseSpot)
                elseif UsedSilverBuff == 2 and self.Menu.HarassMode.HarassModeQ.UseQFinish:Value() and DamageList.QWKills then
                    self:UseQ(QMouseSpot)
                elseif UsedSilverBuff >= 1 and self.Menu.HarassMode.HarassModeQ.UseQFinish:Value() and DamageList.QEWKills and self.Menu.HarassMode.HarassModeE.UseEFinish:Value() and self:CanUse(_E, Mode()) then
                    self:UseQ(QMouseSpot)
                elseif self.Menu.HarassMode.HarassModeQ.UseQFinish:Value() and DamageList.QEKills and self.Menu.HarassMode.HarassModeE.UseEFinish:Value() and self:CanUse(_E, Mode()) then
                    self:UseQ(QMouseSpot)
                elseif self.Menu.HarassMode.HarassModeQ.UseQFinish:Value() and DamageList.QKills then
                    self:UseQ(QMouseSpot)
                elseif SilverBuff == 1 and self.Menu.HarassMode.HarassModeQ.UseQPrepair:Value() and self.Menu.HarassMode.HarassModeE.UseEProc:Value() then

                end
            end
        end
    end     
end

function Vayne:QDodge(enemy, HelperSpot)
    if enemy.activeSpell and enemy.activeSpell.valid then
        if enemy.activeSpell.target == myHero.handle then

        else
            local SpellName = enemy.activeSpell.name
            if self.Menu.ComboMode.UseQDodgeChamps[enemy.charName] and self.Menu.ComboMode.UseQDodgeChamps[enemy.charName][SpellName] and self.Menu.ComboMode.UseQDodgeChamps[enemy.charName][SpellName]:Value() then




                local CastPos = enemy.activeSpell.startPos
                local PlacementPos = enemy.activeSpell.placementPos
                local width = 100
                if enemy.activeSpell.width > 0 then
                    width = enemy.activeSpell.width
                end
                local SpellType = "Linear"
                if SpellType == "Linear" and PlacementPos and CastPos then

                    --PrintChat(CastPos)
                    local VCastPos = Vector(CastPos.x, CastPos.y, CastPos.z)
                    local VPlacementPos = Vector(PlacementPos.x, PlacementPos.y, PlacementPos.z)

                    local CastDirection = Vector((VCastPos-VPlacementPos):Normalized())
                    local PlacementPos2 = VCastPos - CastDirection * enemy.activeSpell.range

                    local TargetPos = Vector(enemy.pos)
                    local MouseDirection = Vector((myHero.pos-mousePos):Normalized())
                    local ScanDistance = width*2 + myHero.boundingRadius
                    local ScanSpot = myHero.pos - MouseDirection * ScanDistance
                    local ClosestSpot = Vector(self:ClosestPointOnLineSegment(myHero.pos, PlacementPos2, CastPos))
                    if HelperSpot then 
                        local ClosestSpotHelper = Vector(self:ClosestPointOnLineSegment(HelperSpot, PlacementPos2, CastPos))
                        if ClosestSpot and ClosestSpotHelper then
                            local PlacementDistance = GetDistance(myHero.pos, ClosestSpot)
                            local HelperDistance = GetDistance(HelperSpot, ClosestSpotHelper)
                            if PlacementDistance < width*2 + myHero.boundingRadius then
                                if HelperDistance > width*2 + myHero.boundingRadius then
                                    return HelperSpot
                                elseif self.Menu.ComboMode.UseQDodgeCalc:Value() then
                                    local DodgeRange = width*2 + myHero.boundingRadius
                                    if DodgeRange < QRange then
                                        local DodgeSpot = self:GetDodgeSpot(CastPos, ClosestSpot, DodgeRange)
                                        if DodgeSpot ~= nil then
                                           --PrintChat("Dodging to Calced Spot")
                                            return DodgeSpot
                                        end
                                    end
                                end
                            end
                        end
                    else
                        if ClosestSpot then
                            local PlacementDistance = GetDistance(myHero.pos, ClosestSpot)
                            if PlacementDistance < width*2 + myHero.boundingRadius then
                                if self.Menu.ComboMode.UseQDodgeCalc:Value() then
                                    local DodgeRange = width*2 + myHero.boundingRadius
                                    if DodgeRange < QRange then
                                        local DodgeSpot = self:GetDodgeSpot(CastPos, ClosestSpot, DodgeRange)
                                        if DodgeSpot ~= nil then
                                           --PrintChat("Dodging to Calced Spot")
                                            return DodgeSpot
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end    
    return nil
end





function Vayne:Eflash(FlashSpot)
    if target then
        if IsReady(_E) and ValidTarget(target, ERange) and self:CastingChecksE() and not (myHero.pathing and myHero.pathing.isDashing) and Flash and IsReady(Flash) then
            Control.CastSpell(HK_E, target)
            PrimedFlashE = FlashSpot
            PrimedFlashETime = Game.Timer()
            DelayAction(function() Control.CastSpell(FlashSpell, PreMouse) end, 0.05)
        end  
    end
end 


function Vayne:PrimeEOnKey()
    if target then
        PrimedE = true
        PrimedETime = Game.Timer()
    end
end 

function Vayne:GetRTarget()
    if target then
        Rtarget = target
    end

    if myHero.activeSpell.name == "VayneLocusOfPower2" then
        if Rtarget then
            if not Rtarget.pos:ToScreen().onScreen then
                --self:MoveCamera2(Rtarget)
            elseif CameraMoving == true then
                --self:StopCamera(Rtarget)
            end
            self:MoveCamera2(Rtarget)
        end

    end
end

function Vayne:ClosestPointOnLineSegment(p, p1, p2)
    local px = p.x
    local pz = p.z
    local ax = p1.x
    local az = p1.z
    local bx = p2.x
    local bz = p2.z
    local bxax = bx - ax
    local bzaz = bz - az
    local t = ((px - ax) * bxax + (pz - az) * bzaz) / (bxax * bxax + bzaz * bzaz)
    if (t < 0) then
        return p1, false
    end
    if (t > 1) then
        return p2, false
    end
    return {x = ax + t * bxax, z = az + t * bzaz}, true
end

function Vayne:RangedHelper(unit)
    local EAARangel = _G.SDK.Data:GetAutoAttackRange(unit)
    local MoveSpot = nil
    local RangeDif = AARange - EAARangel
    local ExtraRangeDist = RangeDif + self.Menu.VayneOrbMode.RangedHelperRange:Value()
    local ExtraRangeChaseDist = RangeDif + self.Menu.VayneOrbMode.RangedHelperRangeFacing:Value()

    local ScanDirection = Vector((myHero.pos-mousePos):Normalized())
    local ScanDistance = GetDistance(myHero.pos, unit.pos) * 0.8
    local ScanSpot = myHero.pos - ScanDirection * ScanDistance

    local MouseDirection = Vector((unit.pos-ScanSpot):Normalized())
    local MouseSpotDistance = EAARangel + ExtraRangeDist
    if not IsFacing(unit) then
        MouseSpotDistance = EAARangel + ExtraRangeChaseDist
    end
    if MouseSpotDistance > AARange then
        MouseSpotDistance = AARange
    end

    local MouseSpot = unit.pos - MouseDirection * (MouseSpotDistance)
    local QMouseSpotDirection = Vector((myHero.pos-MouseSpot):Normalized())
    local QmouseSpotDistance = GetDistance(myHero.pos, MouseSpot)
    if QmouseSpotDistance > 300 then
        QmouseSpotDistance = 300
    end
    local QMouseSpoty = myHero.pos - QMouseSpotDirection * QmouseSpotDistance
    MoveSpot = MouseSpot

    if MoveSpot then
        if GetDistance(myHero.pos, MoveSpot) < 50 then
            _G.SDK.Orbwalker.ForceMovement = nil
        elseif self.Menu.VayneOrbMode.UseRangedHelperWalk:Value() and GetDistance(myHero.pos, unit.pos) <= AARange-50 and (Mode() == "Combo" or Mode() == "Harass") then
            _G.SDK.Orbwalker.ForceMovement = MoveSpot
        else
            _G.SDK.Orbwalker.ForceMovement = nil
        end
    end
    return QMouseSpoty
end

function Vayne:DrawStunSpot(unit, PredictedE, PredictedQ)
    local DegAngle = 0
    local RadAngle = DegAngle * math.pi / 180
    local MyHeroPos = Vector(myHero.pos)
    local TargetPos = Vector(unit.pos)

    if PredictedE == true then
        local NextSpot = GetUnitPositionNext(unit)
        if NextSpot then
            local Time = (GetDistance(unit.pos, myHero.pos) / 2000) + 0.25
            if PredictedQ == true then
                Time = Time + 0.45
            end
            local UnitDirection = Vector((unit.pos-NextSpot):Normalized())
            local PredictedPos = unit.pos - UnitDirection * (unit.ms*Time)
            TargetPos = PredictedPos
        end
    end

    local CheckPos = TargetPos + (MyHeroPos - TargetPos):Rotated(0, RadAngle, 0):Normalized() * 475
    local ClosestMSSpot = nil
    local ClosestESSpot = nil

    for i = 0, 360 do
        RadAngle = i * math.pi / 180
        CheckPos = TargetPos + (MyHeroPos - TargetPos):Rotated(0, RadAngle, 0):Normalized() * 475

        
        local Direction = Vector((CheckPos - TargetPos):Normalized())
        local MSSpotFar = nil
        local MSSpot = nil
        for i=1, 10 do
            local ESSpot = TargetPos - Direction * (47*i) 
            if MapPosition:inWall(ESSpot) then
                MSSpotFar = CheckPos
            end
        end
        --Draw.Circle(MSSpotFar, 50, 1, Draw.Color(255, 0, 0, 255))
        if MSSpotFar ~= nil then
            local MSSpot = Vector(self:ClosestPointOnLineSegment(myHero.pos, MSSpotFar, TargetPos))
            if ClosestMSSpot == nil or GetDistance(myHero.pos, ClosestMSSpot) > GetDistance(myHero.pos, MSSpot) then
                ClosestMSSpot = MSSpot
            end
        end
    end
    if ClosestMSSpot == nil then
        --PrintChat(" Closest Stun Spot Is NIL")
    else
        --PrintChat(" Closest Stun Spot FOUND")
        Draw.Circle(ClosestMSSpot, 50, 1, Draw.Color(255, 0, 0, 255))
    end
end

function Vayne:GetStunSpot(unit, PredictedE, PredictedQ)
    local DegAngle = 0
    local RadAngle = DegAngle * math.pi / 180
    local MyHeroPos = Vector(myHero.pos)
    local TargetPos = Vector(unit.pos)

    if PredictedE == true then
        local NextSpot = GetUnitPositionNext(unit)
        if NextSpot then
            local Time = (GetDistance(unit.pos, myHero.pos) / 2000) + 0.25
            if PredictedQ == true then
                Time = Time + 0.45
            end
            local UnitDirection = Vector((unit.pos-NextSpot):Normalized())
            local PredictedPos = unit.pos - UnitDirection * (unit.ms*Time)
            TargetPos = PredictedPos
        end
    end

    local CheckPos = TargetPos + (MyHeroPos - TargetPos):Rotated(0, RadAngle, 0):Normalized() * 475
    local ClosestMSSpot = nil
    local ClosestESSpot = nil

    for i = 0, 360, 10 do
        RadAngle = i * math.pi / 180
        CheckPos = TargetPos + (MyHeroPos - TargetPos):Rotated(0, RadAngle, 0):Normalized() * 475

        
        local Direction = Vector((CheckPos - TargetPos):Normalized())
        local MSSpotFar = nil
        local MSSpot = nil
        for i=1, 10 do
            local ESSpot = TargetPos - Direction * (40*i) 
            if MapPosition:inWall(ESSpot) then
                MSSpotFar = CheckPos
            end
        end
        if MSSpotFar ~= nil then
            local MSSpot = Vector(self:ClosestPointOnLineSegment(myHero.pos, MSSpotFar, TargetPos))
            if ClosestMSSpot == nil or GetDistance(myHero.pos, ClosestMSSpot) > GetDistance(myHero.pos, MSSpot) then
                ClosestMSSpot = MSSpot
            end
        end
    end
    return ClosestMSSpot
end

function Vayne:GetDodgeSpot(CastSpot, ClosestSpot, width)
    local DodgeSpot = nil
    local RadAngle1 = 90 * math.pi / 180
    local CheckPos1 = ClosestSpot + (CastSpot - ClosestSpot):Rotated(0, RadAngle1, 0):Normalized() * width
    local RadAngle2 = 270 * math.pi / 180
    local CheckPos2 = ClosestSpot + (CastSpot - ClosestSpot):Rotated(0, RadAngle2, 0):Normalized() * width

    if GetDistance(CheckPos1, mousePos) < GetDistance(CheckPos2, mousePos) then
        if GetDistance(CheckPos1, myHero.pos) < QRange then
            DodgeSpot = CheckPos1
        elseif GetDistance(CheckPos2, myHero.pos) < QRange then
            DodgeSpot = CheckPos2
        end
    else
        if GetDistance(CheckPos2, myHero.pos) < QRange then
            DodgeSpot = CheckPos2
        elseif GetDistance(CheckPos1, myHero.pos) < QRange then
            DodgeSpot = CheckPos1
        end
    end
    return DodgeSpot
end

function Vayne:GetWallRollSpot()
    local DegAngle = 0
    local RadAngle = DegAngle * math.pi / 180
    local MyHeroPos = Vector(myHero.pos)
    local TargetPos = Vector(target.pos)


    local CheckPos = MyHeroPos + (TargetPos - MyHeroPos):Rotated(0, RadAngle, 0):Normalized() * 100
    local ClosestMSSpot = nil
    local ClosestESSpot = nil

    for i = 0, 360, 10 do
        RadAngle = i * math.pi / 180
        CheckPos = MyHeroPos + (TargetPos - MyHeroPos):Rotated(0, RadAngle, 0):Normalized() * 100

        
        local Direction = Vector((CheckPos - MyHeroPos):Normalized())
        local MSSpotFar = nil
        local MSSpot = nil
        for i=1, 2 do
            local ESSpot = MyHeroPos - Direction * (50*i) 
            if MapPosition:inWall(ESSpot) then
                MSSpotFar = CheckPos
            end
        end
        if MSSpotFar ~= nil then
            if ClosestMSSpot == nil or GetDistance(target.pos, ClosestMSSpot) > GetDistance(target.pos, MSSpotFar) then
                ClosestMSSpot = MSSpot
            end
        end
    end
    return ClosestMSSpot
end

function Vayne:CheckWallStun(unit, PredictedE)
    local PredictedPos = unit.pos
    local Direction = Vector((PredictedPos-myHero.pos):Normalized())
    local ESpot = unit.pos
    if PredictedE == true then
        local NextSpot = GetUnitPositionNext(unit)
        if NextSpot then
            local Time = (GetDistance(unit.pos, myHero.pos) / 2000) + 0.25
            local UnitDirection = Vector((unit.pos-NextSpot):Normalized())
            PredictedPos = unit.pos - UnitDirection * (unit.ms*Time)
            Direction = Vector((PredictedPos-myHero.pos):Normalized())
            ESpot = PredictedPos + Direction * (440)
            if MapPosition:intersectsWall(myHero.pos, ESpot) then
                return ESpot
            end
        end
    end
    for i=1, 11 do
        ESpot = PredictedPos + Direction * (40*i) 
        if MapPosition:inWall(ESpot) then
            return ESpot
        end
    end
    return nil
end

function Vayne:DamageChecks(unit)
    local Qdmg = getdmg("Q", unit, myHero)
    local Edmg = getdmg("E", unit, myHero)
    local Wdmg = getdmg("W", unit, myHero)
    local AAdmg = getdmg("AA", unit, myHero)
    if Kraken and KrakenStacks == 2 then
        AAdmg = AAdmg + 60 + (0.45*myHero.bonusDamage)
        --PrintChat(60 + (0.45*myHero.bonusDamage))
    end
    local UnitHealth = unit.health + unit.shieldAD
    local BurstDmg = Qdmg + Wdmg + Edmg + (AAdmg*3)
    local QCheck = UnitHealth - (Qdmg + AAdmg) < 0
    local WCheck = UnitHealth - Wdmg < 0
    local ECheck = UnitHealth - (Edmg) < 0
    local QECheck = UnitHealth - (Qdmg + AAdmg + Edmg) < 0
    local QWCheck = UnitHealth - (Qdmg + AAdmg + Wdmg) < 0
    local EWCheck = UnitHealth - (Edmg + Wdmg) < 0
    local QEWCheck = UnitHealth - (Qdmg + AAdmg + Wdmg + Edmg) < 0

    local DamageArray = {QKills = QCheck, EKills = ECheck, WKills = WCheck, QWKills = QWCheck, EWKills = EWCheck, QEWKills = QEWCheck, BurstDamage = BurstDamage, QDamage = Qdmg, EDamage = Edmg, WDamage = Wdmg, AADamage = AAdmg}
    return DamageArray
end

function Vayne:ProcessSpells()
    CastingQ = myHero.activeSpell.name == "VayneTumble" 
    CastingW = myHero.activeSpell.name == "VayneArcaneBarrage2"
    CastingE = myHero.activeSpell.name == "VayneCondemn"
    CastingR = myHero.activeSpell.name == "VayneFinalHour" 

    RActive = BuffActive(myHero, "VayneInquisition")
    Kraken = BuffActive(myHero, "6672buff")


    if myHero:GetSpellData(SUMMONER_1).name:find("Flash") then
        Flash = SUMMONER_1
        FlashSpell = HK_SUMMONER_1
    elseif myHero:GetSpellData(SUMMONER_2).name:find("Flash") then
        Flash = SUMMONER_2
        FlashSpell = HK_SUMMONER_2
    else 
        Flash = nil
    end

    if Kraken == false then
        KrakenStacks = 0
    end

    if target then
        SilverBuff = _G.SDK.BuffManager:GetBuffCount(target, "VayneSilveredDebuff")
        --PrintChat(SilverBuff)
    else
        SilverBuff = 0
    end

    if PrimedFlashE ~= nil and Game.Timer() - PrimedFlashETime > 0.5 then
        PrimedFlashE = nil
    end

    if PrimedE == true and Game.Timer() - PrimedETime > 3 then
        PrimedE = false
    end

    if myHero:GetSpellData(_Q).currentCd == 0 then
        CastedQ = false
    else
        if CastedQ == false then
            TickQ = true
            LastSpellCasted = "Q"
        end
        CastedQ = true
    end
    if myHero:GetSpellData(_W).currentCd == 0 then
        CastedW = false
    else
        if CastedW == false then
            TickW = true
            LastSpellCasted = "W"
        end
        CastedW = true
    end
    if myHero:GetSpellData(_E).currentCd == 0 then
        CastedE = false
    else
        if CastedE == false then
            TickE = true
            LastSpellCasted = "E"
            if PrimedFlashE ~= nil and Flash and IsReady(Flash) then
                --Control.CastSpell(FlashSpell, PrimedFlashE)
                PrimedFlashE = nil
            end
            PrimedE = false
        end
        CastedE = true
    end
    if myHero:GetSpellData(_R).currentCd == 0 then
        CastedR = false
    else
        if CastedR == false then
            TickR = true
            LastSpellCasted = "R"
        end
        CastedR = true
    end
end

function Vayne:CastingChecks()
    if not CastingQ and not CastingW and not CastingE and not CastingR then
        return true
    else
        return false
    end
end

function Vayne:CastingChecksE()
    if not CastingQ and not CastingE then
        return true
    else
        return false
    end
end


function Vayne:CastingChecksQ()
    if not CastingQ and not CastingE then
        return true
    else
        return false
    end
end

function Vayne:OnPostAttack(args)

end

function Vayne:OnPostAttackTick(args)
end

function Vayne:OnPreAttack(args)
end


function Vayne:UseQ(unit, wallroll)
    if wallroll == false then
        Control.CastSpell(HK_Q, unit)
    else
        local WallSpot = self:GetWallRollSpot()
        if WallSpot ~= nil then
            Control.CastSpell(HK_Q, WallSpot)
        else
            Control.CastSpell(HK_Q, unit)
        end
    end
end

function Vayne:UseE(unit)
    Control.CastSpell(HK_E, unit)
end

class "Twitch"

local EnemyLoaded = false
local TargetTime = 0

local CastingQ = false
local CastingW = false
local CastingE = false
local CastingR = false

local CastedQ = false
local TickQ = false
local CastedW = false
local TickE = false
local CastedE = false
local TickE = false
local CastedR = false
local TickR = false

local Item_HK = {}

local WasInRange = false

local ForceTarget = nil
local Rtarget = nil

local QBuff = nil
local WBuff = nil
local EBuff = nil
local RBuff = nil

local AARange = 0
local EAARange = 0
local QRange = 1400
local ERange = 1200

local ActiveQRange = 750
local QMaxRange = 1400

local QStarted = Game.Timer()
local RStarted = Game.Timer()

local Flash = nil
local FlashSpell = nil

local WStacks = 0
local HadStun = false
local StunTime = Game.Timer()
local UseBuffs = false
local ReturnMouse = mousePos

local Kraken = false
local KrakenStacks = 0
local RActive = false

local PrimedFlashE = nil
local PrimedFlashETime = Game.Timer()

local Flash = nil
local FlashSpell = nil


local SilverBuff = 0
local UsedSilverBuff
local PredSilverBuff = 0

local WRange = 1000
local ERange = 1200
local RRange = 5000
local QRange = 300

local AutoEEnable = false

local QMouseSpot = nil

local WasAttacking = false

local CameraMoving = false

local Mounted = true

local DrawCounter = 0

local EnemiesEInfo = {}
local VenomList = {}


function Twitch:Menu()
    self.Menu = MenuElement({type = MENU, id = "Twitch", name = "AP Twitch"})
    self.Menu:MenuElement({id = "ComboMode", name = "Combo", type = MENU})
    self.Menu.ComboMode:MenuElement({id = "ComboModeW", name = "W Settings", type = MENU})
    self.Menu.ComboMode.ComboModeW:MenuElement({id = "UseWMulti", name = "(W) Hold For Multiple Enemies", value = true})
    self.Menu.ComboMode.ComboModeW:MenuElement({id = "InvisW", name = "(W) While Invisible", value = true})
    self.Menu.ComboMode.ComboModeW:MenuElement({id = "UseWMultiInfo", name = "Delay W if possible to hit Multiple enemies", type = SPACE})
    self.Menu.ComboMode:MenuElement({id = "UseW", name = "(W) Enable/Disable All Usage", value = true})
    self.Menu.ComboMode:MenuElement({id = "ComboModeE", name = "E Settings", type = MENU})
    self.Menu.ComboMode.ComboModeE:MenuElement({id = "UseEFinish", name = "(E) Finish Kills", value = true})
    self.Menu.ComboMode.ComboModeE:MenuElement({id = "UseEFinishInfo", name = "Use E If All Enemies In Range Die", type = SPACE})
    self.Menu.ComboMode:MenuElement({id = "UseE", name = "(E) Enable/Disable All Usage", value = true})
    self.Menu:MenuElement({id = "HarassMode", name = "Harass", type = MENU})
    self.Menu.HarassMode:MenuElement({id = "UseW", name = "(W) Enable/Disable All Usage", value = true})
    self.Menu.HarassMode:MenuElement({id = "UseE", name = "(E) Enable/Disable All Usage", value = true})
    self.Menu:MenuElement({id = "TwitchOrbMode", name = "Orbwalker", type = MENU})
    self.Menu.TwitchOrbMode:MenuElement({id = "UseRangedHelperWalk", name = "RangedHelper: Movement Assist", value = false})
    self.Menu.TwitchOrbMode:MenuElement({id = "UseRangedHelperWalkInfo", name = "Assist Movement To Kite Enemies", type = SPACE})
    self.Menu.TwitchOrbMode:MenuElement({id = "RangedHelperMouseDistance", name = "Mouse Range From Target", value = 550, min = 0, max = 1500, step = 50})
    self.Menu.TwitchOrbMode:MenuElement({id = "RangedHelperMouseDistanceInfo", name = "Max Mouse Distance From Target To Kite", type = SPACE})
    self.Menu.TwitchOrbMode:MenuElement({id = "RangedHelperRange", name = "Kite Distance Adjustment", value = 100, min = -500, max = 500, step = 10})
    self.Menu.TwitchOrbMode:MenuElement({id = "RangedHelperRangeInfo", name = "Adjust the Kiting Distance By This Much", type = SPACE})
    self.Menu.TwitchOrbMode:MenuElement({id = "RangedHelperRangeFacing", name = "Kite Distance Adjustment (Fleeing)", value = -120, min = -500, max = 500, step = 10})
    self.Menu.TwitchOrbMode:MenuElement({id = "RangedHelperRangeFacingInfo", name = "Adjust the Kiting Distance Against A Fleeing Target", type = SPACE})
    self.Menu:MenuElement({id = "AutoMode", name = "Auto", type = MENU})
    self.Menu:MenuElement({id = "Draw", name = "Draw", type = MENU})
    self.Menu.Draw:MenuElement({id = "UseDraws", name = "Enable Draws", value = true})
    self.Menu.Draw:MenuElement({id = "DrawEHelper", name = "Draw E Help?", value = true})
    self.Menu.Draw:MenuElement({id = "EInfoX", name = "RInfo X Position", value = 1800, min = 0, max = 5000, step = 10})
    self.Menu.Draw:MenuElement({id = "EInfoY", name = "RInfo Y Position", value = 300, min = 0, max = 3000, step = 10})
    self.Menu.Draw:MenuElement({id = "EInfoSize", name = "RInfo Text Size", value = 10, min = 0, max = 50, step = 1})
    self.Menu.Draw:MenuElement({id = "DrawAA", name = "Draw AA range", value = false})
    self.Menu.Draw:MenuElement({id = "DrawQ", name = "Draw Q range", value = false})
    self.Menu.Draw:MenuElement({id = "DrawW", name = "Draw W range", value = false})
    self.Menu.Draw:MenuElement({id = "DrawE", name = "Draw E range", value = false})
    self.Menu.Draw:MenuElement({id = "DrawR", name = "Draw R range", value = false})
    self.Menu.Draw:MenuElement({id = "DrawCustom", name = "Draw A Custom Range Circle", value = false})
    self.Menu.Draw:MenuElement({id = "DrawCustomRange", name = "Custom Range Circle", value = 500, min = 0, max = 2000, step = 10})
end


function Twitch:Spells()
    --ESpellData = {speed = math.huge, range = ERange, delay = 0, angle = 50, radius = 0, collision = {}, type = "conic"}

    QSpellData = {speed = math.huge, range = 1400, delay = 0.10, radius = 30, collision = {}, type = "linear"}


    WSpellData = {speed = 1400, range = 950, delay = 0.25, radius = 120, collision = {}, type = "circular"}


    ESpellData = {speed = 1400, range = 1125, delay = 0.25, radius = 210, collision = {}, type = "linear"}
    RSpellData = {speed = math.huge, range = 5000, delay = 0.627, radius = 130, collision = {}, type = "circular"}

end


function Twitch:Draw()
    if self.Menu.Draw.UseDraws:Value() then
        DrawCounter = DrawCounter + 1
        if DrawCounter > 20 then
            DrawCounter = 0
        end
        local AARange = _G.SDK.Data:GetAutoAttackRange(myHero)
        if self.Menu.Draw.DrawAA:Value() then
            Draw.Circle(myHero.pos, AARange, 1, Draw.Color(255, 0, 191, 0))
        end
        if self.Menu.Draw.DrawQ:Value() then
            Draw.Circle(myHero.pos, QRange, 1, Draw.Color(255, 255, 0, 255))
        end
        if self.Menu.Draw.DrawW:Value() then
            Draw.Circle(myHero.pos, WRange, 1, Draw.Color(255, 0, 0, 255))
        end
        if self.Menu.Draw.DrawE:Value() then
            Draw.Circle(myHero.pos, ERange, 1, Draw.Color(255, 0, 0, 255))
        end
        if self.Menu.Draw.DrawR:Value() then
            Draw.Circle(myHero.pos, RRange, 1, Draw.Color(255, 255, 255, 255))
        end
        if self.Menu.Draw.DrawCustom:Value() then
            Draw.Circle(myHero.pos, self.Menu.Draw.DrawCustomRange:Value(), 1, Draw.Color(255, 0, 191, 0))
        end
        if #EnemiesEInfo > 0 and self.Menu.Draw.DrawEHelper:Value() then
            for i = 1, #EnemiesEInfo do
                local TextSize = self.Menu.Draw.EInfoSize:Value()
                local YLevel = self.Menu.Draw.EInfoY:Value() + ((TextSize*5)*i)
                local Xlevel = self.Menu.Draw.EInfoX:Value()
                if EnemiesEInfo[i].Enemy and EnemiesEInfo[i].Killable then
                    Draw.Text(EnemiesEInfo[i].Enemy.charName, TextSize, Xlevel, YLevel, Draw.Color(255, 0, 255, 0))
                    Draw.Text(math.floor(EnemiesEInfo[i].CurrentHealth), TextSize, Xlevel, YLevel+(TextSize*1.5), Draw.Color(255, 255, 255, 255))
                    Draw.Text("____", TextSize, Xlevel, YLevel+(TextSize*1.6), Draw.Color(255, 0, 0, 0))
                    Draw.Text(math.floor(EnemiesEInfo[i].MaxHealth), TextSize, Xlevel, YLevel+(TextSize*2.5), Draw.Color(255, 255, 255, 255))

                    Draw.Text(EnemiesEInfo[i].EDamage, TextSize, Xlevel+(TextSize*2.6), YLevel+(TextSize*1.5), Draw.Color(255, 0, 255, 0))
                    Draw.Text("____", TextSize, Xlevel+(TextSize*2.6), YLevel+(TextSize*1.6), Draw.Color(255, 0, 0, 0))
                    Draw.Text("E Dmg", TextSize, Xlevel+(TextSize*2.6), YLevel+(TextSize*2.5), Draw.Color(255, 0, 255, 0))

                    Draw.Text(math.floor(EnemiesEInfo[i].EDamage), 15, EnemiesEInfo[i].Enemy.pos:To2D().x+10, EnemiesEInfo[i].Enemy.pos:To2D().y-125, Draw.Color(255, 0, 255, 0))
                    Draw.Text("____", 15, EnemiesEInfo[i].Enemy.pos:To2D().x+10, EnemiesEInfo[i].Enemy.pos:To2D().y-124, Draw.Color(255, 0, 255, 0))
                    Draw.Text("E Dmg", 15, EnemiesEInfo[i].Enemy.pos:To2D().x+10, EnemiesEInfo[i].Enemy.pos:To2D().y-110, Draw.Color(255, 0, 255, 0))

                    if DrawCounter > 10 then
                        Draw.Text("KILL", 25, EnemiesEInfo[i].Enemy.pos:To2D().x-40, EnemiesEInfo[i].Enemy.pos:To2D().y-125, Draw.Color(255, 0, 255, 0))
                    else
                        Draw.Text("KILL", 25, EnemiesEInfo[i].Enemy.pos:To2D().x-40, EnemiesEInfo[i].Enemy.pos:To2D().y-125, Draw.Color(255, 255, 0, 0))
                    end

                else
                    Draw.Text(EnemiesEInfo[i].Enemy.charName, TextSize, Xlevel, YLevel, Draw.Color(255, 255, 0, 0))
                    Draw.Text(math.floor(EnemiesEInfo[i].CurrentHealth), TextSize, Xlevel, YLevel+(TextSize*1.5), Draw.Color(255, 255, 255, 255))
                    Draw.Text("____", TextSize, Xlevel, YLevel+(TextSize*1.6), Draw.Color(255, 0, 0, 0))
                    Draw.Text(math.floor(EnemiesEInfo[i].MaxHealth), TextSize, Xlevel, YLevel+(TextSize*2.5), Draw.Color(255, 255, 255, 255))

                    Draw.Text(EnemiesEInfo[i].EDamage, TextSize, Xlevel+(TextSize*2.6), YLevel+(TextSize*1.5), Draw.Color(255, 0, 0, 255))
                    Draw.Text("____", TextSize, Xlevel+(TextSize*2.6), YLevel+(TextSize*1.6), Draw.Color(255, 0, 0, 0))
                    Draw.Text("E Dmg", TextSize, Xlevel+(TextSize*2.6), YLevel+(TextSize*2.5), Draw.Color(255, 0, 0, 255))

                    Draw.Text(math.floor(EnemiesEInfo[i].CurrentHealth), 15, EnemiesEInfo[i].Enemy.pos:To2D().x-40, EnemiesEInfo[i].Enemy.pos:To2D().y-125, Draw.Color(255, 0, 0, 255))
                    Draw.Text("____", 15, EnemiesEInfo[i].Enemy.pos:To2D().x-40, EnemiesEInfo[i].Enemy.pos:To2D().y-124, Draw.Color(255, 0, 0, 0))
                    Draw.Text(math.floor(EnemiesEInfo[i].MaxHealth), 15, EnemiesEInfo[i].Enemy.pos:To2D().x-40, EnemiesEInfo[i].Enemy.pos:To2D().y-110, Draw.Color(255, 0, 0, 255))

                    Draw.Text(math.floor(EnemiesEInfo[i].EDamage), 15, EnemiesEInfo[i].Enemy.pos:To2D().x+10, EnemiesEInfo[i].Enemy.pos:To2D().y-125, Draw.Color(255, 0, 0, 255))
                    Draw.Text("____", 15, EnemiesEInfo[i].Enemy.pos:To2D().x+10, EnemiesEInfo[i].Enemy.pos:To2D().y-124, Draw.Color(255, 0, 0, 0))
                    Draw.Text("E Dmg", 15, EnemiesEInfo[i].Enemy.pos:To2D().x+10, EnemiesEInfo[i].Enemy.pos:To2D().y-110, Draw.Color(255, 0, 0, 255))
                end
            end
        end
    end
end



function Twitch:Tick()
    if _G.JustEvade and _G.JustEvade:Evading() or (_G.ExtLibEvade and _G.ExtLibEvade.Evading) or Game.IsChatOpen() or myHero.dead then return end
    target = GetTarget(2000)
    AARange = _G.SDK.Data:GetAutoAttackRange(myHero)
    if target then
        EAARange = _G.SDK.Data:GetAutoAttackRange(target)
    end
    if target and ValidTarget(target) then
        --PrintChat(target.pos:To2D())
        --PrintChat(mousePos:To2D())
        QMouseSpot = self:RangedHelper(target)
    else
        _G.SDK.Orbwalker.ForceMovement = nil
    end
    
    self:ProcessSpells()
    self:UpdateItems()
    self:Logic()
    self:Auto()
    self:Items2()

    if TickQ then

        TickQ= false
    end
    if TickW then

        TickW = false
    end
    if TickE then

        TickE = false
    end
    if TickR then

        TickR = false
    end
    if EnemyLoaded == false then
        local CountEnemy = 0
        for i, enemy in pairs(EnemyHeroes) do
            CountEnemy = CountEnemy + 1
        end
        if CountEnemy < 1 then
            GetEnemyHeroes()
        else
            EnemyLoaded = true
            PrintChat("Enemy Loaded")
        end
    end
end


function Twitch:UpdateItems()
    Item_HK[ITEM_1] = HK_ITEM_1
    Item_HK[ITEM_2] = HK_ITEM_2
    Item_HK[ITEM_3] = HK_ITEM_3
    Item_HK[ITEM_4] = HK_ITEM_4
    Item_HK[ITEM_5] = HK_ITEM_5
    Item_HK[ITEM_6] = HK_ITEM_6
    Item_HK[ITEM_7] = HK_ITEM_7
end

function Twitch:Items1()
    if GetItemSlot(myHero, 3074) > 0 and ValidTarget(target, 300) then --rave 
        if myHero:GetSpellData(GetItemSlot(myHero, 3074)).currentCd == 0 then
            Control.CastSpell(Item_HK[GetItemSlot(myHero, 3074)])
        end
    end
    if GetItemSlot(myHero, 3077) > 0 and ValidTarget(target, 300) then --tiamat
        if myHero:GetSpellData(GetItemSlot(myHero, 3077)).currentCd == 0 then
            Control.CastSpell(Item_HK[GetItemSlot(myHero, 3077)])
        end
    end
    if GetItemSlot(myHero, 3144) > 0 and ValidTarget(target, 550) then --bilge
        if myHero:GetSpellData(GetItemSlot(myHero, 3144)).currentCd == 0 then
            Control.CastSpell(Item_HK[GetItemSlot(myHero, 3144)], target)
        end
    end
    if GetItemSlot(myHero, 3153) > 0 and ValidTarget(target, 550) then -- botrk
        if myHero:GetSpellData(GetItemSlot(myHero, 3153)).currentCd == 0 then
            Control.CastSpell(Item_HK[GetItemSlot(myHero, 3153)], target)
        end
    end
    if GetItemSlot(myHero, 3146) > 0 and ValidTarget(target, 700) then --gunblade hex
        if myHero:GetSpellData(GetItemSlot(myHero, 3146)).currentCd == 0 then
            Control.CastSpell(Item_HK[GetItemSlot(myHero, 3146)], target)
        end
    end
    if GetItemSlot(myHero, 3748) > 0 and ValidTarget(target, 300) then -- Titanic Hydra
        if myHero:GetSpellData(GetItemSlot(myHero, 3748)).currentCd == 0 then
            Control.CastSpell(Item_HK[GetItemSlot(myHero, 3748)])
        end
    end
end

function Twitch:Items2()
    if GetItemSlot(myHero, 3139) > 0 then
        if myHero:GetSpellData(GetItemSlot(myHero, 3139)).currentCd == 0 then
            if IsImmobile(myHero) then
                Control.CastSpell(Item_HK[GetItemSlot(myHero, 3139)], myHero)
            end
        end
    end
    if GetItemSlot(myHero, 3140) > 0 then
        if myHero:GetSpellData(GetItemSlot(myHero, 3140)).currentCd == 0 then
            if IsImmobile(myHero) then
                Control.CastSpell(Item_HK[GetItemSlot(myHero, 3140)], myHero)
            end
        end
    end
end

function Twitch:GetPassiveBuffs(unit, buffname)
    for i = 0, unit.buffCount do
        local buff = unit:GetBuff(i)
        if buff.name == buffname and buff.count > 0 then 
            return buff
        end
    end
    return nil
end


function Twitch:Auto()
    local EnemiesEInfoTemp = {}
    local InRange = 0
    local KillsInRange = 0
    for i, enemy in pairs(EnemyHeroes) do
        if enemy and not enemy.dead and ValidTarget(enemy) then
            local EEAARange = _G.SDK.Data:GetAutoAttackRange(enemy)
            local Venom = _G.SDK.BuffManager:GetBuff(enemy, "twitchdeadlyvenom")
            local VenomTargetID = enemy.networkID
            if VenomList[VenomTargetID] == nil then 
                VenomList[VenomTargetID] = {Stacks = 1, LastTick = 0} 
            end
            if Venom and Venom.count > 0 and Venom.duration > 0 then
                if VenomList[VenomTargetID].Stacks < 6 and Venom.startTime > VenomList[VenomTargetID].LastTick then
                    VenomList[VenomTargetID].Stacks = VenomList[VenomTargetID].Stacks + 1
                end
                VenomList[VenomTargetID].LastTick = Venom.startTime
            else
                VenomList[VenomTargetID].Stacks = 0
                VenomList[VenomTargetID].LastTick = 0
            end
            local DamageLists = self:DamageChecks(enemy)
            table.insert(EnemiesEInfoTemp, {Enemy = enemy, MaxHealth = enemy.maxHealth, CurrentHealth = enemy.health, Killable = DamageLists.EKills, MaxKillable = DamageLists.ERMaxKills, EDamage = DamageLists.EDamage, EMaxDamage = DamageLists.EMaxDamage})
            if (Mode() == "Combo" or Mode() == "Harass") and GetDistance(enemy.pos, myHero.pos) < ERange then
                InRange = InRange + 1
                if DamageLists.EKills then
                    KillsInRange = KillsInRange + 1
                end
            end
        end
    end
    --PrintChat(KillsInRange)
    --PrintChat(InRange)
    if KillsInRange > 0 and KillsInRange == InRange then
        --PrintChat("True Kills In Range")
        AutoEEnable = true
    else
        --PrintChat("False Kills In Range")
        AutoEEnable = false
    end
    EnemiesEInfo = EnemiesEInfoTemp
end 

function Twitch:DamageChecks(unit)



    local AAdmg = getdmg("AA", unit, myHero)
    local Edmg = getdmg("E", unit, myHero)
    if VenomList[unit.networkID] then
        local stacks = VenomList[unit.networkID].Stacks
        Edmg = Edmg * stacks
        --PrintChat(stacks)
    end

    local UnitHealth = unit.health + unit.shieldAD
    local ECheck = UnitHealth - (Edmg) < 0
    local EMaxdmg = getdmg("E", unit, myHero, 2) * 6
    local ECheckMax = UnitHealth - EMaxdmg < 0

    local DamageArray = {EKills = ECheck, EDamage = Edmg, AADamage = AAdmg, EMaxDamage = EMaxdmg, MaxKillable = ECheckMax}
    return DamageArray
end

function Twitch:CanUse(spell, mode)
    if mode == nil then
        mode = Mode()
    end
    --PrintChat(Mode())
    if spell == _Q then
        if mode == "Combo" and IsReady(spell) and self.Menu.ComboMode.UseQ:Value() then
            return true
        end
        if mode == "Harass" and IsReady(spell) and self.Menu.HarassMode.UseQ:Value() then
            return true
        end
        if mode == "Auto" and IsReady(spell) and self.Menu.AutoMode.UseQ:Value() then
            return true
        end
        if mode == "Force" and IsReady(spell) then
            return true
        end
    elseif spell == _W then
        if mode == "Combo" and IsReady(spell) and self.Menu.ComboMode.UseW:Value() then
            return true
        end
        if mode == "Harass" and IsReady(spell) and self.Menu.HarassMode.UseW:Value() then
            return true
        end
        if mode == "Force" and IsReady(spell) then
            return true
        end
    elseif spell == _E then
        if mode == "Combo" and IsReady(spell) and self.Menu.ComboMode.UseE:Value() then
            return true
        end
        if mode == "Harass" and IsReady(spell) and self.Menu.HarassMode.UseE:Value() then
            return true
        end
        if mode == "Force" and IsReady(spell) then
            return true
        end
    elseif spell == _R then
        if mode == "Combo" and IsReady(spell) and self.Menu.ComboMode.UseR:Value() then
            return true
        end
        if mode == "Harass" and IsReady(spell) and self.Menu.HarassMode.UseR:Value() then
            return true
        end
        if mode == "Force" and IsReady(spell) then
            return true
        end
    end
    return false
end

function Twitch:Logic()

    if target == nil then 
        if Game.Timer() - TargetTime > 2 then
            WasInRange = false
        end
        return 
    end

    if Mode() == "Combo" or Mode() == "Harass" and target then

        local DamageList = self:DamageChecks(target)
        self:Items1()

        if Game.Timer() - TargetTime > 2 then
            WasInRange = false
        end
        if GetDistance(myHero.pos, target.pos) < AARange then
            TargetTime = Game.Timer()
            WasInRange = true
        end

        if self:CanUse(_E, Mode()) and self:CastingChecksE() and not (myHero.pathing and myHero.pathing.isDashing) then
            if self.Menu.ComboMode.ComboModeE.UseEFinish:Value() and AutoEEnable then
                self:UseE()
            end
        end
        if self:CanUse(_W, Mode()) and ValidTarget(target, WRange) and self:CastingChecksW() and not (myHero.pathing and myHero.pathing.isDashing) then
            if self.Menu.ComboMode.UseW:Value() and not _G.SDK.Attack:IsActive() and (not Invisible or self.Menu.ComboMode.ComboModeW.InvisW:Value()) then
                self:UseW(target)
            end
        end
    end     
end

function Twitch:ClosestPointOnLineSegment(p, p1, p2)
    local px = p.x
    local pz = p.z
    local ax = p1.x
    local az = p1.z
    local bx = p2.x
    local bz = p2.z
    local bxax = bx - ax
    local bzaz = bz - az
    local t = ((px - ax) * bxax + (pz - az) * bzaz) / (bxax * bxax + bzaz * bzaz)
    if (t < 0) then
        return p1, false
    end
    if (t > 1) then
        return p2, false
    end
    return {x = ax + t * bxax, z = az + t * bzaz}, true
end

function Twitch:RangedHelper(unit)
    local EAARangel = _G.SDK.Data:GetAutoAttackRange(unit)
    local MoveSpot = nil
    local RangeDif = AARange - EAARangel
    local ExtraRangeDist = RangeDif + self.Menu.TwitchOrbMode.RangedHelperRange:Value()
    local ExtraRangeChaseDist = RangeDif + self.Menu.TwitchOrbMode.RangedHelperRangeFacing:Value()

    local ScanDirection = Vector((myHero.pos-mousePos):Normalized())
    local ScanDistance = GetDistance(myHero.pos, unit.pos) * 0.8
    local ScanSpot = myHero.pos - ScanDirection * ScanDistance

    local MouseDirection = Vector((unit.pos-ScanSpot):Normalized())
    local MouseSpotDistance = EAARangel + ExtraRangeDist
    if not IsFacing(unit) then
        MouseSpotDistance = EAARangel + ExtraRangeChaseDist
    end
    if MouseSpotDistance > AARange then
        MouseSpotDistance = AARange
    end

    local MouseSpot = unit.pos - MouseDirection * (MouseSpotDistance)
    local QMouseSpotDirection = Vector((myHero.pos-MouseSpot):Normalized())
    local QmouseSpotDistance = GetDistance(myHero.pos, MouseSpot)
    if QmouseSpotDistance > 300 then
        QmouseSpotDistance = 300
    end
    local QMouseSpoty = myHero.pos - QMouseSpotDirection * QmouseSpotDistance
    MoveSpot = MouseSpot

    if MoveSpot then
        if GetDistance(myHero.pos, MoveSpot) < 50 then
            _G.SDK.Orbwalker.ForceMovement = nil
        elseif self.Menu.TwitchOrbMode.UseRangedHelperWalk:Value() and GetDistance(myHero.pos, unit.pos) <= AARange-50 and (Mode() == "Combo" or Mode() == "Harass") then
            _G.SDK.Orbwalker.ForceMovement = MoveSpot
        else
            _G.SDK.Orbwalker.ForceMovement = nil
        end
    end
    return QMouseSpoty
end


function Twitch:ProcessSpells()
    CastingQ = myHero.activeSpell.name == "TwitchTumble" 
    CastingW = myHero.activeSpell.name == "TwitchVenomCask"
    CastingE = myHero.activeSpell.name == "TwitchExpunge"
    CastingR = myHero.activeSpell.name == "TwitchFinalHour" 

    --PrintChat(myHero.activeSpell.name)

    Invisible = _G.SDK.BuffManager:HasBuff(myHero, "globalcamouflage")
    InvisibleDuration = _G.SDK.BuffManager:GetBuffDuration(myHero, "globalcamouflage")

    if target then
        --local SilverBuff = _G.SDK.BuffManager:GetBuffCount(target, "twitchdeadlyvenom")
        --PrintChat(SilverBuff)
    end

    if myHero:GetSpellData(_Q).currentCd == 0 then
        CastedQ = false
    else
        if CastedQ == false then
            TickQ = true
            LastSpellCasted = "Q"
        end
        CastedQ = true
    end
    if myHero:GetSpellData(_W).currentCd == 0 then
        CastedW = false
    else
        if CastedW == false then
            TickW = true
            LastSpellCasted = "W"
        end
        CastedW = true
    end
    if myHero:GetSpellData(_E).currentCd == 0 then
        CastedE = false
    else
        if CastedE == false then
            TickE = true
            LastSpellCasted = "E"
        end
        CastedE = true
    end
    if myHero:GetSpellData(_R).currentCd == 0 then
        CastedR = false
    else
        if CastedR == false then
            TickR = true
            LastSpellCasted = "R"
        end
        CastedR = true
    end
end

function Twitch:CastingChecks()
    if not CastingQ and not CastingW and not CastingE and not CastingR then
        return true
    else
        return false
    end
end

function Twitch:CastingChecksW()
    if not CastingW and not CastingE then
        return true
    else
        return false
    end
end


function Twitch:CastingChecksE()
    if not CastingW and not CastingE then
        return true
    else
        return false
    end
end


function Twitch:CastingChecksQ()
    if not CastingQ and not CastingE then
        return true
    else
        return false
    end
end

function Twitch:OnPostAttack(args)

end

function Twitch:OnPostAttackTick(args)
end

function Twitch:OnPreAttack(args)
end


function Twitch:UseW(unit)
    local pred = _G.PremiumPrediction:GetPrediction(myHero, unit, WSpellData)
    if pred.CastPos and myHero.pos:DistanceTo(pred.CastPos) < WRange then
        --PrintChat("Casting W")
        Control.CastSpell(HK_W, pred.CastPos)
    end 
end

function Twitch:UseE()
    Control.CastSpell(HK_E)
end

function OnLoad()
    Manager()
end
