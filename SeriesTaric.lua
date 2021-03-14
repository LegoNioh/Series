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
    
    local Version = 1001.0
    
    local Files = {
        Lua = {
            Path = SCRIPT_PATH,
            Name = "SeriesMelee.lua",
            Url = "https://raw.githubusercontent.com/LegoNioh/Series/master/SeriesTaric.lua"
        },
        Version = {
            Path = SCRIPT_PATH,
            Name = "SeriesMelee.version",
            Url = "https://raw.githubusercontent.com/LegoNioh/Series/master/SeriesTaric.version"    -- check if Raw Adress correct pls.. after you have create the version file on Github
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
            return buff.startTime
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
    if myHero.charName == "Taric" then
        DelayAction(function() self:LoadTaric() end, 1.05)
    end
end

function Manager:LoadTaric()
    Taric:Spells()
    Taric:Menu()
    --
    --GetEnemyHeroes()
    Callback.Add("Tick", function() Taric:Tick() end)
    Callback.Add("Draw", function() Taric:Draw() end)
    if _G.SDK then
        _G.SDK.Orbwalker:OnPreAttack(function(...) Taric:OnPreAttack(...) end)
        _G.SDK.Orbwalker:OnPostAttackTick(function(...) Taric:OnPostAttackTick(...) end)
        _G.SDK.Orbwalker:OnPostAttack(function(...) Taric:OnPostAttack(...) end)
    end
end

class "Taric"

local EnemyLoaded = false
local AllyLoaded = false
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
local Qstacks = 0


local SilverBuff = 0
local UsedSilverBuff
local PredSilverBuff = 0
local QPostAttackTime = 0
local LastTarget = nil

local WRange = 800
local TeatherRange = 1300
local ERange = 575
local RRange = 5000
local QRange = 325

local BindedAlly = nil

local EMouseSpot = nil

local WasAttacking = false

local CameraMoving = false

local Mounted = true


local DangerBindedW = false
local DangerHeroW = false
local DangerBinded = false
local DangerHero = false

local BindedTime = 0

local AllyTargetInRange = false

function Taric:Menu()
    self.Menu = MenuElement({type = MENU, id = "Taric", name = "Taric"})
    self.Menu:MenuElement({id = "UseEFlashKey", name = "N/A", key = string.byte("T"), value = false})
    self.Menu:MenuElement({id = "UseEFlashInfo", name = "N/A", type = SPACE})
    self.Menu:MenuElement({id = "ComboMode", name = "Combo", type = MENU})
    self.Menu.ComboMode:MenuElement({id = "UseQWChamps", name = "N/A", type = MENU})
    self.Menu.ComboMode:MenuElement({id = "ComboModeQ", name = "Q Settings", type = MENU})
    self.Menu.ComboMode.ComboModeQ:MenuElement({id = "UseQHeal", name = "(Q) To Heal Yourself", value = true})
    self.Menu.ComboMode.ComboModeQ:MenuElement({id = "UseQHealInfo", name = "Enable Healing Based on Your HP", type = SPACE})
    self.Menu.ComboMode.ComboModeQ:MenuElement({id = "UseQHealHP", name = "HP% To Heal Self", value = 40, min = 0, max = 100, step = 1})
    self.Menu.ComboMode.ComboModeQ:MenuElement({id = "UseQHealHPLow", name = "HP% To Heal Self and Ignore Stacks", value = 10, min = 0, max = 100, step = 1})
    self.Menu.ComboMode.ComboModeQ:MenuElement({id = "UseQHealStacks", name = "Starlight Stacks To Heal Self", value = 4, min = 0, max = 5, step = 1})
    self.Menu.ComboMode.ComboModeQ:MenuElement({id = "UseQHealAlly", name = "(Q) To Heal Allies", value = true})
    self.Menu.ComboMode.ComboModeQ:MenuElement({id = "UseQHealAllyInfo", name = "Enable Healing Based on Your HP", type = SPACE})
    self.Menu.ComboMode.ComboModeQ:MenuElement({id = "UseQHealAllyHP", name = "HP% To Heal Ally", value = 40, min = 0, max = 100, step = 1})
    self.Menu.ComboMode.ComboModeQ:MenuElement({id = "UseQHealAllyHPLow", name = "HP% To Heal Ally and Ignore Stacks", value = 10, min = 0, max = 100, step = 1})
    self.Menu.ComboMode.ComboModeQ:MenuElement({id = "UseQHealAllyStacks", name = "Starlight Stacks To Heal Ally", value = 3, min = 0, max = 5, step = 1})
    self.Menu.ComboMode.ComboModeQ:MenuElement({id = "UseQPassive", name = "(Q) Pause For passive", value = true})
    self.Menu.ComboMode.ComboModeQ:MenuElement({id = "UseQPassiveInfo", name = "Stop Q Casting When your passive Is Active", type = SPACE})
    self.Menu.ComboMode.ComboModeQ:MenuElement({id = "UseQPassiveSpam", name = "(Q) Cast Q To Proc Passive", value = false})
    self.Menu.ComboMode.ComboModeQ:MenuElement({id = "UseQPassiveSpamInfo", name = "Cast Q if in AA Range to proc Passive", type = SPACE})
    self.Menu.ComboMode:MenuElement({id = "UseQ", name = "(Q) Enable/Disable All Usage", value = true})
    self.Menu.ComboMode:MenuElement({id = "ComboModeW", name = "W Settings", type = MENU})
    self.Menu.ComboMode.ComboModeW:MenuElement({id = "UseWBind", name = "(W) To Bind To Ally", value = true})
    self.Menu.ComboMode.ComboModeW:MenuElement({id = "UseWBindInfo", name = "Bind To Allies With W", type = SPACE})
    self.Menu.ComboMode.ComboModeW:MenuElement({id = "UseWBindChamps", name = "Allies To Bind With", type = MENU})
    self.Menu.ComboMode.ComboModeW:MenuElement({id = "UseWShield", name = "(W) To Shield", value = true})
    self.Menu.ComboMode.ComboModeW:MenuElement({id = "UseWShieldHeroHP", name = "HP% To Shield Hero", value = 40, min = 0, max = 100, step = 1})
    self.Menu.ComboMode.ComboModeW:MenuElement({id = "UseWShieldAllyHP", name = "HP% To Shield Ally", value = 40, min = 0, max = 100, step = 1})
    self.Menu.ComboMode.ComboModeW:MenuElement({id = "UseWPassive", name = "(W) Pause For Passive", value = true})
    self.Menu.ComboMode.ComboModeW:MenuElement({id = "UseWPassiveInfo", name = "Stop Casting W When Your Passive IS Active", type = SPACE})
    self.Menu.ComboMode.ComboModeW:MenuElement({id = "UseWPassiveSpam", name = "(W) Cast To Proc Passive", value = false})
    self.Menu.ComboMode.ComboModeW:MenuElement({id = "UseWPassiveSpamInfo", name = "Cast W if in AA range to Proc Passive", type = SPACE})
    self.Menu.ComboMode:MenuElement({id = "UseW", name = "(W) Enable/Disable All Usage", value = true})
    self.Menu.ComboMode:MenuElement({id = "ComboModeE", name = "E Settings", type = MENU})
    self.Menu.ComboMode.ComboModeE:MenuElement({id = "UseEStun", name = "(E) To Stun The Target", value = true})
    self.Menu.ComboMode.ComboModeE:MenuElement({id = "UseEStunInfo", name = "Stun Your Target With E", type = SPACE})
    self.Menu.ComboMode.ComboModeE:MenuElement({id = "UseEStunAlly", name = "(E) To Stun The Target from ally", value = true})
    self.Menu.ComboMode.ComboModeE:MenuElement({id = "UseEStunAllyInfo", name = "Stun Your Target With E from your ally", type = SPACE})
    self.Menu.ComboMode.ComboModeE:MenuElement({id = "UseEPush", name = "(E) To Stun Gap Closers", value = true})
    self.Menu.ComboMode.ComboModeE:MenuElement({id = "UseEPushInfo", name = "Stun Target If Too Close", type = SPACE})
    self.Menu.ComboMode.ComboModeE:MenuElement({id = "UseEPushAuto", name = "(E) Auto Stun Gapclosers", value = true})
    self.Menu.ComboMode.ComboModeE:MenuElement({id = "UseEPushAutoInfo", name = "Stun Gap Closers Without Combo Key Held", type = SPACE})
    self.Menu.ComboMode:MenuElement({id = "UseE", name = "(E) Enable/Disable All Usage", value = true})
    self.Menu:MenuElement({id = "HarassMode", name = "Harass", type = MENU})
    self.Menu.HarassMode:MenuElement({id = "UseQ", name = "(Q) Enable/Disable All Usage", value = true})
    self.Menu.HarassMode:MenuElement({id = "UseW", name = "(W) Enable/Disable All Usage", value = true})
    self.Menu.HarassMode:MenuElement({id = "UseE", name = "(E) Enable/Disable All Usage", value = true})
    self.Menu:MenuElement({id = "AutoMode", name = "Auto", type = MENU})
    self.Menu.AutoMode:MenuElement({id = "AutoModeW", name = "W Settings", type = MENU})
    self.Menu.AutoMode.AutoModeW:MenuElement({id = "UseWShield", name = "(W) To Shield", value = true})
    self.Menu.AutoMode.AutoModeW:MenuElement({id = "UseWShieldHeroHP", name = "HP% To Shield Hero", value = 40, min = 0, max = 100, step = 1})
    self.Menu.AutoMode.AutoModeW:MenuElement({id = "UseWShieldAllyHP", name = "HP% To Shield Ally", value = 40, min = 0, max = 100, step = 1})
    self.Menu.AutoMode.AutoModeW:MenuElement({id = "UseWPassive", name = "(W) Pause For Passive", value = true})
    self.Menu.AutoMode.AutoModeW:MenuElement({id = "UseWPassiveInfo", name = "Stop Casting W When Your Passive IS Active", type = SPACE})
    self.Menu.AutoMode:MenuElement({id = "UseW", name = "(W) Enable/Disable All Usage", value = true})
    self.Menu.AutoMode:MenuElement({id = "AutoModeQ", name = "Q Settings", type = MENU})
    self.Menu.AutoMode.AutoModeQ:MenuElement({id = "UseQHeal", name = "(Q) To Heal Yourself", value = true})
    self.Menu.AutoMode.AutoModeQ:MenuElement({id = "UseQHealInfo", name = "Enable Healing Based on Your HP", type = SPACE})
    self.Menu.AutoMode.AutoModeQ:MenuElement({id = "UseQHealHP", name = "HP% To Heal Self", value = 40, min = 0, max = 100, step = 1})
    self.Menu.AutoMode.AutoModeQ:MenuElement({id = "UseQHealHPLow", name = "HP% To Heal Self and Ignore Stacks", value = 10, min = 0, max = 100, step = 1})
    self.Menu.AutoMode.AutoModeQ:MenuElement({id = "UseQHealStacks", name = "Starlight Stacks To Heal Self", value = 4, min = 0, max = 5, step = 1})
    self.Menu.AutoMode.AutoModeQ:MenuElement({id = "UseQHealAlly", name = "(Q) To Heal Allies", value = true})
    self.Menu.AutoMode.AutoModeQ:MenuElement({id = "UseQHealAllyInfo", name = "Enable Healing Based on Your HP", type = SPACE})
    self.Menu.AutoMode.AutoModeQ:MenuElement({id = "UseQHealAllyHP", name = "HP% To Heal Ally", value = 40, min = 0, max = 100, step = 1})
    self.Menu.AutoMode.AutoModeQ:MenuElement({id = "UseQHealAllyHPLow", name = "HP% To Heal Ally and Ignore Stacks", value = 10, min = 0, max = 100, step = 1})
    self.Menu.AutoMode.AutoModeQ:MenuElement({id = "UseQHealAllyStacks", name = "Starlight Stacks To Heal Ally", value = 3, min = 0, max = 5, step = 1})
    self.Menu.AutoMode.AutoModeQ:MenuElement({id = "UseQPassive", name = "(Q) Pause For passive", value = true})
    self.Menu.AutoMode.AutoModeQ:MenuElement({id = "UseQPassiveInfo", name = "Stop Q Casting When your passive Is Active", type = SPACE})
    self.Menu.AutoMode:MenuElement({id = "UseQ", name = "(Q) Enable/Disable All Usage", value = true})
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

function Taric:MenuBindWFunction()
    for i, ally in pairs(AllyHeroes) do
        self.Menu.ComboMode.ComboModeW.UseWBindChamps:MenuElement({id = ally.charName, name = ally.charName, value = true})
    end
end


function Taric:Spells()
    --ESpellData = {speed = math.huge, range = ERange, delay = 0, angle = 50, radius = 0, collision = {}, type = "conic"}

    QSpellData = {speed = math.huge, range = 1400, delay = 0.10, radius = 30, collision = {}, type = "linear"}
    WSpellData = {speed = math.huge, range = 1000, delay = 0.75, radius = 120, collision = {}, type = "circular"}
    ESpellData = {speed = 1400, range = 1125, delay = 0.25, radius = 210, collision = {}, type = "linear"}
    RSpellData = {speed = math.huge, range = 5000, delay = 0.627, radius = 130, collision = {}, type = "circular"}

end


function Taric:Draw()
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
        if (BindedAlly ~= nil and not BindedAlly.dead) then
            Draw.Text(BindedAlly.charName, 10, myHero.pos:To2D().x+5, myHero.pos:To2D().y-130, Draw.Color(255, 0, 255, 0))
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



function Taric:Tick()
    if _G.JustEvade and _G.JustEvade:Evading() or (_G.ExtLibEvade and _G.ExtLibEvade.Evading) or Game.IsChatOpen() or myHero.dead then return end
    target = GetTarget(2000)
    AARange = _G.SDK.Data:GetAutoAttackRange(myHero)
    if target then
        EAARange = _G.SDK.Data:GetAutoAttackRange(target)
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
            self:MenuBindWFunction()
            EnemyLoaded = true
            PrintChat("Enemy Loaded")
        end
    end
    if AllyLoaded == false then
        local CountAlly = 0
        for i, ally in pairs(AllyHeroes) do
            CountAlly = CountAlly + 1
        end
        if CountAlly < 1 then
            GetAllyHeroes()
        else
            AllyLoaded = true
            PrintChat("Ally Loaded")
        end
    end
end


function Taric:UpdateItems()
    Item_HK[ITEM_1] = HK_ITEM_1
    Item_HK[ITEM_2] = HK_ITEM_2
    Item_HK[ITEM_3] = HK_ITEM_3
    Item_HK[ITEM_4] = HK_ITEM_4
    Item_HK[ITEM_5] = HK_ITEM_5
    Item_HK[ITEM_6] = HK_ITEM_6
    Item_HK[ITEM_7] = HK_ITEM_7
end

function Taric:Items1()
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

function Taric:Items2()
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

function Taric:GetPassiveBuffs(unit, buffname)
    for i = 0, unit.buffCount do
        local buff = unit:GetBuff(i)
        if buff.name == buffname and buff.count > 0 then 
            return buff
        end
    end
    return nil
end


function Taric:Auto()
    DangerBinded = false
    DangerHero = false
    DangerHeroW = false
    DangerBindedW = false

    local AllyLowestHP = nil
    local AllyCarry = nil
    local AllyTank = nil
    local AllyCriticalCarry = nil
    local AllyCriticalHP = nil
    local AllyTargetRange = nil

    local PossibleWTargetTemp = false

    for i, ally in pairs(AllyHeroes) do
        if ally and not ally.dead then
            local WActive = BuffActive(ally, "taricwallybuff")
            if WActive then
                if BindedAlly == nil or BindedAlly.networkID ~= ally.networkID then
                    BindedTime = WActive
                    BindedAlly = ally
                end
            end
            if Mode() == "Combo" or Mode() == "Harass" then
                if GetDistance(ally.pos, myHero.pos) < 1300 then
                    PossibleWTargetTemp = true
                    if GetDistance(ally.pos, myHero.pos) < WRange and self.Menu.ComboMode.ComboModeW.UseWBindChamps[ally.charName]:Value() and ally ~= myHero then
                        local AllyHealthPercent = (ally.health / ally.maxHealth) * 100  
                        if AllyLowestHP == nil or ally.health < AllyLowestHP.health then
                            AllyLowestHP = ally
                            if AllyHealthPercent < 30 then
                                AllyCriticalHP = ally
                            end
                        end
                        if AllyTank == nil or ally.maxHealth > AllyTank.maxHealth then
                            if ally.maxHealth > myHero.maxHealth * 1.5 and AllyHealthPercent > 20 then
                                AllyTank = ally
                            end
                        end
                        if AllyCarry == nil or (ally.ap + ally.totalDamage) > (AllyCarry.ap + AllyCarry.totalDamage) then
                            if (ally.ap + ally.totalDamage) > (myHero.ap + myHero.totalDamage) * 2 then
                                AllyCarry = ally
                                if AllyHealthPercent < 40 then
                                    AllyCriticalCarry = ally
                                end
                            end
                        end
                        if target and GetDistance(target.pos, myHero.pos) > ERange and GetDistance(ally.pos, target.pos) < ERange then
                            AllyTargetRange = ally
                            --PrintChat("Ally in range")
                        end
                    end
                end
            end
        end
    end
    AllyTargetInRange = PossibleWTargetTemp
    if self:CanUse(_W, Mode()) and self.Menu.ComboMode.ComboModeW.UseWBind:Value() and self:CastingChecks() and ValidTarget(target, 1900) and not (myHero.pathing and myHero.pathing.isDashing) then
        if AllyCriticalCarry ~= nil then
            if BindedAlly == nil or BindedAlly.networkID ~= AllyCriticalCarry.networkID then
                self:UseW(AllyCriticalCarry)
                --PrintChat("AllyCriticalCarry")
            end
        elseif AllyCriticalHP ~= nil then
            if BindedAlly == nil or BindedAlly.networkID ~= AllyCriticalHP.networkID then
                self:UseW(AllyCriticalHP)
                --PrintChat("AllyCriticalHP")
            end
        elseif AllyTargetRange ~= nil then
            if BindedAlly then
                --PrintChat(BindedAlly.networkID)
                --PrintChat(AllyTargetRange.networkID)
                --PrintChat("------------------")
            end
            if BindedAlly == nil or BindedAlly.networkID ~= AllyTargetRange.networkID then
                self:UseW(AllyTargetRange)
            end
        elseif AllyTank ~= nil then
            if BindedAlly == nil or BindedAlly.networkID ~= AllyTank.networkID then
                self:UseW(AllyTank)
                --PrintChat("AllyTank")
            end
        elseif AllyCarry ~= nil then
            if BindedAlly == nil or BindedAlly.networkID ~= AllyCarry.networkID then
                self:UseW(AllyCarry)
                --PrintChat("AllyCarry")
            end
        elseif AllyLowestHP ~= nil then
            if BindedAlly == nil or BindedAlly.networkID ~= AllyLowestHP.networkID then
                self:UseW(AllyLowestHP)
                --PrintChat("AllyLowestHP")
            end
        end
    end
    for i, enemy in pairs(EnemyHeroes) do
        if enemy and not enemy.dead and ValidTarget(enemy) then

            if (BindedAlly ~= nil and not BindedAlly.dead) then
                if GetDistance(enemy.pos, BindedAlly.pos) < 700 then
                    DangerBindedW = true
                    DangerBinded = true
                elseif GetDistance(enemy.pos, BindedAlly.pos) < 700 then
                    DangerBinded = true
                end
            end
            if GetDistance(enemy.pos, myHero.pos) < 700 then
                DangerHeroW = true
                DangerHero = true
            elseif GetDistance(enemy.pos, myHero.pos) < 700 then
                DangerHero = true
            end

            local EEAARange = _G.SDK.Data:GetAutoAttackRange(enemy)
            local EPushRange = 250
            if EAARange < 250 then
                EPushRange = EEAARange + 10
            end
            if Mode() == "Combo" or Mode() == "Harass" then
                if self:CanUse(_E, Mode()) and self:CastingChecksE() and not (myHero.pathing and myHero.pathing.isDashing) then
                    --PrintChat(Game.Timer() - BindedTime)
                    if self.Menu.ComboMode.ComboModeE.UseEStun:Value() and ValidTarget(enemy, ERange) then
                        self:UseE(enemy)
                        --PrintChat("Stunning")
                    elseif self.Menu.ComboMode.ComboModeE.UseEStunAlly:Value() and (BindedAlly ~= nil and not BindedAlly.dead) and  ValidTarget(enemy, 2000) and GetDistance(enemy.pos, BindedAlly.pos) < ERange and Game.Timer() - BindedTime > 0.10 then
                        self:UseE(enemy)
                    elseif self.Menu.ComboMode.ComboModeE.UseEPush:Value() and  ValidTarget(enemy, ERange)  and GetDistance(enemy.pos, myHero.pos) <= EPushRange then
                        self:UseE(enemy)
                    elseif self.Menu.ComboMode.ComboModeE.UseEPush:Value() and (BindedAlly ~= nil and not BindedAlly.dead) and ValidTarget(enemy, 2000)  and GetDistance(enemy.pos, BindedAlly.pos) <= EPushRange and Game.Timer() - BindedTime > 0.10 then
                        self:UseE(enemy)
                    end
                end
            else
                if self:CanUse(_E, "Force") and self.Menu.ComboMode.ComboModeE.UseEPushAuto:Value() and self:CastingChecksE() and not (myHero.pathing and myHero.pathing.isDashing) then
                    if ValidTarget(enemy, ERange) and GetDistance(enemy.pos, myHero.pos) <= EPushRange then
                        self:UseE(enemy)
                    elseif (BindedAlly ~= nil and not BindedAlly.dead) and ValidTarget(enemy, 2000) and GetDistance(enemy.pos, BindedAlly.pos) <= EPushRange then
                        self:UseE(enemy)
                    end
                end
            end
        end
    end
    if self:CanUse(_Q, "Auto") and self:CastingChecks() and not (myHero.pathing and myHero.pathing.isDashing) then
        local HealthPercent = (myHero.health / myHero.maxHealth) * 100  
        if HealthPercent < self.Menu.AutoMode.AutoModeQ.UseQHealHP:Value() and self.Menu.AutoMode.AutoModeQ.UseQHeal:Value() and (self.Menu.AutoMode.AutoModeQ.UseQHealStacks:Value() <= Qstacks or HealthPercent < self.Menu.AutoMode.AutoModeQ.UseQHealHPLow:Value()) then
            if HealthPercent < self.Menu.AutoMode.AutoModeQ.UseQHealHPLow:Value() or (not PassiveActiveChecks or not self.Menu.AutoMode.AutoModeQ.UseQPassive:Value()) then
                self:UseQ()
            end
        end
        if (BindedAlly ~= nil and not BindedAlly.dead) and self.Menu.AutoMode.AutoModeQ.UseQHealAlly:Value() then
            local HealthPercent2 = (BindedAlly.health / BindedAlly.maxHealth) * 100
            if HealthPercent2 < self.Menu.AutoMode.AutoModeQ.UseQHealAllyHP:Value() and (self.Menu.AutoMode.AutoModeQ.UseQHealAllyStacks:Value() <= Qstacks or HealthPercent2 < self.Menu.AutoMode.AutoModeQ.UseQHealAllyHPLow:Value()) then
                if HealthPercent2 < self.Menu.AutoMode.AutoModeQ.UseQHealAllyHPLow:Value() or (not PassiveActiveChecks or not self.Menu.AutoMode.AutoModeQ.UseQPassive:Value()) then
                    self:UseQ()
                end
            end
        end
    end
    if self:CanUse(_W, "Auto") and self.Menu.AutoMode.AutoModeW.UseWShield:Value() and self:CastingChecks() and not (myHero.pathing and myHero.pathing.isDashing) then
        local MyHealthPercent = (myHero.health / myHero.maxHealth) * 100
        if MyHealthPercent < self.Menu.AutoMode.AutoModeW.UseWShieldHeroHP:Value() then
            if MyHealthPercent < 10 or (not PassiveActiveChecks or not self.Menu.AutoMode.AutoModeW.UseWPassive:Value()) then
                self:UseW(myHero)
            end
        end
        if (BindedAlly ~= nil and not BindedAlly.dead) and GetDistance(BindedAlly.pos, myHero.pos) < WRange then
            local HealthPercent = (BindedAlly.health / BindedAlly.maxHealth) * 100
            if HealthPercent < self.Menu.AutoMode.AutoModeW.UseWShieldAllyHP:Value() then
                if HealthPercent < 10 or (not PassiveActiveChecks or not self.Menu.AutoMode.AutoModeW.UseWPassive:Value()) then
                    self:UseW(BindedAlly)
                end
            end
        end
    end


end 

function Taric:CanUse(spell, mode)
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
        if mode == "Auto" and IsReady(spell) and self.Menu.AutoMode.UseW:Value() then
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
        if mode == "Auto" and IsReady(spell) and self.Menu.AutoMode.UseE:Value() then
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
        if mode == "Auto" and IsReady(spell) and self.Menu.AutoMode.UseR:Value() then
            return true
        end
    end
    return false
end

function Taric:Logic()

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
            QPostAttackTime = Game.Timer()
        end
        WasAttacking = false
    end



    if Mode() == "Combo" or Mode() == "Harass" and target then
        local PassiveActiveChecks = PassiveActive and GetDistance(target.pos, myHero.pos) < AARange
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
        if self:CanUse(_Q, Mode()) and self:CastingChecks() and ValidTarget(target) and (DangerHero or DangerBinded) and not (myHero.pathing and myHero.pathing.isDashing) then
            local HealthPercent = (myHero.health / myHero.maxHealth) * 100  
            if HealthPercent < self.Menu.ComboMode.ComboModeQ.UseQHealHP:Value() and self.Menu.ComboMode.ComboModeQ.UseQHeal:Value() and (self.Menu.ComboMode.ComboModeQ.UseQHealStacks:Value() <= Qstacks or HealthPercent < self.Menu.ComboMode.ComboModeQ.UseQHealHPLow:Value()) then
                if HealthPercent < self.Menu.ComboMode.ComboModeQ.UseQHealHPLow:Value() or (not PassiveActiveChecks or not self.Menu.ComboMode.ComboModeQ.UseQPassive:Value()) then
                    self:UseQ()
                end
            end
            if (BindedAlly ~= nil and not BindedAlly.dead) and self.Menu.ComboMode.ComboModeQ.UseQHealAlly:Value() then
                local HealthPercent2 = (BindedAlly.health / BindedAlly.maxHealth) * 100
                if HealthPercent2 < self.Menu.ComboMode.ComboModeQ.UseQHealAllyHP:Value() and (self.Menu.ComboMode.ComboModeQ.UseQHealAllyStacks:Value() <= Qstacks or HealthPercent2 < self.Menu.ComboMode.ComboModeQ.UseQHealAllyHPLow:Value()) then
                    if HealthPercent2 < self.Menu.ComboMode.ComboModeQ.UseQHealAllyHPLow:Value() or (not PassiveActiveChecks or not self.Menu.ComboMode.ComboModeQ.UseQPassive:Value()) then
                        self:UseQ()
                    end
                end
            end
            if not PassiveActive and self.Menu.ComboMode.ComboModeQ.UseQPassiveSpam:Value() and GetDistance(target.pos, myHero.pos) < AARange then
                self:UseQ()
            end
        end
        if self:CanUse(_W, Mode()) and self.Menu.ComboMode.ComboModeW.UseWShield:Value() and self:CastingChecks() and ValidTarget(target) and (DangerHeroW or DangerBindedW) and not (myHero.pathing and myHero.pathing.isDashing) then
            local MyHealthPercent = (myHero.health / myHero.maxHealth) * 100
            if MyHealthPercent < self.Menu.ComboMode.ComboModeW.UseWShieldHeroHP:Value() then
                if MyHealthPercent < 10 or (not PassiveActiveChecks or not self.Menu.ComboMode.ComboModeW.UseWPassive:Value()) then
                    self:UseW(myHero)
                end
            end
            if (BindedAlly ~= nil and not BindedAlly.dead) and GetDistance(BindedAlly.pos, myHero.pos) < WRange then
                local HealthPercent = (BindedAlly.health / BindedAlly.maxHealth) * 100
                if HealthPercent < self.Menu.ComboMode.ComboModeW.UseWShieldAllyHP:Value() then
                    if HealthPercent < 10 or (not PassiveActiveChecks or not self.Menu.ComboMode.ComboModeW.UseWPassive:Value()) then
                        self:UseW(BindedAlly)
                    end
                end
            end
            if not PassiveActive and self.Menu.ComboMode.ComboModeW.UseWPassiveSpam:Value() and GetDistance(target.pos, myHero.pos) < AARange then
                self:UseW(myHero)
            end
        end
    end     
end





function Taric:ClosestPointOnLineSegment(p, p1, p2)
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




function Taric:DamageChecks(unit)
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

function Taric:ProcessSpells()
    CastingQ = myHero.activeSpell.name == "TaricTumble" 
    CastingW = myHero.activeSpell.name == "TaricArcaneBarrage2"
    CastingE = myHero.activeSpell.name == "TaricCondemn"
    CastingR = myHero.activeSpell.name == "TaricFinalHour" 

    PassiveActive = BuffActive(myHero, "TaricPassiveAttack")
    --Kraken = BuffActive(myHero, "6672buff")
    Qstacks = myHero:GetSpellData(Qstacks).ammo
    --PrintChat(Qstacks)


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
            --PrintChat("TickW")
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

function Taric:CastingChecks()
    if not CastingQ and not CastingW and not CastingE and not CastingR then
        return true
    else
        return false
    end
end

function Taric:CastingChecksE()
    if not CastingQ and not CastingE then
        return true
    else
        return false
    end
end


function Taric:CastingChecksQ()
    if not CastingQ and not CastingE then
        return true
    else
        return false
    end
end

function Taric:OnPostAttack(args)

end

function Taric:OnPostAttackTick(args)
end

function Taric:OnPreAttack(args)
end


function Taric:UseQ(unit)
    Control.CastSpell(HK_Q)
end

function Taric:UseE(unit)
    Control.CastSpell(HK_E, unit)
end

function Taric:UseW(unit)
    Control.CastSpell(HK_W, unit)
end


function OnLoad()
    Manager()
end
