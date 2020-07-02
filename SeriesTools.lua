require "PremiumPrediction"
require "DamageLib"
require "2DGeometry"
require "MapPositionGOS"

local EnemyHeroes = {}
local AllyHeroes = {}
local EnemySpawnPos = nil
-- [ AutoUpdate ] --
do
    
    local Version = 102.00
    
    local Files = {
        Lua = {
            Path = SCRIPT_PATH,
            Name = "SeriesTools.lua",
            Url = "https://raw.githubusercontent.com/LegoNioh/Series/master/SeriesTools.lua"
        },
        Version = {
            Path = SCRIPT_PATH,
            Name = "SeriesTools.version",
            Url = "https://raw.githubusercontent.com/LegoNioh/Series/master/SeriesTools.version"    -- check if Raw Adress correct pls.. after you have create the version file on Github
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
    
    --AutoUpdate()

end

local function IsNearEnemyTurret(pos, distance)
    --PrintChat("Checking Turrets")
    local turrets = _G.SDK.ObjectLoader:GetTurrets(GetDistance(pos) + 1000)
    for i = 1, #turrets do
        local turret = turrets[i]
        if turret and GetDistance(turret.pos, pos) <= distance+915 and turret.team == 300-myHero.team then
            --PrintChat("turret")
            return turret
        end
    end
    return nil
end


local function IsUnderEnemyTurret(pos, dist)
    --PrintChat("Checking Turrets")
    if not dist then
        dist = 0
    end

    local turrets = _G.SDK.ObjectManager:GetTurrets(GetDistance(pos) + 1000+dist)
    for i = 1, #turrets do
        local turret = turrets[i]
        if turret and GetDistance(turret.pos, pos) <= 915 and turret.team == 300-myHero.team then
            --PrintChat("turret")
            return turret
        end
    end
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

local function GetWaypoints(unit) -- get unit's waypoints
    local waypoints = {}
    local pathData = unit.pathing
    table.insert(waypoints, unit.pos)
    if pathData.hasMovePath and pathData.pathCount > 0 then
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
        if buff.name == buffname and buff.count > 0 then 
            return buff.count
        end
    end
    return 0
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

function SetMovement(bool)
    if _G.PremiumOrbwalker then
        _G.PremiumOrbwalker:SetAttack(bool)
        _G.PremiumOrbwalker:SetMovement(bool)       
    elseif _G.SDK then
        _G.SDK.Orbwalker:SetMovement(bool)
        _G.SDK.Orbwalker:SetAttack(bool)
    end
end

function AntiDash(unit)
    local path = unit.pathing;
    local PathStart = unit.pathing.pathIndex
    local PathEnd = unit.pathing.pathCount
    if PathStart and PathEnd and PathStart >= 0 and PathEnd <= 20 and path.hasMovePath then
        for i = path.pathIndex, path.pathCount do
            local path_vec = unit:GetPath(i)
            if path.isDashing then
                return path_vec
            end
        end
    end
    return false
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
class "Loader"

function Loader:__init()
    if myHero.charName then
        DelayAction(function() self:LoadUtility() end, 1.05)
    end
end


function Loader:LoadUtility()
    Utility:Spells()
    Utility:Menu()
    --
    --GetEnemyHeroes()

    for i = 1, Game.ObjectCount() do
        local object = Game.Object(i)
        
        if not object.isAlly and object.type == Obj_AI_SpawnPoint then 
            EnemySpawnPos = object
            break
        end
    end
    Callback.Add("Tick", function() Utility:Tick() end)
    Callback.Add("Draw", function() Utility:Draw() end)
end


class "Utility"

local EnemyLoaded = false
local recalls = {}
local Exhaust = nil
local ExhaustSpell = nil
local Range = 650

function Utility:Menu()
    self.Menu = MenuElement({type = MENU, id = "Utility", name = "Series Tools"})
    self.Menu:MenuElement({id = "ExKey", name = "Exhaust Key", key = string.byte("A"), value = false})  
    self.Menu:MenuElement({id = "MeleeKey", name = "Melee Helper Toggle Key", key = string.byte("H"), toggle = true, value = true})
    self.Menu:MenuElement({id = "OrbMode", name = "Orbwalker", type = MENU})
    self.Menu.OrbMode:MenuElement({id = "UseMeleeHelper", name = "Enable MeleeHelper", value = true})
    self.Menu.OrbMode:MenuElement({id = "MeleeHelperMouseDistance", name = "Mouse Distance From Target To Enable", value = 550, min = 0, max = 1500, step = 50})
    self.Menu.OrbMode:MenuElement({id = "MeleeHelperExtraDistance", name = "Extra Distance To Stick To target", value = 0, min = 0, max = 1500, step = 10})
    self.Menu:MenuElement({id = "Draw", name = "Draw", type = MENU})
    self.Menu.Draw:MenuElement({id = "UseDraws", name = "Enable Draws", value = false})
    self.Menu.Draw:MenuElement({id = "DrawSummonerRange", name = "Enable Summoner Range", value = false})
    self.Menu.Draw:MenuElement({id = "MeleeHelperSpot", name = "Draw Melee Helper Spot", value = false})
    self.Menu.Draw:MenuElement({id = "MeleeHelperDistance", name = "Draw Melee Helper Mouse Distance", value = false})
    self.Menu.Draw:MenuElement({id = "MeleeHelperText", name = "Draw Melee Helper Text (On/Off)", value = false})
end

function Utility:Spells()
end

function Utility:Tick()
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
    if Game.IsChatOpen() or myHero.dead then return end
    --PrintChat(myHero.activeSpell.name)
    target = GetTarget(1400)
    self:MeleeHelper()
    if self.Menu.ExKey:Value() then
    	self:Exhaust()
    end
    if myHero:GetSpellData(SUMMONER_1).name:find("Exhaust") or myHero:GetSpellData(SUMMONER_1).name:find("Dot") then
        Exhaust = SUMMONER_1
        ExhaustSpell = HK_SUMMONER_1
        if myHero:GetSpellData(SUMMONER_1).name:find("Dot") then
            Range = 600
        else
            Range = 650
        end
    elseif myHero:GetSpellData(SUMMONER_2).name:find("Exhaust") or myHero:GetSpellData(SUMMONER_2).name:find("Dot")  then
        Exhaust = SUMMONER_2
        ExhaustSpell = HK_SUMMONER_2
        if myHero:GetSpellData(SUMMONER_2).name:find("Dot") then
            Range = 600
        else
            Range = 650
        end
    else 
        Exhaust = nil
    end
end

function Utility:DrawMeleeHelper()
    local AARange = _G.SDK.Data:GetAutoAttackRange(myHero)
    local MoveSpot = nil

    local TargetUnderTurret = false
    local HeroUnderTurret = IsUnderEnemyTurret(myHero.pos, -200)
    if target then
        TargetUnderTurret = IsUnderEnemyTurret(target.pos)
    end
    local TurretCheck = not TargetUnderTurret or (TargetUnderTurret and HeroUnderTurret)

    if self.Menu.MeleeKey:Value() and self.Menu.OrbMode.UseMeleeHelper:Value() and target and Mode() == "Combo" and TurretCheck and GetDistance(mousePos, target.pos) < self.Menu.OrbMode.MeleeHelperMouseDistance:Value() and GetDistance(target.pos) <= AARange + self.Menu.OrbMode.MeleeHelperExtraDistance:Value() then
        local MouseDirection = Vector((target.pos-mousePos):Normalized())
        local MouseDistance = GetDistance(mousePos, target.pos)
        local MouseSpotDistance = AARange - target.boundingRadius
        if IsFacing(target) then
            MouseSpotDistance = AARange - 10
            --PrintChat("Facing")
        end
        local MouseSpot = target.pos - MouseDirection * (MouseSpotDistance)
        MoveSpot = MouseSpot
        return MoveSpot
        --PrintChat("Forcing")
    else
        return nil
    end
end

function Utility:MeleeHelper()
    local AARange = _G.SDK.Data:GetAutoAttackRange(myHero)
    local MoveSpot = nil

    local TargetUnderTurret = false
    local HeroUnderTurret = IsUnderEnemyTurret(myHero.pos, - 200) ~= nil
    if HeroUnderTurret == true then
        PrintChat("true")
    end

    if target then
        TargetUnderTurret = IsUnderEnemyTurret(target.pos) ~= nil
        if TargetUnderTurret == true then
            --PrintChat("True")
        end
    end
    local TurretCheck = not TargetUnderTurret or (TargetUnderTurret and HeroUnderTurret)

    if self.Menu.MeleeKey:Value() and self.Menu.OrbMode.UseMeleeHelper:Value() and target and Mode() == "Combo" and TurretCheck and GetDistance(mousePos, target.pos) < self.Menu.OrbMode.MeleeHelperMouseDistance:Value() and GetDistance(target.pos) <= AARange + self.Menu.OrbMode.MeleeHelperExtraDistance:Value() then
        local MouseDirection = Vector((target.pos-mousePos):Normalized())
        local MouseDistance = GetDistance(mousePos, target.pos)
        local MouseSpotDistance = AARange - target.boundingRadius
        if IsFacing(target) then
            MouseSpotDistance = AARange - 10
            --PrintChat("Facing")
        end
        local MouseSpot = target.pos - MouseDirection * (MouseSpotDistance)
        MoveSpot = MouseSpot
        _G.SDK.Orbwalker.ForceMovement = MoveSpot
        --PrintChat("Forcing")
    else
        _G.SDK.Orbwalker.ForceMovement = nil
    end
    if MoveSpot and GetDistance(MoveSpot) < 50 then
        _G.SDK.Orbwalker:SetMovement(false)
        --PrintChat("False")
    else
        _G.SDK.Orbwalker:SetMovement(true)
    end
end

function Utility:Draw()
    if self.Menu.Draw.UseDraws:Value() then
        if self.Menu.Draw.DrawSummonerRange:Value() then
            Draw.Circle(myHero.pos, Range, 1, Draw.Color(255, 0, 191, 255))
        end
        if self.Menu.OrbMode.UseMeleeHelper:Value() and target and self.Menu.Draw.MeleeHelperDistance:Value() then
            Draw.Circle(target.pos, self.Menu.OrbMode.MeleeHelperMouseDistance:Value(), 1, Draw.Color(255, 0, 0, 0))
        end
        if self.Menu.OrbMode.UseMeleeHelper:Value() and target and self.Menu.Draw.MeleeHelperSpot:Value() then
            local MeleeSpot = self:DrawMeleeHelper()
            if MeleeSpot then
                Draw.Circle(MeleeSpot, 25, 1, Draw.Color(255, 0, 100, 255))
                Draw.Circle(MeleeSpot, 35, 1, Draw.Color(255, 0, 100, 255))
                Draw.Circle(MeleeSpot, 45, 1, Draw.Color(255, 0, 100, 255))
            end
        end
        if self.Menu.Draw.MeleeHelperText:Value() then
            if self.Menu.MeleeKey:Value() and self.Menu.OrbMode.UseMeleeHelper:Value() then
                Draw.Text("Melee Helper On", 10, myHero.pos:To2D().x, myHero.pos:To2D().y-130, Draw.Color(255, 0, 255, 0))
                --InfoBarSprite:Draw(myHero.pos:To2D().x,myHero.pos:To2D().y)
            else
                Draw.Text("Melee Helper On", 10, myHero.pos:To2D().x, myHero.pos:To2D().y-130, Draw.Color(255, 255, 0, 0))
                --InfoBarSprite:Draw(myHero.pos:To2D().x,myHero.pos:To2D().y)
            end
        end
    end
end

function Utility:Exhaust()
    local TargetEnemy = nil
    if target and ValidTarget(target, Range) then
        TargetEnemy = target
    else
        for i, enemy in pairs(EnemyHeroes) do
            if enemy and not enemy.dead and ValidTarget(enemy, Range) then
                if not TargetEnemy or enemy.ap >= TargetEnemy.ap then
                    TargetEnemy = enemy
                end
            end
        end
    end
    if TargetEnemy and Exhaust and IsReady(Exhaust) then
        Control.CastSpell(ExhaustSpell, TargetEnemy)
    end
end




function OnLoad()
    Loader()
end
